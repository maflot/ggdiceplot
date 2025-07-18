#' Custom Guide for Dice Category Positions
#'
#' @description
#' Creates a custom ggplot2 guide that shows category positions using miniature dice
#' representations. This guide appears outside the plot area as a proper legend.
#'
#' @param title Guide title
#' @param ncol Number of columns in the legend
#' @param nrow Number of rows in the legend
#' @param byrow Whether to fill the legend by row
#' @param reverse Whether to reverse the order of legend entries
#' @param override.aes List of aesthetic overrides
#' @param ... Additional arguments passed to guide_legend
#' @return A ggplot2 guide object
#' @export
guide_dice <- function(title = waiver(), ncol = NULL, nrow = NULL, byrow = FALSE, 
                       reverse = FALSE, override.aes = list(), ...) {
  
  # Create a modified guide_legend with custom key drawing
  guide <- ggplot2::guide_legend(
    title = title,
    ncol = ncol,
    nrow = nrow,
    byrow = byrow,
    reverse = reverse,
    override.aes = override.aes,
    ...
  )
  
  # Set the class for custom key drawing
  class(guide) <- c("guide_dice", class(guide))
  
  return(guide)
}

#' Custom Key Drawing for Dice Guide
#'
#' @description
#' Draws miniature dice with dots in specific positions for the legend.
#'
#' @param data Legend key data
#' @param params Guide parameters
#' @param size Key size
#' @return A grid grob
#' @export
draw_key_dice_position <- function(data, params, size) {
  
  # Extract position from data (assume it's stored in a specific column)
  position <- data$dice_position[1]
  if (is.na(position) || is.null(position)) {
    position <- 1  # Default position
  }
  
  # Get dice positions for this specific position
  dice_positions <- create_dice_positions(6)
  if (position > 0 && position <= 6) {
    selected_position <- dice_positions[position, ]
  } else {
    selected_position <- dice_positions[1, ]  # Default to position 1
  }
  
  # Create dice background
  dice_rect <- grid::rectGrob(
    x = 0.5, y = 0.5,
    width = grid::unit(0.8, "npc"),
    height = grid::unit(0.8, "npc"),
    gp = grid::gpar(
      fill = "white",
      col = "black",
      lwd = 1.5
    )
  )
  
  # Create dot at the specific position
  dot_x <- 0.5 + selected_position$x_offset * 0.3
  dot_y <- 0.5 + selected_position$y_offset * 0.3
  
  dot <- grid::pointsGrob(
    x = dot_x, y = dot_y,
    pch = 19,
    gp = grid::gpar(
      col = data$colour %||% "black",
      cex = 1.8
    )
  )
  
  grid::grobTree(dice_rect, dot)
}

#' Helper Function to Add Dice Position Legend
#'
#' @description
#' Adds a legend showing category positions with miniature dice to a ggplot.
#'
#' @param plot A ggplot object
#' @param category_positions Named vector of category positions
#' @param title Legend title
#' @param position Legend position
#' @return Modified ggplot object
#' @export
add_dice_position_legend <- function(plot, category_positions, title = "Categories", 
                                    position = "right") {
  
  # Create invisible aesthetic mapping for the legend
  legend_data <- data.frame(
    category = names(category_positions),
    dice_position = as.numeric(category_positions),
    x = 0,  # Invisible position
    y = 0,  # Invisible position
    stringsAsFactors = FALSE
  )
  
  # Add the legend data to the plot
  plot <- plot + 
    ggplot2::geom_point(
      data = legend_data,
      ggplot2::aes(x = x, y = y, shape = category),
      alpha = 0,  # Make invisible
      size = 0,   # Make invisible
      show.legend = TRUE
    ) +
    ggplot2::scale_shape_manual(
      name = title,
      values = setNames(rep(22, length(category_positions)), names(category_positions)),
      guide = guide_dice(title = title)
    ) +
    ggplot2::theme(
      legend.position = position,
      legend.title = ggplot2::element_text(face = "bold"),
      legend.margin = ggplot2::margin(10, 10, 10, 10)
    )
  
  return(plot)
}

#' Create Dice Position Scale
#'
#' @description
#' Creates a scale that maps categories to dice positions for legend display.
#'
#' @param category_positions Named vector of category positions
#' @param name Scale name
#' @param guide Guide specification
#' @param ... Additional arguments
#' @return A ggplot2 scale
#' @export
scale_dice_position <- function(category_positions, name = "Categories", 
                               guide = guide_dice(), ...) {
  
  # Create a manual scale
  ggplot2::scale_discrete_manual(
    aesthetics = "dice_position",
    values = category_positions,
    name = name,
    guide = guide,
    ...
  )
}