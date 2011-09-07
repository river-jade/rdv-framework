rm( list = ls( all=TRUE ));

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'dbms.functions.R' )      


    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

#  set in python...

PUinformationDBname <- 'PUinformation19.dbms';

    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------


connect.to.database( PUinformationDBname );


query <- 'create table PUstatus( ID int, COST float, AREA float, RESERVED char(60), LANDUSE int, RES_EXPIRY_TIME int, PROB_RES_EXPIRING_PER_TIMESTEP float)';

sql.send.operation( query );

query2 <- 'insert into PUstatus values(1,34.34,1000.2, 1,"URBAN", 50, 0.45)';
sql.send.operation( query2 );

query3 <- 'insert into PUstatus values(2,56.456,10234.76, 1,"AG", 50, 0.45)';
sql.send.operation( query3 );



query4 <- 'update PUstatus set RESERVED = -1 where ID = 1';
sql.send.operation( query4 );


close.database.connection();
