#still plenty to do here.

package MIDI::XML::MetaEvent;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::MetaEvent - MIDI Meta messages.

=head1 SYNOPSIS

  use MIDI::XML::MetaEvent;
  $Meta = MIDI::XML::MetaEvent->new();
  $Meta->delta(0);
  $Meta->number(35);
  $Meta->data(pack('C*',65,16,66,18,64,0,127,0,65,247));
  @event = $Meta->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Meta->as_MusicXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::MetaEvent is a class encapsulating MIDI  
Meta messages. A Meta message includes either a delta time 
or absolute time as implemented by MIDI::XML::Message and the MIDI 
Sequencer Specific event encoded in as follows:

0xFF 0x7F 0xnn length data


=head2 EXPORT

None.

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Meta = MIDI::XML::MetaEvent->new()

This creates a new MIDI::XML::MetaEvent object.

=item $Meta = MIDI::XML::MetaEvent->new($event);

Creates a new MetaEvent object initialized with the values of a 
MIDI::Event raw_meta_event array.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        '_Delta'=> undef,
        '_Absolute'=> undef,
        '_Number'=> undef,
        '_Data'=> undef,
    };
    if (@_) {
        if (ref($_[0]) eq 'ARRAY') {
            if ($_[0][0] eq 'raw_meta_event') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_Number'} = $_[0][2];
                $self->{'_Data'} = $_[0][3];
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
            if ($_[0] eq 'raw_meta_event') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Number'} = $_[2];
                $self->{'_Data'} = $_[3];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Meta->delta() or $Meta->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Meta->absolute() or $Meta->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.  The absolute time should be zero according to the specification. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Meta->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $number = $Meta->number() or $Meta->number($number);

Returns and optionally sets the meta event number.

=cut

sub number {
    my $self = shift;
    if (@_) {
        $self->{'_Number'} = shift;
    }
    return  $self->{'_Number'};
}

#==========================================================================

=item $data = $Meta->data() or $Meta->data($data);

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

=item @event = $Text->as_event();

Returns a MIDI::Event raw_meta_event array initialized with the values 
of the MetaEvent object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'raw_meta_event',
            MIDI::XML::Message::time($self),
            $self->{'_Number'},
            $self->{'_Data'}
    );
    return @event;
}

#==========================================================================

=item @xml = $Text->as_MusicXML();

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
    my $hex = sprintf("%02X",$self->{'_Number'});
    push @xml, MIDI::XML::Message::as_MidiXML($self);
    $xml[2] = "<OtherMetaEvent Number=\"$hex\">@bytes</OtherMetaEvent>";
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

