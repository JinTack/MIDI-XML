package MIDI::XML::MidiFile;

use 5.006;
use strict;
use warnings;
use MIDI::Opus;

our @ISA = qw();

=head1 NAME

MIDI::XML::MIDI - MIDI file/stream data.

=head1 SYNOPSIS

use MIDI::XML::MidiFile;
use MIDI::XML::Track;

use MIDI::Opus;

unless (@ARGV) {
die "Usage: perl testmidixml.pl filename\n";
}

my $file = shift @ARGV;

my $opus = MIDI::Opus->new({ 'from_file' => "$file.mid"});
my $midi=MIDI::XML::MidiFile->new({'from_opus' => $opus});
my $measures = $midi->measures();
open XML,">","$file.xml";
print XML "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"; 
print XML join("\n",$midi->as_MidiXML());
close XML;

=head1 DESCRIPTION

MIDI::XML::MidiFile is a class for .

=head2 EXPORT

None by default.

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $obj = MIDI::XML::MIDI->new()

This creates a new MIDI::XML::MidiFile object.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $options_r = (defined($_[0]) and ref($_[0]) eq 'HASH') ? $_[0] : {};

    my $self = {
        '_Format'=> undef,
        '_TrackCount'=> undef,
        '_TicksPerBeat'=> undef,
        '_FrameRate'=> undef,
        '_TicksPerFrame'=> undef,
        '_TimestampType'=> undef,
        '_Tracks'=> [],
        '_Measures'=> undef,
    };

    bless($self,$class);
    if( exists( $options_r->{'from_opus'} ) 
            && defined( $options_r->{'from_opus'} ) )
    {
        $self->from_opus( $options_r->{'from_opus'}, $options_r );
    }

    return $self;
}

#==========================================================================

=item $format = $MidiFile->format() or $MidiFile->format($format)

Returns or optionally sets the format indicator for the MidiFile object. Valid
values are 0, 1, and 2.

=cut

sub format {
    my $self = shift;
    if (@_) {
        $self->{'_Format'} = shift;
    }
    return $self->{'_Format'};
}

#==========================================================================

=item $track_count = $MidiFile->track_count() or $MidiFile->track_count($track_count)

Returns or optionally sets the track count for the MidiFile object.  This does not
necessarilly indicate the number of Track objects contained by the tracks array.

=cut

sub track_count {
    my $self = shift;
    if (@_) {
        $self->{'_TrackCount'} = shift;
    }
    return  $self->{'_TrackCount'};
}

#==========================================================================

=item $ticks_per_beat = $MidiFile->ticks_per_beat() or $MidiFile->ticks_per_beat($ticks_per_beat)

Returns or optionally sets the ticks per beat for the MidiFile object. To avoid
contradictory values, frame_rate and ticks_per_frame are set to undef when 
ticks_per_beat is set. 

=cut

sub ticks_per_beat {
    my $self = shift;
    if (@_) {
        $self->{'_TicksPerBeat'} = shift;
        $self->{'_FrameRate'} = undef;
        $self->{'_TicksPerFrame'} = undef;
    }
    return  $self->{'_TicksPerBeat'};
}

#==========================================================================

=item $frame_rate = $MidiFile->frame_rate() or $MidiFile->frame_rate($frame_rate)

Returns or optionally sets the frame rate for the MidiFile object. To avoid
contradictory values, ticks_per_beat is set to undef when 
frame_rate is set. 

=cut

sub frame_rate {
    my $self = shift;
    if (@_) {
        $self->{'_FrameRate'} = shift;
        $self->{'_TicksPerBeat'} = undef;
    }
    return  $self->{'_FrameRate'};
}

#==========================================================================

=item $ticks_per_frame = $MidiFile->ticks_per_frame() or $MidiFile->ticks_per_frame($ticks_per_frame)

Returns or optionally sets the ticks per frame for the MidiFile object. To avoid
contradictory values, ticks_per_beat is set to undef when 
ticks_per_frame is set. 

=cut

sub ticks_per_frame {
    my $self = shift;
    if (@_) {
        $self->{'_TicksPerFrame'} = shift;
        $self->{'_TicksPerBeat'} = undef;
    }
    return  $self->{'_TicksPerFrame'};
}

#==========================================================================

=item $timestamp_type = $MidiFile->timestamp_type() or $MidiFile->timestamp_type($timestamp_type)

Returns or optionally sets the format indicator for the MidiFile object. Valid
values are Delta and Absolute.  This value is only used for the production of
MidiXML.

=cut

sub timestamp_type {
    my $self = shift;
    if (@_) {
        $self->{'_TimestampType'} = shift;
    }
    return  $self->{'_TimestampType'};
}

#==========================================================================

=item $tracks = $MidiFile->tracks()

Returns an array reference to the tracks contained in the MidiFile object.

=cut

sub tracks {
    my $self = shift;

    return  $self->{'_Tracks'};
}

#==========================================================================

=item $MidiFile->append($Track)

Appends a track to the track array in this MIDI::Xml:MidiFile object.

=cut

sub append {
    my $self = shift;
    my $Track = shift;

    push @{$self->{'_Tracks'}},$Track if (defined($Track));
}

#==========================================================================

=item $MidiFile->from_opus($Opus)

Appends the events in a MIDI::Opus object to the event array in this
MIDI::Xml:MidiFile object.

=cut

sub from_opus {
    my $self = shift;
    my $opus = shift;

    my $tracks = $opus->tracks_r();
    $self->{'_Format'} = $opus->format();
    $self->{'_TicksPerBeat'} = $opus->ticks();
    $self->{'_FrameRate'} = undef;
    $self->{'_TicksPerFrame'} = undef;
    $self->{'_TimestampType'} = 'Delta';
    $self->{'_Tracks'} = [];

    foreach my $trk (@{$tracks}) {
        push @{$self->{'_Tracks'}}, MIDI::XML::Track->new({from_track => $trk});
        $self->{'_Tracks'}->[-1]->number($#{$self->{'_Tracks'}});
    } 
    $self->{'_TrackCount'} = $#{$self->{'_Tracks'}}+1;
}

#==========================================================================

=item $Midi_opus = $MidiFile->as_midi_opus();

Returns a MIDI:Opus object constructed from this MidiFile object.

=cut

sub as_midi_opus {
    my $self = shift;

    my $Midi_opus = MIDI::Opus->new();
    foreach my $trk (@{$self->{'_Track'}}) {
        push @{$Midi_opus->tracks_r}, $trk->as_midi_track();
    }
    $Midi_opus->format($self->{'_Format'});
    $Midi_opus->ticks($self->{'_TicksPerBeat'});
    return  $Midi_opus;
}

#==========================================================================

=item $array_ref = $MidiFile->measures() or $MidiFile->measures('refresh');

Returns a reference to an array of measures.  If called with
any parameter the array is refreshed before the reference is returned.

=cut

sub measures {
    my $self = shift;
    my @measures;
    my @timesig;
    my $end = 0;

    if (@_) {
        $self->{'_Measures'} = undef;
    }
    if (defined($self->{'_Measures'})) {
        return  $self->{'_Measures'};
    }
    foreach my $track (@{$self->{'_Tracks'}}) {
        $track->make_times_absolute();
        my $e = $track->end();
        $end = $e if ($e > $end);
    }
    if (@_) {
    } else {
        my $tsigs = $self->{'_Tracks'}->[0]->time_signatures();
    foreach my $tsig (@{$tsigs}) {
        my $abs = $tsig->absolute();
        my $num = $tsig->numerator();
        my $log = $tsig->logDenominator();
        my $den = 2 ** $log;
        push @timesig, [$abs,$num,$den];
    }

    push @timesig, [$end,1,1];
    my $meas = 1;
    my $time=0;
    my $denom_ticks;
    for (my $i=0; $i<$#timesig; $i++) {
        my $lim = $timesig[$i+1]->[0];
        $denom_ticks = $self->{'_TicksPerBeat'} * 4 / $timesig[$i]->[2];
        my $divs = $denom_ticks * $timesig[$i]->[1];
        while ($time < $lim) {
            push @{$self->{'_Measures'}},[$time,$denom_ticks];
            print "$meas, $time, $denom_ticks\n";
            $meas++;
            $time += $divs;
        }
    }
    push @{$self->{'_Measures'}},[$time,$denom_ticks];

    return  $self->{'_Measures'};
}

#==========================================================================

=item @xml = $File->as_MidiXML();

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

    push @xml, '<MIDIFile>';
    if ( defined($self->{'_Format'})) {
        push @xml, "<Format>$self->{'_Format'}</Format>";
    }
    $self->{'_TrackCount'} = $#{$self->{'_Tracks'}}+1;
    if ( defined($self->{'_TrackCount'})) {
        push @xml, "<Tracks>$self->{'_TrackCount'}</Tracks>";
    }
    if ( defined($self->{'_TicksPerBeat'})) {
        push @xml, "<TicksPerBeat>$self->{'_TicksPerBeat'}</TicksPerBeat>";
    }
    if ( defined($self->{'_FrameRate'})) {
        push @xml, "<FrameRate>$self->{'_FrameRate'}</FrameRate>";
    }
    if ( defined($self->{'_TicksPerFrame'})) {
        push @xml, "<TicksPerFrame>$self->{'_TicksPerFrame'}</TicksPerFrame>";
    }
    if ( defined($self->{'_TimestampType'})) {
        push @xml, "<TimestampType>$self->{'_TimestampType'}</TimestampType>";
    }
    if ( defined($self->{'_Tracks'})) {
        foreach my $trk (@{$self->{'_Tracks'}}) {
            push @xml, $trk->as_MidiXML();
        }
    }
    push @xml, '</MIDIFile>';
    return @xml;
}

return 1;
__END__

=head1 AUTHOR

Brian M. Ames, E<lt>bmames@apk.netE<gt>

=head1 SEE ALSO

L<MIDI::Opus>, L<MIDI::XML::Parser>.

=head1 COPYRIGHT and LICENSE

Copyright 2002 Brian M. Ames.  This software may be used under the terms of
the GPL and Artistic licenses, the same as Perl itself. 

=cut

