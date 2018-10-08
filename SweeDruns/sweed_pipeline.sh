#!/bin/bash
#cat ~/work/sweed/nosingl_chromosomes/chr1 | while read LINE ; do

cat <chr-pos-rs_file> | while read LINE ; do
	IFS=$"#" read -ra TOK <<< "$LINE"

	chr=${TOK[0]}
	pos=${TOK[1]}
	rs=${TOK[2]}

	vcf_file=$'/home/anna/synology/common/1KGP_phase3_data/ALL.chr'$chr$'.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'

	start=$(($pos - 500000))
	end=$(($pos + 500000))

	mkdir $rs
	cd $rs

	~/work/sweed/GridFileCreator.py -c $chr -s $start -e $end -n 1000 #always 1000 positions in a range #Author:Ioannis Koutsoukos

	~/work/sweedApp/SweeD -grid 1000 -gridFile $'points.'$start$'.'$end$'.1000.out' -name $rs -folded -input $vcf_file

	cd ..

done;
