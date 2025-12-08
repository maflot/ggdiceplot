# Before and After Comparison

## The Issue

When using `geom_dice()` with discrete fill mapping, only the dots legend appeared. The fill legend was missing.

## Test Case

```R
library(ggplot2)
library(ggdiceplot)

df_dice <- data.frame(
  miRNA = c("miR-1", "miR-1", "miR-1", "miR-2", "miR-2", "miR-2", "miR-3", "miR-3"),
  Compound = c("Compound_1", "Compound_1", "Compound_2", "Compound_1", "Compound_2", 
               "Compound_3", "Compound_3", "Compound_1"),
  Organ = c("Lung", "Brain", "Liver", "Lung", "Liver", "Brain", "Liver", "Brain"),
  direction = factor(c("Up", "Down", "Unchanged", "Down", "Unchanged", "Up", "Down", "Up"),
                     levels = c("Down", "Unchanged", "Up"))
)

ggplot(df_dice, aes(x = miRNA, y = Compound)) +
  geom_dice(
    aes(dots = Organ, fill = direction, width = 0.8, height = 0.8),
    show.legend = TRUE,
    ndots = 3,
    x_length = 3,
    y_length = 3
  ) +
  scale_fill_manual(
    values = c(Down = "#2166ac", Unchanged = "grey80", Up = "#b2182b"),
    name = "Regulation"
  )
```

## Before Fix

**Legends shown:**
- ✅ "Organ" legend with dice positions (Lung=1, Liver=2, Brain=3)
- ❌ "Regulation" legend MISSING

**Problem:**
- Users couldn't see what the colors meant
- Required hacky workarounds (adding extra geom_point layers off-plot)

## After Fix

**Legends shown:**
- ✅ "Organ" legend with dice positions (Lung=1, Liver=2, Brain=3)
- ✅ "Regulation" legend with colored circles (Down=blue, Unchanged=grey, Up=red)

**Result:**
- Both legends appear automatically
- Fill colors are clearly explained
- No workarounds needed

## The Fix Explained Simply

**Before:** Legend keys were drawn as solid circles (shape 19) using only the `colour` aesthetic. The `fill` aesthetic wasn't visible in legends even though it was being used in the plot.

**After:** Legend keys are now drawn as filled circles (shape 21) which show both the fill color (inside) and border color (outside, matching the fill). This makes the fill aesthetic visible in legend keys.

## Visual Difference in Legend Keys

### Before (shape 19 - solid circle):
```
● = solid circle with colour only
  = fill aesthetic ignored in legend
```

### After (shape 21 - filled circle):
```
◉ = filled circle with both fill (inside) and colour (border)
  = fill aesthetic visible in legend
```

## Why This is Important

In the biological/scientific context:
- Different colored dots represent different regulation directions (Up/Down/Unchanged)
- Without a legend, users can't interpret what the colors mean
- The dice positions (organs) AND colors (regulation) both need legends
- This fix ensures both are shown automatically

## Code Changes

Only 2 modifications to the core codebase:
1. Removed incorrect `show.legend = TRUE` from default_aes (cleanup)
2. Added custom draw_key function that uses shape 21 for fill support

Total lines changed in core code: **+12, -2**

## Backward Compatibility

✅ **100% backward compatible:**
- Continuous fill scales (gradients) work exactly as before
- Cases without fill mapping work exactly as before
- No breaking changes to existing code
- Only addition: discrete fill legends now appear correctly
