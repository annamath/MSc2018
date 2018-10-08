############################
# Author: Anna Mathioudaki #
############################

# <><><><><> Required Packages <><><><><>
library(argparse)

#create parser argument
parser <- ArgumentParser()
parser$add_argument("-variant_info", "--variant_info", required=TRUE, help="Chromosome-Position-rsID for variants of interest")
parser$add_argument("-chrom_sizes", "--chromosome_sizes", required=TRUE, help="Chromosome Sizes")
parser$add_argument("-centromeres", "--centromere_positions", required=TRUE, help="Centromere positions")
args <- parser$parse_args()

snps <- read.table(args$variant_info)
#~~~~~~~~~RSIDs-row names
a <- snps[, 3]
rownames(snps) <- paste("rs", a, sep="")

#~~~~~~~~~Positions-col names
snps <- snps[, 1:2]
colnames(snps) <- c("chr", "start")

#~~~~~~~~~Chromosomes in correct order
ChrOrder <- paste("chr", c(1:21), sep="") #, "X", "Y"

#~~~~~~~~~Chromosome sizes
a <- read.table(args$chromosome_sizes, stringsAsFactors = F, sep = "\t", header = T)
b <- a[which(nchar(a[, 1]) <= 5), ]
max_chromosome <- as.numeric(max(b$size))
b <- b[match(ChrOrder, b$chrom), ]
rownames(b) <- b[,1]

#~~~~~~~~Centromere position
#        https://www.biostars.org/p/2349/
centr <- read.table(args$centromere_positions, colClasses=c("character", "integer", "integer", "character", "character"))
centr.list <- list()

#we fill first and then in the second we change min and max
for(i in 1:nrow(centr)){
  centr.list[[centr[i,1]]] <- c(min=centr[i,2], max=centr[i,3])
}

for(i in 1:nrow(centr)){
  centr.list[[centr[i,1]]][1] <- ifelse( centr.list[[ centr[i,1] ]][1] <centr[i,2], centr.list[[ centr[i,1] ]][1],centr[i,2])
  centr.list[[centr[i,1]]][2] <- ifelse( centr.list[[ centr[i,1]] ][2] >centr[i,3], centr.list[[ centr[i,1]] ][2],centr[i,3])
}

snps[,1] <- as.character(paste("chr", snps[,1], sep=""))
chrs <- as.character(unique(snps[,1]))

#~~~~~~~~~~Plot the SNP density (along with centromere position and chromosome size

pdf("SNPdensityPlot.pdf", height=16, width=6)
layout(matrix(1:nrow(b), ncol=3, byrow=TRUE))
i <- 1
for(i in 1:nrow(b)){
  e <- b[i,1]
  plot(c(0,b[i,2]), c(0, 0), col='red', xlab="", ylab="", axes=F, main=e, pch=19, cex=0.7, ylim=c(0,1), xlim=c(0, b[i,2]*1.1))
  axis(side=1,pos=0)
  rect(centr.list[[e]][1], 0, centr.list[[e]][2], 1, col="22111144")
  k <- snps[snps[,1]==e,]
  points(k[,2],rep(0.5, length(k[,2])), pch=19, cex=0.5) #y = sfs (af)
  den <-density( k[,2] )
  par(new=TRUE)
  plot(den$x, den$y, type='l', col='blue', axes=F, xlab="", ylab="")
}
dev.off()
