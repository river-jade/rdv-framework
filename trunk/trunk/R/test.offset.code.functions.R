
get.initial.amounts.for.dev.and.offset <- function() {

  # First get the intital amounts of CPW that is available for
  # development for the whole lanscape, and also inside and outside
  # the Growth Centers (GCs). Note that this needs to be run on the
  # files evalCondition.XXX.dbms (where XXX is run number). For some
  # of these files the SQLite database seems to be corrupted, so using
  # a hard coded run number for now. This should be the same for all
  # runs the use the same input shapefiles.

  # Note for getting the initial amounts of CPW we don't want to
  # include the criteria GC_CERT = 1. This critearia is only for
  # parcels that can be developed, and does not inlcude the parcels
  # that can be offset. This criteria should include alll/only the
  # parcels that can be offset and developed
  
  GC.selection.option <- paste( 'and DEVELOPED = 0 and RESERVED = 0 and TENURE = "Unprotected"',
                               'and GROWTH_CENTRE = 1 and GC_CERT =1 and UNDEV_LAND=0')
  
  nonGC.selection.option <- 'and DEVELOPED = 0 and RESERVED = 0 and TENURE = "Unprotected" and GROWTH_CENTRE = 0'

  
  cat( "\n----------------------------------------------------------------------",
       "\nCALCULATING INITIAL AMOUNT OF CPW FOR OFFSETTING AND DEVELOPMENT" )

  cat( '\n\n ** Amounts available for development (ha) **' )
  
  init.CPW.df <<- get.init.CPW.stats( GC.option='', descript='All      ' )
  init.devble.CPW.in.GC.df <<- get.init.CPW.stats( GC.option=GC.selection.option, descript='Inside GC ' )
  init.devble.CPW.out.GC.df <<- get.init.CPW.stats( GC.option=nonGC.selection.option, descript='Ouside GC' )


  # get the inial amount of CPW available for offsets

  cat( '\n\n ** Amounts available for offsetting (ha) **' )
  GC.selection.option <- paste( 'and DEVELOPED = 0 and RESERVED = 0 and TENURE = "Unprotected"',
                         'and GROWTH_CENTRE = 1 and GC_NOTCERT =1 and UNDEV_LAND = 0 and AREA_OF_CPW > 0' )
  
  nonGC.selection.option <- paste( 'and RESERVED = 0 and DEVELOPED = 0 and TENURE = "Unprotected"',
                            'and GROWTH_CENTRE = 0 and AREA_OF_CPW > 0' )
  
  init.offsettable.CPW.df <<- get.init.CPW.stats( GC.option='', descript='All      ' )
  init.offsettable.devble.CPW.in.GC.df <<- get.init.CPW.stats( GC.option=GC.selection.option, descript='Inside GC' )
  init.offsettable.devble.CPW.out.GC.df <<- get.init.CPW.stats( GC.option=nonGC.selection.option, descript='Outside GC' )
  
  cat( '\n----------------------------------------------------------------------------------------')


}

#------------------------------------------------------------------------------------------------

generate.offset.stats <- function( dbname, time.steps, extra.query.terms='', offset.criteria='' ) {

  connect.to.database( dbname )
  
  results <- matrix(0, nrow = length(time.steps) , ncol = 5)

  running.tot.dev <- 0
  running.tot.res <- 0

  ctr <- 0

  for( cur.time in time.steps ) {
    ctr <- ctr + 1
    
    cat( '\nTime step = ', cur.time )
    
    query.dev <- paste( "select HH_SCORE_AT_DEV_TIME from dynamicPUinfo where TIME_DEVELOPED =",
                       cur.time, extra.query.terms )
#    query.res <- paste( "select HH_SCORE_AT_OFFSET_TIME from dynamicPUinfo where TIME_RESERVED =", # xxx
    query.res <- paste( "select AREA_OF_CPW from dynamicPUinfo where TIME_RESERVED =",
                       cur.time, extra.query.terms )
    query.res.C1 <- paste( "select AREA_OF_C1_CPW from dynamicPUinfo where TIME_RESERVED =",
                       cur.time, extra.query.terms )
    query.res.C2 <- paste( "select AREA_OF_C2_CPW from dynamicPUinfo where TIME_RESERVED =",
                       cur.time, extra.query.terms )
    query.res.C3 <- paste( "select AREA_OF_C3_CPW from dynamicPUinfo where TIME_RESERVED =",
                       cur.time, extra.query.terms )
    

    dev <-  sql( query.dev ); res <-  sql( query.res )
    res.C1 <-  sql( query.res.C1 ); res.C2 <-  sql( query.res.C2 ); res.C3 <-  sql( query.res.C3 )
      
    running.tot.dev <- running.tot.dev + sum( dev )
    running.tot.res <- running.tot.res + sum( res )
  
    cat( '\n  No. of parcels dev   :', length( dev), 'Tot score =', round(sum (dev),1),
        'Running tot:', round(running.tot.dev,2) )
    cat( '\n  No. of parcels offset:', length( res), 'Tot score =', round(sum (res),1),
        'Running tot:', round(running.tot.res,1) )
    
    #cat( " [RandRes: expected=", 3.3* cur.time,
    #    'C1res=',  round(sum (res.C1),1), # xxxx
    #    'C2&3res=',  round((sum (res.C2)+sum (res.C3)),1), ']' ) # xxxx
    
    cat('\n')

    if( length(dev) == 0 ) results[ctr,1] <- 0
    else results[ctr,1] <- sum(dev)
    
    if( length(res) == 0 )  results[ctr,2] <- 0
    else results[ctr,2] <- sum(res)

    # Store the cumulative difference
    results[ctr,3] <-  running.tot.res - running.tot.dev  #results[ctr,2] - results[ctr,1]
    
    # Store the proportional difference for that time step
    results[ctr,4] <-  ( results[ctr,2] - results[ctr,1] ) / results[ctr,1]

    # Store the proportional cumlative difference 
    results[ctr,5] <-  (running.tot.res - running.tot.dev)/ running.tot.dev 
  
  }


  close.database.connection()

  make.offset.plots( dbname, results, time.steps, extra.query.terms  )

  return( results )
}

make.offset.plots <- function( dbname, results, time.steps, tag='' ) {

  par(mfrow = c(2,2))
  
  par(oma=c(2,2,3,2))  # expand outer margins so can fit a global title

  
  plot(time.steps, results[,2] - results[,1], type = 'h', xlab = "Time (years)",
       ylab="Difference (HH)", main = "Diff b/w Offset and Dev HH score at each time step")
  abline( h=0,col='grey')
  
  plot(time.steps, results[,3], type = 'b',xlab = "Time (years)",
       ylab="Difference (HH)", main = "Cummulative diff b/w Offset and Dev HH score" )
  
  plot(time.steps, results[,4], type = 'b',xlab = "Time (years)",
       ylab="Difference (HH)", main = "Proportional diff b/w Offset & Dev HH score at each time step" )
  abline( h=0,col='grey')
  
  plot(time.steps, results[,5], type = 'b', xlab = "Time (years)",
       ylab="Difference (HH)", main = "Proportional cumulative diff " )
  
  abline( h=0,col='grey')
  
  mtext( paste(dbname, tag),  side = 3, outer=TRUE )
  
}




#--------------------------------------------------------------------------------------------------------

get.init.CPW.stats <- function( GC.option, descript ){

  # These are the values inside the growth centre only
  init.CPW <-2025.674
  init.C1.CPW <- 391.828
  init.C2.CPW <- 723.779
  init.C3.CPW <- 910.066

  # this is the hardcoded run number, as some of the evalCondition database files seem to be corrupted. 
  #PAR.runs <- c(5)


  
  full.db.filename <- paste( filename.pt1, 'evalCondition.', PAR.runs[1], filename.pt3, sep='')
  #full.db.filename <- paste( filename.pt1, 'PUinformation.', PAR.runs[1], filename.pt3, sep='')

  full.db.filename <- '/Users/ascelin/rdv/analysis/AllScen_x10_inc_ranRes2/evalCondition.605.dbms'
  
  connect.to.database( full.db.filename )
  
#browser()
  
  init.CPW.query  <- paste( "select ID, AREA_OF_CPW, AREA_OF_C1_CPW, AREA_OF_C2_CPW,",
                           "AREA_OF_C3_CPW from",
                           #"dynamicPUinfo where AREA_OF_CPW > 0",
                           "PU_COND where TIME_STEP = 0 ",
                           GC.option );
  init.parcel.CPW.df <- sql( init.CPW.query )
  close.database.connection()
  
  init.CPW <- sum( init.parcel.CPW.df$AREA_OF_CPW )
  init.C1.CPW <- sum( init.parcel.CPW.df$AREA_OF_C1_CPW )
  init.C2.CPW <- sum( init.parcel.CPW.df$AREA_OF_C2_CPW )
  init.C3.CPW <- sum( init.parcel.CPW.df$AREA_OF_C3_CPW )
  
  init.CPW.df <- data.frame( area.all.CPW=init.CPW, area.C1.CWP=init.C1.CPW, area.C2.CWP=init.C2.CPW,
                            area.C3.CWP=init.C3.CPW)
  
  cat( '\n    Init area of all CPW ', descript, ' = ', round(init.CPW.df$area.all.CPW,1),
      '     [C1.CWP=', round(init.CPW.df$area.C1.CWP,1), ',',
      '  C2.CWP=', round(init.CPW.df$area.C2.CWP,1),',',
      '  C3.CWP=', round(init.CPW.df$area.C3.CWP,1), ']', sep='' )
  #browser()
  return( init.CPW.df )
  
}

