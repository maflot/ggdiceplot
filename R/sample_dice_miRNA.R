#' Sample miRNA Dice Dataset
#'
#' @description
#' `sample_dice_miRNA` is a toy dataset for demonstrating `geom_dice()` with
#' categorical fill mapping. It simulates miRNA dysregulation across compounds
#' and organs, with direction (Up, Down, Unchanged) as the fill variable.
#'
#' @format A data frame with approximately 90 rows and 5 columns:
#' \describe{
#'   \item{miRNA}{Factor. miRNA identifier (miR-1 through miR-5).}
#'   \item{Compound}{Factor. Treatment compound (Control, Compound_1 through Compound_4).}
#'   \item{Organ}{Factor. Target organ (Lung, Liver, Brain, Kidney).}
#'   \item{log2FC}{Numeric. Simulated log2 fold change.}
#'   \item{direction}{Factor. Regulation direction (Down, Unchanged, Up).}
#' }
#'
#' @usage data(sample_dice_miRNA)
#' @keywords datasets
#' @examples
#' data(sample_dice_miRNA)
#' head(sample_dice_miRNA)
"sample_dice_miRNA"
