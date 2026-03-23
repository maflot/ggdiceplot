# Register global variables to avoid CMD check warnings
utils::globalVariables(c("x", "y", "z", "x_pos", "y_pos", "x_offset", "y_offset", "id", "size"))

#' Calculate Dice Dot Offsets
#'
#' @description Computes the (x, y) offset positions for drawing dots on dice faces.
#'
#' @param n Integer from 1 to 6, indicating the number of dots on the die face.
#' @param width Total width of the die face (default: 0.5).
#' @param height Total height of the die face (default: 0.5).
#' @param pad Padding to apply around the dot grid (default: 0.1).
#'
#' @return A data.frame with `key`, `x`, and `y` columns indicating dot positions.
#' @export
make_offsets <- function(n, width = 0.5, height = 0.5, pad = 0.1) {
  if (!n %in% 1:6) stop("n must be an integer between 1 and 6", call. = FALSE)
  
  grid_pos <- data.frame(
    pos = 1:9,
    col = rep(1:3, each = 3),
    row = rep(3:1, times = 3)
  )
  
  # Define dice dot positions with row-major order (left-to-right, top-to-bottom)
  # Grid layout:
  # 1  2  3
  # 4  5  6
  # 7  8  9
  # 
  # For 4+ dots, we use row-major ordering to match legend display:
  # - 4 dots: top-left, top-right, bottom-left, bottom-right (1, 7, 3, 9)
  # - 5 dots: adds center point in middle position (1, 7, 5, 3, 9)
  # - 6 dots: full rows - top row left-to-right, bottom row left-to-right (1, 4, 7, 3, 6, 9)
  dice_map <- list(
    "1" = c(5),
    "2" = c(1, 9),
    "3" = c(1, 5, 9),
    "4" = c(1, 7, 3, 9),      # Row-major: top-left, top-right, bottom-left, bottom-right
    "5" = c(1, 7, 5, 3, 9),   # Row-major: top-left, top-right, center, bottom-left, bottom-right
    "6" = c(1, 4, 7, 3, 6, 9) # Row-major: top row (left, mid, right), bottom row (left, mid, right)
  )
  
  positions <- dice_map[[as.character(n)]]
  
  grid_pos$x <- (grid_pos$col - 1) / 2
  grid_pos$y <- (grid_pos$row - 1) / 2
  
  # This ensures dots appear in the correct sequence (row-major) rather than grid_pos order
  dots <- grid_pos[match(positions, grid_pos$pos), c("x", "y")]
  
  avail_w <- width - 2 * pad
  avail_h <- height - 2 * pad
  
  dots$x <- dots$x * avail_w + pad - width / 2
  dots$y <- dots$y * avail_h + pad - height / 2
  
  # Reset row names to NULL to ensure clean indexing
  # Without this, row names would inherit from grid_pos (e.g., 1, 3, 7, 9)
  # which would cause misalignment when converting to matrix with column_to_rownames("key")
  # After reset, row names become 1, 2, 3, 4 matching the key values
  rownames(dots) <- NULL
  dots$key <- seq_len(n)
  
  dots <- dots[, c("key", "x", "y")]
  
  return(dots)
}

#' Get Dice Dot Positions as Text Grid
#'
#' @description Returns a string representing dice layout with numbered positions.
#'
#' @param n_dots Integer between 1 and 6
#'
#' @return Character string representing dice dot layout
#' @keywords internal
create_dice_positions <- function(n_dots) {
  if (!n_dots %in% 1:6) {
    stop("n_dots must be an integer between 1 and 6", call. = FALSE)
  }
  
  switch(as.character(n_dots),
         "1" = "
            ###
            #1#
            ###
         ",
         "2" = "
            1##
            ###
            ##2
         ",
         "3" = "
            1##
            #2#
            ##3
         ",
         "4" = "
            1#2
            ###
            3#4
         ",
         "5" = "
            1#2
            #3#
            4#5
         ",
         "6" = "
            1#2
            3#4
            5#6
         "
  )
}

#' Discrete Scale for Dice Dot Colors
#'
#' @importFrom scales pal_hue
#' @description Creates a ggplot2 discrete scale for dice dot aesthetics.
#'
#' @param ... Passed to `ggplot2::discrete_scale()`
#' @param aesthetics Character string of the target aesthetic (default: "dots")
#'
#' @return A ggplot2 scale
#' @export
#' @importFrom ggplot2 discrete_scale
scale_dots_discrete <- function(..., aesthetics = "dots") {
  ggplot2::discrete_scale(
    aesthetics = aesthetics,
    palette = scales::pal_hue(),
    ...
  )
}

#' Dice Theme for ggplot2
#' @importFrom ggplot2 %+replace%
#'
#' @description A minimal ggplot2 theme for dice plots.
#'
#' @param x_length Width of the plotting area (kept for compatibility)
#' @param y_length Height of the plotting area (kept for compatibility)
#' @param ... Additional arguments passed to `theme_grey()`
#'
#' @return A ggplot2 theme
#' @export
#' @importFrom ggplot2 theme_grey theme element_rect element_line
theme_dice <- function(x_length, y_length, ...) {
  ggplot2::theme_grey(...) %+replace%
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = NA, colour = NA),
      panel.grid = ggplot2::element_line(colour = "grey80"),
      complete = TRUE
    )
}
