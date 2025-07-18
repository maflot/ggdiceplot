# ggdiceplot

A ggplot2 extension for creating dice plot visualizations, where each dice represents multiple categorical variables using the traditional dice dot patterns.

## Installation

```r
# Install from local directory
devtools::install_local("path/to/ggdiceplot")

# Or install dependencies manually
install.packages(c("ggplot2", "tibble"))
```

## Quick Start

```r
library(ggplot2)
library(ggdiceplot)

# Create sample data
data <- data.frame(
  x = rep(1:3, each = 3),
  y = rep(1:3, times = 3),
  categories = c("A", "A,B", "A,B,C", "B", "B,C", "C", "A,C", "A,B,C", "B,C")
)

# Define category positions on dice
category_positions <- c("A" = 1, "B" = 2, "C" = 3)

# Create dice plot
ggplot(data, aes(x = x, y = y, categories = categories)) +
  geom_dice(category_positions = category_positions) +
  theme_minimal()
```

## Features

- **Automatic Sizing**: Dice automatically scale based on grid density
- **Boundary Safety**: Dice stay within plot boundaries
- **Flexible Mapping**: Map any categories to dice positions 1-6
- **Multiple Applications**: Gene expression, survey data, clinical trials, market research
- **Customizable**: Control dice size, colors, and positioning

## Key Functions

- `geom_dice()`: Main geom for creating dice plots
- `create_dice_positions()`: Generate standard dice dot positions

## Demo Examples

See the `demo_output/` directory for:
- Basic functionality examples
- Real-world usage scenarios
- Boundary validation tests
- Custom sizing demonstrations

Run the demo scripts:
```bash
cd demo_output
Rscript create_demo_plots.R
Rscript usage_examples.R
```

## Package Structure

- `R/`: Core package functions
- `data/`: Sample datasets
- `demo_output/`: Example plots and scripts
- `inst/examples/`: Installation examples
- `man/`: Documentation files
- `tests/`: Unit tests
- `vignettes/`: Extended documentation

## Documentation

- Package functions: `help(package = "ggdiceplot")`
- Main function: `?geom_dice`
- Vignette: `vignette("introduction", package = "ggdiceplot")`

## Citation

If you use ggdiceplot in your research, please cite:

```
[Add citation information here]
```

## License

This package is licensed under [LICENSE](LICENSE).