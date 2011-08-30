
    #------------------------------------------------------------
    #            reserve.condition.R                            #
    #  Select parcels based on their grassland condition score  #
    #  Strategy will be try to select parces that have a mean   #
    #  cond score above the grassland threshold. Out of this    #
    #  selection choose parcels in order of tot cond score till #
    #  budget is exhausted.                                     #
    #                                                           #
    #  Created 25/5/09 - AG                                     #
    #                                                           #
    #                                                           #
    #                                                           #
    #                                                           #
    #                                                           #
    #    source('reserve.condition.R' )                    #
    #-----------------------------------------------------------#


rm( list = ls( all=TRUE ));

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'w.R' );
source( 'variables.R' );
source( 'utility.functions.R' );
source( 'dbms.functions.R' )  

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

# set in python....

    #------------------------------------------------------------
    #  Outputs/returned
    #------------------------------------------------------------


    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------

if (use.run.number.as.seed) {
  set.seed(random.seed)
}

planning.units.filename <- paste(planning.units.filename.base, '.txt',sep='');


# first define a function to be used several times below

cat( '\n------------------------------------' );
cat( '\nReserve Selection Method: CONDITION'   );
cat( '\n------------------------------------' );


# read in the PU id map
cur.pid.map <- as.matrix( read.table( planning.units.filename ) );


# work out all the unique PU ids
#initial.pu.IDs <- cur.pid.map[ cur.pid.map != non.habitat.indicator ];
#unique.sorted.pu.ids <- sort (unique( initial.pu.IDs) );

# get the unique  PU ids from the database
query <- paste( "select ID from", dynamicPUinfoTableName )
unique.sorted.pu.ids <- sql.get.data(PUinformationDBname , query);

tot.num.of.pus <- length( unique.sorted.pu.ids );

# define a reserve map with all values set to zero
reserve.pu.map <- cur.pid.map;
reserve.pu.map[,] <- as.integer(0);


if(DEBUG){
  cat('\nInitial PUs are:');
  show(unique.sorted.pu.ids);
}


    #------------------------------------------------------------
    #  Query the database to get lists of PUs eligible for reservation
    #------------------------------------------------------------

# get the previously reserved PUs
query <- paste( "select ID from ",dynamicPUinfoTableName,"where RESERVED = 1");
priev.reserved.pus <- sql.get.data(PUinformationDBname , query);


# get the available PUs from the database that are above the grassland
# condition threshold. These are the PUs that have RESERVED = 0 and
# LANDUSE = "UNDEVELOPED" and TOTAL_COND_SCORE_MEAN >0.35 in the PU info database.



query <- paste( 'select ID, COST, MANAGEMENT_COST, TOTAL_COND_SCORE_SUM from ',
               dynamicPUinfoTableName,
               'where RESERVED = 0 and DEVELOPED = 0',
               'and TOTAL_COND_SCORE_MEDIAN >',
               PAR.grassland.threshold.value );

available.pus.above.thresh <- sql.get.data(PUinformationDBname, query);

# get the available PUs from the database that are BELOW the grassland
# condition threshold. These are the PUs that have RESERVED = 0 and
# LANDUSE = "UNDEVELOPED" and TOTAL_COND_SCORE_MEAN <= 0.35 in the PU
# info database.  these will be used if there is budget left over once
# once all PUs above thresh are reserved

query <- paste( 'select ID, COST, MANAGEMENT_COST, TOTAL_COND_SCORE_SUM from ',
               dynamicPUinfoTableName,
               'where RESERVED = 0 and DEVELOPED = 0',
               'and TOTAL_COND_SCORE_SUM > 0 and TOTAL_COND_SCORE_MEDIAN <=',
               PAR.grassland.threshold.value );

available.pus.below.thresh <- sql.get.data(PUinformationDBname, query);



    #------------------------------------------------------------
    #  Sort the lists of PUs based on TOTAL_COND_SCORE_SUM
    #------------------------------------------------------------

there.are.pus.above.thresh <- FALSE;
there.are.pus.below.thresh <- FALSE;

if( length(available.pus.above.thresh) > 0 ) {

  there.are.pus.above.thresh <- TRUE;

  # check for zero costs
  zero.cost.ind <- which( available.pus.above.thresh$COST == 0 );
  if( length( zero.cost.ind ) > 0 ){
    available.pus.above.thresh$COST[zero.cost.ind] <- 1;
  }
  
  cost.benefit <- available.pus.above.thresh$TOTAL_COND_SCORE_SUM /
    available.pus.above.thresh$COST;
    
  
  ordered.index.above.thresh <- order(cost.benefit, decreasing = TRUE);
    #order(available.pus.above.thresh$TOTAL_COND_SCORE_SUM, decreasing = TRUE);

  ordered.available.pus.above.thresh <-
    available.pus.above.thresh[ordered.index.above.thresh, ];

}


if( length(available.pus.below.thresh) > 0 ) {

  there.are.pus.below.thresh <- TRUE;
  
  # check for zero costs
  zero.cost.ind <- which( available.pus.below.thresh$COST == 0 );
  if( length( zero.cost.ind ) > 0 ){
    available.pus.below.thresh$COST[zero.cost.ind] <- 1;
  }


  cost.benefit <- available.pus.below.thresh$TOTAL_COND_SCORE_SUM /
    available.pus.below.thresh$COST
 
  
  ordered.index.below.thresh <- order(cost.benefit, decreasing = TRUE);
    #order(available.pus.below.thresh$TOTAL_COND_SCORE_SUM, decreasing = TRUE)
  
  ordered.available.pus.below.thresh <-
    available.pus.below.thresh[ordered.index.below.thresh, ];

}



if( there.are.pus.above.thresh & there.are.pus.below.thresh) {
  ordered.available.pus <- rbind( ordered.available.pus.above.thresh,
                                 ordered.available.pus.below.thresh )

} else {

  if( there.are.pus.above.thresh & !there.are.pus.below.thresh ) {
    
    ordered.available.pus <-  ordered.available.pus.above.thresh;

  } else {

    if( !there.are.pus.above.thresh & there.are.pus.below.thresh ) {
    
      ordered.available.pus <-  ordered.available.pus.below.thresh;
      
    } else {

      # there are no PUs available
      ordered.available.pus <- integer(0);
    }
  } 
}




if( length( ordered.available.pus ) > 0  ) {

  vec.of.available.pus <- ordered.available.pus[,1];
  pu.purchase.cost.vec <- ordered.available.pus[,2];
  pu.managment.cost.vec <- ordered.available.pus[,3];

} else {

  vec.of.available.pus <- integer(0);
  pu.purchase.cost.vec <- integer(0);
  pu.managment.cost.vec <- integer(0);

}

if( OPT.action.type == OPT.VAL.public.reserve ) {

  # Adding a hack here to be able to specify different management
  # costs for public and private conservation. Will leave the default
  # setting to be the private management setting and will set the
  # public managment cost to be a smaller value by multiplying all
  # managment costs by a reduction value. Thus the cost of managing
  # existing and new parcels will be reduced by this factor.
  
  # The plan is to set private management at $0.03/m^2 ($300/ha) and
  # public management to be $0.01/m^2 ($100/ha). Thus the conversion
  # factor will be 0.333333 to that 300 * 0.3333 = 100

  #priv.to.pub.conv.factor <- 0.3333333
  priv.to.pub.conv.factor <- 1

   
  # in this case add the cost of purchasing the property and managing
  # it for the next timestep

  pu.cost.vec <- pu.purchase.cost.vec +
    step.interval * pu.managment.cost.vec * priv.to.pub.conv.factor;

  # now get the cost of managing all existing reserves for the next
  # time step. This will then get subtracted off the budget for the
  # current time step before new reserves are added
  
  query <- paste( 'select MANAGEMENT_COST from', dynamicPUinfoTableName,
                 'where RESERVED = 1 and RESERVE_TYPE =',
                 OPT.VAL.public.reserve );
  
  mgmt.costs.of.exisiting.reserves <- sql.get.data(PUinformationDBname,query);


  tot.cost.of.managing.existing.reserves <-
    sum(mgmt.costs.of.exisiting.reserves)*step.interval*priv.to.pub.conv.factor;
  
   
} else {

  if( OPT.action.type == OPT.VAL.private.management ) {
    
    pu.cost.vec <- pu.managment.cost.vec * PAR.reserve.duration;
    tot.cost.of.managing.existing.reserves <- 0;

    
  } else {
    cat( '\nError unknown OPT.action.type. [OPT.action.type =',
        OPT.action.type, ']' );
    stop();
  }
}

    #------------------------------------------------------------
    #  Do a greedy selection of PUs that meet budget 
    #------------------------------------------------------------

budget <- PAR.budget.for.timestep - tot.cost.of.managing.existing.reserves;

if( length( vec.of.available.pus )> 0 & budget>0  ) {

  # there are some PUs available to reserve
  cur.pus.to.reserve <- greedy.selection.of.PUs( vec.of.available.pus,
                                                pu.cost.vec, budget );
} else {
  

  cur.pus.to.reserve <- integer(0);
}

num.of.pus.to.reserve <- length( cur.pus.to.reserve);

# work out the total reserved PUs by adding the prieviously reserved
# PUs to the currently reserved ones
all.reserved.pus <- sort( c(cur.pus.to.reserve, priev.reserved.pus) );

# create the map of reserved patches and work out total reserved area
total.reserved.area <- as.integer( 0 );

for ( pu.id in all.reserved.pus ) {
  
  pu.area <- length( cur.pid.map [ cur.pid.map  == pu.id ] );
  total.reserved.area <- total.reserved.area + pu.area;
  
  reserve.pu.map[cur.pid.map == pu.id] <- as.integer( 1 );
  
  }

  cat( '\n\n' );



# ---------
# WRITE OUTPUT FILES
# ---------


# determine the name to write the current reserve map to 
cur.reserve.map.name.base <-
  paste (reserved.planning.units.filename.base, '.', current.time.step,sep="");

   
write.pgm.txt.files( reserve.pu.map,
                          reserved.planning.units.filename.base,
                          rows, cols );
write.pgm.txt.files( reserve.pu.map,
                          cur.reserve.map.name.base,
                          rows, cols );


# Create managed PU map and planning units - at this time step
# it's identical to the reserved map

managed.pu.map <- reserve.pu.map;

write.pgm.txt.files( managed.pu.map,
                    managed.planning.units.filename.base,
                    rows, cols );

    #------------------------------------------------------------
    #  Update the database 
    #------------------------------------------------------------

if( length( cur.pus.to.reserve ) > 0 ) {
  
  # there were some pus to reserve in this time step...
  
  # update the database
  update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                     cur.pus.to.reserve, 1, 'RESERVED');
  
  update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                     cur.pus.to.reserve, 1, 'MANAGED');
  
  # PU timestep reserved
  update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                     cur.pus.to.reserve, current.time.step,
                                     'TIME_RESERVED');


  # set the exiry time for the reserves
  reserve.expiry.time <- current.time.step + PAR.reserve.duration;

  update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                     cur.pus.to.reserve,
                                     reserve.expiry.time,
                                     'RES_EXPIRY_TIME');

  # set the RESERVE_TYPE
  update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                     cur.pus.to.reserve,
                                     OPT.action.type,
                                     'RESERVE_TYPE');


  
}

cat( '\nFinished reserve selection.' );
cat( '\n - PUs reserved this timestep  = ', num.of.pus.to.reserve  );
cat( '\n - Total area reserved = ', total.reserved.area , 'Pixels');
cat( '\n - PU ids reserved in this timestep = ', cur.pus.to.reserve );
cat( '\n - All reserved PUs  = ', all.reserved.pus, '\n' );

cat( '\n' );

#cat( num.of.pus.to.reserve, total.reserved.area, '\n',
#    file = reserve.info.file  );


