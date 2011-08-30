

# source( "testing.loss.cond.model.R" )


for( step in seq(0, 100, 10) ) {

  current.time.step <- step;
  
  source( 'loss.model.R' );
  
  source( 'grassland.condition.model.R' )

}
