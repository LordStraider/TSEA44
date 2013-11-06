#!/usr/bin/perl -w
# Usage: analyze.pl foo.xdl
#
# If you want to get statistics about modules that are not
# instantiated on the top level you need to specify these on the
# command line:
# analyze.pl leela/cpu0 leela/mc0 foo.xdl
#
# Note that the figures will usually not be exactly the same as the
# figures reported by map. This is because map does not count a 
# LUT with a constant output as a LUT, at least not in ISE 8.1.
#

use IO::Handle;

my %themodules;
my %luts;
my %ff;
my %iob;
my %ramb16;
my %mult;


my $arg;
for($arg = 0; $arg < $#ARGV;$arg++) {
    $themodules{$ARGV[$arg]} = 1;
}


sub add_component {
    my $thename = $_[0];
    my $thetype = $_[1];

    my @temppath = split("/",$thename);
    my @list = ();
    my $currname = $temppath[0];
    push(@list,$currname);
    
    for($i = 1; $i < $#temppath; $i = $i  + 1) {
	$currname = "$currname/$temppath[$i]";
	push(@list,$currname);
    }
    
    for($i = 0; $i < $#temppath; $i = $i + 1) {
	$currname = pop(@list);
	if($themodules{$currname}) {
	    $i = $#temppath;
	}
    }
    
    if($thename =~ /\//) {
    }else{
	$currname = "/";
    }
    
    if($thetype == 1) {
	$luts{$currname}++;
    }
    
    if($thetype == 2) {
	$ff{$currname}++;
    }
    
    if($thetype == 3) {
	$iob{$currname}++;
    }
    
    if($thetype == 4) {
	$ramb16{$currname}++;
    }
    
    if($thetype == 5) {
	$mult{$currname}++;
    }
    
    $themodules{$currname} = 1;
}

print "Analyzing the file $ARGV[$#ARGV]...";
STDOUT->autoflush(1);

open THEFILE, '<', $ARGV[$#ARGV] or die;

my $line = 0;
while (<THEFILE>){
    $line++;

    if($line == 1000){
	$line = 0;
	print(".");
	STDOUT->autoflush(1);
    }

    if(/ F:([a-zA-Z0-9_\/\[\]<>\.]+:\#([A-Z]+):D=.*)/) {
	&add_component($1,1);
    }

    if(/ G:([a-zA-Z0-9_\/\[\]<>\.]+:\#([A-Z]+):D=.*)/) {
	&add_component($1,1);
    }


    if(/FFX:([a-zA-Z0-9_\/\[\]<>\.]+:\#[A-Z]+)/) {
	&add_component($1,2);
    }

    if(/FFY:([a-zA-Z0-9_\/\[\]<>\.]+:\#[A-Z]+)/) {
	&add_component($1,2);
    }

    if(/^inst \"([a-zA-Z0-9_\/\[\]<>\.]+)\" \"IOB\"/){
	&add_component($1,3);
    }

    if(/^inst \"([a-zA-Z0-9_\/\[\]<>\.]+)\" \"RAMB16\"/){
	&add_component($1,4);
    }

    if(/^inst \"([a-zA-Z0-9_\/\[\]<>\.]+)\" \"MULT18X18\"/){
	&add_component($1,5);
    }

}

print "\n";

my $maxval = length("Module ");
my @thekeys = keys %themodules;
@thekeys = sort(@thekeys);

foreach $i (@thekeys) {
    if($maxval < length($i)){
	$maxval = length($i);
    }
}

print "|-------";
for($i = 0; $i < $maxval - 6; $i = $i + 1){
    print "-";
}

print "+-------+-------+--------+------------+-------+\n" ;

print "|Module ";
for($i = 0; $i < $maxval - 6; $i = $i + 1){
    print " ";
}
print "|   LUT |    FF | RAMB16 | MULT_18x18 |   IOB |\n" ;

print "|-------";
for($i = 0; $i < $maxval - 6; $i = $i + 1){
    print "-";
}

print "+-------+-------+--------+------------+-------+\n" ;

my $totalluts = 0;
my $totalff = 0;
my $totaliob = 0;
my $totalramb16 = 0;
my $totalmult = 0;

foreach $name (@thekeys) {
    print "|$name";
    for($i = length($name); $i < $maxval; $i = $i + 1) {
	print " ";
    }
    if($luts{$name}) {
	printf(" |% 6d ",$luts{$name});
	$totalluts += $luts{$name};
    }else{
	printf(" |       ");
    }

    if($ff{$name}) {
	printf("|% 6d ",$ff{$name});
	$totalff += $ff{$name};
    }else{
	printf("|       ");
    }

    if($ramb16{$name}) {
	$totalramb16 += $ramb16{$name};
	printf("| % 6d ",$ramb16{$name});
    }else{
	printf("|        ");
    }

    if($mult{$name}) {
	$totalmult += $mult{$name};
	printf("|     % 6d ",$mult{$name});
    }else{
	printf("|            ");
    }

    if($iob{$name}) {
	$totaliob += $iob{$name};
	printf("|% 6d |\n",$iob{$name});
    }else{
	printf("|       |\n");
    }
}


print "|-------";
for($i = 0; $i < $maxval - 6; $i = $i + 1){
    print "-";
}

print "+-------+-------+--------+------------+-------+\n" ;

print "|Total";
for($i = 5; $i < $maxval; $i = $i + 1) {
    print " ";
}

if($totalluts) {
    printf(" |% 6d ",$totalluts);
}else{
	printf(" |       ");
}

if($totalff) {
    printf("|% 6d ",$totalff);
}else{
	printf("|       ");
    }

if($totalramb16) {
    printf("| % 6d ",$totalramb16);
}else{
    printf("|        ");
}

if($totalmult) {
    printf("|     % 6d ",$totalmult);
}else{
    printf("|            ");
}

if($totaliob) {
    printf("|% 6d |\n",$totaliob);
}else{
    printf("|       |\n");
}

print "|-------";
for($i = 0; $i < $maxval - 6; $i = $i + 1){
    print "-";
}

print "+-------+-------+--------+------------+-------+\n" ;
