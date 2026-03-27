# Helper functions and shared test data for ggdiceplot tests.
# Sourced automatically by testthat before running any test files.

library(ggplot2)

# ---------------------------------------------------------------------------
# Minimal "long-format" dice data:
#   one row per (tile, dot-position) combination.
#   tile (x=1,y=1): positions A, B, C  (all three present)
#   tile (x=2,y=1): positions A, C     (B absent)
# ---------------------------------------------------------------------------
make_simple_data <- function() {
  data.frame(
    x    = c(1L, 1L, 1L, 2L, 2L),
    y    = c(1L, 1L, 1L, 1L, 1L),
    dots = factor(c("A", "B", "C", "A", "C"), levels = c("A", "B", "C")),
    fill_val = c(1.0, -1.0, 0.5, -0.5, 0.8),
    size_val = c(2.0,  3.0, 4.0,  2.5, 3.5),
    stringsAsFactors = FALSE
  )
}

# Single tile with n dots (useful for testing individual die faces)
make_single_tile_data <- function(n) {
  stopifnot(n >= 1L, n <= 6L)
  data.frame(
    x    = rep(1L, n),
    y    = rep(1L, n),
    dots = factor(LETTERS[seq_len(n)], levels = LETTERS[seq_len(n)]),
    stringsAsFactors = FALSE
  )
}

# Build a ggplot with geom_dice() for the simple 2-tile data
make_simple_plot <- function(fill_mapped = FALSE, size_mapped = FALSE,
                              pip_scale = 0.75) {
  dat <- make_simple_data()
  mapping <- if (fill_mapped && size_mapped) {
    ggplot2::aes(x = x, y = y, dots = dots, fill = fill_val, size = size_val)
  } else if (fill_mapped) {
    ggplot2::aes(x = x, y = y, dots = dots, fill = fill_val)
  } else if (size_mapped) {
    ggplot2::aes(x = x, y = y, dots = dots, size = size_val)
  } else {
    ggplot2::aes(x = x, y = y, dots = dots)
  }

  ggplot2::ggplot(dat, mapping) +
    geom_dice(ndots = 3L, x_length = 2L, y_length = 1L, pip_scale = pip_scale)
}
