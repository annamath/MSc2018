############################
# Author: Anna Mathioudaki #
############################

# <><><><><> Required Packages <><><><><>
library(argparse)
library(ggplot2)

# <><><><><> Create Parser Argument <><><><><>
parser <- ArgumentParser()
parser$add_argument("-msmc_run", "--msmc_run", required=TRUE, help="Output of msmc")
parser$add_argument("-rs", "--rs", required=TRUE, help="rs ID")
parser$add_argument("-pop", "--population", required=TRUE, help="Population Analyzed")
args <- parser$parse_args()


Dat <- read.table(args$msmc_run, header=FALSE, colClasses=c("character", "numeric", "numeric", "numeric", "numeric"))
colnames(Dat) <- c("Individual", "time_index", "left_time_boundary", "right_time_boundary", "lambda")

unique(Dat$Individual)
mu <- 1.25e-8
gen <- 30

Dat$Time <- Dat$left_time_boundary/mu*gen

Dat$PopulationSize <- log10((1/Dat$lambda)/mu)

pdf(paste(args$rs, args$pop, ".pdf", sep=""))
ggplot(Dat, aes(x=Time, y=PopulationSize, colour=Individual)) +
	geom_line() + 
	theme(legend.position="bottom") + 
    theme(plot.title=element_text(size=12,colour="gray54")) +
    theme(plot.subtitle=element_text(size=8, color="gray68")) +
    labs(subtitle=args$population, x="Time", y="Effective Population Size", title=paste("Demography of ", args$rs, sep="")) +
	xlim(c(0, 5000000))
dev.off()
