#!/usr/bin/env Rscript
# Spatial dice plot example using new ggdiceplot package
# Recreated from geom_dice_sf_test2.R legacy example

# Required packages:
# install.packages(c("sf", "ggplot2", "dplyr", "rnaturalearth", "ggdiceplot"))

library(sf)
library(ggplot2)
library(dplyr)
library(rnaturalearth)
library(tidyr)
library(grid)
library(scales)
library(legendry)

# Load ggdiceplot functions directly from source
source("../R/utils.R")
source("../R/geom-dice-ggprotto.R") 
source("../R/geom-dice.R")

# Get Germany states and focus on Saarland
germany_states <- ne_states(country = "Germany", returnclass = "sf")
saarland <- germany_states[germany_states$name == "Saarland", ]

# Create city data with distances to neighboring regions
cities <- data.frame(
  name = c("Saarbrücken", "Saarlouis", "Homburg", "Britten", "Merzig", "Lebach", "Ottweiler"),
  lon = c(6.996, 6.751, 7.339, 6.784, 6.639, 6.913, 7.167),
  lat = c(49.234, 49.315, 49.320, 49.481, 49.442, 49.407, 49.400),
  France = c(14, 12, 38, 27, 18, 27, 36),
  Swiss = c(190, 204, 195, 221, 220, 210, 206),
  Luxembourg = c(51, 31, 67, 23, 17, 35, 52),
  Rheinlandpfalz = c(29, 27, 6, 16, 20, 12, 16)
)

# Transform to long format for geom_dice
cities_long <- cities %>%
  pivot_longer(
    cols = c(France, Swiss, Luxembourg, Rheinlandpfalz),
    names_to = "region",
    values_to = "distance"
  ) %>%
  mutate(
    log_distance = log(distance),
    region = factor(region, levels = c("France", "Swiss", "Luxembourg", "Rheinlandpfalz"))
  )

# Calculate scale limits
lo <- floor(min(cities_long$log_distance, na.rm = TRUE))
up <- ceiling(max(cities_long$log_distance, na.rm = TRUE))
mid <- (lo + up) / 2

# Create the spatial dice plot
p <- ggplot(cities_long, aes(x = lon, y = lat)) +
  # Add Saarland background (convert to regular data frame for ggplot)
  geom_sf(data = saarland, fill = "lightblue", color = "black", alpha = 0.3) +
  # Add dice markers
  geom_dice(
    aes(
      dots = region,
      fill = log_distance,
      size = distance / 50,  # Scale size for visibility
      width = 0.08,
      height = 0.05
    ),
    na.rm = TRUE,
    show.legend = TRUE,
    ndots = 4,  # 4 regions
    x_length = length(unique(cities_long$lon)),
    y_length = length(unique(cities_long$lat))
  ) +
  # Add city labels
  geom_text(
    data = cities,
    aes(x = lon, y = lat, label = name),
    nudge_y = 0.03,
    size = 3,
    inherit.aes = FALSE
  ) +
  scale_fill_viridis_c(
    option = "D",
    name = "Log Distance",
    labels = function(x) paste0("log(", round(exp(x)), ")"),
    breaks = c(lo, mid, up)
  ) +
  scale_size_continuous(
    name = "Distance (km)",
    range = c(1, 4),
    breaks = c(10, 50, 100, 200),
    labels = c("10", "50", "100", "200")
  ) +
  coord_sf(
    xlim = c(6.4, 7.4),  # Limit to Saarland area
    ylim = c(49.1, 49.6),
    expand = FALSE
  ) +
  theme_minimal() +
  theme(
    legend.key = element_blank(),
    legend.key.size = unit(0.6, "cm"),
    panel.grid = element_line(color = "grey90", size = 0.2)
  ) +
  labs(
    title = "Saarland Cities: Distance to Neighboring Regions",
    subtitle = "Each dice shows log-scaled distances to France, Switzerland, Luxembourg, and Rheinland-Pfalz",
    x = "Longitude",
    y = "Latitude"
  )

# Save the plot
ggsave("spatial_dice_example.png", p, width = 12, height = 8, dpi = 300)
ggsave("spatial_dice_example.pdf", p, width = 12, height = 8)

print(p)

# Create summary table
summary_distances <- cities_long %>%
  group_by(region) %>%
  summarise(
    min_dist = min(distance),
    max_dist = max(distance),
    avg_dist = round(mean(distance), 1),
    .groups = "drop"
  )

print("Distance summary by region:")
print(summary_distances)

print("Spatial dice plot created successfully!")
print("Generated files:")
print("- spatial_dice_example.png")
print("- spatial_dice_example.pdf")