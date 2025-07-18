# ggdiceplot Demo Output

This directory contains demonstration plots and scripts for the ggdiceplot package.

## Generated Demo Plots

### Basic Functionality Demos
- `basic_dice_demo.png` - Basic dice plot showing category combinations
- `dense_grid_demo.png` - 6x6 dense grid with auto-scaled dice
- `sparse_grid_demo.png` - 3x3 sparse grid with larger dice
- `custom_sizing_demo.png` - Custom dice size example
- `boundary_validation_demo.png` - Strict boundary validation with red borders
- `dice_position_reference.png` - Reference showing dice positions 1-6

### Real-world Usage Examples
- `gene_expression_example.png` - Gene expression pathway analysis
- `survey_analysis_example.png` - Survey response analysis
- `clinical_trial_example.png` - Clinical trial symptom tracking
- `market_research_example.png` - Market research feature preferences

### Legacy Plots (from previous development)
- `comparison_tab20.png` - Color comparison using tab20 palette
- `comparison_viridis.png` - Color comparison using viridis palette
- `final_4x4_tab20.png` - Previous 4x4 example with tab20 colors
- `final_4x4_viridis.png` - Previous 4x4 example with viridis colors

## Demo Scripts

### `create_demo_plots.R`
Generates basic functionality demonstration plots:
- Basic dice plot
- Dense and sparse grid examples
- Custom sizing
- Boundary validation
- Dice position reference

### `usage_examples.R`
Generates real-world usage examples:
- Gene expression analysis
- Survey data visualization
- Clinical trial tracking
- Market research analysis

## Running the Scripts

To regenerate the demo plots:

```bash
# From the demo_output directory
Rscript create_demo_plots.R
Rscript usage_examples.R
```

## Package Features Demonstrated

1. **Automatic Dice Sizing**: Adapts to grid density
2. **Boundary Safety**: Dice stay within plot boundaries
3. **Category Mapping**: Flexible category-to-position mapping
4. **Multiple Use Cases**: Scientific, business, and survey applications
5. **Customization**: Manual size control and styling options