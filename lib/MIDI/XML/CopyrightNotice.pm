package MIDI::XML::CopyrightNotice;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;
use HTML::Entities;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::CopyrightNotice - Copyright Notice meta messages.

=head1 SYNOPSIS

  use MIDI::XML::CopyrightNotice;
  $Copy = MIDI::XML::CopyrightNotice->new();
  $Copy->delta(0);
  $Copy->value("Copyright 2003 Brian M. Ames");
  @event = $Copy->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Copy->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::CopyrightNotice is a class encapsulating MIDI Copyright Notice 
meta messages. A Copyright Notice message includes either a delta time 
or absolute time as implemented by MIDI::XML::Message and the MIDI Copyright 
Notice event encoded as follows:

0xFF 0x02 length text

=head2 EXPORT

None.

=cut

# Items to export into callers namespace by default. 

# This allows declaration use MIDI::XML::CopyrightNotice ':all';
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

=item $Copy = MIDI::XML::CopyrightNotice->new()

This creates a new MIDI::XML::CopyrightNotice object.

=item $Copy = MIDI::XML::CopyrightNotice->new($event);

Creates a new CopyrightNotice object initialized with the values of a 
MIDI::Event copyright_text_event array.

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
            if ($_[0][0] eq 'copyright_text_event') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Value'} = $_[0][2];
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
            $self->{'_Value'} = $_[0]->{'_CDATA'};
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'copyright_text_event') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Value'} = $_[2];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Copy->delta() or $Copy->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Copy->absolute() or $Copy->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.  The absolute time should be zero according to the specification. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Copy->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $text = $Copy->text() or $Copy->text($text);

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

=item $ordinal = $Copy->ordinal();

Returns a value to be used to order events that occur at the same time.

=cut

sub ordinal {
    my $self = shift;
    return 0x0002;
}

#==========================================================================

=item @event = $Copy->as_event();

Returns a MIDI::Event copyright_text_event array initialized with the values 
of the CopyrightNotice object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'copyright_text_event',
            MIDI::XML::Message::time($self),
            $self->{'_Value'}
    );
    return @event;
}

#==========================================================================

=item @xml = $Copy->as_MidiXML();

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
    $xml[2] = "<CopyrightNotice>$value</CopyrightNotice>";
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
