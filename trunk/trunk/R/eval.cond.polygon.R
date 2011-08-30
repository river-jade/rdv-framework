#=============================================================================
#
#                            eval.cond.polygon.R
#
#  Evaluate the condition of the landscape by summing various subsets
#  of the condition map: the whole map, the unreserved polygons, and
#  the reserved polygons. Note that this is for the case where no
#  raster maps are being used and all data is acessed from a database
#  that contains all the information from the shapefile attribute
#  table
#
#  For now this is just filler code, that needs to be filled in once
#  we decide what variables we want to save
#
#  To run:
#      source( 'eval.cond.polygon.R' )
#
#
#  Create 01/12/2010 - AG.
#  
#  Added code 
#
#
#=============================================================================


rm( list = ls( all=TRUE ))


    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'variables.R' )
source( 'dbms.functions.R' )      

# get the total condition of all parcels



get.all.PU.values.for <- function( db.field) {

  query <- paste( 'select', db.field, 'from', dynamicPUinfoTableName )  
  total.amount  <-  sql.get.data( PUinformationDBname, query)

  return( total.amount )
  
}

areas.of.CPW <- get.all.PU.values.for( "AREA_OF_CPW" ) 
areas.C1.CPW <- get.all.PU.values.for( "AREA_OF_C1_CPW" )
areas.C2.CPW <- get.all.PU.values.for( "AREA_OF_C2_CPW" )
areas.C3.CPW <- get.all.PU.values.for( "AREA_OF_C3_CPW" )

cond.scores.for.C1.CPW <- get.all.PU.values.for( "SCORE_OF_C1_CPW" )
cond.scores.for.C2.CPW <- get.all.PU.values.for( "SCORE_OF_C2_CPW" )
cond.scores.for.C3.CPW <- get.all.PU.values.for( "SCORE_OF_C3_CPW" )

tot.cond.C1.CPW <- sum( cond.scores.for.C1.CPW * areas.C1.CPW )
tot.cond.C2.CPW <- sum( cond.scores.for.C2.CPW * areas.C2.CPW )
tot.cond.C3.CPW <- sum( cond.scores.for.C3.CPW * areas.C3.CPW )
tot.cond.all.CPW <- sum( tot.cond.C1.CPW, tot.cond.C2.CPW, tot.cond.C3.CPW )

# round the numbers to 5 decimal places
landscape.cond.vec <- c( current.time.step,
                        sum( areas.of.CPW ),
                        sum( areas.C1.CPW ),
                        sum( areas.C2.CPW ),
                        sum( areas.C3.CPW ),
                        tot.cond.all.CPW,
                        tot.cond.C1.CPW,
                        tot.cond.C2.CPW,
                        tot.cond.C3.CPW,
                        rep(-999.999, 29)
                        )

landscape.cond.vec <- round(landscape.cond.vec, 5)

col.names <- c( 'TIME_STEP',

               # CPW params
               'TOT_AREA_OF_CPW',    
               'TOT_AREA_OF_C1_CPW', 
               'TOT_AREA_OF_C2_CPW', 
               'TOT_AREA_OF_C3_CPW', 
               'TOT_SCORE_OF_ALL_CPW',
               'TOT_SCORE_OF_C1_CPW',
               'TOT_SCORE_OF_C2_CPW',
               'TOT_SCORE_OF_C3_CPW',

               'TOTAL_COND_SCORE_SUM',
               'TOTAL_COND_SCORE_MEAN',
               'TOTAL_COND_SCORE_MEDIAN', 
               'RESERVED_COND_SCORE_SUM',
               'RESERVED_COND_SCORE_MEAN',
               'RESERVED_COND_SCORE_MEDIAN', 
               'UNRESERVED_COND_SCORE_SUM',
               'UNRESERVED_COND_SCORE_MEAN',
               'UNRESERVED_COND_SCORE_MEDIAN',
               'MANAGED_COND_SCORE_SUM',
               'MANAGED_COND_SCORE_MEAN',
               'MANAGED_COND_SCORE_MEDIAN', 
               'UNMANAGED_COND_SCORE_SUM',
               'UNMANAGED_COND_SCORE_MEAN',
               'UNMANAGED_COND_SCORE_MEDIAN',
               'SUMMED_COND_ABOVE_THRESH',
               'SUMMED_COND_BELOW_THRESH',
               'MEAN_COND_ABOVE_THRESH',
               'MEAN_COND_BELOW_THRESH',
               'MEDIAN_COND_ABOVE_THRESH',
               'MEDIAN_COND_BELOW_THRESH',
               'SD_COND_ABOVE_THRESH',
               'SD_COND_BELOW_THRESH',
               'DEV_POOL_COND_SCORE_SUM',
               'DEV_POOL_COND_SCORE_MEAN',
               'DEV_POOL_COND_SCORE_MEDIAN',
               'OFFSET_POOL_COND_SCORE_SUM',
               'OFFSET_POOL_COND_SCORE_MEAN',
               'OFFSET_POOL_COND_SCORE_MEDIAN'
               )

landscape.cond.data.frame <- data.frame( t(landscape.cond.vec) )

colnames( landscape.cond.data.frame ) <- col.names

connect.to.database( CondDBname )

write.data.to.db( LandscapeCondTableName, landscape.cond.data.frame )

close.database.connection()



# now record the value for each PU

connect.to.database( PUinformationDBname )
db.data.frame <- dbReadTable(globalSQLcon, dynamicPUinfoTableName)
close.database.connection()

TIME_STEP <- rep( current.time.step, dim(db.data.frame)[1])

df.inc.time <- cbind( TIME_STEP, db.data.frame )


connect.to.database( CondDBname )
write.data.to.db( PUcondTableName, df.inc.time )
close.database.connection()




