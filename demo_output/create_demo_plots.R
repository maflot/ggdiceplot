#!/usr/bin/env Rscript
# Demo script for ggdiceplot package
# This script creates demonstration plots showcasing the package capabilities

library(ggplot2)

# Load the ggdiceplot functions
source("../R/utils.R")
source("../R/geom-dice.R")
source("../R/geom-dice-ggprotto.R")

# Already in demo_output directory
cat("Working from demo_output directory...\n")

cat("Creating ggdiceplot demonstration plots...\n")

# Demo 1: Basic dice plot functionality
cat("1. Creating example1 plot demo...\n")

# Load dataset sample_dice_data1 from package data folder and assign to toy_data1
load("../data/sample_dice_data1.rda")  # loads object sample_dice_data1 in environment
toy_data1 <- sample_dice_data1

# Effect size
lo = floor(min(toy_data$lfc, na.rm = TRUE))
up = ceiling(max(toy_data$lfc, na.rm=TRUE))
mid = (lo + up)/2

minsize = floor(min(-log10(toy_data$q), na.rm=TRUE))
maxsize = ceiling(max(-log10(toy_data$q), na.rm=TRUE))
midsize = ceiling(quantile(-log10(toy_data$q), c(0.5), na.rm=TRUE))

#
## PLOT
#

pex1 <- ggplot(toy_data1, aes(x=specimen, y=taxon)) +
  geom_dice(aes(dots=disease, fill=lfc, size=-log10(q), 
                # Square dims
                width = 0.5, height = 0.5),
            # For missing info
            na.rm = TRUE,
            # For legend display
            show.legend=TRUE, 
            # For legend position calculation
            ndots=length(unique(toy_data$disease)),
            # For aspect.ratio: ensure squares
            x_length = length(unique(toy_data$specimen)), 
            y_length = length(unique(toy_data$taxon)), 
  )+
  scale_fill_continuous(name="lfc") +
  scale_fill_gradient2(low = "#40004B", high = "#00441B", mid = "white",
                       na.value = "white", 
                       limit = c(lo, up),
                       midpoint = mid, 
                       name = "Log2FC") +
  scale_size_continuous(limits = c(minsize, maxsize),
                        breaks = c(minsize, midsize, maxsize),
                        labels = c(10^minsize, 10^-midsize, 10^-maxsize),
                        name = "q-value")

ggsave("example1.png", pex1, width = 8, height = 8, dpi = 300)


# Demo 2: Dense grid showcase
cat("2. Creating example2 plot demo...\n")
# Load dataset sample_dice_data2 from package data folder and assign to toy_data2
load("../data/sample_dice_data2.rda")
toy_data2 <- sample_dice_data2

# Effect size
lo = floor(min(toy_data$lfc, na.rm = TRUE))
up = ceiling(max(toy_data$lfc, na.rm=TRUE))
mid = (lo + up)/2

minsize = floor(min(-log10(toy_data$q), na.rm=TRUE))
maxsize = ceiling(max(-log10(toy_data$q), na.rm=TRUE))
midsize = ceiling(quantile(-log10(toy_data$q), c(0.5), na.rm=TRUE))

#
## PLOT
#

pex2 <- ggplot(toy_data, aes(x=specimen, y=taxon)) +
  geom_dice(aes(dots=disease, fill=lfc, size=-log10(q), 
                # Square dims
                width = 0.5, height = 0.5),
            # For missing info
            na.rm = TRUE,
            # For legend display
            show.legend=TRUE, 
            # For legend position calculation
            ndots=length(unique(toy_data$disease)),
            # For aspect.ratio: ensure squares
            x_length = length(unique(toy_data$specimen)), 
            y_length = length(unique(toy_data$taxon)), 
  )+
  scale_fill_continuous(name="lfc") +
  scale_fill_gradient2(low = "#40004B", high = "#00441B", mid = "white",
                       na.value = "white", 
                       limit = c(lo, up),
                       midpoint = mid, 
                       name = "Log2FC") +
  scale_size_continuous(limits = c(minsize, maxsize),
                        breaks = c(minsize, midsize, maxsize),
                        labels = c(10^minsize, 10^-midsize, 10^-maxsize),
                        name = "q-value")

ggsave("example2.png", pex1, width = 10, height = 6, dpi = 300)




cat("All demonstration plots created successfully!\n")
cat("Generated files in demo_output/:\n")
cat("- example1.png\n")
cat("- example2.png\n")