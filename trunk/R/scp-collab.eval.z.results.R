
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



get.landscape.lost.when.av.spp.prop.remain.is <- function( spp.prop ) {
  indices <- which( av.prop.rem > spp.prop )

  if( length( indices )  > 0 ){
    prop.landscape <- prop.landscape.lost[max( indices )]
  } else {
    prop.landscape <- 0
  }

  return(prop.landscape)
}


# calcualte the prop of the landscape that needs to be removed for
# different mean spp proportions to be left and write it to file

cat( 'av_spp_rep', 'prop_landscap\n', file=PAR.z.mean.props.summary.filename, append=TRUE)

for( x in c(0.1,0.2,0.3, 0.4) ) {
  prop.rem <- get.landscape.lost.when.av.spp.prop.remain.is(x)
  cat( '\n Prop landscape when av spp rep =', x, 'is', prop.rem )
  cat( x, prop.rem, '\n', file=PAR.z.mean.props.summary.filename, append=TRUE)
}
cat('\n')

    #--------------------------------------------
    # Make a plot of the results
    #--------------------------------------------

pdf( PAR.z.curves.graph )
plot(prop.landscape.lost, av.prop.rem, col=1, type='l')
dev.off ()

