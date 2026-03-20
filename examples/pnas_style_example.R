#!/usr/bin/env Rscript
# PNAS-style dice plot example using new ggdiceplot package
# Recreated from pnas_diceplot_example.R legacy example

# Required packages:
# install.packages(c("dplyr", "ggplot2", "tidyr", "ggdiceplot"))

library(dplyr)
library(ggplot2)
library(tidyr)
library(grid)
library(scales)
library(legendry)

# Load ggdiceplot functions directly from source
source("../R/utils.R")
source("../R/geom-dice-ggprotto.R")
source("../R/geom-dice.R")

# Create synthetic gene expression data similar to PNAS format
# This simulates the structure from the PNAS supplemental data

set.seed(123)  # For reproducibility

# Define cell types and demographic combinations  
cell_types <- c("NK", "TC", "BC", "DC", "MC")
cell_type_names <- c(
  "NK" = "Natural Killer",
  "TC" = "T Cell", 
  "BC" = "B Cell",
  "DC" = "Dendritic Cell",
  "MC" = "Monocyte"
)

demographics <- c("Old_Male", "Old_Female", "Young_Male", "Young_Female")
demo_names <- c(
  "Old_Male" = "Old Male",
  "Old_Female" = "Old Female", 
  "Young_Male" = "Young Male",
  "Young_Female" = "Young Female"
)

# Create top 25 most studied genes (common immunology genes)
top_genes <- c(
  "IL6", "TNF", "IFNG", "IL1B", "IL10", "CCL2", "CXCL10", "IL2", "IL4", "IL17A",
  "CD8A", "CD4", "FOXP3", "GZMB", "PRF1", "CD68", "CD163", "IRF4", "STAT1", "STAT3",
  "NFKB1", "JUN", "FOS", "CD19", "MS4A1"
)

# Create synthetic data: not all genes appear in all combinations
gene_data <- expand_grid(
  gene = top_genes,
  cell_type_code = cell_types,
  demo_code = demographics
) %>%
  # Randomly exclude some combinations to make it realistic
  sample_frac(0.75) %>%  # Keep 75% of all possible combinations
  mutate(
    cell_type = cell_type_names[cell_type_code],
    demographic = demo_names[demo_code],
    # Add some biological realism
    expression_level = case_when(
      gene %in% c("IL6", "TNF", "IL1B") ~ runif(n(), 0.8, 2.0),  # High inflammation markers
      gene %in% c("CD8A", "CD4", "CD19") ~ runif(n(), 0.5, 1.5), # Cell markers
      TRUE ~ runif(n(), 0.1, 1.0)  # Other genes
    ),
    significance = runif(n(), 0.001, 0.1)  # p-values
  ) %>%
  # Ensure factors are properly ordered
  mutate(
    gene = factor(gene, levels = top_genes),
    cell_type = factor(cell_type, levels = unname(cell_type_names)),
    demographic = factor(demographic, levels = c("Old Male", "Old Female", "Young Male", "Young Female"))
  )

# Calculate scale limits
lo <- floor(min(gene_data$expression_level, na.rm = TRUE))
up <- ceiling(max(gene_data$expression_level, na.rm = TRUE))
mid <- (lo + up) / 2

minsize <- floor(min(-log10(gene_data$significance), na.rm = TRUE))
maxsize <- ceiling(max(-log10(gene_data$significance), na.rm = TRUE))
midsize <- ceiling(quantile(-log10(gene_data$significance), c(0.5), na.rm = TRUE))

# Create the main PNAS-style dice plot
p_main <- ggplot(gene_data, aes(x = gene, y = cell_type)) +
  geom_dice(
    aes(
      dots = demographic,
      fill = expression_level,
      size = -log10(significance),
      width = 0.8,
      height = 0.8
    ),
    na.rm = TRUE,
    show.legend = TRUE,
    ndots = 4,  # 4 demographic combinations
    x_length = length(top_genes),
    y_length = length(cell_types)
  ) +
  scale_fill_gradient2(
    low = "#2166AC", 
    high = "#762A83", 
    mid = "white",
    na.value = "grey90",
    limit = c(lo, up),
    midpoint = mid,
    name = "Expression\nLevel"
  ) +
  scale_size_continuous(
    limits = c(minsize, maxsize),
    breaks = c(minsize, midsize, maxsize),
    labels = c(10^minsize, 10^-midsize, 10^-maxsize),
    name = "p-value"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 11),
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 11),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.key = element_blank(),
    legend.key.size = unit(0.7, "cm"),
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11)
  ) +
  labs(
    x = "Gene",
    y = "Cell Type", 
    title = "Gene Expression across Cell Types and Demographics",
    subtitle = "Top 25 immune-related genes showing expression patterns across age and sex groups"
  )

# Save the main plot
ggsave("pnas_style_example.png", p_main, width = 14, height = 8, dpi = 300)
ggsave("pnas_style_example.pdf", p_main, width = 14, height = 8)

print(p_main)

# Create a focused subset plot for top inflammatory genes
inflammatory_genes <- c("IL6", "TNF", "IFNG", "IL1B", "IL10", "CCL2", "CXCL10")

p_inflammatory <- gene_data %>%
  filter(gene %in% inflammatory_genes) %>%
  ggplot(aes(x = gene, y = cell_type)) +
  geom_dice(
    aes(
      dots = demographic,
      fill = expression_level,
      size = -log10(significance),
      width = 0.9,
      height = 0.9
    ),
    na.rm = TRUE,
    show.legend = TRUE,
    ndots = 4,
    x_length = length(inflammatory_genes),
    y_length = length(cell_types)
  ) +
  scale_fill_gradient2(
    low = "#2166AC",
    high = "#762A83", 
    mid = "white",
    na.value = "grey90",
    limit = c(lo, up),
    midpoint = mid,
    name = "Expression\nLevel"
  ) +
  scale_size_continuous(
    limits = c(minsize, maxsize),
    breaks = c(minsize, midsize, maxsize),
    labels = c(10^minsize, 10^-midsize, 10^-maxsize),
    name = "p-value"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.key = element_blank(),
    legend.key.size = unit(0.8, "cm"),
    plot.title = element_text(size = 14, face = "bold")
  ) +
  labs(
    x = "Inflammatory Gene",
    y = "Cell Type",
    title = "Inflammatory Gene Expression Patterns"
  )

ggsave("pnas_inflammatory_subset.png", p_inflammatory, width = 10, height = 6, dpi = 300)

print(p_inflammatory)

# Create summary statistics
print("Data Summary:")
print(paste("Total gene-cell-demographic combinations:", nrow(gene_data)))
print(paste("Unique genes:", length(unique(gene_data$gene))))
print(paste("Unique cell types:", length(unique(gene_data$cell_type))))
print(paste("Unique demographics:", length(unique(gene_data$demographic))))

# Gene frequency summary
gene_freq <- gene_data %>%
  count(gene, sort = TRUE) %>%
  head(10)

print("Top 10 most frequent genes:")
print(gene_freq)

# Cell type summary
cell_summary <- gene_data %>%
  group_by(cell_type) %>%
  summarise(
    gene_count = n(),
    avg_expression = round(mean(expression_level, na.rm = TRUE), 2),
    .groups = "drop"
  )

print("Summary by cell type:")
print(cell_summary)

print("PNAS-style dice plots created successfully!")
print("Generated files:")
print("- pnas_style_example.png")
print("- pnas_style_example.pdf")
print("- pnas_inflammatory_subset.png")

# ---------------------------------------------------------------------------
# pip_scale demonstration: fill-only version (no size mapping)
# ---------------------------------------------------------------------------
# When size is not mapped to a variable, geom_dice auto-scales each pip to
# fill pip_scale * (available space per pip) at render time.
# Use pip_scale = NULL to revert to the fixed size = 3 mm legacy behaviour.

# Aggregate to one row per gene/cell_type (collapse demographics)
gene_data_agg <- gene_data %>%
  group_by(gene, cell_type) %>%
  summarise(
    expression_level = mean(expression_level, na.rm = TRUE),
    demographic      = first(demographic),
    .groups = "drop"
  ) %>%
  mutate(
    gene      = factor(gene, levels = top_genes),
    cell_type = factor(cell_type, levels = unname(cell_type_names))
  )

# -- Auto-scaled (default pip_scale = 0.75) -----------------------------------
p_auto <- ggplot(gene_data_agg, aes(x = gene, y = cell_type)) +
  geom_dice(
    aes(dots = cell_type, fill = expression_level, width = 0.85, height = 0.85),
    na.rm       = TRUE,
    show.legend = TRUE,
    ndots       = length(unique(gene_data_agg$cell_type)),
    x_length    = length(top_genes),
    y_length    = length(cell_types)
    # pip_scale defaults to 0.75
  ) +
  scale_dots_discrete(guide = "none") +
  scale_fill_gradient2(
    low = "#2166AC", high = "#762A83", mid = "white",
    na.value = "grey90", limit = c(lo, up), midpoint = mid,
    name = "Expression\nLevel"
  ) +
  theme_minimal() +
  theme(
    axis.text.x   = element_text(angle = 45, hjust = 1, size = 9),
    axis.text.y   = element_text(size = 10),
    legend.text   = element_text(size = 9),
    legend.title  = element_text(size = 10),
    panel.grid    = element_blank()
  ) +
  labs(
    x        = "Gene",
    y        = "Cell Type",
    title    = "pip_scale = 0.75  (auto-scaled, default)",
    subtitle = "No size mapping — pip diameter adapts to figure size"
  )

# -- Fixed legacy size (pip_scale = NULL) -------------------------------------
p_fixed <- p_auto +
  geom_dice(
    aes(dots = cell_type, fill = expression_level, width = 0.85, height = 0.85),
    na.rm       = TRUE,
    show.legend = FALSE,
    ndots       = length(unique(gene_data_agg$cell_type)),
    x_length    = length(top_genes),
    y_length    = length(cell_types),
    pip_scale    = NULL   # disables auto-scaling; falls back to size = 3 mm
  ) +
  labs(
    title    = "pip_scale = NULL  (fixed size = 3 mm)",
    subtitle = "Legacy behaviour — may leave excess whitespace at small figure sizes"
  )

# Actually rebuild separately so they render independently
p_fixed <- ggplot(gene_data_agg, aes(x = gene, y = cell_type)) +
  geom_dice(
    aes(dots = cell_type, fill = expression_level, width = 0.85, height = 0.85),
    na.rm       = TRUE,
    show.legend = TRUE,
    ndots       = length(unique(gene_data_agg$cell_type)),
    x_length    = length(top_genes),
    y_length    = length(cell_types),
    pip_scale    = NULL
  ) +
  scale_dots_discrete(guide = "none") +
  scale_fill_gradient2(
    low = "#2166AC", high = "#762A83", mid = "white",
    na.value = "grey90", limit = c(lo, up), midpoint = mid,
    name = "Expression\nLevel"
  ) +
  theme_minimal() +
  theme(
    axis.text.x   = element_text(angle = 45, hjust = 1, size = 9),
    axis.text.y   = element_text(size = 10),
    legend.text   = element_text(size = 9),
    legend.title  = element_text(size = 10),
    panel.grid    = element_blank()
  ) +
  labs(
    x        = "Gene",
    y        = "Cell Type",
    title    = "pip_scale = NULL  (fixed size = 3 mm)",
    subtitle = "Legacy behaviour — may leave excess whitespace at small figure sizes"
  )

ggsave("pnas_pip_scale_auto.png",  p_auto,  width = 14, height = 5, dpi = 300)
ggsave("pnas_pip_scale_fixed.png", p_fixed, width = 14, height = 5, dpi = 300)

print("pip_scale comparison plots created:")
print("- pnas_pip_scale_auto.png   (pip_scale = 0.75, auto-scaled)")
print("- pnas_pip_scale_fixed.png  (pip_scale = NULL, fixed size = 3 mm)")