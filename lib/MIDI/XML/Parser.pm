package MIDI::XML::Parser;

use 5.006;
use strict;
use warnings;
use MIDI::XML::MidiFile;
use vars qw($element2class $MidiFile $Track $Event %attr $cdata $delta $absolute);

our @ISA = qw();

=head1 NAME

MIDI::XML::Parser - SAX Parser for creating MidiFile objects 
from XML.

=head1 SYNOPSIS

  use MIDI::XML::Parser;
  $MidiFile = MIDI::XML::Parser->parse_MidiXML($file);

=head1 DESCRIPTION

MIDI::XML::MidiFile is a class for .

=head2 EXPORT

None by default.

our $VERSION = '0.01';


#my $MidiFile;
#my $Track;
#my $Event;
#my %attr;
#my $cdata;
#my $delta;
#my $absolute;

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item parse_MidiXML($file);

Parses a MidiXML file creating and returning a MidiFile object.

=cut

sub parse_MidiXML {
    my $class = shift;
    my $file = shift;

$element2class = {
  'NoteOff'             => 'MIDI::XML::NoteOff',
  'NoteOn'              => 'MIDI::XML::NoteOn',
  'PolyKeyPressure'     => 'MIDI::XML::PolyKeyPressure',
  'ControlChange'       => 'MIDI::XML::ControlChange',
  'AllSoundOff'         => 'MIDI::XML::ControlChange',
  'ResetAllControllers' => 'MIDI::XML::ControlChange',
  'LocalControl'        => 'MIDI::XML::ControlChange',
  'AllNotesOff'         => 'MIDI::XML::ControlChange',
  'OmniOff'             => 'MIDI::XML::ControlChange',
  'OmniOn'              => 'MIDI::XML::ControlChange',
  'MonoMode'            => 'MIDI::XML::ControlChange',
  'PolyMode'            => 'MIDI::XML::ControlChange',
  'ProgramChange'       => 'MIDI::XML::ProgramChange',
  'ChannelKeyPressure'  => 'MIDI::XML::ChannelKeyPressure',
  'PitchBendChange'     => 'MIDI::XML::PitchBend',
  'SystemExclusive'     => 'MIDI::XML::SystemExclusive',
  'EndOfExclusive'      => 'MIDI::XML::EndOfExclusive',
  'SequenceNumber'      => 'MIDI::XML::SequenceNumber',
  'TextEvent'           => 'MIDI::XML::TextEvent',
  'CopyrightNotice'     => 'MIDI::XML::CopyrightNotice',
  'TrackName'           => 'MIDI::XML::TrackName',
  'InstrumentName'      => 'MIDI::XML::InstrumentName',
  'Lyric'               => 'MIDI::XML::Lyric',
  'Marker'              => 'MIDI::XML::Marker',
  'CuePoint'            => 'MIDI::XML::CuePoint',
  'ProgramName'         => 'MIDI::XML::ProgramName',
  'DeviceName'          => 'MIDI::XML::DeviceName',
  'MidiChannelPrefix'   => 'MIDI::XML::MidiChannelPrefix',
  'Port'                => 'MIDI::XML::Port',
  'EndOfTrack'          => 'MIDI::XML::EndOfTrack',
  'SetTempo'            => 'MIDI::XML::SetTempo',
  'SmpteOffset'         => 'MIDI::XML::SmpteOffset',
  'TimeSignature'       => 'MIDI::XML::TimeSignature',
  'KeySignature'        => 'MIDI::XML::KeySignature',
  'SequencerSpecific'   => 'MIDI::XML::SequencerSpecific',
  'OtherMetaEvent'      => 'MIDI::XML::MetaEvent',
};

    my $parser = XML::Parser->new( Handlers => {
#       Init  => \&start_doc_MidiXML,
       Start => \&start_elem_MidiXML,
       Char  => \&char_data,
       End   => \&end_elem_MidiXML,
#       Final => \&end_doc_MidiXML,
    });
    $parser->parsefile($file);
    return $MIDI::XML::Parser::MidiFile;
    
}

#==========================================================================

=item start_elem($expat, $name, %attr);

Handler for XML::Parser start element events.

=cut

sub start_elem_MidiXML {
    my $expat;
    my $name;
    ($expat, $name, %MIDI::XML::Parser::attr) = @_;
    
#    print %attr,"\n";
    $MIDI::XML::Parser::cdata = undef;

    if ($name eq 'MIDIFile') {
        $MidiFile = MIDI::XML::MidiFile->new();
    } elsif ($name eq 'Format') {
    } elsif ($name eq 'Tracks') {
    } elsif ($name eq 'TicksPerBeat') {
    } elsif ($name eq 'FrameRate') {
    } elsif ($name eq 'TicksPerFrame') {
    } elsif ($name eq 'TimestampType') {
    } elsif ($name eq 'Track') {
        $Track = MIDI::XML::Track->new();
        $Track->number($attr{'Number'});
    } elsif ($name eq 'Event') {
        $delta = undef;
        $absolute = undef;
    } else {
    }
#    print $name, %attr, "\n";
}

#==========================================================================

=item char_data($expat, $name, $cdata);

Handler for XML::Parser character data events.

=cut

sub char_data {
    my $expat = shift;
    $MIDI::XML::Parser::cdata = shift;
}

#==========================================================================

=item end_elem($expat, $name);

Handler for XML::Parser end element events.

=back

=cut

sub end_elem_MidiXML {
    my $expat = shift;
    my $name = shift;

    if ($name eq 'MIDIFile') {
    } elsif ($name eq 'Format') {
        $MidiFile->format($cdata);
    } elsif ($name eq 'Tracks') {
        $MidiFile->track_count($cdata);
    } elsif ($name eq 'TicksPerBeat') {
        $MidiFile->ticks_per_beat($cdata);
    } elsif ($name eq 'FrameRate') {
        $MidiFile->frame_rate($cdata);
    } elsif ($name eq 'TicksPerFrame') {
        $MidiFile->ticks_per_frame($cdata);
    } elsif ($name eq 'TimestampType') {
        $MidiFile->timestamp_type($cdata);
    } elsif ($name eq 'Track') {
        $MidiFile->append($Track);
    } elsif ($name eq 'Delta') {
        $delta = $cdata + 0;
    } elsif ($name eq 'Absolute') {
        $absolute = $cdata + 0;
    } else {
        $attr{'_ELEMENT'} = $name;
        $attr{'_CDATA'} = $cdata;
        $attr{'Delta'} = $delta if (defined($delta));
        $attr{'Absolute'} = $absolute if (defined($absolute));
        if (${$element2class}{ $name }) {
#            print "$name\n";
            $Track->append($element2class->{ $name }->new(\%attr));
        }
    }

}



return 1;
__END__

=head1 AUTHOR

Brian M. Ames, E<lt>bmames@apk.netE<gt>

=head1 SEE ALSO

L<perl>.

=cut

