package MIDI::XML::EndOfExclusive;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::EndOfExclusive - MIDI End Of Exclusive messages.

=head1 SYNOPSIS

  use MIDI::XML::EndOfExclusive;
  use MIDI::Track;

  $End_Excl = MIDI::XML::EndOfExclusive->new();
  $End_Excl->delta(384);
  $End_Excl->data(pack('C*',65,16,66,18,64,0,127,0,65,247));
  @event = $End_Excl->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $End_Excl->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::EndOfExclusive is a class encapsulating MIDI End Of Exclusive messages.
An End Of Exclusive message includes either a delta time or absolute time as 
implemented by MIDI::XML::Message and the MIDI End Of Exclusive event encoded
as follows:

111101111 data 11110111

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $End_Excl = MIDI::XML::EndOfExclusive->new();

This creates a new MIDI::XML::EndOfExclusive object.

=item $End_Excl = MIDI::XML::EndOfExclusive->new($event);

Creates a new EndOfExclusive object initialized with the values of a 
MIDI::Event sysex_f7 array.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        '_Delta'=> undef,
        '_Absolute'=> undef,
        '_Data'=> undef,
    };
    if (@_) {
        if (ref($_[0]) eq 'ARRAY') {
            if ($_[0][0] eq 'sysex_f7') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Data'} = $_[0][2];
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
            my @hex_bytes =  split (' ',$_[0]->{'_CDATA'});
            foreach $b (@hex_bytes) { 
               $self->{'_Data'} .= pack('C',hex($b));
            }
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'sysex_f7') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Data'} = $_[0][2];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $End_Excl->delta() or $End_Excl->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $End_Excl->absolute() or $End_Excl->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $End_Excl->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $data = $End_Excl->data() or $End_Excl->data($data);

Returns and optionally sets the data content.

=cut

sub data {
    my $self = shift;
    if (@_) {
        $self->{'_Data'} = shift;
    }
    return  $self->{'_Data'};
}

#==========================================================================

=item @event = $End_Excl->as_event();

Returns a MIDI::Event sysex_f7 array initialized with the values 
of the End Of Exclusive object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'sysex_f7',
            MIDI::XML::Message::time($self),
            $self->{'_Data'}
    );
    return @event;
}

#==========================================================================

=item @xml = $End_Excl->as_MidiXML();

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
    my @bytes;

    if ( defined($self->{'_Data'})) {
        for (my $i=0; $i<length($self->{'_Data'}); $i++) {
            push @bytes, sprintf("%02X",ord(substr($self->{'_Data'},$i,1)));
        }
    }
    push @xml, MIDI::XML::Message::as_MidiXML($self);
    $xml[2] = "<EndOfExclusive>@bytes</EndOfExclusive>";
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

