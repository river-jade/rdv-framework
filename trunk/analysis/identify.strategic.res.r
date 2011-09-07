#1. figure out summed condition of development pool
#2. identify a strategic reserve with the same net condition
#    - find the zonation threshold that produces a reserve with the same condition
#
#   1.
#   read in vector of development pool pus
#   query database to get condition of all and sum
#
#   2.
#   zonation reserve maps for various thresholds
#   match pixel ids or pus (?) in zonation map to condition map and get summed
#   condition - PUs fit linear(?) curve to points
#   read off curve the threshold required test if correct


# source( "identify.strategic.res.r" )

rm( list = ls( all=TRUE ));




source( "..\\R\\w.R" );
source( "dbms.functions.r" );
#source( '..\\R\\gen.reserved.patches.R' )
source( '..\\R\\utility.functions.R' );

DEBUG <<-  FALSE;

# input files
master.habitat.map.pid.filename <- "..\\runall\\hab.map.master.pid.txt";
reserve.map <<- "..\\runall\\zonation_output.rank.txt";
planning.units.filename <<- "..\\runall\\planning.units.uid.txt";
PUinformationDBbname <<- '..\\runall\\PUinformation.dbms';

# output files
patch.map.filename.base <<-  "..\\analysis\\res.patch.map";
reserved.map.filename.base <<- "..\\analysis\\reserved.map";


# Variables
non.habitat.indicator <<- 0;

# Thresholds for reserving a patch or a PU  - amount of reserve patch required
PAR.prop.pixels.in.PU.to.reserve <<- 0.7;
#Z.thresholds <- c(0.96, 0.94, 0.92, 0.91); # 0.85 too low
Z.thresholds <- c(0.9, 0.88); # 0.85 too low
#Z.thresholds <- c(0.9175);

#-------------------------------------------------------------------#
get.total.condition.of.patch.subset <- function( pu.vector, descriptor )
{
  if( file.exists( PUinformationDBbname ))
  {
      connect.to.database( PUinformationDBbname );
  } else {
      cat( '\nError: the database file: ', PUinformationDBbname, 'does not exist\n' );
      stop();
  }
  
  connect.to.database( PUinformationDBbname );
  
  cond.sum <- 0;
  
  if( length( pu.vector) < 1 ) 
  {
    cat( "\n\nError: zero length reserve pool.\n" );
    stop();
  }
  
  for( pu in pu.vector )
  {
      query1 <- paste( 'select TOTAL_COND_SCORE_SUM from dynamicPUinfo ',
                              'where ID = ', pu, ';', sep = '' ); 
      
      result <- sql( query1 );
     
      if( length(result) == 0 )
      {  result <- 0  }
      
      #cat( "\n cond.sum = ",  result );
      
      cond.sum <- cond.sum + result; 
  }
  
  cat( "\nTotal summed condition of ", descriptor, " = ", cond.sum, "\n\n" );
  
  close.database.connection();

  return( cond.sum );
}

 #--------------------------------------------------------------#
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
  #res <- patch.id.map
  #res[,] <- as.integer( non.habitat.indicator )
  
  tmp <- patch.id.map  #tmp matrix to use in the loop
  tmp[,] <- as.integer( non.habitat.indicator ) 

                #vector to store the locations of pids of the selected patches.
                #ie the elements of the pid vector which contain the reserved patches
                #create from pids vector so it has enough elements for each patch
                #spids <- pids
                #spids[] <- 0  #set to zero

   
   total.reserved.area <- as.integer( 0 );
                #ctr <- 1;

  for( i in pids ) 
  {
    
    num.pixels.in.patch <- length(patch.id.map[ patch.id.map == i ]);
    
    #set cells in a patch that overlap zonation to one
    tmp[ which( (zonation.map >= threshold) & (patch.id.map == i) )] <- 1;

    #num.pixels.that.overlap <- length(  tmp[which( tmp == 1)] );
    #curr.proportion.of.overlap <- num.pixels.that.overlap / num.pixels.in.patch ;

    if( DEBUG ) { 
      cat( '\nPatch', i, 'size = ', num.pixels.in.patch );
      cat( ' num.pixels.that.overlap  = ', num.pixels.that.overlap );
      cat( ' curr.proportion.of.overlap = ', curr.proportion.of.overlap  );
    }
    
    r.area <- length( tmp[ tmp  == 1 ] );
    total.reserved.area <- total.reserved.area + r.area;
                #ctr <- ctr + 1 #increment the counter    
    #tmp[,] <- as.integer( non.habitat.indicator )   #reset the tmp matrix to non habitat

  }

            #make a binary reserve map
            #binary.res <- res;
            #binary.res[ which( res != non.habitat.indicator  )  ] <- as.integer(1);
            
            
                      #save the sorted values of spids with the zero's removed
                      #reservedPatchIds <-  t(sort( pids[ spids == 1] ));
                      #unreservedPatchIds <- t(sort( pids[ spids == 0  ] ));
                    
                      #num.of.patches.to.reserve <- length(  reservedPatchIds );
                    
                      #if( length(reservedPatchIds < 500) & length( unreservedPatchIds)  ) {
                      #
                      #  # don't print these out if more then 500
                        
                      #  if( DEBUG ) {
                      #    print( "the reserved pids are:" )
                      #    print( reservedPatchIds )
                    
                      #    print( "the un-reserved pids are:" )
                      #    print( unreservedPatchIds )
                      #  }
                      #}

   patch.map.filename <-
    paste (patch.map.filename.base, '-', threshold, sep = '');
  write.pgm.txt.files( tmp, patch.map.filename, 782, 832 );
 
  cat( '\nFinished reserve selection.' );
  #cat( '\n - Num of patches reserved  = ', num.of.patches.to.reserve );
  cat( '\n - Total area reserved = ', total.reserved.area , 'Pixels\n');
  
  cat( '\n' );

  return( tmp );

}
#-----------------------------------------------------------------------

get.PUs.to.reserve.from.patch.map <- function( reserve.map, pu.map, thresholdVal )
{
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
  #query <- paste( "select ID, cost from ", dynamicPUinfoTableName );
  query <- "select ID from dynamicPUinfo;";
  #pu.costs <- sql.get.data(PUinformationDBname , query);
  
  reserved.pu.indicies   <- vector( length = length(plan.unit.vec));
  reserved.pu.indicies[] <- as.integer( 0 );
  
  total.reserved.pu.area <- as.integer( 0 );
  
  ctr <- 0;
  
  tot.num.pus <- length( plan.unit.vec );
  
  #running.total.cost <- 0;
  
  for( cur.pu in plan.unit.vec ){
    
    ctr <- ctr + 1;
  
    #pu.cost.index <- which( pu.costs[, 1] == cur.pu );
    #cur.cost <- pu.costs[pu.cost.index,2];
  
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
      
      #total.reserved.pu.area <- total.reserved.pu.area + curr.pu.area;
  
      #running.total.cost <- running.total.cost + cur.cost;
  
    } else {
      #reserved.pu.map[ pu.map == cur.pu ] <- as.integer( 0 );
    }
  }
  
  
  reserved.planning.units <-  plan.unit.vec[reserved.pu.indicies == 1];
  unreserved.planning.units <-  plan.unit.vec[reserved.pu.indicies == 0];
  
  #number.of.pus.reserved <- length( reserved.planning.units );

  reserved.map.filename <-
    paste (reserved.map.filename.base, '-', thresholdVal, sep = '');
  write.pgm.txt.files( reserved.pu.map, reserved.map.filename, 782, 832 );
  
  close.database.connection();
  
  return( reserved.planning.units );

}



 #----- part 1.  -----------------------------------------------#
path.dev <- 'D:\\analysis\\svn\\framework2\\runall\\initialisation_files\\PUs_IN_DEV_POOL.txt';

#dev.pool <- as.vector( unlist( read.table( path.dev  )));

connect.to.database( PUinformationDBbname );
query2 <- 'select TOTAL_COND_SCORE_SUM from dynamicPUinfo where IN_DEV_POOL = 1;'
#query3 <- 'select ID from dynamicPUinfo where IN_DEV_POOL = 1;'
dev.pool.cond <- sum( sql( query2 ));

#pus <- sql(query3);
close.database.connection();

cat( "\nTotal summed condition of Development pool =", dev.pool.cond );
#dev.pool.cond2 <- get.total.condition.of.patch.subset(dev.pool, "Development pool"); 
 
 
 #----- part 2.  -----------------------------------------------#
#read in the planning unit map
pu.map  <- as.matrix ( read.table( planning.units.filename  ) );


# zonation thresholds to use to fit line for total condition
threshold <- Z.thresholds;
reserve.pool.cond <- vector(length = length(threshold));

for( x in 1:length(threshold) )
{

  cat( '\nUsing Zonation threshold = ', threshold[x] );
  
  # get the reserve patch map for the given zonation and patch thresholds
  res.map <-  sel.res.full( threshold[x] );

  # convert the reserved patches into reserved planning units
  res.pool <- get.PUs.to.reserve.from.patch.map( res.map, pu.map, threshold[x] );
  
  cat("length res pool is: ", length(res.pool));
   
  # get the reserve pool condition
  descr <- paste( "Strategic reserve (Z-threshold ", threshold[x], ")" );
  reserve.pool.cond[x] <-  get.total.condition.of.patch.subset(res.pool, descr);   
}  

plot( threshold, reserve.pool.cond, xlab = 'Zonation threshold', 
                               ylab ='Total reserve condition' ); 
 
fit <- lm(reserve.pool.cond ~ threshold);

print( fit ); 
 
 
 
