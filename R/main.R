#' @title Preprocess high-resolution tandem mass spectra prior to database searching
#'
#' @description This package is designed to preprocess high-resolution MS/MS Data, which integrated three modules, removal of label-associated ions, isotope peak reduction and charge deconvolution, and a graph-based network approach and aimed at filtering out extraneous peaks with/without specific-feature. pClean is supportive to a wide array of instruments with all types of MS data, and incorporative into most data analysis pipelines.
#' @param mgf Input MS/MS data in MGF format.
#' @param itol Fragment tolerance, default 0.05Da.
#' @param outdir Output directory, default current directory.
#' @param mem The maximun memeroy to be used, default 1GB.
#' @param cpu The number of cpu to be used, default 0 (all).
#' @param aa2 Consider gap masses of two amino acid, default is TRUE.
#' @param ms2tolfilter Default 1.2.
#' @param mionFilter Filter immonium ions, default FALSE.
#' @param labelMethod Peptide labeling method, iTRAQ4plex, iTRAQ8plex, TMT6plex, TMT10plex or NULL.
#' @param repFilter Remove reporter ions, default FALSE.
#' @param labelFilter Remove label-associated ions, default FALSE.
#' @param low Remove ions in low b-/y-free window for label-based MS/MS data, default FALSE.
#' @param high Remove ions in high b-/y-free window for label-based MS/MS data, default FALSE.
#' @param isoReduction Reduction of heavy isotopic peaks, default FALSE.
#' @param chargeDeconv Charge deconvolution, default FALSE.
#' @param largerThanPrecursor Remove ions larger than precursor, default FALSE.
#' @param ionsMarge Marge two adjecent ions with similar m/z, default FALSE.
#' @param idres Use MSGF identification result to annotate peaks (.mzid), default NULL.
#' @return A much cleaner MS/MS data.
#' @export
pCleanGear <- function(mgf=NULL,itol=0.05,outdir="./",mem=1,cpu=0,plot=FALSE,aa2=TRUE,mionFilter=FALSE,labelMethod=NULL,repFilter=FALSE,labelFilter=FALSE,low=FALSE,high=FALSE,isoReduction=FALSE,chargeDeconv=FALSE,largerThanPrecursor=FALSE,ionsMarge=FALSE,idres=NULL,ms2tolfilter=1.2){
  dir.create(outdir,recursive = TRUE,showWarnings = FALSE)
  ph<-paste("java",paste("-Xmx",mem,"G",sep=""),"-jar",
            paste("\"",paste(system.file("pClean.jar",
                                         package = "pClean"),sep = "",collapse = ""),
                  "\"",sep = ""),
            collapse = " ",sep = " ")

  runcmd = paste(ph,
                 paste(" -i ", "\"",mgf,"\"",sep = ""),
                 paste(" -itol ", "\"",itol,"\"",sep = ""),
                 paste(" -o ", "\"",outdir,"\"",sep = ""),
                 collapse = " ",sep = " ")

  if (!is.null(labelMethod)) {
    runcmd=paste(runcmd, paste(" -labelMethod ", "\"",labelMethod,"\"",sep = ""),
                 collapse=" ",sep=" ")
  }
  if(!is.null(idres)){
    runcmd=paste(runcmd, paste(" -m ", "\"",idres,"\"",sep=""),
                 collapse=" ",sep=" ")
  }
  if(aa2==TRUE){
    runcmd=paste(runcmd," -a2 ",collapse=" ",sep=" ")
  }
  if(mionFilter==TRUE){
    runcmd=paste(runcmd," -mionFilter ",collapse=" ",sep=" ")
  }
  if(repFilter==TRUE){
    runcmd=paste(runcmd," -repFilter ",collapse=" ",sep=" ")
  }
  if(labelFilter==TRUE){
    runcmd=paste(runcmd," -labelFilter ",collapse=" ",sep=" ")
  }
  if(low==TRUE){
    runcmd=paste(runcmd," -low ",collapse=" ",sep=" ")
  }
  if(high==TRUE){
    runcmd=paste(runcmd," -high ",collapse=" ",sep=" ")
  }
  if(isoReduction==TRUE){
    runcmd=paste(runcmd," -isoReduction ",collapse=" ",sep=" ")
  }
  if(chargeDeconv==TRUE){
    runcmd=paste(runcmd," -chargeDeconv ",collapse=" ",sep=" ")
  }
  if(largerThanPrecursor==TRUE){
    runcmd=paste(runcmd," -largerThanPrecursor ",collapse=" ",sep=" ")
  }
  if(ionsMarge==TRUE){
    runcmd=paste(runcmd," -ionsMarge ",collapse=" ",sep=" ")
  }

  message("Preprocessing begining ...")
  system(command=runcmd)
  message("Graph-based network analysis ...")
  fs <- readr::read_tsv(paste(outdir,"/spectrumInfor.txt",sep=""))

  if(cpu==1){
    res <- fs %>% group_by(index) %>%
      do(doNetwork(.,plot = plot,outdir = outdir))
    return(res)
  }else{
    if(cpu==0){
      cpu <- parallel::detectCores()
    }
    cl <- parallel::makeCluster(getOption("cl.cores", cpu))
    parallel::clusterEvalQ(cl,library("readr"))
    parallel::clusterEvalQ(cl,library("dplyr"))
    parallel::clusterEvalQ(cl,library("igraph"))
    parallel::clusterEvalQ(cl,options(bitmapType="cairo"))
    xx <- lapply(1:nrow(fs),.myfun,fs)
    res <- parallel::parLapply(cl,xx,pClean::doNetwork,outdir=outdir,
                     plot=plot,outliers.coef=ms2tolfilter)
    parallel::stopCluster(cl)
    return(res)
  }
}


#' @title Merge MGF files
#' @describeIn Merge multiply MS/MS data
#' @param dir The directry of MS/MS data
#' @param name Merged file name
#' @param clean Delete individual MS/MS spectrum file
#' @return MGF
#' @export
mergeMGF <- function(dir=NULL,name=NULL,clean=TRUE){
  spectraList <- list.files(dir)
  output <- paste(dir,"/",name,collapse = "",sep = "")
  file.create(output)
  currentdir <- getwd()
  setwd(dir)

  file.append(output,spectraList)
  if (clean) {
    file.remove(spectraList)
  }
  setwd(currentdir)
  return(length(spectraList))
}

#' @title Make a list nesting another list
#' @description Make a list nesting another list
#' @param x list
#' @param a list
#' @return A new list.
#' @export
.myfun <- function(x,a){a[x,]}


#' @title Do graph-based internet filtration
#' @description Do graph-based internet filtration
#' @param dat _edge.txt file
#' @param plot Plot ions-interaction network, default FALSE
#' @param outdir Output directory, default current directory
#' @param outliers.coef Default 1.2
#' @return MGF
#' @export
doNetwork <- function(dat=NULL,plot=FALSE,outdir="./",outliers.coef=1.2){
  msms <- paste(outdir,"/msms",collapse = "",sep = "")
  if (dir.exists(msms)) {
  }else{
    dir.create(msms)
  }

  edgefile <- dat$edge
  vertexfile <- dat$vertex

  fileprefixpng = paste(png,"/",dat$index,sep="")
  fileprefixgml = paste(gml,"/",dat$index,sep="")

  edgelist <- readr::read_tsv(edgefile,na = "")
  edgelist <- edgelist %>% mutate(From = as.character(From),
                                  To = as.character(To),
                                  naa = nchar(deltaName)) # %>%
  #filter(naa==1)
  # if interactions of two ions has both high-level interactions and low-level interactions,
  # pClean remains high-level ones and remove low-level ones to simplify the ions-network
  edgelist %>% group_by(To) %>% do(.afun(.)) -> edgelist
  edgelist %>% group_by(From) %>% do(.afun(.)) -> edgelist

  vlist <- read.delim(vertexfile,stringsAsFactors = FALSE)
  vlist <- vlist %>% mutate(name = as.character(name))

  # remove higher error interactions
  edgelist <- edgelist[!.sel.outliers(edgelist$mztol,outliers.coef = outliers.coef),]

  # built graph
  g <- graph_from_data_frame(edgelist,
                             directed = TRUE,
                             vertices = vlist)

  V(g)$degree <- degree(g)
  V(g)$degreeIn <- degree(g,mode="in")
  V(g)$degreeOut <- degree(g,mode="out")
  V(g)$closeness <- closeness(g)
  V(g)$bet <- betweenness(g)
  V(g)[!is.na(type)]$color <- "red"
  V(g)[is.na(type)]$color <- "black"
  E(g)$weight <- ifelse(E(g)$naa==1,6,1)

  if(TRUE==plot){
    png <- paste(outdir,"/png",collapse = "",sep = "")
    if (dir.exists(png)) {
    }else{
      dir.create(png)
    }

    gml <- paste(outdir,"/gml",collapse = "",sep = "")
    if (dir.exists(gml)) {
    }else{
      dir.create(gml)
    }

    png(paste(fileprefixpng,".png",sep=""),width = 700,height = 700,res=110)
    par(mar=c(0,0,0,0))
    plot(g,vertex.label=V(g)$type,
         vertex.label.cex=0.6,
         vertex.size=log2(V(g)$intensity+1)/2,
         edge.label.cex=0.5,
         edge.arrow.size=0.3,
         layout=layout_nicely)

    dev.off()
    write_graph(g,file=paste(fileprefixgml,".gml",sep=""),format = "gml")
  }

  comp <- components(g,mode="weak")
  max_ind <- which.max(comp$csize)
  vertex_name <- names(comp$membership[comp$membership==max_ind])


  y1 <- setdiff(names(comp$membership),vertex_name)[grepl("175.1",setdiff(names(comp$membership),vertex_name))]
  vertex_name <- c(vertex_name,y1)
  y1 <- setdiff(names(comp$membership),vertex_name)[grepl("291.2",setdiff(names(comp$membership),vertex_name))]
  vertex_name <- c(vertex_name,y1)
  y1 <- setdiff(names(comp$membership),vertex_name)[grepl("451.3",setdiff(names(comp$membership),vertex_name))]
  vertex_name <- c(vertex_name,y1)
  y1 <- setdiff(names(comp$membership),vertex_name)[grepl("147.1",setdiff(names(comp$membership),vertex_name))]
  vertex_name <- c(vertex_name,y1)

  peaks <- igraph::as_data_frame(g,what="vertices") %>%
    filter(name %in% vertex_name) %>%
    select(name,intensity) %>%
    mutate(name=as.numeric(name)) %>%
    arrange(name)
  mgftitle <- paste("BEGIN IONS\n",
                    "TITLE=",dat$title,"\n",
                    "PEPMASS=",dat$mz," ",dat$intensity,"\n",
                    "CHARGE=",dat$charge,"+",sep="")


  mgffile <- sub(pattern = ".txt$",replacement = ".mgf",x= tail(unlist(strsplit(dat$vertex,"/")),1))
  #mgffile <- sub(pattern = ".txt$",replacement = ".mgf",x=dat$vertex)
  resMgf <- paste(msms,"/",mgffile,collapse="",sep="")
  write(mgftitle,file = resMgf)
  write.table(peaks,file = resMgf,
              col.names = FALSE,row.names = FALSE,
              quote=FALSE,sep=" ",append = TRUE)
  write("END IONS\n",file = resMgf,append = TRUE)

  file.remove(edgefile)
  file.remove(vertexfile)
  return(data.frame(npeak=vcount(g),rpeak=max(comp$csize)))
}


#' @title Simplify the ion-interactions based on the formula level
#' @description Simplify the ion-interactions based on the formula level
#' @param x Ion-interactions
#' @return Simplified ion-interactions
#' @export
.afun = function(x){
  ## if not equal to 2, reveal that one amino acid has a water-loss or NH3-loss.
  if(sum(x$naa!=2)>=1){

    x <- filter(x, naa!=2)
  }
  return(x)
}


#' @title Remove high-error ion-interactions
#' @description Remove high-error ion-interactions
#' @param x Ion-interactions
#' @param method iqr method
#' @param outliers.coef Default 1.2
#' @return Simplified ion-interactions
#' @export
.sel.outliers = function(x,method="iqr",outliers.coef=1.0) {
  sel <- is.na(x)

  if (method == "iqr") {
    qs <- quantile(x,c(.25,.75),na.rm=TRUE)
    iqr <- qs[2] - qs[1]
    sel | x < qs[1]-outliers.coef*iqr | x > qs[2]+outliers.coef*iqr

  } else {
    stop("method ",method," not known, current only can use iqr")
  }
}

