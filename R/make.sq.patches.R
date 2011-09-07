    #-----------------------------------------------------------#
    #                                                           #
    #             make.sq.patches.R                              #
    #                                                           #
    #  Makes a test map of square patches of value one in a     #
    #  matrix the value 'non.habitat.indicator'                 #
    #  The user defines the number of pacthes in x and y and    #
    #  square patches are just spaced evenly over the map cells.#
    #                                                           #
    #  Created April 3rd, 2006 - Ascelin Gordon                 #
    #  12 July - modified to run much faster (old version       #
    #            over all pixels in the map                     #
    #                                                           #
    #  source( 'make.sq.patches.R' )                     #
    #                                                           #
    #-----------------------------------------------------------#


source( 'w.R' )
source( 'pause.R' ) 

source( 'variables.R' )


num.patches = num.patches.x * num.patches.y;

hab.matrix <-  matrix( data = as.integer(non.habitat.indicator),
                      nrow = rows, ncol = cols );

  spacingX <- cols / (num.patches.x *2 + 1);
  spacingY <- rows / (num.patches.y *2 + 1);

  cat( '\nSpacing between patches is:\n',
      '   ',  as.integer(spacingX), 'in x (pixels)\n',
      '   ',  as.integer(spacingY), 'in y (pixels)' )
      

x.corner.locs <- seq( spacingX, cols, spacingX*2 );
y.corner.locs <- seq( spacingY, rows, spacingY*2 );

#cat( '\nX left locations of patchs are:\n');
#show( x.corner.locs )

#cat( '\nY top locations of patchs are:\n');
#show( y.corner.locs )



#start loop through patches and set appropriate cells in habmap to zero
for( x in 1:num.patches.x ) {
  for( y in 1:num.patches.y ) {

    x.int <- as.integer( x.corner.locs[x] ); #convert to integer
    y.int <- as.integer( y.corner.locs[y] );
    #cat( paste('\n x = ', x.int,' y = ', y.int, '\n' )  );

    x.locs <- x.int:(x.int + spacingX); #vector of x cell locations in map
    #cat( '\nX locations are:\n');
    #show(x.locs);
    
    y.locs <- y.int:(y.int + spacingY); #vector of y cell locations in map
    #cat( '\nY locations are:\n');
    #show(y.locs);

    #set the values in the habitat matrix
    hab.matrix[ y.locs, x.locs ] <- as.integer( habitat.value );

  }    
}

#write the map out
    #  Changed z01 to zo1 to match other uses in the python code.
    #  BTL - 02/03/09.
###write.pgm.txt.files( hab.matrix, master.habitat.map.z01.base.filename, rows, cols )
write.pgm.txt.files( hab.matrix, master.habitat.map.zo1.base.filename, rows, cols )



