# examples.R
# code showing how to use the jitter functions

# rem to set working directory to code directory for now
# won't need to do this once part of ASAPplots

source("read_ASAP3_dat_file.R")
source("read_ASAP3_pin_file.R")
source("create_param_list.R")
source("get_fixed_params.R")
source("write_ASAP3_dat_file.R")
source("write_ASAP3_pin_file.R")
source("jitter_asap.R")
source("run_jitter.R")
source("plot_jitter.R")

# once put jitter in ASAPplots
library("ASAPplots")
library("ggplot2")
library("dplyr")

# need to work on README.md to describe what was done and how to use functions

######################################################
# Simple - drop this example???
wd <- "C:\\Users\\chris.legault\\Desktop\\jitter_asap"
od <- paste0(wd, "\\jitter\\")
asap.name <- "Simple"
njitter <- 3
#sjitter <- RunJitter(wd, asap.name, njitter, ploption = "jitter", save.plots = "TRUE", od, plotf="png")
sfull <- RunJitter(wd, asap.name, njitter, ploption = "full", save.plots = "TRUE", od, plotf="png", showtitle=TRUE)
######################################################


######################################################
# fluke
fluke.dir <- "C:\\Users\\chris.legault\\Desktop\\jitter_asap\\fluke"
fluke.name <- "F2018_BASE"
njitter <- 50

wdj <- paste0(fluke.dir,"\\myjitter") 
odj <- paste0(wdj, "\\jitter\\")
fjitter <- RunJitter(wdj, fluke.name, njitter, ploption = "jitter", save.plots = "FALSE", odj, plotf="png")
which(fjitter$objfxn < fjitter$orig_objfxn)
# integer(0)

wdf <- paste0(fluke.dir,"\\myfull")
odf <- paste0(wdf, "\\jitter\\")
ffull <- RunJitter(wdf, fluke.name, njitter, ploption = "full", save.plots = "TRUE", odf, plotf="png")
which(ffull$objfxn < ffull$orig_objfxn)
# integer(0)

# compare jitter.pins for select params
njitter <- 40 # had to kill jitter runs early
myparam <- c("# sel_params[1]:", "# log_Fmult_year1:", "# log_N_year1_devs:", "# log_SR_scaler:")
np <- length(myparam)
pname <- paste0(wdj,"\\", fluke.name, ".par")
asap.pin <- ReadASAP3PinFile(pname)

plab <- NULL
for (ip in 1:np){
  pval <- which(asap.pin$comments == myparam[ip])
  thislab <- paste0(myparam[ip], 1:length(asap.pin$dat[[pval]][[1]]))
  plab <- c(plab, thislab)
}

pindf <- data.frame()
ip <- 1:np
p <- myparam[ip]

pval <- which(asap.pin$comments %in% p)
thisdf <- data.frame(source="orig", param=plab, jitter=0, val=unlist(asap.pin$dat[pval]))
pindf <- rbind(pindf, thisdf)

for (ijit in 1:njitter){
  pnamej <- paste0(odj, "jitter", ijit, ".pin")
  if (file.exists(pnamej)){
    asap.pin <- ReadASAP3PinFile(pnamej)
    thisdf <- data.frame(source="jitter", param=plab, jitter=ijit, val=unlist(asap.pin$dat[pval]))
    pindf <- rbind(pindf, thisdf)
  }
  pnamef <- paste0(odf, "jitter", ijit, ".pin")
  if (file.exists(pnamef)){
    asap.pin <- ReadASAP3PinFile(pnamef)
    thisdf <- data.frame(source="full", param=plab, jitter=ijit, val=unlist(asap.pin$dat[pval]))
    pindf <- rbind(pindf, thisdf)
  }
}  
pindf

jitter_pin_plot <- ggplot(pindf, aes(x=source, y=val)) +
  geom_jitter(width = 0.2, height = 0) +
  facet_wrap(~param, scales = "free_y") +
  theme_bw()

print(jitter_pin_plot)
ggsave(jitter_pin_plot, file=paste0(fluke.dir, "\\jitter_pin_plot.png"))
######################################################

######################################################
# groundfish
# ASAP assessment input files from https://www.nefsc.noaa.gov/saw/sasi/sasi_report_options.php
base.dir <- "C:\\Users\\chris.legault\\Desktop\\jitter_asap\\"
njitter <- 200
ploption <- "jitter"

gstocks <- c("gomcod", "gomhaddock", "pollock", "redfish", "snemawinter", "snemayt", "whitehake")
nstocks <- length(gstocks)
gres <- list()
gname <- "base" # did not have to do this, just an easier way of running through many cases in a loop

for (istock in 1:nstocks){  
  wd <- paste0(base.dir, gstocks[istock])
  gres[[istock]] <- RunJitter(wd, gname, njitter, ploption) 
}

# GOM cod - a few diff objfxn vals with one wacko one, fair number of NA

# GOM haddock - solid results with only one slightly diff objfxn val and 2 NA

# when ran full case - both GOM cod and haddock did well with just a few wacko results
#####################################################################################
### TODO need to move full jitter into sub dir so doesn't conflict with jitter runs
#####################################################################################

# Pollock lots of realizations did not converge - model on edge - check for diffs in SSB trends
# bombed out on full due to NAN in likelihood - add error trap?

# redfish - takes a long time - rock solid estimates (only one diff res) but lots of did not converge

# snemawinter - 2 diff solutions with high freq (objfxn change 400!), see how diff the SSB trends are

# snemayt - rock solid solution almost all same value, only four did not converge 

# white hake - rock solid solution 

# save gres
# setwd(base.dir)
# dput(gres, file="dputgres.Rdat", control = "keepNA") # to make sure don't lose results
# use the following line to get it back
# gres <- dget("dputgres.Rdat")

# convert gres into data.frames for use in ggplot?? or should I use base plot and modify PlotJitter function???
PlotJitter(gres[[1]], FALSE, NULL, NULL, FALSE, 1E+5)
