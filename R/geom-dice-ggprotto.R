#' @rdname geom_dice
#' @format NULL
#' @usage NULL
#' @export
GeomDice <- ggplot2::ggproto("GeomDice", ggplot2::Geom,
                             
                             extra_aes = c("dots"),
                             required_aes = c("x", "y", "dots"),
                             
                             default_aes = ggplot2::aes(
                               linewidth = 0.1,
                               linetype = 1,
                               size = 3,
                               shape = 19,
                               fill = NA,
                               dots = NA,
                               colour = "black",
                               alpha = 0.8,
                               stroke = 1,
                               width = 0.5,
                               height = 0.5,
                               show.legend = TRUE
                             ),
                             
                             extra_params = c("na.rm", "ndots", "x_length", "y_length"),
                             
                             setup_data = function(data, params, ...) {
                               data$na.rm <- data$na.rm %||% params$na.rm
                               data
                             },
                             
                             draw_key = ggplot2::draw_key_point,
                             
                             draw_panel = function(data, panel_params, coord, params, ...) {
                               data$x <- as.numeric(data$x)
                               data$y <- as.numeric(data$y)
                               
                               tile_coords <- dplyr::distinct(data, x, y)
                               
                               offsets <- make_offsets(
                                 n = length(unique(data$dots)),
                                 width = unique(data$width)[1],
                                 height = unique(data$height)[1]
                               )
                               
                               offsets_mat <- offsets |>
                                 tibble::remove_rownames() |>
                                 tibble::column_to_rownames("key") |>
                                 as.matrix()
                               
                               point_coords_list <- lapply(seq_len(nrow(tile_coords)), function(i) {
                                 coords <- sweep(offsets_mat, 2, as.matrix(tile_coords)[i, ], FUN = "+")
                                 df <- as.data.frame(coords)
                                 df$x_coord <- tile_coords$x[i]
                                 df$y_coord <- tile_coords$y[i]
                                 df$key <- unique(data$dots)
                                 df
                               })
                               
                               point_coords <- dplyr::bind_rows(point_coords_list)
                               point_coords$id <- paste0(point_coords$key, point_coords$x_coord, point_coords$y_coord)
                               
                               data$point_id <- paste0(data$dots, data$x, data$y)
                               point_df <- dplyr::filter(point_coords, id %in% data$point_id)
                               
                               point_df$size <- data$size
                               point_df$shape <- data$shape
                               point_df$stroke <- data$stroke
                               point_df$alpha <- data$alpha
                               point_df$colour <- data$fill
                               point_df$fill <- data$fill
                               point_df$PANEL <- 1
                               point_df$group <- data$group
                               
                               bad_mask <- is.infinite(point_df$size) | point_df$size <= 0
                               if (any(bad_mask, na.rm = TRUE)) {
                                 warning(sum(bad_mask, na.rm = TRUE),
                                         " zero(s)/negative(s)/infinitive(s) detected in dot size... converted to NA.")
                                 point_df$size[bad_mask] <- NA
                               }
                               
                               if (isTRUE(unique(data$na.rm))) {
                                 na_mask <- is.na(point_df$size)
                                 if (any(na_mask)) {
                                   warning(sum(na_mask), " NA's detected in dot size. Removing them...")
                                   point_df <- dplyr::filter(point_df, !is.na(size))
                                 }
                               }
                               
                               tile_df <- tile_coords
                               tile_df$width <- unique(data$width)
                               tile_df$height <- unique(data$height)
                               tile_df$alpha <- unique(data$alpha)
                               tile_df$colour <- "#000000"
                               tile_df$fill <- "#FFFFFF"
                               tile_df$PANEL <- 1
                               tile_df$group <- seq_len(nrow(tile_coords))
                               tile_df$linewidth <- unique(data$linewidth)
                               
                               tile_df <- ggplot2::GeomTile$setup_data(tile_df, params)
                               
                               grid::gList(
                                 ggplot2::GeomTile$draw_panel(tile_df, panel_params, coord, ...),
                                 ggplot2::GeomPoint$draw_panel(point_df, panel_params, coord, ...)
                               )
                             }
)
