#!/usr/bin/env Rscript
# Demonstration of pip_fill auto-scaling in geom_dice

library(ggplot2)
library(dplyr)
library(legendry)
library(scales)
library(grid)
library(patchwork)

source("R/utils.R")
source("R/geom-dice-ggprotto.R")
source("R/geom-dice.R")

# ---- shared toy data -------------------------------------------------------

set.seed(42)
test_data <- data.frame(
  x        = rep(1:4, each = 4),
  y        = rep(1:2, times = 8),
  category = rep(c("A", "B", "C", "D"), times = 4),
  value    = runif(16, -2, 2)
)

# ---- Plot 1: pip_fill comparison (0.5 / 0.75 / 0.9 / 1.0 / NULL) ----------

make_base_plot <- function(pip_fill_val, title_label) {
  ggplot(test_data, aes(x = x, y = y)) +
    geom_dice(
      aes(dots = category, fill = value),
      ndots     = 4,
      x_length  = 4,
      y_length  = 2,
      pip_fill  = pip_fill_val
    ) +
    scale_fill_gradient2(
      low = "#2166AC", high = "#762A83", mid = "white",
      midpoint = 0, name = "value"
    ) +
    labs(title = title_label) +
    theme(plot.title = element_text(size = 10))
}

p_050 <- make_base_plot(0.50, "pip_fill = 0.50")
p_075 <- make_base_plot(0.75, "pip_fill = 0.75  (default)")
p_090 <- make_base_plot(0.90, "pip_fill = 0.90")
p_100 <- make_base_plot(1.00, "pip_fill = 1.00  (tight)")
p_off <- make_base_plot(NULL, "pip_fill = NULL  (fixed 3 mm)")

comparison <- (p_050 + p_075 + p_090) / (p_100 + p_off + plot_spacer()) +
  plot_annotation(
    title    = "pip_fill comparison",
    subtitle = "pip_fill scales both pip size and positions; NULL = legacy fixed size"
  )

ggsave("demo_output/pip_fill_comparison.png", comparison, width = 14, height = 9, dpi = 300)

# ---- Plot 2: tile size vs pip_fill = 0.75 and 1.0 -------------------------

make_tile_size_plot <- function(tile_w, title_label, pip_fill_val = 0.75) {
  ggplot(test_data, aes(x = x, y = y)) +
    geom_dice(
      aes(dots = category, fill = value, width = tile_w, height = tile_w),
      ndots    = 4,
      x_length = 4,
      y_length = 2,
      pip_fill = pip_fill_val
    ) +
    scale_fill_gradient2(
      low = "#2166AC", high = "#762A83", mid = "white",
      midpoint = 0, name = "value"
    ) +
    labs(title = title_label) +
    theme(plot.title = element_text(size = 9))
}

# row 1: pip_fill = 0.75
p_75_04  <- make_tile_size_plot(0.40, "pf=0.75, tile=0.40", 0.75)
p_75_07  <- make_tile_size_plot(0.70, "pf=0.75, tile=0.70", 0.75)
p_75_095 <- make_tile_size_plot(0.95, "pf=0.75, tile=0.95", 0.75)

# row 2: pip_fill = 1.0
p_10_04  <- make_tile_size_plot(0.40, "pf=1.00, tile=0.40", 1.00)
p_10_07  <- make_tile_size_plot(0.70, "pf=1.00, tile=0.70", 1.00)
p_10_095 <- make_tile_size_plot(0.95, "pf=1.00, tile=0.95", 1.00)

tile_comparison <- (p_75_04 + p_75_07 + p_75_095) /
                   (p_10_04 + p_10_07 + p_10_095) +
  plot_annotation(
    title    = "Auto-scaling adapts to tile width",
    subtitle = "Row 1: pip_fill=0.75  |  Row 2: pip_fill=1.00 (tight packing)"
  )

ggsave("demo_output/tile_size_comparison.png", tile_comparison, width = 14, height = 9, dpi = 300)

# ---- Plot 3: ndots 2 to 6 at pip_fill = 0.75 and 1.0 ---------------------

make_single_tile <- function(n, pip_fill_val) {
  d <- data.frame(
    x        = rep(1, n),
    y        = rep(1, n),
    category = LETTERS[1:n],
    value    = rep(c(-1, 1, -0.6, 0.6, -0.8, 0.8), length.out = n)  # no zeros
  )
  ggplot(d, aes(x = x, y = y)) +
    geom_dice(
      aes(dots = category, fill = value),
      ndots    = n,
      x_length = 1,
      y_length = 1,
      pip_fill = pip_fill_val
    ) +
    scale_fill_gradient2(
      low = "#2166AC", high = "#762A83", mid = "white",
      midpoint = 0, guide = "none"
    ) +
    labs(title = paste0("n=", n)) +
    theme_minimal() +
    theme(
      axis.text    = element_blank(),
      axis.title   = element_blank(),
      axis.ticks   = element_blank(),
      panel.grid   = element_blank(),
      plot.title   = element_text(size = 10, hjust = 0.5)
    )
}

row_75 <- lapply(2:6, make_single_tile, pip_fill_val = 0.75)
row_10 <- lapply(2:6, make_single_tile, pip_fill_val = 1.00)

ndots_comparison <- wrap_plots(c(row_75, row_10), nrow = 2) +
  plot_annotation(
    title    = "ndots 2–6: pip positioning and sizing",
    subtitle = "Top row: pip_fill=0.75  |  Bottom row: pip_fill=1.00"
  )

ggsave("demo_output/ndots_comparison.png", ndots_comparison, width = 14, height = 6, dpi = 300)

# ---- Plot 4: size mapping bypasses auto-scale (existing use case) ----------

set.seed(1)
test_data_sized <- test_data
test_data_sized$sig <- runif(16, 0.5, 4)

p_size_mapped <- ggplot(test_data_sized, aes(x = x, y = y)) +
  geom_dice(
    aes(dots = category, fill = value, size = sig),
    ndots    = 4,
    x_length = 4,
    y_length = 2,
    pip_fill = 1.0
  ) +
  scale_fill_gradient2(
    low = "#2166AC", high = "#762A83", mid = "white",
    midpoint = 0, name = "value"
  ) +
  scale_size_continuous(range = c(1, 5), name = "size") +
  labs(
    title    = "aes(size = ...) bypasses auto-scaling",
    subtitle = "pip_fill is ignored; user-mapped sizes are respected"
  )

ggsave("demo_output/size_mapped_example.png", p_size_mapped, width = 8, height = 5, dpi = 300)

cat("Generated files:\n")
cat("- demo_output/pip_fill_comparison.png\n")
cat("- demo_output/tile_size_comparison.png\n")
cat("- demo_output/ndots_comparison.png\n")
cat("- demo_output/size_mapped_example.png\n")
