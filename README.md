# Yigit lab-CPRG Colorimetric Image Analysis

CPRG Colorimetric Image Analysis (MATLAB)

This repository contains the MATLAB code and an example image for the quantitative and spatial analysis of CPRG colorimetric assays from digital microscopy images (.RGB).

#### *(MATLAB version R2021b Update 6 (9.11.0.2207237), 64 bits, February 23, 2023)*

### To cite this work
Lashkari M, Connell N, Hanson E, Adade EE and Yigit MY, 2026.  Using glucometer for programmable genome sensing with visual and fluorescence outputs: Cell-free in vitro translation approach using RNA switch-CRISPR ……..

Overview

This workflow converts RGB images into CIE L* a* b* color space and performs block-based analysis of the a* channel to quantify chromogenic signal associated with CPRG substrate conversion. Spatial variation in signal is captured using grid-based sampling and visualized as heat maps across assay regions.

-------------------------------------------------------
#### STEP by STEP

1. Create a root directory and name it.
   
2. Download the MATLAB code [CPRG_CIElab_analysis.m](/CPRG_CIElab_analysis.m) and save it  in the directory.
 
3. Download and save the example image file ![CPRG_example_2x2.tif](CPRG_example_2x2.tif).
 
4. In MATLAB, this code is annotated to show all analysis procedures. You can run the code to visualize result for this example analysis experiment. This code can be adjusted depending on the study.
   
  - Import image [CPRG_example_2x2.tif](/https://zenodo.org/records/19556047?preview=1&token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6IjlhMTRhZDQ4LTJjYjMtNDY5Mi1hNDI2LWUyZWUyNjdmMDAxYSIsImRhdGEiOnt9LCJyYW5kb20iOiI0ZGM4MjE2NmI2YTA4MGJjZDFkYTUxNDM1NTIwY2VmOCJ9.qJAErt4i0m50rtRdAWYOgnvqOzlzdzwGi7KnGOyZEaUB5ZHIiSVqbzzF-yQVpeqVXKrts2oHj5GYOT1fM_qkmw) into MATLAB.
  
  - Automated circular assay regions detection with the built-in circle detection function. 
  
  - Subdivide image into grids blocks to enable spatial quantification (10 x 10 0r 15 x 15 pixels, can be adjusted depending on the image resolution).
  
  - Filtering of edge blocks using 95 % overlap threshold (can be adjusted).
  
  - Convert RGB to CIE L* a* b* color space to operate luminance from chromatic information.
  
  - Extract go L* a* b* channels and compute the block-wise mean for a*.
  
  - Quantitative output for this anlaysis will be exported as .csv files to the directory.
  
  - Heat map will also be generated.

--------------------------------------------------------
#### Key notes

1. Results depend on consistent imaging acquisition settings.

2. Block size should be chosen relative to image resolution.

3. Parameter tuning (e.g., circle detection, thresholds) may be required for different datasets.

4. You can adjust the row and column dimensions to run code. This example is a 2 x 2 grid.

---------------------------------------------------------
#### Contributions

[Emmanuel Edem Adade](https://github.com/Edem2326) wrote the code for this quantitative image analysis.

Mahla Lashkari, Natalie Connell and Emmett Hanson performed all the imaging experiments.

Mehmet Yigit conceived the study.
