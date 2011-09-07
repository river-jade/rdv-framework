    #------------------------------------------------------------
    #                dbms.initialise.R                          #
    #                                                           #
    #  Creates the intital database and tables within it that   #
    #  will store information about planning units.             #
    #  any other arbitaty shape                                 #
    #                                                           #
    #  See the file dbms.example.operations.R for examples of   #
    #  reading and writing to the database.                     #
    #                                                           #
    #  Created 2/4/2009 - AG                                    #
    #                                                           #
    #  Added fields related to offsetting - 2009.07.02 - BTL    #
    #  Added fields related to testing offseting - 2009.08.19   #
    #                                               - DWM       #
    #    source('dbms.initialise.R')                            #
    #------------------------------------------------------------



rm( list = ls( all=TRUE ))

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'dbms.functions.R' )      
source( 'variables.R' )      
source( 'stop.execution.R' )
source( 'utility.functions.R' )

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

#  set in python...

    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------


# check if database exists and remove them if they do.
safe.remove.file.if.exists( PUinformationDBname )
safe.remove.file.if.exists( CondDBname )


    #------------------------------------------------------------
    #  Create an empty database file for CondDBname by just opening
    #  and closing a connection.
    #------------------------------------------------------------

connect.to.database( CondDBname )
close.database.connection()

    #------------------------------------------------------------
    #  Create the PU information DB and make the tables and
    #  column headings
    #------------------------------------------------------------


connect.to.database( PUinformationDBname )

# define the column names and types of the table to hold the PU information
table.defn.dynamic <- matrix( c(
                       'ID', 'int',
                       'AREA', 'float', ## WHY IS AREA DYNAMIC? BTL-2009.08.02
                       'COST', 'float',
                       'MANAGED', 'int',                                
                       'MANAGEMENT_COST', 'float',
                       'TIME_MANAGEMENT_COMMENCED', 'int',
                       'RESERVED', 'int',
                       'RESERVE_TYPE', 'int',
                       'TIME_RESERVED', 'int',
                       'RES_EXPIRY_TIME', 'int',
                       'PROB_RES_EXPIRING_PER_TIMESTEP', 'float',
                       'PROB_MAN_EXPIRING_PER_TIMESTEP', 'float',
                       'LANDUSE', 'char(60)',
                       'LANDUSE_CHANGE_TIME', 'int',
                       'DEVELOPED', 'int',
                       'TIME_DEVELOPED', 'int',
                       'IN_DEV_POOL', 'int',
                       'IN_OFFSET_POOL', 'int',
                       'AREA_OF_GRASSLAND', 'float',
                       'TOTAL_COND_SCORE_SUM', 'float',
                       'TOTAL_COND_SCORE_MEAN', 'float',
                       'TOTAL_COND_SCORE_MEDIAN', 'float',
                       'TOTAL_COND_SCORE_SD', 'float',

                       # CPW project variables
                       'TENURE', 'char(60)',
                       'AREA_OF_CPW', 'float',
                       'AREA_OF_C1_CPW', 'float',
                       'AREA_OF_C2_CPW', 'float',
                       'AREA_OF_C3_CPW', 'float',
                       'SCORE_OF_C1_CPW', 'float',
                       'SCORE_OF_C2_CPW', 'float',
                       'SCORE_OF_C3_CPW', 'float',
                       'GROWTH_CENTRE', 'int',
                       'GC_CERT', 'int',
                       'GC_NOTCERT', 'int',
                       'PRIORITY', 'int',
                       'UNDEV_LAND', 'int',
                                
                       # Offsetting variables
                                
                       'NEUTRAL_ASSESSED_TOTAL_HH_SCORE_SUM', 'float', 
                       'OVEREST_ASSESSED_TOTAL_HH_SCORE_SUM', 'float', 
                       'UNDEREST_ASSESSED_TOTAL_HH_SCORE_SUM', 'float', 
                       'DEVELOPER_ASSESSMENT_BIAS', 'float',
                       'SELLER_ASSESSMENT_BIAS', 'float',
                       'LEAKED', 'int',
                       'OFFSET_INTO_PU', 'int',
                       'HH_SCORE_AT_DEV_TIME', 'float',
                       'HH_SCORE_AT_OFFSET_TIME', 'float',
                       'UNUSED_PARTIAL_OFFSET_HH_SCORE', 'float',
                       'AREA_OF_C1_CPW_AT_DEV_TIME', 'float',
                       'AREA_OF_C2_CPW_AT_DEV_TIME', 'float',
                       'AREA_OF_C3_CPW_AT_DEV_TIME', 'float'
 
                       ),
                    byrow = TRUE,
                    ncol = 2 );

table.defn.static <- matrix( c(
                       'ID', 'int',
                       'AREA', 'float',
                       'BOUNDARY_LENGTH', 'float',
                       'EDGE_TO_AREA_RATIO', 'float'
                       ),
                    byrow = TRUE,
                    ncol = 2 );


    #------------------------------------------------------------
    #  Built the sql expression to create the table using SQLite
    #------------------------------------------------------------

sql.create.table.query <-
  build.sql.create.table.expression(dynamicPUinfoTableName,
                                   table.defn.dynamic);
res <- sql.send.operation( sql.create.table.query );

sql.create.table.query <-
  build.sql.create.table.expression(staticPUinfoTableName,
                                   table.defn.static);

res <- sql.send.operation( sql.create.table.query );


# add some dummy data for testing 
#query2d <- 'insert into dynamicPUinfo values(1,34.34, 1,"URBAN", 50, 0.45)';
#sql.send.operation( query2d );

#query2s <- 'insert into staticPUinfo values(1, 4567)';
#sql.send.operation( query2s );


# some other example queries

#query3 <- 'insert into PUstatus values(2,56.456,10234.76, 1,"AG", 50, 0.45)';
#sql.send.operation( query3 );

#query4 <- 'update PUstatus set RESERVED = -1 where ID = 1';
#sql.send.operation( query4 );

    #-----------------------------------------------------------------
    #  Define the column names and types of the table for working
    #  variables used in offsetting.
    #  These are variables that would just be global variables in R or
    #  instance variables in an offsetting object in python.
    #  Since we're mixing python and R and the offsetting model gets
    #  closed down after every time step, these values don't survive
    #  between time steps unless you save them away in a db or pass
    #  them back and forth to python.  The db seems easier for now.
    #-----------------------------------------------------------------

table.defn.offset.working.vars <-
    matrix( c(
              'PARTIAL_OFFSET_IS_ACTIVE_INSIDE_GC', 'int',
              'PARTIAL_OFFSET_PU_ID_INSIDE_GC', 'int',
              'PARTIAL_OFFSET_SUM_SCORE_REMAINING_INSIDE_GC', 'float',
              'PARTIAL_OFFSET_IS_ACTIVE_OUTSIDE_GC', 'int',
              'PARTIAL_OFFSET_PU_ID_OUTSIDE_GC', 'int',
              'PARTIAL_OFFSET_SUM_SCORE_REMAINING_OUTSIDE_GC', 'float',
              'INSIDE_GC_DEV_OVERFLOW_PU_ID', 'int',
              'OUTSIDE_GC_DEV_OVERFLOW_PU_ID', 'int', 
              'CPW_TOT_DEV_INSIDE_GC', 'float',
              'HMV_TOT_DEV_INSIDE_GC', 'float',
              'MMV_TOT_DEV_INSIDE_GC', 'float',
              'LMV_TOT_DEV_INSIDE_GC', 'float',
              'CPW_TOT_DEV_OUTSIDE_GC', 'float',
              'HMV_TOT_DEV_OUTSIDE_GC', 'float',
              'MMV_TOT_DEV_OUTSIDE_GC', 'float',
              'LMV_TOT_DEV_OUTSIDE_GC', 'float'
              ),
           byrow = TRUE,
           ncol = 2 );

sql.create.table.query <-
  build.sql.create.table.expression (offsettingWorkingVarsTableName,
                                     table.defn.offset.working.vars);

res <- sql.send.operation (sql.create.table.query)


    #----------

   #-----------------------------------------------------------------
    #  Define the column names and types of the table for the offset
    #  testing code - this will track HH scores and PU IDs 
    #  to verify that offsetting is working properly 
    #-----------------------------------------------------------------


table.defn.offset.testing.info <-
      matrix( c('TIME_STEP', 'int',
                'ID_PU', 'int',
                'ACTION', 'string',
                'HH_SCORE_USED_AT_TIME_OF_ACTION', 'float' ,
                'TOTAL_PU_HH_SCORE_AT_TIME_OF_ACTION', 'float',
                'PERCENTAGE_OF_PU_USED_IN_ACTION', 'float' ,
                'ASSOCIATED_DEV_OR_OFFSET_PU', 'int'
                ),
             byrow = TRUE,
             ncol = 2 
            );
  
sql.create.table.query <-
  build.sql.create.table.expression (offsettingTestingInfoTableName,
                                     table.defn.offset.testing.info);

res <- sql.send.operation (sql.create.table.query);


    #----------
close.database.connection();
