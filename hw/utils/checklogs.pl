#!/usr/bin/perl -w

use Term::ANSIColor;

my $latchfound;
$latchfound = 0;

while(<>) {
    if(/^WARNING:.* Found.*bit latch for signal/){
	$latchfound = 1;
	print color 'bold red';
	print "$_";
	print color 'reset';
    }elsif(/^ERROR:/){
	print color 'bold red';
	print "$_";
	print color 'reset';
    }elsif(/^WARNING:/){
	print color 'yellow';
	print "$_";
	print color 'reset';
    }else{
	print "$_";
    }
}

if($latchfound){
    print color 'bold red';
    print "checklogs.pl found one or more latch warnings, please check your code\n";
    print color 'reset';
    exit 1;
}
