
#   source( 'gen.reserved.pus.from.patches.R' )


# now generate the reserved planning units.


rm( list = ls( all=TRUE ));


    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'w.R' );
source( 'utility.functions.R' );
source( 'variables.R' );
source( 'dbms.functions.R' );

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

#  set in python...


    #------------------------------------------------------------
    #  Outputs/returned
    #------------------------------------------------------------


    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------


#read in the maps
reserve.map <-
  as.matrix( read.table( paste( reserve.map.name.base, '.txt', sep = '' ) ));

pu.map  <- as.matrix ( read.table( planning.units.filename  ) );

#make the blank reserve map
reserved.pu.map <- pu.map;
reserved.pu.map[,] <- as.integer( 0 ) ;


# get a vector of all the planning units
plan.unit.vec <-
  get.unique.ids.from.map( planning.units.filename, non.habitat.indicator );

# get the PU costs and IDs from the database
# this will return a matrix with two columns
# <PU_id> <cost>
#pu.costs <- as.matrix( read.table( pu.costs.filename ));
query <- paste( "select ID, cost from ", dynamicPUinfoTableName )
pu.costs <- sql.get.data(PUinformationDBname , query);

reserved.pu.indicies   <- vector( length = length(plan.unit.vec));
reserved.pu.indicies[] <- as.integer( 0 );

total.reserved.pu.area <- as.integer( 0 );

ctr <- 0;

tot.num.pus <- length( plan.unit.vec );

running.total.cost <- 0;

for( cur.pu in plan.unit.vec ){
  
  ctr <- ctr + 1;

  pu.cost.index <- which( pu.costs[, 1] == cur.pu );
  cur.cost <- pu.costs[pu.cost.index,2];

  #display.progress( ctr, tot.num.pus );
  
  # work out the number of pixels in the current PU
  num.pixels.in.cur.pu <- length( which (pu.map == cur.pu));

  # work put the prop of the reserved patches (or the Z solution)
  # that is in the current PU

  num.reserved.pixels.in.pu <-
    length( reserve.map[ (pu.map == cur.pu) & (reserve.map == 1) ])

  # work out the proportion of reserved pixels are contained in current PU
  prop.res.pixels.in.pu <- num.reserved.pixels.in.pu/num.pixels.in.cur.pu;

  if(DEBUG) cat( '\nPU id:', cur.pu,
                '\n    num pixels =', num.pixels.in.cur.pu,
                '\n    num reserved pixels =', num.reserved.pixels.in.pu,
                '\n    prop pixels in PU reserved', prop.res.pixels.in.pu,
                '\n' );
  
  
  #if( length( reserve.map[ (pu.map == cur.pu) & (reserve.map == 1) ]
  #           ) > num.pixels.in.patch.to.reserve.pu) {


  # check to see if enough pixels in the PU are reserved
  if(  prop.res.pixels.in.pu > PAR.prop.pixels.in.PU.to.reserve ) {
    
    # set the planning unit to "reserved" in the PU map
    reserved.pu.map[ pu.map == cur.pu ] <- as.integer( 1 );
    
    reserved.pu.indicies[ ctr ] <- as.integer( 1 );
    curr.pu.area <-  length( reserved.pu.map[ pu.map == cur.pu ]);
    
    total.reserved.pu.area <- total.reserved.pu.area + curr.pu.area;

    running.total.cost <- running.total.cost + cur.cost;

  } else {
    reserved.pu.map[ pu.map == cur.pu ] <- as.integer( 0 );
  }
}


reserved.planning.units <-  plan.unit.vec[reserved.pu.indicies == 1];
unreserved.planning.units <-  plan.unit.vec[reserved.pu.indicies == 0];

# Create managed PU map and planning units - at this time step
# it's identical to the reserved map
managed.pu.map <- reserved.pu.map;
managed.planning.units <- reserved.planning.units;


number.of.pus.reserved <- length( reserved.planning.units );

cat( '\nReserved Planning Unit Infomration:' );
cat( '\n - Num of PUs reserved                = ', number.of.pus.reserved );
cat( '\n - Total area reservedof reserved PUs = ',
    total.reserved.pu.area, 'Pixels\n');

# ---------
# WRITE OUTPUT FILES
# ---------

    #------------------------------------------------------------
    #  Update the database 
    #------------------------------------------------------------

# reserved PUS
reserved.value <- 1;
update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                  reserved.planning.units,
                                  reserved.value,
                                  'RESERVED' );

# timestep that the PU was reserved
update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                  reserved.planning.units,
                                  current.time.step,
                                  'TIME_RESERVED');
                                  
# reserved PUs are also managed
managed.value <- 1;
update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                  managed.planning.units,
                                  managed.value,
                                  'MANAGED' );                                  

# timestep that the PU was managed
update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                  reserved.planning.units,
                                  current.time.step,
                                  'TIME_MANAGEMENT_COMMENCED');

# set the exiry time for the reserves
reserve.expiry.time <- current.time.step + PAR.reserve.duration;

update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                   reserved.planning.units,
                                   reserve.expiry.time,
                                   'RES_EXPIRY_TIME');

cat( number.of.pus.reserved,  total.reserved.pu.area, '\n',
    file = pu.reserve.info.file  );

    #----------------------------------
    #  BTL - 23/02/09
    #  Added the time step to the name.
    #----------------------------------

reserved.planning.units.filename.base <-
    paste (reserved.planning.units.filename.base, '.', current.time.step,
           sep = '');

write.pgm.txt.files( reserved.pu.map, reserved.planning.units.filename.base, rows, cols );

managed.planning.units.filename.base <-
    paste (managed.planning.units.filename.base, '.', current.time.step,
           sep = '');

write.pgm.txt.files( managed.pu.map, managed.planning.units.filename.base, rows, cols );