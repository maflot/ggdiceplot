#!/usr/bin/env Rscript
# Test to verify that fill legend appears when using discrete color coding in geom_dice()

library(ggplot2)
library(ggdiceplot)

## ---- SPARSE TEST DATA ----
df_dice <- data.frame(
  miRNA = c(
    # miR-1
    "miR-1", "miR-1",             # compound 1 (two organs only)
    "miR-1",                      # compound 2 (one organ)
    # miR-2
    "miR-2", "miR-2", "miR-2",    # complete row
    # miR-3
    "miR-3",                      # only one organ across all compounds
    "miR-3"
  ),
  
  Compound = c(
    # miR-1
    "Compound_1", "Compound_1",
    "Compound_2",
    # miR-2
    "Compound_1", "Compound_2", "Compound_3",
    # miR-3
    "Compound_3",
    "Compound_1"
  ),
  
  Organ = c(
    # miR-1
    "Lung", "Brain",
    "Liver",
    # miR-2
    "Lung", "Liver", "Brain",
    # miR-3
    "Liver",
    "Brain"
  ),
  
  log2FC = c(
    1.2, -0.8,
    0.3,
    -1.1, 0.6, 2.0,
    -0.5,
    1.5
  )
)

## ---- DIRECTION CATEGORIES ----
df_dice$direction <- ifelse(
  df_dice$log2FC > 0.5, "Up",
  ifelse(df_dice$log2FC < -0.5, "Down", "Unchanged")
)

## ---- FACTOR LEVELS ----
organ_levels_boxes <- c("Lung", "Liver", "Brain")

df_dice$Organ     <- factor(df_dice$Organ,     levels = organ_levels_boxes)
df_dice$direction <- factor(df_dice$direction, levels = c("Down", "Unchanged", "Up"))
df_dice$miRNA     <- factor(df_dice$miRNA)
df_dice$Compound  <- factor(df_dice$Compound,
                            levels = c("Compound_1", "Compound_2", "Compound_3"))

direction_colors <- c(
  Down      = "#2166ac",  # blue
  Unchanged = "grey80",
  Up        = "#b2182b"   # red
)

## ---- PLOT ----
p_dice <- ggplot(df_dice, aes(x = miRNA, y = Compound)) +
  geom_dice(
    aes(
      dots  = Organ,      # Position in dice = Organ
      fill  = direction,  # Fill = Up / Down / Unchanged
      width = 0.8,
      height = 0.8
    ),
    show.legend = TRUE,
    ndots       = length(levels(df_dice$Organ)),      # = 3 organs
    x_length    = length(levels(df_dice$miRNA)),
    y_length    = length(levels(df_dice$Compound))
  ) +
  scale_fill_manual(
    values = direction_colors,
    drop   = FALSE,
    name   = "Regulation"
  ) +
  theme_dice(x_length = length(levels(df_dice$miRNA)),
             y_length = length(levels(df_dice$Compound))) +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 0.5),
    axis.text.y = element_text(hjust = 1),
    panel.grid  = element_blank()   # remove background grid
  ) +
  labs(
    title = "DicePlot: log2FC direction per miRNA, compound and organ",
    x = "miRNA",
    y = "Compound"
  )

# Save plot
ggsave("test_fill_legend_after_fix.png", p_dice, width = 10, height = 8, dpi = 150)

print("Plot saved to test_fill_legend_after_fix.png")
print("Expected: Both 'Organ' legend (showing dice positions) AND 'Regulation' legend (showing fill colors)")
