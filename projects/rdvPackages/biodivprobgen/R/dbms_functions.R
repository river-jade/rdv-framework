#===============================================================================

                    #  source ("dbms_initialize.R")

#  Functions for setting up and writing data to a database.
#  Currenty set up for using with SQLite, but shouldn't have
#  change much if we swap to another DBMS.

#===============================================================================

#  History:

#  2014 12 10 - BTL
#  Cloned from dbms.functions.R /Users/bill/D/rdv-framework/R/dbms.functions.R
#  That file:
#       Created Dec 9, 2008 - Ascelin Gordon
#       to run   (from runall directry)

#===============================================================================

    #  From /Users/bill/D/rdv-framework/R/utility.functions.R

safe.remove.file.if.exists = function (filename) 
    {
    if (file.exists (filename)) 
        {
        if (!file.remove (filename)) 
            {
            cat ('\nError: could not delete existing file:',
                 filename, '\n')
            stop.execution ();
            }
        }
    }

#===============================================================================

    #  Check if database exists and remove them if they do.
    #  From /Users/bill/D/rdv-framework/R/utility.functions.R

#safe.remove.file.if.exists (db_name)

#     C02NL166G3QP:rdv-framework bill$ grep -inr globalDBdriver .
#     ./analysis/.svn/text-base/dbms.functions.r.svn-base:34:                              dbDriver (globalDBdriver),
#     ./analysis/.svn/text-base/dbms.functions.variables.R.svn-base:1:globalDBdriver <<- 'SQLite';
#     ./analysis/dbms.functions.r:34:                              dbDriver (globalDBdriver),
#     ./analysis/dbms.functions.variables.R:1:globalDBdriver <<- 'SQLite';
#     ./projects/.svn/text-base/globalparams.yaml.svn-base:89:    globalDBdriver: SQLite

globalDBdriver <<- "SQLite"

#===============================================================================

library (RSQLite)

#source ('variables.R')

DEBUGGING_DBMS = FALSE;

#===============================================================================
#       Functions to connect to and disconnect from database
#===============================================================================

    # Connect to the database

connect_to_database = function (db_name)
    {
    globalSQLcon <<- dbConnect (
                                dbDriver (globalDBdriver),
                                dbname = db_name
                               )
    if (DEBUGGING_DBMS)
        cat ('\nDBMS> Successfully opened connection to DB', 
             db_name, '\n');
    }

#-----------------------------------------------------------------------------

close_database_connection = function () 
    {
    if (exists ("globalSQLcon")) 
        { 
        try (dbDisconnect (globalSQLcon)) 
        }

    if (DEBUGGING_DBMS)
        cat ('\nDBMS> Closed DB connection\n');
    }

#===============================================================================
#               Functions to write data to file 
#===============================================================================

write_data_to_db = function (table_name, data_to_write) 
    {
        #  if data is not in a data frame then convert to be one
    if (!is.data.frame (data_to_write)) 
        {
        data_to_write = data_frame (data_to_write);
        }

    dbWriteTable (globalSQLcon, table_name, data_to_write, 
                  append = TRUE)

    if (DEBUGGING_DBMS)
        cat ('\nDBMS> wrote data to table', table_name);
    }

#-----------------------------------------------------------------------------

write_data_frame_to_new_DB = function (c_dataframe, 
                                       c_new_DB_name, 
                                       c_table_name) 
    {
    connect_to_database (c_new_DB_name)
    write_data_to_db (c_table_name, c_dataframe)
    close_database_connection ()
    }

#-----------------------------------------------------------------------------

write_data_to_textfile = function (filename, data_to_write) 
    {
    cat (data_to_write, '\n', file = filename, append = TRUE );
    }

#===============================================================================
#                   Functions to retrieve data
#===============================================================================

    # Retrieve the data    
    # Use a single database connection, so I do not have to
    # give the connection argument each time.

sql_get_data = function (dbname, query) 
    {
    connect_to_database (dbname)
    res = dbGetQuery (globalSQLcon, query)
  
        #  When the result has a single column, convert to a vector 
        #  (as default is to return a data.frame).
  
    if (!is.null (res)) 
        {  
        if (is.data.frame (res) & ncol (res) == 1) 
            { res = res [,1] }
        }
  
  drop (res)

        #  if there was no data selected from the database 
        #  return integer (0)

  if (length (res) == 0) { res = integer (0) }
  
  close_database_connection ();
  
  # add line
  return (res)
}

#-----------------------------------------------------------------------------

    # single line version  - useful for offset testing code. 
    # Added by Daniel 10 Aug 2009

sql = function (query) 
    {  
    res = dbGetQuery (globalSQLcon, query)
  
        # When the result has a single column, convert to a vector 
        # (as default is to return a data.frame.
  
    if (!is.null (res)) 
        {  
        if (is.data.frame (res) & ncol (res) == 1) 
            { res = res[,1] }
        }
  
    drop (res)

        # if there was no data selected from the database return integer (0)

    if (length (res) == 0) { res = integer (0) }
    
        #  add line
    return (res)
    }

#-----------------------------------------------------------------------------

sql_send_operation = function (query) 
    {
    #cat ('\nDBMS>sending query:', query); 
    res = dbSendQuery (globalSQLcon, query)

        # Not sure why this is here and it was causing error messages, so
        # I'm commenting it out for now. AG - 29 Nov 2010
  
    dbClearResult (res); 
  
        # Commenting this line otherwise the return value is printed if it's
        # not caught when this function is called

    #return (res)
    }

#===============================================================================
#  Misc functions (not sure whether these are specific to old rdv code)
#===============================================================================

build_sql_create_table_expression = function (table_name, table_defn) 
    {
    cols_expression = '';
    
    for (ctr in 1:dim (table_defn)[1]) 
        {    
        cols_expression = paste (cols_expression, 
                                 table_defn[ctr,1],
                                 table_defn[ctr,2]);
        
            # add a ',' if not on the last entry
        if (ctr != dim (table_defn)[1]) 
            {
            cols_expression = paste (cols_expression, ',', sep = '');
            }
        }
    
    sql_full_query = paste ('create table ', table_name, 
                            '(', cols_expression, ')',
                            sep = '');
    
    return (sql_full_query);
    }

#-----------------------------------------------------------------------------

selection_not_empty = function (selection_returned_from_sql_query)
    {
    retval = FALSE
    
    if (length (selection_returned_from_sql_query) < 1)
        {
        retval = FALSE
        
        } else if (is.vector (selection_returned_from_sql_query))
        {
        retval = (length (vector) > 0)
        
        } else if (is.data.frame (selection_returned_from_sql_query))
        {
        retval = (dim (selection_returned_from_sql_query) [1] > 0)
        
        } else
        {
        cat ("\n\nIn selection_not_empty(): selection must be vector or data.frame but is ", 
             class (selection_returned_from_sql_query), ".\n\n")
        stop ()
        }
  
  return (retval)
  }

#===============================================================================
#           Functions specific to very old rdv code
#===============================================================================

insert_pu_ids_to_db = function (table_name, pu_id_vec, val_name) 
    {
    if (DEBUGGING_DBMS)  
        cat ('\nAbout to write data to database')
  
    connect_to_database (PUinformationDBname)

    pu_ctr = 0;
    for (cur_pu in pu_id_vec) 
        {
        pu_ctr = pu_ctr + 1
    
        query = paste ('insert into ', table_name, 
                       ' (', val_name, ') values (', 
                       cur_pu, ')', sep = '')
    
        sql_send_operation (query);
        }
  
    close_database_connection ();
    }

#-----------------------------------------------------------------------------

insert_pu_id_and_value_to_db = function (table_name, 
                                         pu_ids_and_values_matrix,
                                         val_name) 
    {
    if (DEBUGGING_DBMS)
        cat ('\nAbout to write data to database')
  
    connect_to_database (PUinformationDBname)

    pu_id_vec = pu_ids_and_values_matrix[,1]
    
    pu_ctr = 0;
    for (cur_pu in pu_id_vec) 
        {
        pu_ctr = pu_ctr + 1
        
        cur_value = pu_ids_and_values_matrix[pu_ctr,2]

            # build the query it should look something like this
            #     insert into PUstatus (ID AREA) values (77, 456) 
            # with the R variables
            #     insert into PUstatus (ID AREA) values (cur_pu, cur_value)

        query = paste ('insert into ', table_name, 
                       ' (ID,', val_name,') values (',
                       cur_pu, ',', cur_value, ')', sep = '')
    
        sql_send_operation (query)        
        }
    
    close_database_connection ()
    }

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------

update_single_db_pu_with_single_value = 
                    function (table_name, pu_id, value, db_col_name)
    {
    if (DEBUGGING_DBMS)
        cat ("\nAbout to update database for single PU with single value.");
  
    connect_to_database (PUinformationDBname)

        #-----------------------------------------------------
        #  Build the query. It should look something like this
        #      update PUstatus set COST = 345 where ID = 1';
        #-----------------------------------------------------  

    query = paste ('update ', table_name, ' set ', db_col_name, ' = ',
                 value, ' where ID = ', pu_id, sep = '')
    
    sql_send_operation (query)
    
    close_database_connection ()
    }

#-----------------------------------------------------------------------------

update_db_all_pu_ids_with_single_value = function (table_name, 
                                                   value,
                                                   db_col_name) 
    {
    connect_to_database (PUinformationDBname);    
    query = paste ('update ', table_name, 
                   ' set ', db_col_name, ' = ',
                   value, sep = '');    
    sql_send_operation (query);
    close_database_connection ();
    }

#-----------------------------------------------------------------------------

    # This function is for updating multiple entries in the same column of
    # a single table. It's a little convoluted but is FAST (1 second
    # compared to 2 minutes when using a loop). Instead of updating the
    # table through database calls within a loop, the whole table in
    # question is read into a R data frame, then the column in the data
    # frame is updated, the original table is deleted in the data base,
    # then the updated data frame is then written to the data base.

update_column_in_db_table_via_dataframe = function (table_name, 
                                                    col_name, 
                                                    new_values) 
    {
    connect_to_database (PUinformationDBname)
    
        # First read the database into a data.frame
    db_data_frame = dbReadTable (globalSQLcon, table_name)
    
        # Save the values to be overwritten that are currently in the data base
    old_vales = db_data_frame[,col_name]
    
        # Update the data.frame with the new values
    
        # First check that the new values are the same length as the
        # dataframe and stop if this is not the case
    stopifnot (length (db_data_frame[,col_name]) == length (new_values))
    
    db_data_frame[,col_name] = new_values
    
        # Remove the old table from the database (it'll be recreated when we
        # dump the new data.frame to the database

    query = paste ("DROP TABLE", dynamicPUinfoTableName)
    sql_res = dbSendQuery (globalSQLcon, query)
    res = dbClearResult (sql_res)
    
        # Write the new dataframe to the database
    res = dbWriteTable (globalSQLcon, table_name, db_data_frame)
    
    close_database_connection ()
    }

#-----------------------------------------------------------------------------

update_db_pu_ids_with_single_value = function (table_name, 
                                               pu_id_vec, 
                                               value,
                                               db_col_name) 
    {
        # make a table containing PU Ids with the value to be updated
    pu_ids_and_single_value = cbind (pu_id_vec, value);
    
        # update multiple planning units with multiple different values
    if (DEBUGGING_DBMS)
        cat ('\nAbout to write data to database');
    
    connect_to_database (PUinformationDBname);
    
    pu_ctr = 0;
    for (cur_pu in pu_id_vec) 
        {
        pu_ctr = pu_ctr + 1;
        
        cur_val = pu_ids_and_single_value[pu_ctr,2];
        #cur_val = round (cur_val, 5);
        
        if (is.na (cur_val)) 
            {
                # if there is a NA then turn it onto a zero
                # an NA can occure for PUs of 1 pixel when trying
                # to take the sd of the condition of all pixles in the PU
            cur_val = 0;
            }
        
        if (is.numeric (cur_val)) 
            {
                # if it's a number round it off to 5 places to save space
            cur_val = round (cur_val, 5);      
            }
        
                # build the query. It should look something like this
                #     update PUstatus set COST  = 345 where ID = 1';        
        query = paste ('update ', table_name, 
                       ' set ', db_col_name, ' = ',
                       cur_val, ' where ID = ', 
                       cur_pu, sep = '');        
        sql_send_operation (query);
        }
    
    close_database_connection ();
    }

#-----------------------------------------------------------------------------

#update_pu_id_and_value_to_db

update_db_pu_ids_with_multiple_values = function (table_name,
                                                  pu_ids_and_values_matrix,
                                                  val_name) 
    {
        # update multiple planning units with multiple different values
    if (DEBUGGING_DBMS)  
        cat ('\nAbout to write data to database');
    
    connect_to_database (PUinformationDBname);
    
    pu_id_vec = pu_ids_and_values_matrix[,1];
    
    pu_ctr = 0;
    for (cur_pu in pu_id_vec) 
        {
        pu_ctr = pu_ctr + 1;
        
        cur_val = pu_ids_and_values_matrix[pu_ctr,2];
        
        if (is.na (cur_val)) 
            {
                # if there is a NA then turn it onto a zero
                # an NA can occure for PUs of 1 pixel when trying
                # to take the sd of the condition of all pixles in the PU
            cur_val = 0;
            }
        
        if (is.numeric (cur_val)) 
            {
                # if it's a number round it off to 5 places to save space
            cur_val = round (cur_val, 5);            
            }
        
        
            # build the query it should look something like this
            #     update PUstatus set COST  = 345 where ID = 1';        
        query = paste ('update ', table_name ,
                       ' set ', val_name, ' = ', cur_val,
                       ' where ID = ', cur_pu, sep = '');
        
        sql_send_operation (query);
        }
    
    close_database_connection ();
    }

#-----------------------------------------------------------------------------

get_field_value_of_pu = function (PU_ID, field_name)
    {
    query = paste ('select ', field_name, 
                   ' from ', dynamicPUinfoTableName,
                   'where ID = ', PU_ID)
    
    return (sql_get_data (PUinformationDBname, query))
    }

#-----------------------------------------------------------------------------

insert_new_record_for_offset_test_info_to_db = 
        function (table_name, cur_time_step, pu_id, action, 
                  hh_score_used, tot_hh_score, pctg_pu, linked_pu) 
    { 
    if (DEBUGGING_DBMS)  cat ('\nAbout to write data to database')
  
    connect_to_database (PUinformationDBname)
  
        # build the query it should look something like this
        #     insert into PUstatus (ID AREA) values (77, 456) 
        # with the R variables
        #     insert into PUstatus (ID AREA) values (cur_pu, cur_value)
        
        #query = paste('insert into ', table_name, ' (TIME_STEP, ', 
        #                                              'ID_PU_DEVELOPED ',   
        #                                              'HH_SCORE_AT_TIME_DEVELOPED ',
        #                                              'ID_PU_OFFSET ',
        #                                              'HH_SCORE_OF_OFFSET_AT_TIME_RESERVED ',
        #                                              'HH_SCORE_OF_TOTAL_OFFSET_PU_AT_TIME_RESERVED ', 
        #                                              ') ', 
        #                 values(', cur_pu, ',', cur_value, ')', sep = '');
        
    if (DEBUG)  cat ("\n\nAction = ", action, "\n")
    
    query = paste ('insert into ', table_name, 
                   ' (TIME_STEP, ', 
                        'ID_PU, ',   
                        'ACTION, ',
                        'HH_SCORE_USED_AT_TIME_OF_ACTION, ',
                        'TOTAL_PU_HH_SCORE_AT_TIME_OF_ACTION, ',
                        'PERCENTAGE_OF_PU_USED_IN_ACTION, ',
                        'ASSOCIATED_DEV_OR_OFFSET_PU ',
                        ') ', 
                    'values(', cur_time_step, ', ',  
                        pu_id, ', ',
                        '"', action, '"', ', ', 
                        hh_score_used, ', ',
                        tot_hh_score, ', ',
                        pctg_pu, ', ',
                        linked_pu,
                        ')', 
                    sep = '')
    
    if (DEBUG)  cat ("\n\nQuery = ", query, "\n") 
    
    sql_send_operation (query)

    close_database_connection ()
    }

#===============================================================================


