# code to run jitter asap

# rem to set working directory to code directory

library("ggplot2")

source("Read.ASAP3.dat.file.R")
source("Read.ASAP3.pin.file.R")
source("get_fixed_params.R")
source("Write.ASAP3.dat.file.R")
source("Write.ASAP3.pin.file.R")
source("jitter_asap.R")

fname <- "Simple.dat"
pname <- paste0(substr(fname, 1, nchar(fname) - 3), "p01")
njitter <- 100

asap.dat <- read.asap3.dat.file(fname)

# check for jitter subdirectory, create if necessary
if (!dir.exists("./jitter")){
  shell("mkdir jitter")
} 

# copy ASAP3.exe into jitter dir
shell("copy ASAP3.exe jitter/ASAP3.EXE")

# change working directory to jitter dir (remember to change working directory back)
base.dir <- getwd()
setwd("./jitter")

# write orig asap input file 
header.text <- "original ASAP run"
write.asap3.dat.file(fname,asap.dat,header.text)

# run original file and save important bits
shell("del asap3.rdat", mustWork = NA)
shell(paste("ASAP3.exe -ind", fname), intern=TRUE)
shell("copy asap3.rdat orig.rdat")
shell("copy asap3.par jitter.pin")
orig <- dget("orig.rdat") 
asap.pin.obj <- read.asap3.pin.file("jitter.pin")

# this is how to write the pin file
##write.asap3.pin.file('delme.pin', asap.pin.obj)

# delete everything except .exe, .rdat, and .pin needed???

# write orig file with ignore_guesses flag=1 to file no_init_guesses.dat
no.init.guesses <- asap.dat
no.init.guesses$dat$ignore_guesses <-  1
write.asap3.dat.file("no_init_guesses.dat", no.init.guesses, "no initial guesses")



# figure out which parameters are being jittered (non-estimated params stay at orig values)
# type possible values = "fixed", "jitterbound", "jitterfactor"
## TODO check for parameters estimated, create function to fill in param.list values, figure out sel params
comments <- asap.pin.obj$comments
np <- length(comments)
param.list <- list()
param.list$type <- rep(NA, np)
param.list$lowerbound <- rep(NA, np)
param.list$upperbound <- rep(NA, np)
param.list$mfactor <- rep(NA, np)

p <- which(substring(comments, 1, 12) == "# sel_params")
param.list$type[p] <- "jitterbound"
param.list$lowerbound[p] <- 0
param.list$upperbound[p] <- 1

p <- which(substring(comments, 1, 18) == "# index_sel_params")
param.list$type[p] <- "jitterbound"
param.list$lowerbound[p] <- 0
param.list$upperbound[p] <- 1

p <- which(comments == "# log_Fmult_year1:")
param.list$type[p] <- "jitterbound"
param.list$lowerbound[p] <- -15
param.list$upperbound[p] <- 2

p <- which(comments == "# log_Fmult_devs:")
param.list$type[p] <- "jitterbound"
param.list$lowerbound[p] <- -15
param.list$upperbound[p] <- 15

p <- which(comments == "# log_recruit_devs:")
param.list$type[p] <- "jitterbound"
param.list$lowerbound[p] <- -15
param.list$upperbound[p] <- 15

p <- which(comments == "# log_N_year1_devs:")
param.list$type[p] <- "jitterbound"
param.list$lowerbound[p] <- -15
param.list$upperbound[p] <- 15

p <- which(comments == "# log_q_year1:")
param.list$type[p] <- "jitterbound"
param.list$lowerbound[p] <- -30
param.list$upperbound[p] <- 5

p <- which(comments == "# log_q_devs:")
param.list$type[p] <- "jitterbound"
param.list$lowerbound[p] <- -15
param.list$upperbound[p] <- 15

p <- which(comments == "# log_SR_scaler:")
param.list$type[p] <- "jitterbound"
param.list$lowerbound[p] <- -1
param.list$upperbound[p] <- 200

p <- which(comments == "# SR_steepness:")
param.list$type[p] <- "jitterbound"
param.list$lowerbound[p] <- 0.20001
param.list$upperbound[p] <- 1.0


# temp for Simple.dat
# fixing sel and q devs params
#param.list$type[c(1:10, 16, 19:28)] <- "fixed"


fixed_params <- get_fixed_params(asap.dat)

if (length(fixed_params[,1]) != length(param.list$type)) print("ERROR")

param.list$type[fixed_params[,2] == "fixed"] <- "fixed"

# loop through njitter writing pin file with random values and running program
# when run asap use -ainp jitterXXX.pin along with -ind no_init_guesses.dat 
# save .rdat file to jitterXXX.rdat 
# summarize results

for (ijit in 1:njitter){
  jname <- paste0("jitter", ijit, ".pin")
  asap.pin.jit <- jitter_asap(asap.pin.obj, param.list)
  write.asap3.pin.file(jname, asap.pin.jit)
  shell("del asap3.rdat", intern = TRUE)
  shell(paste("ASAP3.exe -ind no_init_guesses.dat -ainp", jname), intern=TRUE)
  shell(paste("copy asap3.rdat", paste0("jitter", ijit, ".rdat")), intern=TRUE)
  print(paste("jitter", ijit, "complete"))
}

# get obj fxn
# TODO make sure don't include the bad runs
objfxn <- rep(NA, njitter)
for (ijit in 1:njitter){
  asap <- dget(paste0("jitter", ijit, ".rdat"))
  objfxn[ijit] <- asap$like$lk.total
}
objfxn <- c(orig$like$lk.total, objfxn)

# plot obj fxn
plot(0:njitter,objfxn)
abline(h=objfxn[1])
points(0,objfxn[1],col="red",pch=16)

# compare SSB time series
ssbdf <- data.frame()
years <- asap$parms$styr:asap$parms$endyr
for (ijit in 1:njitter){
  asap <- dget(paste0("jitter", ijit, ".rdat"))
  ssb <- asap$SSB
  thisdf <- data.frame(jitter = ijit,
                       Year = years,
                       SSB = ssb)
  ssbdf <- rbind(ssbdf, thisdf)
}

#g <- ggplot(ssbdf, aes(x=Year, y=SSB, color=as.factor(jitter))) +
#  geom_line() +
#  theme_bw()
#
#print(g)

g <- ggplot(ssbdf, aes(x=Year, y=SSB, group=Year)) +
  geom_boxplot() +
  theme_bw()

print(g)
# change back to original directory