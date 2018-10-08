#!/usr/bin/python2.7

# <><><><><> Required Packages <><><><><>
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-fa", "--fasta_file", required=True, help="Input fasta file from which I want to get chromosome sizes")
parser.add_argument("-o", "--output", required=True, help="Output file")
args = parser.parse_args()

def main(file, output_file):
     with open(output_file, 'w') as wf:
	with open(file, 'r') as f:
	     for line in f:
		if line.startswith('>'):
		     chr = line.replace('>chr', '')
		     seq = ''
		elif not line.startswith('>'):
		     seq = seq + str(line)
		     seq = seq.replace('\n', '')
	     wf.write(str(chr)+'\t'+str(len(seq))+'\n')

main(args.fasta_file, args.output)
