# pClean

![Downloads](https://img.shields.io/github/downloads/AimeeD90/pClean_release/total.svg)

pClean is a powerful tool to preprocess high-resolution tandem mass spectra prior to database searching, and aimed at filtering out extraneous peaks with/without specific-feature, which integrated three modules, removal of label-associated ions, isotope peak reduction and charge deconvolution, and a graph-based network approach. pClean is supportive to a wide array of instruments with all types of MS data, and incorporative into most data analysis pipelines.

## Resources and executive environment

pClean is programed in Java and R, and released as a R package.

**Software download:** The source code is available at [https://github.com/AimeeD90/pClean](https://github.com/AimeeD90/pClean), and the released software is downloadable at [https://github.com/AimeeD90/pClean_release](https://github.com/AimeeD90/pClean_release). Please download the latest version.

**Java version:** 1.8 or later

**R version:** 3.5.0 or later

**Operation platforms:** Windows, Mac OSX, Linux

**Hardware:** 2 CPUs, 4 Gb memory (the more, the better)

## How to use pClean

### 3.1 Data transformation

pClean accepts MGF files as inputs. A vendor-specific format can be easily converted to MGF format using MSconvert of ProteoWizard library.

### 3.2 Installation

pClean was released as a R package and distributed through GitHub. The installation steps are listed as follows.

* Check R and Java to ensure the required version is installed. If not, you can download the latest version of software from [https://cran.r-project.org](https://cran.r-project.org) (or [https://www.rstudio.com](https://www.rstudio.com)) and [https://java.com/en/download/](https://java.com/en/download/), respectively. 

Note that if you are a Windows user, please add Java path to the system path after the Java installation.

* Open R software (recommended RStudio), and install package "devtools" via commands:


```{r install, eval = FALSE}
install.packages("devtools")
library(devtools)
```

* Install pClean package using the following command:

```{r install, eval = FALSE}
devtools::install_github("AimeeD90/pClean_release")
library(pClean)
```

* Now pClean is executable on your work station.

### 3.3 Usage

Here, one fraction of TTE dataset (peptide labeled with iTRAQ8plex) and one fraction of Jurkat dataset (label free) were used as examples to illustrate how to use pClean. 

**3.3.1  Parameters**

All the parameters of pClean are listed in the following table.

Parameter|Description|Default value
----------|------------|--------------
mgf|Input MS/MS data|NULL
itol|Fragment ion tolerance|0.05 (Da)
outdir|Output directory|./
mem|The maximum Java heap size, unit G|1
cpu|Allowable number of CPU|0 (all)
aa2|Consider mass gap of two amino acids|TRUE
mionFilter|Filter out immonium ions|FALSE
labelMethod|Peptide labeling method|NULL
repFilter|Filter out reporter ions|FALSE
labelFilter|Filter out label-associated ions|FALSE
low|Clearance of low b-/y-ion free window|FALSE
high|Clearance of high b-/y-ion free window|FALSE
isoReduction|Heavy isotopic ions reduction|FALSE
chargeDeconv|High charge deconvolution|FALSE
largerThanPrecursor|Filter out ions larger than precursor’s mass|FALSE
ionsMerge|Merge two ions of similar mass|FALSE
network|Graph-based network filtration|FALSE
plot|Plot ions-network|FALSE
idres|Identification result, mzid or dat file|NULL
ms2tolfilter|Fragment mass error tolerance filter limit|1.2

pClean provide with a function to eliminate the immonium ions from MS/MS data, and the list of immonium ions are got from reference. Filter out the immonium ions.

**3.3.2  pClean treatment on label-based MS/MS data**

1)  Open R and load pClean, type: 

```{r install, eval = FALSE}
library(pClean)
```

2)  Set parameters then run pClean:

```{r install, eval = FALSE}
mgffile<-system.file("extdata/", "tte.frac1.mgf",package="pClean")
pCleanGear(mgf=mgffile,outdir="tte/result",mem=2,cpu=0,mionFilter=TRUE,labelMethod="iTRAQ8plex",repFilter=TRUE,labelFilter=TRUE,low=TRUE,high=TRUE,isoReduction=TRUE,chargeDeconv=TRUE,largerThanPrecursor=TRUE,ionsMerge=TRUE,network=TRUE)
```

3)  The resultant MS/MS spectra are written to the ms/ms directory in separate files. To merge all the files, run this:

```{r install, eval = FALSE}
mergeMGF(dir="tte/result/msms",name="tte.frac1.pClean.mgf")
```

**3.3.3  pClean treatment on label-free MS/MS data**

1)  Open R and load pClean, and type: 

```{r install, eval = FALSE}
library(pClean)
```

2)  Set parameters then run pClean:

```{r install, eval = FALSE}
mgffile<-system.file("extdata/", "120426_Jurkat_highLC_Frac1.mgf",package="pClean")
pCleanGear(mgf=mgffile,outdir="jurkat/result",mem=2,cpu=0,mionFilter=TRUE,isoReduction=TRUE,chargeDeconv=TRUE,largerThanPrecursor=TRUE,ionsMerge=TRUE,network=TRUE)
```

3)  The resultant MS/MS spectra are written to the ms/ms directory in separate files. To merge all the files, run this:

```{r install, eval = FALSE}
mergeMGF(dir="jurkat/result/msms",name="Jurkat.frac1.pClean.mgf")
```

**3.3.4  Visualization of ions-network**

Optionally, if you want to visualize the construction of ions-network graph, and annotate ions with corresponding peptide fragment, you need do a database search in advance. At present, pClean supports parsing identification results from dat and mzid. The provided sample mzid file was generated using MSGF+ software. To fulfill this purpose, please use the following commands:

```{r install, eval = FALSE}
mgffile<-system.file("extdata/", "tte.frac1.mgf",package="pClean")
datfile<-system.file("extdata/", "tte.frac1.asc.dat",package="pClean")
pCleanGear(mgf=mgffile,outdir="tte/result",mem=2,cpu=0,mionFilter=TRUE,labelMethod="iTRAQ8plex",repFilter=TRUE,labelFilter=TRUE,low=TRUE,high=TRUE,isoReduction=TRUE,chargeDeconv=TRUE,largerThanPrecursor=TRUE,ionsMerge=TRUE,network=TRUE,plot=TRUE,idres=datfile)
mergeMGF(dir="tte/result/msms",name="tte.frac1.pClean.mgf")

mzidfile<-system.file("extdata/", "tte.frac1.mzid",package="pClean")
pCleanGear(mgf=mgffile,outdir="tte/result",mem=2,cpu=0,mionFilter=TRUE,labelMethod="iTRAQ8plex",repFilter=TRUE,labelFilter=TRUE,low=TRUE,high=TRUE,isoReduction=TRUE,chargeDeconv=TRUE,largerThanPrecursor=TRUE,ionsMerge=TRUE,network=TRUE,plot=TRUE,idres=mzidfile)
mergeMGF(dir="tte/result/msms",name="tte.frac1.pClean.mgf")
```

Once the progress completed, pClean creates a png directory and a gml directory. You can match a png or gml file to the corresponding MS/MS spectrum with the help of `spectrumInfor.txt (under the directory: tte/result/)`.

**3.3.5  Other filters**

Alternatively, pClean implements two reported filters in it, Top10 filter, a traditional intensity-based preprocessing method, and CRF filter (reference), a chemical rules-based approach but unavailable currently. 

To use Top10 filter, run the following command:

To use CRF filter, run the following command:

