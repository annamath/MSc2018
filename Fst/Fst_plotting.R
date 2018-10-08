############################
# Author: Anna Mathioudaki #
############################

# <><><><><> Required Packages <><><><><>
library(argparse)
library(ggplot2)

# <><><><><> Create Parser Argument <><><><><>
parser <- ArgumentParser()

parser$add_argument("-Fst_output", "--Fst_output", required=TRUE, help="Population-Position-Fst")

args <- parser$parse_args()

# <><><> Read Table <><><>
af <- read.table(args$Fst_output, skip=3, header=FALSE, stringsAsFactors=FALSE)#colClasses=c('character', 'numeric', 'numeric'))
colnames(af) <- c("Population", "POS", "Fst")

rs <- basename(args$Fst_output)

# <><><> Convert Positions to megabases <><><>
af$Position <- as.numeric(af$POS)#/1e6

af$Position <- as.numeric(af$Position)/1e6

af$Fst <- as.numeric(af$Fst)
af <- data.frame(af)

pdf(paste(rs, ".pdf", sep=""), height=5, width=5)

ggplot(af, aes(x=Position, y=Fst, colour=Population)) + 
  geom_point(size=0.7) +
  theme(legend.position="bottom") + 
  theme(plot.title=element_text(size=14,colour="gray54")) +
  xlim(c(115097237/1e6, 115347237/1e6))+
  theme(legend.text=element_text(size=12)) +
  labs(x="Position (Mb)", y="Fst", title=rs)
  dev.off()

#how to get plotting colors
#g <- ggplot_build(p)

