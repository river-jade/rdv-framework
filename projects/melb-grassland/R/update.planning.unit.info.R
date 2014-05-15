#==============================================================================
#
#                            update.planning.unit.info.R
#
#  Runs at the start of each time step to updates the condition information 
#  for each planning unit. 
#
#  To run:
#      source( 'update.planning.unit.info.R' )
#
#
#  Create 24/05/09 - AG.
#
#==============================================================================


rm( list = ls( all=TRUE ));


    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

#source( 'w.R' );
#source( 'variables.R' );


source( 'utility.functions.R' )
source( 'dbms.functions.R' )      

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

source( 'variables.R' )


    #------------------------------------------------------------------
    #  Loop through each of the PUs and calculate the condition 
    #  scores for each planning unit. The store this
    #  
    #------------------------------------------------------------------


cur.cond.map.filename <-  paste (cond.model.root.filename, 
                                   current.time.step, '.txt', sep = "");

cur.cond.map <- as.matrix (read.table (cur.cond.map.filename));


pu.map <- as.matrix ( read.table( planning.units.filename  ) );

plan.units.vec <- get.unique.ids.from.map( planning.units.filename,
                                           non.habitat.indicator );

if( Debug.Test.With.given.num.of.PUs ) {
  plan.units.vec <- plan.units.vec[1:Debug.Num.of.PUs.to.test.with]
}


# make a data.frame to store the results for each pu

col.names <- c( 'TIME_STEP', 'ID', 'AREA', 'COST', 'AREA_OF_GRASSLAND',
               'MANAGEMENT_COST', 'TOTAL_COND_SCORE_SUM',
               'TOTAL_COND_SCORE_MEAN', 'TOTAL_COND_SCORE_MEDIAN',
               'TOTAL_COND_SCORE_SD', 'RESERVED',
               'DEVELOPED', 'LEAKED', 'IN_DEV_POOL', 'IN_OFFSET_POOL',
               'OFFSET_INTO_PU' );

PU.cond.data.frame <- data.frame( matrix( nrow = length(plan.units.vec),
                                          ncol = length(col.names) )
                                 );
colnames(PU.cond.data.frame) <- col.names;


ctr <- 0;


for( cur.pu in plan.units.vec ){

  ctr <- ctr + 1;
  
  indices.of.pixels.in.cur.pu <- which (pu.map == cur.pu);
  
  # work out the number of pixels in the current PU
  num.pixels.in.cur.pu <- length( indices.of.pixels.in.cur.pu );

  # the condition scores of all the pixels in the PU
  cur.pixel.cond.scores <- cur.cond.map[indices.of.pixels.in.cur.pu]

  # calculate statistics for the PU condition scores
  pu.cond.score.sum <- sum( cur.pixel.cond.scores );
  pu.cond.score.mean <- mean( cur.pixel.cond.scores );
  pu.cond.score.median <- median( cur.pixel.cond.scores );
  pu.cond.score.sd <- sd( cur.pixel.cond.scores );
  pu.num.pixels.grassland <- length( which( cur.pixel.cond.scores > 0 ));
  pu.managment.cost <- PAR.management.cost.per.pixel * pu.num.pixels.grassland;
  
  if(DEBUG)  cat( '\nPU num:', ctr, ' PU id:', cur.pu,
                '\n    num pixels =', num.pixels.in.cur.pu,
                '\n    cond score sum  =', pu.cond.score.sum,
                '\n    cond score mean  =', pu.cond.score.mean,
                '\n    cond score median  =', pu.cond.score.median,
                '\n    cond score sd  =', pu.cond.score.sd,
                '\n' );
  
  query <- paste( "select COST, RESERVED, DEVELOPED, LEAKED, IN_DEV_POOL,",
                 "IN_OFFSET_POOL, OFFSET_INTO_PU from", dynamicPUinfoTableName,
                 "where ID = ", cur.pu );
  cur.PU.info <- sql.get.data(PUinformationDBname , query)

 
  # Need the following format
  
  # 'TIME_STEP', 'ID', 'AREA', 'COST', 'AREA_OF_GRASSLAND',
  # 'MANAGEMENT_COST', 'TOTAL_COND_SCORE_SUM',
  # 'TOTAL_COND_SCORE_MEAN', 'TOTAL_COND_SCORE_MEDIAN',
  # 'TOTAL_COND_SCORE_SD' 'RESERVED' 'DEVELOPED' 'LEAKED'
  # 'IN_DEV_POOL' 'IN_OFFSET_POOL' 'OFFSET_INTO_PU'

  summary.PU.cond.vector <- c(current.time.step, 
                              cur.pu,
                              num.pixels.in.cur.pu,
                              cur.PU.info$COST,
                              pu.num.pixels.grassland,
                              pu.managment.cost,
                              pu.cond.score.sum, 
                              pu.cond.score.mean,
                              pu.cond.score.median, 
                              pu.cond.score.sd,
                              cur.PU.info$RESERVED,
                              cur.PU.info$DEVELOPED,
                              cur.PU.info$LEAKED,
                              cur.PU.info$IN_DEV_POOL,
                              cur.PU.info$IN_OFFSET_POOL,
                              cur.PU.info$OFFSET_INTO_PU
                              );

  
  PU.cond.data.frame[ctr,] <- summary.PU.cond.vector




}

 


    #------------------------------------------------------------------
    #  Now upate the PUinformation.dbms file that keeps track of all the 
    #  current info for each planning unit.
    #  
    #------------------------------------------------------------------


# save the resulst to the database

connect.to.database( CondDBname );
write.data.to.db(  PUcondTableName, PU.cond.data.frame )

close.database.connection();


# save the total cond score

pu.id.tot.pixels.grassland <-
  cbind( plan.units.vec, PU.cond.data.frame$AREA_OF_GRASSLAND );

update.db.pu.ids.with.multiple.values(dynamicPUinfoTableName,
                                      pu.id.tot.pixels.grassland,
                                      'AREA_OF_GRASSLAND')
pu.managment.cost.vec <-
  cbind( plan.units.vec, PU.cond.data.frame$MANAGEMENT_COST);

update.db.pu.ids.with.multiple.values(dynamicPUinfoTableName,
                                      pu.managment.cost.vec,
                                      'MANAGEMENT_COST')

pu.id.tot.cond <-
  cbind( plan.units.vec, PU.cond.data.frame$TOTAL_COND_SCORE_SUM );

update.db.pu.ids.with.multiple.values(dynamicPUinfoTableName,
                                      pu.id.tot.cond, 'TOTAL_COND_SCORE_SUM' );


pu.id.mean.cond <-
  cbind( plan.units.vec, PU.cond.data.frame$TOTAL_COND_SCORE_MEAN );

update.db.pu.ids.with.multiple.values(dynamicPUinfoTableName,pu.id.mean.cond,
                                      'TOTAL_COND_SCORE_MEAN' );

pu.id.median.cond <-
  cbind( plan.units.vec, PU.cond.data.frame$TOTAL_COND_SCORE_MEDIAN );

update.db.pu.ids.with.multiple.values(dynamicPUinfoTableName,pu.id.median.cond,
                                      'TOTAL_COND_SCORE_MEDIAN' );


# note that PUs with area of 1 pixel will have a SD of NA as taking the SD of
# a single value is undefined.

pu.id.sd.cond <-
  cbind( plan.units.vec, PU.cond.data.frame$TOTAL_COND_SCORE_SD );
update.db.pu.ids.with.multiple.values(dynamicPUinfoTableName,pu.id.sd.cond,
                                      'TOTAL_COND_SCORE_SD' )
 
