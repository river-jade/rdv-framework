
pause <- function( info  ) {

  cat( "\n------------------------------------------------------------\n")
  cat( info )
  cat( "\n\nOptions:" )
  
  if( PAUSE.BETWEEN.STAGES ) {

    option = menu(  c("Continue", "Stop") );
  
    if( (option == 0) || (option ==2)) {
      stop("Aborted by user", call. = FALSE );
    }
    
  }
}

