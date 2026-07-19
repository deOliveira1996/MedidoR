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

Drone-based photogrammetry has become the primary method to estimate the body size and physical condition of the marine megafauna, especially for marine mammals [@Burnett:2018; @deOliveira:2023a; @deOliveira:2023b]. Aerial photogrammetry relies on calculating the Ground Sample Distance (GSD) to convert image pixels into metric units. However, as most off-the-shelf drones use an onboard barometer to estimate altitude, this sensor measure the relative take-off height and is often distored by changes in environmental conditions, which affects the calculated GSD. Here, I present `MedidoR`, an open-source R package with Shiny applications that streamline drone-based photogrammetry analyses using scale calibration models. `MedidoR` uses independent calibration flights to fit statistical models [@deOliveira:2023a] to correct altitude biases from the barometer and increase the accuracy of derived measurements.

# Statement of Need

Body size and condition have major implications on individual health and energetic status across various marine megafauna. The rapid advancement of Remotely Piloted Aircraft System (RPAS, or drones) has facilitated the non-invasive monitoring of such morphological traits using aerial photogrammetry for a wide range of surface-associated species, including dugongs, pinnipeds, sharks, rays, and marine turtles [@Hodgson:2020; @Dujon:2021]. However, accurate altitude estimates are required to properly scale pixels into metric units. Laser altimeters have been adapted to off-the-shelf UAS to provide altitude estimates that overcome the inaccuracy from onboard barometers [@Dawson:2017], but adding a significant cost, hardware complexity, and weight to the UAS.

A cost-effective alternative to hardware modifications is the use of scale calibration models derived from flights over objects of known dimensions [@Burnett:2018; @deOliveira:2023a; @deOliveira:2023b]. Despite the establishment of this calibration methodology, the current software ecosystem for marine photogrammetry lacks integrated tools to streamline this specific workflow. For example, general image processing programs like ImageJ [@Schneider:2012] require manual data transcription and lack dedicated tools to automatically draw segmented widths on the animal body. Dedicated photogrammetry tools such as MorphoMetriX [@Torres:2020] and AragoJ [@Aleixo:2020] are highly effective for pixel extraction but rely on direct metadata input, such as date and time with corresponding altitude estimates to match with imagery, or in-frame scaling. Thus, the integration of calibration models are restricted to post-processing software like CollatriX [@Bird:2020] or custom software.

`MedidoR` aims to fill this gap by offering a user-friendly graphical interface (GUI) to fit and validate statistical calibration models, along with routines to automatically draw segmented widths on the animal body. It makes advanced, statistically-validated photogrammetry accessible to biologists without requiring extensive coding expertise or hardware adaptations, standardizing workflows to provide accurate metric measurements for marine megafauna.

# Software design

The `MedidoR` package [@deOliveira:2026] is structured into two interconnected modules built on the Shiny framework, creating a continuous workflow from calibration to final measurement extraction:

1.  **MedidoR-Scale (`calib_GUI`)**: A dedicated utility for generating calibration datasets. Users import images of reference objects of known length captured at varying altitudes. The GUI calculates the empirical Ground Sample Distance (eGSD) for each altitude. The software implements the calibration methodology described by @deOliveira:2023a, assuming a linear relationship between the eGSD and the observed flight altitude.

2.  **MedidoR-Analysis (`medidor_GUI`)**: The primary interface for morphometric extraction of the target animals. It supports both "free measurements" (e.g., fluke width, specific marks, rostrum length) and "morphometrics" (automatically segmenting body widths at 5% or 10% intervals along the total body length). This flexibility allows for measuring straight body length in dugongs or total length in elasmobranchii. The "calibration feature" allows the user to fit a calibration model based on calibration data (e.g., the calib.xlsx spreadsheet), predicting corrected GSD (cGSD) values using the following regression: $$CGSD = \beta_0 + \beta_1(\text{Altitude}) + \varepsilon$$ This cGSD serves as the dynamic calibration factor to convert all pixel distances into metric units for a specific flight altitude. Furthermore, the application provides built-in real-time diagnostic plots, including linearity, homogeneity of variance, and accuracy metrics (RMSE, $R^{2}$, and MAE) to visually inspect and validate the assumptions of statistical models before exporting the final standardized `.xlsx` datasets.

# Figures

![Figure 1 - Overview of the MedidoR-Scale (`calib_GUI`) interface for generating calibration datasets. Panel (A) displays the Input Data section for directory management and database initialization. Panel (B) shows the parameters input fields, requiring users to input the known scale length and camera/flight parameters. Panel (C) illustrates the interactive image plot where users crop the image and measure the reference object to establish the empirical Ground Sample Distance.](figures/Fig%201.png){#fig:1}

![Figure 2 - Overview of the MedidoR-Analysis (`medidor_GUI`) interface for morphometric extraction. Panel (A) details the Input Data section, allowing users to choose between Morphometrics and Free Measurement modes and set segmentation intervals. Panel (B) contains the required image, flight, and camera parameters. Panel (C) demonstrates the interactive canvas in Proportional Morphometrics Mode, showcasing the automatically generated perpendicular segmented widths along the user-defined total length.](figures/Fig%202.png){#fig:2}

![Figure 3 - Standardized three-phase workflow of the MedidoR R package. Phase 1 (top-left) describes building the scale calibration database using reference imagery through `calib_GUI()`. Phase 2 (top-right) illustrates the morphometric extraction from target animals using `medidor_GUI()`, detailing the choice between Proportional Morphometrics Mode (A) and Free Measurement Mode (B). Phase 3 (bottom) displays the integration of calibration data to correct Ground Sample Distance (cGSD) using dynamic regression models, resulting in standardizing metric outputs and generating diagnostic plots.](figures/Fig%203.png){#fig:3}

# Research impact statement

Over the last decade, the emerging tools have been rapidly inceasing their number of citations () [@Dawson:2017, @Torres:2020, @Bird:2020]. This showcases the importance of such tools for the field. However, despite the widespread use of R in Ecology [@Lai:2019], tools to directly measure and process photogrammetric data in R are still missing. `MedidoR` aims to fill this gap, as it has already been tested and is currently used by different research groups in Brazil to estimate morphometric measurements and body condition of the Franciscana dolphin (*Pontoporia blainvillei*), southern right whale (*Eubalaena australis*), *Tursiops truncatus gephyreus*, Bryde's whale (*Balaenoptera edeni brydei*) and *Sotalia guianensis* [@deOliveira:2023a]. Overall, this demonstrates the importance and robustness of `MedidoR` as a reliable tool for the marine ecology research community.

# AI usage disclosure

No generative AI tools were used in the development of the source code or the conceptual design of this software. Generative AI (Google Gemini 3.1 pro) was utilized strictly for copy-editing and formatting this manuscript to comply with JOSS submission guidelines. All automated outputs were rigorously reviewed, validated, and edited by the human author, who assumes full responsibility for the content.

# Acknowledgements

I acknowledge the Projeto Toninhas do Brasil - Univille, and the Grupo de Estudos de Mamíferos Aquáticos do Rio Grande do Sul (GEMARS) for providing the imagery data used to validate the software. Special thanks to Matheus Lima de Oliveira for assistance with the graphic parameters of the interface. Thanks to Alexandre Machado for his help in optimizing and testing the application. And thanks to Denis Hille for his great help during the functional testing.

# References
