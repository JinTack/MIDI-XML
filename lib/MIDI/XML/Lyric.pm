package MIDI::XML::Lyric;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;
use HTML::Entities;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::SequenceNumber - MIDI Lyric/Display messages.

=head1 SYNOPSIS

  use MIDI::XML::Lyric;
  $Lyric = MIDI::XML::Lyric->new();
  $Lyric->delta(384);
  $Lyric->text('How');
  @event = $Lyric->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Lyric->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::Lyric is a class encapsulating MIDI Lyric/Display 
meta messages. A Lyric message includes either a delta time 
or absolute time as implemented by MIDI::XML::Message and the MIDI 
Lyric/Display meta event encoded as follows:

0xFF 0x05 length text

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Lyric = MIDI::XML::Lyric->new()

This creates a new MIDI::XML::Lyric object.

=item $Lyric = MIDI::XML::Lyric->new($event);

Creates a new Lyric object initialized with the values of a 
MIDI::Event lyric array.

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
            if ($_[0][0] eq 'lyric') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Value'} = $_[0][2];
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
            $self->{'_Value'} = $_[0]->{'_CDATA'};
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'lyric') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Value'} = $_[2];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Lyric->delta() or $Lyric->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Lyric->absolute() or $Lyric->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Lyric->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $text = $Lyric->text() or $Lyric->text($text);

Returns and optionally sets the text value.

=cut

sub text {
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
    return 0x0006;
}

#==========================================================================

=item @event = $Lyric->as_event();

Returns a MIDI::Event lyric array initialized with the values 
of the Lyric object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'lyric',
            MIDI::XML::Message::time($self),
            $self->{'_Value'}
    );
    return @event;
}

#==========================================================================

=item @xml = $Lyric->as_MidiXML();

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

    my $value = HTML::Entities::encode($self->{'_Value'});
    $value =~ s/\n/&#10;/;
    $value =~ s/\r/&#13;/;

    push @xml, MIDI::XML::Message::as_MidiXML($self);
    $xml[2] = "<Lyric>$value</Lyric>";
    return @xml;
}

#==========================================================================


return 1;
__END__

=head1 RAVINGS

MMA Recommended Practice RP-017 describes the way sylables, word ends, line
ends, paragragh end, and melismas should be identified in Lyric/Display events.

MMA Recommended Practice RP-026 describes a means of encoding additional
information in Lyric/Display meta events to allow the display of Character
Codeset and Song Information by Karaoke applications and MIDI file players.
I may add methods to perform this encoding in a future release.

I do not have any MIDI file formatted for Karaoke to examine.  If you have
one that I can use, please let me know. 

=head1 AUTHOR

Brian M. Ames, E<lt>bmames@apk.netE<gt>

=head1 SEE ALSO

L<MIDI::Event>.

=head1 COPYRIGHT and LICENSE

Copyright 2002 Brian M. Ames.  This software may be used under the terms of
the GPL and Artistic licenses, the same as Perl itself. 

=cut

