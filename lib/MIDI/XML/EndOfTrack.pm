package MIDI::XML::EndOfTrack;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::EndOfTrack - MIDI End Of Track messages.

=head1 SYNOPSIS

  use MIDI::XML::EndOfTrack;
  $Eot = MIDI::XML::EndOfTrack->new();
  $Eot->delta(0);
  @event = $Eot->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Eot->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::EndOfTrack is a class encapsulating MIDI End Of Track 
meta messages. A End Of Track message includes either a delta time 
or absolute time as implemented by MIDI::XML::Message and the 
MIDI End Of Track event encoded in 3 bytes as follows:

0xFF 0x2F 0x00

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Eot = MIDI::XML::EndOfTrack->new()

This creates a new MIDI::XML::EndOfTrack object.

=item $Eot = MIDI::XML::EndOfTrack->new($event);

Creates a new EndOfTrack object initialized with the values of a 
MIDI::Event end_track array.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        '_Delta'=> undef,
        '_Absolute'=> undef,
    };
    if (@_) {
        if (ref($_[0]) eq 'ARRAY') {
            if ($_[0][0] eq 'end_track') {
                $self->{'_Delta'} = $_[0][1];
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'end_track') {
                $self->{'_Delta'} = $_[1];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Eot->delta() or $Eot->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Eot->absolute() or $Eot->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.  The absolute time should be zero according to the specification. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Eot->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $ordinal = $Eot->ordinal();

Returns a value to be used to order events that occur at the same time.

sub ordinal {
    my $self = shift;
    return 0xFFFF ;
}

#==========================================================================

=item @event = $Eot->as_event();

Returns a MIDI::Event end_track array initialized with the values 
of the EndOfTrack object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'end_track',
            MIDI::XML::Message::time($self)
    );
    return @event;
}

#==========================================================================

=item @xml = $Eot->as_MidiXML();

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
    $xml[2] = "<EndOfTrack/>";
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

