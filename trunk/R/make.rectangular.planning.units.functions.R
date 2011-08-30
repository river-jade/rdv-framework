

# source( 'make.rectangular.planning.units.functions.R' )


make.pu.consistency.checks <- function() {

# check that the PUs are at least one pixel in size
  if( num.planning.units.x > cols | num.planning.units.y > rows ) {
    cat( '\n\nError: There are more planning unites then there');
    cat( '\n       pixels in the map! Either make larger planning'  );
    cat( '\n       units or increas the number of pixels.\n' );
    stop( 'Aborted due to error in input.', call. = FALSE );
  }


  # check to see if the number planning units is a factor
  # of the number of pixels in the map. If not print a warning
  # as the planning units on the right and bottom may be slighly
  # smaller than the other PUs

  if( remainder.x > 0 || remainder.y > 0 ) {
  
    cat( '\n\nWarning: The number of planning units in X or Y' );
    cat( '\n         is not a multiple of the number of cells '  );
    cat( '\n         in the map. Not all planning units will be' );
    cat( '\n         identical in size\n'                        );

  }

  
}
