package MIDI::XML::TextEvent;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;
use HTML::Entities;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::TextEvent - MIDI Text Event Messages.

=head1 SYNOPSIS

  use MIDI::XML::TextEvent;
  $Text = MIDI::XML::TextEvent->new();
  $Text->delta(0);
  $Text->text('Some text.');
  @event = $Text->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Text->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::TextEvent is a class encapsulating MIDI Text 
meta messages. A Text message includes either a delta time 
or absolute time as implemented by MIDI::XML::Message and the MIDI Sequence 
Number event encoded as follows:

0xFF 0x01 length text

=head2 EXPORT

None.

=cut

# Items to export into callers namespace by default.

# This allows declaration use MIDI::XML::TextEvent ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);
our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Text = MIDI::XML::TextEvent->new()

This creates a new MIDI::XML::TextEvent object.

=item $Text = MIDI::XML::TextEvent->new($event);

Creates a new TextEvent object initialized with the values of a 
MIDI::Event text_event array.

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
            if ($_[0][0] eq 'text_event') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Value'} = $_[0][2];
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
            $self->{'_Value'} = $_[0]->{'_CDATA'};
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'text_event') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Value'} = $_[2];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Text->delta() or $Text->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Text->absolute() or $Text->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.  The absolute time should be zero according to the specification. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Text->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $text = $Text->text() or $Text->text($text);

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

=item $ordinal = $Text->ordinal();

Returns a value to be used to order events that occur at the same time.

=cut

sub ordinal {
    my $self = shift;
    return 0x0003;
}

#==========================================================================

=item @event = $Text->as_event();

Returns a MIDI::Event set_sequence_number array initialized with the values 
of the SequenceNumber object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'text_event',
            MIDI::XML::Message::time($self),
            $self->{'_Value'}
    );
    return @event;
}

#==========================================================================

=item @xml = $Text->as_MidiXML();

Returns an array of elements formatted according to the MidiXML DTD. These
elements may be assembled by track into entire documents with the following
suggested DOCTYPE declaration:

	<!DOCTYPE MIDI PUBLIC
		"-//Recordare//DTD MusicXML 0.6c MIDI//EN"
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
    $xml[2] = "<TextEvent>$value</TextEvent>";
    return @xml;
}

#==========================================================================


return 1;
__END__

=head1 RAVINGS

Text events could be used to embed XML into MIDI files, if only by maniacs.

=head1 AUTHOR

Brian M. Ames, E<lt>bmames@apk.netE<gt>

=head1 SEE ALSO

L<MIDI::Event>.

=head1 COPYRIGHT and LICENSE

Copyright 2002 Brian M. Ames.  This software may be used under the terms of
the GPL and Artistic licenses, the same as Perl itself. 

=cut
