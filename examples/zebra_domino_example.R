#!/usr/bin/env Rscript
# ZEBRA domino plot example using new ggdiceplot package

# Required packages:
# install.packages(c("dplyr", "ggplot2", "legendry", "scales"))

library(dplyr)
library(ggplot2)
library(legendry)  # Required for guide_legend_base
library(scales)
library(grid)

# Load ggdiceplot functions directly from source
source("R/utils.R")
source("R/geom-dice-ggprotto.R")
source("R/geom-dice.R")

# Load ZEBRA dataset
zebra.df <- read.csv(file = "legacy examples/data/ZEBRA_sex_degs_set.csv")

# Select genes of interest
genes <- c("SPP1", "APOE", "SERPINA1", "PINK1", "ANGPT1", "ANGPT2", "APP", "CLU", "ABCA7")

# Filter and prepare data - keep one row per gene/cell_type/contrast combination
library(tidyr)  # Need this for complete()

zebra.df <- zebra.df %>% 
  filter(gene %in% genes) %>%
  filter(contrast %in% c("MS-CT", "AD-CT", "ASD-CT", "FTD-CT", "HD-CT")) %>%
  mutate(
    cell_type = factor(cell_type, levels = sort(unique(cell_type))),
    contrast = factor(contrast, levels = c("MS-CT", "AD-CT", "ASD-CT", "FTD-CT", "HD-CT")),
    gene = factor(gene, levels = genes)
  ) %>%
  filter(PValue < 0.05) %>%
  # Aggregate by gene/cell_type/contrast to handle duplicates (e.g., different sex)
  group_by(gene, cell_type, contrast) %>%
  summarise(
    logFC = mean(logFC, na.rm = TRUE),
    FDR = min(FDR, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  # Complete the data so every gene/cell_type has all contrasts (with NA for missing)
  complete(gene, cell_type, contrast, fill = list(logFC = NA, FDR = NA))

# Debug: Check the data structure
print("Data dimensions after complete:")
print(dim(zebra.df))
print("Number of unique contrasts:")
print(length(unique(zebra.df$contrast)))
print("Sample of completed data:")
print(head(zebra.df, 20))

# Calculate limits for color scale
lo <- floor(min(zebra.df$logFC, na.rm = TRUE))
up <- ceiling(max(zebra.df$logFC, na.rm = TRUE))
mid <- (lo + up) / 2

# Calculate size scale limits for -log10(FDR)
minsize <- floor(min(-log10(zebra.df$FDR), na.rm = TRUE))
maxsize <- ceiling(max(-log10(zebra.df$FDR), na.rm = TRUE))
midsize <- ceiling(quantile(-log10(zebra.df$FDR), c(0.5), na.rm = TRUE))

# Create the domino plot using geom_dice
# Note: geom_dice returns a list with the layer and theme
dice_plot <- geom_dice(
  mapping = aes(
    x = gene, 
    y = cell_type,
    dots = contrast,
    fill = logFC,
    size = -log10(FDR),
    width = 0.8,
    height = 0.8
  ),
  data = zebra.df,
  na.rm = TRUE,
  show.legend = TRUE,
  ndots = 5,  # We have 5 contrasts: MS-CT, AD-CT, ASD-CT, FTD-CT, HD-CT
  x_length = length(genes),  # Use the number of genes
  y_length = length(unique(zebra.df$cell_type))
)

p <- ggplot(zebra.df, aes(x = gene, y = cell_type)) +
  dice_plot +
  scale_fill_gradient2(
    low = "#40004B",
    high = "#00441B",
    mid = "white",
    na.value = "white",
    limit = c(lo, up),
    midpoint = mid,
    name = "Log2FC"
  ) +
  scale_size_continuous(
    limits = c(minsize, maxsize),
    breaks = c(minsize, midsize, maxsize),
    labels = round(10^(-c(minsize, midsize, maxsize)), 3),
    name = "FDR"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    # Remove legend key background and border
    legend.key = element_blank(),
    legend.key.size = unit(0.8, "cm")
  ) +
  labs(
    x = "Gene",
    y = "Cell Type",
    title = "ZEBRA Sex DEGs Domino Plot"
  )

# Save the plot
ggsave("ZEBRA_domino_example.pdf", p, width = 10, height = 8)
ggsave("ZEBRA_domino_example.png", p, width = 10, height = 8, dpi = 300)

print(p)

# Create version with custom legend labels
dice_plot2 <- geom_dice(
  mapping = aes(
    x = gene,
    y = cell_type,
    dots = contrast,
    fill = logFC,
    size = -log10(FDR),
    width = 0.7,
    height = 0.7
  ),
  data = zebra.df,
  na.rm = TRUE,
  show.legend = TRUE,
  ndots = 5,  # We have 5 contrasts
  x_length = length(genes),
  y_length = length(unique(zebra.df$cell_type))
)

p2 <- ggplot(zebra.df, aes(x = gene, y = cell_type)) +
  dice_plot2 +
  scale_fill_gradient2(
    low = "#40004B",
    high = "#00441B",
    mid = "white",
    na.value = "white",
    limit = c(lo, up),
    midpoint = mid,
    name = "Other color name"
  ) +
  scale_size_continuous(
    limits = c(minsize, maxsize),
    breaks = c(minsize, midsize, maxsize),
    labels = round(10^(-c(minsize, midsize, maxsize)), 3),
    name = "Other scale name"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    # Remove legend key background and border
    legend.key = element_blank(),
    legend.key.size = unit(0.8, "cm")
  ) +
  labs(
    x = "Gene",
    y = "Cell Type",
    title = "ZEBRA Sex DEGs with Custom Legend Labels"
  )

ggsave("ZEBRA_domino_example_custom_labels.png", p2, width = 10, height = 8, dpi = 300)

print("ZEBRA domino plots created successfully!")
print("Generated files:")
print("- ZEBRA_domino_example.pdf")
print("- ZEBRA_domino_example.png")
print("- ZEBRA_domino_example_custom_labels.png")