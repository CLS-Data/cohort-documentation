# Downloading CLS Documentation

This repository contains code to download documentation (PDFs) from CLS's four established cohort studies - NCDS, BCS70, Next Steps, and MCS.

The code places the PDFs into sub-folders for each study-sweep. Where a document pertains to multiple sweeps, the PDF is placed in a separate `xwave` folder. Where a document pertains to more than one cohort (e.g., the Missing Data Handling Guide) the PDF is placed in a separate `All` sub-folder.

The code also renames the PDFs to the more user-friendly titles given on the CLS website. Combined the files require \~ 750mb of storage.

To use the code you will need R (<https://cran.r-project.org/>) and RStudio (<https://posit.co/download/rstudio-desktop/>) installed. You will only need to use R and RStudio once.

## Instructions

1.  Download or clone this GitHub directory.

    -   To download the directory, click `Code -> Download ZIP` above (see screenshot below) then unzip the downloaded file and place in a suitable location on your computer.

    -   To clone the directory, open your computer’s command line or terminal, navigate to an appropriate location (`cd ...`) and type `git clone https://github.com/CLS-Data/cohort-documentation`. You may want to rename the folder from `cohort-documentation` to "CLS Documentation" or something similar.

2.  In the downloaded folder, double click the `CLS Documentation.Rproj` file. This will open RStudio and automatically sets the working directory to the folder that contains the `.Rproj` file, so you won't need to change any file paths.

3.  Run the code in `01_get_pdfs.R`. You will need the `tidyverse` package installed. If you do not have this installed, uncomment the first line and run it.

After the code is finished, you will have a new set of sub-folders within the `cohort-documentation` folder that contain the PDFs.

This code was tested on 27 November 2024. If you have any issues using this code, please contact me at [liam.wright\@ucl.ac.uk](mailto:liam.wright@ucl.ac.uk).
