package MIDI::XML::ProgramChange;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Channel;

our @ISA = qw(MIDI::XML::Channel);

=head1 NAME

MIDI::XML::ProgramChange - MIDI Program Change messages.

=head1 SYNOPSIS

  use MIDI::XML::ProgramChange;
  use MIDI::Track;

  $Program_Change = MIDI::XML::ProgramChange->new();
  $Program_Change->delta(384);
  $Program_Change->channel(0);
  $Program_Change->number(60);
  @event = $Program_Change->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Program_Change->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::ProgramChange is a class encapsulating MIDI Program Change messages.
A Program_Change message includes either a delta time or absolute time as 
implemented by MIDI::XML::Message and the MIDI Program Change event encoded
in 2 bytes as follows:

1100cccc 0nnnnnnn

cccc = channel;

nnnnnnn = program number

The classes for MIDI Program Change messages and the other six channel
messages are derived from MIDI::XML::Channel.

=head2 EXPORT

None.

=cut

our $VERSION = '0.02';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $obj = MIDI::XML::ProgramChange->new()

This creates a new MIDI::XML::ProgramChange object.

=item $Program_Change = MIDI::XML::ProgramChange->new($event);

Creates a new ProgramChange object initialized with the values of a 
MIDI::Event patch_change array.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        '_Delta'=> undef,
        '_Absolute'=> undef,
        '_Channel'=> undef,
        '_Number'=> undef,
    };
    if (@_) {
        if (ref($_[0]) eq 'ARRAY') {
            if ($_[0][0] eq 'patch_change') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Channel'} = $_[0][2] & 0x0F;
                $self->{'_Number'} = $_[0][3] & 0x7F;
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'patch_change') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Channel'} = $_[2] & 0x0F;
                $self->{'_Number'} = $_[3] & 0x7F;
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Program_Change->delta() or $Program_Change->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Program_Change->absolute() or $Program_Change->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Program_Change->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=item $channel = $Program_Change->channel() or $Program_Change->channel($channel);

Returns and optionally sets the channel number.  Channel numbers are limited
to the range 0-15.

This functionality is provided by the MIDI::XML::Channel base class.

=cut

#==========================================================================

=item $number = $Program_Change->number() or $Program_Change->number($number);

Returns and optionally sets the program number.  Program numbers are limited
to the range 0-127.

=cut

sub number {
    my $self = shift;
    if (@_) {
        $self->{'_Number'} = (shift) & 0x7F;
    }
    return  $self->{'_Number'};
}

#==========================================================================

=item $ordinal = $Program_Change->ordinal();

Returns a value to be used to order events that occur at the same time.

=cut

sub ordinal {

    my $self = shift;
    return 0x0221 + $self->{'_Channel'};
}

#==========================================================================

=item @event = $Program_Change->as_event();

Returns a MIDI::Event patch_change array initialized with the values of the 
ProgramChange object.  MIDI::Event does not expect absolute times and will interpret 
them as delta times.  Calling this method when the time is absolute will not
generate a warning or error but it is unlikely that the results will be 
satisfactory.

=cut

sub as_event {

    my $self = shift;
    my @event = (
            'patch_change',
            MIDI::XML::Message::time($self),
            $self->{'_Channel'} & 0x0F,
            $self->{'_Number'} & 0x7F
    );
    return @event;
}

#==========================================================================

=item @xml = $Program_Change->as_MidiXML();

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
    $xml[2] = "<ProgramChange $xml[2] Number=\"$self->{'_Number'}\"/>";
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

