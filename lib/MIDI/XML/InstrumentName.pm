package MIDI::XML::InstrumentName;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;
use HTML::Entities;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::SequenceNumber - MIDI Instrument Name messages.

=head1 SYNOPSIS

  use MIDI::XML::InstrumentName;
  $Instrument_Name = MIDI::XML::InstrumentName->new();
  $Instrument_Name->delta(768);
  $Instrument_Name->text('Oboe');
  @event = $Instrument_Name->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Instrument_Name->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::InstrumentName is a class encapsulating MIDI Instrument Name 
meta messages. An Instrument Name message includes either a delta time 
or absolute time as implemented by MIDI::XML::Message and the MIDI 
Instrument Name event encoded as follows:

0xFF 0x04 length text

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Instrument_Name = MIDI::XML::InstrumentName->new()

This creates a new MIDI::XML::InstrumentName object.

=item $Instrument_Name = MIDI::XML::InstrumentName->new($event);

Creates a new InstrumentName object initialized with the values of a 
MIDI::Event instrument_name array.

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
            if ($_[0][0] eq 'instrument_name') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Value'} = $_[0][2];
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
            $self->{'_Value'} = $_[0]->{'_CDATA'};
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'instrument_name') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Value'} = $_[2];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Instrument_Name->delta() or $Instrument_Name->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Instrument_Name->absolute() or $Instrument_Name->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Instrument_Name->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $text = $Instrument_Name->text() or $Instrument_Name->text($text);

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
    return 0x0005;
}

#==========================================================================

=item @event = $Instrument_Name->as_event();

Returns a MIDI::Event instrument_name array initialized with the values 
of the InstrumentName object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'instrument_name',
            MIDI::XML::Message::time($self),
            $self->{'_Value'}
    );
    return @event;
}

#==========================================================================

=item @xml = $Instrument_Name->as_MidiXML();

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
    $xml[2] = "<InstrumentName>$value</InstrumentName>";
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

