package MIDI::XML::TimeSignature;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::TimeSignature - MIDI Time Signature messages.

=head1 SYNOPSIS

  use MIDI::XML::TimeSignature;
  $Time_Sig = MIDI::XML::TimeSignature->new();
  $Time_Sig->delta(0);
  $Time_Sig->numerator(4);
  $Time_Sig->logDenominator(2);
  $Time_Sig->midiClocksPerMetronomeClick(96);
  $Time_Sig->thirtySecondsPer24Clocks(8);
  @event = $Time_Sig->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Time_Sig->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::TimeSignature is a class encapsulating MIDI Time Signature 
meta messages. A Time Signature message includes either a delta time 
or absolute time as implemented by MIDI::XML::Message and the MIDI 
Time Signature event encoded in 7 bytes as follows:

0xFF 0x58 0x04 0xnn 0xpp 0xmm 0xqq

nn = numerator

pp = log(2) denominator

mm = clock signals per metronome pulse

qq = thirty-second notes per MIDI quarter notes

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Time_Sig = MIDI::XML::TimeSignature->new()

This creates a new MIDI::XML::TimeSignature object.

=item $Time_Sig = MIDI::XML::TimeSignature->new($event);

Creates a new TimeSignature object initialized with the values of a 
MIDI::Event set_sequence_number array.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        '_Delta'=> undef,
        '_Absolute'=> undef,
        '_Numerator'=> undef,
        '_LogDenominator'=> undef,
        '_MidiClocksPerMetronomeClick'=> undef,
        '_ThirtySecondsPer24Clocks'=> undef,
    };
    if (@_) {
        if (ref($_[0]) eq 'ARRAY') {
            if ($_[0][0] eq 'time_signature') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Numerator'} = $_[0][2];
                $self->{'_LogDenominator'} = $_[0][3];
                $self->{'_MidiClocksPerMetronomeClick'} = $_[0][4];
                $self->{'_ThirtySecondsPer24Clocks'} = $_[0][5];
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'time_signature') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Numerator'} = $_[2];
                $self->{'_LogDenominator'} = $_[3];
                $self->{'_MidiClocksPerMetronomeClick'} = $_[4];
                $self->{'_ThirtySecondsPer24Clocks'} = $_[5];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Time_Sig->delta() or $Time_Sig->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Time_Sig->absolute() or $Time_Sig->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.  The absolute time should be zero according to the specification. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Time_Sig->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $numerator = $Time_Sig->numerator() or $Time_Sig->numerator($numerator);

Returns and optionally sets the numerator.

=cut

sub numerator {
    my $self = shift;
    if (@_) {
        $self->{'_Numerator'} = shift;
    }
    return  $self->{'_Numerator'};
}

#==========================================================================

=item $log_denominator = $Time_Sig->logDenominator() or $Time_Sig->logDenominator($log_denominator);

Returns and optionally sets the log Denominator.

=cut

sub logDenominator {
    my $self = shift;
    if (@_) {
        $self->{'_LogDenominator'} = shift;
    }
    return  $self->{'_LogDenominator'};
}

#==========================================================================

=item $clocks = $Time_Sig->midiClocksPerMetronomeClick() or $Time_Sig->midiClocksPerMetronomeClick($clocks);

Returns and optionally sets the number of MIDI clocks per metronome click.

=cut

sub midiClocksPerMetronomeClick {
    my $self = shift;
    if (@_) {
        $self->{'_MidiClocksPerMetronomeClick'} = shift;
    }
    return  $self->{'_MidiClocksPerMetronomeClick'};
}

#==========================================================================

=item $ts = $Time_Sig->thirtySecondsPer24Clocks() or $Time_Sig->thirtySecondsPer24Clocks($ts);

Returns and optionally sets the number of thirty-second note per 24 MIDI clocks.

=cut

sub thirtySecondsPer24Clocks {
    my $self = shift;
    if (@_) {
        $self->{'_ThirtySecondsPer24Clocks'} = shift;
    }
    return  $self->{'_ThirtySecondsPer24Clocks'};
}

#==========================================================================

=item $ordinal = $Time_Sig->ordinal();

Returns a value to be used to order events that occur at the same time.

sub ordinal {
    my $self = shift;
    return 0x0050 ;
}

#==========================================================================

=item @event = $Time_Sig->as_event();

Returns a MIDI::Event time_signature array initialized with the values 
of the TimeSignature object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'time_signature',
            MIDI::XML::Message::time($self),
            $self->{'_Numerator'},
            $self->{'_LogDenominator'},
            $self->{'_MidiClocksPerMetronomeClick'},
            $self->{'_ThirtySecondsPer24Clocks'}
    );
    return @event;
}

#==========================================================================

=item @xml = $Time_Sig->as_MidiXML();

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
    my @attr;

    if ( defined($self->{'_Numerator'})) {
        push @attr, "Numerator=\"$self->{'_Numerator'}\"";
    }
    if ( defined($self->{'_LogDenominator'})) {
        push @attr, "LogDenominator=\"$self->{'_LogDenominator'}\"";
    }
    if ( defined($self->{'_MidiClocksPerMetronomeClick'})) {
        push @attr, "MidiClocksPerMetronomeClick=\"$self->{'_MidiClocksPerMetronomeClick'}\"";
    }
    if ( defined($self->{'_ThirtySecondsPer24Clocks'})) {
        push @attr, "ThirtySecondsPer24Clocks=\"$self->{'_ThirtySecondsPer24Clocks'}\"";
    }

    push @xml, MIDI::XML::Message::as_MidiXML($self);
    $xml[2] = "<TimeSignature @attr/>";
    return @xml;
}

#==========================================================================


return 1;
__END__

=head1 AUTHOR

Brian M. Ames, E<lt>bmames@apk.netE<gt>

=head1 SEE ALSO

L<MIDI::Event>.

=head1 COPYRIGHT and LICENSE

Copyright 2002 Brian M. Ames.  This software may be used under the terms of
the GPL and Artistic licenses, the same as Perl itself. 

=cut

