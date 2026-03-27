# Tests for aesthetic correctness:
#   - pip colours are never NA when dots are visible
#   - pip coordinates fall within tile boundaries
#   - pip row count matches the data (no silent drops)

# ---------------------------------------------------------------------------
# Helper: extract point_df from the first layer's DiceGrob.
# Uses the same tree-traversal approach as test-rendering.R.
# ---------------------------------------------------------------------------
find_dice_grob_aes <- function(x) {
  if (inherits(x, "DiceGrob")) return(x)
  kids <- if (inherits(x, "gTree")) x$children else if (is.list(x)) x else NULL
  if (!is.null(kids)) {
    for (k in kids) {
      found <- find_dice_grob_aes(k)
      if (!is.null(found)) return(found)
    }
  }
  NULL
}

get_point_df <- function(plot) {
  raw <- ggplot2::layer_grob(plot, i = 1L)
  g   <- find_dice_grob_aes(raw)
  if (is.null(g)) stop("DiceGrob not found in layer_grob() output")
  g$point_df
}

# ---------------------------------------------------------------------------
# Colour correctness
# ---------------------------------------------------------------------------

test_that("pip colour is never NA (fill unmapped)", {
  p   <- make_simple_plot(fill_mapped = FALSE)
  pdf <- get_point_df(p)
  expect_false(
    any(is.na(pdf$colour)),
    info = "All pip colours must be non-NA when fill is not mapped"
  )
})

test_that("pip colour is never NA (fill mapped to continuous)", {
  dat <- make_simple_data()
  p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y, dots = dots,
                                          fill = fill_val)) +
    geom_dice(ndots = 3L, x_length = 2L, y_length = 1L) +
    ggplot2::scale_fill_gradient2(low = "blue", high = "red", mid = "white",
                                   midpoint = 0)
  pdf <- get_point_df(p)
  expect_false(
    any(is.na(pdf$colour)),
    info = "All pip colours must be non-NA when fill is a continuous aesthetic"
  )
})

test_that("pip colour is never NA (fill mapped to discrete)", {
  dat <- make_simple_data()
  dat$group <- factor(ifelse(dat$fill_val > 0, "Up", "Down"))
  p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y, dots = dots,
                                          fill = group)) +
    geom_dice(ndots = 3L, x_length = 2L, y_length = 1L)
  pdf <- get_point_df(p)
  expect_false(
    any(is.na(pdf$colour)),
    info = "All pip colours must be non-NA when fill is a discrete aesthetic"
  )
})

# ---------------------------------------------------------------------------
# Coordinate bounds: pips must lie within their tile boundaries
# ---------------------------------------------------------------------------

test_that("pip x-coordinates fall within tile boundaries", {
  dat <- make_simple_data()
  tile_w <- 0.5  # default width
  p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y, dots = dots)) +
    geom_dice(ndots = 3L, x_length = 2L, y_length = 1L)
  pdf <- get_point_df(p)

  # x_coord holds the tile centre; pips must stay within ± tile_w/2
  tile_centers <- pdf$x_coord
  expect_true(
    all(pdf$x >= tile_centers - tile_w / 2 - .Machine$double.eps &
          pdf$x <= tile_centers + tile_w / 2 + .Machine$double.eps),
    info = "Pip x-coordinates must not exceed tile boundaries"
  )
})

test_that("pip y-coordinates fall within tile boundaries", {
  dat <- make_simple_data()
  tile_h <- 0.5  # default height
  p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y, dots = dots)) +
    geom_dice(ndots = 3L, x_length = 2L, y_length = 1L)
  pdf <- get_point_df(p)

  tile_centers <- pdf$y_coord
  expect_true(
    all(pdf$y >= tile_centers - tile_h / 2 - .Machine$double.eps &
          pdf$y <= tile_centers + tile_h / 2 + .Machine$double.eps),
    info = "Pip y-coordinates must not exceed tile boundaries"
  )
})

# ---------------------------------------------------------------------------
# Pip count invariant: no silent row drops
# ---------------------------------------------------------------------------

test_that("pip count matches the number of data rows (no silent drops)", {
  dat <- make_simple_data()
  # dat has 5 rows => 5 dots expected (2 tiles: 3+2 dots)
  p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y, dots = dots)) +
    geom_dice(ndots = 3L, x_length = 2L, y_length = 1L)
  pdf <- get_point_df(p)
  expect_equal(
    nrow(pdf), nrow(dat),
    info = "point_df must have exactly one row per data observation"
  )
})

test_that("all ndots values produce the correct pip count for a full single tile", {
  for (n in 1:6) {
    dat <- make_single_tile_data(n)
    p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y, dots = dots)) +
      geom_dice(ndots = n, x_length = 1L, y_length = 1L)
    pdf <- get_point_df(p)
    expect_equal(
      nrow(pdf), n,
      info = paste0("Expected ", n, " pip rows for ndots = ", n)
    )
  }
})

# ---------------------------------------------------------------------------
# Tile count invariant: one tile grob per unique (x, y) combination
# ---------------------------------------------------------------------------

test_that("tile_df has one row per unique (x, y) tile", {
  dat <- make_simple_data()
  # 2 unique (x, y) combinations: (1,1) and (2,1)
  p <- ggplot2::ggplot(dat, ggplot2::aes(x = x, y = y, dots = dots)) +
    geom_dice(ndots = 3L, x_length = 2L, y_length = 1L)
  raw <- ggplot2::layer_grob(p, i = 1L)
  g <- find_dice_grob_aes(raw)
  n_tiles <- nrow(unique(dat[, c("x", "y")]))
  expect_equal(
    nrow(g$tile_df), n_tiles,
    info = "tile_df must have exactly one row per unique tile"
  )
})
