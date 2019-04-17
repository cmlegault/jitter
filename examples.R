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
gname <- "base" # did not have to do this, just an easier way of running through many cases in a loop

# this section of code takes a long time to run, so commented out
# gres <- list()
# 
# for (istock in 1:nstocks){  
#   wd <- paste0(base.dir, gstocks[istock])
#   gres[[istock]] <- RunJitter(wd, gname, njitter, ploption) 
# }

# GOM cod - a few diff objfxn vals with one wacko one, fair number of NA

# GOM haddock - solid results with only one slightly diff objfxn val and 2 NA

# Pollock lots of realizations did not converge - model on edge - check for diffs in SSB trends
# bombed out on full due to NAN in likelihood - add error trap?

# redfish - takes a long time - rock solid estimates (only one diff res) but lots of did not converge

# snemawinter - 2 diff solutions with high freq (objfxn change 400!), see how diff the SSB trends are

# snemayt - rock solid solution almost all same value, only four did not converge 

# white hake - rock solid solution 

# save gres
setwd(base.dir)
# use the following line to save gres for later use
# dput(gres, file="dputgres.Rdat", control = "keepNA") # to make sure don't lose results
# use the following line to get it back
gres <- dget("dputgres.Rdat")

# get plots with ymaxlimit option turned on when necessary
# PlotJitter params are reslist, save.plots, od, plotf, showtitle, ymaxlimit=NULL
# used the following line changing istock values one at a time to determine myymaxs values
# PlotJitter(gres[[istock]], FALSE, base.dir, 'png', FALSE)
myymaxs <- c(NA, NA, 14400, 20530, NA, NA, NA)
mydir <- "C:\\Users\\chris.legault\\Desktop\\qqq\\jitter\\figs\\"
for (istock in 1:nstocks){
  PlotJitter(gres[[istock]], TRUE, base.dir, 'png', FALSE)
  shell(paste0("copy jitter_objfxn.png ", mydir, "jitter_objfxn_", gstocks[istock], ".png"))
  if (!is.na(myymaxs[istock])){
    PlotJitter(gres[[istock]], TRUE, base.dir, 'png', FALSE, myymaxs[istock])
    shell(paste0("copy jitter_objfxn.png ", mydir, "jitter_objfxn_", gstocks[istock], "_ymaxlimit.png"))
  }
}
graphics.off()

# compare some SSB time series for original and alternative solutions
ii <- 1:nstocks
irep <- 1:njitter

istock <- ii[gstocks == "snemawinter"]
gdf <- data.frame()
objvals <- unique(gres[[istock]]$objfxn)
objvals <- objvals[!is.na(objvals)]
objvals <- objvals[order(objvals)]
nobjvals <- length(objvals)
for (ival in 1:nobjvals){
  mysamp <- irep[which(gres[[istock]]$objfxn == objvals[ival])]
  if (length(mysamp) == 1){
    myrep <- mysamp
  } else {
    myrep <- base::sample(mysamp, 1)  
  }
  asap <- dget(paste0(base.dir, gstocks[istock], "\\jitter\\jitter", myrep, ".rdat"))
  thisdf <- data.frame(stock = gstocks[istock], 
                       rep = as.factor(myrep),
                       objfxn = objvals[ival],
                       Year = seq(asap$parms$styr, asap$parms$endyr),
                       SSB = asap$SSB)
  gdf <- rbind(gdf, thisdf)
}

p1 <- ggplot(gdf, aes(x=Year, y=SSB, color=rep)) +
  geom_point() +
  geom_line() +
  ggtitle(gstocks[istock]) +
  annotate("text", x=2010, y=20000, label="rep     objfxn") +
  annotate("text", x=2010, y=19000, label=paste0(gdf$rep[1], " = ", gdf$objfxn[1])) +
  annotate("text", x=2010, y=18000, label=paste0(gdf$rep[72], " = ", gdf$objfxn[72])) +
  theme_bw()
print(p1)
ggsave(p1, file=paste0(base.dir, "\\", "ssb_plot_", gstocks[istock], ".png"))

# next stock
istock <- ii[gstocks == "pollock"]
gdf <- data.frame()
objvals <- unique(gres[[istock]]$objfxn)
objvals <- objvals[!is.na(objvals)]
objvals <- objvals[objvals <= 14400]
objvals <- objvals[order(objvals)]
nobjvals <- length(objvals)
for (ival in 1:nobjvals){
  mysamp <- irep[which(gres[[istock]]$objfxn == objvals[ival])]
  if (length(mysamp) == 1){
    myrep <- mysamp
  } else {
    myrep <- base::sample(mysamp, 1)  
  }
  asap <- dget(paste0(base.dir, gstocks[istock], "\\jitter\\jitter", myrep, ".rdat"))
  thisdf <- data.frame(stock = gstocks[istock], 
                       rep = as.factor(myrep),
                       objfxn = objvals[ival],
                       Year = seq(asap$parms$styr, asap$parms$endyr),
                       SSB = asap$SSB)
  gdf <- rbind(gdf, thisdf)
}

p2 <- ggplot(gdf, aes(x=Year, y=SSB, color=rep)) +
  geom_point() +
  geom_line() +
  ggtitle(gstocks[istock]) +
  expand_limits(y = 0) +
  theme_bw()
print(p2)
ggsave(p2, file=paste0(base.dir, "\\", "ssb_plot_", gstocks[istock], ".png"))

# next stock
istock <- ii[gstocks == "gomcod"]
gdf <- data.frame()
objvals <- unique(gres[[istock]]$objfxn)
objvals <- objvals[!is.na(objvals)]
objvals <- objvals[order(objvals)]
nobjvals <- length(objvals)
for (ival in 1:nobjvals){
  mysamp <- irep[which(gres[[istock]]$objfxn == objvals[ival])]
  if (length(mysamp) == 1){
    myrep <- mysamp
  } else {
    myrep <- base::sample(mysamp, 1)  
  }
  asap <- dget(paste0(base.dir, gstocks[istock], "\\jitter\\jitter", myrep, ".rdat"))
  thisdf <- data.frame(stock = gstocks[istock], 
                       rep = as.factor(myrep),
                       objfxn = objvals[ival],
                       Year = seq(asap$parms$styr, asap$parms$endyr),
                       SSB = asap$SSB)
  gdf <- rbind(gdf, thisdf)
}

p3 <- ggplot(gdf, aes(x=Year, y=SSB, color=rep)) +
  geom_point() +
  geom_line() +
  ggtitle(gstocks[istock]) +
  expand_limits(y = 0) +
  theme_bw()
print(p3)
ggsave(p3, file=paste0(base.dir, "\\", "ssb_plot_", gstocks[istock], ".png"))

shell(paste0("copy ", base.dir, "\\ssb_plot_*.png ", mydir))

###################################################################################
# add note about jitter subdirectory getting overwritten if run both jitter and full ploptions
# ran full case for both GOM cod and haddock did well with just a few wacko results
###################################################################################

istock <- 1
njitter <- 200

wd <- paste0(base.dir, gstocks[istock])
## rename jitter subdir as jitter-jitter
#full1 <- RunJitter(wd, gname, njitter, ploption = "full") 
## rename jitter subdir as full-jitter
## rename jitter-jitter subdir as jitter

# compare jitter.pins for select params
myparam <- c("# sel_params[1]:", "# log_Fmult_year1:", "# index_sel_params[12]:", "# log_SR_scaler:")
np <- length(myparam)
pname <- paste0(base.dir, gstocks[istock], "\\", gname, ".par")
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
thisdf <- data.frame(source="orig", param=plab, jitter=0, val=unlist(asap.pin$dat[pval]), Converged="Yes")
pindf <- rbind(pindf, thisdf)

for (ijit in 1:njitter){
  pnamej <- paste0(base.dir, gstocks[istock], "\\jitter\\", "jitter", ijit, ".pin")
  rnamej <- paste0(base.dir, gstocks[istock], "\\jitter\\", "jitter", ijit, ".rdat")
  if (file.exists(pnamej)){
    asap.pin <- ReadASAP3PinFile(pnamej)
    converged <- ifelse(file.exists(rnamej), "Yes", "No")
    thisdf <- data.frame(source="jitter", param=plab, jitter=ijit, val=unlist(asap.pin$dat[pval]), Converged=converged)
    pindf <- rbind(pindf, thisdf)
  }
  pnamef <- paste0(base.dir, gstocks[istock], "\\full-jitter\\", "jitter", ijit, ".pin")
  rnamef <- paste0(base.dir, gstocks[istock], "\\full-jitter\\", "jitter", ijit, ".rdat")
  if (file.exists(pnamef)){
    asap.pin <- ReadASAP3PinFile(pnamef)
    converged <- ifelse(file.exists(rnamef), "Yes", "No")
    thisdf <- data.frame(source="full", param=plab, jitter=ijit, val=unlist(asap.pin$dat[pval]), Converged=converged)
    pindf <- rbind(pindf, thisdf)
  }
}  
pindf

jitter_pin_plot <- ggplot(pindf, aes(x=source, y=val, color=Converged)) +
  geom_jitter(width = 0.2, height = 0, alpha=0.5) +
  facet_wrap(~param, scales = "free_y") +
  scale_color_manual(values=c("blue", "red")) +
  theme_bw()

print(jitter_pin_plot)
ggsave(jitter_pin_plot, file=paste0(base.dir, "\\", "jitter_pin_plot_", gstocks[istock], ".png"))
shell(paste0("copy ", base.dir, "\\jitter_pin_plot_*.png ", mydir))
