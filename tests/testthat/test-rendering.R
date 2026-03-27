# Tests for core rendering: S3 method registration, DiceGrob structure,
# fill/size aesthetic variations, and all ndots values 1–6.

# ---------------------------------------------------------------------------
# Helper: extract the DiceGrob produced by the first layer of a ggplot.
# layer_grob() may wrap the result in a grobTree (or list) depending on the
# ggplot2 version, so we traverse the tree to find the DiceGrob.
# ---------------------------------------------------------------------------
find_dice_grob <- function(x) {
  if (inherits(x, "DiceGrob")) return(x)
  # Recurse into gTree children or plain lists
  kids <- if (inherits(x, "gTree")) x$children else if (is.list(x)) x else NULL
  if (!is.null(kids)) {
    for (k in kids) {
      found <- find_dice_grob(k)
      if (!is.null(found)) return(found)
    }
  }
  NULL
}

get_dice_grob <- function(plot) {
  raw <- ggplot2::layer_grob(plot, i = 1L)
  g   <- find_dice_grob(raw)
  if (is.null(g)) stop("DiceGrob not found in layer_grob() output")
  g
}

# ---------------------------------------------------------------------------
# S3 dispatch registration (the v1.1.0 bug)
# ---------------------------------------------------------------------------

test_that("drawDetails.DiceGrob is registered as an S3 method", {
  method <- getS3method("drawDetails", "DiceGrob", optional = TRUE)
  expect_false(
    is.null(method),
    info = paste(
      "drawDetails.DiceGrob must be registered in NAMESPACE.",
      "This test catches the v1.1.0 bug where the S3 method was missing."
    )
  )
})

# ---------------------------------------------------------------------------
# Basic DiceGrob structure
# ---------------------------------------------------------------------------

test_that("geom_dice() layer returns a DiceGrob", {
  p <- make_simple_plot()
  g <- get_dice_grob(p)
  expect_s3_class(g, "DiceGrob")
})

test_that("DiceGrob contains a non-empty point_df", {
  p <- make_simple_plot()
  g <- get_dice_grob(p)
  expect_s3_class(g$point_df, "data.frame")
  expect_gt(nrow(g$point_df), 0L)
})

test_that("DiceGrob contains a non-empty tile_df", {
  p <- make_simple_plot()
  g <- get_dice_grob(p)
  expect_s3_class(g$tile_df, "data.frame")
  expect_gt(nrow(g$tile_df), 0L)
})

# ---------------------------------------------------------------------------
# Draw paths: fill mapped / unmapped, size mapped / unmapped
# ---------------------------------------------------------------------------

test_that("fill mapped: DiceGrob point_df has non-zero rows", {
  p <- make_simple_plot(fill_mapped = TRUE)
  g <- get_dice_grob(p)
  expect_gt(nrow(g$point_df), 0L)
})

test_that("fill unmapped: DiceGrob point_df has non-zero rows", {
  p <- make_simple_plot(fill_mapped = FALSE)
  g <- get_dice_grob(p)
  expect_gt(nrow(g$point_df), 0L)
})

test_that("size mapped: DiceGrob point_df has non-zero rows", {
  p <- make_simple_plot(size_mapped = TRUE)
  g <- get_dice_grob(p)
  expect_gt(nrow(g$point_df), 0L)
})

test_that("fill + size mapped: DiceGrob point_df has non-zero rows", {
  p <- make_simple_plot(fill_mapped = TRUE, size_mapped = TRUE)
  g <- get_dice_grob(p)
  expect_gt(nrow(g$point_df), 0L)
})

# ---------------------------------------------------------------------------
# pip_scale variations
# ---------------------------------------------------------------------------

test_that("pip_scale = NULL (legacy mode) still produces a DiceGrob", {
  p <- make_simple_plot(pip_scale = NULL)
  g <- get_dice_grob(p)
  expect_s3_class(g, "DiceGrob")
  expect_gt(nrow(g$point_df), 0L)
})

test_that("pip_scale = 0.5 produces a valid DiceGrob", {
  p <- make_simple_plot(pip_scale = 0.5)
  g <- get_dice_grob(p)
  expect_s3_class(g, "DiceGrob")
  expect_gt(nrow(g$point_df), 0L)
})

test_that("pip_scale = 1.0 (tight packing) produces a valid DiceGrob", {
  p <- make_simple_plot(pip_scale = 1.0)
  g <- get_dice_grob(p)
  expect_s3_class(g, "DiceGrob")
  expect_gt(nrow(g$point_df), 0L)
})

# ---------------------------------------------------------------------------
# All ndots values 1–6
# ---------------------------------------------------------------------------

for (.n in 1:6) {
  local({
    n <- .n
    test_that(paste0("ndots = ", n, ": DiceGrob is produced and has correct pip count"), {
      dat <- make_single_tile_data(n)
      p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y, dots = dots)) +
        geom_dice(ndots = n, x_length = 1L, y_length = 1L)
      g <- get_dice_grob(p)
      expect_s3_class(g, "DiceGrob")
      expect_equal(
        nrow(g$point_df), n,
        info = paste0("ndots = ", n, ": expected exactly ", n, " pip rows")
      )
    })
  })
}

# ---------------------------------------------------------------------------
# Rendering to a device does not throw an error (exercises drawDetails)
# ---------------------------------------------------------------------------

test_that("rendering a dice plot to a device does not error", {
  p <- make_simple_plot(fill_mapped = TRUE)
  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)
  expect_no_error(
    ggplot2::ggsave(tf, plot = p, width = 4, height = 3, dpi = 72)
  )
  expect_true(file.exists(tf))
})

test_that("rendering all ndots values to a device does not error", {
  for (n in 1:6) {
    dat <- make_single_tile_data(n)
    p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y, dots = dots)) +
      geom_dice(ndots = n, x_length = 1L, y_length = 1L)
    tf <- tempfile(fileext = ".png")
    on.exit(unlink(tf), add = TRUE)
    expect_no_error(
      ggplot2::ggsave(tf, plot = p, width = 3, height = 3, dpi = 72),
      info = paste0("Rendering ndots = ", n, " failed")
    )
  }
})
