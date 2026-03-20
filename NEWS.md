# ggdiceplot 1.1.0

## New features

* **`pip_scale` parameter** — New argument to `geom_dice()` that controls pip
  diameter as a fraction (0–1) of the maximum available space inside each die
  face. When `size` is constant (not mapped), all pips are drawn at
  `pip_scale × max_diameter`. When `size` is mapped to a variable, pips scale
  between 25% and `pip_scale` of the maximum pip diameter. Set `pip_scale = NULL`
  to disable auto-scaling and use the raw `size` aesthetic (legacy behaviour).
  Default: `0.75`.

* **Deferred rendering via `DiceGrob`** — Pip sizing is now calculated at
  grid draw time rather than ggplot build time, so pip diameters adapt
  correctly to the final figure dimensions.

* **Scale expansion for edge tiles** — `setup_data` now exposes
  `xmin`/`xmax`/`ymin`/`ymax` so ggplot2 trains axis scales to include the
  full tile area, preventing clipping of border tiles.

* **New datasets** — `sample_dice_large` (480 rows, 60 taxa) and
  `sample_dice_miRNA` (~90 rows, miRNA dysregulation) are included for
  demonstrating high-density and categorical-fill use cases.

## Breaking changes

* **Minimum R version raised to 4.1.0** (was 4.0.0). R 4.1 is required for
  the native pipe operator (`|>`) used internally.

* **`tibble` is now a hard dependency** — added to `Imports` for
  `column_to_rownames()` / `remove_rownames()`.

* **`draw_panel` signature changed** — The method now takes explicit named
  arguments (`na.rm`, `ndots`, `x_length`, `y_length`, `pip_scale`) instead of
  `params, ...`. Code that subclassed `GeomDice` or called `draw_panel`
  directly will need updating.

* **Sample datasets restructured**:
    - `sample_dice_data1`: 48 rows → 160 rows (8 taxa × 4 diseases × 5
      specimens). Columns are the same but `lfc` and `q` may now contain `NA`.
    - `sample_dice_data2`: 48 rows → 160 rows; the `replicate` column has been
      removed. Column count changed from 6 to 5.

* **Legend key for unmapped fill** — When `fill` is not mapped, legend keys now
  draw a solid black dot instead of an empty circle, making spatial/dots-only
  legends more readable.

## Minor changes

* `LICENSE` switched to CRAN-standard two-line format (`YEAR` / `COPYRIGHT
  HOLDER`).
* `.Rbuildignore` added to exclude pixi, demo output, test scripts, and other
  non-package files from the R CMD build tarball.
* `data-raw/` directory created; dataset-generation scripts moved there from
  `data/`.
* `pixi.toml` / `pixi.lock` added for reproducible environment management.
* Demo scripts (`create_demo_plots.R`, `test_simple_dice.R`) rewritten to
  exercise the new `pip_scale` feature and run from the project root.
* README updated with new examples, a parameter table, and the published
  Bioinformatics citation.
* RoxygenNote bumped to 7.3.3.
