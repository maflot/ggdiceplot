#' Large Sample Dice Dataset
#'
#' @description
#' `sample_dice_large` is a larger toy dataset with 60 taxa, designed to test
#' `geom_dice()` at higher density. It simulates log2 fold-change and q-values
#' with approximately 50\% missing data.
#'
#' @format A data frame with 480 rows and 6 columns:
#' \describe{
#'   \item{taxon}{Character. Taxon name (Taxon_1 through Taxon_60).}
#'   \item{disease}{Character. Disease condition (Caries, Periodontitis, Healthy, Gingivitis).}
#'   \item{specimen}{Character. Specimen type (Saliva, Plaque).}
#'   \item{replicate}{Integer. Replicate identifier.}
#'   \item{lfc}{Numeric. Simulated log2 fold change; may contain NA.}
#'   \item{q}{Numeric. Simulated adjusted p-value; may contain NA.}
#' }
#'
#' @usage data(sample_dice_large)
#' @keywords datasets
#' @examples
#' data(sample_dice_large)
#' head(sample_dice_large)
"sample_dice_large"
