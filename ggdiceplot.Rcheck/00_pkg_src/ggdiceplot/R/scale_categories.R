#' Scale for Category Positions with Dice Legend
#'
#' @description
#' Creates a ggplot2 scale for category positions that displays a legend with miniature dice
#' showing the position of each category. This legend appears outside the plot area.
#'
#' @param category_positions Named vector defining category positions (e.g., c("PathwayA" = 1, "PathwayB" = 2))
#' @param name Legend title
#' @param breaks Categories to show in legend (defaults to all categories)
#' @param labels Labels for categories (defaults to category names)
#' @param guide Legend guide specification
#' @param ... Additional arguments passed to scale
#' @return A ggplot2 scale
#' @export
scale_categories_dice <- function(category_positions, name = "Categories", 
                                 breaks = waiver(), labels = waiver(), 
                                 guide = "legend", ...) {
  
  # Create the scale
  ggplot2::scale_discrete_manual(
    aesthetic = "categories",
    values = category_positions,
    name = name,
    breaks = breaks,
    labels = labels,
    guide = guide,
    ...
  )
}

#' Custom Key Glyph for Dice Legend
#'
#' @description
#' Creates a custom key glyph that displays a miniature dice with a dot in the
#' specific position corresponding to the category.
#'
#' @param data Data for the legend key
#' @param params Parameters for the key glyph
#' @param size Size of the key glyph
#' @return A grid grob
#' @export
draw_key_dice <- function(data, params, size) {
  
  # Extract position from data
  position <- data$position[1]
  if (is.na(position)) position <- 1
  
  # Get dice positions for this specific position
  dice_positions <- create_dice_positions(6)
  selected_position <- dice_positions[position, ]
  
  # Create dice background
  dice_rect <- grid::rectGrob(
    x = 0.5, y = 0.5,
    width = grid::unit(0.8, "npc"),
    height = grid::unit(0.8, "npc"),
    gp = grid::gpar(
      fill = "white",
      col = "black",
      lwd = 1
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
      cex = 1.5
    )
  )
  
  grid::grobTree(dice_rect, dot)
}

#' Create Dice Position Guide
#'
#' @description
#' Creates a guide that shows category positions using miniature dice representations.
#'
#' @param category_positions Named vector of category positions
#' @param title Guide title
#' @param ncol Number of columns in the legend
#' @param nrow Number of rows in the legend
#' @param byrow Whether to fill the legend by row
#' @param ... Additional arguments
#' @return A ggplot2 guide
#' @export
guide_dice_positions <- function(category_positions, title = "Categories", 
                                ncol = NULL, nrow = NULL, byrow = FALSE, ...) {
  
  # Create custom guide
  ggplot2::guide_legend(
    title = title,
    ncol = ncol,
    nrow = nrow,
    byrow = byrow,
    override.aes = list(
      position = unname(category_positions),
      shape = 22,  # Use square shape as base
      size = 3
    ),
    ...
  )
}

#' Add Category Legend to Plot
#'
#' @description
#' Adds a proper ggplot2 legend for category positions that appears outside the plot area.
#'
#' @param plot A ggplot object
#' @param category_positions Named vector of category positions
#' @param title Legend title
#' @param position Legend position ("right", "left", "top", "bottom")
#' @return Modified ggplot object with legend
#' @export
add_category_legend <- function(plot, category_positions, title = "Categories", 
                               position = "right") {
  
  # Create legend data
  legend_data <- data.frame(
    category = names(category_positions),
    position = as.numeric(category_positions),
    x = 1,
    y = 1:length(category_positions),
    stringsAsFactors = FALSE
  )
  
  # Add invisible points for legend
  plot <- plot + 
    ggplot2::geom_point(
      data = legend_data,
      ggplot2::aes(x = x, y = y, shape = category),
      alpha = 0,  # Make invisible
      show.legend = TRUE
    ) +
    ggplot2::scale_shape_manual(
      name = title,
      values = setNames(rep(22, length(category_positions)), names(category_positions)),
      guide = guide_dice_positions(category_positions, title = title)
    ) +
    ggplot2::theme(
      legend.position = position,
      legend.title = ggplot2::element_text(face = "bold")
    )
  
  return(plot)
}