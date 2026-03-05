#!/usr/bin/env Rscript
# Demo script for ggdiceplot package
# Run from the project root: Rscript demo_output/create_demo_plots.R

library(ggplot2)
library(legendry)
library(scales)
library(grid)

source("R/utils.R")
source("R/geom-dice-ggprotto.R")
source("R/geom-dice.R")

make_dice_plot <- function(toy_data, pip_fill = 1.0) {
  lo      <- floor(min(toy_data$lfc, na.rm = TRUE))
  up      <- ceiling(max(toy_data$lfc, na.rm = TRUE))
  mid     <- (lo + up) / 2
  minsize <- floor(min(-log10(toy_data$q), na.rm = TRUE))
  maxsize <- ceiling(max(-log10(toy_data$q), na.rm = TRUE))
  midsize <- ceiling(quantile(-log10(toy_data$q), 0.5, na.rm = TRUE))

  ggplot(toy_data, aes(x = specimen, y = taxon)) +
    geom_dice(
      aes(dots = disease, fill = lfc, size = -log10(q), width = 0.5, height = 0.5),
      na.rm       = TRUE,
      show.legend = TRUE,
      pip_fill    = pip_fill,
      ndots       = length(unique(toy_data$disease)),
      x_length    = length(unique(toy_data$specimen)),
      y_length    = length(unique(toy_data$taxon))
    ) +
    scale_fill_continuous(name = "lfc") +
    scale_fill_gradient2(
      low      = "#40004B", high = "#00441B", mid = "white",
      na.value = "white", limit = c(lo, up), midpoint = mid,
      name     = "Log2FC"
    ) +
    scale_size_continuous(
      limits = c(minsize, maxsize),
      breaks = c(minsize, midsize, maxsize),
      labels = c(10^minsize, 10^-midsize, 10^-maxsize),
      name   = "q-value"
    )
}

# ---- Example 1 --------------------------------------------------------------
cat("1. Creating example1...\n")
load("data/sample_dice_data1.rda")
ggsave("demo_output/example1.png", make_dice_plot(sample_dice_data1),
       width = 8, height = 8, dpi = 300)

# ---- Example 2 --------------------------------------------------------------
cat("2. Creating example2...\n")
load("data/sample_dice_data2.rda")
ggsave("demo_output/example2.png", make_dice_plot(sample_dice_data2),
       width = 10, height = 6, dpi = 300)

# ---- Example large ----------------------------------------------------------
cat("3. Creating example_large...\n")
load("data/sample_dice_large.rda")
ggsave("demo_output/example_large.png", make_dice_plot(sample_dice_large),
       width = 10, height = 6, dpi = 300)

# ---- Example 4: fill-only, pip_fill = 1.0 -----------------------------------
# No size mapping → auto-scaling active; pip_fill = 1.0 fills die face fully.
cat("4. Creating example4_fill_only...\n")
load("data/sample_dice_data1.rda")
toy_data <- sample_dice_data1
lo  <- floor(min(toy_data$lfc, na.rm = TRUE))
up  <- ceiling(max(toy_data$lfc, na.rm = TRUE))
mid <- (lo + up) / 2

pex4 <- ggplot(toy_data, aes(x = specimen, y = taxon)) +
  geom_dice(
    aes(dots = disease, fill = lfc, width = 0.9, height = 0.9),
    na.rm       = TRUE,
    show.legend = TRUE,
    pip_fill    = 1.0,
    ndots       = length(unique(toy_data$disease)),
    x_length    = length(unique(toy_data$specimen)),
    y_length    = length(unique(toy_data$taxon))
  ) +
  scale_fill_gradient2(
    low = "#40004B", high = "#00441B", mid = "white",
    na.value = "white", limit = c(lo, up), midpoint = mid,
    name = "Log2FC"
  ) +
  labs(
    title    = "Fill-only dice plot  (pip_fill = 1.0)",
    subtitle = "Pips fill the die face at maximal density"
  )

ggsave("demo_output/example4_fill_only.png", pex4, width = 8, height = 8, dpi = 300)

cat("All demonstration plots created successfully!\n")
cat("Generated files in demo_output/:\n")
cat("- example1.png\n- example2.png\n- example_large.png\n- example4_fill_only.png\n")
