#!/usr/bin/python

#./samples_from_haplotype.py -i path_rs_1KG.vcf -ps output(path_rs_samples)  -hap chr:start-end.vcf --get_path

#~~~~~Required packages
import pandas as pd
import argparse
import os
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_file", required=False,
                    help="This is the vcf file which contains the path_rs from 1000genomes")
parser.add_argument("-ps", "--samples_of_pathogenic", required=True, help="This is either created "
                                                                          "from the program or already exists")
parser.add_argument("-hap", "--haplotype_file", required=False, help="haplotype's vcf file. Filename 'format'->"
									  " chr:start-end.vcf")
parser.add_argument("--get_path", required=False, action="store_true",
                    help="Return all pathogenic rsIDs in the given haplotype")
args = parser.parse_args()

def file_validation(parser, arg):
    """If an input file doesn't exist raise error"""
    if not os.path.exists(str(arg)):
        parser.error("File %s does not exist" % arg)
    else:
        pass

def header_counter(file):
    """Returns the number of comment-header lines from vcf"""
    has_counter = 0  # this is a counter of of header lines
    with open(file, "r") as f:
        for line in f:
            if line.startswith('#'):
                has_counter = has_counter + 1
    return has_counter

def get_samples(input, output):
    """Create a file which contains the pathogenic variants from 1KG and their ~samples~"""
    file_validation(parser, input)
    has_counter = header_counter(input)
    df = pd.read_csv(input, header=(int(has_counter) - 1), sep='\t')
    path_list = df['ID'].tolist()
    
    with open(output, "w") as wf:
        for j in range(0, len(df.index)):
            tmp_df = pd.DataFrame(df.iloc[j, :])  # select one row and all columns
	    tmp_df = tmp_df.transpose()	    
	    tmp_df = tmp_df.astype(np.object) # i couldnt run the next command without np.object
	    
            samples = list(tmp_df.columns[(tmp_df != '0|0').iloc[0]]) #in pandas series you cannot use .loc .iloc etc
	    samples = samples[9:]	    

	    samples = str(samples)

	    chr = tmp_df.iloc[0, 0]
	    pos = tmp_df.iloc[0, 1]
	    rs = tmp_df.iloc[0, 2]

            wf.write(str(chr)+'\t'+str(pos)+'\t'+rs+'\t'+samples+'\n')

    global path_list

def haplotype_driver(input):
    """Returns the rs from which this haplotype was extracted
    & a list of samples which contain that particular haplotype.
    If required, it returns also a file with list of pathogenic
    rs within that haplotype"""

    file_validation(parser, input)
    haplotype = os.path.splitext(os.path.basename(input))[0]
    print haplotype
    fields = haplotype.replace(":", "-").replace("_", "-").replace(".","-")####careful with the name-format
    fields = fields.split("-")

    middle = abs(int(fields[2]) + int(fields[1]))/2
    has_counter = header_counter(input)
    
    output1 = '{}{}'.format(haplotype, '_samples')
    df = pd.read_csv(input, header=(int(has_counter) - 1), sep='\t') #read haplotypes' vcf file
 
    with open(output1, "w") as w1f:
	tmp_df = df[df.values  == middle]
	driver_rs = tmp_df.iat[0, 2]
	tmp_df = tmp_df.astype(np.object)

	samples1 = list(tmp_df.columns[(tmp_df == '1|0').iloc[0]])
	samples2 = list(tmp_df.columns[(tmp_df == '1|1').iloc[0]])
	samples = samples1 + samples2

	w1f.write(driver_rs+ '\t'+ str(samples))

    if args.get_path:
        print "The IDs of pathogenic SNPs within that haplotype" \
              " will be printed in a seperate file"

        output2 = '{}{}'.format(haplotype, '_pathogenic')
        hap_rs = df['ID'].tolist()
        
	with open(output2, "w") as w2f:
            for i in hap_rs:
                if i in path_list:
                    w2f.write(i+'\n')
                else:
                    pass
    else:
        pass

if __name__ == '__main__':
    if args.input_file:
        get_samples(args.input_file, args.samples_of_pathogenic)
    else:
        p_df = pd.read_csv(args.samples_of_pathogenic, sep = '\t')
        path_list = p_df.iloc[:,2].tolist()
    haplotype_driver(args.haplotype_file)
