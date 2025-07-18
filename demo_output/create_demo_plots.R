#!/usr/bin/env Rscript
# Demo script for ggdiceplot package
# This script creates demonstration plots showcasing the package capabilities

library(ggplot2)

# Load the ggdiceplot functions
source("../R/utils.R")
source("../R/geom_dice.R")

# Already in demo_output directory
cat("Working from demo_output directory...\n")

cat("Creating ggdiceplot demonstration plots...\n")

# Demo 1: Basic dice plot functionality
cat("1. Creating basic dice plot demo...\n")
basic_data <- data.frame(
  x = rep(1:4, each = 3),
  y = rep(1:3, times = 4),
  categories = c("A", "A,B", "A,B,C", "A,B,C,D", "A,B,C,D,E", "A,B,C,D,E,F",
                 "A", "A,B", "A,B,C", "A,B,C,D", "A,B,C,D,E", "A,B,C,D,E,F")
)

category_positions <- c("A" = 1, "B" = 2, "C" = 3, "D" = 4, "E" = 5, "F" = 6)

p_basic <- ggplot(basic_data, aes(x = x, y = y, categories = categories)) +
  geom_dice(category_positions = category_positions) +
  scale_x_continuous(breaks = 1:4, limits = c(0.5, 4.5)) +
  scale_y_continuous(breaks = 1:3, limits = c(0.5, 3.5)) +
  labs(title = "Basic Dice Plot", 
       subtitle = "Showing category combinations using dice metaphor",
       x = "X Position", y = "Y Position") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

ggsave("basic_dice_demo.png", p_basic, width = 10, height = 6, dpi = 300)

# Demo 2: Dense grid showcase
cat("2. Creating dense grid demo...\n")
dense_data <- data.frame(
  x = rep(1:6, each = 6),
  y = rep(1:6, times = 6),
  categories = sample(c("A", "A,B", "A,B,C", "A,B,C,D", "A,B,C,D,E", "A,B,C,D,E,F"), 36, replace = TRUE)
)

p_dense <- ggplot(dense_data, aes(x = x, y = y, categories = categories)) +
  geom_dice(category_positions = category_positions) +
  scale_x_continuous(breaks = 1:6, limits = c(0.5, 6.5)) +
  scale_y_continuous(breaks = 1:6, limits = c(0.5, 6.5)) +
  labs(title = "Dense Grid: Auto-scaled Dice", 
       subtitle = "6x6 grid with automatic size adjustment",
       x = "X Position", y = "Y Position") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

ggsave("dense_grid_demo.png", p_dense, width = 8, height = 8, dpi = 300)

# Demo 3: Sparse grid showcase
cat("3. Creating sparse grid demo...\n")
sparse_data <- data.frame(
  x = rep(1:3, each = 3),
  y = rep(1:3, times = 3),
  categories = c("A", "A,B", "A,B,C", "A,B,C,D", "A,B,C,D,E", "A,B,C,D,E,F", "A", "A,B", "A,B,C")
)

p_sparse <- ggplot(sparse_data, aes(x = x, y = y, categories = categories)) +
  geom_dice(category_positions = category_positions) +
  scale_x_continuous(breaks = 1:3, limits = c(0.5, 3.5)) +
  scale_y_continuous(breaks = 1:3, limits = c(0.5, 3.5)) +
  labs(title = "Sparse Grid: Large Dice", 
       subtitle = "3x3 grid with larger dice for better visibility",
       x = "X Position", y = "Y Position") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

ggsave("sparse_grid_demo.png", p_sparse, width = 6, height = 6, dpi = 300)

# Demo 4: Custom sizing
cat("4. Creating custom sizing demo...\n")
p_custom <- ggplot(basic_data, aes(x = x, y = y, categories = categories)) +
  geom_dice(category_positions = category_positions, dice_size = 0.4) +
  scale_x_continuous(breaks = 1:4, limits = c(0.5, 4.5)) +
  scale_y_continuous(breaks = 1:3, limits = c(0.5, 3.5)) +
  labs(title = "Custom Dice Size", 
       subtitle = "Manual dice_size = 0.4 for precise control",
       x = "X Position", y = "Y Position") +
  theme_minimal() +
  theme(panel.grid.minor = element_blank())

ggsave("custom_sizing_demo.png", p_custom, width = 10, height = 6, dpi = 300)

# Demo 5: Boundary validation
cat("5. Creating boundary validation demo...\n")
p_boundary <- ggplot(basic_data, aes(x = x, y = y, categories = categories)) +
  geom_dice(category_positions = category_positions) +
  scale_x_continuous(breaks = 1:4, limits = c(0.5, 4.5), expand = c(0, 0)) +
  scale_y_continuous(breaks = 1:3, limits = c(0.5, 3.5), expand = c(0, 0)) +
  labs(title = "Boundary Validation", 
       subtitle = "Strict plot boundaries with no expansion",
       x = "X Position", y = "Y Position") +
  theme_minimal() +
  theme(
    panel.grid.minor = element_blank(),
    panel.border = element_rect(color = "red", fill = NA, linewidth = 1)
  )

ggsave("boundary_validation_demo.png", p_boundary, width = 10, height = 6, dpi = 300)

# Demo 6: Dice position reference
cat("6. Creating dice position reference...\n")
ref_data <- data.frame(
  x = rep(1:6, each = 1),
  y = rep(1, times = 6),
  categories = c("A", "B", "C", "D", "E", "F")
)

p_reference <- ggplot(ref_data, aes(x = x, y = y, categories = categories)) +
  geom_dice(category_positions = category_positions, dice_size = 0.8) +
  scale_x_continuous(breaks = 1:6, limits = c(0.5, 6.5)) +
  scale_y_continuous(breaks = 1, limits = c(0.5, 1.5)) +
  labs(title = "Dice Position Reference", 
       subtitle = "Standard dice positions 1-6 for categories A-F",
       x = "Dice Position", y = "") +
  theme_minimal() +
  theme(
    panel.grid.minor = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  )

ggsave("dice_position_reference.png", p_reference, width = 10, height = 3, dpi = 300)

cat("All demonstration plots created successfully!\n")
cat("Generated files in demo_output/:\n")
cat("- basic_dice_demo.png\n")
cat("- dense_grid_demo.png\n")
cat("- sparse_grid_demo.png\n")
cat("- custom_sizing_demo.png\n")
cat("- boundary_validation_demo.png\n")
cat("- dice_position_reference.png\n")