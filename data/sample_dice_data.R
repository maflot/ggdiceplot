# Create sample data for examples
set.seed(123)
sample_dice_data <- expand.grid(x = 1:4, y = 1:3)
sample_dice_data$z <- sample(1:6, nrow(sample_dice_data), replace = TRUE)
sample_dice_data$category <- sample(c("Type A", "Type B", "Type C"), nrow(sample_dice_data), replace = TRUE)
sample_dice_data$value <- sample(1:100, nrow(sample_dice_data), replace = TRUE)

# Save the data
usethis::use_data(sample_dice_data, overwrite = TRUE)