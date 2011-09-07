


#  source( 'testing.cond.model.R' )

rm( list = ls( all=TRUE ));

source( 'variables.R' );
source( 'grassland.condition.model.functions.R' );



#-----------------------------------------------------------------------------


PAR.variablity.percent <- 0.15;
GC.grassland.threshold.value <- 0.35
GC.grassland.min.cond.score <- 0.1;
GC.grassland.max.cond.score <- 0.7;



#-----------------------------------------------------------------------------


reps <- 50;

time.steps <- 40;
time.step.interval <- 2 # in years

init.res.cond <- 0.15;
init.unres.cond <- 0.7;


# vectors to hold the res and unres time series
res.matrix <- matrix( ncol = time.steps, nrow = reps )
unres.matrix <- matrix( ncol = time.steps, nrow = reps )

mean.res.vector <- vector( len = time.steps );
mean.unres.vector <- vector( len = time.steps );


# this defines as global functions the reference curves for how
# grasslands condition changes over time

define.reference.curves();

time.values <- c( (1:time.steps)* time.step.interval );

for( r in 1:reps ) {
  
  cur.res.cond <- init.res.cond;
  cur.unres.cond <- init.unres.cond;

  for( t in 1:time.steps ) {
    
    res.matrix[r,t] <- cur.res.cond;
    unres.matrix[r,t] <- cur.unres.cond;


    new.res.cond <- evolve.condition(cur.res.cond,time.step.interval,"MANAGED" );
    
    new.unres.cond <- evolve.condition(cur.unres.cond, time.step.interval,
                                       "UNMANAGED" );
    
    #cat( "\n--\n  timestep", t, "man cond   = ", new.res.cond );
    #cat( "\n  timestep", t, "unman cond = ", new.unres.cond );
    
    cur.res.cond <-  new.res.cond;
    cur.unres.cond <- new.unres.cond;
    
  }
}


x <- (1:time.steps);

par(mfrow = c (2,1))

plot (x, res.matrix[1,], type = 'l', ylim = c( 0, 0.8) );


maxed.ctr <- 0;

for( r in 1:reps ) {


  lines (x, res.matrix[r,] );

  num.reached.max <- which ( res.matrix[r,] > 43 )

  if( length(  num.reached.max ) > 0 ) {
    maxed.ctr <- maxed.ctr +1 ;
  }
  
}



# calculate and plot the mean trajectory
for( t in 1:time.steps) mean.res.vector[t] <- mean( res.matrix[,t] )
lines( x, mean.res.vector, col = 'green', lwd = 3 );

# plot the threshold lines
abline( h = GC.grassland.max.cond.score, col = 'red' )
abline( h = GC.grassland.min.cond.score, col = 'red' )
abline( h = GC.grassland.threshold.value, col = 'red' )


#cat( '\nProportion of reserved runs where cond > 43:',
#    maxed.ctr, '/', reps, '=', maxed.ctr/reps );


plot (x, unres.matrix[1,], type = 'l', ylim = c(0,0.8) );


min.ctr <- 0;

for( r in 1:reps ) {

  #lines( x, unres.matrix[r,]);


 # num.reached.min <- which ( unres.matrix[r,] < 5 )

#  if( length(  num.reached.min ) > 0 ) {
 #   min.ctr <- min.ctr +1 ;
    
 # }
 
  
}


for( t in 1:time.steps) mean.unres.vector[t] <- mean( unres.matrix[,t] )
lines( x, mean.unres.vector, col = 'green', lwd = 3 );
abline( h = GC.grassland.max.cond.score, col = 'red' )
abline( h = GC.grassland.min.cond.score, col = 'red' )


  
#cat( '\nProportion of unreserved runs where  cond < 5:',
#    min.ctr, '/', reps, '=', min.ctr/reps );


cat( '\n' );






two.d.test <- function() {
  
  time.step.interval = 20;
  
  test.map <- matrix( c(0.2, 0.2, 0.2, 0.2 ), nrow = 2, ncol = 2 );
  
  new.res.cond <- evolve.condition(test.map, time.step.interval,"MANAGED" );
  new.unres.cond <- evolve.condition(test.map, time.step.interval,"UNMANAGED" );


  print( "init" );
  show( test.map );

  print( "managed" );
  show( new.res.cond );
  
  print( "unmanaged" );
  show( new.unres.cond );
  
}
