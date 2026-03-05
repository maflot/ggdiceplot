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

                             extra_params = c("na.rm", "ndots", "x_length", "y_length", "pip_fill"),
                             
                             setup_data = function(data, params, ...) {
                               data$na.rm <- data$na.rm %||% params$na.rm

                               # Critical fix: Save original dots values before scale processing
                               # At this point data$dots is still the original factor or character
                               data$dots_original <- data$dots
                               if (is.factor(data$dots)) {
                                 attr(data, "dots_levels") <- levels(data$dots)
                               }

                               # Expose tile extents so ggplot2 trains x/y scales to include the
                               # full tile area, preventing panel clipping of edge tiles.
                               # Note: default_aes values (width, height) are applied AFTER
                               # setup_data in ggplot2 >=3.5, so we must supply the fallback.
                               w <- data$width  %||% 0.5
                               h <- data$height %||% 0.5
                               data$xmin <- data$x - w / 2
                               data$xmax <- data$x + w / 2
                               data$ymin <- data$y - h / 2
                               data$ymax <- data$y + h / 2
                               data
                             },
                             
                             draw_key = function(data, params, size) {
                               data$shape <- 21
                               if (!is.null(data$fill) && !is.na(data$fill)) {
                                 # fill is mapped: match stroke to fill for a solid-coloured pip
                                 data$colour <- data$fill
                               } else {
                                 # fill is unmapped (spatial/dots-only legend): show solid black dot
                                 data$fill   <- "black"
                                 data$colour <- "black"
                               }
                               ggplot2::draw_key_point(data, params, size)
                             },
                             
                             draw_panel = function(data, panel_params, coord,
                                                      na.rm = FALSE, ndots = NULL,
                                                      x_length = NULL, y_length = NULL,
                                                      pip_fill = 0.75) {
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

                               if (isTRUE(na.rm)) {
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

                               tile_df <- ggplot2::GeomTile$setup_data(tile_df, list())

                               tile_width  <- unique(data$width)[1]
                               tile_height <- unique(data$height)[1]
                               min_half_tile <- min(tile_width / 2, tile_height / 2)

                               # Compute minimum inter-pip distance and maximum absolute offset.
                               if (nrow(offsets) > 1) {
                                 pos_mat        <- as.matrix(offsets[, c("x", "y")])
                                 dist_mat       <- as.matrix(dist(pos_mat))
                                 diag(dist_mat) <- Inf
                                 min_inter_pip  <- min(dist_mat)
                               } else {
                                 min_inter_pip  <- Inf
                               }
                               max_abs_offset <- if (nrow(offsets) > 0) max(pmax(abs(offsets$x), abs(offsets$y))) else 0

                               # Tight-packing scale factor: at s_tight, pip border clearance equals
                               # half the inter-pip distance (pips simultaneously touch each other
                               # and tile borders). s_tight = 1 when inter-pip is the binding constraint.
                               if (is.finite(min_inter_pip) && max_abs_offset > 0) {
                                 s_tight <- min(1.0, min_half_tile / (max_abs_offset + min_inter_pip / 2))
                               } else {
                                 s_tight <- 1.0
                               }

                               # Maximum pip radius at tight-packing positions (both constraints).
                               pip_radius_tight <- min(
                                 min_half_tile - max_abs_offset * s_tight,
                                 if (is.finite(min_inter_pip)) min_inter_pip * s_tight / 2 else min_half_tile
                               )

                               # Auto-scale pip size only when size is constant (not user-mapped).
                               auto_scale <- length(unique(data$size)) == 1

                               # Shift pip centers toward tile center proportionally to pip_fill,
                               # so larger pips fit without clipping at tile borders.
                               if (auto_scale && !is.null(pip_fill) && pip_fill > 0 && s_tight < 1) {
                                 offset_scale <- 1 - pip_fill * (1 - s_tight)
                                 point_df$x   <- point_df$x_coord + (point_df$x - point_df$x_coord) * offset_scale
                                 point_df$y   <- point_df$y_coord + (point_df$y - point_df$y_coord) * offset_scale
                               }

                               dice_grob(
                                 point_df       = point_df,
                                 tile_df        = tile_df,
                                 panel_params   = panel_params,
                                 coord          = coord,
                                 max_pip_radius = pip_radius_tight,
                                 tile_width     = tile_width,
                                 pip_fill       = pip_fill,
                                 auto_scale     = auto_scale
                               )
                             }
)

# ---------------------------------------------------------------------------
# DiceGrob: defers pip-size calculation to grid draw time so that we can
# convert data-unit distances to physical mm via the live panel viewport.
# ---------------------------------------------------------------------------

dice_grob <- function(point_df, tile_df, panel_params, coord,
                      max_pip_radius, tile_width, pip_fill, auto_scale) {
  grid::grob(
    point_df     = point_df,
    tile_df      = tile_df,
    panel_params = panel_params,
    coord        = coord,
    max_pip_radius = max_pip_radius,
    tile_width   = tile_width,
    pip_fill     = pip_fill,
    auto_scale   = auto_scale,
    cl = "DiceGrob"
  )
}

#' @importFrom grid drawDetails
#' @method drawDetails DiceGrob
drawDetails.DiceGrob <- function(x, recording) {
  point_df <- x$point_df

  if (x$auto_scale && !is.null(x$pip_fill)) {
    # Convert tile width from data units to mm using the live panel viewport.
    panel_w_mm <- grid::convertUnit(grid::unit(1, "npc"), "mm", valueOnly = TRUE)

    ref_df  <- data.frame(x = c(0, x$tile_width), y = c(0, 0), PANEL = 1L, group = 1L)
    ref_npc <- x$coord$transform(ref_df, x$panel_params)
    tile_w_mm <- abs(ref_npc$x[2] - ref_npc$x[1]) * panel_w_mm

    # pip diameter = 2 * max_pip_radius (in mm) * fill fraction
    # max_pip_radius already accounts for both inter-pip and border constraints.
    pip_size_mm <- 2 * (x$max_pip_radius / x$tile_width) * tile_w_mm * x$pip_fill

    if (is.finite(pip_size_mm) && pip_size_mm > 0) {
      point_df$size <- pip_size_mm
    }
  }

  # Drop NA-size rows: ggplot2 >=4.x gpar rejects mixed NA/non-NA fontsize.
  point_df <- point_df[!is.na(point_df$size), ]

  grid::grid.draw(ggplot2::GeomTile$draw_panel(x$tile_df, x$panel_params, x$coord))
  grid::grid.draw(ggplot2::GeomPoint$draw_panel(point_df, x$panel_params, x$coord))
}
