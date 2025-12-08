#!/usr/bin/env Rscript
# Test to verify that pad parameter works correctly in geom_dice()

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
  x = rep(1:2, each = 3),
  y = rep(1:3, times = 2),
  category = rep(c("A", "B", "C"), times = 2),
  value = runif(6, -2, 2)
)

print("Test data:")
print(test_data)

# Test 1: Default pad (0.1)
print("\nTest 1: Creating plot with default pad = 0.1")
p1 <- ggplot(test_data, aes(x = x, y = y)) +
  geom_dice(
    aes(
      dots = category,
      fill = value
    ),
    ndots = 3,
    x_length = 2,
    y_length = 3
  ) +
  ggtitle("Default pad = 0.1")

print("Plot 1 created successfully")

# Test 2: Increased pad (0.2) - dots closer to center
print("\nTest 2: Creating plot with pad = 0.2 (dots closer to center)")
p2 <- ggplot(test_data, aes(x = x, y = y)) +
  geom_dice(
    aes(
      dots = category,
      fill = value
    ),
    ndots = 3,
    x_length = 2,
    y_length = 3,
    pad = 0.2
  ) +
  ggtitle("Increased pad = 0.2")

print("Plot 2 created successfully")

# Test 3: Minimal pad (0.05) - dots closer to edges
print("\nTest 3: Creating plot with pad = 0.05 (dots closer to edges)")
p3 <- ggplot(test_data, aes(x = x, y = y)) +
  geom_dice(
    aes(
      dots = category,
      fill = value
    ),
    ndots = 3,
    x_length = 2,
    y_length = 3,
    pad = 0.05
  ) +
  ggtitle("Minimal pad = 0.05")

print("Plot 3 created successfully")

# Test make_offsets directly with different pad values
print("\nTesting make_offsets() directly:")
print("pad = 0.1 (default):")
print(make_offsets(3, pad = 0.1))

print("\npad = 0.2 (more centered):")
print(make_offsets(3, pad = 0.2))

print("\npad = 0.05 (more spread):")
print(make_offsets(3, pad = 0.05))

print("\nAll tests completed successfully!")
