#' A ggplot2 layer for creating dice representations
#'
#' @description
#' `geom_dice()` creates a ggplot2 layer that displays dice representations where
#' each dot position represents a specific categorical variable. Dots are only
#' shown when that categorical variable is present in the data.
#'
#' @param mapping Set of aesthetic mappings created by `aes()`. Must include:
#'   - `x`: x-axis position
#'   - `y`: y-axis position
#'   - `categories`: comma-separated string of present categories OR multiple category columns
#'   
#'   Optional aesthetics:
#'   - `colour`/`color`: color of the dice dots
#'   - `fill`: fill color of the dice dots
#'   - `alpha`: transparency of the dice dots
#'   - `size`: size scaling factor
#' @param category_positions Named vector defining which position each category occupies
#'   on the dice (positions 1-6). If NULL, uses first 6 unique categories found.
#' @param show_legend_dice Whether to show a legend with miniature dice representations
#' @param data A data frame. If `NULL`, the default, the data is inherited from the plot.
#' @param stat The statistical transformation to use on the data for this layer.
#' @param position Position adjustment, either as a string, or the result of a call to a position adjustment function.
#' @param show.legend logical. Should this layer be included in the legends?
#' @param inherit.aes If `FALSE`, overrides the default aesthetics.
#' @param na.rm If `FALSE`, the default, missing values are removed with a warning. If `TRUE`, missing values are silently removed.
#' @param dice_size Numeric. Size of the dice background rectangle. Default is 1.
#' @param dot_size Numeric. Size of the dots on the dice. If `NULL`, calculated as 20% of `dice_size`.
#' @param dice_color Character. Background color of the dice. Default is "white".
#' @param dice_alpha Numeric. Transparency of the dice background. Default is 0.8.
#' @param dot_stroke Numeric. Stroke width for dot outlines. Default is 0.5.
#' @param ... Other arguments passed on to `layer()`.
#'
#' @return A ggplot2 layer that can be added to a ggplot object.
#'
#' @section Dice Concept:
#' The dice concept works as follows:
#' - Each position on the dice (1-6) represents a specific categorical variable
#' - A dot is shown in that position ONLY if that category is present for that observation
#' - Empty positions mean that categorical variable is absent
#' - This allows visualization of up to 6 categorical variables simultaneously
#'
#' @section Aesthetics:
#' `geom_dice()` understands the following aesthetics (required aesthetics are in bold):
#' - **x**: x-axis position
#' - **y**: y-axis position
#' - **categories**: comma-separated string of present categories
#' - `colour`/`color`: color of the dice dots
#' - `fill`: fill color of the dice dots
#' - `alpha`: transparency of the dice dots
#' - `size`: size scaling factor
#'
#' @examples
#' library(ggplot2)
#' library(dplyr)
#' 
#' # Example: Gene expression data
#' # Each position represents a different biological pathway
#' gene_data <- data.frame(
#'   gene = c("GENE1", "GENE2", "GENE3"),
#'   condition = c("Control", "Treatment", "Control"),
#'   pathways = c("Pathway1,Pathway3", "Pathway2,Pathway4,Pathway5", "Pathway1,Pathway6")
#' )
#' 
#' # Define which position each pathway occupies
#' pathway_positions <- c(
#'   "Pathway1" = 1, "Pathway2" = 2, "Pathway3" = 3,
#'   "Pathway4" = 4, "Pathway5" = 5, "Pathway6" = 6
#' )
#' 
#' # Create dice plot
#' ggplot(gene_data, aes(x = gene, y = condition, categories = pathways)) +
#'   geom_dice(category_positions = pathway_positions)
#'
#' @export
geom_dice <- function(mapping = NULL, data = NULL, 
                      category_positions = NULL,
                      stat = "identity", position = "identity",
                      show.legend = NA, inherit.aes = TRUE, na.rm = FALSE,
                      dice_size = 1, dot_size = NULL, dice_color = "white", 
                      dice_alpha = 0.8, dot_stroke = 0.5, 
                      show_legend_dice = TRUE, ...) {
  
  # Set default dot size if not provided
  if (is.null(dot_size)) {
    dot_size <- dice_size * 3.0  # Proportional dot size that fits within dice
  }
  
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomDice,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      dice_size = dice_size,
      dot_size = dot_size,
      dice_color = dice_color,
      dice_alpha = dice_alpha,
      dot_stroke = dot_stroke,
      category_positions = category_positions,
      ...
    )
  )
}

#' @rdname geom_dice
#' @format NULL
#' @usage NULL
#' @export
GeomDice <- ggplot2::ggproto("GeomDice", ggplot2::Geom,
  required_aes = c("x", "y", "categories"),
  default_aes = ggplot2::aes(
    colour = "black",
    fill = "black", 
    size = 1,
    alpha = 1
  ),
  
  draw_panel = function(data, panel_params, coord, dice_size = 1, dot_size = NULL, 
                        dice_color = "white", dice_alpha = 0.8, dot_stroke = 0.5,
                        category_positions = NULL) {
    
    # Transform coordinates
    coords <- coord$transform(data, panel_params)
    
    if (nrow(coords) == 0) {
      return(grid::nullGrob())
    }
    
    # Calculate dynamic dice size based on plot space and data density
    if (dice_size == 1) {  # Only auto-scale if default size is used
      x_range <- diff(range(coords$x, na.rm = TRUE))
      y_range <- diff(range(coords$y, na.rm = TRUE))
      
      # Calculate available space per point
      if (x_range > 0 && y_range > 0) {
        # Get unique positions to understand grid structure
        unique_x <- length(unique(coords$x))
        unique_y <- length(unique(coords$y))
        
        # Calculate spacing between grid points
        x_spacing <- if (unique_x > 1) x_range / (unique_x - 1) else 1
        y_spacing <- if (unique_y > 1) y_range / (unique_y - 1) else 1
        
        # Use smaller spacing dimension for square dice
        min_spacing <- min(x_spacing, y_spacing)
        
        # Apply conservative scaling to ensure dice don't overlap
        # Use 50% of available space to ensure clear boundaries and prevent plot overflow
        scale_factor <- 0.5
        
        # Scale dice size to use appropriate portion of available space
        dice_size <- min_spacing * scale_factor
        
        # Ensure reasonable bounds - minimum size for visibility, maximum for boundaries
        dice_size <- max(0.1, min(dice_size, 0.5))
      }
    }
    
    # Set default dot size if not provided
    if (is.null(dot_size)) {
      dot_size <- dice_size * 3.0  # Proportional dot size that fits within dice
    }
    
    # If category_positions not provided, auto-detect from data
    if (is.null(category_positions)) {
      all_categories <- unique(unlist(strsplit(as.character(coords$categories), ",")))
      all_categories <- trimws(all_categories[!is.na(all_categories)])
      category_positions <- setNames(1:min(6, length(all_categories)), all_categories)
    }
    
    # Create grobs for each dice
    grobs <- lapply(seq_len(nrow(coords)), function(i) {
      row <- coords[i, ]
      
      # Parse categories for this observation
      if (is.na(row$categories) || row$categories == "") {
        present_categories <- character(0)
      } else {
        present_categories <- trimws(strsplit(as.character(row$categories), ",")[[1]])
      }
      
      # Create dice background
      dice_rect <- grid::rectGrob(
        x = row$x, y = row$y,
        width = grid::unit(dice_size, "native"),
        height = grid::unit(dice_size, "native"),
        gp = grid::gpar(
          fill = dice_color,
          alpha = dice_alpha,
          col = "black",
          lwd = 0.5
        )
      )
      
      # Create dots only for present categories
      if (length(present_categories) > 0) {
        # Filter to categories that have defined positions
        valid_categories <- present_categories[present_categories %in% names(category_positions)]
        
        if (length(valid_categories) > 0) {
          # Get positions for valid categories
          positions_to_show <- category_positions[valid_categories]
          
          # Get dice positions for these specific positions
          dot_positions <- data.frame(
            x_offset = numeric(0),
            y_offset = numeric(0)
          )
          
          # Get the standard dice positions
          all_positions <- create_dice_positions(6)  # Get all 6 positions
          
          # Select only the positions we need
          for (pos in positions_to_show) {
            dot_positions <- rbind(dot_positions, all_positions[pos, ])
          }
          
          # Create dots
          if (nrow(dot_positions) > 0) {
            # Scale positions with better spacing - ensure dots stay within dice boundaries
            # Use 30% of dice size for dot positioning to ensure they don't exceed boundaries
            dot_positions$x_offset <- dot_positions$x_offset * dice_size * 0.3
            dot_positions$y_offset <- dot_positions$y_offset * dice_size * 0.3
            
            dot_x <- row$x + dot_positions$x_offset
            dot_y <- row$y + dot_positions$y_offset
            
            dots <- grid::pointsGrob(
              x = dot_x, y = dot_y,
              pch = 19,
              gp = grid::gpar(
                col = if (is.null(row$colour)) "black" else row$colour,
                alpha = if (is.null(row$alpha)) 1 else row$alpha,
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
                  alpha = if (is.null(row$alpha)) 1 else row$alpha,
                  fontsize = dot_size + 0.5,
                  lwd = dot_stroke
                )
              )
              
              return(grid::grobTree(dice_rect, dots, dot_outlines))
            } else {
              return(grid::grobTree(dice_rect, dots))
            }
          }
        }
      }
      
      # Return just the dice background if no valid categories
      return(dice_rect)
    })
    
    # Combine all grobs
    do.call(grid::grobTree, grobs)
  }
)