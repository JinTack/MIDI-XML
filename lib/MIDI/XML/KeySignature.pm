package MIDI::XML::KeySignature;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::KeySignature - MIDI Key Signature messages.

=head1 SYNOPSIS

  use MIDI::XML::KeySignature;
  $Key_Sig = MIDI::XML::KeySignature->new();
  $Key_Sig->delta(768);
  $Key_Sig->fifths(2);
  $Key_Sig->mode(0);
  @event = $Key_Sig->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Key_Sig->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::KeySignature is a class encapsulating MIDI Key Signature 
meta messages. A Key Signature message includes either a delta time 
or absolute time as implemented by MIDI::XML::Message and the MIDI 
Key Signature event encoded in 5 bytes as follows:

0xFF 0x59 0x02 0xss 0xmm

ss = number of sharps (+) or flats (-)

mm = mode, 0 = Major, 1 = minor

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Key_Sig = MIDI::XML::KeySignature->new()

This creates a new MIDI::XML::KeySignature object.

=item $Key_Sig = MIDI::XML::KeySignature->new($event);

Creates a new KeySignature object initialized with the values of a 
MIDI::Event key_signature array.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        '_Delta'=> undef,
        '_Absolute'=> undef,
        '_Fifths'=> undef,
        '_Mode'=> undef,
    };
    if (@_) {
        if (ref($_[0]) eq 'ARRAY') {
            if ($_[0][0] eq 'key_signature') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Fifths'} = $_[0][2];
                $self->{'_Mode'} = $_[0][3];
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'key_signature') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Fifths'} = $_[2];
                $self->{'_Mode'} = $_[3];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Key_Sig->delta() or $Key_Sig->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Key_Sig->absolute() or $Key_Sig->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.  The absolute time should be zero according to the specification. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Key_Sig->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $fifths = $Key_Sig->fifths() or $Key_Sig->fifths($fifths);

Returns and optionally sets the number of fifths on the circle of fifths 
from C Major or A minor to the given key.  This is equal to the number sharps
or flats.

=cut

sub fifths {
    my $self = shift;
    if (@_) {
        $self->{'_Fifths'} = shift;
    }
    return  $self->{'_Fifths'};
}

#==========================================================================

=item $mode = $Key_Sig->mode() or $Key_Sig->mode($mode);

Returns and optionally sets the mode.

=cut

sub mode {
    my $self = shift;
    if (@_) {
        $self->{'_Mode'} = shift;
    }
    return  $self->{'_Mode'};
}

#==========================================================================

=item $ordinal = $Key_Sig->ordinal();

Returns a value to be used to order events that occur at the same time.

=cut

sub ordinal {
    my $self = shift;
    return 0x0059 ;
}

#==========================================================================

=item @event = $Key_Sig->as_event();

Returns a MIDI::Event key_signature array initialized with the values 
of the KeySignature object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'key_signature',
            MIDI::XML::Message::time($self),
            $self->{'_Fifths'},
            $self->{'_Mode'}
    );
    return @event;
}

#==========================================================================

=item @xml = $Key_Sig->as_MidiXML();

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
    my @attr;

    if ( defined($self->{'_Fifths'})) {
        push @attr, "Fifths=\"$self->{'_Fifths'}\"";
    }
    if ( defined($self->{'_Mode'})) {
        push @attr, "Mode=\"$self->{'_Mode'}\"";
    }
    push @xml, MIDI::XML::Message::as_MidiXML($self);
    $xml[2] = "<KeySignature @attr/>";
    return @xml;
}

#==========================================================================


return 1;
__END__

=head1 RAVINGS

This Key Signature meta event present difficulties in encoding key signatures 
for music in other that Ionian (Major) and Aeolian (minor) modes.  I have 
adopted the practice of identifying those modes having a Major third 
(Ionian, Lydian, Mixolydian) as Major and those having a minor third 
(Aeolian, Dorian, Phrygian, Locrian) as minor.  Thus Mixolydian on G is 
encoded as G Major,  Dorian on D as D minor.

=head1 AUTHOR

Brian M. Ames, E<lt>bmames@apk.netE<gt>

=head1 SEE ALSO

L<MIDI::Event>.

=head1 COPYRIGHT and LICENSE

Copyright 2002 Brian M. Ames.  This software may be used under the terms of
the GPL and Artistic licenses, the same as Perl itself. 

=cut

