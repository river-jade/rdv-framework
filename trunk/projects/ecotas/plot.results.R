

# To run
# source( '/Users/ascelin/analysis/src/rdv-framework/projects/ecotas/plot.results.R' )

rm( list = ls( all=TRUE ))

library('scatterplot3d')

df <- read.table( '/Users/ascelin/tzar/global_output/pop.traj.all.txt', header=TRUE)

#df2 <- subset( df, initPopSize==1000, select=c(-runId, -reps) )
df2 <- subset( df,  select=c(-runId, -reps) )

#Col names
# "initPopSize" "mu"  "sd"  "median"      "medianLog"   "var"         "varLog"     min minLog

par(mfrow=c(1,1 ) )
#plot( df2$sd, df2$varLog)


scatterplot3d( df2$mu, df2$sd, df2$var,
              pch=20, highlight.3d=TRUE, )


scatterplot3d( df2$mu, df2$sd, df2$median,
              pch=20, highlight.3d=TRUE, )

scatterplot3d( df2$initPopSize, df2$sd, df2$median,
              pch=20, highlight.3d=TRUE, )


scatterplot3d( df2$mu, df2$sd, df2$min,
              pch=20, highlight.3d=TRUE, xlab='mu', ylab='sd', zlab='min population' )
