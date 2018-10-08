#!/usr/bin/python

# Author: ANNA MATHIOUDAKI

# <><><><><> Required Packages <><><><><>
import argparse
import re
import csv
import numpy as np
import pandas as pd
import itertools
from collections import defaultdict

# <><><><><> Create Parser Argument <><><><><>
parser = argparse.ArgumentParser()

parser.add_argument("-clinvar", "--clinvar_file", required=True, help="Clinvar file that contains all the logged variants")
parser.add_argument("-path_file", "--file_of_pathogenics", required=True, help="Output file that contains all the variants characterized as pathogenic")
parser.add_argument("-rsID_diseases", "--rsID_diseases", required=True, help="Output-rsID and corresponding diseases file")
parser.add_argument("-occur_matrix", "--occurences_matrix", required=True, help="Output-Matrix of zeros and ones indicating the match between SNV and disease")
parser.add_argument("-no_singl_matrix", "--no_singletons_occur_matrix", required=True, help="Output-Matrix of zeros and ones that indicate the match between SNV and diseases-NO SINGLETONS")

args = parser.parse_args()


# <><><> Create a file with Pathogenic Variants only <><><>

p=re.compile('CLNSIG=Pathogenic')

with open(args.clinvar_file,"r") as rf:
	with open(args.file_of_pathogenics, "w") as wf:
		for line in rf:
			pathogenicSNVs=p.findall(line)
			if len(pathogenicSNVs) > 0:
				wf.write(line)
			else:
				pass
# <><><> Create a file with the ID and the diseases of the path. variants <><><>

p = re.compile(r"^[\w]+\t[\w]+\t([\w]+)\t.*\;CLNDN=([^;]+)\;")

with open(args.rsID_diseases, "w") as wf:
	with open(args.file_of_pathogenics, "r") as rf:
		for line in rf:
			pathdis = p.findall(line)
			if len(pathdis) > 0:
				#wf.write(pathogenicdiseases[0]+'\t'+pathogenicdiseases[1]+'\n')
				wf.write(str(pathdis[0][0])+'\t'+str(pathdis[0][1])+'\n')

# <><><> Create a dictionary that has as keys rsIDs and as values diseases <><><>
# dict = {ID: diseases}
with open(args.rsID_diseases, "r") as f:
    SNP_dict = defaultdict(list)
    for line in f:
        collumns = line.split("\t")
        ID = collumns[0]
        diseases = (collumns[1].replace(",", "").replace("_", " ").replace("\n", "")).split('|')
        for j in range(len(diseases)):
            SNP_dict[ID].append(diseases[j])

# <><><> Create a dictionary that has as keys Diseases and as values rSIDs
#dict = {diseases: IDs}
disease_dict = defaultdict(list)
for k, v in SNP_dict.items():
    for item in v:
        disease_dict[item].append(k)

# <><><><> Create a 'Binary' matrix of diseases-variant matches <><><><><>

MatchingMatrix = np.zeros([len(disease_dict), len(SNP_dict)]) #initialize matrix with zeros

SNP_index = {k: i for i, k in enumerate(SNP_dict.keys())} #enumerate returns index-keys as keys and as values the index
disease_index = {k: i for i, k in enumerate(disease_dict.keys())}

header_col = list()
header_row = list()

for SNP_dict_key in SNP_dict.keys():
    col_index = SNP_index[SNP_dict_key]
    header_col.insert(int(col_index), SNP_dict_key)
    # if disease in disease_dict.keys()[disease_dict.values().index(SNP_dict_key)]:
    for disease in SNP_dict[SNP_dict_key]:
        if disease not in header_row:
            header_row.insert(disease_index[disease], disease)
            row_index = disease_index[disease]
            MatchingMatrix[row_index][col_index] = 1
        else:
            MatchingMatrix[row_index][col_index] = 1

# <><><> Write Matching Matrix (diseases-variants) to a new file <><><>

df1 = pd.DataFrame(data=MatchingMatrix, columns=header_col, index=header_row)
df1.to_csv(args.occurences_matrix, line_terminator='\n', sep="\t", header=True, index=True)

#df = pd.DataFrame(data=Matrix, dtype=int, columns=header_col, index=header_row) this is how you should load

# <><><> Drop singleton variants since they want help the disease grouping <><><>
# <><><> The grouping is based on variants-patterns <><><>

print "Removing SNPs"
for key, value in df1.iteritems():
    if sum(value) == 0 or sum(value) == 1: #that way we could remove the singletons
        df2 = df1.drop(key, axis=1)
print df2.shape

# <><><> Drop diseases with no 'variant' match <><><>
print "Removing diseases"
for index, row in df2.iterrows():
    if sum(row) == 0:
        df2 = df2.drop(index)
print df2.shape

# <><><> Get rid not-specified and not-provided pathogenicity <><><>
df2 = df2[df.index != 'not provided']
df2 = df2[df.index != 'not specified']
print df2.shape

# <><><> Create an occurence matrix with no singletons <><><>
# <><><> This will be also used for 'clustering' algorithms <><><>

df2.to_csv(args.no_singletons_occur_matrix, line_terminator='\n', sep="\t", header=True, index=True)
