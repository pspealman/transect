# Computational Analysis included in the Transect Paper
A collection of code and resources used in the analyses of the Transect 2025 paper.

---
### Overview

Several computational components were used in the analysis of the data. This file offers a brief explanation of each.

## QIIME2 on 16S and ITS reads

Shell scripts containing the CLI commands used to perform QIIME2 analysis on both 16S and ITS data. These are used to generate Figures 1, 2A,2B, 3A, 3B. And Supplementary tables ST1, ST2, and ST3.

```{}
Qiime_Transect_16S.sh 
Qiime_Transect_ITS.sh
```

## Linear model and plot in R
To evaluate changes in several variables in relation to distance we used linear model (lm) in R, Figures 2C, 2D, and 3C.

```{}
Run_lm_plot.r
```

## Heatmap
Because of the large number of possible ARG and gene function combinations a heatmap wass used to summarize the results.

```{}
Build_heatmap.py
```

## Bray-Curtis distance

Generate Bray-curtis distance, Supplemental Table 4.

```{}
parse_median_bc_distance.py
```
