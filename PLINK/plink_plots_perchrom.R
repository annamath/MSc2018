############################
# Author: Anna Mathioudaki #
############################

# <><><><><> Required Packages <><><><><>
library(argparse)
	
# <><><><><> Create Parser Argument <><><><><>
parser <- ArgumentParser()

parser$add_argument("-plink_r", "--plink_output_r", required=TRUE, help="PLINK's output file-Linkage Disequillibrium is calculated with r")
parser$add_argument("-plink_Dprime", "--plink_output_Dprime", required=TRUE, help="PLINK's output file-Linkage Disequillibrium is calculated with Dprime")
parser$add_argument("-output_pdf", "--output_pdf", required=TRUE, help="Name of the output PDF file to be created")
args <- parser$parse_args()

# <><><> Read PLINK's output file - r <><><>
a <- read.table(args$plink_output_r, sep="", header=T)
aa <- read.table(args$plink_output_Dprime, sep="", header=T)

# <><><> Calculate distances and extract LD for each case <><><>

# <><><> r <><><>
b <- nrow(a)
dist_ld <- data.frame()

for (i in 1:b){
  if (identical(a[i, 1], a[i, 4]) #if on the same chromosome 
  	& a[i,2] != a[i, 5]){  #and not on the same position
      dist <- abs(a[i, 2] - a[i, 5]) #assign distance
      dist_ld[nrow(dist_ld)+1, 1] <- a[i, 1] 
      dist_ld[nrow(dist_ld), 2] <- dist
      dist_ld[nrow(dist_ld), 3] <- a[i, 7]
  }
}
colnames(dist_ld) <- c('chr', 'distance', 'ld')

# <><><> Dprime <><><>
bb <- nrow(aa)
dist_ld2 <- data.frame()
for (i in 1:bb){
  if (identical(aa[i, 1], aa[i, 4]) & aa[i,2] != aa[i, 5]){
    dist2 <- abs(aa[i, 2] - aa[i, 5])
    dist_ld2[nrow(dist_ld2)+1, 1] <- a[i, 1]
    dist_ld2[nrow(dist_ld2), 2] <- dist2
    dist_ld2[nrow(dist_ld2), 3] <- aa[i, 7]
  }
}
colnames(dist_ld2) <- c('chr', 'distance', 'ld')

# <><><><><><>
chr <- sort(unique(as.matrix(a[,1])))
length(chr)

# <><><> Plot LD~distance for each chromosome <><><>
pdf(args$output_pdf, height=16, width=6)
#png(args$output_pdf, height=16, width=6)
layout(matrix(1:length(chr), ncol=3, byrow=TRUE))
#par(mfrow=c(length(chr),3))
for (i in chr){
  k <- dist_ld[dist_ld[, 1] == i, ]
  j <- dist_ld2[dist_ld2[, 1] == i, ]
  plot(k$distance, k$ld, type="p", pch=1, cex=1.5, col="slateblue1", xlab="Distance", ylab="LD", main=paste('Chromosome ', i, sep=""), ylim=c(-1, 1))
  points(j$distance, j$ld, col='slategray', pch=4)
  legend("bottomright",legend=c('r','D'), col=c("slateblue1", "slategray"), pch=c(1, 4), horiz=TRUE)
}
dev.off()
