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
    #  source( '../R/make.rectangular.planning.units.R' )       #
    #                                                           #
    #  2014 09 21 - BTL                                         #
    #  Updated for use in new marxan package                    #
    #                                                           #
    #-----------------------------------------------------------#

#===============================================================================
#
#  2014 09 21 - BTL
#  Gradually changing the ancient code for make.rectangular.planning.units.R
#  into part of a new reserveselection package.
#
#-------------------------------------------------------------------------------
#
#  Step 1 - extract as a function
#
#  Used RStudio's "Extract Function" to wrap a function around all of
#  the code in the file so that I could figure out what are all the
#  external dependencies in here.
#  It was originally a quick inline hack inside the early rdv-framework code
#  and assumed that many variables had been set.  The "Extract Function"
#  automatically finds all those variables and puts them into an argument
#  list for the extracted function.
#  The first try at running the extraction failed with a message that said:
#      Extract Function
#      The selected code could not be parsed.
#  Some trial and error partitioning of the code showed that there was one
#  offending line that was part of creating and initializing a matrix.
#  The problem was in the second line of this pair:
#      pu.map <- matrix (data = NA,  nrow = num_rows, ncol = num_cols)
#      pu.map[,] <- as.integer (non_habitat_indicator)
#  I've now combined those two into a single initialization that satisfied
#  the function extraction:
#      pu.map <- matrix (data = as.integer (non_habitat_indicator),
#                        nrow = num_rows, ncol = num_cols)
#
#-------------------------------------------------------------------------------
#
#  Step 2 - fixing errors I introduced when I fixed the pu.map above
#
#  I had done the fix above in an earlier try at making this a function in
#  a different file.  There, I had changed pu.map to PU_map and rows and cols
#  to num_rows and num_cols.  I had copied the fix above from that old file
#  and consequently, injected these new, unknown variable names in here.
#  So, I've reverted these to pu.map, rows, and cols in here to make them
#  consistent with the rest of the file and redone the extraction of the
#  function in RStudio.
#
#  There is still one odd thing.  RStudio has extracted pu.x and pu.y as
#  function arguments, but as far as I can tell, they are purely local
#  variables here, so I'm commenting them out of the argument list for now.
#
#===============================================================================

make_rectangular_planning_units <-
    function (rows, cols,
              num.planning.units.x, num.planning.units.y,
#              pu.x, pu.y,
              planning.units.filename.base,
              non_habitat_indicator,
              DEBUG
              )
    {
      planning.unit.size.x <- floor( cols / num.planning.units.x);
      planning.unit.size.y <- floor( rows / num.planning.units.y);


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

      remainder.x <- cols %% num.planning.units.x;
      remainder.y <- rows %% num.planning.units.y;
      if( remainder.x > 0 || remainder.y > 0 ) {

        cat( '\n\nWarning: The number of planning units in X or Y' );
        cat( '\n         is not a multiple of the number of cells '  );
        cat( '\n         in the map. Not all planning units will be' );
        cat( '\n         identical in size\n'                        );

        # round the pu size up, so that the last PUs will end up
        # being a little smaller
        planning.unit.size.x <- ceiling( planning.unit.size.x )
        planning.unit.size.y <- ceiling( planning.unit.size.y )


      }


      #check to make sure planning unit size is a multiple of row and cols

      cat( paste( '\nNum planning units in x    :', num.planning.units.x)   )
      cat( paste( '\nNum planning units in y    :', num.planning.units.y)   )

      cat( paste( '\nX size of planning units in pixels:', planning.unit.size.x)     )
      cat( paste( '\nY size of planning units in pixels:', planning.unit.size.y)     )


      #  BTL - 2014 09 16
      #  RStudio didn't accept the second line of this code when
      #  I tried to use the Extract Function feature.
      #  The error message it gave was:
      #      Extract Function
      #      The selected code could not be parsed.
      #  So, I've moved the assignment back into the initialization.
      #pu.map <- matrix (data = NA,  nrow = num_rows, ncol = num_cols)
      #pu.map[,] <- as.integer (non_habitat_indicator)
      pu.map <- matrix (data = as.integer (non_habitat_indicator),
                        nrow = rows, ncol = cols)

      cat( '\n\n' )

      planning.units.x <- 1 : (num.planning.units.x )
      planning.units.y <- 1 : (num.planning.units.y )


      pu.ctr <- 1

      for( pu.y in planning.units.y ) {

        for( pu.x in planning.units.x ) {

          x.index.start <- ( pu.x * planning.unit.size.x ) - planning.unit.size.x + 1;
          x.indices <-    x.index.start : ( x.index.start + planning.unit.size.x -1 );

          y.index.start <- ( pu.y * planning.unit.size.y ) - planning.unit.size.y + 1;
          y.indices <-    y.index.start : ( y.index.start + planning.unit.size.y -1 );


          # If the PUs do not tile the area with no left over space
          # then we need to remove the indices of the last planning unit that
          # will not fit completely into the map.

          # if there are left over pixels (ie the last planning unit
          # does not completely tile the area, then make the remaining
          # pixels part of the last planning unit

          # note doing this at every step but this gets overwritten by the above
          # unless on the last PU on the right or bottom edge.

          if( max(x.indices) < cols ){

            x.indices <- c( x.indices, (max(x.indices)+1) : cols);

          }

          if( max(y.indices) < rows ){

            y.indices <- c( y.indices, (max(y.indices)+1) : rows);

          }



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

      cat( '\n\n' )

      write.pgm.txt.files( pu.map, planning.units.filename.base, rows, cols );
      write.asc.file( pu.map, planning.units.filename.base, rows, cols );
    }

