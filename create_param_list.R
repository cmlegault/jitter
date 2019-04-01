# create the upper and lower limits for each parameter
# if ploption = full then use full bounded range for parameter
# if ploption = jitter then use param plus minus 10% (make this an input???)

create_param_list <- function(ploption, asap.pin.obj){
  dat <- asap.pin.obj$dat
  comments <- asap.pin.obj$comments
  np <- length(comments)
  param.list <- list()
  param.list$type <- rep(NA, np)
  param.list$lowerbound <- list()
  param.list$upperbound <- list()

  if (ploption == "full"){
    
    param.list$type <- rep("full", np)
    
    p <- which(substring(comments, 1, 12) == "# sel_params")
    for (ip in p){
      param.list$lowerbound[[ip]] <- 0
      param.list$upperbound[[ip]] <- 1
    }
    
    p <- which(substring(comments, 1, 18) == "# index_sel_params")
    for (ip in p){
      param.list$lowerbound[[ip]] <- 0
      param.list$upperbound[[ip]] <- 1
    }
    
    p <- which(comments == "# log_Fmult_year1:")
    param.list$lowerbound[[p]] <- list()
    param.list$upperbound[[p]] <- list()
    param.list$lowerbound[[p]] <- rep(-15, length(dat[[p]][[1]]))
    param.list$upperbound[[p]] <- rep(2, length(dat[[p]][[1]]))
    
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
    param.list$lowerbound[[p]] <- rep(-15, length(dat[[p]][[1]]))
    param.list$upperbound[[p]] <- rep(15, length(dat[[p]][[1]]))

    p <- which(comments == "# log_N_year1_devs:")
    param.list$lowerbound[[p]] <- list()
    param.list$upperbound[[p]] <- list()
    param.list$lowerbound[[p]] <- rep(-15, length(dat[[p]][[1]]))
    param.list$upperbound[[p]] <- rep(15, length(dat[[p]][[1]]))

    p <- which(comments == "# log_q_year1:")
    param.list$lowerbound[[p]] <- list()
    param.list$upperbound[[p]] <- list()
    param.list$lowerbound[[p]] <- rep(-30, length(dat[[p]][[1]]))
    param.list$upperbound[[p]] <- rep(5, length(dat[[p]][[1]]))

    p <- which(comments == "# log_q_devs:")
    param.list$lowerbound[[p]] <- list()
    param.list$upperbound[[p]] <- list()
    for (i in 1:length(dat[[p]])){
      nvals <- length(dat[[p]][[i]])
      param.list$lowerbound[[p]][[i]] <- rep(-15, nvals)
      param.list$upperbound[[p]][[i]] <- rep(15, nvals)
    }

    p <- which(comments == "# log_SR_scaler:")
    param.list$lowerbound[[p]] <- -1
    param.list$upperbound[[p]] <- 200
    
    p <- which(comments == "# SR_steepness:")
    param.list$lowerbound[[p]] <- 0.20001
    param.list$upperbound[[p]] <- 1.0
  } # end of full ploption if statement

  if (ploption == "jitter"){
    
    param.list$type <- rep("jitter", np)
    
    for (i in 1:np){
      
      x <- dat[[i]]
      
      nrows <- length(x)
      param.list$lowerbound[[i]] <- list()
      param.list$upperbound[[i]] <- list()
      for (irow in 1:nrows){
        param.list$lowerbound[[i]][[irow]] <- dat[[i]][[irow]] - 0.1
        param.list$upperbound[[i]][[irow]] <- dat[[i]][[irow]] + 0.1
      }
    } 
    
    # add check for selectivity bounds < 0 or > 1
    
  } # end of jitter ploption if statement
  
  return(param.list)
}
