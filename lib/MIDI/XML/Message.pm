package MIDI::XML::Message;

use 5.006;
use strict;
use warnings;

our @ISA = qw();

our $VERSION = '0.02';

=head1 NAME

MIDI::XML::Channel - Base class for deriving MIDI message classes.

=head1 SYNOPSIS

  use MIDI::XML::Message;
  MIDI::XML::Message->as_MidiXML($self);

=head1 DESCRIPTION

MIDI::XML::Message is the base class from which MIDI Message objects are 
derived.  It should not generally be used directly except as shown in the
classes for the individual messages.

=head2 EXPORT

None.

=head1 METHODS AND ATTRIBUTES

=over 4

=cut

#==========================================================================

=item $delta_time = $Obj->delta() or $Obj->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

=cut

sub delta {
    my $self = shift;
    if (@_) {
        $self->{'_Delta'} = shift;
        $self->{'_Absolute'} = undef;
    }
    return  $self->{'_Delta'};
}

#==========================================================================

=item $absolute_time = $Obj->absolute() or $Obj->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set. 

=cut

sub absolute {
    my $self = shift;
    if (@_) {
        $self->{'_Absolute'} = shift;
        $self->{'_Delta'} = undef;
    }
    return  $self->{'_Absolute'};
}

#==========================================================================

=item $time = $Obj->time();

Returns the message time, absolute or delta, whichever was last set.

=cut

sub time {
    my $self = shift;

    if ( defined($self->{'_Delta'})) {
        return $self->{'_Delta'};
    } elsif ( defined($self->{'_Absolute'})) {
        return $self->{'_Absolute'};
    }

    return undef;
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


    push @xml, "<Event>";
    if ( defined($self->{'_Absolute'})) {
        push @xml, "<Absolute>$self->{'_Absolute'}</Absolute>";
    } elsif ( defined($self->{'_Delta'})) {
        push @xml, "<Delta>$self->{'_Delta'}</Delta>";
    }
    push @xml, undef;
    push @xml, "</Event>";
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

