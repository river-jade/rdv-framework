## A  routine to test bill's offsetting code

# source( "test.offset.code.R" )

rm( list = ls( all=TRUE ))

source( 'dbms.functions.R' )
source( "test.offset.code.functions.R" )

#at each timestep, for each PU
#- score when developed
#- score of offset PU
#are these equal or offset greater?

# loop through the timesteps
# at each ts extract the data

plot.offset.results <- function( dbname ) {
  
  cat( '\n=========================================================================\n',
      '\n= Testing Offsetting using db:', dbname )
  
  connect.to.database( dbname )
  time.steps <- sort(unique( as.integer( sql( "select TIME_RESERVED from dynamicPUinfo" ) ) ) )
  close.database.connection()

  # skip the first time step and the -999 values for which are set for parcels that were never reserved
  time.steps <- time.steps[ which(time.steps > 0 ) ]

  if( length(time.steps) == 0 ) {
    cat( "\nWarning: Nothing has been reserved after time step zero generating offset results\n\n")
    return()
  }

  # Both inside and out outside Growth Centers
  #results <- generate.offset.stats( dbname, time.steps )
  #make.offset.plots( dbname, results, time.steps )
  
  # Only inside and out outside Growth Centers
  cat( '\n Developments and offsets inside the GCs' )
  extra.query.terms <- 'and GROWTH_CENTRE = 1'

  dev.IN.offset.IN.criteria <- paste (' DEVELOPED = 0 ',
                                    ' and RESERVED = 0 ',
                                    ' and TENURE = "Unprotected"',                    
                                    ' and GROWTH_CENTRE = 1',
                                    ' and GC_NOTCERT = 1',
                                    ' and UNDEV_LAND = 0',  
                                    ' and AREA_OF_CPW > 0 '
                                    )  

  results <- generate.offset.stats( dbname, time.steps, extra.query.terms, dev.IN.offset.IN.criteria )
  
  # Only outside and out outside Growth Centers
  cat( '\n-----------------------------------------' )
  cat( '\n Developments and offsets outside the GCs' )
  extra.query.terms <- 'and GROWTH_CENTRE = 0'
  results <- generate.offset.stats( dbname, time.steps, extra.query.terms, dev.IN.offset.IN.criteria )
  
 
  

}

#------------------------------------------------------------------------------------------------------------


plot.development.results <- function( dbname ) {
  
  cat( '\n=========================================================================\n',
      '\n= Testing Development model using db:', dbname )
 
  connect.to.database(dbname )
  
  # get the number of time steps
  # todo(Ascelin): Make this a function as it's called above
  time.steps <- sort(unique( as.integer( sql( "select TIME_DEVELOPED from dynamicPUinfo" ) ) ) )
  # skip the first time step and the -999 values for which are set for parcels that were never reserved
  time.steps <- time.steps[ which(time.steps > 0 ) ]
  step.interval <- time.steps[2] - time.steps[1]
  


  # Make a dataframe to store the results
  f <- rep( -1, length(time.steps) )
  results <- data.frame( cur.dev.inside.gc=f,               # 1
                         cur.dev.outside.gc=f,              # 2
                        
                         running.tot.dev.inside.gc=f,       # 3
                         running.tot.dev.outside.gc=f,      # 4
                         running.tot.C1.dev.inside.gc=f,    # 5 
                         running.tot.C2.dev.inside.gc=f,    # 6
                         running.tot.C3.dev.inside.gc=f,    # 7
                        
                         running.tot.offset.inside.gc=f,    # 8
                         running.tot.offset.outside.gc=f,   # 9

                         running.tot.C1.offset.inside.gc=f, # 10
                         running.tot.C2.offset.inside.gc=f, # 11
                         running.tot.C3.offset.inside.gc=f, # 12
   
                         running.tot.C1.offset.outside.gc=f, # 13
                         running.tot.C2.offset.outside.gc=f, # 14
                         running.tot.C3.offset.outside.gc=f, # 15

                         rem.tot.devble.CPW.in.GC=f,               # 16
                         rem.tot.devble.CPW.out.GC=f,               # 16
                         rem.devble.C1.CPW.in.CG=f,                # 17
                         rem.devble.C2.CPW.in.CG=f,                # 18
                         rem.devble.C3.CPW.in.CG=f,                # 19
                         rem.devble.C1.CPW.out.CG=f,               # 20
                         rem.devble.C2.CPW.out.CG=f,               # 21
                         rem.devble.C3.CPW.out.CG=f                # 22
                        )

  running.tot.dev.outside.gc <- 0
  running.tot.dev.inside.gc  <- 0

  running.tot.C1.dev.inside.gc <- 0
  running.tot.C2.dev.inside.gc <- 0
  running.tot.C3.dev.inside.gc <- 0
  
  running.tot.C1.outside.gc <- 0
  running.tot.C2.outside.gc <- 0
  running.tot.C3.outside.gc <- 0

  #
  
  running.tot.offset.outside.gc <- 0
  running.tot.offset.inside.gc  <- 0

  running.tot.C1.offset.inside.gc <- 0
  running.tot.C2.offset.inside.gc <- 0
  running.tot.C3.offset.inside.gc <- 0
  
  running.tot.C1.offset.outside.gc <- 0
  running.tot.C2.offset.outside.gc <- 0
  running.tot.C3.offset.outside.gc <- 0

  ctr <- 0

  for( cur.time in time.steps ) {
    ctr <- ctr + 1
    
    cat( '\nTime step = ', cur.time );


    # Calc the total CPW developed inside and outside the GCs
    query.inside.gc <- paste( "select HH_SCORE_AT_DEV_TIME from dynamicPUinfo where TIME_DEVELOPED =",
                       cur.time, 'and GROWTH_CENTRE = 1' )
    query.outside.gc <- paste( "select HH_SCORE_AT_DEV_TIME from dynamicPUinfo where TIME_DEVELOPED =",
                       cur.time, 'and GROWTH_CENTRE = 0' )

    cur.dev.inside.gc <-  sql( query.inside.gc )
    cur.dev.outside.gc <-  sql( query.outside.gc )

    running.tot.dev.inside.gc <- running.tot.dev.inside.gc + sum( cur.dev.inside.gc )
    running.tot.dev.outside.gc <- running.tot.dev.outside.gc + sum( cur.dev.outside.gc )

    

    # Calculate the area developed of each category of CPW
    query.CX.CPW.inside.GC  <- paste( "select AREA_OF_C1_CPW_AT_DEV_TIME, AREA_OF_C2_CPW_AT_DEV_TIME,",
                                     "AREA_OF_C3_CPW_AT_DEV_TIME from dynamicPUinfo",
                                     "where TIME_DEVELOPED =", cur.time, 'and GROWTH_CENTRE = 1' )
    
    query.CX.CPW.outside.GC  <- paste( "select AREA_OF_C1_CPW_AT_DEV_TIME, AREA_OF_C2_CPW_AT_DEV_TIME,",
                                     "AREA_OF_C3_CPW_AT_DEV_TIME from dynamicPUinfo",
                                      "where TIME_DEVELOPED =",
                                      cur.time, 'and GROWTH_CENTRE = 0' )
    
    CX.in.GC <-  sql( query.CX.CPW.inside.GC )
    CX.out.GC <-  sql( query.CX.CPW.outside.GC )

    running.tot.C1.dev.inside.gc <- running.tot.C1.dev.inside.gc+sum(CX.in.GC$AREA_OF_C1_CPW_AT_DEV_TIME)
    running.tot.C2.dev.inside.gc <- running.tot.C2.dev.inside.gc+sum(CX.in.GC$AREA_OF_C2_CPW_AT_DEV_TIME)
    running.tot.C3.dev.inside.gc <- running.tot.C3.dev.inside.gc+sum(CX.in.GC$AREA_OF_C3_CPW_AT_DEV_TIME)
  
    running.tot.C1.outside.gc <- running.tot.C1.outside.gc+sum(CX.out.GC$AREA_OF_C1_CPW_AT_DEV_TIME)
    running.tot.C2.outside.gc <- running.tot.C2.outside.gc+sum(CX.out.GC$AREA_OF_C2_CPW_AT_DEV_TIME)
    running.tot.C3.outside.gc <- running.tot.C3.outside.gc+sum(CX.out.GC$AREA_OF_C3_CPW_AT_DEV_TIME)

    
    # Calculate the area offset of each category of CPW
    query.CX.CPW.offset.inside.GC  <- paste( "select AREA_OF_CPW, AREA_OF_C1_CPW, AREA_OF_C2_CPW,",
                                     "AREA_OF_C3_CPW from dynamicPUinfo",
                                     "where TIME_RESERVED =", cur.time, 'and GROWTH_CENTRE = 1' )
    
    query.CX.CPW.offset.outside.GC  <- paste( "select AREA_OF_CPW, AREA_OF_C1_CPW, AREA_OF_C2_CPW,",
                                     "AREA_OF_C3_CPW from dynamicPUinfo",
                                      "where TIME_RESERVED =",
                                      cur.time, 'and GROWTH_CENTRE = 0' )
    
    CX.offset.in.GC <-  sql( query.CX.CPW.offset.inside.GC )
    CX.offset.out.GC <-  sql( query.CX.CPW.offset.outside.GC )
    
    running.tot.offset.inside.gc <- running.tot.offset.inside.gc+sum(CX.offset.in.GC$AREA_OF_CPW)
    running.tot.offset.outside.gc <- running.tot.offset.outside.gc+sum(CX.offset.out.GC$AREA_OF_CPW)

    running.tot.C1.offset.inside.gc <- running.tot.C1.offset.inside.gc+sum(CX.offset.in.GC$AREA_OF_C1_CPW)
    running.tot.C2.offset.inside.gc <- running.tot.C2.offset.inside.gc+sum(CX.offset.in.GC$AREA_OF_C2_CPW)
    running.tot.C3.offset.inside.gc <- running.tot.C3.offset.inside.gc+sum(CX.offset.in.GC$AREA_OF_C3_CPW)
  
    running.tot.C1.offset.outside.gc <- running.tot.C1.offset.outside.gc+sum(CX.offset.out.GC$AREA_OF_C1)
    running.tot.C2.offset.outside.gc <- running.tot.C2.offset.outside.gc+sum(CX.offset.out.GC$AREA_OF_C2)
    running.tot.C3.offset.outside.gc <- running.tot.C3.offset.outside.gc+sum(CX.offset.out.GC$AREA_OF_C3)


    # Print the resuts to screen
    
    cat( '\n INSIDE GC :', length( cur.dev.inside.gc ), ' parcels', 
        '; Curr area of CPW  = ',  round(sum(cur.dev.inside.gc)),
        ' Cum. All CPW:',  round(running.tot.dev.inside.gc),
        ' [C1:', round(running.tot.C1.dev.inside.gc,1),
        '; C2: ', round(running.tot.C2.dev.inside.gc,1),
        '; C3: ', round(running.tot.C3.dev.inside.gc,1), ']', sep=''
        )
    
    cat( '\n OUTSIDE GC:', length( cur.dev.outside.gc ), ' parcels', 
        ' Cur score CPW  = ', round(sum(cur.dev.outside.gc),1),
        ' Cum. All CPW:', round(running.tot.dev.outside.gc,1),
        ' [C1:', round(running.tot.C1.outside.gc,1),
        '; C2:', round(running.tot.C2.outside.gc,1),
        '; C3:', round(running.tot.C3.outside.gc,1), ']', sep=''
        )
    
    cat('\n')
  
    if( length(cur.dev.inside.gc) == 0 ) results[ctr,1] <- 0
    else results[ctr,1] <- sum(cur.dev.inside.gc)
    
    if( length(cur.dev.outside.gc) == 0 )  results[ctr,2] <- 0
    else results[ctr,2] <- sum(cur.dev.outside.gc)

    # Store the cumulative dev inside GC
    results[ctr,3] <- running.tot.dev.inside.gc
    
    # Store the cumulative dev outside GC
    results[ctr,4] <- running.tot.dev.outside.gc

    # Store the cumulative C1 CPW dev inside the GC
    results[ctr,5] <- running.tot.C1.dev.inside.gc
    results[ctr,6] <- running.tot.C2.dev.inside.gc
    results[ctr,7] <- running.tot.C3.dev.inside.gc

    # Store the CPW offset in each category
    results[ctr, 'running.tot.offset.inside.gc'] <- running.tot.offset.inside.gc
    results[ctr, 'running.tot.offset.outside.gc'] <- running.tot.offset.outside.gc
    
    results[ctr, 'running.tot.C1.offset.inside.gc'] <- running.tot.C1.offset.inside.gc
    results[ctr, 'running.tot.C2.offset.inside.gc'] <- running.tot.C2.offset.inside.gc
    results[ctr, 'running.tot.C3.offset.inside.gc'] <- running.tot.C3.offset.inside.gc
    
    results[ctr, 'running.tot.C1.offset.outside.gc'] <- running.tot.C1.offset.outside.gc
    results[ctr, 'running.tot.C2.offset.outside.gc'] <- running.tot.C2.offset.outside.gc
    results[ctr, 'running.tot.C3.offset.outside.gc'] <- running.tot.C3.offset.outside.gc

    results[ctr, 'rem.tot.devble.CPW.in.GC'] <- round(
      init.devble.CPW.in.GC.df$area.all.CPW - running.tot.dev.inside.gc, 2)

    results[ctr, 'rem.tot.devble.CPW.out.GC'] <- round(
      init.devble.CPW.out.GC.df$area.all.CPW - running.tot.dev.outside.gc, 2)

    cat( '   rem.tot.devble.CPW.in.GC =', results[ctr, 'rem.tot.devble.CPW.in.GC'], '\n\n'  )
    
    # Store the remaining CPW in each category
    results[ctr, 'rem.devble.C1.CPW.in.CG'] <- round(
      init.devble.CPW.in.GC.df$area.C1.CWP - running.tot.C1.dev.inside.gc - running.tot.C1.offset.inside.gc, 2)

    results[ctr, 'rem.devble.C2.CPW.in.CG'] <- round(
      init.devble.CPW.in.GC.df$area.C2.CWP - running.tot.C2.dev.inside.gc - running.tot.C2.offset.inside.gc, 2)

    results[ctr, 'rem.devble.C3.CPW.in.CG'] <- round(
      init.devble.CPW.in.GC.df$area.C3.CWP - running.tot.C3.dev.inside.gc - running.tot.C3.offset.inside.gc, 2)

    results[ctr, 'rem.devble.C1.CPW.out.CG'] <- round(
      init.devble.CPW.out.GC.df$area.C1.CWP - running.tot.C1.outside.gc, 2)
    
    results[ctr, 'rem.devble.C2.CPW.out.CG'] <- round(
      init.devble.CPW.out.GC.df$area.C2.CWP - running.tot.C2.outside.gc, 2)
    
    results[ctr, 'rem.devble.C3.CPW.out.CG'] <- round(
      init.devble.CPW.out.GC.df$area.C3.CWP - running.tot.C3.outside.gc, 2)
    
  }


  close.database.connection()


  # Make plots of the results
  
  par(mfrow = c(2,2))
  par(oma=c(2,2,3,2))  # expand outer margins so can fit a global title
  
  plot(time.steps, results$cur.dev.inside.gc, type = 'h', xlab = "Time (years)",
       ylab="Area (ha)", main = "Area of CPW developed INSIDE GC")
  abline( h=PAR.initial.inside.gc.cpw.loss.rate*step.interval,col='grey')
  plot(time.steps, results$cur.dev.outside.gc, type = 'h', xlab = "Time (years)",
       ylab="Area (ha)", main = "Area of CPW developed OUTSIDE GC")
  abline( h=PAR.initial.outside.gc.cpw.loss.rate*step.interval,col='grey')

  plot(time.steps, results$running.tot.dev.inside.gc, type = 'b',xlab = "Time (years)",
       ylab="Area (ha)", main = "Cum. area of CPW developed INSIDE GC" )
  
  plot(time.steps, results$running.tot.dev.outside.gc, type = 'b',xlab = "Time (years)",
       ylab="Area (ha)", main = "Cum. area of CPW developed OUTSIDE GC" )

  mtext( dbname, side = 3, outer=TRUE )

  

  # plot the cumulative amounts of HMV, MMV  LMV CPW over time all on the one plot
  #par(mfrow=c(1,1))

  plot( time.steps, results$running.tot.C3.dev.inside.gc, type = 'b',xlab = "Time (years)",
       ylim=c(0,720), col = 'red',
       ylab="Area (ha)", main = "Cum. area of CPW categories INSIDE GC" ) # running.tot.C3.dev.inside.gc
  
  lines( time.steps, results$running.tot.C2.dev.inside.gc, type = 'b', col = 'blue' ) # running.tot.C2.dev.inside.gc


  
  # Plot the thresholds 
  abline( h = PAR.lmv.limit.inside.gc, col = 'red' )
  abline( h = PAR.mmv.limit.inside.gc, col = 'blue' )


  
  plot( time.steps, results$running.tot.C1.dev.inside.gc, type = 'b',xlab = "Time (years)",
       ylim=c(0,30), col = 'grey',
       ylab="Area (ha)", main = "Cum. area of CPW categories INSIDE GC" ) # running.tot.C1.dev.inside.gc

   # Plot the thresholds 
  abline( h = PAR.hmv.limit.inside.gc, col = 'grey' )


  # Print out the results matrix
  #cat( '\n\nThe results matrix:\n' )
  #print (results)
  
}

#--------------------------------------------------------------------------------------------------------

calc.props.of.CPW.in.GC <- function( dbname ) {

  cat( '\n=========================================================================\n',
      '\n= Calculating the areas of HMV, MMV, LMV in the GCs using db:\n   ', dbname,'\n' )
  connect.to.database(dbname )

  query.CX.CPW.inside.GC  <- paste( "select ID, AREA_OF_C1_CPW, AREA_OF_C2_CPW, AREA_OF_C3_CPW",
                                   "from PU_COND",
                                   "where TIME_STEP = 0 and GROWTH_CENTRE = 1" )
  CX.in.GC <-  sql( query.CX.CPW.inside.GC )
  
  query.CX.CPW.inside.GC.notcert  <- paste( "select ID, AREA_OF_C1_CPW, AREA_OF_C2_CPW, AREA_OF_C3_CPW",
                                   "from PU_COND",
                                   "where TIME_STEP = 0 and GROWTH_CENTRE = 1 and GC_NOTCERT = 1" )
  CX.in.GC.notcert <-  sql( query.CX.CPW.inside.GC.notcert )

  query.CX.CPW.inside.GC.cert  <- paste( "select ID, AREA_OF_C1_CPW, AREA_OF_C2_CPW, AREA_OF_C3_CPW",
                                   "from PU_COND",
                                   "where TIME_STEP = 0 and GROWTH_CENTRE = 1 and GC_CERT = 1" )
  CX.in.GC.cert <-  sql( query.CX.CPW.inside.GC.cert )


  query.CX.CPW.inside.GC.dev  <- paste( 'select ID, AREA_OF_C1_CPW, AREA_OF_C2_CPW, AREA_OF_C3_CPW',
                                       'from PU_COND',
                                       'where TIME_STEP = 0',
                                       'and DEVELOPED = 0',
                                       'and GROWTH_CENTRE = 1',
                                       'and TENURE = "Unprotected"',
                                       'and RESERVED = 0',
                                       'and GC_CERT = 1' )
                                       #'where TIME_STEP = 0 and GROWTH_CENTRE = 1 and GC_CERT = 1',
                                       #'and TENURE = "Unprotected"' )
  
  CX.in.GC.dev <-  sql( query.CX.CPW.inside.GC.dev )
  query.CX.CPW.inside.GC.offset  <- paste( 'select ID, AREA_OF_C1_CPW, AREA_OF_C2_CPW, AREA_OF_C3_CPW',
                                          'from PU_COND',
                                          'where TIME_STEP = 0 ',
                                          'and DEVELOPED = 0',
                                          'and RESERVED = 0',
                                          'and TENURE = "Unprotected"',
                                          'and GROWTH_CENTRE = 1',
                                          'and GC_NOTCERT = 1',
                                          'and UNDEV_LAND = 0',
                                          'and AREA_OF_CPW > 0'
                                          )
                                        #'and TENURE <> "Protected"' )
  
  CX.in.GC.offset <-  sql( query.CX.CPW.inside.GC.offset )

  query.CX.CPW.inside.GC.undev <- paste( 'select ID, AREA_OF_C1_CPW, AREA_OF_C2_CPW, AREA_OF_C3_CPW',
                                          'from PU_COND',
                                          'where TIME_STEP = 0 ',
                                          'and DEVELOPED = 0',
                                          #'and RESERVED = 0',
                                          #'and TENURE = "Unprotected"',
                                          'and GROWTH_CENTRE = 1',
                                          'and GC_NOTCERT = 1',
                                          'and UNDEV_LAND = 1',
                                          'and AREA_OF_CPW > 0'
                                          )
                                       #'and TENURE <> "Protected"' )
  
  CX.in.GC.undev <-  sql( query.CX.CPW.inside.GC.undev )


  cpw.cats <- c("AREA_OF_C1_CPW", "AREA_OF_C2_CPW", "AREA_OF_C3_CPW")
  

  ctr <- 0

  for(cur.cpw.cat in cpw.cats ) {

    cur.length <- length( which( CX.in.GC[, cur.cpw.cat] > 0 ) )
    cur.length.notcert <- length( which( CX.in.GC.notcert[, cur.cpw.cat] > 0 ) )
    cur.length.cert <- length( which( CX.in.GC.cert[, cur.cpw.cat] > 0 ) )
    cur.length.dev <- length( which( CX.in.GC.dev[, cur.cpw.cat] > 0 ) )
    cur.length.offset <- length( which( CX.in.GC.offset[, cur.cpw.cat] > 0 ) )
    cur.length.undev <- length( which( CX.in.GC.undev[, cur.cpw.cat] > 0 ) )
    
    cat( '\nTotal', cur.cpw.cat, '=',  sum(CX.in.GC[, cur.cpw.cat]), '[', cur.length, ']'   )
    
    cat( '  Not cert =',  sum(CX.in.GC.notcert[, cur.cpw.cat] ), '[', cur.length.notcert, ']' )
    
    cat( '  Cert =',  sum(CX.in.GC.cert[, cur.cpw.cat] ), '[', cur.length.cert, ']' )

    cat( '\n    Developable (CERT, TENURE=Unprotected)=',  sum(CX.in.GC.dev[,cur.cpw.cat]),
        '[', cur.length.dev, ']'  )
    
    cat( '\n    Offsettable (UNCERT, UNDEV_LAND = 0)=',  sum(CX.in.GC.offset[,cur.cpw.cat]),
                '[', cur.length.offset, ']'  )

    cat( '\n    Undevelopable (UNCERT, UNDEV_LAND = 1)=',  sum(CX.in.GC.undev[,cur.cpw.cat]),
                '[', cur.length.undev, ']'  )

    cat( '\n')
  }

  cat( '\n\n\n' )
  

  close.database.connection()

  
}

#--------------------------------------------------------------------------------------------------------

# This is just to make it clear when a new set of plots start
par(mfrow = c(1,1)); plot(1, main="NEW SET OF PLOTS" )



#filename.pt1 <- '/Users/ascelin/rdv/output/CPW/local_run50_Offset_in_out_GC_0.95_no_offset_outside_GC/'
#filename.pt1 <- '/Users/ascelin/rdv/output/CPW/local_run51_Offset_in_out_GC/'
#filename.pt1 <- '/Users/ascelin/rdv/output/CPW/local_run10_Offset_in_out_GC_0.95_no_offset_outside_GC/'
#filename.pt1 <- '/Users/ascelin/rdv/analysis/testResRandom2Q2/'
#filename.pt1 <- '/Users/ascelin/rdv/analysis/A10_CPWinitCond_100years/'

#filename.pt1 <- '/Users/ascelin/rdv/analysis/T_new_ranRes/'
filename.pt1 <- '/Users/ascelin/rdv/analysis/T4_new_ranRes/'

filename.pt2 <- 'PUinformation.'

PAR.runs <- c(10)
#PAR.runs <- c(50)
PAR.runs <- c(468)
PAR.runs <- c(800)
PAR.runs <- c(1016)

filename.pt3 <- '.dbms'


PAR.initial.inside.gc.cpw.loss.rate <- 39.6
PAR.initial.outside.gc.cpw.loss.rate <- 48
PAR.hmv.limit.inside.gc <- 27
PAR.mmv.limit.inside.gc <- 450
PAR.lmv.limit.inside.gc <- 710


for( cur.run in PAR.runs) {

  full.filename <- paste( filename.pt1, filename.pt2, cur.run, filename.pt3, sep='')

  cat( '\n file =', full.filename )
  
  #get.initial.amounts.for.dev.and.offset()
  #browser()
  plot.offset.results( full.filename )
  #plot.development.results( full.filename )

}

filename.pt2 <- 'evalCondition.dbms'
#calc.props.of.CPW.in.GC( paste( filename.pt1, cur.run, filename.pt2, sep=''))

