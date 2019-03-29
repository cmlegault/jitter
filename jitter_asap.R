get_rand_mfac <- function(asap.dat, repname, mfac){
  asap.adj <- asap.dat
  init_val <- asap.dat$dat[names(asap.dat$dat) == repname][[1]]
  adj_val <- runif(length(init_val), init_val / mfac, init_val * mfac)
  asap.adj$dat[names(asap.adj$dat) == repname][[1]] <- adj_val
  return(asap.adj)
}

get_rand_bound <- function(asap.dat, repname, lowbound, highbound){
  asap.adj <- asap.dat
  init_val <- asap.dat$dat[names(asap.dat$dat) == repname][[1]]
  adj_val <- runif(length(init_val), lowbound, highbound)
  asap.adj$dat[names(asap.adj$dat) == repname][[1]] <- adj_val
  return(asap.adj)
}

# jitter_asap
# changes .pin file to use random restarts

jitter_asap <- function(in.pin, param.list){
  out.pin <- in.pin
  
  for (i in 1:length(param.list$type)){
    if (param.list$type[i] == "full" | param.list$type[i] == "jitter"){
      nrows <- length(out.pin$dat[[i]])
      if (nrows == 1){
        nvals <- length(out.pin$dat[[i]][[1]])
        for (ival in 1:nvals){
          out.pin$dat[[i]][[ival]] <- runif(1, 
                                            param.list$lowerbound[[i]][[ival]],
                                            param.list$upperbound[[i]][[ival]])
        }
#        out.pin$dat[[i]][[1]] <- runif(nvals, param.list$lowerbound[i], param.list$upperbound[i])
      }else{
        for (irow in 1:nrows){
          nvals <- length(out.pin$dat[[i]][[irow]])
          for (ival in 1:nvals){
            out.pin$dat[[i]][[irow]][[ival]] <- runif(1, 
                        param.list$lowerbound[[i]][[irow]][[ival]],
                        param.list$upperbound[[i]][[irow]][[ival]])
          }
#          out.pin$dat[[i]][[irow]] <- runif(nvals, param.list$lowerbound[i], param.list$upperbound[i])
        }
      }
    }
  }
  return(out.pin)
}