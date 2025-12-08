# Fix for Missing Fill Legend in geom_dice()

## Problem
When using `geom_dice()` with a discrete variable mapped to `fill` and a manual fill scale, the legend for fill was not shown. Only the dots legend (for the dice positions) appeared.

## Root Cause
The issue was in the `draw_key` function of `GeomDice`. The original implementation used `ggplot2::draw_key_point` which only renders points with the `colour` aesthetic, not `fill`. Even though the fill aesthetic was being used to color the dice dots (by copying it to colour in the draw_panel function), the legend keys were not displaying the fill colors because:

1. `draw_key_point` with the default shape (19 - solid circle) only uses the `colour` aesthetic
2. To display fill colors, you need to use a filled shape (21-25) which has both a fill and a border

## Solution
Modified the `draw_key` function in `R/geom-dice-ggprotto.R` to:

1. Always use shape 21 (filled circle) for legend keys
2. Set the border colour to match the fill colour for a clean appearance
3. Properly handle cases where fill is not mapped (NULL, NA, or "NA" string)

This ensures that when fill is mapped to a discrete variable (e.g., "Up", "Down", "Unchanged"), the legend displays colored circles showing each category's color.

## Changes Made

### R/geom-dice-ggprotto.R

1. **Removed `show.legend = TRUE` from `default_aes`** (line 22)
   - This was incorrect as `show.legend` is a layer parameter, not an aesthetic
   - Having it in default_aes could cause confusion

2. **Replaced simple `draw_key` assignment with custom function** (lines 38-47)
   - Old: `draw_key = ggplot2::draw_key_point,`
   - New: Custom function that:
     - Sets shape to 21 (filled circle)
     - Matches border colour to fill colour
     - Handles edge cases (NULL, NA, "NA" string)
     - Calls `ggplot2::draw_key_point` to render

## Testing

To test this fix, run `test_fill_legend_fix.R`:

```R
library(ggplot2)
library(ggdiceplot)

# Create test data with discrete fill categories
df_dice <- data.frame(
  x = rep(1:3, each = 3),
  y = rep(1:3, times = 3),
  organ = rep(c("Lung", "Liver", "Brain"), 3),
  direction = rep(c("Up", "Down", "Unchanged"), each = 3)
)

# Plot with discrete fill mapping
ggplot(df_dice, aes(x = x, y = y)) +
  geom_dice(
    aes(dots = organ, fill = direction),
    ndots = 3,
    x_length = 3,
    y_length = 3
  ) +
  scale_fill_manual(
    values = c(Down = "blue", Unchanged = "grey", Up = "red"),
    name = "Regulation"
  )
```

**Expected Result**: Two legends appear:
1. "organ" legend showing the dice dot positions
2. "Regulation" legend showing colored circles for Up, Down, and Unchanged

## Compatibility

This fix maintains backward compatibility:
- Existing code using continuous fill scales (gradients) continues to work
- Existing code not using fill aesthetic continues to work
- The only change is that discrete fill scales now properly show a legend

## References

- Issue: "Missing fill legend when using discrete color coding in geom_dice()"
- Related ggplot2 documentation:
  - `?ggplot2::draw_key_point`
  - Shape types: https://ggplot2.tidyverse.org/reference/aes_linetype_size_shape.html
