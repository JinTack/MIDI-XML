package MIDI::XML::SequencerSpecific;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::SequencerSpecific - MIDI Sequencer Specific  messages.

=head1 SYNOPSIS

  use MIDI::XML::SequencerSpecific;
  $Seq_Specific = MIDI::XML::SequencerSpecific->new();
  $Seq_Specific->delta(0);
  $Seq_Specific->data(pack('C*',0,0,119,14,0)));
  @event = $Seq_Specific->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Seq_Specific->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::SequencerSpecific is a class encapsulating MIDI Sequencer Specific 
meta messages. A Sequencer Specific message includes either a delta time 
or absolute time as implemented by MIDI::XML::Message and the MIDI 
Sequencer Specific event encoded in as follows:

0xFF 0x7F 0x02 length data

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Seq_Specific = MIDI::XML::SequencerSpecific->new()

This creates a new MIDI::XML::SequencerSpecific object.

=item $Seq_Specific = MIDI::XML::SequencerSpecific->new($event);

Creates a new SequencerSpecific object initialized with the values of a 
MIDI::Event sequencer_specific array.

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
            if ($_[0][0] eq 'sequencer_specific') {
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
            if ($_[0] eq 'sequencer_specific') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Data'} = $_[2];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Seq_Specific->delta() or $Seq_Specific->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Seq_Specific->absolute() or $Seq_Specific->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.  The absolute time should be zero according to the specification. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Seq_Specific->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item @data = $Seq_Specific->data();

=cut

sub data {
    my $self = shift;
    if (@_) {
        $self->{'_Data'} = shift;
    }
    return  $self->{'_Data'};
}

#==========================================================================

=item $ordinal = $Seq_Specific->ordinal();

Returns a value to be used to order events that occur at the same time.

=cut

sub ordinal {
    my $self = shift;
    return 0x007F;
}

#==========================================================================

=item @event = $Seq_Specific->as_event();

Returns a MIDI::Event sequencer_specific array initialized with the values 
of the Sequencer Specific object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'sequencer_specific',
            MIDI::XML::Message::time($self),
            $self->{'_Data'}
    );
    return @event;
}

#==========================================================================

=item @xml = $Seq_Specific->as_MidiXML();

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
#    print "@{$self->{'_Data'}}\n";
    if ( defined($self->{'_Data'})) {
        for (my $i=0; $i<length($self->{'_Data'}); $i++) {
            push @bytes, sprintf("%02X",ord(substr($self->{'_Data'},$i,1)));
        }
    }
#    @bytes = @{$self->{'_Data'}};
    push @xml, MIDI::XML::Message::as_MidiXML($self);
    $xml[2] = "<SequencerSpecific>@bytes</SequencerSpecific>";
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

