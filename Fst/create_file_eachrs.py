#!/usr/bin/python

############################
# Author: Anna Mathioudaki #
############################

# This scripts take as input multiple Fst output files
# for each rsID and concatenates them by creating a 1st
# column which contains information about the population

# This will be used for Fst plotting

# <><><><><> Required Packages <><><><><>
import argparse
import pandas as pd

# <><><><><> Create Parser Argument <><><><><>
parser = argparse.ArgumentParser()

parser.add_argument("-rs", "--rs", required=True, help="rs")
parser.add_argument("-AMR", "--AMR", required=True, help="AMR Fst output")
parser.add_argument("-AFR", "--AFR", required=True, help="AFR Fst output")
parser.add_argument("-EUR", "--EUR", required=True, help="EUR Fst output")
parser.add_argument("-EAS", "--EAS", required=True, help="EAS Fst output")
parser.add_argument("-SAS", "--SAS", required=True, help="SAS Fst output")

args = parser.parse_args()

df = pd.DataFrame()

i = 0
for file in (args.AMR, args.AFR, args.EUR, args.EAS, args.SAS):
	population = file.split("/")[-2]#.split('_')[1]
	with open(file, "r") as rf:
		for line in rf:
			fields = line.replace("\n", "").split("\t")
			position = fields[1]
			fst = fields[2]
			df.loc[i, 0] = population
			df.loc[i, 1] = position
			df.loc[i, 2] = fst
			i = i + 1

df.to_csv(str("{}{}".format(args.rs, "Fst")) ,line_terminator='\n', sep="\t", header=True, index=False)
