# Does all the file copying then
# Runs zonation 

# source( 'scp-collab.eval.z.results.R' )

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------


rm( list = ls( all=TRUE ))

source( 'variables.R' )

cat( '\n----------------------------------' )
cat( '\n  scp-collab.eval.z.results.R     ' )
cat( '\n----------------------------------\n' )

    #--------------------------------------------
    # Read in the .curves.txt file and extract relevant bits
    #--------------------------------------------

setwd( PAR.current.run.directory )
z.results <- read.csv(PAR.final.Z.curves.filename, header=FALSE, skip=2, sep="")

# The structure of the file columns are
# 1 - Prop_landscape_lost
# 2 - cost_needed_for_top_fraction
# 3 - min_prop_rem
# 4 - ave_prop_rem
# 5 - W_prop_rem
# 6 - ext-1 ext-2 prop for each species remaining at level of removal ...
Prop_landscape_lost.colno <- 1
ave_prop_rem.colno <- 4
min_prop_rem.colno <- 3

# extract some info from the results 
prop.landscape.lost <- z.results[,Prop_landscape_lost.colno]
av.prop.rem <- z.results[,ave_prop_rem.colno]
min.prop.rem <- z.results[,min_prop_rem.colno]

    #--------------------------------------------
    # 
    #--------------------------------------------

prop.to.eval <- 0.3

indices <- which(av.prop.rem > prop.to.eval )

if( length( indices )  > 0 ){
  prop.landscape <- prop.landscape.lost[max( indices )]
} else {
  prop.landscape <- 0
}

cat('\nProp of landscape lost to retain an average of proporstion of', prop.to.eval,
    'over all spp =', prop.landscape, '\n') 

    #--------------------------------------------
    # Make a plot of the results
    #--------------------------------------------

pdf( PAR.z.curves.graph )
plot(prop.landscape.lost, av.prop.rem, col=1, type='l')
dev.off ()

