package MIDI::XML::Track;

use 5.006;
use strict;
use warnings;
use MIDI::Track;
use MIDI::Event;
use MIDI::XML::NoteOn;
use MIDI::XML::NoteOff;
use MIDI::XML::PolyKeyPressure;
use MIDI::XML::ControlChange;
use MIDI::XML::ProgramChange;
use MIDI::XML::ChannelKeyPressure;
use MIDI::XML::PitchBend;
use MIDI::XML::SequenceNumber;
use MIDI::XML::TextEvent;
use MIDI::XML::CopyrightNotice;
use MIDI::XML::TrackName;
use MIDI::XML::InstrumentName;
use MIDI::XML::Lyric;
use MIDI::XML::Marker;
use MIDI::XML::CuePoint;
use MIDI::XML::ProgramName;
use MIDI::XML::DeviceName;
use MIDI::XML::MidiChannelPrefix;
use MIDI::XML::Port;
use MIDI::XML::EndOfTrack;
use MIDI::XML::SetTempo;
use MIDI::XML::SmpteOffset;
use MIDI::XML::TimeSignature;
use MIDI::XML::KeySignature;
use MIDI::XML::SequencerSpecific;
use MIDI::XML::MetaEvent;
use MIDI::XML::SystemExclusive;
use MIDI::XML::EndOfExclusive;

our @ISA = qw();

=head1 NAME

MIDI::XML::Track - MIDI Tracks.

=head1 SYNOPSIS

  use MIDI::XML::Track;
  use MIDI::XML::TrackName;

  $Track = MIDI::XML::Track->new();
  $Track->number(0);

  $Track_Name = MIDI::XML::TrackName->new();
  $Track_Name->delta(0);
  $Track_Name->text('Silent Night');
  $Track->append($Track_Name);
  $Track->append(MIDI::XML::TimeSignature->new(['time_signature',0,4,2,96,8]));


  @xml = $Track->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::Track is an object oriented class for representing tracks in
Standard MIDI Files.

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

#==========================================================================

my $event2class = {
  'note_off'=>'MIDI::XML::NoteOff',
  'note_on'=>'MIDI::XML::NoteOn',
  'key_after_touch'=>'MIDI::XML::PolyKeyPressure',
  'control_change'=>'MIDI::XML::ControlChange',
  'patch_change'=>'MIDI::XML::ProgramChange',
  'channel_after_touch'=>'MIDI::XML::ChannelKeyPressure',
  'pitch_wheel_change'=>'MIDI::XML::PitchBend',
  'sysex_f0'=>'MIDI::XML::SystemExclusive',
  'sysex_f7'=>'MIDI::XML::EndOfExclusive',
  'set_sequence_number'=>'MIDI::XML::SequenceNumber',
  'text_event'=>'MIDI::XML::TextEvent',
  'copyright_text_event'=>'MIDI::XML::CopyrightNotice',
  'track_name'=>'MIDI::XML::TrackName',
  'instrument_name'=>'MIDI::XML::InstrumentName',
  'lyric'=>'MIDI::XML::Lyric',
  'marker'=>'MIDI::XML::Marker',
  'cue_point'=>'MIDI::XML::CuePoint',
  'program_name'=>'MIDI::XML::ProgramName',
  'text_event_08'=>'MIDI::XML::ProgramName',
  'device_name'=>'MIDI::XML::DeviceName',
  'text_event_09'=>'MIDI::XML::DeviceName',
#  'text_event_0a'=>'',
#  'text_event_0b'=>'',
#  'text_event_0c'=>'',
#  'text_event_0d'=>'',
#  'text_event_0e'=>'',
#  'text_event_0f'=>'',
  'midi_channel_prefix'=>'MIDI::XML::MidiChannelPrefix',
  'port'=>'MIDI::XML::Port',
  'end_track'=>'MIDI::XML::EndOfTrack',
  'set_tempo'=>'MIDI::XML::SetTempo',
  'smpte_offset'=>'MIDI::XML::SmpteOffset',
  'time_signature'=>'MIDI::XML::TimeSignature',
  'key_signature'=>'MIDI::XML::KeySignature',
  'sequencer_specific'=>'MIDI::XML::SequencerSpecific',
  'raw_meta_event'=>'MIDI::XML::MetaEvent',
#  'song_position'=>'MIDI::XML::SongPositionPointer',
#  'song_select'=>'MIDI::XML::SongSelect',
#  'tune_request'=>'MIDI::XML::TuneRequest'
#  'raw_data'=>''
};

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $xml_track = MIDI::XML::Track->new();

This creates a new MIDI::XML::Track object.

=item $xml_track = MIDI::XML::NoteOn->new({'from_track' => $midi_track});

Creates a new Track object initialized with the events in a 
MIDI::Track object.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $options_r = (defined($_[0]) and ref($_[0]) eq 'HASH') ? $_[0] : {};

    my $self = {
        '_Number'=> undef,
        '_Events'=> [],
        '_NoteOff'=> undef,
        '_NoteOn'=> undef,
        '_KeyAftertouch'=> undef,
        '_ControlChange'=> undef,
        '_ProgramChange'=> undef,
        '_ChannelAftertouch'=> undef,
        '_PitchBend'=> undef,
        '_SystemExclusive'=> undef,
        '_MidiTimeCodeQuarterFrame'=> undef,
        '_SongPositionPointer'=> undef,
        '_SongSelect'=> undef,
        '_TuneRequest'=> undef,
        '_EndOfExclusive'=> undef,
        '_SequenceNumber'=> undef,
        '_TextEvent'=> undef,
        '_CopyrightNotice'=> undef,
        '_TrackName'=> undef,
        '_InstrumentName'=> undef,
        '_Lyric'=> undef,
        '_Marker'=> undef,
        '_CuePoint'=> undef,
        '_ProgramName'=> undef,
        '_DeviceName'=> undef,
        '_MidiChannelPrefix'=> undef,
        '_Port'=> undef,
        '_EndOfTrack'=> undef,
        '_SetTempo'=> undef,
        '_SmpteOffset'=> undef,
        '_TimeSignature'=> undef,
        '_KeySignature'=> undef,
        '_SequencerSpecific'=> undef,
        '_MetaEvent'=> undef,
        '_End'=> undef,
    };

    bless($self,$class);
    if( exists( $options_r->{'from_track'} ) 
            && defined( $options_r->{'from_track'} ) )
    {
        $self->append_from_track( $options_r->{'from_track'}, $options_r );
    }

    return $self;
}

#==========================================================================

=item MIDI::XML::Track->register_subclass($event_name, $sub_class)

Registers a subclass the for MIDI::XML::Track objects to use to represent the
named event.  To work properly with the array methods the subclass name should
be the same as the orignal name.  For example:

$Track->register_subclass('sequencer_specific', 'MIDI::Huh::SequencerSpecific');

will allow the sequencer_specifics method to identify the subclass but

$Track->register_subclass('sequencer_specific', 'MIDI::Huh::SequinsAreSpecific');

will not.

=cut

sub register_subclass {
    my $self = shift;

    if ($#_ >0) {
        my ($event_name, $sub_class) = @_;
        $event2class->{$event_name} = $event_name;
    }
}

#==========================================================================
=item $number = $Track->number() or $Track->number($number)

Returns or optionally sets the track number for the Track object.

=cut

sub number {
    my $self = shift;
    if (@_) {
        $self->{'_Number'} = shift;
    }
    return  $self->{'_Number'};
}

#==========================================================================

=item $events = $Track->events()

Returns a reference to the array containing all the events associated with 
the track.

=cut

sub events {
    my $self = shift;
    return  $self->{'_Events'};
}

#==========================================================================

=item $Track->append($Event)

Appends an event to the event array in this MIDI::Xml:Track object.

=cut

sub append {
    my $self = shift;
    my $Event = shift;

    push @{$self->{'_Events'}},$Event if (defined($Event));
}

#==========================================================================

=item $Track->append_from_track($track)

Appends the events in a MIDI::Track object to the event array in this
MIDI::Xml:Track object.

=cut

sub append_from_track {
    my $self = shift;
    my $track = shift;
    my @events = $track->events();
    my $xml_event;
    foreach my $ev (@events) {
        $xml_event = undef;
        if ($ev->[0] eq 'note_on') {
            if ($ev->[4] == 0) {                 # note_on events with vel=0
                $ev->[0] = 'note_off';           # function as note_off
                $xml_event = $event2class->{'note_off'}->new($ev);
                $ev->[0] = 'note_on';
            } else {
                $xml_event = $event2class->{'note_on'}->new($ev);
            }
        } elsif ($ev->[0] eq 'raw_meta_event' and $ev->[2] == 0x20) {
            my $pev = ['midi_channel_prefix',$ev->[1],ord($ev->[3])];
            $xml_event = $event2class->{'midi_channel_prefix'}->new($pev);
        } elsif ($ev->[0] eq 'raw_meta_event' and $ev->[2] == 0x21) {
            my $pev = ['port',$ev->[1],ord($ev->[3])];
            $xml_event = $event2class->{'port'}->new($pev);
#        } elsif ($ev->[0] eq 'raw_data') {
        } elsif ($event2class->{ $ev->[0] }) {
            $xml_event = $event2class->{ $ev->[0] }->new($ev);
        }
        push @{$self->{'_Events'}},$xml_event if (defined($xml_event));
    } 
}

#==========================================================================

=item $Track->make_times_absolute()

Converts the event times from delta values to absolute values.

=cut

sub make_times_absolute {
    my $self = shift;
    my $abs = 0;
    my $del = 0;

    foreach my $event (@{$self->{'_Events'}}) {
        if (defined($event->delta())) {
            $abs += $event->delta();
            $event->absolute($abs);
        } elsif (defined($event->absolute())) {
            $abs = $event->absolute();
        }
    }
    $self->{'_End'} = $abs;
}

#==========================================================================

=item $Track->make_times_delta()

Converts the event times from absolute values to delta values.

=cut

sub make_times_delta {
    my $self = shift;
    my $abs = 0;
    my $del = 0;

    foreach my $event (@{$self->{'_Events'}}) {
        if (defined($event->absolute())) {
            $del = $abs - $event->absolute();
            $abs += $del;
            $event->delta($abs);
        } elsif (defined($event->delta())) {
            $abs += $event->delta();
        }
    }
    $self->{'_End'} = $abs;
}

#==========================================================================

=item $array_ref = $Track->note_ons() or $Track->note_ons('refresh');

Returns a reference to an array of all NoteOn objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub note_ons {
    my $self = shift;
    if (@_) {
        $self->{'_NoteOn'} = undef;
    }
    if (!defined($self->{'_NoteOn'})) {
        $self->{'_NoteOn'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::NoteOn$/) {
                push @{$self->{'_NoteOn'}},$event;
            }
        }
    }
    return  $self->{'_NoteOn'};
}

#==========================================================================

=item $array_ref = $Track->note_offs() or $Track->note_offs('refresh');

Returns a reference to an array of all NoteOff objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub note_offs {
    my $self = shift;
    if (@_) {
        $self->{'_NoteOff'} = undef;
    }
    if (!defined($self->{'_NoteOff'})) {
        $self->{'_NoteOff'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::NoteOff$/) {
                push @{$self->{'_NoteOff'}},$event;
            }
        }
    }
    return  $self->{'_NoteOff'};
}

#==========================================================================

=item $array_ref = $Track->control_changes() or $Track->control_changes('refresh');

Returns a reference to an array of all ControlChange objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub control_changes {
    my $self = shift;
    if (@_) {
        $self->{'_ControlChange'} = undef;
    }
    if (!defined($self->{'_ControlChange'})) {
        $self->{'_ControlChange'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::ControlChange$/) {
                push @{$self->{'_ControlChange'}},$event;
            }
        }
    }
    return  $self->{'_ControlChange'};
}

#==========================================================================

=item $array_ref = $Track->program_changes() or $Track->program_changes('refresh');

Returns a reference to an array of all ProgramChange objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub program_changes {
    my $self = shift;
    if (@_) {
        $self->{'_ProgramChange'} = undef;
    }
    if (!defined($self->{'_ProgramChange'})) {
        $self->{'_ProgramChange'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::ProgramChange$/) {
                push @{$self->{'_ProgramChange'}},$event;
            }
        }
    }
    return  $self->{'_ProgramChange'};
}

#==========================================================================

=item $array_ref = $Track->key_aftertouches() or $Track->key_aftertouches('refresh');

Returns a reference to an array of all KeyAftertouch objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub key_aftertouches {
    my $self = shift;
    if (@_) {
        $self->{'_KeyAftertouch'} = undef;
    }
    if (!defined($self->{'_KeyAftertouch'})) {
        $self->{'_KeyAftertouch'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::KeyAftertouch$/) {
                push @{$self->{'_KeyAftertouch'}},$event;
            }
        }
    }
    return  $self->{'_KeyAftertouch'};
}

#==========================================================================

=item $array_ref = $Track->channel_aftertouches() or $Track->channel_aftertouches('refresh');

Returns a reference to an array of all ChannelAftertouch objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub channel_aftertouches {
    my $self = shift;
    if (@_) {
        $self->{'_ChannelAftertouch'} = undef;
    }
    if (!defined($self->{'_ChannelAftertouch'})) {
        $self->{'_ChannelAftertouch'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::ChannelAftertouch$/) {
                push @{$self->{'_ChannelAftertouch'}},$event;
            }
        }
    }
    return  $self->{'_ChannelAftertouch'};
}

#==========================================================================

=item $array_ref = $Track->pitch_bend() or $Track->pitch_bend('refresh');

Returns a reference to an array of all PitchBend objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub pitch_bend {
    my $self = shift;
    if (@_) {
        $self->{'_PitchBend'} = undef;
    }
    if (!defined($self->{'_PitchBend'})) {
        $self->{'_PitchBend'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::Xml::PitchBend$/) {
                push @{$self->{'_PitchBend'}},$event;
            }
        }
    }
    return  $self->{'_PitchBend'};
}

#==========================================================================

=item $array_ref = $Track->sequence_numbers() or $Track->sequence_numbers('refresh');

Returns a reference to an array of all SequenceNumber objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub sequence_numbers {
    my $self = shift;
    if (@_) {
        $self->{'_SequenceNumber'} = undef;
    }
    if (!defined($self->{'_SequenceNumber'})) {
        $self->{'_SequenceNumber'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::SequenceNumber$/) {
                push @{$self->{'_SequenceNumber'}},$event;
            }
        }
    }
    return  $self->{'_SequenceNumber'};
}

#==========================================================================

=item $array_ref = $Track->text_events() or $Track->text_events('refresh');

Returns a reference to an array of all TextEvent objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub text_events {
    my $self = shift;
    if (@_) {
        $self->{'_TextEvent'} = undef;
    }
    if (!defined($self->{'_TextEvent'})) {
        $self->{'_TextEvent'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::TextEvent$/) {
                push @{$self->{'_TextEvent'}},$event;
            }
        }
    }
    return  $self->{'_TextEvent'};
}

#==========================================================================

=item $array_ref = $Track->copyrights() or $Track->copyrights('refresh');

Returns a reference to an array of all CopyrightNotice objects within the track.  If called 
with any parameter the array is refreshed before the reference is returned.

=cut

sub copyrights {
    my $self = shift;
    if (@_) {
        $self->{'_CopyrightNotice'} = undef;
    }
    if (!defined($self->{'_CopyrightNotice'})) {
        $self->{'_CopyrightNotice'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::CopyrightNotice$/) {
                push @{$self->{'_CopyrightNotice'}},$event;
            }
        }
    }
    return  $self->{'_CopyrightNotice'};
}

#==========================================================================

=item $array_ref = $Track->track_names() or $Track->track_names('refresh');

Returns a reference to an array of all TrackName objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub track_names {
    my $self = shift;
    if (@_) {
        $self->{'_TrackName'} = undef;
    }
    if (!defined($self->{'_TrackName'})) {
        $self->{'_TrackName'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::TrackName$/) {
                push @{$self->{'_TrackName'}},$event;
            }
        }
    }
    return  $self->{'_TrackName'};
}

#==========================================================================

=item $array_ref = $Track->instrument_names() or $Track->instrument_names('refresh');

Returns a reference to an array of all InstrumentName objects within the track. If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub instrument_names {
    my $self = shift;
    if (@_) {
        $self->{'_InstrumentName'} = undef;
    }
    if (!defined($self->{'_InstrumentName'})) {
        $self->{'_InstrumentName'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::InstrumentName$/) {
                push @{$self->{'_InstrumentName'}},$event;
            }
        }
    }
    return  $self->{'_InstrumentName'};
}

#==========================================================================

=item $array_ref = $Track->lyrics() or $Track->lyrics('refresh');

Returns a reference to an array of all Lyric objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub lyrics {
    my $self = shift;
    if (@_) {
        $self->{'_Lyric'} = undef;
    }
    if (!defined($self->{'_Lyric'})) {
        $self->{'_Lyric'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::Lyric$/) {
                push @{$self->{'_Lyric'}},$event;
            }
        }
    }
    return  $self->{'_Lyric'};
}

#==========================================================================

=item $array_ref = $Track->markers() or $Track->markers('refresh');

Returns a reference to an array of all Marker objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub markers {
    my $self = shift;
    if (@_) {
        $self->{'_Marker'} = undef;
    }
    if (!defined($self->{'_Marker'})) {
        $self->{'_Marker'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::Marker$/) {
                push @{$self->{'_Marker'}},$event;
            }
        }
    }
    return  $self->{'_Marker'};
}

#==========================================================================

=item $array_ref = $Track->cue_points() or $Track->cue_points('refresh');

Returns a reference to an array of all CuePoint objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub cue_points {
    my $self = shift;
    if (@_) {
        $self->{'_CuePoint'} = undef;
    }
    if (!defined($self->{'_CuePoint'})) {
        $self->{'_CuePoint'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::CuePoint$/) {
                push @{$self->{'_CuePoint'}},$event;
            }
        }
    }
    return  $self->{'_CuePoint'};
}

#==========================================================================

=item $array_ref = $Track->program_names() or $Track->program_names('refresh');

Returns a reference to an array of all ProgramName objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub program_names {
    my $self = shift;
    if (@_) {
        $self->{'_ProgramName'} = undef;
    }
    if (!defined($self->{'_ProgramName'})) {
        $self->{'_ProgramName'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::ProgramName$/) {
                push @{$self->{'_ProgramName'}},$event;
            }
        }
    }
    return  $self->{'_ProgramName'};
}

#==========================================================================

=item $array_ref = $Track->device_names() or $Track->device_names('refresh');

Returns a reference to an array of all DeviceName objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub device_names {
    my $self = shift;
    if (@_) {
        $self->{'_DeviceName'} = undef;
    }
    if (!defined($self->{'_DeviceName'})) {
        $self->{'_DeviceName'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::DeviceName$/) {
                push @{$self->{'_DeviceName'}},$event;
            }
        }
    }
    return  $self->{'_DeviceName'};
}

#==========================================================================

=item $array_ref = $Track->ports() or $Track->ports('refresh');

Returns a reference to an array of all Port objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub ports {
    my $self = shift;
    if (@_) {
        $self->{'_Port'} = undef;
    }
    if (!defined($self->{'_Port'})) {
        $self->{'_Port'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::Port$/) {
                push @{$self->{'_Port'}},$event;
            }
        }
    }
    return  $self->{'_Port'};
}

#==========================================================================

=item $array_ref = $Track->channel_prefixes() or $Track->channel_prefixes('refresh');

Returns a reference to an array of all MidiChannelPrefix objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub channel_prefixes {
    my $self = shift;
    if (@_) {
        $self->{'_MidiChannelPrefix'} = undef;
    }
    if (!defined($self->{'_MidiChannelPrefix'})) {
        $self->{'_MidiChannelPrefix'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::MidiChannelPrefix$/) {
                push @{$self->{'_MidiChannelPrefix'}},$event;
            }
        }
    }
    return  $self->{'_MidiChannelPrefix'};
}

#==========================================================================

=item $array_ref = $Track->ends_of_tracks() or $Track->ends_of_tracks('refresh');

Returns a reference to an array of all EndOfTrack objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub ends_of_tracks {
    my $self = shift;
    if (@_) {
        $self->{'_EndOfTrack'} = undef;
    }
    if (!defined($self->{'_EndOfTrack'})) {
        $self->{'_EndOfTrack'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::EndOfTrack$/) {
                push @{$self->{'_EndOfTrack'}},$event;
            }
        }
    }
    return  $self->{'_EndOfTrack'};
}

#==========================================================================

=item $array_ref = $Track->set_tempi() or $Track->set_tempi('refresh');

Returns a reference to an array of all SetTempo objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub set_tempi {
    my $self = shift;
    if (@_) {
        $self->{'_SetTempo'} = undef;
    }
    if (!defined($self->{'_SetTempo'})) {
        $self->{'_SetTempo'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::SetTempo$/) {
                push @{$self->{'_SetTempo'}},$event;
            }
        }
    }
    return  $self->{'_SetTempo'};
}

#==========================================================================

=item $array_ref = $Track->smpte_offsets() or $Track->smpte_offsets('refresh');

Returns a reference to an array of all SmpteOffset objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub smpte_offsets {
    my $self = shift;
    if (@_) {
        $self->{'_SmpteOffset'} = undef;
    }
    if (!defined($self->{'_SmpteOffset'})) {
        $self->{'_SmpteOffset'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::SmpteOffset$/) {
                push @{$self->{'_SmpteOffset'}},$event;
            }
        }
    }
    return  $self->{'_SmpteOffset'};
}

#==========================================================================

=item $array_ref = $Track->time_signatures() or $Track->time_signatures('refresh');

Returns a reference to an array of all TimeSignature objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub time_signatures {
    my $self = shift;
    if (@_) {
        $self->{'_TimeSignature'} = undef;
    }
    if (!defined($self->{'_TimeSignature'})) {
        $self->{'_TimeSignature'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::TimeSignature$/) {
                push @{$self->{'_TimeSignature'}},$event;
            }
        }
    }
    return  $self->{'_TimeSignature'};
}

#==========================================================================

=item $array_ref = $Track->key_signatures() or $Track->key_signatures('refresh');

Returns a reference to an array of all KeySignature objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub key_signatures {
    my $self = shift;
    if (@_) {
        $self->{'_KeySignature'} = undef;
    }
    if (!defined($self->{'_KeySignature'})) {
        $self->{'_KeySignature'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::KeySignature$/) {
                push @{$self->{'_KeySignature'}},$event;
            }
        }
    }
    return  $self->{'_KeySignature'};
}

#==========================================================================

=item $array_ref = $Track->sequencer_specifics() or $Track->sequencer_specifics('refresh');

Returns a reference to an array of all SequencerSpecific objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub sequencer_specifics {
    my $self = shift;
    if (@_) {
        $self->{'_SequencerSpecific'} = undef;
    }
    if (!defined($self->{'_SequencerSpecific'})) {
        $self->{'_SequencerSpecific'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::SequencerSpecific$/) {
                push @{$self->{'_SequencerSpecific'}},$event;
            }
        }
    }
    return  $self->{'_SequencerSpecific'};
}

#==========================================================================

=item $array_ref = $Track->meta_events() or $Track->meta_events('refresh');

Returns a reference to an array of all Port objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub meta_events {
    my $self = shift;
    if (@_) {
        $self->{'_MetaEvent'} = undef;
    }
    if (!defined($self->{'_MetaEvent'})) {
        $self->{'_MetaEvent'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::MetaEvent$/) {
                push @{$self->{'_MetaEvent'}},$event;
            }
        }
    }
    return  $self->{'_MetaEvent'};
}

#==========================================================================

=item $array_ref = $Track->system_exclusives() or $Track->system_exclusives('refresh');

Returns a reference to an array of all SystemExclusive objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub system_exclusives {
    my $self = shift;
    if (@_) {
        $self->{'_SystemExclusive'} = undef;
    }
    if (!defined($self->{'_SystemExclusive'})) {
        $self->{'_SystemExclusive'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::SystemExclusive$/) {
                push @{$self->{'_SystemExclusive'}},$event;
            }
        }
    }
    return  $self->{'_SystemExclusive'};
}

#==========================================================================

=item $array_ref = $Track->ends_of_exclusives() or $Track->ends_of_exclusives('refresh');

Returns a reference to an array of all EndOfExclusive objects within the track.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub ends_of_exclusives {
    my $self = shift;
    if (@_) {
        $self->{'_EndOfExclusive'} = undef;
    }
    if (!defined($self->{'_EndOfExclusive'})) {
        $self->{'_EndOfExclusive'} = [];
        foreach my $event (@{$self->{'_Events'}}) {
            if (ref($event) =~ /::EndOfExclusive$/) {
                push @{$self->{'_EndOfExclusive'}},$event;
            }
        }
    }
    return  $self->{'_EndOfExclusive'};
}

#==========================================================================

=item $end = $Track->end() or $Track->end('refresh');

Returns the absolute time for the end of the track.  If called with
any parameter the value is refreshed before it is returned.

=cut

sub end {
    my $self = shift;
    my $abs = 0;
    my $del = 0;

    if (@_) {
        $self->{'_End'} = undef;
    }
    if (defined($self->{'_End'})) {
        return  $self->{'_End'};
    }
    foreach my $event (@{$self->{'_Events'}}) {
        if (defined($event->delta())) {
            $abs += $event->delta();
            $event->absolute($abs);
        } elsif (defined($event->absolute())) {
            $abs = $event->absolute();
        }
    }
    $self->{'_End'} = $abs;
    return  $self->{'_End'};
}

#==========================================================================

=item $Midi_track = $Track->as_midi_track();

Returns a reference to an array of all objects within the track.

=cut

sub as_midi_track {
    my $self = shift;

    my $Midi_track = MIDI::Track->new();
    foreach my $evt (@{$self->{'_Events'}}) {
        my @midi_event = $evt->as_event();
        push @{$Midi_track->events_r}, \@midi_event;
    }
    return  $Midi_track;
}

#==========================================================================

=item @xml = $Track->as_MidiXML();

Returns an array of elements formatted according to the MidiXML DTD. These
elements may be assembled by track into entire documents with the following
suggested DOCTYPE declaration:

	<!DOCTYPE MIDI PUBLIC
		"-//Recordare//DTD MusicXML 0.7 MIDI//EN"
		"http://www.musicxml.org/dtds/midixml.dtd">

=back

=cut

sub as_MidiXML {
    my $self = shift;
    my @xml;
    my @events = @{$self->{'_Events'}};
    my $start = '<Track'
        . " Number=\"$self->{'_Number'}\""
        . '>';
    push @xml, $start;
    foreach my $evt (@{$self->{'_Events'}}) {
        push @xml, $evt->as_MidiXML();
    }
    push @xml, '</Track>';
    @xml;
}

#==========================================================================


return 1;
__END__

=head1 AUTHOR

Brian M. Ames, E<lt>bmames@apk.netE<gt>

=head1 SEE ALSO

L<MIDI::Track>, L<MIDI::Event>.

=head1 COPYRIGHT and LICENSE

Copyright 2002 Brian M. Ames.  This software may be used under the terms of
the GPL and Artistic licenses, the same as Perl itself. 

=cut

