# examples.R
# code showing how to use the functions

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

######################################################
# Simple
wd <- "C:\\Users\\chris.legault\\Desktop\\jitter_asap"
od <- paste0(wd, "\\jitter\\")
asap.name <- "Simple"
njitter <- 3
#sjitter <- RunJitter(wd, asap.name, njitter, ploption = "jitter", save.plots = "TRUE", od, plotf="png")
sfull <- RunJitter(wd, asap.name, njitter, ploption = "full", save.plots = "TRUE", od, plotf="png")
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

library("ggplot2")
jitter_pin_plot <- ggplot(pindf, aes(x=source, y=val)) +
  geom_jitter(width = 0.2, height = 0) +
  facet_wrap(~param, scales = "free_y") +
  theme_bw()

print(jitter_pin_plot)
ggsave(jitter_pin_plot, file=paste0(fluke.dir, "\\jitter_pin_plot.png"))
######################################################

