package MIDI::XML::NoteOn;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Channel;
use MIDI::XML::NoteOff;

our @ISA = qw(MIDI::XML::Channel MIDI::XML::NoteOff);

=head1 NAME

MIDI::XML::NoteOff - MIDI Note On messages.

=head1 SYNOPSIS

  use MIDI::XML::NoteOn;
  use MIDI::Track;

  $Note_On = MIDI::XML::NoteOn->new();
  $Note_On->delta(0);
  $Note_On->channel(0);
  $Note_On->note('F',1,4);
  $Note_On->velocity(92);
  @event = $Note_On->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Note_On->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::NoteOn is a class encapsulating MIDI Note On messages.
A Note On message includes either a delta time or absolute time as 
implemented by MIDI::XML::Message and the MIDI Note On event encoded
in 3 bytes as follows:

1001cccc 0nnnnnnn 0vvvvvvv

cccc = channel;

nnnnnnn = note number

vvvvvvv = velocity

The classes for MIDI Note On messages and the other six channel
messages are derived from MIDI::XML::Channel.

=head2 EXPORT

None by default.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Note_On = MIDI::XML::NoteOn->new();

This creates a new MIDI::XML::NoteOn object.

=item $Note_On = MIDI::XML::NoteOn->new($event);

Creates a new NoteOn object initialized with the values of a 
MIDI::Event note_on array.

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
            if ($_[0][0] eq 'note_on') {
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
            if ($_[0] eq 'note_on') {
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

=item $delta_time = $Note_On->delta() or $Note_On->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Note_On->absolute() or $Note_On->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Note_On->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=item $channel = $Note_On->channel() or $Note_On->channel($channel);

Returns and optionally sets the channel number.  Channel numbers are limited
to the range 0-15.

This functionality is provided by the MIDI::XML::Channel base class.

#==========================================================================

=item $note_no = $Note_On->note();

Returns the MIDI note number.  Note numbers are limited
to the range 0-127.

=item $note_no = $Note_On->note($note_no);

Sets and returns the MIDI note number to the specified number.  Note numbers 
are limited to the range 0-127.

=item $note_no = $Note_On->note($step, $alter, $octave);

Sets the MIDI note number to the specified step, alter and octave 
values.  Step is a letter designation of the note, /A|B|C|D|E|F|G/, alter 
is -1 for flat, 0 for natural, and 1 for sharp, and octave is the octave, -1
to 9.  Valid values range from ('C',0,-1) to ('G',0,9).  Returns the MIDI 
note number.

=item $note_no = $Note_On->note($step, $octave);

Sets and returns the MIDI note number to the specified step and octave 
values assuming a 0 alter value.  

This functionality is provided by the MIDI::XML::NoteOff class.

=cut

#==========================================================================

=item $velocity = $Note_On->velocity() or $Note_On->velocity($velocity);

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

=item $ordinal = $Note_On->ordinal();

Returns a value to be used to order events that occur at the same time.

=cut

sub ordinal {
    my $self = shift;
    return 0x0700 + (127 - $self->{'_Note'});
}

#==========================================================================

=item @event = $Note_On->as_event();

Returns a MIDI::Event note_on array initialized with the values of the 
NoteOn object.  MIDI::Event does not expect absolute times and will interpret 
them as delta times.  Calling this method when the time is absolute will not
generate a warning or error but it is unlikely that the results will be 
satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'note_on',
            MIDI::XML::Message::time($self),
            $self->{'_Channel'} & 0x0F,
            $self->{'_Note'} & 0x7F,
            $self->{'_Velocity'} & 0x7F
    );
    return @event;
}
#==========================================================================

=item @xml = $Note_On->as_MidiXML();

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
    $xml[2] = "<NoteOn $xml[2] Note=\"$self->{'_Note'}\" Velocity=\"$self->{'_Velocity'}\"/>";
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

