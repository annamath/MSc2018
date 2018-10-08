############################
# Author: Anna Mathioudaki #
############################

# <><><><><> Required Packages <><><><><>
library(argparse)

# <><><><><> Create Parser Argument <><><><><>
parser <- ArgumentParser()

parser$add_argument("-sweed_run", "--sweed_run", required=TRUE, help="SweeD output")
parser$add_argument("-chrom", "--chromosome", required=TRUE, help="Chromosome of interest")
parser$add_argument("-rand_chr", "--random_chromosome", required=TRUE, help="1000x1000 random sweed files, for each chrom")

args <- parser$parse_args()

directory <- getwd()

# <><><><><> Create the Null Distribution <><><><><>
# Get the values of the null distribution
# Null Hypothesis: There is no natural selection, since the positions are chosen randomly
# The 'random' chromosome files where created by the random_chr_pos_for_sweed.sh
setwd(args$random_chromosome)
file <- read.csv(args$chromosome, sep="\t", header=FALSE, blank.lines.skip = TRUE, stringsAsFactors = FALSE)#colClasses="numeric" 

max_col <- apply(file, 2, max)
null_distribution <- sort(max_col)
right_threshold <- min(tail(sort(max_col), 0.05*length(max_col)))

# <><><><><> Which of your max values correspond to the 2.5% of the ' right most extreme' values <><><><><>
# This will be considered as our threshold for the actual runs

# <><><><><> Load Sweed's Report File <><><><><>
setwd(directory)

# We are interested only in likelihoods-thus second column of the file
# First Line -> comment
# Second Line -> Header
sweed_run <- read.csv(args$sweed_run, skip=3, header=FALSE, colClasses="numeric", sep="\t", stringsAsFactors=FALSE)[, 2]
max_likelihood <- max(sweed_run)

write(max_likelihood, file=paste('~/work/sweed/sweed_nosingleton/maxlikelihoods', args$chromosome, paste="_"), append=TRUE)

#<><><> Keep the rs if it is in a location under selective sweep <><><>

if (max_likelihood>=right_threshold){
	rs <- basename(args$sweed_run)
	rs <- unlist(strsplit(rs, split="[.]"))[2] 
	print(rs)
}

