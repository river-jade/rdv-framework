#===============================================================================

                        #  gscp_7_set_up_dbms.R

#===============================================================================
#  Start adding dbms code to replace data frames.
#  Most of this part is cloned from dbms.initialise.melb.grassland.R
#===============================================================================

source ("/Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/dbms_functions.R")

db_name = "test.db"

    #------------------------------------------------------------
    #  Check whether database exists and remove it if it does.
    #------------------------------------------------------------

safe.remove.file.if.exists (db_name)

    #------------------------------------------------------------
    #  Create the DB and make the tables and
    #  column headings
    #------------------------------------------------------------

connect_to_database (db_name)

# db_driver <- dbDriver("SQLite")
# db_con <- dbConnect (db_driver, db_name)

    #------------------------------------------------------------
    #  Define the column names and types of the table 
    #------------------------------------------------------------

node_table_defn = 
    matrix (c ('ID', 'int',
               'GROUP_ID', 'int', 
               'DEPENDENT_SET_MEMBER', 'int'
               ),
            byrow = TRUE,
            ncol = 2 )

link_table_defn = 
    matrix (c ('ID', 'int',
               'NODE_1', 'int',
               'NODE_2', 'int', 
               'LINK_DIRECTION', 'string'    #  "UN", "BI", "FT", "TF"
               ),
            byrow = TRUE,
            ncol = 2 )

    #------------------------------------------------------------
    #  Build the sql expression to create the table using SQLite
    #------------------------------------------------------------

node_table_name = "nodes"
sql_create_table_query = 
  build_sql_create_table_expression (node_table_name,
                                     node_table_defn)
sql_send_operation (sql_create_table_query)

link_table_name = "links"
sql_create_table_query = 
  build_sql_create_table_expression (link_table_name,
                                     node_table_defn)
sql_send_operation (sql_create_table_query)


    #  add some dummy data for testing 
testSqlCmd <- paste0 ('insert into ', node_table_name, 
                     ' values (1, 0, 1)')
sql_send_operation (testSqlCmd)

#query2s <- 'insert into staticPUinfo values(1, 4567)';
#sql.send.operation( query2s );
testSqlCmd <- paste0 ('insert into ', link_table_name, 
                     ' values (1, 2, "un")')
sql_send_operation (testSqlCmd)


# some other example queries

#query4 <- 'update PUstatus set RESERVED = -1 where ID = 1';
#sql.send.operation( query4 );

    #----------

close_database_connection()

#===============================================================================

