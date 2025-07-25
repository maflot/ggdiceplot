#' ggdiceplot: Dice Plot Visualization for ggplot2
#'
#' @description
#' The **ggdiceplot** package provides extensions for `ggplot2` that allow 
#' visualizing data using dice-based dot patterns. The main feature is 
#' `geom_dice()`, which displays categorical variables using traditional dice 
#' face layouts (1 to 6 dots). This is especially helpful for multidimensional 
#' categorical data visualization.
#'
#' @section Main Functions:
#' \itemize{
#'   \item \code{\link{geom_dice}} — Display dice representations for data points
#'   \item \code{\link{create_dice_positions}} — Generate dice dot patterns for integers 1–6
#'   \item \code{\link{make_offsets}} — Internal function to calculate x/y offsets for dot placement
#' }
#'
#' @section Features:
#' \itemize{
#'   \item Seamless integration with ggplot2
#'   \item Traditional dice dot layouts
#'   \item Customizable appearance (size, color, transparency)
#'   \item Support for faceting and multiple aesthetics
#' }
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
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
## usethis namespace: end
NULL
