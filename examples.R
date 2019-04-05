# examples.R
# code showing how to use the functions

# rem to set working directory to code directory for now
# won't need to do this once part of ASAPplots

source("Read.ASAP3.dat.file.R")
source("Read.ASAP3.pin.file.R")
source("create_param_list.R")
source("get_fixed_params.R")
source("Write.ASAP3.dat.file.R")
source("Write.ASAP3.pin.file.R")
source("jitter_asap.R")
source("run_jitter.R")
source("plot_jitter.R")

######################################################
# Simple
wd <- "C:\\Users\\chris.legault\\Desktop\\jitter_asap"
od <- paste0(wd, "\\jitter\\")
asap.name <- "Simple"
njitter <- 30
#sjitter <- run_jitter(wd, asap.name, njitter, ploption = "jitter", save.plots = "TRUE", od, plotf="png")
sfull <- run_jitter(wd, asap.name, njitter, ploption = "full", save.plots = "TRUE", od, plotf="png")
######################################################


######################################################
# fluke
fluke.dir <- "C:\\Users\\chris.legault\\Desktop\\jitter_asap\\fluke"
fluke.name <- "F2018_BASE"
njitter <- 50

wd <- paste0(fluke.dir,"\\myjitter") 
od <- paste0(wd, "\\jitter\\")
fjitter <- run_jitter(wd, fluke.name, njitter, ploption = "jitter", save.plots = "FALSE", od, plotf="png")

wd <- paste0(fluke.dir,"\\myfull")
od <- paste0(wd, "\\jitter\\")
ffull <- run_jitter(wd, fluke.name, njitter, ploption = "full", save.plots = "FALSE", od, plotf="png")
######################################################

