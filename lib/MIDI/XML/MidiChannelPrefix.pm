package MIDI::XML::MidiChannelPrefix;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::MidiChannelPrefix - MIDI ChannelPrefix messages.

=head1 SYNOPSIS

  use MIDI::XML::MidiChannelPrefix;
  $Channel_Prefix = MIDI::XML::MidiChannelPrefix->new();
  $Channel_Prefix->delta(0);
  $Channel_Prefix->channel(4);
  @event = $Channel_Prefix->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Channel_Prefix->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::MidiChannelPrefix is a class encapsulating MIDI Channel Prefix 
meta messages. A Channel Prefix message includes either a delta time 
or absolute time as implemented by MIDI::XML::Message and the MIDI Sequence 
Number event encoded in 4 bytes as follows:

0xFF 0x20 0x01 0xnn

nn = channel number

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Channel_Prefix = MIDI::XML::MidiChannelPrefix->new()

This creates a new MIDI::XML::MidiChannelPrefix object.

=item $Channel_Prefix = MIDI::XML::MidiChannelPrefix->new($event);

Creates a new MidiChannelPrefix object initialized with the values of a 
MIDI::Event midi_channel_prefix array.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        '_Delta'=> undef,
        '_Absolute'=> undef,
        '_Value'=> undef,
    };
    if (@_) {
        if (ref($_[0]) eq 'ARRAY') {
            if ($_[0][0] eq 'midi_channel_prefix') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Channel'} = $_[0][2];
            }
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'midi_channel_prefix') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Channel'} = $_[2];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Channel_Prefix->delta() or $Channel_Prefix->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Channel_Prefix->absolute() or $Channel_Prefix->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.  The absolute time should be zero according to the specification. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Channel_Prefix->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $channel = $Channel_Prefix->channel() or $Channel_Prefix->channel($channel);

Returns and optionally sets the channel number.

=cut

sub channel {
    my $self = shift;
    if (@_) {
        $self->{'_Channel'} = shift;
    }
    return  $self->{'_Channel'};
}

#==========================================================================

=item $ordinal = $Channel_Prefix->ordinal();

Returns a value to be used to order events that occur at the same time.

=cut

sub ordinal {
    my $self = shift;
    return 0x0020 ;
}

#==========================================================================

=item @event = $Channel_Prefix->as_event();

Returns a MIDI::Event midi_channel_prefix array initialized with the values 
of the MidiChannelPrefix object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'midi_channel_prefix',
            MIDI::XML::Message::time($self),
            $self->{'_Channel'}
    );
    return @event;
}

#==========================================================================

=item @xml = $Channel_Prefix->as_MidiXML();

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

    push @xml, MIDI::XML::Message::as_MidiXML($self);
    $xml[2] = "<MidiChannelPrefix Value=\"$self->{'_Channel'}\"/>";
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

