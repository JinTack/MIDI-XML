package MIDI::XML::SequenceNumber;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::SequenceNumber - MIDI Sequence Number messages.

=head1 SYNOPSIS

  use MIDI::XML::SequenceNumber;
  $Seq_No = MIDI::XML::SequenceNumber->new();
  $Seq_No->delta(0);
  $Seq_No->value(4);
  @event = $Seq_No->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Seq_No->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::SequenceNumber is a class encapsulating MIDI Sequence Number 
meta messages. A Sequence Number message includes either a delta time 
or absolute time as implemented by MIDI::XML::Message and the MIDI Sequence 
Number event encoded
in 5 bytes as follows:

0xFF 0x00 0x02 0xnn 0xnn

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Seq_No = MIDI::XML::SequenceNumber->new()

This creates a new MIDI::XML::SequenceNumber object.

=item $Seq_No = MIDI::XML::SequenceNumber->new($event);

Creates a new SequenceNumber object initialized with the values of a 
MIDI::Event set_sequence_number array.

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
            if ($_[0][0] eq 'set_sequence_number') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Value'} = $_[0][2];
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'set_sequence_number') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Value'} = $_[2];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Seq_No->delta() or $Seq_No->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Seq_No->absolute() or $Seq_No->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.  The absolute time should be zero according to the specification. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Seq_No->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $value = $Seq_No->value() or $Seq_No->value($value);

Returns and optionally sets the sequence number.

=cut

sub value {
    my $self = shift;
    if (@_) {
        $self->{'_Value'} = shift;
    }
    return  $self->{'_Value'};
}

#==========================================================================

=item $ordinal = $Seq_No->ordinal();

Returns a value to be used to order events that occur at the same time.

=cut

sub ordinal {
    my $self = shift;
    return 0x0009;
}

#==========================================================================

=item @event = $Seq_No->as_event();

Returns a MIDI::Event set_sequence_number array initialized with the values 
of the SequenceNumber object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'set_sequence_number',
            MIDI::XML::Message::time($self),
            $self->{'_Value'} & 0x7F
    );
    return @event;
}

#==========================================================================

=item @xml = $Seq_No->as_MidiXML();

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
    $xml[2] = "<SequenceNumber Value=\"$self->{'_Value'}\"/>";
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

