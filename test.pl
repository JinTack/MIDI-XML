# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1 };
use MIDI::XML::MidiFile;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

use strict;
#use MIDI::XML::MidiFile;
use MIDI::XML::Track;
use MIDI::XML::Parser;

use MIDI::Opus;
my $file = 'test';

my $opus = MIDI::Opus->new({ 'from_file' => "$file.mid"});
my $midi=MIDI::XML::MidiFile->new({'from_opus' => $opus});
my $measures = $midi->measures();
open XML,">","$file.xml";
print XML "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"; 
print XML join("\n",$midi->as_MidiXML());
close XML;
$MidiFile = MIDI::XML::Parser->parse_MidiXML("$file.xml");
