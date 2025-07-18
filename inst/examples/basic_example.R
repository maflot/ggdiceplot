# Basic ggdiceplot example
library(ggdiceplot)
library(ggplot2)
library(dplyr)

# Create sample data
set.seed(123)
data <- expand.grid(x = 1:4, y = 1:3) %>%
  mutate(
    z = sample(1:6, n(), replace = TRUE),
    category = sample(c("Type A", "Type B", "Type C"), n(), replace = TRUE)
  )

# Basic dice plot
p1 <- ggplot(data, aes(x = x, y = y, z = z)) +
  geom_dice() +
  scale_x_continuous(breaks = 1:4) +
  scale_y_continuous(breaks = 1:3) +
  labs(
    title = "Basic Dice Plot",
    subtitle = "Each dice shows 1-6 dots based on the z variable",
    x = "X Position",
    y = "Y Position"
  ) +
  theme_minimal()

print(p1)

# Colored dice plot
p2 <- ggplot(data, aes(x = x, y = y, z = z, color = category)) +
  geom_dice(dice_size = 1.2) +
  scale_color_manual(values = c("Type A" = "#E74C3C", "Type B" = "#3498DB", "Type C" = "#2ECC71")) +
  scale_x_continuous(breaks = 1:4) +
  scale_y_continuous(breaks = 1:3) +
  labs(
    title = "Colored Dice Plot",
    subtitle = "Dice dots colored by category",
    x = "X Position",
    y = "Y Position",
    color = "Category"
  ) +
  theme_minimal()

print(p2)

# Custom styled dice plot
p3 <- ggplot(data, aes(x = x, y = y, z = z, color = category)) +
  geom_dice(
    dice_size = 1.5,
    dice_color = "lightgray",
    dice_alpha = 0.9,
    dot_size = 0.4,
    dot_stroke = 0.8
  ) +
  scale_color_manual(values = c("#E74C3C", "#3498DB", "#2ECC71")) +
  scale_x_continuous(breaks = 1:4) +
  scale_y_continuous(breaks = 1:3) +
  labs(
    title = "Custom Styled Dice Plot",
    subtitle = "Custom dice background, dot size, and colors",
    x = "X Position",
    y = "Y Position",
    color = "Category"
  ) +
  theme_minimal()

print(p3)

# Show dice patterns
pattern_data <- data.frame(
  x = 1:6,
  y = rep(1, 6),
  z = 1:6
)

p4 <- ggplot(pattern_data, aes(x = x, y = y, z = z)) +
  geom_dice(dice_size = 2) +
  geom_text(aes(label = paste("Dice", z)), y = 0.5, size = 3) +
  scale_x_continuous(breaks = 1:6, limits = c(0.5, 6.5)) +
  scale_y_continuous(limits = c(0, 2)) +
  labs(
    title = "Traditional Dice Patterns",
    subtitle = "Standard arrangements for 1-6 dots",
    x = "Dice Value",
    y = ""
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank()
  )

print(p4)