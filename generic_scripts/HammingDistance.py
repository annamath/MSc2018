#!/usr/bin/python

############################
# Author: Anna Mathioudaki #
############################

# <><><><><> Required Packages <><><><><>
import pandas as pd
import numpy as np
import argparse

# <><><> Create Parser Argument <><><>
parser = argparse.ArgumentParser()
parser.add_argument("-binary_matrix", "--binary_matrix", required=True, help="Input matrix of 0s and 1s")
parser.add_argument("-output", "--output", required=True, help="Output file")
args = parser.parse_args()

# <><><> Load File <><><>
existing_df = pd.read_table(args.binary_matrix, sep="\t", header=0, index_col=0, engine='c')

def hamming_distance(matrix):
    """Computes the hamming distance between the rows of a pandas dataframe,
    while both of the datapoints are not equal to zero.
    Required modules: numpy, pandas"""

    a = len(matrix.index)
    b = len(matrix.columns)
    matrix = matrix.astype(np.float64)

    hamming_distance = np.zeros((a, a))

    numerator = 0
    denominator = 0
    
    i = 0
    while i <= a - 1:
        k = 0
        while k + i <= a - 1:
            j = 0
            while j <= b - 1:
                if matrix.iloc[i, j] != 0 or matrix.iloc[i+k, j] != 0: #or means and/or
                    numerator += abs(matrix.iloc[i, j] - matrix.iloc[i+k, j])
                    denominator += 1
                j += 1
            hamming_distance[i, i + k] = numerator / denominator
            k += 1
            denominator = 0
            numerator = 0
        i = i + 1

    hamming_distance = np.maximum(hamming_distance, hamming_distance.transpose())
    hammingdistance = pd.DataFrame(hamming_distance, columns= matrix.index, index=matrix.index)
    hammingdistance.to_csv(args.output, line_terminator='\n', sep="\t", header=True, index=True)

hamming_distance(existing_df)
