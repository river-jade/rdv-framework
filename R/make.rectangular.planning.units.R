    #-----------------------------------------------------------#
    #                                                           #
    #             make.rectangular.planning.units.R             #
    #                                                           #
    #  Make a planning unit map. This is for use with the MARXAN#
    #  reserve selection software.  For now the planning units  #
    #  are just rectangles that cover the whole area. You       #
    #  specify how many in x and y and divies the map up evenly.#
    #                                                           #
    #  Created June 29, 2006 - Ascelin Gordon                   #
    #  source( 'make.rectangular.planning.units.R' )     #       
    #                                                           #
    #   Exported  for use in new version of framework based on  #
    #   oop in python                                           #
    #-----------------------------------------------------------#

#rm( list = ls( all=TRUE ));

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'w.R' );
source( 'make.rectangular.planning.units.functions.R' );
#source( 'variables.R' );

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

# set in python, which creates the file below


    #------------------------------------------------------------
    #  Outputs generated:
    #
    #    - the PU map (both .txt and .asc versions)
    #
    #------------------------------------------------------------



    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------


# determine the number of PUs that will fit in x and y
planning.unit.size.x <- cols / num.planning.units.x;
planning.unit.size.y <- rows / num.planning.units.y;

# determine the remainder
remainder.x <- cols %% num.planning.units.x;
remainder.y <- rows %% num.planning.units.y;


make.pu.consistency.checks();

cat( paste( '\nNum planning units in x    :', num.planning.units.x)   )
cat( paste( '\nNum planning units in y    :', num.planning.units.y)   )
cat( paste( '\nX size of planning units in pixels:', planning.unit.size.x))
cat( paste( '\nY size of planning units in pixels:', planning.unit.size.y))

cat( '\n\n' )


# round the pu size down, to be an integer
planning.unit.size.x <- floor( planning.unit.size.x )
planning.unit.size.y <- floor( planning.unit.size.y )

# make an array to store the PU map
pu.map <- matrix( data = NA,  nrow = rows, ncol = cols )
pu.map[,] <- as.integer( non.habitat.indicator )


planning.units.x <- 1 : (num.planning.units.x )
planning.units.y <- 1 : (num.planning.units.y )


pu.ctr <- 1

for( pu.y in planning.units.y ) {
  
  for( pu.x in planning.units.x ) {
  
    x.index.start <- (pu.x * planning.unit.size.x) - planning.unit.size.x + 1;
    x.indices <-    x.index.start : (x.index.start + planning.unit.size.x -1);

    y.index.start <- (pu.y * planning.unit.size.y) - planning.unit.size.y + 1;
    y.indices <-    y.index.start : (y.index.start + planning.unit.size.y -1);


    # If there are left over pixels (ie the last planning unit
    # does not completely tile the area), then make the remaining 
    # pixels part of the last planning unit.

    # Note: This is being done at every step but this gets overwritten by
    # the above unless on the last PU on the right or bottom edge.
    
    if( max(x.indices) < cols ){
      
      x.indices <- c( x.indices, (max(x.indices)+1) : cols);
      
    }
    
    if( max(y.indices) < rows ){
      
      y.indices <- c( y.indices, (max(y.indices)+1) : rows);
      
    }
    

    # now have the indices calculated, write them to the PU map
    pu.map[y.indices, x.indices ] <- as.integer( pu.ctr);
      
    if( DEBUG ) {
      cat( paste( '\nPlanning number ', pu.ctr ) );
      cat( paste( '\n  Planning unit x ctr ', pu.x ) );
      cat( paste( '\n  Planning unit y ctr', pu.y ) );
      
      cat( paste( '\n  x index start', x.index.start ) );
      cat( '\n  x indices:' );
      show( x.indices );
    
      cat( paste( '\n  y index start', y.index.start ) );
      cat( '\n  y indices:' );
      show( y.indices );
      cat( '\n' );
    }
    
    pu.ctr <- pu.ctr+ 1;
  }
}


planning.unit.vector <- 1:(pu.ctr -1);

cat( '\n\n' )



    #------------------------------------------------------------
    #  Write output
    #------------------------------------------------------------

write.pgm.txt.files( pu.map, planning.units.filename.base, rows, cols );
write.asc.file( pu.map, planning.units.filename.base, rows, cols );
