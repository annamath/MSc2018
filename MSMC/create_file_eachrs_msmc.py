#!/usr/bin/python

############################
# Author: Anna Mathioudaki #
############################

# This scripts take as input multiple MSMC output files
# for each rsID, for each individuals and concatenates
# them by creating a 1st column which contains information
# about the individual
# This will be used for MSMC plotting

# <><><><><> Required Packages <><><><><>
import argparse
import pandas as pd
from os.path import basename

# <><><><><> Create Parser Argument <><><><><>
parser = argparse.ArgumentParser()

parser.add_argument("-rs", "--rs", required=True, help="rs")
parser.add_argument("files", type=argparse.FileType('r'), nargs='+')
args = parser.parse_args()

df = pd.DataFrame()

i = 0
for file in args.files:
	sample = str(basename(file).split(".")[0]).split("_")[1]
	with open(file, "r") as rf:
		next(rf) #dont read header
		for line in rf:
			fields = line.replace("\n", "").split("\t")
			f1 = fields[0]
			f2 = fields[1]
			f3 = fields[2]
			f4 = fields[3]
			df.loc[i, 0] = sample
			df.loc[i, 1] = f1
			df.loc[i, 2] = f2
			df.loc[i, 3] = f3
			df.loc[i, 4] = f4
			i = i + 1

df.to_csv(str("{}{}".format(args.rs, "ms")) ,line_terminator='\n', sep="\t", header=False, index=False)
