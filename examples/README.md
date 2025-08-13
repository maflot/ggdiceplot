# ggdiceplot Examples

This directory contains examples showing how to use the `ggdiceplot` package for creating dice-based visualizations.

## Examples

### 1. ZEBRA Domino Plot (`zebra_domino_example.R`)
Recreates the legacy ZEBRA differential expression analysis using the new `geom_dice()` function.

**Features:**
- Gene expression data across cell types
- Multiple disease contrasts (MS-CT, AD-CT, ASD-CT, FTD-CT, HD-CT)
- Color encoding for log fold change
- Size encoding for statistical significance (FDR)
- 5-dot dice pattern for contrasts

**Generated files:**
- `ZEBRA_domino_example.pdf`
- `ZEBRA_domino_example.png`
- `ZEBRA_domino_example_custom_labels.png`

### 2. Spatial Dice Plot (`spatial_dice_example.R`)
Geographic visualization showing distances from Saarland cities to neighboring regions.

**Features:**
- Spatial coordinates (longitude/latitude)
- 4-dot dice pattern for regions (France, Switzerland, Luxembourg, Rheinland-Pfalz)
- Log-scaled distance encoding
- Integration with `sf` spatial data
- City labels and geographic context

**Generated files:**
- `spatial_dice_example.png`
- `spatial_dice_example.pdf`

### 3. PNAS-Style Gene Expression (`pnas_style_example.R`)
Comprehensive gene expression analysis across cell types and demographic groups.

**Features:**
- 25 top immune-related genes
- 5 cell types (NK, T Cell, B Cell, Dendritic Cell, Monocyte)
- 4-dot dice pattern for demographics (Old/Young × Male/Female)
- Expression level and significance encoding
- Focused inflammatory gene subset

**Generated files:**
- `pnas_style_example.png`
- `pnas_style_example.pdf`
- `pnas_inflammatory_subset.png`

## Common Features

All examples demonstrate:
- Custom legend styling with `legend.key = element_blank()`
- Proper data structure with `tidyr::complete()` for missing combinations
- Color gradient scaling with `scale_fill_gradient2()`
- Size scaling for significance values
- Theme customization for publication-ready plots

## Usage

Each example script can be run independently:

```bash
# Run from the main package directory
Rscript examples/zebra_domino_example.R
Rscript examples/spatial_dice_example.R  
Rscript examples/pnas_style_example.R
```

## Dependencies

The examples require:
- Base R packages: `ggplot2`, `dplyr`, `tidyr`, `grid`, `scales`
- `legendry` package for custom legend guides
- Additional packages per example:
  - Spatial: `sf`, `rnaturalearth`
  - ZEBRA: data provided in `legacy examples/data/`

## Data Structure

All examples follow the pattern expected by `geom_dice()`:
- One row per x/y/dots combination
- Missing combinations filled with NA values
- Factors properly leveled for consistent ordering
- Appropriate `ndots` parameter (1-6) matching unique dot categories

## Key Parameters

- `ndots`: Number of dice positions (1-6), must match unique categories in `dots` aesthetic
- `x_length`, `y_length`: Grid dimensions for aspect ratio calculation
- `width`, `height`: Dice face dimensions
- `show.legend`: Enable/disable custom dice legend guide