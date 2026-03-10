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
#' @param x_length Numeric: number of x categories (used for aspect ratio).
#' @param y_length Numeric: number of y categories (used for aspect ratio).
#' @param pip_fill Numeric (0–1): controls pip diameter relative to the
#'   maximum available space. When `size` is constant (not mapped), all pips
#'   are drawn at `pip_fill` fraction of the die face. When `size` is mapped
#'   to a variable, pips scale between 0.25 (smallest value) and `pip_fill`
#'   (largest value) of the maximum pip diameter. Default is `0.75`. Set to
#'   `NULL` to disable auto-scaling and use the raw `size` aesthetic.
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
                      pip_fill = 0.75,
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
        y_length = y_length,
        pip_fill = pip_fill
      )
    ),
    theme_dice(x_length = x_length, y_length = y_length),
    ggplot2::coord_fixed(ratio = 1),
    ggplot2::guides(dots = guide_legend_base(
      design = create_dice_positions(n_dots = ndots),
      theme = ggplot2::theme(
        legend.background = ggplot2::element_rect(
          fill = "white", colour = "grey", linewidth = 0.5),
        legend.key = ggplot2::element_rect(fill = NA, colour = NA),
        legend.key.spacing.x = grid::unit(0.1, "cm"),
        legend.key.spacing.y = grid::unit(0.5, "cm"),
        legend.text = ggplot2::element_text(hjust = 0.5),
        legend.text.position = "bottom",
        legend.title = ggplot2::element_text(hjust = 0.4)
      )
    ))
  )
}
