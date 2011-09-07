

stop.execution <- function() {
  
  #unset the MULTIBATCH variable
  if( exists('MULTIBATCH')) rm( MULTIBATCH )
  
  # stop execution
  stop( "\nAborted due to error in input.", call. = FALSE );

}
