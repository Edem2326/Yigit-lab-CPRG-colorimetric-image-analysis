# Yigit_Lab-CPRG_imageanalysis

CPRG Colorimetric Image Analysis (MATLAB)

This repository provides MATLAB scripts for quantitative and spatial analysis of CPRG colorimetric assays from digital microscopy images (.RGB).

#### *(MATLAB version R2021b Update 6 (9.11.0.2207237), 64 bits, February 23, 2023)*

### To cite this work
Lashkari M, Connell N, Hanson E, Adade EE and Yigit MY, 2026.  Using glucometer for programmable genome sensing with visual and fluorescence outputs: Cell-free in vitro translation approach using RNA switch-CRISPR ……..

Overview

The workflow converts RGB images into CIE L*a*b* color space and performs block-based analysis of the a* channel to quantify chromogenic signal associated with CPRG substrate conversion. Spatial variation in signal is captured using grid-based sampling and visualized as heat maps across assay regions.

-------------------------------------------------------
#### STEP by STEP

1. Create a root directory and name it.
2. 
3. Download the MATLAB code ‘CPRG_CIElab_analysis.mfile’ and save it  in the directory.
4. 
5. Download and save the example image file. [CPRG image 2 x 2].
6. 
7. In MATLAB,  code is annotated to show experimental procedures. You an run the code to see you result.
1. Import image “CPRG_example.tif” into MATLAB.
2. Automated circular assay regions detection with the built-in circle detection function. 
3. Subdivide image into grids blocks to enable spatial quantification (10 x 10 0r 15 x 15 pixels, can be adjusted depending on the image resolution).
4. Filtering of edge blocks using 95 % overlap threshold (can be adjusted).
5. Convert RGB to CIE L*a*b* color space to operate luminance from chromatic information.
6. Extract go L*a*b*  channels and compute the block-wise mean for a*.
7. Quantitate measurement will be exported as .csv files to the directory.
8. Heat map will also be generated.

Key notes

1. Results depend on consistent imaging acquisition settings.

2. Block size should be chosen relative to image resolution.

3. Parameter tuning (e.g., circle detection, thresholds) may be required for different datasets.

4. For this code adjust the row and column dimensions to run code. This example is a 2 x 2 grid.

Contributions
Mahla Lashkari, Natalie Connell and Emmett Hanson performed all the imaging expermients.
Emmanuel Edem Adade wrote the code for this quantitive image analysis.
