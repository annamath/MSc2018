#!/usr/bin/perl -w
use strict;

my $infile= "";
my $sfs = 0;
my $sfsfile = "";

my $usage = "./vcf2ms.pl infile=<FILE> (-sfs)\n";

if($#ARGV < 0){
    die $usage, "\n";
}



while(my $args = shift @ARGV){
    if($args =~ /^infile=(.*)/i){ $infile = $1; next; }
    if($args =~ /^sfs=(.*)/){ $sfs = 1; $sfsfile = $1; next; }
    else{ die "Argument $args is invalid\n"; }
}


open(IN, $infile) or die "$!";

my @data = ();
my @w = ();
while(defined(my $ln = <IN>)){
    if($ln !~ /^\s*#/){
	@w = split('\s+', $ln);
	my @v = ();
	my $sum = 0;
	for(my $j = 0; $j < @w; ++$j){
	    if($w[$j] =~ /(\d)[\\\|](\d)/){
		my $first = $1;
		my $second = $2;
		if($first > 1){ $first = 1;}
		if($second > 1){ $second = 1; }
		$sum += $first + $second;
		push @v, $first, $second;
	    }		
	}
	if($sum == 0 || $sum == @v){
	    print STDERR "Warning... no polymorphism ... $w[0] $w[1] $w[2]\n";
	    next;
	}
	push @data, [@v];
    }
}

my %afs = ();
if($sfs == 1){
    open(SFS, ">$sfsfile") or die "Couldn't open $sfsfile for output\n";
    
    for(my $i = 0; $i < @data; ++$i){
	my $sum = 0;
	for(my $j = 0; $j < @{$data[0]}; ++$j){
	    if($data[$i][$j] != 0){ $sum++;}
	}
	if(defined($afs{$sum})){
	    $afs{$sum}+= 1;
	}
	else{
	    $afs{$sum} = 1;
	}
    }

    for( my $i = 0; $i <= @{$data[0]}; ++$i )
    {
	if( defined($afs{$i}) ){
	    print SFS "$i\t$afs{$i}\n";
	}else{
	    print SFS "$i\t0\n";
	}
    }
    close SFS;
}



my $prevLength = 0;
for( my $i = 0; $i < @{$data[0]}; ++$i )
{
    # if($prevLength != 0 && @{$data[$i]} != $prevLength){
    # 	die scalar @{$data[$i]}." is not equal to $prevLength\n";
    # }
    #prevLength = @{$data[$i]};
    for(my $j = 0; $j < @data; ++$j)
    {
	print $data[$j][$i];
    }
    print "\n";
}
	
    
