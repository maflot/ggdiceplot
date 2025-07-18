utils::globalVariables(c("x", "y", "z", "x_pos", "y_pos", "x_offset", "y_offset"))

#' Create Dice Dot Positions
#'
#' @description
#' Creates the traditional dice dot positions for values 1-6.
#' This function generates the x and y offsets for placing dots
#' on a dice face following standard dice patterns.
#'
#' @param n_dots Integer between 1 and 6. Number of dots to place on the dice.
#' @return A data frame with columns:
#' \describe{
#'   \item{x_offset}{Numeric x-axis offset for each dot}
#'   \item{y_offset}{Numeric y-axis offset for each dot}
#' }
#'
#' @examples
#' # Get positions for a dice showing 3 dots
#' create_dice_positions(3)
#'
#' # Get positions for all dice faces
#' lapply(1:6, create_dice_positions)
#'
#' @export
create_dice_positions <- function(n_dots) {
  if (!n_dots %in% 1:6) {
    stop("n_dots must be an integer between 1 and 6", call. = FALSE)
  }
  
  switch(as.character(n_dots),
    "1" = tibble::tibble(
      x_offset = 0,
      y_offset = 0
    ),
    "2" = tibble::tibble(
      x_offset = c(-0.3, 0.3),
      y_offset = c(-0.3, 0.3)
    ),
    "3" = tibble::tibble(
      x_offset = c(-0.3, 0, 0.3),
      y_offset = c(-0.3, 0, 0.3)
    ),
    "4" = tibble::tibble(
      x_offset = c(-0.3, 0.3, -0.3, 0.3),
      y_offset = c(-0.3, -0.3, 0.3, 0.3)
    ),
    "5" = tibble::tibble(
      x_offset = c(-0.3, 0.3, -0.3, 0.3, 0),
      y_offset = c(-0.3, -0.3, 0.3, 0.3, 0)
    ),
    "6" = tibble::tibble(
      x_offset = c(-0.3, 0.3, -0.3, 0.3, -0.3, 0.3),
      y_offset = c(-0.3, -0.3, 0, 0, 0.3, 0.3)
    )
  )
}

#' Validate Dice Data
#'
#' @description
#' Validates that the data contains the required columns and
#' that the z values are within the valid range for dice (1-6).
#'
#' @param data A data frame to validate
#' @param mapping The aesthetic mappings
#' @return Logical. TRUE if data is valid, FALSE otherwise
#' @keywords internal
validate_dice_data <- function(data, mapping) {
  # Check required aesthetics
  required_aes <- c("x", "y", "z")
  mapped_aes <- names(mapping)
  
  missing_aes <- required_aes[!required_aes %in% mapped_aes]
  if (length(missing_aes) > 0) {
    stop(paste("Missing required aesthetics:", paste(missing_aes, collapse = ", ")), 
         call. = FALSE)
  }
  
  # Check z values are in valid range
  z_values <- data[[as.character(mapping$z)]]
  if (any(!is.na(z_values) & (z_values < 1 | z_values > 6))) {
    warning("Some z values are outside the valid range (1-6) and will be ignored", 
            call. = FALSE)
  }
  
  TRUE
}

#' Map continuous values to colors
#'
#' @description
#' Maps continuous values to colors using a color scale.
#'
#' @param values Numeric vector of values to map
#' @param colors Vector of colors to use for the scale
#' @param na_color Color to use for NA values
#' @return Vector of colors
#' @keywords internal
map_continuous_colors <- function(values, colors = c("blue", "white", "red"), na_color = "gray") {
  if (all(is.na(values))) {
    return(rep(na_color, length(values)))
  }
  
  # Handle NA values
  na_indices <- is.na(values)
  clean_values <- values[!na_indices]
  
  # Normalize values to [0, 1]
  min_val <- min(clean_values, na.rm = TRUE)
  max_val <- max(clean_values, na.rm = TRUE)
  
  if (min_val == max_val) {
    # All values are the same
    result_colors <- rep(colors[length(colors) %/% 2 + 1], length(values))
  } else {
    normalized <- (values - min_val) / (max_val - min_val)
    
    # Map to color indices
    color_indices <- pmax(1, pmin(length(colors), round(normalized * (length(colors) - 1)) + 1))
    result_colors <- colors[color_indices]
  }
  
  # Set NA values to na_color
  result_colors[na_indices] <- na_color
  
  return(result_colors)
}

#' Create Dice Grob with Enhanced Color Support
#'
#' @description
#' Creates a grid grob for rendering dice with the specified parameters.
#' Supports both discrete and continuous color mappings.
#'
#' @param x,y Position coordinates
#' @param z Number of dots (1-6)
#' @param dice_size Size of the dice
#' @param dot_size Size of the dots
#' @param dice_color Background color of the dice
#' @param dice_alpha Alpha transparency of the dice
#' @param dot_color Color of the dots (can be single color or vector for continuous mapping)
#' @param dot_alpha Alpha transparency of the dots
#' @param dot_stroke Stroke width for dot outlines
#' @param color_values Optional continuous values for color mapping
#' @return A grid grob
#' @keywords internal
create_dice_grob <- function(x, y, z, dice_size, dot_size, dice_color, dice_alpha,
                            dot_color, dot_alpha, dot_stroke, color_values = NULL) {
  if (is.na(z) || z < 1 || z > 6) {
    return(grid::nullGrob())
  }
  
  # Get dot positions
  positions <- create_dice_positions(z)
  
  # Scale positions with better spacing - ensure dots stay within dice boundaries
  positions$x_offset <- positions$x_offset * dice_size * 0.3
  positions$y_offset <- positions$y_offset * dice_size * 0.3
  
  # Create dice background
  dice_rect <- grid::rectGrob(
    x = x, y = y,
    width = grid::unit(dice_size, "native"),
    height = grid::unit(dice_size, "native"),
    gp = grid::gpar(
      fill = dice_color,
      alpha = dice_alpha,
      col = "black",
      lwd = 0.5
    )
  )
  
  # Create dots
  dot_x <- x + positions$x_offset
  dot_y <- y + positions$y_offset
  
  # Handle color mapping for continuous values
  if (!is.null(color_values) && is.numeric(color_values) && length(color_values) == nrow(positions)) {
    # Map continuous values to colors for each dot
    dot_colors <- map_continuous_colors(color_values)
  } else {
    # Use single color for all dots
    dot_colors <- rep(dot_color, nrow(positions))
  }
  
  dots <- grid::pointsGrob(
    x = dot_x, y = dot_y,
    pch = 19,
    gp = grid::gpar(
      col = dot_colors,
      alpha = dot_alpha,
      fontsize = dot_size
    )
  )
  
  # Create dot outlines if stroke > 0
  if (dot_stroke > 0) {
    dot_outlines <- grid::pointsGrob(
      x = dot_x, y = dot_y,
      pch = 1,
      gp = grid::gpar(
        col = "black",
        alpha = dot_alpha,
        fontsize = dot_size + 0.5,
        lwd = dot_stroke
      )
    )
    
    grid::grobTree(dice_rect, dots, dot_outlines)
  } else {
    grid::grobTree(dice_rect, dots)
  }
}