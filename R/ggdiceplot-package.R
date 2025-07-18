#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom dplyr %>%
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 Geom
#' @importFrom ggplot2 ggproto
#' @importFrom ggplot2 layer
#' @importFrom grid gpar
#' @importFrom grid grobTree
#' @importFrom grid nullGrob
#' @importFrom grid pointsGrob
#' @importFrom grid rectGrob
#' @importFrom grid unit
#' @importFrom rlang %||%
#' @importFrom tibble tibble
## usethis namespace: end
NULL

#' ggdiceplot: Dice Plot Visualization for ggplot2
#'
#' @description
#' The ggdiceplot package provides ggplot2 extensions for creating dice-based 
#' visualizations. The package includes geom_dice() for displaying data points 
#' as dice with 1-6 dots arranged in traditional dice patterns. This is 
#' particularly useful for visualizing categorical data with multiple dimensions 
#' in an intuitive and visually appealing way.
#'
#' @section Main Functions:
#' \itemize{
#'   \item \code{\link{geom_dice}}: Create dice representations in ggplot2
#'   \item \code{\link{create_dice_positions}}: Generate traditional dice dot positions
#' }
#'
#' @section Key Features:
#' \itemize{
#'   \item Native ggplot2 integration
#'   \item Customizable appearance (size, colors, transparency)
#'   \item Traditional dice patterns (1-6 dots)
#'   \item Support for multiple aesthetic mappings
#'   \item Works with faceting and other ggplot2 features
#' }
#'
#' @docType package
#' @name ggdiceplot-package
#' @aliases ggdiceplot
NULL