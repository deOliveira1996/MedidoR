---
title: 'MedidoR: An R package for aerial photogrammetry of marine megafauna with integrated scale calibration'
tags:
  - R
  - photogrammetry
  - marine biology
  - drones
  - morphometrics
  - shiny
authors:
  - name: Lucas Lima de Oliveira
    orcid: 0000-0002-6814-6052
    affiliation: 1
affiliations:
 - name: Laboratory of Ecology and Conservation of Marine and Coastal Tetrapods, University of the Region of Joinville - UNIVILLE, São Francisco do Sul, Santa Catarina, Brazil
   index: 1
date: 30 June 2026
bibliography: paper.bib
---

# Summary

Estimating morphometric measurements plays a crucial role in understanding animal biology, ecology, and behavior. Over the last decade, drone-based photogrammetry has enabled non-invasive, systematic, and long-term data collection, allowing researchers to estimate the body size and physical condition of wild marine megafauna [@Burnett:2019; @deOliveira:2023a]. Aerial photogrammetry relies on calculating a Ground Sample Distance (GSD) to convert image pixels into metric units. While a drone's onboard barometer can provide altitude estimates to calculate GSD, these are often biased by environmental conditions and take-off height. `MedidoR` is an open-source R package with Shiny applications designed to optimize drone-based photogrammetry analyses by utilizing scale calibration models. `MedidoR` allows for independent calibration flights to build robust statistical models that correct altitude biases, increasing measurement accuracy without limiting field sampling opportunities or requiring hardware additions.

# Statement of Need

Accurate size and body condition estimation is a fundamental requirement for assessing population health and individual energetic status across various marine megafauna. The rapid advancement of Unoccupied Aircraft Systems (UAS, or drones) has facilitated non-invasive monitoring and photogrammetry for a wide range of surface-associated species, including dugongs, pinnipeds, sharks, rays, and marine turtles [@Hodgson:2020; @Dujon:2021]. Precise metric measurements require highly accurate altitude data to properly scale imagery. While laser altimeters have been developed to overcome the inaccuracies of onboard barometers [@Dawson:2017], they add significant cost, hardware complexity, and weight to the aircraft.

A proven, cost-effective alternative to hardware modifications is the use of scale calibration models derived from flights over objects of known dimensions [@Burnett:2019; @deOliveira:2023a]. Despite the establishment of this calibration methodology, the current software ecosystem for marine photogrammetry lacks integrated tools to streamline this specific workflow. General image processing programs like ImageJ [@Schneider:2012] require manual data transcription and lack automated body segmentation. Dedicated photogrammetry tools such as MorphoMetriX [@Torres:2020] and AragoJ [@Aleixo:2020] are highly effective for pixel extraction but rely on direct metadata input or in-frame scaling, leaving the integration of calibration models to post-processing software like CollatriX [@Bird:2020] or custom scripts.

`MedidoR` fills this software gap by offering a user-friendly graphical interface (GUI) that combines the generation of statistical calibration models with specialized routines for proportional body segmentation. It makes advanced, statistically-validated photogrammetry accessible to biologists without requiring extensive coding expertise, standardizing workflows for marine megafauna species where metric measurements are required.

# Implementation and Features

The `MedidoR` package is structured into two interconnected modules built on the Shiny framework, creating a continuous workflow from calibration to final measurement extraction:

1.  **MedidoR-Scale (`calib_GUI`)**: A dedicated utility for generating calibration datasets. Users import images of reference objects of known length captured at varying altitudes. The GUI calculates the empirical Ground Sample Distance (eGSD) for each altitude. The software implements the calibration methodology described by @deOliveira:2023a, assuming a linear relationship between the eGSD and the observed flight altitude. The model predicts the corrected GSD (cGSD) using the following regression: $$CGSD = \beta_0 + \beta_1(\text{Altitude}) + \varepsilon$$ This cGSD serves as the dynamic calibration factor to convert all pixel distances into metric estimates (meters) for a specific flight altitude. Furthermore, the application provides built-in real-time diagnostic plots, including linearity, homogeneity of variance, and accuracy metrics (RMSE, $R^{2}$, and MAE) to visually and statistically validate calibration models before exporting the final standardized `.xlsx` datasets.

2.  **MedidoR-Analysis (`medidor_GUI`)**: The primary interface for morphometric extraction of the target animals. It supports both "free measurements" (e.g., fluke width, specific marks, rostrum length) and "morphometrics" (automatically segmenting body widths at 5% or 10% intervals along the total body length). This flexibility makes it suitable not only for cetaceans but also for measuring straight body length in dugongs or total length in elasmobranchii.

# Acknowledgements

I acknowledge the Projeto Toninhas do Brasil, and the Grupo de Estudos de Mamíferos Aquáticos do Rio Grande do Sul (GEMARS) for providing the imagery data used to validate the software. Special thanks to Matheus Lima de Oliveira for assistance with the graphic parameters of the interface. Thanks to Alexandre Machado for his help in optimizing and testing the application. And thanks to Denis Hille for his great help during the functional testing.

# References
