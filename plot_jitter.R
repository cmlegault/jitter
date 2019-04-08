#' PlotJitter
#' 
#' Plot results of jitter analysis, objective function values by realization with line for original value.
#' @param reslist result of RunJitter function containing objective function values by realization and original value
#' @param save.plots saves indivdual plots 
#' @param od directory where plot will be saved
#' @param plotf format for individual plots 
#' @param showtitle option to add title for plot providing number of realizations better than original, equal to original, and not converged
#' @export

PlotJitter <- function(reslist, save.plots, od, plotf, showtitle){
  
  nna <- length(reslist$objfxn[is.na(reslist$objfxn)])
  neq <- length(which(reslist$objfxn == reslist$orig_objfxn))
  loreals <- which(reslist$objfxn < reslist$orig_objfxn)
  
  if (length(loreals) == 1){
    maintitle <- paste0("Realization ", loreals, " is less than original")
  }else if (length(loreals > 1)){
    maintitle <- paste0(length(loreals), " realizations are less than original")
  }else{
    maintitle <- "No realizations had objective function lower than original"
  }
  
  subtitle <- paste0(nna, " realizations did not converge and ", neq, " had same objfxn as orig")
  maintitle <- paste0(maintitle, "\n", subtitle)
  
  windows(record = TRUE)
  
  plot(1:length(reslist$objfxn), reslist$objfxn, xlab = "Realization", ylab = "Objective Function")
    abline(h = reslist$orig_objfxn, col="red")
    if (showtitle == TRUE) title(main = maintitle)
  
  if (save.plots==TRUE) savePlot(paste0(od, "jitter_objfxn.", plotf), type=plotf)

  return()
}
