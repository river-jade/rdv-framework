

# source ( 'limit.evolution.of.CPW.initial.condition.R' ) 


# This is to i) make sure that no CPW evolves to have a greater score
# that its initial condition and ii) tomake sure that if the score of
# CPW gets to zero then the area is set to zero and iii) if a
# threshold is set such that when CPW falls below this score it is
# then set to zero

rm( list = ls( all=TRUE ))
source( 'dbms.functions.R' )   
source( 'variables.R')

connect.to.database( PUinformationDBname )
  
# First read the database into a data.frame
PU.df <- dbReadTable(globalSQLcon, dynamicPUinfoTableName )

#
# Now update the values within the data frame:
#



# 1. If any scores evolved above what they should set them back to the
# max allowed for their category

#     this was the initial code where each parcel was given a fixed inital condition
#ind.of.c1 <- which( PU.df$SCORE_OF_C1_CPW > PAR.max.cond.of.HMV.CPW )
#ind.of.c2 <- which( PU.df$SCORE_OF_C2_CPW > PAR.max.cond.of.MMV.CPW )
#ind.of.c3 <- which( PU.df$SCORE_OF_C3_CPW > PAR.max.cond.of.LMV.CPW )

#if( length(ind.of.c1) > 0 ) PU.df$SCORE_OF_C1_CPW[ind.of.c1] <- PAR.max.cond.of.HMV.CPW 
#if( length(ind.of.c2) > 0 ) PU.df$SCORE_OF_C2_CPW[ind.of.c2] <- PAR.max.cond.of.MMV.CPW 
#if( length(ind.of.c3) > 0 ) PU.df$SCORE_OF_C3_CPW[ind.of.c3] <- PAR.max.cond.of.LMV.CPW 

# Now each parcel is given a condition based on sampling from a
# truncated normal dist so need to read in all the initial values

# Get the inital values of all the parcels

source( PAR.init.CPW.score.filename )        # this creates a dataframe called CPW.init.vals 

ind.of.c1 <- which( PU.df$SCORE_OF_C1_CPW > CPW.init.vals$C1.init.vals )
ind.of.c2 <- which( PU.df$SCORE_OF_C2_CPW > CPW.init.vals$C2.init.vals )
ind.of.c3 <- which( PU.df$SCORE_OF_C3_CPW > CPW.init.vals$C3.init.vals )

if( length(ind.of.c1) > 0 ) PU.df$SCORE_OF_C1_CPW[ind.of.c1] <- CPW.init.vals$C1.init.vals[ind.of.c1]
if( length(ind.of.c2) > 0 ) PU.df$SCORE_OF_C2_CPW[ind.of.c2] <- CPW.init.vals$C2.init.vals[ind.of.c2]
if( length(ind.of.c3) > 0 ) PU.df$SCORE_OF_C3_CPW[ind.of.c3] <- CPW.init.vals$C3.init.vals[ind.of.c3]


# 2. If any scores went to zero, then set the area of CPW to be zero for those parcels.

ind2.of.c1 <- which( (PU.df$SCORE_OF_C1_CPW < PAR.min.cond.to.count.as.cpw) & (PU.df$AREA_OF_C1_CPW > 0))
ind2.of.c2 <- which( (PU.df$SCORE_OF_C2_CPW < PAR.min.cond.to.count.as.cpw) & (PU.df$AREA_OF_C2_CPW > 0))
ind2.of.c3 <- which( (PU.df$SCORE_OF_C3_CPW < PAR.min.cond.to.count.as.cpw) & (PU.df$AREA_OF_C3_CPW > 0))


browser()


if( length(ind2.of.c1) > 0 ) {
  PU.df$AREA_OF_CPW[ind2.of.c1] <- PU.df$AREA_OF_CPW[ind2.of.c1] - PU.df$AREA_OF_C1_CPW[ind2.of.c1]

  # this is to catch rounding errors
  PU.df$AREA_OF_CPW[ind2.of.c1] <- round( PU.df$AREA_OF_CPW[ind2.of.c1], 2)

  PU.df$AREA_OF_C1_CPW[ind2.of.c1] <- 0
  PU.df$SCORE_OF_C1_CPW[ind2.of.c1] <- 0
  stopifnot( PU.df$AREA_OF_CPW[ind2.of.c1] >= 0  )
}

if( length(ind2.of.c2) > 0 ) {
  PU.df$AREA_OF_CPW[ind2.of.c2] <- PU.df$AREA_OF_CPW[ind2.of.c2] - PU.df$AREA_OF_C2_CPW[ind2.of.c2]
  
  # this is to catch rounding errors
  PU.df$AREA_OF_CPW[ind2.of.c2] <- round( PU.df$AREA_OF_CPW[ind2.of.c2], 2)

  PU.df$AREA_OF_C2_CPW[ind2.of.c2] <- 0
  PU.df$SCORE_OF_C2_CPW[ind2.of.c2] <- 0
  stopifnot( PU.df$AREA_OF_CPW[ind2.of.c2] >= 0  )
}

if( length(ind2.of.c3) > 0 ) {
  PU.df$AREA_OF_CPW[ind2.of.c3] <- PU.df$AREA_OF_CPW[ind2.of.c3] - PU.df$AREA_OF_C3_CPW[ind2.of.c3]
  
  # this is to catch rounding errors
  PU.df$AREA_OF_CPW[ind2.of.c3] <- round( PU.df$AREA_OF_CPW[ind2.of.c3], 2)
  
  PU.df$AREA_OF_C3_CPW[ind2.of.c3] <- 0
  PU.df$SCORE_OF_C3_CPW[ind2.of.c3] <- 0
  stopifnot( PU.df$AREA_OF_CPW[ind2.of.c3] >= 0  )

}



# Also if the scores of all categories are zero then set the AREA_OF_CPW to zero


# Remove the old table from the database (it'll be recreated when we
# dump the new data.frame to the database)
query <- paste( "DROP TABLE", dynamicPUinfoTableName )
sql.res <- dbSendQuery( globalSQLcon, query )
res <- dbClearResult( sql.res)

# Write the new dataframe to the database
res <- dbWriteTable(globalSQLcon, dynamicPUinfoTableName, PU.df )
 
close.database.connection()


