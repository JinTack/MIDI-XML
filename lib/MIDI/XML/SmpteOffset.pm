package MIDI::XML::SmpteOffset;

use 5.006;
use strict;
use warnings;

use MIDI::XML::Message;

our @ISA = qw(MIDI::XML::Message);

=head1 NAME

MIDI::XML::SmpteOffset - MIDI SMPTE Offset messages.

=head1 SYNOPSIS

  use MIDI::XML::SmpteOffset;
  $Offset = MIDI::XML::SmpteOffset->new();
  $Offset->delta(0);
  $Offset->time_code_type(3);
  $Offset->hour(1);
  $Offset->minute(15);
  $Offset->second(6);
  $Offset->frame(2);
  $Offset->fractional_frame(9);
  @event = $Offset->as_event();
  $midi_track = MIDI::Track->new();
  push( @{$midi_track->events_r},\@event;
  @xml = $Offset->as_MidiXML();
  print join("\n",@xml);

=head1 DESCRIPTION


MIDI::XML::SmpteOffset is a class encapsulating MIDI SMPTE Offset 
meta messages. A SMPTE Offset message includes either a delta time 
or absolute time as implemented by MIDI::XML::Message and the MIDI 
SMPTE Offset event encoded in 8 bytes as follows:

0xFF 0x54 0x05 0xhh 0xmm 0xss 0xrr 0xpp

hh = frame rate + hours (0rrhhhhh)

mm = minutes

ss = seconds

rr = frames

pp = 

=head2 EXPORT

None by default.

=cut

our $VERSION = '0.01';

#==========================================================================

=head1 METHODS AND ATTRIBUTES

=over 4

=item $Offset = MIDI::XML::SmpteOffset->new()

This creates a new MIDI::XML::SmpteOffset object.

=item $Offset = MIDI::XML::SmpteOffset->new($event);

Creates a new SmpteOffset object initialized with the values of a 
MIDI::Event set_sequence_number array.

=cut

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        '_Delta'=> undef,
        '_Absolute'=> undef,
        '_TimeCodeType'=> undef,
        '_Hour'=> undef,
        '_Minute'=> undef,
        '_Second'=> undef,
        '_Frame'=> undef,
        '_FractionalFrame'=> undef,
    };
    if (@_) {
        if (ref($_[0]) eq 'ARRAY') {
            if ($_[0][0] eq 'smpte_offset') {
                $self->{'_Delta'} = $_[0][1];
                $self->{'_TimeCodeType'} = ($_[0][2] & 0x60) >> 5;
                $self->{'_Hour'} = $_[0][2] & 0x1F;
                $self->{'_Minute'} = $_[0][3];
                $self->{'_Second'} = $_[0][4];
                $self->{'_Frame'} = $_[0][5];
                $self->{'_FractionalFrame'} = $_[0][6];
            }
        } elsif (ref($_[0]) eq 'HASH') {
            foreach my $attr (keys %{$_[0]}) {
                $self->{"_$attr"} = $_[0]->{$attr} unless ($attr =~ /^_/);
            }
        } elsif (ref($_[0]) eq '') {
            if ($_[0] eq 'smpte_offset') {
                $self->{'_Delta'} = $_[1];
                $self->{'_TimeCodeType'} = ($_[2] & 0x60) >> 5;
                $self->{'_Hour'} = $_[2] & 0x1F;
                $self->{'_Minute'} = $_[3];
                $self->{'_Second'} = $_[4];
                $self->{'_Frame'} = $_[5];
                $self->{'_FractionalFrame'} = $_[6];
            }
        }        
    }

    bless($self,$class);
    return $self;
}

=item $delta_time = $Offset->delta() or $Offset->delta($delta_time);

Returns the message time as a delta time or undef if it is an absolute
time.  Optionally sets the message time to the specified delta time.  To 
avoid contradictory times, the absolute time is set to undef when a delta time 
is set.

This functionality is provided by the MIDI::XML::Message base class.

=item $absolute_time = $Offset->absolute() or $Offset->absolute($absolute_time);

Returns the message time as an absolute time or undef if it is a delta
time.  Optionally sets the message time to the specified absolute time.  To 
avoid contradictory times, the delta time is set to undef when an absolute time 
is set.  The absolute time should be zero according to the specification. 

This functionality is provided by the MIDI::XML::Message base class.

=item $time = $Offset->time();

Returns the message time, absolute or delta, whichever was last set.

This functionality is provided by the MIDI::XML::Message base class.

=cut

#==========================================================================

=item $time_code_type = $Offset->time_code_type() or $Offset->time_code_type($time_code_type);

=cut

sub time_code_type {
    my $self = shift;
    if (@_) {
        my $r = shift;
        $self->{'_TimeCodeType'} = ($r & 0x03);
    }
    return  $self->{'_Rate'};
}

#==========================================================================

=item $hour = $Offset->hour() or $Offset->hour($hour);

=cut

sub hour {
    my $self = shift;
    if (@_) {
        $self->{'_Hour'} = shift;
    }
    return  $self->{'_Hour'};
}

#==========================================================================

=item $minute = $Offset->minute() or $Offset->minute($minute);

=cut

sub minute {
    my $self = shift;
    if (@_) {
        $self->{'_Minute'} = shift;
    }
    return  $self->{'_Minute'};
}

#==========================================================================

=item $second = $Offset->second() or $Offset->second($second);

=cut

sub second {
    my $self = shift;
    if (@_) {
        $self->{'_Second'} = shift;
    }
    return  $self->{'_Second'};
}

#==========================================================================

=item $frame = $Offset->frame() or $Offset->frame($frame);

=cut

sub frame {
    my $self = shift;
    if (@_) {
        $self->{'_Frame'} = shift;
    }
    return  $self->{'_Frame'};
}

#==========================================================================

=item $fraction = $Offset->fractional_frame() or $Offset->fractional_frame($fraction);

=cut

sub fractional_frame {
    my $self = shift;
    if (@_) {
        $self->{'_FractionalFrame'} = shift;
    }
    return  $self->{'_FractionalFrame'};
}

#==========================================================================

=item $ordinal = $Offset->ordinal();

Returns a value to be used to order events that occur at the same time.

sub ordinal {
    my $self = shift;
    return 0x0054 ;
}

#==========================================================================

=item @event = $Offset->as_event();

Returns a MIDI::Event smpte_offset array initialized with the values 
of the SmpteOffset object.  MIDI::Event does not expect absolute times 
and will interpret them as delta times.  Calling this method when the time 
is absolute will not generate a warning or error but it is unlikely that 
the results will be satisfactory.

=cut

sub as_event {
    my $self = shift;

    my @event = (
            'smpte_offset',
            MIDI::XML::Message::time($self),
            $self->{'_Hour'} | ($self->{'_TimeCodeType'} << 5),
            $self->{'_Minute'},
            $self->{'_Second'},
            $self->{'_Frame'},
            $self->{'_FractionalFrame'}
    );
    return @event;
}

#==========================================================================

=item @xml = $Offset->as_MidiXML();

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

    if ( defined($self->{'_TimeCodeType'})) {
        push @attr, "TimeCodeType=\"$self->{'_TimeCodeType'}\"";
    }
    if ( defined($self->{'_Hour'})) {
        push @attr, "Hour=\"$self->{'_Hour'}\"";
    }
    if ( defined($self->{'_Minute'})) {
        push @attr, "Minute=\"$self->{'_Minute'}\"";
    }
    if ( defined($self->{'_Second'})) {
        push @attr, "Second=\"$self->{'_Second'}\"";
    }
    if ( defined($self->{'_Frame'})) {
        push @attr, "Frame=\"$self->{'_Frame'}\"";
    }
    if ( defined($self->{'_FractionalFrame'})) {
        push @attr, "FractionalFrame=\"$self->{'_FractionalFrame'}\"";
    }
    push @xml, MIDI::XML::Message::as_MidiXML($self);
    $xml[2] = "<SmpteOffset @attr/>";
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

