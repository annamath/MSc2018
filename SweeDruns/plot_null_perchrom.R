# <><><><><> Required Packages <><><><><>
library(argparse)
library(ggplot2)

# <><><><><> Create Parser Argument <><><><><>
parser <- ArgumentParser()
parser$add_argument("-rand_chr", "--random_chromosome", required=TRUE, help="1000x1000 random sweed files, for each chrom")
parser$add_argument("-max_likelihood_perchrom", "--max_likelihood_perchrom", required=TRUE, help="Maximum max. likelihood per rs , created y plot_sweed.R")
parser$add_argument("-chrom", "--chromosome", required=TRUE, help="Chromosome of interest")
args <- parser$parse_args()

file <- read.csv(args$random_chromosome, sep="\t", header=FALSE, blank.lines.skip = TRUE, stringsAsFactors = FALSE)#colClasses="numeric" 
points <- read.csv(args$max_likelihood_perchrom, header=FALSE, blank.lines.skip=TRUE, stringsAsFactors=FALSE, colClasses="numeric")
dim(file)
max_col <- apply(file, 2, max)
typeof(max_col)
dim(max_col)
null_distribution <- sort(max_col)
right_threshold <- min(tail(sort(max_col), 0.05*length(max_col)))
#colnames(max_col) <- 'likelihood'

likelihood <- data.frame(max_col)
#dim(max_col)
#colnames(points) <- 'likelihood'
colnames(likelihood) <- 'likelihood'

#den <- density(max_col)

right_threshold
min_sweed <- min(points)
max_sweed <- max(points)
#points(points$likelihood, 0, pch=4, col='red')
pdf(paste(args$chromosome, "sweed_null.pdf", sep=""), height=6, width=6)

ggplot(data=likelihood, aes(x=likelihood)) +
  geom_density(data=likelihood,fill="gray54", alpha=.5) + 
  geom_vline(xintercept=c(min_sweed, right_threshold), color=c("black", "red3"), linetype=c( "longdash", "solid")) +
  geom_vline(xintercept=c(min_sweed, max_sweed, right_threshold), color=c("black", "black", "red3"), linetype=c("longdash", "longdash", "solid")) +
  #theme(plot.title=paste("SweeD Null Distribution - ", args$chromosome, collapse=""), size=8, face="plain", color="gray54")
  labs(title = paste("SweeD Null Distribution - ", args$chromosome, sep=""), size=8, face="plain", color="gray54")
dev.off()