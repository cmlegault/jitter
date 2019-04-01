# jitter_asap
# changes .pin file to use random restarts

jitter_asap <- function(in.pin, param.list){
  out.pin <- in.pin
  
  for (i in 1:length(param.list$type)){
    if (param.list$type[i] == "full" | param.list$type[i] == "jitter"){
      nrows <- length(out.pin$dat[[i]])
      for (irow in 1:nrows){
        nvals <- length(out.pin$dat[[i]][[irow]])
        for (ival in 1:nvals){
          out.pin$dat[[i]][[irow]][ival] <- runif(1, 
                                                  param.list$lowerbound[[i]][[irow]][ival],
                                                  param.list$upperbound[[i]][[irow]][ival])
        }
      }
    }
  }
  return(out.pin)
}