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
                               height = 0.5
                             ),
                             
                             extra_params = c("na.rm", "ndots", "x_length", "y_length"),
                             
                             setup_data = function(data, params, ...) {
                               data$na.rm <- data$na.rm %||% params$na.rm

                               # Critical fix: Save original dots values before scale processing
                               # At this point data$dots is still the original factor or character
                               data$dots_original <- data$dots
                               if (is.factor(data$dots)) {
                                 attr(data, "dots_levels") <- levels(data$dots)
                               }
                               data
                             },
                             
                             draw_key = function(data, params, size) {
                               # Always use filled circle (shape 21) to properly display fill colors in legend
                               # This ensures that when fill is mapped to a discrete variable,
                               # the legend shows the fill colors correctly
                               data$shape <- 21
                               # Set stroke color to match fill for clean appearance
                               if (!is.null(data$fill) && !is.na(data$fill)) {
                                 data$colour <- data$fill
                               }
                               ggplot2::draw_key_point(data, params, size)
                             },
                             
                             draw_panel = function(data, panel_params, coord, params, ...) {
                               data$x <- as.numeric(data$x)
                               data$y <- as.numeric(data$y)
                               
                               tile_coords <- dplyr::distinct(data, x, y)
                               dots_levels <- attr(data, "dots_levels")

                               if (!is.null(dots_levels)) {
                                 present_levels <- dots_levels[dots_levels %in% as.character(data$dots_original)]
                               } else {
                                 present_levels <- as.character(unique(data$dots_original))
                               }

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
                                 df$key <- present_levels
                                 df
                               })
                               
                               point_coords <- dplyr::bind_rows(point_coords_list)
                               point_coords$id <- paste0(point_coords$key, point_coords$x_coord, point_coords$y_coord)
                               
                               # Use original dots_original to create point_id
                               data$point_id <- paste0(data$dots_original, data$x, data$y)
                               point_df <- dplyr::filter(point_coords, id %in% data$point_id)
                               
                               # Precise attribute matching
                               attr_lookup <- data[!duplicated(data$point_id), ]
                               match_idx <- match(point_df$id, attr_lookup$point_id)
                               
                               point_df$size <- attr_lookup$size[match_idx]
                               point_df$shape <- attr_lookup$shape[match_idx]
                               point_df$stroke <- attr_lookup$stroke[match_idx]
                               point_df$alpha <- attr_lookup$alpha[match_idx]
                               point_df$fill <- attr_lookup$fill[match_idx]
                               point_df$colour <- attr_lookup$fill[match_idx]
                               point_df$group <- attr_lookup$group[match_idx]
                               point_df$PANEL <- 1
                               
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
