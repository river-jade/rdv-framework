

    #------------------------------------------------------------
    #                    make.cost.layer.R                      #
    #                                                           #
    #  Creates a cost layer. This is done from the planning     #
    #  unit layer (which can be the same as the patches or      #
    #  any other arbitaty shape                                 #
    #                                                           #
    #  Created 31/8/2006 - AG                                   #
    #                                                           #
    #  modified 18/08/07 - AG. Added code so that it will       #
    #                                                           #
    #                                                           #
    #  Inputs: planning unit file ( specified by the variable   #
    #                               planning.units.filename )   #
    #                                                           #
    #                                                           #
    #  Output:                                                  #
    #         - a vector containing the costs and areas of the  #
    #           of the planning units.                          #
    #         - cost.map  (cost.map.base.filename)              #
    #                                                           #
    #    source('make.cost.layer.R')                     #
    #------------------------------------------------------------

rm( list = ls( all=TRUE ));

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'w.R' );
source( 'dbms.functions.R' )      

source('variables.R')

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

#  set in python...

    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------

# Option 1 is that all patches have the same cost
# Option 2 is that the cost of a patch is just it's area
# Option 3 is that the patch cost is a random value between
#          min and max cost
# Option 4 is that it is sampled with a normal prbability distribution
#          having a mean halfway between the min and max costs
#            

# NOTE PU is planning unit



# read in file
pu.id.map <- as.matrix ( read.table( planning.units.filename ) );

# extract the unique planning unit ID values 
pu.id.vector <- sort( unique ( as.vector( pu.id.map ) ) );

cat( '\nDetermining costs for PUs.',
    '\nThere are', length( pu.id.vector ), 'planning units\n' )

# remove the nonhabitat
pu.id.vector <- pu.id.vector[ pu.id.vector != non.habitat.indicator  ];


# create the vector to hold the PU  areas
pu.area.vector <- rep( 0, length(pu.id.vector));

# create the vector to hold the PU costs
pu.cost.vector <- rep( 0, length(pu.id.vector)); 

#define the cost map
cost.map <- pu.id.map;
cost.map[,] <- as.integer( 0 );

#work out the PU  areas
for( pu.index in 1:length(pu.id.vector) ) {

  cur.pu.id <- pu.id.vector[pu.index];
  
  # find the number of pixels in the current patch
  current.pu.area <- length( pu.id.map[ pu.id.map == cur.pu.id ] );
  
  # save the area into a vector
  pu.area.vector[  pu.index ] <- current.pu.area
  
  if( DEBUG ) cat( '\nThe area of Patch', pu.id, 'is', current.pu.area );

}

#combine the patch IDs and areas.
pu.area.column <- 2;
pu.areas <- cbind( pu.id.vector, pu.area.vector )


# calculate the cost of each planning unit
# based on the cost scenario

if( OPT.cost.scenario == OPT.VAL.all.PUs.have.same.cost ){

  # set all PUs to the same value
  cost.map[ pu.id.map != non.habitat.indicator ] <- PAR.minimum.patch.cost;  
  pu.cost.vector[] <- PAR.minimum.patch.cost;
  
} else {

  # loop through all the planning units and set the cost.
  for( pu.index in 1:length(pu.id.vector) ) {

    cur.pu.id <- pu.id.vector[pu.index];

    if( OPT.cost.scenario == OPT.VAL.PU.cost.is.proportional.to.area ) {

      cost.value <- pu.areas[pu.index, pu.area.column];

      # rescale to be within the limits.
      max.area <- max( pu.areas[ , pu.area.column] );
      cost.range <- PAR.maximum.patch.cost -PAR.minimum.patch.cost;
      
      cost.value <-
        cost.range * (cost.value / max.area) + PAR.minimum.patch.cost;
      
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
      
            cat( '\nError: unknown cost scenario:',
                '\n    OPT.cost.scenario = ', OPT.cost.scenario, '\n' );
            stop( '\nAborted due to error in input.', call. = FALSE );


          }
        }
      }
    }

    cost.map[  pu.id.map == cur.pu.id  ] <- round( cost.value, 3 );
    pu.cost.vector[pu.index] <- round( cost.value, 3 );

    #browser();
  
  }  # end - for( pu.id in pu.id.vector )
  
}  # end - if( OPT.cost.scenario == OPT.VAL.all.PUs.have.same.cost ) else

pu.areas.and.costs <- cbind( pu.areas, pu.cost.vector );

pu.ids.and.costs <- cbind( pu.id.vector, pu.cost.vector);

hist( pu.cost.vector,xlab = 'cost', br = 20, 
     main = 'Histogram of planning unit costs', plot = FALSE );

#
# Write the outputs
#

write.table( pu.areas.and.costs, file = pu.area.and.cost.filename,
            row.names = FALSE, col.names = FALSE );

write.table( pu.ids.and.costs, file = pu.costs.filename,
             row.names = FALSE, col.names = FALSE );

write.to.3.forms.of.files( cost.map, cost.map.base.filename, rows, cols);

