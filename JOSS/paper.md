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

Estimating morphometric measurements is essential to understanding animal biology, ecology, and behavior. Over the last decade, drone-based photogrammetry has enabled non-invasive, systematic, and long-term data collection, allowing researchers to estimate the body size and physical condition of wild marine megafauna, especially in studies involving marine mammals [@Burnett:2018; @deOliveira:2023a; @deOliveira:2023b]. Aerial photogrammetry relies on calculating a Ground Sample Distance (GSD) to convert image pixels into metric units. While a drone's onboard barometer can provide altitude estimates to calculate GSD, these are often biased by environmental conditions and take-off height. `MedidoR` is an open-source R package with Shiny applications designed to optimize drone-based photogrammetry analyses by utilizing scale calibration models. `MedidoR` allows for independent calibration flights to build statistical models [@deOliveira:2023a] that correct altitude biases, increasing measurement accuracy.

# Statement of Need

Accurate size and body condition estimation is a fundamental requirement for assessing population health and individual energetic status across various marine megafauna. The rapid advancement of Unoccupied Aircraft Systems (UAS, or drones) has facilitated non-invasive monitoring and photogrammetry for a wide range of surface-associated species, including dugongs, pinnipeds, sharks, rays, and marine turtles [@Hodgson:2020; @Dujon:2021]. Precise metric measurements require a accurate altitude data to properly scale imagery. While laser altimeters have been developed to overcome the inaccuracies of onboard barometers [@Dawson:2017], they add significant cost, hardware complexity, and weight to the aircraft.

A proven, cost-effective alternative to hardware modifications is the use of scale calibration models derived from flights over objects of known dimensions [@Burnett:2018; @deOliveira:2023a; @deOliveira:2023b]. Despite the establishment of this calibration methodology, the current software ecosystem for marine photogrammetry lacks integrated tools to streamline this specific workflow. General image processing programs like ImageJ [@Schneider:2012] require manual data transcription and lack automated body segmentation. Dedicated photogrammetry tools such as MorphoMetriX [@Torres:2020] and AragoJ [@Aleixo:2020] are highly effective for pixel extraction but rely on direct metadata input or in-frame scaling, leaving the integration of calibration models to post-processing software like CollatriX [@Bird:2020] or custom scripts.

`MedidoR` fills this software gap by offering a user-friendly graphical interface (GUI) that combines the generation of statistical calibration models with routines for proportional body segmentation. It makes advanced, statistically-validated photogrammetry accessible to biologists without requiring extensive coding expertise, standardizing workflows for marine megafauna species where metric measurements are required.

# Software design

The `MedidoR` package [@deOliveira:2025] is structured into two interconnected modules built on the Shiny framework, creating a continuous workflow from calibration to final measurement extraction:

1.  **MedidoR-Scale (`calib_GUI`)**: A dedicated utility for generating calibration datasets. Users import images of reference objects of known length captured at varying altitudes. The GUI calculates the empirical Ground Sample Distance (eGSD) for each altitude. The software implements the calibration methodology described by @deOliveira:2023a, assuming a linear relationship between the eGSD and the observed flight altitude. The model predicts the corrected GSD (cGSD) using the following regression: $$CGSD = \beta_0 + \beta_1(\text{Altitude}) + \varepsilon$$ This cGSD serves as the dynamic calibration factor to convert all pixel distances into metric estimates (meters) for a specific flight altitude. Furthermore, the application provides built-in real-time diagnostic plots, including linearity, homogeneity of variance, and accuracy metrics (RMSE, $R^{2}$, and MAE) to visually and statistically validate calibration models before exporting the final standardized `.xlsx` datasets.

2.  **MedidoR-Analysis (`medidor_GUI`)**: The primary interface for morphometric extraction of the target animals. It supports both "free measurements" (e.g., fluke width, specific marks, rostrum length) and "morphometrics" (automatically segmenting body widths at 5% or 10% intervals along the total body length). This flexibility makes it suitable not only for cetaceans but also for measuring straight body length in dugongs or total length in elasmobranchii.

# Figures

Figures can be included like this:
![Caption for example figure.\label{fig:example}](figure.png)
and referenced from text using \autoref{fig:example}.

Figure sizes can be customized by adding an optional second parameter:
![Caption for example figure.](figure.png){ width=20% }

# Research impact statement

`MedidoR` has been actively used to process photogrammetric data in marine conservation initiatives—such as the long-term *Projeto Toninhas do Brasil - Univille* in Babitonga Bay and northern Santa Catarina, Brazil—to estimate morphometric measurements and body condition of the Franciscana dolphin (*Pontoporia blainvillei*). It is also used by the "Farol das Baleias - GEMARS" project, where drone-based aerial photogrammetry estimates morphometric measurements of the southern right whale (*Eubalaena australis*) in southern Santa Catarina and northern Rio Grande do Sul, Brazil. Furthermore, the statistical models employed in the package are based on results presented by @deOliveira:2023b for Bryde's whale (*Balaenoptera edeni brydei*) and small cetaceans (Franciscana and Guiana dolphin—*Pontoporia blainvillei* and *Sotalia guianensis*, respectively) [@deOliveira:2023a], demonstrating its robustness as a reliable tool for the marine ecology research community.

# AI usage disclosure

No generative AI tools were used in the development of the source code or the conceptual design of this software. Generative AI (Google Gemini 3.1 pro) was utilized strictly for copy-editing and formatting this manuscript to comply with JOSS submission guidelines. All automated outputs were rigorously reviewed, validated, and edited by the human author, who assumes full responsibility for the content.

# Acknowledgements

I acknowledge the Projeto Toninhas do Brasil - Univille, and the Grupo de Estudos de Mamíferos Aquáticos do Rio Grande do Sul (GEMARS) for providing the imagery data used to validate the software. Special thanks to Matheus Lima de Oliveira for assistance with the graphic parameters of the interface. Thanks to Alexandre Machado for his help in optimizing and testing the application. And thanks to Denis Hille for his great help during the functional testing.

# References

1.  Aleixo, F., O'Callaghan, S. A., Ducla Soares, L., Nunes, P., & Prieto, R. (2020). AragoJ: A free, open-source software to aid single camera photogrammetry studies. Methods in Ecology and Evolution, 11(5), 670–677.

2.  Bird, C. N., & Bierlich, K. C. (2020). CollatriX: A GUI to collate MorphoMetriX outputs. Journal of Open Source Software, 5(51), 2328.

3.  Burnett, J. D., Lemos, L., Barlow, D., Wing, M. G., Chandler, T., & Torres, L. G. (2018). Estimating morphometric attributes of baleen whales with photogrammetry from small UASs: A case study with blue and gray whales. Marine Mammal Science, 35(1), 108–139.

4.  Dawson, S. M., Bowman, M. H., Leunissen, E., & Sirguey, P. (2017). Inexpensive aerial photogrammetry for studies of whales and large marine animals. Frontiers in Marine Science, 4, 366.

5.  de Oliveira, L. L., Andriolo, A., Cremer, M. J., & Zerbini, A. N. (2023a). Aerial photogrammetry techniques using drones to estimate morphometric measurements and body condition in South American small cetaceans. Marine Mammal Science.

6.  de Oliveira, L. L., Fettermann, T., Marcançoli, R. K. M., & Danilewicz, D. (2023b). Drone survey provides preliminary insights into the biological aspects of Bryde’s whales in southeastern Brazil. Latin American Journal of Aquatic Mammals, 18(2), 224–230.

7.  de Oliveira, L. L., (2025). MedidoR (1.0.0.9999). Zenodo.

8.  Dujon, A. M., Ierodiaconou, D., Geeson, J. J., Arnould, J. P. Y., Allan, B. M., Katselidis, K. A., & Schofield, G. (2021). Machine learning to detect marine animals in UAV imagery: effect of morphology, spacing, behaviour and habitat. Remote Sensing in Ecology and Conservation, 7(3), 341–354.

9.  Hodgson, A. J., Kelly, N., & Peel, D. (2020). Unmanned aerial vehicles for surveying marine fauna: assessing detection probability. Ecological Applications, 30(2), e02065.

10. Schneider, C. A., Rasband, W. S., & Eliceiri, K. W. (2012). NIH Image to ImageJ: 25 years of image analysis. Nature Methods, 9(7), 671–675.

11. Torres, W., & Bierlich, K. (2020). MorphoMetriX: a photogrammetric measurement GUI for morphometric analysis of megafauna. Journal of Open Source Software, 5(45), 1825.
