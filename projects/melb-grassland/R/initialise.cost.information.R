

    #-----------------------------------------------------------#
    #                initialise.cost.information.R              #
    #                                                           #
    #  Initialised cost information and makes a map of the      #
    #  based in the planning unit layer (which can be the same  #
    #  as the patches or or any arbitary shape.                 #
    #  This file was originally called  make.cost.layer         #
    #                                                           #
    #  any other arbitaty shape                                 #
    #                                                           #
    #  Created 3/4/2009 - AG                                    #
    #                                                           #
    #                                                           #
    #    source('initialise.cost.information.R')                #
    #-----------------------------------------------------------#



rm( list = ls( all=TRUE ));

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'w.R' );
source( 'dbms.functions.R' )      

source('variables.R')
source('initialise.cost.information.functions.R' )

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

#  set in python...
OPTsetRandomSeedForCost <- FALSE
OPT.VAL.all.PUs.have.same.cost <- 1
OPT.VAL.PU.cost.is.proportional.to.area <- 2
OPT.VAL.PU.cost.is.a.random.value <- 3 
OPT.VAL.PU.cost.sampled.from.a.normal.distribution <- 4
OPT.VAL.PU.cost.is.a.gradient.from.corner <- 5
OPT.VAL.PU.cost.is.a.fixed.value.per.sq.meter <- 6

OPT.cost.scenario <- OPT.VAL.all.PUs.have.same.cost

PAR.minimum.patch.cost <- 10
non.habitat.indicator = -9999
DEBUG <- FALSE
    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------

# Option 1 is that all patches have the same cost
# Option 2 is that the cost of a patch is just it's area (in pixels)
# Option 3 is that the patch cost is a random value between
#          min and max cost
# Option 4 is that it is sampled with a normal prbability distribution
#          having a mean halfway between the min and max costs
#            

# NOTE PU is planning unit

    #------------------------------------------------------------
    #  Fist check if a random number seed needs to be set and set 
    #  set it if necessary
    #------------------------------------------------------------

if( OPTsetRandomSeedForCost ) {
  set.seed( PARcostRandomSeed );
}

    #------------------------------------------------------------
    #  extract the PU IDs and areas from the database 
    #------------------------------------------------------------

cat( '\nDefining the PU costs' );

cat( '\nQuering the database to get PU ID and area info' );

query <- paste( "select ID, AREA from", dynamicPUinfoTableName) 
pu.ids.and.areas <- sql.get.data( PUinformationDBname, query );

pu.id.column <- 1;
pu.area.column <- 2;

pu.id.vector <- pu.ids.and.areas[,pu.id.column];
pu.area.vector <-  pu.ids.and.areas[,pu.area.column];  # area in pixels

    #------------------------------------------------------------
    #  read in the PU ID map (need to make cost map)
    #------------------------------------------------------------


# read in file
pu.id.map <- as.matrix ( read.table( planning.units.filename ) );


    #------------------------------------------------------------
    #  set up strucures to hold cost info 
    #------------------------------------------------------------

# create the vector to hold the PU costs
pu.cost.vector <- rep( 0, length(pu.id.vector)); 

#define the cost map
cost.map <- matrix( nrow = rows, ncol = cols );
cost.map[,] <- as.integer( 0 );


    #------------------------------------------------------------
    #  calculate the cost of each planning unit based on the cost scenario
    #------------------------------------------------------------

if( OPT.cost.scenario == OPT.VAL.all.PUs.have.same.cost ){

  # set all PUs to the same value
  cost.map[ pu.id.map != non.habitat.indicator ] <- PAR.minimum.patch.cost;  
  pu.cost.vector[] <- PAR.minimum.patch.cost;
  
} else {

  # loop through all the planning units and set the cost.
  for( pu.index in 1:length(pu.id.vector) ) {

    cur.pu.id <- pu.id.vector[pu.index];

    # work our the area of the current PU in pixels
    cur.area <- pu.ids.and.areas[pu.index, pu.area.column];

    if( OPT.cost.scenario == OPT.VAL.PU.cost.is.proportional.to.area ) {

 
      # rescale to be within the limits.
      max.area <- max( pu.ids.and.areas[ , pu.area.column] );
      cost.range <- PAR.maximum.patch.cost - PAR.minimum.patch.cost;
      
      cost.value <-
        cost.range * (cur.area / max.area) + PAR.minimum.patch.cost;
      
    } else {

      if( OPT.cost.scenario == OPT.VAL.PU.cost.is.a.random.value ){
        
        cost.value <-
          runif(1, PAR.minimum.patch.cost,PAR.maximum.patch.cost)
        
      } else {

        if(OPT.cost.scenario ==
           OPT.VAL.PU.cost.sampled.from.a.normal.distribution){

          # work out the mean and standard dev of the normal dist.
          mean.cost <- (PAR.maximum.patch.cost - PAR.minimum.patch.cost)/2;
          cost.sd <- mean.cost/4;
          
          cost.value <- rnorm( 1, mean = mean.cost, sd = cost.sd );
      
          # make sure the cost is within the bounds we've set
          cost.value <- max( PAR.minimum.patch.cost, cost.value ); 
          cost.value <- min( PAR.maximum.patch.cost, cost.value ); 
      
      
        } else {

          if( OPT.cost.scenario == OPT.VAL.PU.cost.is.a.gradient.from.corner ){

            # find all the pixels in the current planning unit
            pixels.in.current.pu <- which( pu.id.map==cur.pu.id, arr.ind=TRUE);
      
            # pick the first pixel and use it to calculate the distance from
            x.location <- pixels.in.current.pu[1,2];
            y.location <- pixels.in.current.pu[1,1];

            # calculate the distance
            distance.from.corner <- sqrt( x.location^2 + y.location^2 );
            cost.value <- distance.from.corner;
      
            # rescale to be within the limits.
            max.dist <- sqrt( rows^2 + cols^2 );
            cost.range <- PAR.maximum.patch.cost -PAR.minimum.patch.cost;
      
            cost.value <-
              cost.range * (cost.value / max.dist) + PAR.minimum.patch.cost;
      
      
          } else {

            if( OPT.cost.scenario ==
                OPT.VAL.PU.cost.is.a.fixed.value.per.sq.meter) {
              
              cost.value <- PAR.pu.cost.per.pixel * cur.area;

            } else {

              if( OPT.cost.scenario == OPTVALPUcostIsSampledFromRealMelbCosts){

		# cur area is in pixels and using 50 meter 
		cur.area.sq.meters <- cur.area * 50 * 50;
                cur.area.hectares <- cur.area *50*50/100/100

		# use one of these
		if( OPTsampleMelbCostsFromLogNormDist ) {
                  
		  #sampling from a log normal dist fitted to the real data
   		  cost.per.sq.meter <- 
                       sample.lognorm.dist.fitted.to.real.melb.costs(
                                                             cur.area.hectares)

		} else {

		  # sampling directly from the real data distribution
		  cost.per.sq.meter <- sample.from.dist.of.real.melb.costs();

		}

		cost.value <- cost.per.sq.meter * cur.area.sq.meters;

              } else {
            
                cat( '\nError: unknown cost scenario:',
                    '\n    OPT.cost.scenario = ', OPT.cost.scenario, '\n' );
                stop( '\nAborted due to error in input.', call. = FALSE );
              }
            }
          }
        }
      }
    }

    cost.map[  pu.id.map == cur.pu.id  ] <- round( cost.value, 3 );
    pu.cost.vector[pu.index] <- round( cost.value, 3 );

    #browser();
  
  }  # end - for( pu.id in pu.id.vector )
  
}  # end - if( OPT.cost.scenario == OPT.VAL.all.PUs.have.same.cost ) else

pu.areas.and.costs <- cbind( pu.area.vector, pu.cost.vector );
  
pu.ids.and.costs <- cbind( pu.id.vector, pu.cost.vector);

  
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# manually set some PUs to have a low cost 

#low.cost.PUs <- 711:718
#low.cost.vale <- 5;

#for( c.id in low.cost.PUs) {

#  low.cost.PUs.index <- which(pu.ids.and.costs[,1]  == c.id )
#  pu.ids.and.costs[low.cost.PUs.index, 2] <- low.cost.vale;

#}
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




#hist( pu.cost.vector, xlab = 'cost', br = 20, 
#     main = 'Histogram of planning unit costs', plot = FALSE );

#
# Write the outputs
#
cat( '\nWriting the  PU costs maps/database' );

update.db.pu.ids.with.multiple.values( dynamicPUinfoTableName,
                                      pu.ids.and.costs, 'COST');

res <- write.to.3.forms.of.files( cost.map, cost.map.base.filename, rows, cols);

