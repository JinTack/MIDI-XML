package MIDI::XML::NoteOff;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Channel;

our @ISA = qw(MIDI::XML::Channel);

=head1 NAME

MIDI::XML::NoteOff - MIDI Note Off messages.

=head1 SYNOPSIS

  use MIDI::XML::NoteOff;
  use MIDI::Track;

  $Note_Off = MIDI::XML::NoteOff->new();
  $Note_Off->delta(384);
  $Note_Off->channel(0);
  $Note_Off->note('F',1,4);
  $Note_Off->velocity(64);
  @event = $Note_Off->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Note_Off->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::NoteOff is a class encapsulating MIDI Note Off messages.
A Note Off message includes either a delta time or absolute time as 
implemented by MIDI::XML::Message and the MIDI Note Off event encoded
in 3 bytes as follows:

1000cccc 0nnnnnnn 0vvvvvvv

cccc = channel;

nnnnnnn = note number

vvvvvvv = velocity

The classes for MIDI Note Off messages and the other six channel
messages are derived from MIDI::XML::Channel.

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Note_Off = MIDI::XML::NoteOff->new();

This creates a new MIDI::XML::NoteOff object.

=item $Note_Off = MIDI::XML::NoteOff->new($event);

Creates a new NoteOff object initialized with the values of a 
MIDI::Event note_off array.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        '_Delta'=> undef,
        '_Absolute'=> undef,
        '_Channel'=> undef,
        '_Note'=> undef,
        '_Velocity'=> undef,
    };
    if (@_) {
        if (ref($_[0]) eq 'ARRAY') {
            if ($_[0][0] eq 'note_off') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Channel'} = $_[0][2] & 0x0F;
                $self->{'_Note'} = $_[0][3] & 0x7F;
                $self->{'_Velocity'} = $_[0][4] & 0x7F;
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'note_off') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Channel'} = $_[2] & 0x0F;
                $self->{'_Note'} = $_[3] & 0x7F;
                $self->{'_Velocity'} = $_[4] & 0x7F;
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Note_Off->delta() or $Note_Off->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Note_Off->absolute() or $Note_Off->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Note_Off->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=item $channel = $Note_Off->channel() or $Note_Off->channel($channel);

Returns and optionally sets the channel number.  Channel numbers are limited
to the range 0-15.

This functionality is provided by the MIDI::XML::Channel base class.

=cut

#==========================================================================

=item $note_no = $Note_Off->note();

Returns the MIDI note number.  Note numbers are limited
to the range 0-127.

=item $note_no = $Note_Off->note($note_no);

Sets and returns the MIDI note number to the specified number.  Note numbers 
are limited to the range 0-127.

=item $note_no = $Note_Off->note($step, $alter, $octave);

Sets the MIDI note number to the specified step, alter and octave 
values.  Step is a letter designation of the note, /A|B|C|D|E|F|G/, alter 
is -1 for flat, 0 for natural, and 1 for sharp, and octave is the octave, -1
to 9.  Valid values range from ('C',0,-1) to ('G',0,9).  Returns the MIDI 
note number.

=item $note_no = $Note_Off->note($step, $octave);

Sets and returns the MIDI note number to the specified step and octave 
values assuming a 0 alter value.  

=cut

sub note {
    my $self = shift;
    if (@_) {
        if ($#_ == 2) {
            $self->{'_Note'} = 
                 (${{'C'=>0,'D'=>2,'E'=>4,'F'=>5,'G'=>7,'A'=>9,'B'=>11}}{$_[0]}
                     + $_[1] 
                     + 12 * $_[2] + 12) & 0x7F; 
        } elsif ($#_ == 1) {
            $self->{'_Note'} = 
                 (${{'C'=>0,'D'=>2,'E'=>4,'F'=>5,'G'=>7,'A'=>9,'B'=>11}}{$_[0]}
                     + 12 * $_[1] + 12) & 0x7F; 
        } else {
            $self->{'_Note'} = (shift) & 0x7F;
        }
    }
    return  $self->{'_Note'};
}

#==========================================================================

=item $velocity = $Note_Off->velocity() or $Note_Off->velocity($velocity);

Returns and optionally sets the velocity.  Velocities are limited
to the range 0-127.

=cut

sub velocity {
    my $self = shift;
    if (@_) {
        $self->{'_Velocity'} = (shift) & 0x7F;
    }
    return  $self->{'_Velocity'};
}

#==========================================================================

=item $ordinal = $Seq_No->ordinal();

Returns a value to be used to order events that occur at the same time.

=cut

sub ordinal {
    my $self = shift;
    return 0x0100 + (127 - $self->{'_Note'});
}

#==========================================================================

=item @event = $Note_Off->as_event();

Returns a MIDI::Event note_off array initialized with the values of the 
NoteOff object.  MIDI::Event does not expect absolute times and will interpret 
them as delta times.  Calling this method when the time is absolute will not
generate a warning or error but it is unlikely that the results will be 
satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'note_off',
            MIDI::XML::Message::time($self),
            $self->{'_Channel'} & 0x0F,
            $self->{'_Note'} & 0x7F,
            $self->{'_Velocity'} & 0x7F
    );
    return @event;
}

#==========================================================================

=item @xml = $Note_Off->as_MidiXML();

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
    $xml[2] = "<NoteOff $xml[2] Note=\"$self->{'_Note'}\" Velocity=\"$self->{'_Velocity'}\"/>";
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

