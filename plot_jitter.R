# plot_jitter
# make plots from result of jitter analysis

plot_jitter <- function(reslist, asap.rdat, save.plots, od, plotf){
  windows(record = TRUE)
  
  plot(1:length(reslist$objfxn), reslist$objfxn, xlab = "Realization", ylab = "Objective Function")
    abline(h = asap.rdat$like$lk.total, col="red")
  
  if (save.plots==TRUE) savePlot(paste0(od, "jitter_objfxn.", plotf), type=plotf)

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
    
  dev.off()
  return()
}