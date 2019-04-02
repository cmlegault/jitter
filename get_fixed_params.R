# get_fixed_params

get_fixed_params <- function(asap.dat){
  names(asap.dat$dat)
  counter <- 0
  res <- data.frame()
  sel_block_option <- asap.dat$dat$sel_block_option
  sel_ini <- asap.dat$dat$sel_ini
  nages <- asap.dat$dat$n_ages
  for (iblock in 1:asap.dat$dat$n_fleet_sel_blocks){
    sel_ini_block <- sel_ini[[iblock]]
    if (sel_block_option[iblock] == 1){  # by age
      counter <- counter + 1:nages
      temp <- rep("estimated", nages)
      temp[sel_ini_block[1:nages, 2] <= 0] <- "fixed"
    }
    if (sel_block_option[iblock] == 2){  # single logistic
      counter <- counter + 1:2
      temp <- rep("estimated", 2)
      temp[sel_ini_block[(nages+1):(nages+2), 2] <= 0] <- "fixed"
    }
    if (sel_block_option[iblock] == 3){  # double logistic
      counter <- counter + 1:4
      temp <- rep("estimated", 4)
      temp[sel_ini_block[(nages+3):(nages+6), 2] <= 0] <- "fixed"
    }
    res <- rbind(res, data.frame(counter=counter, param=temp))
  }
  
  counter <- max(counter) + 1:6 
  temp <- rep("estimated", 6)
  if (asap.dat$dat$phase_F1 <= 0)       temp[1] <- "fixed"
  if (asap.dat$dat$phase_F_devs <= 0)   temp[2] <- "fixed"
  if (asap.dat$dat$phase_rec_devs <= 0) temp[3] <- "fixed"
  if (asap.dat$dat$phase_N1_devs <= 0)  temp[4] <- "fixed"
  if (asap.dat$dat$phase_q <= 0)        temp[5] <- "fixed"
  if (asap.dat$dat$phase_q_devs <= 0)   temp[6] <- "fixed"
  res <- rbind(res, data.frame(counter=counter, param=temp))
  counter <- max(counter)
  
  index_sel_option <- asap.dat$dat$index_sel_option
  index_sel_ini <- asap.dat$dat$index_sel_ini
  for (ind in 1:asap.dat$dat$n_indices){
    index_ini <- index_sel_ini[[ind]]
    if (index_sel_option[ind] == 1){  # by age
      counter <- counter + 1:nages
      temp <- rep("estimated", nages)
      temp[index_ini[1:nages, 2] <= 0] <- "fixed"
    }
    if (index_sel_option[ind] == 2){  # single logistic
      counter <- counter + 1:2
      temp <- rep("estimated", 2)
      temp[index_ini[(nages+1):(nages+2), 2] <= 0] <- "fixed"
    }
    if (index_sel_option[ind] == 3){  # double logistic
      counter <- counter + 1:4
      temp <- rep("estimated", 4)
      temp[sel_ini_block[(nages+3):(nages+6), 2] <= 0] <- "fixed"
    }
    res <- rbind(res, data.frame(counter=counter, param=temp))
  }
  
  counter <- max(counter) + 1:2 
  temp <- rep("estimated", 2)
  if (asap.dat$dat$phase_SR_scalar <= 0) temp[1] <- "fixed"
  if (asap.dat$dat$phase_steepness <= 0) temp[2] <- "fixed"
  res <- rbind(res, data.frame(counter=counter, param=temp))
  
  return(res)
}
