#!/usr/bin/perl -w

use strict;

my $usage = "./giveHaploCode.pl -in VCF -rs rsID\n";
if($#ARGV < 0){ die $usage; }

my $vcffile = "";
my $rsid = "";
while(my $args = shift @ARGV){
    if($args =~ /^-in$/i){ $vcffile = shift @ARGV; next; }
    if($args =~ /^-rs$/i){ $rsid = shift @ARGV; next; }
    die "Argument $args is invalid. $usage\n"; 
}

open(IN, $vcffile) or die "Coudnlt open $vcffile for input $!\n";

my @v = ();
my @w = ();
my @haplos = ();
while( defined( my $ln = <IN>)){
    if($ln =~ /$rsid/){
	@v = split(/\s+/, $ln);
	for(my $i = 9; $i < @v; ++$i){
	    @w = split('\|', $v[$i]) ;
	    push @haplos, @w;
	}
    }
}

my $cnt = 0;
my $cnt2 = 0;
my $cnt3=0;
foreach my $h (@haplos){
    if( $h == 1){ $cnt2++; }
    if( $h == 0){ $cnt3++; }
    $cnt++;
    print $h, " ";
} 
print "\n";

print STDERR "ALL: $cnt\n";
print STDERR "1s: $cnt2\n";
print STDERR "0s: $cnt3\n";

	    
