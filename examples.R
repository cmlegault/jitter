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
asap.name <- "Simple"
njitter <- 3
myjitter <- run_jitter(wd, asap.name, njitter, ploption = "jitter", save.plots = "FALSE", od=wd, plotf="png")
myfull <- run_jitter(wd, asap.name, njitter, ploption = "full", save.plots = "TRUE", od=wd, plotf="png")
######################################################

######################################################
# temp comparison of jittered values
tdf <- matrix(NA, nrow = njitter, ncol = 1156)
for (ijit in 1:njitter){
  jname <- paste0(wd, "\\jitter\\jitter", ijit, ".pin")
  tpin <- read.asap3.pin.file(jname)
  tpun <- unlist(tpin$dat)
  tdf[ijit, ] <- tpun
}
tdf
summary(tdf[, 1:20])
######################################################

######################################################
# run fluke
fluke.dir <- "C:\\Users\\chris.legault\\Desktop\\jitter_asap\\fluke"
fluke.name <- "F2018_BASE"
wd <- paste0(fluke.dir,"\\myjitter") 
myjitter <- run_jitter(paste0(fluke.dir,"\\myjitter"), fluke.name, njitter=50, ploption = "jitter", save.plots = "FALSE", od=wd, plotf="png")
myfull <- run_jitter(paste0(fluke.dir,"\\myfull"), fluke.name, njitter=50, ploption = "full", save.plots = "FALSE", od=wd, plotf="png")
######################################################

