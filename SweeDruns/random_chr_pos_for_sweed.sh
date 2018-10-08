#!/bin/bash

#~~~~~From the whole chromosome files, read 1000 random lines~ likelihoods
#~~~~~1000*1000 matrix

for file in <whole_chromosome_sweed_runs_directory> ; do #valto sto swsto directory
	file=~/work/sweed/whole_chromosomes/sweed_runs/SweeD_Report.chr2
	IFS=$"." read -ra TOK <<< "$file"
	chr=${TOK[-1]}
	for i in {1..1000}; do
		sed 1,3d $file | shuf -n 1000 | awk '{print $2}' > $chr$'_'$i
	done;
	paste -d *$chr$'_'* >> $chr$'random'
	rm $chr$'_'*
done;

