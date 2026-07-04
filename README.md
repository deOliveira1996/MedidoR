# MedidoR: Aerial Photogrammetry Analysis Tool

<img src="man/figures/logo.png" align="right" width="83"/>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`MedidoR` is an R package developed to optimize drone-based aerial photogrammetry for marine megafauna (eg., whales, dolphins, dugongs, and sharks). It provides interactive Shiny Graphical User Interfaces (GUIs) that seamlessly bridge the gap between empirical scale calibration modeling and automated morphometric body segmentation.

## Key Features

- **Integrated Scale Calibration:** Build linear regression models from reference flights over objects of known sizes to automatically correct drone barometric/altitude biases.
- **Statistical Validation:** Real-time generation of model diagnostic plots (Residuals vs Fitted, Q-Q Plot, Homogeneity of Variance) and accuracy metrics ($R^2$, RMSE, MAE).
- **Proportional Body Segmentation:** Automatically extracts body widths at 5% or 10% vertical intervals along the centerline for precise Body Condition Index (BCI) analysis.
- **Free Measurement Mode:** Flexible pixel-to-meter extraction for specific landmarks, body injuries, dorsal fins, or fluke widths.

## Installation

You can install the development version of `MedidoR` from GitHub with:

``` r
# Install devtools if not already installed
if (!require("devtools")) install.packages("devtools")

# Install MedidoR
devtools::install_github("deOliveira1996/MedidoR")

OR

# Install devtools if not already installed
if (!require("pak")) install.packages("pak")

# Install MedidoR
pak::pak("deOliveira1996/MedidoR")
```

## Usage

Launching the Application To start the MedidoR Shiny application:

``` r
library(MedidoR)

calib_gui() # Calibration interface

medidor_GUI() # Morphometrics interface
```

## Citation
If you use MedidoR in your research, please cite it as:

de Oliveira, L. L. (2025). MedidoR: Precision Aerial Photogrammetry for Marine Megafauna Research (1.1.0). Zenodo. https://doi.org/10.5281/zenodo.15865770

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Contact
For questions or support, please contact:

Lucas de Oliveira - oceano2014lucas@gmail.com

GitHub issues: https://github.com/deOliveira1996/MedidoR/issues
