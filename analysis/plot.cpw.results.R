
# source( 'plot.cpw.results.R' )

rm( list = ls( all=TRUE ))

source( "dbms.functions.r" )
source( "plot.results.functions.R" )

# Note: to print the graphs to pdf:
#       



PAR.x.lim <- c(0,500)
PAR.lty.vec <- rep(1,10)
PAR.lwd.vec <- rep(1,10)
PAR.col.vec <- 1:10
OPT.show.all.runs <- FALSE                      # Draw a line for each individual runs

PAR.line.width <- 1

PAR.plot.variable.location <- '/Users/ascelin/rdv/analysis/'

#PAR.runset.name <- 'FullTestAllScens'
#PAR.runset.name <- 'testResRandom2Q3'
#PAR.runset.name <- '01testInitCPWcond'
#PAR.runset.name <- 'AllScen_x10_inc_ranRes2'
#PAR.runset.name <- 'AllSx10_testCPWinitCond'                 # running with sampled init CPW cond.
#PAR.runset.name <- 'Allx10_testCPWinitCond_recreate_old'
#PAR.runset.name <- 'A10_CPWinitCond_100years'
PAR.runset.name <- 'T_new_ranRes'

#source("plot.variables.local.R")

path.to.data <- paste( PAR.plot.variable.location, PAR.runset.name, '/', sep = '')
variables.file.to.source <- paste( path.to.data,
                                  'plot.variables.', PAR.runset.name, '.R',
                                  sep = '')

source( variables.file.to.source )

par( mfrow = c (1,1))

#plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_SCORE_OF_ALL_CPW', y.lim=c(2000, 6800 ),
plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_SCORE_OF_ALL_CPW', y.lim=c(2200, 5700 ),
                     title="TOT SCORE OF ALL CPW", legend.op=TRUE)
dev.print( paste(path.to.data, "@1_SCORE_OF_ALL_CPW.pdf",sep=''), device = pdf )

#plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_AREA_OF_CPW', y.lim=c(3000, 10500 ),
plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_AREA_OF_CPW', y.lim=c(2800, 9500 ),
                     title="TOT SCORE OF ALL CPW", legend.op=TRUE, OPT.show.all.runs)
dev.print( paste(path.to.data, "@2_AREA_OF_ALL_CPW.pdf",sep=''), device = pdf )


par( mfrow = c (2,2))

plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_SCORE_OF_C1_CPW', y.lim=c(550, 2500 ),
#plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_SCORE_OF_C1_CPW', y.lim=c(1000, 2500 ),
                     title="TOT_SCORE_OF_C1_CPW", legend.op=FALSE, OPT.show.all.runs)

plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_AREA_OF_C1_CPW', y.lim=c(1000, 2850 ),
#plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_AREA_OF_C1_CPW', y.lim=c(1000, 2850 ),
                     title="TOT_AREA_OF_C1_CPW", legend.op=FALSE, OPT.show.all.runs)

plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_SCORE_OF_C2_CPW', y.lim=c(700, 2400 ),
#plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_SCORE_OF_C2_CPW', y.lim=c(850, 2200 ),
                     title="TOT_SCORE_OF_C2_CPW", legend.op=FALSE, OPT.show.all.runs)

plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_AREA_OF_C2_CPW', y.lim=c(700, 4000 ),
#plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_AREA_OF_C2_CPW', y.lim=c(1200, 3600 ),
                     title="TOT_SCORE_OF_C2_CPW", legend.op=FALSE, OPT.show.all.runs)
dev.print( paste(path.to.data, "@3_C1_C2_INFO.pdf",sep=''), device = pdf )


# new screen

plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_SCORE_OF_C3_CPW', y.lim=c(200, 1600 ),
#plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_SCORE_OF_C3_CPW', y.lim=c(150, 1200 ),
                     title="TOT_SCORE_OF_C3_CPW", legend.op=FALSE, OPT.show.all.runs)

plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_AREA_OF_C3_CPW', y.lim=c(200, 4000 ),
#plot.multiple.bands( list.of.scen.run.nums, plot.var='TOT_AREA_OF_C3_CPW', y.lim=c(400, 3500 ),
                     title="TOT_SCORE_OF_C3_CPW", legend.op=FALSE, OPT.show.all.runs)
dev.print( paste(path.to.data, "@4_C3_INFO.pdf",sep=''), device = pdf )
