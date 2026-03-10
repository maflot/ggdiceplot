#' Sample Dice Dataset 2 for Visualization
#'
#' @description
#' `sample_dice_data2` is a toy dataset designed to demonstrate `geom_dice()`
#' with multiple specimen types. It simulates log2 fold-change (LFC) and
#' adjusted p-values (q-values) for oral taxa across disease conditions and
#' specimen sites, with some missing values.
#'
#' @format A data frame with 160 rows and 5 columns:
#' \describe{
#'   \item{taxon}{Character. Microbial taxon name (8 taxa).}
#'   \item{disease}{Character. Disease condition (Caries, Periodontitis, Healthy, Gingivitis).}
#'   \item{specimen}{Character. Body site specimen (Saliva, Plaque, Tongue, Buccal, Gingival).}
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
