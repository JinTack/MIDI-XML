package MIDI::XML::PitchBend;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Channel;

our @ISA = qw(MIDI::XML::Channel);

=head1 NAME

MIDI::XML::PitchBend - MIDI Pitch Bend messages.

=head1 SYNOPSIS

  use MIDI::XML::PitchBend;
  use MIDI::Track;

  $Pitch_Bend = MIDI::XML::PitchBend->new();
  $Pitch_Bend->delta(384);
  $Pitch_Bend->channel(0);
  $Pitch_Bend->note(8192);
  @event = $Pitch_Bend->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Pitch_Bend->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::PitchBend is a class encapsulating MIDI Pitch Bend messages.
A Pitch Bend message includes either a delta time or absolute time as 
implemented by MIDI::XML::Message and the MIDI Note Off event encoded
in 3 bytes as follows:

1110cccc 0xxxxxxx 0yyyyyyy

cccc = channel;

xxxxxxx = least significant bits

yyyyyyy = most significant bits

The classes for MIDI Pitch Bend messages and the other six channel
messages are derived from MIDI::XML::Channel.

=head2 EXPORT

None by default.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Pitch_Bend = MIDI::XML::PitchBend->new()

This creates a new MIDI::XML::PitchBend object.

=item $Pitch_Bend = MIDI::XML::ChannelAftertouch->new($event);

Creates a new PitchBend object initialized with the values of a 
MIDI::Event pitch_wheel_change array.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        '_Delta'=> undef,
        '_Absolute'=> undef,
        '_Channel'=> undef,
        '_Value'=> undef,
    };
    if (@_) {
        if (ref($_[0]) eq 'ARRAY') {
            if ($_[0][0] eq 'pitch_wheel_change') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Channel'} = $_[0][2] & 0x0F;
                $self->{'_Value'} = $_[0][3];
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'pitch_wheel_change') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Channel'} = $_[2] & 0x0F;
                $self->{'_Value'} = $_[3];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Pitch_Bend->delta() or $Pitch_Bend->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Pitch_Bend->absolute() or $Pitch_Bend->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Pitch_Bend->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=item $channel = $Pitch_Bend->channel() or $Pitch_Bend->channel($channel);

Returns and optionally sets the channel number.  Channel numbers are limited
to the range 0-15.

This functionality is provided by the MIDI::XML::Channel base class.

=cut

#==========================================================================

=item $bend = $Pitch_Bend->bend() or $Pitch_Bend->bend($bend);

Returns and optionally sets the pressure.  Values are limited
to the range 0-127.

=cut

sub bend {
    my $self = shift;
    if (@_) {
        $self->{'_Value'} = (shift);
    }
    return  $self->{'_Value'};
}

#==========================================================================

=item $ordinal = $Pitch_Bend->ordinal();

Returns a value to be used to order events that occur at the same time.

=cut

sub ordinal {

    my $self = shift;
    return 0x0600 + $self->{'_Channel'};
}

#==========================================================================

=item @event = $Pitch_Bend->as_event();

Returns a MIDI::Event pitch_wheel_change array initialized with the values of the 
PitchBend object.  MIDI::Event does not expect absolute times and will interpret 
them as delta times.  Calling this method when the time is absolute will not
generate a warning or error but it is unlikely that the results will be 
satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'pitch_wheel_change',
            MIDI::XML::Message::time($self),
            $self->{'_Channel'} & 0x0F,
            $self->{'_Value'} & 0x7F
    );
    return @event;
}

#==========================================================================

=item @xml = $Pitch_Bend->as_MusicXML();

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

    push @xml, MIDI::XML::Channel::as_MidiXML($self);
    $xml[2] = "<PitchBendChange $xml[2] Value=\"$self->{'_Value'}\"/>";
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

