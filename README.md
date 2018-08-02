# pClean

![Downloads](https://img.shields.io/github/downloads/AimeeD90/pClean_release/total.svg)

pClean is a novel algorithm to preprocess high-resolution tandem mass spectra prior to database searching, which integrated three modules, removal of label-associated ions, isotope peak reduction and charge deconvolution, and a graph-based network approach and aimed at filtering out extraneous peaks with/without specific-feature. pClean is supportive to a wide array of instruments with all types of MS data, and incorporative into most data analysis pipelines.

## Resources and executive environment

pClean is programed in Java and R, and released as a R package.
Software download: The source code is available at [https://github.com/AimeeD90/pClean](https://github.com/AimeeD90/pClean), and the released software is downloadable at [https://github.com/AimeeD90/pClean_release](https://github.com/AimeeD90/pClean_release). Please download the latest version.
Java version: 1.8 or later
R version: 3.5.0 or later
Operation platforms: Windows, Mac OSX, Linux
Hardware: 2 CPUs, 4 Gb memory (the more, the better) 
MS/MS data for testing: The testing data are available at [https://github.com/AimeeD90/pClean_upload.tar.gz](https://github.com/AimeeD90/pClean_upload.tar.gz).

## How to use pClean

### 3.1 Data transformation

pClean accepts MGF files as inputs. A vendor-specific format can be easily converted to MGF format using MSconvert of ProteoWizard library.

### 3.2 Installation

pClean was released as a R package and distributed through GitHub. The installation steps are listed as follows.
*Check R and Java to ensure the required version is installed. If not, you can download the latest version of software from [https://cran.r-project.org](https://cran.r-project.org) (or [https://www.rstudio.com](https://www.rstudio.com)) and [https://java.com/en/download/](https://java.com/en/download/), respectively. Note that if you are a Windows user, please add Java path to the system path after the Java installation.
*Open R software (recommended RStudio), and install package “devtools” via commands:
    `install.packages(“devtools”)`
    `library(devtools)`
*Install pClean package using the following command:
  devtools::install_github(“AimeeD90/pClean_release”)
    `library(pClean)`
*Now pClean is executable on your work station.

### 3.3 Usage

Here, we use one fraction of TTE dataset (peptide labeled with iTRAQ8plex) and one fraction of Jurkat dataset (label free) as examples to illustrate how to use pClean. First of all, please download the sample data from the website: [https://github.com/AimeeD90/pClean_upload.tar.gz](https://github.com/AimeeD90/pClean_upload.tar.gz)

*3.3.1 pClean treatment on label-based MS/MS data*

1)Open R and load pClean, type: 
    `library(pClean)`
2)Set parameters then run pClean:
    `pCleanGear(mgf="TTE.frac1.mgf",outdir="/USER/dengyamei/Workdir/assessment/tte/result",mem=2,cpu=0,mionFilter=TRUE, labelMethod=”iTRAQ8plex”, repFilter=TRUE,labelFilter=TRUE, labelFilter =TRUE,high=TRUE,isoReduction=TRUE,chargeDeconv=TRUE,largerThanPrecursor=TRUE,ionsMarge=TRUE, network=TRUE)`
3)The resultant MS/MS spectra are written to the ms/ms directory in separate files. To merge all the files, run this:
    `mergeMGF(dir=“/USER/dengyamei/Workdir/assessment/tte/result/msms”,name=“tte.frac1.pClean.mgf”)`
    
*3.3.2 pClean treatment on label-free MS/MS data*

1)Open R and load pClean, type: 
    `library(pClean)`
2)Set parameters then run pClean:
    `pCleanGear(mgf="Jurkat.frac1.mgf",outdir="/USER/dengyamei/Workdir/assessment/jurkat/result",mem=2,cpu=0,mionFilter=TRUE,isoReduction=TRUE,chargeDeconv=TRUE,largerThanPrecursor=TRUE,ionsMarge=TRUE, network=TRUE)`
3)The resultant MS/MS spectra are written to the ms/ms directory in separate files. To merge all the files, run this:
    `mergeMGF(dir=“/USER/dengyamei/Workdir/assessment/jurkat/result/msms”,name=“Jurkat.frac1.pClean.mgf”)`
    
*3.3.3 Visualization of ions-network*

Optionally, if you want to visualize the construction of ions-network graph, and annotate ions with corresponding peptide fragment, you need do a database search in advance. At present, pClean supports parsing identification results from mzid and dat. The provided sample mzid file was generated using MSGF+ software. To fulfill this purpose, please use the following commands:
    `pCleanGear(mgf="TTE.frac1.mgf",outdir="/USER/dengyamei/Workdir/assessment/tte/result",mem=2,cpu=0,mionFilter=TRUE, labelMethod=”iTRAQ8plex”, repFilter=TRUE,labelFilter=TRUE, labelFilter=TRUE,high=TRUE,isoReduction=TRUE,chargeDeconv=TRUE,largerThanPrecursor=TRUE,ionsMarge=TRUE, network=TRUE,plot=TRUE,idres="/USER/dengyamei/Workdir/assessment/tte/TTE.frac1.mzid")`
    `mergeMGF(dir=“/USER/dengyamei/Workdir/assessment/tte/result/msms”,name=“tte.frac1.pClean.mgf”)`
Once the progress completed, pClean creates a png directory and a gml directory. You can match a png or gml file to the corresponding MS/MS spectrum with the help of `spectrumInfor.txt (under the directory:/USER/dengyamei/Workdir/assessment/tte/result/)`.

*3.4 Parameters*

All the parameters of pClean are listed in the following table.


pClean provide with a function to eliminate the immonium ions from MS/MS data, and the list of immonium ions are got from reference. Filter out the immonium ions.

*3.5 Other filters*

Alternatively, pClean implements two reported filters in it, Top10 filter, a traditional intensity-based preprocessing method, and CRF filter (reference), a chemical rules-based approach but unavailable currently. 
To use Top10 filter, run the following command:
To use CRF filter, run the following command:
