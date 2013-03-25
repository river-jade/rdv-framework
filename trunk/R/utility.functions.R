


# source( 'utility.functions.R' )

#-----------------------------------------------------------------------------

safe.remove.file.if.exists <- function( filename ) {
  
  if ( file.exists ( filename ) ) {
    
    if( !file.remove( filename ) ) {
      cat( '\nError: could not delete existing file:',
          filename, '\n')
      stop.execution();
    }
    
  }
}

#-----------------------------------------------------------------------------

# obtained from http://r.789695.n4.nabble.com/Extracting-File-Basename-without-Extension-td878817.html

# RECURSIVE function to remove the extension of a filename
no.extension <- function(astring) {
  if (substr(astring, nchar(astring), nchar(astring))==".") {
    return(substr(astring, 1, nchar(astring)-1))
  } else {
    no.extension(substr(astring, 1, nchar(astring)-1))
  }
}


#-----------------------------------------------------------------------------

get.unique.ids.from.map <- function( map.filename, non.habitat ) {

  map <- as.matrix( read.table(map.filename) );

  unique.ids <- unique ( as.vector( map[ which(map != non.habitat)] ) );

  unique.sorted.ids <- sort( unique.ids );

  return( unique.sorted.ids );
  
}


#-----------------------------------------------------------------------------

get.num.pixels.for.each.id.from.map <- function( map.filename, non.habitat ) {

  map <- as.matrix( read.table(map.filename) );

  unique.ids <- unique ( as.vector( map[ which(map != non.habitat)] ) );

  unique.sorted.ids <- sort( unique.ids );

  area.vector <- vector( length = length(unique.sorted.ids) );

  pu.ctr <- 0;
  for( cur.pu.id in unique.sorted.ids) {

    pu.ctr <- pu.ctr + 1;
    
     area.vector[pu.ctr] <- length( map[ map == cur.pu.id ] );
    
  }

  
  ids.and.areas <- cbind( unique.sorted.ids, area.vector )


  return( ids.and.areas );
  
}



#-----------------------------------------------------------------------------

remove.entries.from.vector <- function( vec, entries.to.remove) {

  # function that takes a vector and a list of
  # the values to be removed from that vector
  # returns the vector with the values removed.
  
    indices.to.remove <- which( vec %in% entries.to.remove  )
    vec <- vec[ -indices.to.remove ];

  return( vec );

}

#-----------------------------------------------------------------------------

display.progress <- function( cur.count, total.interations  ){

  quater.value <- floor(total.interations / 4);

  if( cur.count == 1 )                 cat('\n\nIn loop...');
  if( cur.count == quater.value )      cat('25%...');
  if( cur.count == 2*quater.value )    cat('50%...');
  if( cur.count == 3*quater.value )    cat('75%...');
  if( cur.count == total.interations ) cat('100%\n');
  
      
}

#-----------------------------------------------------------------------------

greedy.selection.of.PUs <- function( sorted.pus, cost.vector, budget ){

  running.pus.to.reserve <- rep( -999, length ( sorted.pus ));
  running.total.cost <- 0;

  ctr = 0;
  for( cur.pu in sorted.pus ){
    ctr <- ctr + 1;

    cur.cost <- cost.vector [ctr];

    temp.running.total.cost <-
      running.total.cost + cur.cost;


    if( DEBUG ) { 
      cat( '\ncost = ', cur.cost, 'amt left =',budget - running.total.cost,
          'tmp.r.cost =', temp.running.total.cost,
          ' r.cost =',  running.total.cost, '||budget =', budget  );
    }

        
    if( temp.running.total.cost <= budget ){
    
      # can afford the patch, add it to the reserved patch list
      running.pus.to.reserve[ctr] <- cur.pu;

      running.total.cost <- running.total.cost + cur.cost;
      
      if(DEBUG) {
        cat( '\nPU_id=', cur.pu, '  cost=', cur.cost,
            '  Running total=', running.total.cost, sep = '' );
      }
   

    
    } else {

      # the budget was exceeded, don't do anyting but keep lookping
      # through the PUs to see can fit in any more within the
      # remaining budget
      
      if(DEBUG){
        cat('\nExceeded budget. Would have running cost of',running.total.cost,
            '\nif added patch', cur.pu, ' with cost = ', cur.cost,
            '\n( Budget for this timestep = ', budget, ')',
            '\nContinuing to see if other PUs can fit in remaining budget\n\n')
      }

    }

   #browser()
  }


  pus.to.reserve <-
    running.pus.to.reserve[ which( running.pus.to.reserve != -999 )];
  
  
  return( pus.to.reserve );
}

#-----------------------------------------------------------------------------


    #------------------------------------------------------------
    #  smooth.map.R:
    #   Does a moving window smoothing of a map using arbitary
    #   window size. The smoothing is done by setting the value
    #   of the focal cell to the mean value of all the cells in 
    #   the window around the cell. NOTE: currently the function
    #   igonore cells within window size of the edge (leaves them 
    #   unchanged).
    #   Also the code does not check the windowsize relative to the
    #   map size
    #
    #   Returns the smoothed map and writes pgm's of the orig and
    #   smoothed map.
    #------------------------------------------------------------



smooth.map <- function( map, window.size, weight.of.non.focal.pixels ) {

  wind.size <- window.size;

  # get the map dimensions
  map.dim <- dim(map)

  rows <- map.dim[1]
  cols <- map.dim[2]


  smoothed.map <- map;
  smoothed.map[,] <- 0;

  total.iterations <- rows*cols;

  for( y in 1:rows ) {
    for( x in 1:cols ) {

      smoothed.map[y,x] <- map[y,x];
    
      # make sure that the window doesn't overlap the edge
      # for now will just ignore pixels within a window width from
      # the edge
    
      if( x > wind.size  & y > wind.size ) {

        # far enough away from top or left edge
      
        if( x <= (cols - wind.size) &  y <= (rows - wind.size) ) {

          # far enough from the bottom or right
        
          if(DEBUG) {
            cat( '\nAway from edge: Value = ', map[y,x],
                '[x=', x, 'y=', y, ']' );
          }

          #browser()
          if( map[y,x] >0  ) {
          
            # get the pixels of the window...
            x.window.indices <- (x-wind.size):(x+wind.size)
            y.window.indices <- (y-wind.size):(y+wind.size)

            
            if(DEBUG) {
              cat( '\n   x.window.indices', x.window.indices );
              cat( '\n   y.window.indices', y.window.indices );
            }

            window.values <- map[y.window.indices,x.window.indices ];

            if( DEBUG ) {
              cat( '\nValues = ', window.values);
            }

            
              #-----------------------------------
              #  Work out the weight vector for the weighted mean
              #  calculation
              #-----------------------------------
            
            # define the vector to hold the weight values
            no.pixels.in.window <-
              length( x.window.indices)*length(y.window.indices);

            weights.vec <- rep( -1,no.pixels.in.window );
            
            # set all pixels to have a weight values specified by
            # weight.of.non.focal.pixels            
            weights.vec[ 1:no.pixels.in.window ] <-
              weight.of.non.focal.pixels;

            # then set the central pixel of the window to have value 1
            #   if window size =1 then have 3*3 window
            #   if window size =2 then have 5*5 window, etc...
            central.pixel <- ceiling( no.pixels.in.window/2 );
            weights.vec[central.pixel] <- 1;

            
            # decide whether to remove all values < 0 for calc average value
            if( OPT.exclude.zeros.in.smoothing ) {

              # in this case only using a subset of the pixels in the
              # smoothing calculation
              
              window.values.in.calc <- window.values[ which(window.values>0)];
              
              # this is fine for the trivial smoothing window were all
              # values are the same except for the central pixel. Neet
              # to make sure this line of code still holds for the
              # case where using an arbitary kernel shape
              
              weights.vec2 <- weights.vec[which(window.values>0)];

            } else {

              # otherwise use all pixels
              window.values.in.calc <- window.values;
              weights.vec2 <- weights.vec;
            }


            smoothed.pixel.value.weights <-
              weighted.mean( window.values.in.calc, weights.vec2 );

            
            #smoothed.pixel.value <- mean( window.values.in.calc )

            smoothed.map[y,x] <- smoothed.pixel.value.weights;


          }  # end - if( map[y,x] >0  ) {

          
        }  #  end - if( x <= (cols - wind.size) &  y <= (rows - wind.size) )
      }  #  end - if( x > wind.size  & y > wind.size ) 
    }  #  end - for( x in 1:cols ) 
  }  #  end - for( y in 1:rows ) 


 return( smoothed.map );
  
}

kernel.smooth.map <- function( map, kernel) {

                              # weight.of.non.focal.pixels ) {
  

  # check that it's a square kernel
  if( dim(kernel)[1] != dim(kernel)[2] ) {
    cat( '\nError. The kernel must be square' );
    stop();
  }
  
  sidelength <- dim(kernel)[1];

  wind.size <- floor( sidelength / 2 );
  # then find the central pixel of the window 
  #   if window size =1 then have 3*3 window
  #   if window size =2 then have 5*5 window, etc...
  
  central.index <- ceiling( dim(kernel)[1]/2 );

  # get the map dimensions
  map.dim <- dim(map)

  rows <- map.dim[1]
  cols <- map.dim[2]


  smoothed.map <- map;
  smoothed.map[,] <- 0;

  total.iterations <- rows*cols;

  for( y in 1:rows ) {
    for( x in 1:cols ) {

      smoothed.map[y,x] <- map[y,x];
    
      # make sure that the window doesn't overlap the edge
      # for now will just ignore pixels within a window width from
      # the edge
    
      if( x > wind.size  & y > wind.size ) {

        # far enough away from top or left edge
        if( x <= (cols - wind.size) &  y <= (rows - wind.size) ) {

          # far enough from the bottom or right
        
          if(DEBUG) {
            cat( '\n\nAway from edge: Value = ', map[y,x],
                '[x=', x, 'y=', y, ']' );
          }

          #browser()

          # only want to smooth non zero values for grassland
          
          if( map[y,x] >0  ) {
          
            # get the pixels of the window...
            x.window.indices <- (x-wind.size):(x+wind.size)
            y.window.indices <- (y-wind.size):(y+wind.size)

            
            if(DEBUG) {
              cat( '\n   x.window.indices', x.window.indices );
              cat( '\n   y.window.indices', y.window.indices );
            }

            window.values <- map[y.window.indices,x.window.indices ];

            if( DEBUG ) {
              cat( '\nValues = ', window.values);
            }

            
            if( OPT.smoothing.option ==
               OPT.VAL.only.use.pixels.below.fixed.val.in.smoothing) {

              smooth.indices <-
                which( window.values < PAR.fixed.val.for.smoothing );
              
              smooth.vales <- window.values[smooth.indices];
              
              if( DEBUG ){
                cat( '\nsmooth.indices =', smooth.indices );
                cat( '\nsmooth.vales =', smooth.vales );
              }
              
              cent.k.val <- kernel[central.index, central.index ];
              cent.w.val <- window.values[central.index, central.index ];
              
              if( length( smooth.indices ) > 0 )  {
                
                weights.vec2 <- c( kernel[ smooth.indices ], cent.k.val );
                window.values.in.calc <- c( smooth.vales, cent.w.val );
              } else {
                
                weights.vec2 <- 1;
                window.values.in.calc <- cent.w.val;
              }

              if( DEBUG ){
                cat( '\nweights.vec2 =', weights.vec2 );
                cat( '\nwindow.values.in.calc =', window.values.in.calc );
              }

              #browser();

              
            } else {

              
              # decide whether to remove all values < 0 for calc average value
              if( OPT.smoothing.option == OPT.VAL.exclude.zeros.in.smoothing ){

                # in this case only using a subset of the pixels in the
                # smoothing calculation
              
                window.values.in.calc <- window.values[which(window.values>0)];
              
                # this is fine for the trivial smoothing window were
                # all values are the same except for the central
                # pixel. Neet to make sure this line of code still
                # holds for the case where using an arbitary kernel
                # shape
              
                weights.vec2 <- kernel[which(window.values>0)];

                
              } else {


                if( OPT.smoothing.option==OPT.VAL.use.all.pixels.in.smoothing){
                  # otherwise use all pixels
                  window.values.in.calc <- as.vector( window.values ); 
                  weights.vec2 <- as.vector( kernel );
                  
                } else  {

                  cat( '\nUnknown value for OPT.smoothing.option =',
                      OPT.smoothing.option );
                  stop();
                }

              }
              
            }

            smoothed.pixel.value.weights <-
              weighted.mean( window.values.in.calc, weights.vec2 );

            
            #smoothed.pixel.value <- mean( window.values.in.calc )

            smoothed.map[y,x] <- smoothed.pixel.value.weights;


          }  # end - if( map[y,x] >0  ) {

          
        }  #  end - if( x <= (cols - wind.size) &  y <= (rows - wind.size) )
      }  #  end - if( x > wind.size  & y > wind.size ) 
    }  #  end - for( x in 1:cols ) 
  }  #  end - for( y in 1:rows ) 


 return( smoothed.map );
  
}


test.kernel.smooth.map <- function() {

  OPT.VAL.exclude.zeros.in.smoothing <<- 1;
  OPT.VAL.only.use.pixels.below.fixed.val.in.smoothing <<- 2;
  OPT.VAL.use.all.pixels.in.smoothing <<-  3;  
  PAR.fixed.val.for.smoothing <<- 0.12;
            
  OPT.smoothing.option <<-OPT.VAL.only.use.pixels.below.fixed.val.in.smoothing;
  
  
  DEBUG <<- FALSE

  # make a test kernel
  k.vals <- c(0.01,0.01,0.01,0.01,1,0.01,0.01,0.01,0.01)
  my.kernel <- matrix ( k.vals, nrow = 3, ncol = 3, byrow = TRUE );


  # make a test map
  #m.vals <- sample( 1:10, 36, replace = TRUE);
  #m.vals <- sample( c(0.11, 0.12, seq( 0.1, 0.75, 0.05 )), 36, replace = TRUE);

  m.vals <- c(
              0.0, 0.5, 0.0, 0.5, 0.5, 0.5,
              0.0, 0.5, 0.0, 0.5, 0.5, 0.5,
              0.0, 0.0, 0.0, 0.5, 0.5, 0.5,
              0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
              0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
              0.5, 0.5, 0.5, 0.5, 0.5, 0.5
              )
              
  my.map <- matrix ( m.vals, nrow =6, ncol = 6, byrow = TRUE );

  #my.map[1,] <- 0;
  #my.map[5,2] <- 0;

  cat( '\nmy.map is\n' );
  show( my.map );
  
  cat( '\nmy.kernel is\n' );
  show( my.kernel );
  cat( '\n' );

  my.smoothed.map <- kernel.smooth.map( my.map, my.kernel);

  cat( '\nmy.smoothed.map is\n' );
  show( round(my.smoothed.map, 3)  );
  cat( '\n' );

  
}



#==============================================================================
# Little function to consistently treat the sample pool to sample
# from when only one element left.  In R's 'sample' function a pool with
# one element is treated as a vector with elements 1:x
#
# source( 'Sample.RDV.R' );

#  - DWM 17/09/2009 
#==============================================================================

sample.rdv <- function( pool, x)
{
  if( length(pool) == 0 )
  { 
    cat('\nError in sample.rdv(): cant sample from vector of length zero!\n');
    stop(); 
  }
  if( length(pool) == 1 )
  {
    return( pool )
  } else
  {
    return( sample( pool, x) );
  }
}
  



##########################################################################################

dump.data.frame.to.file <- function( df.to.dump, filename ) {

  
  
  dump( "df.to.dump", file = filename)
  
  
}
