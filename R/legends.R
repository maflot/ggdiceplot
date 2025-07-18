#' Create Category Position Legend with Miniature Dice
#'
#' @description
#' Creates a ggplot2-compatible legend showing category positions using miniature dice representations.
#' This legend will appear outside the plot area as a proper ggplot2 legend.
#'
#' @param category_positions Named vector of category positions (e.g., c("PathwayA" = 1, "PathwayB" = 2))
#' @param title Title for the legend
#' @param dice_size Size of miniature dice in legend
#' @param dot_size Size of dots in miniature dice
#' @return A ggplot2 legend guide
#' @export
create_category_position_legend <- function(category_positions, title = "Categories", 
                                          dice_size = 0.8, dot_size = 0.15) {
  
  # Create a custom legend guide
  legend_data <- data.frame(
    category = names(category_positions),
    position = as.numeric(category_positions),
    stringsAsFactors = FALSE
  )
  
  # Create miniature dice grobs for each position
  create_dice_key_glyph <- function(data, params, size) {
    position <- data$position[1]
    
    # Get dice positions for this specific position
    dice_positions <- create_dice_positions(6)
    selected_position <- dice_positions[position, ]
    
    # Create dice background
    dice_rect <- grid::rectGrob(
      x = 0.5, y = 0.5,
      width = grid::unit(dice_size, "npc"),
      height = grid::unit(dice_size, "npc"),
      gp = grid::gpar(
        fill = "white",
        col = "black",
        lwd = 1
      )
    )
    
    # Create dot at the specific position
    dot_x <- 0.5 + selected_position$x_offset * dice_size * 0.4
    dot_y <- 0.5 + selected_position$y_offset * dice_size * 0.4
    
    dot <- grid::pointsGrob(
      x = dot_x, y = dot_y,
      pch = 19,
      gp = grid::gpar(
        col = "black",
        cex = dot_size * 10
      )
    )
    
    grid::grobTree(dice_rect, dot)
  }
  
  # Return the legend data for use with scale_* functions
  return(legend_data)
}

#' Create Custom Dice Pattern Legend
#'
#' @description
#' Creates a custom legend showing dice patterns for values 1-6.
#'
#' @param dice_size Size of the dice in the legend
#' @param dot_size Size of the dots in the legend
#' @param dice_color Background color of the dice
#' @param dot_color Color of the dots
#' @param title Title for the legend
#' @param show_values Whether to show numeric values
#' @return A ggplot object
#' @export
create_dice_pattern_legend <- function(dice_size = 1, dot_size = 0.3, dice_color = "white", 
                                     dot_color = "black", title = "Dice Patterns", show_values = TRUE) {
  
  # Create legend data
  legend_data <- data.frame(
    dice_value = 1:6,
    x = 1:6,
    y = rep(1, 6),
    description = c("One (Center)", "Two (Diagonal)", "Three (Line)", 
                   "Four (Corners)", "Five (Plus)", "Six (Columns)")
  )
  
  # Create the base plot
  p <- ggplot2::ggplot(legend_data, ggplot2::aes(x = x, y = y)) +
    ggplot2::xlim(0.5, 6.5) +
    ggplot2::ylim(0.3, 1.7) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 12, face = "bold"),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    ) +
    ggplot2::labs(title = title)
  
  # Add dice backgrounds
  for (i in 1:6) {
    p <- p + ggplot2::annotate("rect", 
                              xmin = i - dice_size/2, xmax = i + dice_size/2,
                              ymin = 1 - dice_size/2, ymax = 1 + dice_size/2,
                              fill = dice_color, color = "black", size = 0.5)
  }
  
  # Add dots for each dice
  for (i in 1:6) {
    positions <- create_dice_positions(i)
    dot_x <- i + positions$x_offset * dice_size * 0.4
    dot_y <- 1 + positions$y_offset * dice_size * 0.4
    
    p <- p + ggplot2::annotate("point", x = dot_x, y = dot_y, 
                              color = dot_color, size = dot_size * 8)
  }
  
  # Add value labels if requested
  if (show_values) {
    p <- p + ggplot2::annotate("text", x = 1:6, y = 0.5, 
                              label = paste("Value:", 1:6), 
                              size = 3, hjust = 0.5)
  }
  
  # Add descriptions
  p <- p + ggplot2::annotate("text", x = 1:6, y = 1.5, 
                            label = legend_data$description, 
                            size = 2.5, hjust = 0.5, angle = 0)
  
  return(p)
}

#' Create Custom Color Scale Legend
#'
#' @description
#' Creates a custom legend showing color scale mapping for continuous variables.
#'
#' @param values Vector of values to show in legend
#' @param colors Vector of colors corresponding to values
#' @param title Title for the legend
#' @param labels Labels for the values (optional)
#' @param orientation Either "vertical" or "horizontal"
#' @return A ggplot object
#' @export
create_color_scale_legend <- function(values, colors, title = "Color Scale", 
                                    labels = NULL, orientation = "vertical") {
  
  if (is.null(labels)) {
    labels <- as.character(values)
  }
  
  legend_data <- data.frame(
    value = values,
    color = colors,
    label = labels
  )
  
  if (orientation == "vertical") {
    legend_data$x <- rep(1, length(values))
    legend_data$y <- rev(seq_along(values))
    
    p <- ggplot2::ggplot(legend_data, ggplot2::aes(x = x, y = y)) +
      ggplot2::xlim(0.5, 2.5) +
      ggplot2::ylim(0.5, length(values) + 0.5) +
      ggplot2::theme_void() +
      ggplot2::theme(
        plot.title = ggplot2::element_text(hjust = 0.5, size = 12, face = "bold"),
        plot.margin = ggplot2::margin(10, 10, 10, 10)
      ) +
      ggplot2::labs(title = title)
    
    # Add color rectangles
    for (i in 1:nrow(legend_data)) {
      p <- p + ggplot2::annotate("rect", 
                                xmin = 0.7, xmax = 1.3,
                                ymin = legend_data$y[i] - 0.3, ymax = legend_data$y[i] + 0.3,
                                fill = legend_data$color[i], color = "black", size = 0.3)
    }
    
    # Add labels
    p <- p + ggplot2::annotate("text", x = 1.5, y = legend_data$y, 
                              label = legend_data$label, 
                              size = 3, hjust = 0)
    
  } else {
    legend_data$x <- seq_along(values)
    legend_data$y <- rep(1, length(values))
    
    p <- ggplot2::ggplot(legend_data, ggplot2::aes(x = x, y = y)) +
      ggplot2::xlim(0.5, length(values) + 0.5) +
      ggplot2::ylim(0.5, 1.5) +
      ggplot2::theme_void() +
      ggplot2::theme(
        plot.title = ggplot2::element_text(hjust = 0.5, size = 12, face = "bold"),
        plot.margin = ggplot2::margin(10, 10, 10, 10)
      ) +
      ggplot2::labs(title = title)
    
    # Add color rectangles
    for (i in 1:nrow(legend_data)) {
      p <- p + ggplot2::annotate("rect", 
                                xmin = legend_data$x[i] - 0.3, xmax = legend_data$x[i] + 0.3,
                                ymin = 0.7, ymax = 1.3,
                                fill = legend_data$color[i], color = "black", size = 0.3)
    }
    
    # Add labels
    p <- p + ggplot2::annotate("text", x = legend_data$x, y = 0.5, 
                              label = legend_data$label, 
                              size = 3, hjust = 0.5, angle = 45)
  }
  
  return(p)
}

#' Create Comprehensive Dice Plot Legend
#'
#' @description
#' Creates a comprehensive legend combining dice patterns and color scale.
#'
#' @param color_values Vector of continuous values for color mapping
#' @param color_scale Color scale to use (either vector of colors or scale name)
#' @param dice_title Title for dice pattern legend
#' @param color_title Title for color scale legend
#' @param layout Layout arrangement: "horizontal" or "vertical"
#' @return A combined ggplot object
#' @export
create_comprehensive_legend <- function(color_values, color_scale = c("blue", "white", "red"), 
                                      dice_title = "Dice Patterns", color_title = "Color Scale",
                                      layout = "horizontal") {
  
  # Create dice pattern legend
  dice_legend <- create_dice_pattern_legend(title = dice_title, dice_size = 0.8, dot_size = 0.4)
  
  # Create color scale legend
  if (is.numeric(color_values)) {
    # For continuous values, create a gradient
    n_colors <- 5
    color_breaks <- seq(min(color_values, na.rm = TRUE), max(color_values, na.rm = TRUE), length.out = n_colors)
    colors <- map_continuous_colors(color_breaks, color_scale)
    color_legend <- create_color_scale_legend(color_breaks, colors, title = color_title, 
                                            labels = sprintf("%.1f", color_breaks))
  } else {
    # For discrete values
    unique_values <- unique(color_values)
    colors <- map_continuous_colors(seq_along(unique_values), color_scale)
    color_legend <- create_color_scale_legend(seq_along(unique_values), colors, 
                                            title = color_title, labels = unique_values)
  }
  
  # Combine legends
  if (layout == "horizontal") {
    combined_legend <- cowplot::plot_grid(dice_legend, color_legend, 
                                        ncol = 2, rel_widths = c(2, 1))
  } else {
    combined_legend <- cowplot::plot_grid(dice_legend, color_legend, 
                                        nrow = 2, rel_heights = c(1, 1))
  }
  
  return(combined_legend)
}

#' Create Interactive Dice Legend
#'
#' @description
#' Creates an interactive legend showing dice patterns with hover information.
#'
#' @param include_examples Whether to include example use cases
#' @return A detailed ggplot object
#' @export
create_interactive_dice_legend <- function(include_examples = TRUE) {
  
  # Create detailed legend data
  legend_data <- data.frame(
    dice_value = 1:6,
    x = rep(1:3, each = 2),
    y = rep(c(2, 1), times = 3),
    pattern_name = c("Center", "Diagonal", "Line", "Corners", "Plus", "Columns"),
    description = c(
      "Single dot in center\n(Low values, rare events)",
      "Two dots diagonally\n(Binary outcomes)",
      "Three dots in line\n(Moderate frequency)",
      "Four dots in corners\n(High frequency)",
      "Five dots plus center\n(Very high frequency)",
      "Six dots in columns\n(Maximum frequency)"
    ),
    use_case = c(
      "Rare events", "Binary choice", "Moderate", 
      "Common", "Very common", "Maximum"
    )
  )
  
  # Create the base plot with better layout
  p <- ggplot2::ggplot(legend_data, ggplot2::aes(x = x, y = y)) +
    ggplot2::xlim(0, 4) +
    ggplot2::ylim(0, 3) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 14, face = "bold"),
      plot.subtitle = ggplot2::element_text(hjust = 0.5, size = 10),
      plot.margin = ggplot2::margin(15, 15, 15, 15)
    ) +
    ggplot2::labs(
      title = "Dice Pattern Guide",
      subtitle = "Understanding dot arrangements and their meanings"
    )
  
  # Add dice backgrounds with better styling
  for (i in 1:6) {
    row <- legend_data[i, ]
    p <- p + ggplot2::annotate("rect", 
                              xmin = row$x - 0.4, xmax = row$x + 0.4,
                              ymin = row$y - 0.4, ymax = row$y + 0.4,
                              fill = "white", color = "black", size = 0.8)
  }
  
  # Add dots with improved visibility
  for (i in 1:6) {
    row <- legend_data[i, ]
    positions <- create_dice_positions(i)
    dot_x <- row$x + positions$x_offset * 0.35
    dot_y <- row$y + positions$y_offset * 0.35
    
    # Add dots with outlines
    p <- p + ggplot2::annotate("point", x = dot_x, y = dot_y, 
                              color = "black", size = 4, shape = 19)
    p <- p + ggplot2::annotate("point", x = dot_x, y = dot_y, 
                              color = "black", size = 4.5, shape = 1)
  }
  
  # Add pattern names
  p <- p + ggplot2::annotate("text", x = legend_data$x, y = legend_data$y - 0.6, 
                            label = paste("Value", legend_data$dice_value, "\n", legend_data$pattern_name), 
                            size = 3, hjust = 0.5, face = "bold")
  
  # Add descriptions if requested
  if (include_examples) {
    p <- p + ggplot2::annotate("text", x = legend_data$x, y = legend_data$y - 1, 
                              label = legend_data$use_case, 
                              size = 2.5, hjust = 0.5, style = "italic", color = "gray40")
  }
  
  return(p)
}

#' Create Heat Map Style Color Legend
#'
#' @description
#' Creates a heat map style color legend with gradient bar.
#'
#' @param min_value Minimum value for the scale
#' @param max_value Maximum value for the scale
#' @param colors Vector of colors for the gradient
#' @param title Title for the legend
#' @param n_breaks Number of breaks to show
#' @return A ggplot object
#' @export
create_heatmap_color_legend <- function(min_value, max_value, colors = c("blue", "white", "red"), 
                                      title = "Value", n_breaks = 5) {
  
  # Create gradient data
  gradient_data <- data.frame(
    x = rep(1, 100),
    y = 1:100,
    value = seq(min_value, max_value, length.out = 100)
  )
  
  # Create break points
  breaks <- seq(min_value, max_value, length.out = n_breaks)
  break_y <- seq(10, 90, length.out = n_breaks)
  
  # Create the gradient plot
  p <- ggplot2::ggplot(gradient_data, ggplot2::aes(x = x, y = y, fill = value)) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_gradientn(colors = colors, guide = "none") +
    ggplot2::xlim(0.5, 2.5) +
    ggplot2::ylim(0, 100) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 12, face = "bold"),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    ) +
    ggplot2::labs(title = title)
  
  # Add border
  p <- p + ggplot2::annotate("rect", xmin = 0.9, xmax = 1.1, ymin = 5, ymax = 95,
                            fill = NA, color = "black", size = 0.5)
  
  # Add tick marks and labels
  for (i in 1:length(breaks)) {
    p <- p + ggplot2::annotate("segment", x = 1.1, xend = 1.2, 
                              y = break_y[i], yend = break_y[i], 
                              color = "black", size = 0.3)
    p <- p + ggplot2::annotate("text", x = 1.3, y = break_y[i], 
                              label = sprintf("%.1f", breaks[i]), 
                              size = 3, hjust = 0)
  }
  
  return(p)
}