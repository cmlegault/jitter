# plot_jitter
# make plots from result of jitter analysis

plot_jitter <- function(reslist, save.plots, od, plotf){
  windows(record = TRUE)
  
  plot(1:length(reslist$objfxn), reslist$objfxn, xlab = "Realization", ylab = "Objective Function")
    abline(h = reslist$orig_objfxn, col="red")
  
  if (save.plots==TRUE) savePlot(paste0(od, "jitter_objfxn.", plotf), type=plotf)

  return()
}