
# source( 'test.plot.R' )


#rm( list = ls( all=TRUE ));

source( 'dbms.functions.R' )


plot.results <- function() {


  # query the database

  # landscape condtion

  # COND_SUM


  # PU condition
  #pu.query1 <- "select COND_SUM, COND_MEAN, TIME_STEP from PU_COND where ID = 359525629.0;";
  #pu.query2 <- "select COND_SUM, COND_MEAN, TIME_STEP from PU_COND where ID = 358399775.0;";

  #pu.query.result1 <- sql( pu.query1 );
  #pu.query.result2 <- sql( pu.query2 );



  par(mfrow = c(3,2));

  #plot( pu.query.result1$TIME_STEP, pu.query.result1$COND_SUM );
  #plot( pu.query.result1$TIME_STEP, pu.query.result1$COND_MEAN );

  #plot( pu.query.result2$TIME_STEP, pu.query.result2$COND_SUM );
  #plot( pu.query.result2$TIME_STEP, pu.query.result2$COND_MEAN );


  # landscape condition


  land.query1 <- "select TIME_STEP,
                       TOTAL_COND_SCORE_SUM,
                       TOTAL_COND_SCORE_MEAN,
                       RESERVED_COND_SCORE_SUM,
                       UNRESERVED_COND_SCORE_SUM,
                       RESERVED_COND_SCORE_MEAN,
                       UNRESERVED_COND_SCORE_MEAN
                from LANDSCAPE_COND";
  
  land.query1.result <- sql( land.query1 );

  #ylim.tot <- c(0, max(land.query1.result$TOTAL_COND_SCORE_SUM) );

  ylim.tot <- c(0, 14547608 );
  ylim.tot <- c(0, 10547608 );
  x.lim <- c(0,100)
  
  #ylim.mean <- c(0, max(land.query1.result$RESERVED_COND_SCORE_MEAN) );
  ylim.mean <- c(0, 58 );

  plot( land.query1.result$TIME_STEP, land.query1.result$TOTAL_COND_SCORE_SUM, type = 'l', ylab = 'TOTAL_COND_SUM', ylim = ylim.tot, xlim = x.lim, main =scen.descriptor[scen,2] )


  plot( land.query1.result$TIME_STEP, land.query1.result$TOTAL_COND_SCORE_MEAN, type = 'l' , ylab = 'TOTAL_COND_MEAN', ylim = ylim.mean, xlim = x.lim )

  plot( land.query1.result$TIME_STEP, land.query1.result$RESERVED_COND_SCORE_SUM , type = 'l', ylab = 'RESERVED_COND_SUM', ylim = ylim.tot, xlim = x.lim )

  plot( land.query1.result$TIME_STEP, land.query1.result$RESERVED_COND_SCORE_MEAN , type = 'l', ylab = 'RESERVED_COND__MEAN', ylim = ylim.mean, xlim = x.lim )

  plot( land.query1.result$TIME_STEP, land.query1.result$UNRESERVED_COND_SCORE_SUM, type = 'l', ylab = 'UNRESERVED_COND_SUM', ylim = ylim.tot, xlim = x.lim )


  plot( land.query1.result$TIME_STEP, land.query1.result$UNRESERVED_COND_SCORE_MEAN , type = 'l', ylab = 'UNRESERVED_COND_MEAN', ylim = ylim.mean, xlim = x.lim)


}



#============================================================================

globaDBdriver <<- "SQLite"
PUcondTableName <- "PU_COND";
LandscapeCondTableName <- "LANDSCAPE_COND";


scen.descriptor <- matrix(
                     c(1, '1: Realistic    (Z, offset) (loss) (Opt cond)',
                       2, '2: Realistic    (Z, offset) (loss) (Pes cond)',
                       3, '3: No offset    (Z,       ) (loss) (Opt cond)',
                       4, '4: No offset    (Z,       ) (loss) (Pes cond)',
                       5, '5: Do nothing   (         ) (    ) (Opt cond)',
                       6, '6: Do nothing   (         ) (    ) (Pes cond)',
                       7, '7: All reserved (Z        ) (    ) (Opt cond)',
                       8, '8: All reserved (Z        ) (    ) (Pes cond)'
                       ),
                      ncol = 2, byrow=TRUE );
                          


#==============================================================================
CondDBbname <<- "results/evalCondition.8.dbms"

#for( scen in 1:8 ){
for( scen in c(1) ) {


  CondDBbname <<- paste( 'results/evalCondition.', scen, '.dbms', sep ='' );

  connect.to.database( CondDBbname );


  plot.results();
  
  close.database.connection();


}

#==============================================================================


