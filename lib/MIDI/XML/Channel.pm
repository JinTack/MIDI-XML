package MIDI::XML::Channel;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::Channel - Base class for deriving classes for MIDI channel events.

=head1 SYNOPSIS

  use MIDI::XML::Channel;
  MIDI::XML::Channel->as_MidiXML($self);

=head1 DESCRIPTION

MIDI::XML::Channel is the base class from which MIDI Channel objects are 
derived.

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

=head1 METHODS AND ATTRIBUTES

=over 4

=item $delta_time = $Obj->delta() or $Obj->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Obj->absolute() or $Obj->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Obj->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $channel = $Obj->channel() or $Obj->channel($channel);

Returns and optionally sets the channel number.  Channel numbers are limited
to the range 0-15.

=cut

sub channel {
    my $self = shift;
    if (@_) {
        $self->{'_Channel'} = (shift) & 0x0F;
    }
    return  $self->{'_Channel'};
}

#==========================================================================

=item @xml = $Obj->as_MidiXML();

This method is called by the as_MusicXML methods of derived classes.

Returns an array of elements formatted according to the MidiXML DTD.

=back

=cut

sub as_MidiXML {
    my $self = shift;
    my @xml;

    push @xml, MIDI::XML::Message::as_MidiXML($self); 
    if ( defined($self->{'_Channel'})) {
        my $chn = $self->{'_Channel'}+1;
        $xml[2] = "Channel=\"$chn\"";
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

