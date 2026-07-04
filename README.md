
# MedidoR: Aerial Photogrammetry Analysis Tool

<img src="man/figures/logo.png" align="right" width="120"/>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![R-CMD-check](https://github.com/deOliveira1996/MedidoR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/deOliveira1996/MedidoR/actions/workflows/R-CMD-check.yaml)

## Overview

MedidoR is an R package designed to assist in the collection and analysis of morphometric measurements from drone-collected images of marine animals, particularly marine mammals. The package implements aerial photogrammetry techniques using scale calibration objects to estimate accurate measurements from images.

Key features: - Interactive Shiny application for measurement collection - Calibration tools for converting pixel measurements to real-world dimensions - Data management and visualization tools - Support for both 5% and 10% segment interval analyses - Interface to collect scale calibration measurements

## Installation

You can install the development version of MedidoR from GitHub:

``` r
# Install devtools if not already installed
if (!require("devtools")) install.packages("devtools")

# Install MedidoR
devtools::install_github("deOliveira1996/MedidoR")

OR

if (!require("pak")) install.packages("pak")

# Install MedidoR
pak::pak("deOliveira1996/MedidoR")
```

## Usage

Launching the Application To start the MedidoR Shiny application:

``` r
library(MedidoR)
medidor_GUI()
```

Basic Workflow Set up your working directory using the interface

Create or import a measurement data frame

Load an image of your subject

Crop the image to the area of interest

Take measurements:

Click to mark body length points

Click along perpendicular lines to measure widths

Measure fluke width

Save measurements to your data frame

Apply calibration using known scale objects

Export your data for further analysis

Documentation For detailed documentation of all functions, see:

``` r
?medidor_GUI
```
# NEW FEATURE: The calib_gui() function is now running !!

## Usage

### Launching the Application
To start the calibration GUI:

```r
library(MedidoR)
calib_GUI()
```

Basic Workflow
Set working directory using the interface

Create or import a calibration data frame

Load an image containing your scale object

Crop the image to focus on the scale object

Take measurements:

Click on both ends of your known-length scale object

The measured pixel length will be calculated automatically

Enter metadata:

Drone/camera specifications

Flight parameters (altitude, etc.)

Actual length of the scale object

Save measurements to your calibration data frame

Repeat for multiple images/angles if needed

Export your calibration data for photogrammetric software

#Documentation

This GUI provides an interactive interface for:

Measuring scale objects in aerial imagery

Storing camera/drone parameters

Calculating ground sampling distances

Creating calibration reference tables

Key Features:
Visual measurement of scale objects

Metadata management for photogrammetry

Data export to standard formats (CSV, Excel)

Support for multiple calibration objects

For advanced usage and parameters, see the function help:

```r
?calib_GUI
```

Package vignettes (coming soon) will provide comprehensive tutorials and use cases.

Example Data The package includes example data for testing and demonstration purposes. To access example files:

``` r
# Get path to example image
system.file("extdata", "example_whale.png", package = "MedidoR")

# Get path to example calibration data
system.file("extdata", "calib.xlsx", package = "MedidoR")
```

## Contributing

We welcome contributions! Please follow these steps:

Fork the repository

Create your feature branch (git checkout -b feature/yourfeature)

Commit your changes (git commit -am 'Add some feature')

Push to the branch (git push origin feature/yourfeature)

Create a new Pull Request

## Citation

If you use MedidoR in your research, please cite it as:

*de Oliveira, L. L. (2025). MedidoR (1.1.0). Zenodo. <https://doi.org/10.5281/zenodo.15865770>*

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or support, please contact:

Lucas de Oliveira - [oceano2014lucas\@gmail.com](mailto:oceano2014lucas@gmail.com)

GitHub issues: <https://github.com/deOliveira1996/MeDiDOR/issues>
