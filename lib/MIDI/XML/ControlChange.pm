package MIDI::XML::ControlChange;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Channel;

our @ISA = qw(MIDI::XML::Channel);

=head1 NAME

MIDI::XML::ControlChange - Class encapsulating MIDI Control Change messages.

=head1 SYNOPSIS

  use MIDI::XML::ControlChange;
  use MIDI::Track;

  $Control_Change = MIDI::XML::ControlChange->new();
  $Control_Change->delta(384);
  $Control_Change->channel(0);
  $Control_Change->control(11);
  $Control_Change->value(96);
  @event = $Control_Change->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Control_Change->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::ControlChange is a class encapsulating MIDI Control Change messages.
A Control Change message includes either a delta time or absolute time as 
implemented by MIDI::XML::Message and the MIDI Note Off event encoded
in 3 bytes as follows:

1011cccc 0nnnnnnn 0vvvvvvv

cccc = channel;

nnnnnnn = control number

vvvvvvv = value

The classes for MIDI Control Change messages and the other six channel
messages are derived from MIDI::XML::Channel.

=head2 EXPORT

None by default.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Control_Change = MIDI::XML::ControlChange->new()

This creates a new MIDI::XML::ControlChange object.

=item $Control_Change = MIDI::XML::ControlChange->new($event);

Creates a new ControlChange object initialized with the values of a 
MIDI::Event control_change array.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        '_Delta'=> undef,
        '_Absolute'=> undef,
        '_Channel'=> undef,
        '_Control'=> undef,
        '_Value'=> undef,
    };
    if (@_) {
        if (ref($_[0]) eq 'ARRAY') {
            if ($_[0][0] eq 'control_change') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Channel'} = $_[0][2] & 0x0F;
                $self->{'_Control'} = $_[0][3] & 0x7F;
                $self->{'_Value'} = $_[0][4] & 0x7F;
            }
        } elsif (ref($_[0]) eq 'HASH') {
            $self->{'_Value'} = 0;
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
            if ($_[0]->{'_ELEMENT'} eq 'AllSoundOff') {
                $self->{'_Control'} = 120;
            } elsif ($_[0]->{'_ELEMENT'} eq 'ResetAllControllers') {
                $self->{'_Control'} = 121;
            } elsif ($_[0]->{'_ELEMENT'} eq 'LocalControl') {
                $self->{'_Control'} = 122;
                $self->{'_Value'} = ($_[0]->{'Value'} eq 'on') ? 127 : 0;
            } elsif ($_[0]->{'_ELEMENT'} eq 'AllNotesOff') {
                $self->{'_Control'} = 123;
            } elsif ($_[0]->{'_ELEMENT'} eq 'OmniOff') {
                $self->{'_Control'} = 124;
            } elsif ($_[0]->{'_ELEMENT'} eq 'OmniOn') {
                $self->{'_Control'} = 125;
            } elsif ($_[0]->{'_ELEMENT'} eq 'MonoMode') {
                $self->{'_Control'} = 126;
            } elsif ($_[0]->{'_ELEMENT'} eq 'PolyMode') {
                $self->{'_Control'} = 127;
            }
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'control_change') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Channel'} = $_[2] & 0x0F;
                $self->{'_Control'} = $_[3] & 0x7F;
                $self->{'_Value'} = $_[4] & 0x7F;
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Control_Change->delta() or $Control_Change->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Control_Change->absolute() or $Control_Change->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Control_Change->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=item $channel = $Control_Change->channel() or $Control_Change->channel($channel);

Returns and optionally sets the channel number.  Channel numbers are limited
to the range 0-15.

This functionality is provided by the MIDI::XML::Channel base class.

=cut

#==========================================================================

=item $control = $Control_Change->control() or $Control_Change->control($control);

Returns and optionally sets the control number.  Control numbers are limited
to the range 0-127.

=cut

sub control {
    my $self = shift;
    if (@_) {
        $self->{'_Control'} = (shift) & 0x7F;
    }
    return  $self->{'_Control'};
}

#==========================================================================

=item $value = $Control_Change->value() or $Control_Change->value($value);

Returns and optionally sets the control value.  Values are limited
to the range 0-127.

=cut

sub value {
    my $self = shift;
    if (@_) {
        $self->{'_Value'} = (shift) & 0x7F;
    }
    return  $self->{'_Value'};
}

#==========================================================================

=item $ordinal = $Control_Change->ordinal();

Returns a value to be used to order events that occur at the same time.

=cut

sub ordinal {
    my $self = shift;
    if ($self->{'_Control'} == 0 ) {
        return 0x0201 + $self->{'_Channel'};
    } elsif ($self->{'_Control'} == 32 ) {
        return 0x0211 + $self->{'_Channel'};
    }
    return 0x0300 + $self->{'_Control'};
}

#==========================================================================

=item @event = $Control_Change->as_event();

Returns a MIDI::Event control_change array initialized with the values of the 
ControlChange object.  MIDI::Event does not expect absolute times and will interpret 
them as delta times.  Calling this method when the time is absolute will not
generate a warning or error but it is unlikely that the results will be 
satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'control_change',
            MIDI::XML::Message::time($self),
            $self->{'_Channel'} & 0x0F,
            $self->{'_Control'} & 0x7F,
            $self->{'_Value'} & 0x7F
    );
    return @event;
}

#==========================================================================

=item @xml = $Control_Change->as_MidiXML();

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

    my $ctl = $self->{'_Control'};
    push @xml, MIDI::XML::Channel::as_MidiXML($self);
    if ($ctl == 120) {
        $xml[2] = "<AllSoundOff $xml[2]/>";
    } elsif ($ctl == 121) {
        $xml[2] = "<ResetAllControllers $xml[2]/>";
    } elsif ($ctl == 122) {
        my $v = ($self->{'_Value'}) ? "on" : "off";
        $xml[2] = "<LocalControl $xml[2] Value=\"$v\"/>";
    } elsif ($ctl == 123) {
        $xml[2] = "<AllNotesOff $xml[2]/>";
    } elsif ($ctl == 124) {
        $xml[2] = "<OmniOff $xml[2]/>";
    } elsif ($ctl == 125) {
        $xml[2] = "<OmniOn $xml[2]/>";
    } elsif ($ctl == 126) {
        $xml[2] = "<MonoMode $xml[2] Value=\"$self->{'_Value'}\"/>";
    } elsif ($ctl == 127) {
        $xml[2] = "<PolyMode $xml[2]/>";
    } else {
        $xml[2] = "<ControlChange $xml[2] Control=\"$self->{'_Control'}\" Value=\"$self->{'_Value'}\"/>";
    }
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

