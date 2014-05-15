

    #-----------------------------------------------------------#
    #                                                           #
    #                                                           #
    #                                                           #
    #                                                           #
    #                                                           #
    #                                                           #
    #                                                           #
    #                                                           #
    #                                                           #
    #                                                           #
    #                                                           #
    #                                                           #
    #     source( 'gen.reserved.patches.R' )             #
    #-----------------------------------------------------------#


master.habitat.map.pid.filename <- planning.units.filename

reserve.map <- PAR.Zonation.reserve.map


####INPUT FILES
                
sel.res.full <- function( threshold ) {

  cat ("\nCalculating selected reserves\n")


 
  #read in patch map
  patch.id.map <-
    as.matrix( read.table( master.habitat.map.pid.filename ));

  #get a vector of unique values in the map
  u <- unique ( as.vector ( patch.id.map ) )

  #remove the background value
  pids <- sort( u[ u != non.habitat.indicator ] )

  #read in zonation file
  zonation.map  <- as.matrix ( read.table(reserve.map) )


  #matrix to store the selected patches
  res <- patch.id.map
  res[,] <- as.integer( non.habitat.indicator )
  
  tmp <- patch.id.map  #tmp matrix to use in the loop
  tmp[,] <- as.integer( non.habitat.indicator ) 

  #vector to store the locations of pids of the selected patches.
  #ie the elements of the pid vector which contain the reserved patches
  #create from pids vector so it has enough elements for each patch
  spids <- pids
  spids[] <- 0  #set to zero

   
  total.reserved.area <- as.integer( 0 );
  ctr <- 1;

  for( i in pids ) {
    
    num.pixels.in.patch <- length(patch.id.map[ patch.id.map == i ]);
    
    #set cells in a patch that overlap zonation to one
    tmp[ which( (zonation.map >= threshold) & (patch.id.map == i) )] <- 1;

    num.pixels.that.overlap <- length(  tmp[which( tmp == 1)] );
    curr.proportion.of.overlap <- num.pixels.that.overlap / num.pixels.in.patch ;

    if( DEBUG ) { 
      cat( '\nPatch', i, 'size = ', num.pixels.in.patch );
      cat( ' num.pixels.that.overlap  = ', num.pixels.that.overlap );
      cat( ' curr.proportion.of.overlap = ', curr.proportion.of.overlap  );
    }
    
    if( curr.proportion.of.overlap >= prop.of.patch.overlap ) {
    
      if(DEBUG) print( paste( "Patch", i, " is reserved" ) )

      res[ which( (patch.id.map == i)  )] <- as.integer( i );

      patch.area <- length( patch.id.map [ patch.id.map  == i ] );
      total.reserved.area <- total.reserved.area + patch.area;
      
      #save the patch number in the spids vector
      spids[ ctr ] <- 1
      
    }
    
    ctr <- ctr + 1 #increment the counter    
    tmp[,] <- as.integer( non.habitat.indicator )   #reset the tmp matrix to non habitat

  }

  #make a binary reserve map
  binary.res <- res;
  binary.res[ which( res != non.habitat.indicator  )  ] <- as.integer(1);

  
  #save the sorted values of spids with the zero's removed
  reservedPatchIds <-  t(sort( pids[ spids == 1] ));
  unreservedPatchIds <- t(sort( pids[ spids == 0  ] ));

  num.of.patches.to.reserve <- length(  reservedPatchIds );

  if( length(reservedPatchIds < 500) & length( unreservedPatchIds)  ) {

    # don't print these out if more then 500
    
    if( DEBUG ) {
      print( "the reserved pids are:" )
      print( reservedPatchIds )

      print( "the un-reserved pids are:" )
      print( unreservedPatchIds )
    }
  }


  
  #output maps and pid files
  writeOutputVector( reserved.pid.list.filename, reservedPatchIds )
  writeOutputVector( unreserved.pid.list.filename, unreservedPatchIds )

  write.pgm.txt.files( binary.res, reserve.map.name.base, rows, cols )
  
  cat( '\nFinished reserve selection.' );
  cat( '\n - Num of patches reserved  = ', num.of.patches.to.reserve );
  cat( '\n - Total area reserved = ', total.reserved.area , 'Pixels\n');
  
  cat( '\n' );
  cat( num.of.patches.to.reserve, total.reserved.area, '\n',
    file = reserve.info.file  );


}
###################################################################

sel.res.partial <- function( threshold ) {
 
  #read in patch map

  patch.id.map  <-
    as.matrix( read.table( master.habitat.map.pid.filename ));

  
  # get a vector of unique values in the map
  u <- unique ( as.vector ( patch.id.map ) )

  #remove the background value
  pids <- sort( u[ u != non.habitat.indicator ] );

  

  zonation.map <- as.matrix ( read.table(reserve.map) ); 

  #Now make the selection
  #now select paches based on overlap with pixels in
  #zonation map over some threshold

  #matrix to store the selected patches
  res <- patch.id.map;
  res[,] <- as.integer( non.habitat.indicator );

  #vector to store the pids of the selected patches.
  #create from pids vector so it has enough elements for each patch
  spids <- pids
  spids[] <- 0  #set to zero

  ctr <- 1
  
 
  for( i in pids ) {
    
    #set the cells to i if is there any overlap with zonation map
    res[ which( (zonation.map >= threshold) & (patch.id.map == i)  ) ] <- i
    
    #print( paste( "patch no", i ))

    if( length (which((zonation.map >= threshold) & (patch.id.map == i)) ) > 0) {
      
      #print( paste( "patch ", i, " is reserved" ) )
      #save the patch number in the spids vector
      spids[ ctr ] <- 1
    }
    ctr <- ctr + 1 #increment the counter

    #browser()
  }
  
  binary.res <-  res;
  binary.res[ which( res != non.habitat.indicator  )] <- as.integer(1);

    
  #save the sorted values of spids with the zero's removed
  reservedPatchIds <- t(  pids[ spids == 1 ] )
  unreservedPatchIds <- t(  pids[ spids == 0 ] )

  print( "the reserved pids are:" )
  print( reservedPatchIds )

  print( "the un-reserved pids are:" )
  print( unreservedPatchIds )

  #output maps and pid files
  writeOutputVector( reserved.pid.list.filename, reservedPatchIds );
  writeOutputVector( unreserved.pid.list.filename, unreservedPatchIds );

  #write.txt.file( res, outFileName, rows, cols );
  write.pgm.txt.files( binary.res, reserve.map.name.base, rows, cols );


  #calculate the number of pixels and area reserved
  num.reserved.pixels <- length( which( res != non.habitat.indicator ) );
  area.reserved <- num.reserved.pixels * pixel.size * pixel.size;
  cat( '\nZonation reserve selection finished.' );
  cat( paste( '\nThe number of pixels reserved is', num.reserved.pixels ));
  cat( paste( '\nThe total area reserved is', area.reserved, '\n'  ));



  
}

###############################################################################


