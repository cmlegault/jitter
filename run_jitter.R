# code to run jitter asap

# rem to set working directory to code directory

#library("ggplot2")

source("Read.ASAP3.dat.file.R")
source("Read.ASAP3.pin.file.R")
source("create_param_list.R")
source("get_fixed_params.R")
source("Write.ASAP3.dat.file.R")
source("Write.ASAP3.pin.file.R")
source("jitter_asap.R")

wd <- "C:\\Users\\chris.legault\\Desktop\\jitter_asap"
asap.name <- "Simple"
njitter <- 10

run_jitter <- function(wd, asap.name, njitter, ploption){
  
  # error checks for missing files 
  if (!exists(paste0(wd, "\\", asap.name, ".dat"))){
    return(paste0("Error: ", asap.name, ".dat not located in ", wd))
  }
  
  if (!exists(paste0(wd, "\\", asap.name, ".rdat"))){
    return(paste0("Error: ", asap.name, ".rdat not located in ", wd))
  }
  
  if (!exists(paste0(wd, "\\", asap.name, ".par"))){
    return(paste0("Error: ", asap.name, ".par not located in ", wd))
  }
  
  # directory and file handling
  orig.dir <- getwd()
  setwd(wd) # need to use this approach due to running ASAP3 from within function, creates files in current working directory
  fname <- paste0(asap.name, ".dat")
  pname <- paste0(asap.name, ".par")
  
  asap.dat <- read.asap3.dat.file(fname)
  
  # check for jitter subdirectory, create if necessary
  if (!dir.exists("./jitter")){
    shell("mkdir jitter")
  } 
  
  # copy ASAP3.exe into jitter dir
  shell("copy ASAP3.exe jitter/ASAP3.EXE")
  
  # change working directory to jitter dir and clean up files
  setwd("./jitter")
  # TODO remove previous jitter files so no confusion
  
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
  
  # create base param.list using 
  # ploption = "full" for full range of parameters or 
  # ploption = "jitter" for solution plus minus 0.1
  # TODO check SS for how jitter is performed
  
  param.list <- create_param_list(ploption, asap.pin.obj)

  # which parameters are not estimated
  fixed_params <- get_fixed_params(asap.dat)
  
  if (length(fixed_params[,1]) != length(param.list$type)) print("ERROR")
  
  param.list$type[fixed_params[,2] == "fixed"] <- "fixed"
  
  # loop through njitter writing pin file with random values and running program
  # when run asap use -ainp jitterXXX.pin along with -ind no_init_guesses.dat 
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
    asap <- dget(paste0(wd,"\\jitter\\jitter", ijit, ".rdat"))
    objfxn[ijit] <- asap$like$lk.total
  }
  objfxn <- c(objfxn, orig$like$lk.total)
  
  # put this in separate function and make optional
  # # plot obj fxn
  # plot(0:njitter,objfxn)
  # abline(h=objfxn[1])
  # points(0,objfxn[1],col="red",pch=16)
  
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
  
  # put these in separate function and make optional
  # #g <- ggplot(ssbdf, aes(x=Year, y=SSB, color=as.factor(jitter))) +
  # #  geom_line() +
  # #  theme_bw()
  # #
  # #print(g)
  # 
  # g <- ggplot(ssbdf, aes(x=Year, y=SSB, group=Year)) +
  #   geom_boxplot() +
  #   theme_bw()
  # 
  # print(g)

  # change back to original directory
  setwd(orig.dir)
  return(list(objfxn=objfxn, ssbdf=ssbdf))
}

# to run the function
# ploption can be "jitter" or "full"
run_jitter(wd, asap.name, njitter, ploption = "jitter")
