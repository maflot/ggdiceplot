#!/usr/bin/env Rscript
# Simple test of geom_dice

library(ggplot2)
library(dplyr)
library(legendry)
library(scales)
library(grid)

# Load ggdiceplot functions
source("R/utils.R")
source("R/geom-dice-ggprotto.R")
source("R/geom-dice.R")

# Create simple test data
test_data <- data.frame(
  x = rep(1:3, each = 4),
  y = rep(1:2, times = 6),
  category = rep(c("A", "B", "C", "D"), times = 3),
  value = runif(12, -2, 2),
  size_val = runif(12, 0.1, 1)
)

print("Test data:")
print(test_data)

# Create simple plot
p <- ggplot(test_data, aes(x = x, y = y)) +
  geom_dice(
    aes(
      dots = category,
      fill = value,
      size = size_val
    ),
    ndots = 4,  # 4 categories
    x_length = 3,
    y_length = 2
  )

print(p)