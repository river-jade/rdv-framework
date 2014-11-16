#===============================================================================

#  2014 09 23 - BTL
#  This looks like it might have been the code that was originally in
#  the script file called make.marxan.rectangular.boundry.file.R.
#  Can't tell for sure and not sure why the name of the function here
#  seems so different from that.

#===============================================================================

make.marxan.bound.dat.using.user.supplied.data <-
    function (PAR.Marxan2.input.dir,
              num.planning.units.x,
              num.planning.units.y,
              cols,
              rows,
                    pixel.size,
                    pu.y,  #  temp idx in for loop
                    pu.x  #  temp idx in for loop
              )
        {
  # make.marxan.bound.dat.using.user.supplied.data<- function(
  #     num.planning.units.x,
  #     num.planning.units.y,
  #     rows,
  #     cols,
  #     PAR.Marxan2.input.dir ){

      #e.g. make.marxan.bound.dat.using.user.supplied.data(num.planning.units.x,num.planning.units.y,rows,cols,PAR.Marxan2.input.dir)

      #-----------------------------------------------------------#
      #                                                           #
      #     make.marxan.bound.dat.using.user.supplied.data() #
      #                                                           #
      #  This creates the file 'bound.dat', needed for MARXAN.    #
      #  This takes care of the case where rectangular planning   #
      #  units  are being used                                    #
      #  This file specifies the the boundary of each planning    #
      #  unit (PU) and and shared boundries between each pair of  #
      #  planning units that have a common boundary.              #
      #  This assumes the planning units are rectangles and cover #
      #  the whole region.                                        #
      #                                                           #
      #  The format of the file is:                               #
      #  header "id1,id2,boundary"                                #
      #  then id1,id2,boundary                                    #
      #  where  id1 is PU 1 and id2 is PU 2 and is the boundary   #
      #  1,1,50  means planning unit 1 has a boundary of 50 units #
      #  1,2,25  means PU 1 and 2 have 25 units of shared boundary#
      #  Each boundary shuld only be mentioned once( eg shouldn't #
      #  have:                                                    #
      #  2,1,25                                                   #
      #                                                           #
      #  original file name make.marxan.rectagnular.boundry.file.R#
      #                                                           #
      #-----------------------------------------------------------#

      cat( '\nAbout to make bound.dat file for MARXAN' );
      cat( '\nmake.marxan.bound.dat.using.user.supplied.data\n')

      #file path to save bound.dat file
      outputFile<-paste(PAR.Marxan2.input.dir, "bound.dat", sep="")

      DEBUG<-FALSE

      #these should be set by the scripts that call this script. This is left here
      #for debugging purposes.
      #cols = 100;
      #rows = 100;
      #num.planning.units.x <- 5;
      #num.planning.units.y <- 5;

      tot.num.planning.units <- num.planning.units.x * num.planning.units.y;

      planning.unit.size.x <- cols / num.planning.units.x
      planning.unit.size.y <- rows / num.planning.units.y

      planning.unit.length.x <- planning.unit.size.x * pixel.size
      planning.unit.length.y <- planning.unit.size.y * pixel.size

      two.side.length <- planning.unit.length.x + planning.unit.length.y;
      tot.planning.unit.boundary <- (planning.unit.length.x + planning.unit.length.y) * 2

      #a consistency check:
      remainder.x <- cols %% num.planning.units.x;
      remainder.y <- rows %% num.planning.units.y;


      #calc the number of entries there should be
      no.cost.rows <- tot.num.planning.units

      #the cost matrix - this is to be filled in the loop of planning units

      #the equation to dtermine how many entries will be in the bound.dat file
      x <- num.planning.units.x;
      y <- num.planning.units.y;

      # this expression calculates the tot number of entries that will go
      # into the bound.dat #file... (don't ask!) - see page 151 of my log
      # book II

      num.entries <- (x-2)*(y-2)*2 + (x-1)*2 + (y-2)*2 + (y-2)*2 + (x-2)*2 + y-1 + x-1 + 4;

      # create the cost matrix
      cost.matrix <- matrix( ncol = 3, nrow = num.entries  );

      # make some checks
      if( remainder.x > 0 || remainder.y > 0 ) {

          cat( '\n\nWARNING: The number of planning units in X or Y' )
          cat( '\n          is not a multiple of the number of cells ' )
          cat( '\n          in the map. Thus the algorithm to calculate' )
          cat( '\n          boundary length is not applicable. \n' )


          # in this case do nothing else and don't create the bound.dat file

      } else {

          if( tot.num.planning.units < 2 ){
              cat( '\n\nERROR:Too few planning units. Minimum is 1x2 units.\n' )
              stop( 'Aborted due to error in input.', call. = FALSE )
          }

          cat( paste( '\nTot num planning units            :',tot.num.planning.units));
          cat( paste( '\nX size of planning units in meters:',planning.unit.length.x));
          cat( paste( '\nY size of planning units in meters:',planning.unit.length.y));
          cat( paste( '\nTotal boundary of a single planning unit (meters):',
                      tot.planning.unit.boundary)   )
          cat( paste( '\nThe number of entries in the bound.dat file is:',num.entries))


          pu.current.value.vector <- c(1:3);

          pu.value.matrix <- matrix( data = (1:tot.num.planning.units), nrow =
                                         num.planning.units.y, ncol = num.planning.units.x,
                                     byrow = TRUE );


          if( DEBUG ) {
              cat( '\n\nThe planning unit matrix is as follows:\n' );
              show( pu.value.matrix );
          }

          cat("id1,id2,boundary\n", file=outputFile,append=FALSE)

          line.ctr <- 1;

          #NOTE from the way the matrix
          for( pu.y in 1: num.planning.units.y ) {
              for( pu.x in  1:num.planning.units.x ) {

                  remainder.x <- cols %% num.planning.units.x

                  if( ( line.ctr %% 500 )  == 0 )
                      cat( paste( '\nWrote line number:', line.ctr ));

                  pu.num <- pu.value.matrix[pu.y, pu.x]


                  if( DEBUG ) cat( paste( 'PU number = ', pu.num,
                                          ' (x,y) = ', '(', pu.y,',',pu.x, ')\n' ) );

                  #if using a corner PU add two sides to the boundary length

                  #top or bottom left corners
                  if( pu.x == 1 & ( pu.y ==1  | pu.y == num.planning.units.y  ) ) {

                      pu.current.value.vector[1]<- pu.num;
                      pu.current.value.vector[2]<- pu.num;
                      pu.current.value.vector[3]<- two.side.length;

                      #line.of.text <- paste( two.side.length, pu.num, pu.num, '\n'  );
                      #cat( line.of.text, file = boundary.filename, append = TRUE  );
                      #if( DEBUG ){ cat( ' corner\n' ); cat( line.of.text ); }

                      cat(paste(pu.current.value.vector[1],",",pu.current.value.vector[2],",",
                                pu.current.value.vector[3],"\n", sep=""), file=outputFile,append=TRUE)

                      line.ctr <- line.ctr + 1;

                  }
                  #top or bottom right corners
                  if( pu.x == num.planning.units.x & ( pu.y ==1  | pu.y == num.planning.units.y  ) ){

                      pu.current.value.vector[1]<- pu.num;
                      pu.current.value.vector[2]<- pu.num;
                      pu.current.value.vector[3]<- two.side.length;

                      #line.of.text <- paste( two.side.length, pu.num, pu.num, '\n'  );
                      #cat( line.of.text, file = boundary.filename, append = TRUE  );
                      #if( DEBUG ) { cat( ' corner\n' ); cat( line.of.text ); }

                      cat(paste(pu.current.value.vector[1],",",pu.current.value.vector[2],",",
                                pu.current.value.vector[3],"\n", sep=""), file=outputFile,append=TRUE)

                      line.ctr <- line.ctr + 1;

                  }

                  #if have an edge add 1 side of boundary length

                  #check if a PU is an edge on a left or right column
                  if( (pu.x == 1 | pu.x == num.planning.units.x) &
                          ( pu.y !=1  & pu.y != num.planning.units.y  ) ) {

                      pu.current.value.vector[1]<- pu.num;
                      pu.current.value.vector[2]<- pu.num;
                      pu.current.value.vector[3]<- planning.unit.length.x;

                      #line.of.text <- paste( planning.unit.length.x, pu.num, pu.num, '\n');
                      #cat( line.of.text, file = boundary.filename, append = TRUE  );
                      #if( DEBUG ) { cat( ' edge col\n' ); cat( line.of.text ); }

                      cat(paste(pu.current.value.vector[1],",",pu.current.value.vector[2],",",
                                pu.current.value.vector[3],"\n", sep=""), file=outputFile,append=TRUE)

                      line.ctr <- line.ctr + 1;

                  }

                  #check if a PU is on the top or bottom row
                  if( (pu.y == 1 |  pu.y == num.planning.units.y )&
                          ( pu.x !=1  & pu.x != num.planning.units.x  ) ) {

                      pu.current.value.vector[1]<- pu.num;
                      pu.current.value.vector[2]<- pu.num;
                      pu.current.value.vector[3]<- planning.unit.length.y;

                      #line.of.text <- paste( planning.unit.length.y, pu.num, pu.num, '\n');
                      #cat( line.of.text, file = boundary.filename, append = TRUE  );
                      #if( DEBUG ){ cat( ' edge row\n' ); cat( line.of.text ); }

                      cat(paste(pu.current.value.vector[1],",",pu.current.value.vector[2],",",
                                pu.current.value.vector[3],"\n", sep=""), file=outputFile,append=TRUE)

                      line.ctr <- line.ctr + 1;

                  }


                  #work out the one to the right
                  if( !( pu.x+1 > num.planning.units.x ) ) {

                      pu.current.value.vector[1]<- pu.value.matrix[pu.y,pu.x ];
                      pu.current.value.vector[2]<- pu.value.matrix[pu.y,pu.x+1 ];
                      pu.current.value.vector[3]<- planning.unit.length.y;


                      #line.of.text <- paste( planning.unit.length.y, pu.value.matrix[pu.y,pu.x ],
                      #                      pu.value.matrix[pu.y,pu.x+1 ], '\n'  );
                      #cat( line.of.text, file = boundary.filename, append = TRUE  );
                      #if( DEBUG ) cat( line.of.text );

                      cat(paste(pu.current.value.vector[1],",",pu.current.value.vector[2],",",
                                pu.current.value.vector[3],"\n", sep=""), file=outputFile,append=TRUE)

                      line.ctr <- line.ctr + 1;
                  }

                  #work out the one below
                  if( !( pu.y+1 > num.planning.units.y)  ){

                      pu.current.value.vector[1]<- pu.value.matrix[pu.y,pu.x ];
                      pu.current.value.vector[2]<- pu.value.matrix[pu.y+1,pu.x ];
                      pu.current.value.vector[3]<- planning.unit.length.x;

                      #line.of.text <- paste( planning.unit.length.x, pu.value.matrix[pu.y,pu.x ],
                      #                      pu.value.matrix[pu.y+1,pu.x ], '\n'  )
                      #cat( line.of.text, file = boundary.filename, append = TRUE  );
                      #if( DEBUG ) cat( line.of.text  );

                      cat(paste(pu.current.value.vector[1],",",pu.current.value.vector[2],",",
                                pu.current.value.vector[3],"\n", sep=""), file=outputFile,append=TRUE)

                      line.ctr <- line.ctr + 1;

                  }

              }
          }

      }  # end  - if/else ( remainder.x > 0 || remainder.y > 0 )

  # }  # make.marxan.bound.dat.using.user.supplied.data
}

#===============================================================================

