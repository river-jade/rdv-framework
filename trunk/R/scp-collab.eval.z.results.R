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
cat( '\n----------------------------------' )

test.input <- '/Users/ascelin/tzar/outputdata/SCP_collab_S2_local_790sppXXX_8366/z_curves.txt'

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

setwd( PAR.current.run.directory )

#test <- read.csv(test.input, header=TRUE, col.names=FALSE, skip=2, sep=" ") 
z.results <- read.csv(PAR.final.Z.curves.filename, header=FALSE, skip=2, sep="")

# extract some info from the results 
prop.landscape.lost <- z.results[,Prop_landscape_lost.colno]
av.prop.rem <- z.results[,ave_prop_rem.colno]
min.prop.rem <- z.results[,min_prop_rem.colno]


# make a plot of the results
#pdf( "mean_prop_rem_curve.pdf" )
pdf( PAR.z.curves.graph )
plot(prop.landscape.lost, av.prop.rem, col=1, type='l')
dev.off ()
