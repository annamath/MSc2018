#!/usr/bin/env Rscript
library(argparse)

stringToVector <- function(x){
  as.numeric(unlist(strsplit(x, split="")))
}

#create parser argument
parser <- ArgumentParser()

parser$add_argument("-if", "--info_file", required=TRUE, help="giveHaploCode.pl output")
parser$add_argument("-loc", "--rs_location", required=TRUE, help="Location of path rsID within the haplotype processed, giveHaploCode.pl output")

parser$add_argument("-ms", "--ms_file", required=TRUE, help="ms file of 250k haplotype that contains pathogenic variant")
parser$add_argument("-rs", "--rsID", required=TRUE, help="rsID")

parser$add_argument("-sample.list", "--sample.list", required=TRUE, help="1KG samples, ordered") #/home/anna/work/pcas/sample.list
parser$add_argument("-sample.INFO", "--sample.INFO, required=TRUE, help="Individuals and corresponding populations") #"/home/anna/work/pcas/sample.INFO"
parser$add_argument("-popGroups.INFO", "--popGroups.INFO", required=TRUE, help="Subpopulation and Populations") #"/home/anna/work/pcas/popGroups.INFO"

args <- parser$parse_args()

haplo.info <- read.table(args$info_file)
rs_location <- as.numeric(read.table(args$rs_location, colClasses="numeric")[1,1])

#~~~~~Load ms file~~~~~
aa <- read.table(args$ms_file, colClasses="character")

listOfSamples <- read.table(args$sample.list, colClasses = "character")[,1] #1KG samples, ordered
samplePopInfo <- read.table(args$sample.INFO, header=TRUE, colClasses = "character") # individual population
popGroupInfo <- read.table(args$popGroups.INFO, sep="\t", colClasses = "character") # subpop-info-superpop

inds <- sapply(listOfSamples, function(x){which( samplePopInfo[,1] == x)}) #individuals
inds <- rep(inds, each=2) # since im using ms file format, ...
pops <- samplePopInfo[inds,2] #and their corresponding populations

#Superpopulations
groups <- sapply(pops, function(x){ ind=which(popGroupInfo[,1] == x); popGroupInfo[ind,3]}) #and their corresponding superpopulations
uniqueGroups <- unique(groups) # EUR EAS SAS AFR AMR

#Take a smaller area of the haplotype

#~~~~~Colors
colors <- 1:length(uniqueGroups)
cols <- sapply(groups, function(x){ind=which(uniqueGroups == x); colors[ind]}) #colors of subpopulations, based on populations
mat <- t(apply(aa, 1, stringToVector)) #5008 1684
colnames(mat) <- 1:ncol(mat)

#Take a smaller area of the haplotype
range <- as.numeric(length(mat[1, ]) / 4)
start <- as.numeric(as.numeric(rs_location) - range)
end <- as.numeric(as.numeric(rs_location) + range)

myPCA <- prcomp(x=mat[,start:end], scale.=TRUE, center = TRUE)
summary(myPCA)

pdf(paste(args$rsID, "_", as.character(range), "_pca.pdf", sep=""), height= 10, width= 10)
plot(myPCA$x[cols==1,1], myPCA$x[cols==1,2], pch=19, main=sub=args$rsID, col=cols[cols==1], col.sub="gray73", cex=0.4, xlab='PC1', ylab='PC2', cex.main=1.5) #sub=args$rsID, 

#for j in length of unique colors, you will subset the pca matrix and then take colors
for(j in 2:length(unique(cols))){
  points(myPCA$x[cols==j,1], myPCA$x[cols==j,2], pch=19, col=cols[cols==j], cex=0.4)
}  #for each superpop

# Plot pathogenic samples
points(myPCA$x[haplo.info==1, 1], myPCA$x[haplo.info==1, 2], pch=8, col=7, cex=0.4)

legend("topright", c(uniqueGroups, 'PATH'), inset=c(0,0), cex=0.8, col=c(1, 2, 3, 4, 5, 7), pch=c(19,19,19,19,19,9)) #lty=c(1, 1, 1, 1, 1, 1),

dev.off()
