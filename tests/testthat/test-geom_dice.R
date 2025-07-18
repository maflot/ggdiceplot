library(testthat)
library(ggplot2)
library(dplyr)

test_that("geom_dice creates a ggplot layer", {
  data <- data.frame(x = 1:3, y = 1:3, z = 1:3)
  
  p <- ggplot(data, aes(x = x, y = y, z = z)) +
    geom_dice()
  
  expect_s3_class(p, "ggplot")
  expect_equal(length(p$layers), 1)
  expect_s3_class(p$layers[[1]]$geom, "GeomDice")
})

test_that("geom_dice handles invalid z values", {
  data <- data.frame(x = 1:3, y = 1:3, z = c(1, 7, -1))
  
  expect_warning(
    p <- ggplot(data, aes(x = x, y = y, z = z)) + geom_dice(),
    "Some z values are outside the valid range"
  )
})

test_that("geom_dice works with color aesthetics", {
  data <- data.frame(
    x = 1:3, 
    y = 1:3, 
    z = 1:3,
    color = c("red", "blue", "green")
  )
  
  p <- ggplot(data, aes(x = x, y = y, z = z, color = color)) +
    geom_dice()
  
  expect_s3_class(p, "ggplot")
  expect_equal(length(p$layers), 1)
})

test_that("geom_dice parameters work correctly", {
  data <- data.frame(x = 1:3, y = 1:3, z = 1:3)
  
  p <- ggplot(data, aes(x = x, y = y, z = z)) +
    geom_dice(
      dice_size = 2,
      dot_size = 0.5,
      dice_color = "lightblue",
      dice_alpha = 0.5
    )
  
  expect_s3_class(p, "ggplot")
  expect_equal(p$layers[[1]]$aes_params$dice_size, 2)
  expect_equal(p$layers[[1]]$aes_params$dot_size, 0.5)
  expect_equal(p$layers[[1]]$aes_params$dice_color, "lightblue")
  expect_equal(p$layers[[1]]$aes_params$dice_alpha, 0.5)
})

test_that("geom_dice fails with missing required aesthetics", {
  data <- data.frame(x = 1:3, y = 1:3)
  
  expect_error(
    ggplot(data, aes(x = x, y = y)) + geom_dice(),
    "Missing required aesthetics"
  )
})