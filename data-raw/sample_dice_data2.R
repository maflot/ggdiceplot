set.seed(42)  # For reproducibility

# Define parameters
taxa <- c(
  "Campylobacter_showae",
  "Porphyromonas_gingivalis",
  "Rothia_mucilaginosa",
  "Fusobacterium_nucleatum",
  "Streptococcus_mutans",
  "Prevotella_intermedia"
)
diseases <- c("Caries", "Periodontitis", "Healthy", "Gingivitis")
specimens <- c("Saliva", "Plaque")
replicates <- 1:2

# Create full factorial design with replicates
toy_data <- expand.grid(
  taxon = taxa,
  disease = diseases,
  specimen = specimens,
  replicate = replicates,
  stringsAsFactors = FALSE
)

# Simulate plausible values
toy_data$lfc <- round(stats::rnorm(nrow(toy_data), mean = 0, sd = 2), 2)
toy_data$q   <- signif(stats::runif(nrow(toy_data), min = 1e-6, max = 0.5), 2)

# Introduce ~10% missing values consistently
n_missing <- floor(0.1 * nrow(toy_data))
missing_idx <- sample(seq_len(nrow(toy_data)), n_missing)

toy_data$lfc[missing_idx] <- NA
toy_data$q[missing_idx]   <- NA

sample_dice_data2 <- toy_data[toy_data$replicate==1, ]

# Save the data
usethis::use_data(sample_dice_data2, overwrite = TRUE)