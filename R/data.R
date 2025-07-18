#' Sample Dice Data
#'
#' A sample dataset for demonstrating the ggdiceplot package functionality.
#' Contains x, y coordinates, dice values (z), categories, and additional values.
#'
#' @format A data frame with 12 rows and 5 variables:
#' \describe{
#'   \item{x}{x-axis position (1-4)}
#'   \item{y}{y-axis position (1-3)}
#'   \item{z}{dice value, number of dots to show (1-6)}
#'   \item{category}{categorical variable with levels "Type A", "Type B", "Type C"}
#'   \item{value}{random numeric value (1-100)}
#' }
#'
#' @examples
#' library(ggplot2)
#' data(sample_dice_data)
#' 
#' # Basic dice plot
#' ggplot(sample_dice_data, aes(x = x, y = y, z = z)) +
#'   geom_dice()
#' 
#' # Colored dice plot
#' ggplot(sample_dice_data, aes(x = x, y = y, z = z, color = category)) +
#'   geom_dice()
#'
"sample_dice_data"