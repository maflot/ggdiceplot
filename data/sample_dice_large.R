set.seed(42)  # For reproducibility

# Define parameters
taxa <- paste0("Taxon_", seq_len(60))
diseases <- c("Caries", "Periodontitis", "Healthy", "Gingivitis")
specimens <- c("Saliva", "Plaque")
replicates <- 1:2

# Create full factorial design with replicates
extended_data <- expand.grid(
  taxon = taxa,
  disease = diseases,
  specimen = specimens,
  replicate = replicates,
  stringsAsFactors = FALSE
)

# Simulate plausible values
extended_data$lfc <- round(stats::rnorm(nrow(extended_data), mean = 0, sd = 2), 2)
extended_data$q   <- signif(stats::runif(nrow(extended_data), min = 1e-6, max = 0.5), 2)

# Introduce ~50% missing values consistently (both lfc and q)
n_missing <- floor(0.5 * nrow(extended_data))
missing_idx <- sample(seq_len(nrow(extended_data)), n_missing)

extended_data$lfc[missing_idx] <- NA
extended_data$q[missing_idx]   <- NA

# Optionally filter for one replicate if desired (e.g. replicate == 1)
sample_dice_large <- extended_data[extended_data$replicate == 1, ]

# Optionally save the data
usethis::use_data(sample_dice_large, overwrite = TRUE)
