# Tests for utility functions: make_offsets(), create_dice_positions(),
# scale_dots_discrete(), theme_dice().

test_that("make_offsets() returns a data frame with correct structure for all n", {
  for (n in 1:6) {
    offsets <- make_offsets(n)
    expect_s3_class(offsets, "data.frame")
    expect_equal(nrow(offsets), n)
    expect_named(offsets, c("key", "x", "y"))
    expect_equal(offsets$key, seq_len(n))
  }
})

test_that("make_offsets() positions are within tile bounds", {
  width  <- 0.5
  height <- 0.5
  for (n in 1:6) {
    offsets <- make_offsets(n, width = width, height = height)
    expect_true(
      all(offsets$x >= -width / 2 & offsets$x <= width / 2),
      label = paste("make_offsets(", n, ") x within bounds")
    )
    expect_true(
      all(offsets$y >= -height / 2 & offsets$y <= height / 2),
      label = paste("make_offsets(", n, ") y within bounds")
    )
  }
})

test_that("make_offsets() respects custom width and height", {
  offsets_small <- make_offsets(4, width = 0.4, height = 0.4)
  offsets_large <- make_offsets(4, width = 1.0, height = 1.0)
  # Larger tile => larger offsets
  expect_true(max(abs(offsets_large$x)) > max(abs(offsets_small$x)))
  expect_true(max(abs(offsets_large$y)) > max(abs(offsets_small$y)))
})

test_that("make_offsets() errors for out-of-range n", {
  expect_error(make_offsets(0))
  expect_error(make_offsets(7))
})

test_that("make_offsets() dot offsets are not all identical (n > 1)", {
  for (n in 2:6) {
    offsets <- make_offsets(n)
    # At least one pair of positions must differ
    expect_false(
      isTRUE(all(diff(offsets$x) == 0) && all(diff(offsets$y) == 0)),
      label = paste("make_offsets(", n, ") positions not all identical")
    )
  }
})

test_that("create_dice_positions() returns a non-empty string for all n", {
  for (n in 1:6) {
    pos_str <- ggdiceplot:::create_dice_positions(n)
    expect_type(pos_str, "character")
    expect_true(nchar(trimws(pos_str)) > 0,
                label = paste("create_dice_positions(", n, ") is non-empty"))
  }
})

test_that("create_dice_positions() errors for out-of-range n", {
  expect_error(ggdiceplot:::create_dice_positions(0))
  expect_error(ggdiceplot:::create_dice_positions(7))
})

test_that("scale_dots_discrete() returns a ggplot2 Scale object", {
  sc <- scale_dots_discrete()
  expect_s3_class(sc, "Scale")
})

test_that("theme_dice() returns a ggplot2 theme", {
  th <- theme_dice(x_length = 3, y_length = 2)
  expect_s3_class(th, "theme")
})
