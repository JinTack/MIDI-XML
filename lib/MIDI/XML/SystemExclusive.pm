package MIDI::XML::SystemExclusive;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::SystemExclusive - MIDI System Exclusive messages.

=head1 SYNOPSIS

  use MIDI::XML::SystemExclusive;
  use MIDI::Track;

  $Sys_Excl = MIDI::XML::SystemExclusive->new();
  $Sys_Excl->delta(384);
  $Sys_Excl->data(pack('C*',65,16,66,18,64,0,127,0,65,247));
  @event = $Sys_Excl->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Sys_Excl->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION

MIDI::XML::SystemExclusive is a class encapsulating MIDI System Exclusive messages.
A System Exclusive message includes either a delta time or absolute time as 
implemented by MIDI::XML::Message and the MIDI System Exclusive event encoded
as follows:

11110000 0mmmmmmm data 11110111

mmmmmmm = Manufacturer ID/Universal ID

=head2 EXPORT

None.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Sys_Excl = MIDI::XML::SystemExclusive->new();

This creates a new MIDI::XML::SystemExclusive object.

=item $Sys_Excl = MIDI::XML::SystemExclusive->new($event);

Creates a new SystemExclusive object initialized with the values of a 
MIDI::Event sysex_f0 array.

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
            if ($_[0][0] eq 'sysex_f0') {
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
            if ($_[0] eq 'sysex_f0') {
                $self->{'_Delta'} = $_[1];
                $self->{'_Data'} = $_[2];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Sys_Excl->delta() or $Sys_Excl->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Sys_Excl->absolute() or $Sys_Excl->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Sys_Excl->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $data = $Sys_Excl->data() or $Sys_Excl->data($data);

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

=item @event = $Sys_Excl->as_event();

Returns a MIDI::Event sysex_f0 array initialized with the values 
of the System Exclusive object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'sysex_f0',
            MIDI::XML::Message::time($self),
            $self->{'_Data'}
    );
    return @event;
}

#==========================================================================

=item @xml = $Sys_Excl->as_MidiXML();

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
    push @xml, MIDI::XML::Message::as_MidiXML($self);
    $xml[2] = "<SystemExclusive>@bytes</SystemExclusive>";
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

