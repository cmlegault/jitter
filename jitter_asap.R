# jitter_asap
# changes .pin file to use random restarts
# full approach selects over full range of parameters
# jitter approach based on SS3.30

jitter_asap <- function(in.pin, param.list, jitter=0.1){
  out.pin <- in.pin
  
  zmin <- qnorm(0.001)
  zmax <- qnorm(0.999)
  for (i in 1:length(param.list$type)){
    
    if (param.list$type[i] == "full"){
      nrows <- length(out.pin$dat[[i]])
      for (irow in 1:nrows){
        nvals <- length(out.pin$dat[[i]][[irow]])
        for (ival in 1:nvals){
          Pmin <- param.list$lowerbound[[i]][[irow]][ival]
          Pmax <- param.list$upperbound[[i]][[irow]][ival]
          newval <- runif(1, min = Pmin, max = Pmax)
          out.pin$dat[[i]][[irow]][ival] <- newval
        }
      }
    }
    
    if (param.list$type[i] == "jitter"){
      nrows <- length(out.pin$dat[[i]])
      for (irow in 1:nrows){
        nvals <- length(out.pin$dat[[i]][[irow]])
        for (ival in 1:nvals){
          Pval <- out.pin$dat[[i]][[irow]][[ival]]
          Pmin <- param.list$lowerbound[[i]][[irow]][ival]
          Pmax <- param.list$upperbound[[i]][[irow]][ival]
          Pmean <- (Pmin + Pmax) / 2
          Psigma <- (Pmax - Pmean) / zmax
          zval <- (Pval - Pmean) / Psigma
          kval <- dnorm(zval)
          temp <- runif(1)
          kjitter <- kval + (jitter * ((2 * temp) - 1))
          if (kjitter < 0.0001){
            newval <- Pmin + 0.1 * (Pval - Pmin)
          }else if (kjitter > 0.9999){
            newval <- Pmax - 0.1 * (Pmax - Pval)
          }else{
            zjitter <- qnorm(kjitter)
            newval <- Pmean + (Psigma * zjitter)
          }
          out.pin$dat[[i]][[irow]][ival] <- newval
        }
      }
    }
  }
  
  return(out.pin)
}
