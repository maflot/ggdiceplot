library(testthat)

test_that("create_dice_positions returns correct structure", {
  for (n in 1:6) {
    positions <- create_dice_positions(n)
    
    expect_s3_class(positions, "data.frame")
    expect_equal(nrow(positions), n)
    expect_equal(ncol(positions), 2)
    expect_true(all(c("x_offset", "y_offset") %in% names(positions)))
    expect_true(all(is.numeric(positions$x_offset)))
    expect_true(all(is.numeric(positions$y_offset)))
  }
})

test_that("create_dice_positions handles invalid input", {
  expect_error(create_dice_positions(0), "n_dots must be an integer between 1 and 6")
  expect_error(create_dice_positions(7), "n_dots must be an integer between 1 and 6")
  expect_error(create_dice_positions(-1), "n_dots must be an integer between 1 and 6")
})

test_that("create_dice_positions creates expected patterns", {
  # Test dice with 1 dot (center)
  pos1 <- create_dice_positions(1)
  expect_equal(pos1$x_offset, 0)
  expect_equal(pos1$y_offset, 0)
  
  # Test dice with 2 dots (diagonal)
  pos2 <- create_dice_positions(2)
  expect_equal(nrow(pos2), 2)
  expect_equal(pos2$x_offset, c(-0.2, 0.2))
  expect_equal(pos2$y_offset, c(-0.2, 0.2))
  
  # Test dice with 4 dots (corners)
  pos4 <- create_dice_positions(4)
  expect_equal(nrow(pos4), 4)
  expect_equal(pos4$x_offset, c(-0.2, 0.2, -0.2, 0.2))
  expect_equal(pos4$y_offset, c(-0.2, -0.2, 0.2, 0.2))
  
  # Test dice with 6 dots (two columns)
  pos6 <- create_dice_positions(6)
  expect_equal(nrow(pos6), 6)
  expect_equal(pos6$x_offset, c(-0.2, 0.2, -0.2, 0.2, -0.2, 0.2))
  expect_equal(pos6$y_offset, c(-0.2, -0.2, 0, 0, 0.2, 0.2))
})

test_that("validate_dice_data works correctly", {
  data <- data.frame(x = 1:3, y = 1:3, z = 1:3)
  mapping <- aes(x = x, y = y, z = z)
  
  expect_true(validate_dice_data(data, mapping))
})

test_that("validate_dice_data catches missing aesthetics", {
  data <- data.frame(x = 1:3, y = 1:3)
  mapping <- aes(x = x, y = y)
  
  expect_error(validate_dice_data(data, mapping), "Missing required aesthetics")
})

test_that("validate_dice_data warns about invalid z values", {
  data <- data.frame(x = 1:3, y = 1:3, z = c(1, 7, -1))
  mapping <- aes(x = x, y = y, z = z)
  
  expect_warning(validate_dice_data(data, mapping), "Some z values are outside the valid range")
})