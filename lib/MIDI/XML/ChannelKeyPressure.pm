package MIDI::XML::ChannelKeyPressure;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Channel;

our @ISA = qw(MIDI::XML::Channel);

=head1 NAME

MIDI::XML::ChannelKeyPressure - Class encapsulating MIDI Channel Key Pressure 
messages.

=head1 SYNOPSIS

  use MIDI::XML::ChannelKeyPressure;
  use MIDI::Track;

  $Channel_Pressure = MIDI::XML::ChannelKeyPressure->new();
  $Channel_Pressure->delta(384);
  $Channel_Pressure->channel(0);
  $Channel_Pressure->note('F',1,4);
  $Channel_Pressure->velocity(64);
  @event = $Channel_Pressure->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Channel_Pressure->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::ChannelKeyPressure is a class encapsulating MIDI Channel Key Pressure 
messages. A Channel Key Pressure message includes either a delta time or absolute 
time as implemented by MIDI::XML::Message and the MIDI Channel Key Pressure event 
encoded in 2 bytes as follows:

1101cccc 0ppppppp

cccc = channel;

ppppppp = pressure

The classes for MIDI Channel Key Pressure messages and the other six channel
messages are derived from MIDI::XML::Channel.

=head2 EXPORT

None by default.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Channel_Pressure = MIDI::XML::ChannelKeyPressure->new()

This creates a new MIDI::XML::ChannelKeyPressure object.

=item $Channel_Pressure = MIDI::XML::ChannelKeyPressure->new($event);

Creates a new ChannelKeyPressure object initialized with the values of a 
MIDI::Event channel_after_touch array.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        '_Delta'=> undef,
        '_Absolute'=> undef,
        '_Channel'=> undef,
        '_Pressure'=> undef,
    };
    if (@_) {
        if (ref($_[0]) eq 'ARRAY') {
            if ($_[0][0] eq 'channel_after_touch') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Channel'} = $_[0][2] & 0x0F;
                $self->{'_Pressure'} = $_[0][3] & 0x7F;
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'channel_after_touch') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Channel'} = $_[2] & 0x0F;
                $self->{'_Pressure'} = $_[3] & 0x7F;
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Channel_Pressure->delta() or $Channel_Pressure->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Channel_Pressure->absolute() or $Channel_Pressure->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Channel_Pressure->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=item $channel = $Channel_Pressure->channel() or $Channel_Pressure->channel($channel);

Returns and optionally sets the channel number.  Channel numbers are limited
to the range 0-15.

This functionality is provided by the MIDI::XML::Channel base class.

=cut

#==========================================================================

=item $pressure = $Channel_Pressure->pressure() or $Channel_Pressure->pressure($pressure);

Returns and optionally sets the pressure.  Values are limited
to the range 0-127.

=cut

sub pressure {
    my $self = shift;
    if (@_) {
        $self->{'_Pressure'} = (shift) & 0x7F;
    }
    return  $self->{'_Pressure'};
}

#==========================================================================

=item $ordinal = $Channel_Pressure->ordinal();

Returns a value to be used to order events that occur at the same time.

=cut

sub ordinal {

    my $self = shift;
    return 0x0500 + $self->{'_Channel'};
}

#==========================================================================

=item @event = $Channel_Pressure->as_event();

Returns a MIDI::Event channel_after_touch array initialized with the values of the 
ChannelKeyPressure object.  MIDI::Event does not expect absolute times and will interpret 
them as delta times.  Calling this method when the time is absolute will not
generate a warning or error but it is unlikely that the results will be 
satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'channel_after_touch',
            MIDI::XML::Message::time($self),
            $self->{'_Channel'} & 0x0F,
            $self->{'_Pressure'} & 0x7F
    );
    return @event;
}

#==========================================================================

=item @xml = $Channel_Pressure->as_MidiXML();

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
    $xml[2] = "<ChannelKeyPressure $xml[2] Pressure=\"$self->{'_Pressure'}\"/>";
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

