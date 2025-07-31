# Define `%||%` safely
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' A ggplot2 layer for creating dice representations
#'
#' @importFrom legendry guide_legend_base
#' @description
#' `geom_dice()` creates a layer that displays dice-like symbols where each dot
#' represents a specific category. Dots are only shown when that categorical
#' variable is present in the data, allowing compact visual encoding.
#'
#' @param mapping Set of aesthetic mappings created by `aes()`.
#'   Must include:
#'   - `x`, `y`: Position of the dice.
#'   - `dots`: The categories present (usually as a string or factor).
#' @param data A data frame. If `NULL`, inherits from the plot.
#' @param stat The statistical transformation to use.
#' @param position Position adjustment.
#' @param na.rm Remove missing values if `TRUE`.
#' @param show.legend Whether to include in legend.
#' @param inherit.aes If `FALSE`, overrides the default aesthetics.
#' @param ndots Integer (1–6): number of positions shown per dice.
#' @param x_length, x_length Numeric: used for aspect ratio.
#' @param y_length, y_length Numeric: used for aspect ratio.
#' @param ... Additional arguments passed to `layer()`.
#'
#' @return A `ggplot2` layer that draws dice with categorical dot encodings.
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' df <- data.frame(
#'   x = 1:3,
#'   y = 1,
#'   dots = c("A,B", "A,C,E", "F")
#' )
#'
#' ggplot(df, aes(x, y, dots = dots)) +
#'   geom_dice(ndots = 6, x_length = 3, y_length = 1)
geom_dice <- function(mapping = NULL, data = NULL,
                      stat = "identity", position = "identity",
                      ndots = NULL, x_length = NULL, y_length = NULL,
                      na.rm = FALSE, show.legend = TRUE, inherit.aes = TRUE, ...) {
  
  list(
    ggplot2::layer(
      geom = GeomDice,
      mapping = mapping,
      data = data,
      stat = stat,
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = list(
        na.rm = na.rm,
        ndots = ndots,
        x_length = x_length,
        y_length = y_length
      )
    ),
    theme_dice(x_length = x_length, y_length = y_length),
    ggplot2::guides(dots = guide_legend_base(
      design = create_dice_positions(n_dots = ndots),
      theme = ggplot2::theme(
        legend.background = ggplot2::element_rect(
          fill = "white", colour = "grey", linewidth = 0.5),
        legend.key = ggplot2::element_rect(fill = "white"),
        legend.key.spacing.x = grid::unit(0.1, "cm"),
        legend.key.spacing.y = grid::unit(0.5, "cm"),
        legend.text = ggplot2::element_text(hjust = 0.5),
        legend.text.position = "bottom",
        legend.title = ggplot2::element_text(hjust = 0.4)
      )
    ))
  )
}
