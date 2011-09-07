    #-----------------------------------------------------------#
    #                                                           #
    #                  dbms.functions.R                         #
    #                                                           #
    #  Functions for setting up and writing data to a database. #
    #  Currenty set up for using with SQLite, but shouldn't have#
    #  change much if we swap to another DBMS.                  #
    #                                                           #
    #  Created Dec 9, 2008 - Ascelin Gordon                     #
    #  to run   (from runall directry)                          #
    #                                                           #
    #  source( '..\\R\\dbms.functions.R' )                      #
    #                                                           #
    #-----------------------------------------------------------#

    #------------------------------------------------------------
    #  Database management variables
    #------------------------------------------------------------

source( 'dbms.functions.variables.R' )

# Connect to the database

connect.to.database <- function( db.name ) {
  
  try( library(RSQLite) );
  
  #if (exists("globalSQLcon")) {
    
  #  try( dbDisconnect(globalSQLcon) );
  #}
  
  globalSQLcon <<- dbConnect(
                              dbDriver(globalDBdriver),
                              dbname = db.name
                              )
  #cat( '\nDBMS> Successfully opened connection to DB', db.name, '\n' );
  
}

close.database.connection <- function() {

  if (exists("globalSQLcon")) { 
    try( dbDisconnect(globalSQLcon) );
  }


  #cat( '\nDBMS> Closed DB connection' );
  
}


    #------------------------------------------------------------
    #  Functions to write data to file 
    #------------------------------------------------------------


write.data.to.db <- function( table.name, data.to.write) {

  # the data is not in a data frame then convert to be one
  if( !is.data.frame( data.to.write ) ) {
    
    data.to.write <- data.frame (data.to.write );
    
  }

  dbWriteTable(globalSQLcon, table.name, data.to.write, append = TRUE )

  #cat( '\nDBMS> wrote data to table', table.name );
}


write.data.to.textfile <- function( filename, data.to.write ) {
  
  cat( data.to.write, '\n', file = filename, append = TRUE  );
  
}




    #------------------------------------------------------------
    #  Functions to retrive data
    #------------------------------------------------------------



# Retrieve the data

# Use a single database connection, so I do not want to
# give the connection argument each time.

sql <- function (query) {
  
  res <- dbGetQuery(globalSQLcon, query)
  
  # When the result has a single column, convert to a vector 
  # (as default is to return a data.frame.
  
  if (!is.null(res)) {  
    if (is.data.frame(res) & ncol(res) == 1) {
      
      res <- res[,1]
    }
  }
  
  drop(res)

  # add line
   return( res )
}
