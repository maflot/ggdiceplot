# Create sample data for examples
set.seed(123)
sample_dice_data <- expand.grid(x = 1:4, y = 1:3) %>%
  dplyr::mutate(
    z = sample(1:6, dplyr::n(), replace = TRUE),
    category = sample(c("Type A", "Type B", "Type C"), dplyr::n(), replace = TRUE),
    value = sample(1:100, dplyr::n(), replace = TRUE)
  )

# Save the data
usethis::use_data(sample_dice_data, overwrite = TRUE)