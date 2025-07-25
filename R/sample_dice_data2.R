#' Sample Dice Dataset 2 for Visualization with Replicates
#'
#' @description
#' `sample_dice_data2` is a toy dataset designed to demonstrate the usage of `geom_dice()` 
#' in more advanced scenarios. It simulates log2 fold-change (LFC) and adjusted p-values 
#' (q-values) for common oral taxa across disease conditions and specimen types, 
#' including replicates and missing values.
#'
#' This version filters for `replicate == 1` but retains structure from a more complex
#' design, making it useful for testing visualizations that account for filtering,
#' grouping, or handling of `NA` values.
#'
#' @format A data frame with 48 rows and 6 columns:
#' \describe{
#'   \item{taxon}{Character. Microbial taxon name.}
#'   \item{disease}{Character. Disease condition (e.g., Caries, Periodontitis).}
#'   \item{specimen}{Character. Body site specimen (e.g., Saliva, Plaque).}
#'   \item{replicate}{Integer. Experimental replicate ID. Only replicate 1 is included here.}
#'   \item{lfc}{Numeric. Simulated log2 fold change; may contain NA.}
#'   \item{q}{Numeric. Simulated adjusted p-value (q-value); may contain NA.}
#' }
#'
#' @usage data(sample_dice_data2)
#' @keywords datasets
#' @examples
#' data(sample_dice_data2)
#' head(sample_dice_data2)
"sample_dice_data2"
