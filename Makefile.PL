# This -*- perl -*- script writes the Makefile for MIDI-XML
# Time-stamp: "2003-01-20 19:56:43 EST"
use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		    => 'MIDI-XML',
    'VERSION_FROM'	=> 'lib/MIDI/MidiFile.pm', 
    'ABSTRACT'      => 'convert MIDI files to and from XML',
    'PREREQ_PM'		=> {MIDI => 7.9, HTML::Entities => 0}, 
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (AUTHOR     => 'Brian M. Ames <bmames@apk.net>') : ()),
);
