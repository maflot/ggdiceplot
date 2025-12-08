## Create the sample dice dataset used in examples
## Run this file with source("data-raw/sample_dice_miRNA.R")

set.seed(123)

# Define parameter sets
miRNAs    <- paste0("miR-", 1:5)
organs    <- c("Lung","Liver","Brain","Kidney")
compounds <- c("Control","Compound_1","Compound_2","Compound_3","Compound_4")

# Full factorial design
sample_dice_miRNA <- expand.grid(
  miRNA    = miRNAs,
  Compound = compounds,
  Organ    = organs,
  stringsAsFactors = FALSE
)

# Compound-dependent mean effects (safe named vector)
compound_means <- c(
  Control     = -1,
  Compound_1  = -0.5,
  Compound_2  = 0,
  Compound_3  = 0.5,
  Compound_4  = 1
)

# Compute log2FC cleanly
sample_dice_miRNA$log2FC <- stats::rnorm(
  nrow(sample_dice_miRNA),
  mean = compound_means[sample_dice_miRNA$Compound],  # no NAs
  sd   = 0.8
)

# Direction categories
sample_dice_miRNA$direction <- ifelse(
  sample_dice_miRNA$log2FC >  0.5, "Up",
  ifelse(sample_dice_miRNA$log2FC < -0.5, "Down", "Unchanged")
)

# Factor levels
sample_dice_miRNA$Organ     <- factor(sample_dice_miRNA$Organ,     levels = organs)
sample_dice_miRNA$Compound  <- factor(sample_dice_miRNA$Compound,  levels = compounds)
sample_dice_miRNA$miRNA     <- factor(sample_dice_miRNA$miRNA)
sample_dice_miRNA$direction <- factor(sample_dice_miRNA$direction, levels = c("Down", "Unchanged", "Up"))

# Optional: drop random rows to demonstrate sparsity
drop_idx <- sample(seq_len(nrow(sample_dice_miRNA)), size = 10)
sample_dice_miRNA <- sample_dice_miRNA[-drop_idx, ]

# Save dataset
usethis::use_data(sample_dice_miRNA, overwrite = TRUE)