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
    #  source( 'dbms.functions.R' )                             #
    #                                                           #
    #-----------------------------------------------------------#

    #------------------------------------------------------------
    #  Database management variables
    #------------------------------------------------------------

source( 'variables.R' )


DEBUGGING.DBMS <- FALSE;

# Connect to the database

connect.to.database <- function( db.name ) {
  
  try( library(RSQLite) );
  
  #if (exists("globalSQLcon")) {
    
  #  try( dbDisconnect(globalSQLcon) );
  #}
  
  globalSQLcon <<- dbConnect(
                              #dbDriver("SQLite"),
                              dbDriver(globalDBdriver),
                              dbname = db.name
                              )
  if (DEBUGGING.DBMS)
    cat( '\nDBMS> Successfully opened connection to DB', db.name, '\n' );
  
}
#-----------------------------------------------------------------------------

close.database.connection <- function() {

  if (exists("globalSQLcon")) { 
    try( dbDisconnect(globalSQLcon) );
  }

  if (DEBUGGING.DBMS)
    cat( '\nDBMS> Closed DB connection\n' );
  
}

#-----------------------------------------------------------------------------

    #------------------------------------------------------------
    #  Functions to write data to file 
    #------------------------------------------------------------


write.data.to.db <- function( table.name, data.to.write) {

  # the data is not in a data frame then convert to be one
  if( !is.data.frame( data.to.write ) ) {
    
    data.to.write <- data.frame (data.to.write );
    
  }

  dbWriteTable(globalSQLcon, table.name, data.to.write, append = TRUE )

  if (DEBUGGING.DBMS)
    cat( '\nDBMS> wrote data to table', table.name );
}
#-----------------------------------------------------------------------------

write.data.frame.to.new.DB <- function(c.dataframe, c.new.DB.name, c.table.name ) {

  connect.to.database( c.new.DB.name )
  
  write.data.to.db( c.table.name, c.dataframe )
  
  close.database.connection()

}


#-----------------------------------------------------------------------------

write.data.to.textfile <- function( filename, data.to.write ) {
  
  cat( data.to.write, '\n', file = filename, append = TRUE  );
  
}




    #------------------------------------------------------------
    #  Functions to retrive data
    #------------------------------------------------------------



# Retrieve the data

# Use a single database connection, so I do not want to
# give the connection argument each time.

sql.get.data <- function (dbname, query) {
  
  connect.to.database( dbname );
  
  res <- dbGetQuery(globalSQLcon, query)
  
  # When the result has a single column, convert to a vector 
  # (as default is to return a data.frame.
  
  if (!is.null(res)) {  
    if (is.data.frame(res) & ncol(res) == 1) {
      
      res <- res[,1]
    }
  }
  
  drop(res)

  # if there was no data selected from the database return integer(0)

  if( length( res) == 0 ) {
    
    res <- integer(0);
    
  }
  
  close.database.connection();
  
  # add line
  return( res )
}

#-----------------------------------------------------------------------------
# single line version  - useful for offset testing code. 
# Added by Daniel 10 Aug 2009

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

  # if there was no data selected from the database return integer(0)

  if( length( res) == 0 ) {
    
    res <- integer(0);
    
  }
    
  # add line
  return( res )
}
#-----------------------------------------------------------------------------

sql.send.operation <- function (query) {

  #cat( '\nDBMS>sending query:', query ); 
  res <- dbSendQuery(globalSQLcon, query)

  # Not sure why this is here and it was causing error messages, so
  # I'm commenting it out for now. AG - 29 Nov 2010
  
  dbClearResult(res); 
  
  # Commenting this line otherwise the return value is printed if it's
  # not caught when this function is called

  #return( res )
}

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------

insert.pu.ids.to.db <- function( table.name, pu.id.vec, val.name) {

  if (DEBUGGING.DBMS)  
    cat( '\nAbout to write data to database' );
  
  connect.to.database( PUinformationDBname );

  pu.ctr <- 0;
  for( cur.pu in pu.id.vec ) {
    pu.ctr <- pu.ctr + 1;
    
    query <- paste( 'insert into ', table.name, ' ( ', val.name, ') values (',
                   cur.pu, ')', sep = '' );
    
    sql.send.operation( query );
    
  }
  
  close.database.connection();

}

#-----------------------------------------------------------------------------

insert.pu.id.and.value.to.db <- function( table.name, pu.ids.and.values.matrix,
                                        val.name) {
  if (DEBUGGING.DBMS)
    cat( '\nAbout to write data to database' );
  
  connect.to.database( PUinformationDBname );

  pu.id.vec <- pu.ids.and.values.matrix[,1];

  pu.ctr <- 0;
  for( cur.pu in pu.id.vec ) {
    pu.ctr <- pu.ctr + 1;
    
    cur.value <- pu.ids.and.values.matrix[pu.ctr,2];

    # build the query it should look something like this
    #     insert into PUstatus (ID AREA) values (77, 456) 
    # with the R variables
    #     insert into PUstatus (ID AREA) values (cur.pu, cur.value)

    query <- paste( 'insert into ', table.name, ' (ID,', val.name,') values (',
                   cur.pu, ',', cur.value, ')', sep = '' );
    
    sql.send.operation( query );
    
  }
  
  close.database.connection();

}

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------

update.single.db.pu.with.single.value <- 
    function (table.name, pu.id, value, db.col.name)
  {
  if (DEBUGGING.DBMS)
    cat ("\nAbout to update database for single PU with single value.");
  
  connect.to.database (PUinformationDBname);

      #-----------------------------------------------------
      #  Build the query. It should look something like this
      #      update PUstatus set COST = 345 where ID = 1';
      #-----------------------------------------------------  

  query <- paste( 'update ', table.name, ' set ', db.col.name, ' = ',
                 value, ' where ID = ', pu.id, sep = '' );

  sql.send.operation (query);
  
  close.database.connection ();
  }

#-----------------------------------------------------------------------------

update.db.all.pu.ids.with.single.value <- function(table.name, value,
                                               db.col.name) {

  connect.to.database( PUinformationDBname );


  query <- paste( 'update ', table.name, ' set ', db.col.name, ' = ',
                   value, sep = '' );

  sql.send.operation( query );
    
    
  close.database.connection();


}

#-----------------------------------------------------------------------------

# This function is for updating multiple entries in the same column of
# a single table. It's a little convoluted but is FAST (1 second
# compared to 2 minutes when using a loop). Instead of updating the
# table through database calls within a loop, the whole table in
# question is read into a R data frame, then the column in the data
# frame is updated, the original table is deleted in the data base,
# then the updated data frame is then written to the data base.

update.column.in.db.table.via.dataframe <- function(table.name, col.name, new.values ) {

  connect.to.database( PUinformationDBname )
  
  # First read the database into a data.frame
  db.data.frame <- dbReadTable(globalSQLcon, table.name)

  # Save the values to be overwritten that are currently in the data base
  old.vales <- db.data.frame[,col.name]

  # Update the data.frame with the new values

  # First check that the new values are the same length as the
  # dataframe and stop if this is not the case
  stopifnot( length(db.data.frame[,col.name]) == length(new.values) )
  
  db.data.frame[,col.name] <- new.values
  
  # Remove the old table from the database (it'll be recreated when we
  # dump the new data.frame to the database
  query <- paste( "DROP TABLE", dynamicPUinfoTableName )
  sql.res <- dbSendQuery( globalSQLcon, query )
  res <- dbClearResult( sql.res)
  
  # Write the new dataframe to the database
  res <- dbWriteTable(globalSQLcon, table.name, db.data.frame )
 
  close.database.connection()

}

#-----------------------------------------------------------------------------

update.db.pu.ids.with.single.value <- function(table.name, pu.id.vec, value,
                                               db.col.name) {

  # make a table containing PU Ids with the value to be updated
  pu.ids.and.single.value <- cbind(pu.id.vec, value );

  # update multiple planning units with multiple different values
  if (DEBUGGING.DBMS)
    cat( '\nAbout to write data to database' );
  
  connect.to.database( PUinformationDBname );

  pu.ctr <- 0;
  for( cur.pu in pu.id.vec ) {
    pu.ctr <- pu.ctr + 1;
    
    cur.val <- pu.ids.and.single.value[pu.ctr,2];
    #cur.val <- round( cur.val, 5);

    if ( is.na(cur.val) ) {
      # if there is a NA then turn it onto a zero
      # an NA can occure for PUs of 1 pixel when trying
      # to take the sd of the condition of all pixles in the PU
      cur.val = 0;
    }

    if( is.numeric( cur.val ) ) {
      # if it's a number round it off to 5 places to save space
      cur.val <- round( cur.val, 5);
      
    }

    
    # build the query. It should look something like this
    #     update PUstatus set COST  = 345 where ID = 1';

    query <- paste( 'update ', table.name, ' set ', db.col.name, ' = ',
                   cur.val, ' where ID = ', cur.pu, sep = '' );

    #browser()
    sql.send.operation( query );
    #browser()
    
  }
  
  close.database.connection();


}
#-----------------------------------------------------------------------------

#update.pu.id.and.value.to.db

update.db.pu.ids.with.multiple.values <- function(table.name,
                                                  pu.ids.and.values.matrix,
                                                  val.name) {


  # update multiple planning units with multiple different values
  if (DEBUGGING.DBMS)  
    cat( '\nAbout to write data to database' );
  
  connect.to.database( PUinformationDBname );

  pu.id.vec <- pu.ids.and.values.matrix[,1];

  
  pu.ctr <- 0;
  for( cur.pu in pu.id.vec ) {
    pu.ctr <- pu.ctr + 1;
    
    cur.val <- pu.ids.and.values.matrix[pu.ctr,2];

    if ( is.na(cur.val) ) {
      # if there is a NA then turn it onto a zero
      # an NA can occure for PUs of 1 pixel when trying
      # to take the sd of the condition of all pixles in the PU
      cur.val = 0;
    }

    if( is.numeric( cur.val ) ) {
      # if it's a number round it off to 5 places to save space
      cur.val <- round( cur.val, 5);
      
    }

    
    # build the query it should look something like this
    #     update PUstatus set COST  = 345 where ID = 1';

    query <- paste( 'update ', table.name ,' set ', val.name, ' = ', cur.val,
                   ' where ID = ', cur.pu, sep = '' );

    sql.send.operation( query );

    
  }
  
  close.database.connection();

}

#-----------------------------------------------------------------------------

build.sql.create.table.expression <- function( table.name, table.defn ) {

cols.expression <- '';

for( ctr in 1:dim(table.defn)[1] ) {

  cols.expression <- paste( cols.expression, table.defn[ctr,1],
      table.defn[ctr,2] );

  # add a ',' if not on the last entry
  if( ctr != dim(table.defn)[1]) {
    cols.expression <- paste( cols.expression, ',', sep = '' );
  }
}

sql.full.query <- paste( 'create table ', table.name, '(', cols.expression, ')',
                        sep = '' );

return( sql.full.query );

}

#-----------------------------------------------------------------------------

get.field.value.of.pu <- function (PU.ID, field.name)
  {
  query <- paste ('select ', field.name, ' from ', dynamicPUinfoTableName,
                 'where ID = ', PU.ID);
  
  return (sql.get.data (PUinformationDBname, query));
  }

#-----------------------------------------------------------------------------

selection.not.empty <- function (selection.returned.from.sql.query)
  {
  retval <- FALSE
  
  if (length (selection.returned.from.sql.query) < 1)
    {
    retval <- FALSE
    
    } else if (is.vector (selection.returned.from.sql.query))
    {
    retval <- (length (vector) > 0)
  
    } else if (is.data.frame (selection.returned.from.sql.query))
    {
    retval <- (dim (selection.returned.from.sql.query) [1] > 0)
  
    } else
    {
    cat ("\n\nIn selection.not.empty(): selection must be vector or data.frame but is ", 
         class (selection.returned.from.sql.query), ".\n\n")
    stop ()
    }
  
  return (retval)
  }

#-----------------------------------------------------------------------------

insert.new.record.for.offset.test.info.to.db <- function( 
                  table.name, cur.time.step, pu.id, action, 
                         hh.score.used, tot.hh.score, pctg.pu, linked.pu ) 
{ 

  if (DEBUGGING.DBMS) {
    cat( '\nAbout to write data to database' );
  }
  
  connect.to.database( PUinformationDBname );

  
    # build the query it should look something like this
    #     insert into PUstatus (ID AREA) values (77, 456) 
    # with the R variables
    #     insert into PUstatus (ID AREA) values (cur.pu, cur.value)

    #query <- paste( 'insert into ', table.name, ' (TIME_STEP, ', 
    #                                              'ID_PU_DEVELOPED ',   
    #                                              'HH_SCORE_AT_TIME_DEVELOPED ',
    #                                              'ID_PU_OFFSET ',
    #                                              'HH_SCORE_OF_OFFSET_AT_TIME_RESERVED ',
    #                                              'HH_SCORE_OF_TOTAL_OFFSET_PU_AT_TIME_RESERVED ', 
    #                                              ') ', 
    #                 values(', cur.pu, ',', cur.value, ')', sep = '' );
    
    
    if(DEBUG) 
    {  cat( "\n\nAction = ", action, "\n" ); } 
    
    query <- paste( 'insert into ', table.name, ' (TIME_STEP, ', 
                                                  'ID_PU, ',   
                                                  'ACTION, ',
                                                  'HH_SCORE_USED_AT_TIME_OF_ACTION, ',
                                                  'TOTAL_PU_HH_SCORE_AT_TIME_OF_ACTION, ',
                                                  'PERCENTAGE_OF_PU_USED_IN_ACTION, ',
                                                  'ASSOCIATED_DEV_OR_OFFSET_PU ',
                                                  ') ', 
                                          'values(', cur.time.step, ', ',  
                                                     pu.id, ', ',
                                                     '"', action, '"', ', ', 
                                                     hh.score.used, ', ',
                                                     tot.hh.score, ', ',
                                                     pctg.pu, ', ',
                                                     linked.pu,
                                                     ')', 
                                          sep = '' );
    
        if(DEBUG) 
    {  cat( "\n\nQuery = ", query, "\n" ); } 
    
    sql.send.operation( query );
    
 
  close.database.connection();

}

