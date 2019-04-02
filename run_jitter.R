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
njitter <- 2

run_jitter <- function(wd, asap.name, njitter, ploption){
  
  # error checks for missing files 
  if (!file.exists(paste0(wd, "\\", asap.name, ".dat"))){
    return(paste0("Error: ", asap.name, ".dat not located in ", wd))
  }
  
  if (!file.exists(paste0(wd, "\\", asap.name, ".rdat"))){
    return(paste0("Error: ", asap.name, ".rdat not located in ", wd))
  }
  
  if (!file.exists(paste0(wd, "\\", asap.name, ".par"))){
    return(paste0("Error: ", asap.name, ".par not located in ", wd))
  }
  
  # directory and file handling
  # need to use setwd approach because ASAP3 creates files in current working directory
  orig.dir <- getwd()
  setwd(wd) 
  fname <- paste0(asap.name, ".dat")
  rname <- paste0(asap.name, ".rdat")
  pname <- paste0(asap.name, ".par")
  
  asap.dat <- read.asap3.dat.file(fname)
  asap.rdat <- dget(rname)
  asap.pin <- read.asap3.pin.file(pname)

  # check for jitter subdirectory, create if necessary
  if (!dir.exists("./jitter")){
    shell("mkdir jitter")
  } 
  
  # copy ASAP3.exe into jitter dir
  shell("copy ASAP3.exe jitter/ASAP3.EXE")
  
  # change working directory to jitter dir and clean up files
  setwd("./jitter")
  shell("del jitter*.pin", mustWork = NA, intern = TRUE)
  shell("del jitter*.rdat", mustWork = NA, intern = TRUE)

  # write orig file with ignore_guesses flag=1 to file [base]_no_init_guesses.dat
  nname <- paste0(asap.name, "_no_init_guesses.dat")
  no.init.guesses <- asap.dat
  no.init.guesses$dat$ignore_guesses <-  1
  write.asap3.dat.file(nname, no.init.guesses, "no initial guesses")
  
  # create base param.list using 
  # ploption = "full" for full range of parameters or 
  # ploption = "jitter" for solution plus minus 0.1
  ###### TODO check SS for how jitter is performed
  
  param.list <- create_param_list(ploption, asap.pin)

  # which parameters are not estimated
  fixed_params <- get_fixed_params(asap.dat)
  
  # check to make sure same number of parameters in par file and returned by get_fixed_params
  if (length(fixed_params[,1]) != length(param.list$type)){
    return("ERROR: different number of parameters in .par and calculated by get_fixed_params function")
  }
  
  # parameters not estimated stay at original values
  param.list$type[fixed_params[,2] == "fixed"] <- "fixed"
  
  # loop through njitter writing pin file with random values and running program
  # when run asap use -ainp jitterXXX.pin along with -ind no_init_guesses.dat 
  ####### TODO check for converged run
  objfxn <- rep(NA, njitter)
  ssbdf <- data.frame()
  for (ijit in 1:njitter){
    jname <- paste0("jitter", ijit, ".pin")
    asap.pin.jit <- jitter_asap(asap.pin, param.list)
    write.asap3.pin.file(jname, asap.pin.jit)
    shell("del asap3.rdat", intern = TRUE)
    shell("del asap3.std", intern = TRUE)
    shell(paste("ASAP3.exe -ind", nname, "-ainp", jname), intern=TRUE)
    if (file.exists("asap3.std")){
      shell(paste("copy asap3.rdat", paste0("jitter", ijit, ".rdat")), intern=TRUE)
      asap <- dget("asap3.rdat")
      objfxn[ijit] <- asap$like$lk.total
      ssb <- asap$SSB
      thisdf <- data.frame(jitter = ijit,
                           Year = asap$parms$styr:asap$parms$endyr,
                           SSB = ssb)
      ssbdf <- rbind(ssbdf, thisdf)
      print(paste("jitter", ijit, "complete, objective function =", objfxn[ijit]))
    }else{
      print(paste("jitter", ijit, "did not converge"))
    }
  }
  
  # put this in separate function and make optional
  # # plot obj fxn
  # plot(0:njitter,objfxn)
  # abline(h=objfxn[1])
  # points(0,objfxn[1],col="red",pch=16)
  
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
