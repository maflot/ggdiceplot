# Create sample data for examples
set.seed(42)  # For reproducibility

taxa <- c("Campylobacter_showae", "Porphyromonas_gingivalis", "Rothia_mucilaginosa",
          "Fusobacterium_nucleatum","Streptococcus_mutans","Prevotella_intermedia")
diseases <- c("Caries", "Periodontitis", "Healthy", "Gingivitis")
specimens <- c("Saliva", "Plaque")

# Create all combinations
combinations <- expand.grid(
  taxon = taxa,
  disease = diseases,
  specimen = specimens,
  stringsAsFactors = FALSE
)

# Generate plausible LFCs and q-values
combinations$lfc <- round(stats::rnorm(nrow(combinations), mean = 0, sd = 2), 2)
combinations$q <- signif(stats::runif(nrow(combinations), min = 1e-6, max = 0.5), 2)

# Final extended toy dataset
sample_dice_data1 <- combinations

# Save the data
usethis::use_data(sample_dice_data1, overwrite = TRUE)