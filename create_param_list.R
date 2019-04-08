# create the upper and lower limits for each parameter based on ASAP tpl bounded parameter values
# uses list of lists appraoch regardless of number of values

CreateParamList <- function(asap.pin.obj){
  
  dat <- asap.pin.obj$dat
  comments <- asap.pin.obj$comments
  np <- length(comments)
  
  param.list <- list()
  param.list$type <- rep(NA, np) # placeholder, will be filled in later
  param.list$lowerbound <- list()
  param.list$upperbound <- list()

  p <- which(substring(comments, 1, 12) == "# sel_params")
  for (ip in p){
    param.list$lowerbound[[ip]] <- list()
    param.list$upperbound[[ip]] <- list()
    param.list$lowerbound[[ip]][[1]] <- 0
    param.list$upperbound[[ip]][[1]] <- 1
  }
  
  p <- which(substring(comments, 1, 18) == "# index_sel_params")
  for (ip in p){
    param.list$lowerbound[[ip]] <- list()
    param.list$upperbound[[ip]] <- list()
    param.list$lowerbound[[ip]][[1]] <- 0
    param.list$upperbound[[ip]][[1]] <- 1
  }
  
  p <- which(comments == "# log_Fmult_year1:")
  param.list$lowerbound[[p]] <- list()
  param.list$upperbound[[p]] <- list()
  param.list$lowerbound[[p]][[1]] <- rep(-15, length(dat[[p]][[1]]))
  param.list$upperbound[[p]][[1]] <- rep(2, length(dat[[p]][[1]]))
  
  p <- which(comments == "# log_Fmult_devs:")
  param.list$lowerbound[[p]] <- list()
  param.list$upperbound[[p]] <- list()
  for (i in 1:length(dat[[p]])){
    nvals <- length(dat[[p]][[i]])
    param.list$lowerbound[[p]][[i]] <- rep(-15, nvals)
    param.list$upperbound[[p]][[i]] <- rep(15, nvals)
  }
  
  p <- which(comments == "# log_recruit_devs:")
  param.list$lowerbound[[p]] <- list()
  param.list$upperbound[[p]] <- list()
  param.list$lowerbound[[p]][[1]] <- rep(-15, length(dat[[p]][[1]]))
  param.list$upperbound[[p]][[1]] <- rep(15, length(dat[[p]][[1]]))
  
  p <- which(comments == "# log_N_year1_devs:")
  param.list$lowerbound[[p]] <- list()
  param.list$upperbound[[p]] <- list()
  param.list$lowerbound[[p]][[1]] <- rep(-15, length(dat[[p]][[1]]))
  param.list$upperbound[[p]][[1]] <- rep(15, length(dat[[p]][[1]]))
  
  p <- which(comments == "# log_q_year1:")
  param.list$lowerbound[[p]] <- list()
  param.list$upperbound[[p]] <- list()
  param.list$lowerbound[[p]][[1]] <- rep(-30, length(dat[[p]][[1]]))
  param.list$upperbound[[p]][[1]] <- rep(5, length(dat[[p]][[1]]))
  
  p <- which(comments == "# log_q_devs:")
  param.list$lowerbound[[p]] <- list()
  param.list$upperbound[[p]] <- list()
  for (i in 1:length(dat[[p]])){
    nvals <- length(dat[[p]][[i]])
    param.list$lowerbound[[p]][[i]] <- rep(-15, nvals)
    param.list$upperbound[[p]][[i]] <- rep(15, nvals)
  }
  
  p <- which(comments == "# log_SR_scaler:")
  param.list$lowerbound[[p]] <- list()
  param.list$upperbound[[p]] <- list()
  param.list$lowerbound[[p]][[1]] <- -1
  param.list$upperbound[[p]][[1]] <- 200
  
  p <- which(comments == "# SR_steepness:")
  param.list$lowerbound[[p]] <- list()
  param.list$upperbound[[p]] <- list()
  param.list$lowerbound[[p]][[1]] <- 0.20001
  param.list$upperbound[[p]][[1]] <- 1.0
  
  return(param.list)
}
