# write.asap3.pin.file
# based on write.asap3.dat.file, uses list of lists approach regardless of number of values

write.asap3.pin.file <- function(fname, pin.object){
  # fname <- 'jitter.pin'; pin.object <- asap3.pin.obj
  
  # Create file with one comment
  write('# File created with write.asap3.pin.file function', file=fname, append=FALSE)
    
  # File data and comments
  dat <- pin.object$dat
  comments <- pin.object$comments
    
  for (i in 1:length(dat)){
    x <- dat[[i]]
    write(comments[i], file=fname, append=TRUE)

    nrows <- length(dat[[i]])
    
    for (irow in 1:nrows){
      nvals <- length(dat[[i]][[irow]])
      write(dat[[i]][[irow]], file=fname, append=TRUE, ncolumns = nvals)
    }

  }  # End of "i" for loop
  
} # End of function      


