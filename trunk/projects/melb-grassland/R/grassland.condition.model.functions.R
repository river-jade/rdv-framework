
# source( 'grassland.condition.model.functions.R' )


#-----------------------------------------------------------------------------

get.managed.habitat.indices <- function() { 


  if( OPT.use.raster.maps.for.input.and.output ) {
    
    # generate the current managed PU file name
    cur.managed.pu.map.file.name <-
      paste (managed.planning.units.filename.base, '.',
             (current.time.step - step.interval),
             '.txt', sep="")

    if( file.exists( cur.managed.pu.map.file.name ) ) {
    # read in the reserved PU file
      cur.managed.pu.map <-
        as.matrix( read.table( cur.managed.pu.map.file.name ) )
  

      # select the reserved reserved pixels 
      managed.habitat.indices <-
        which( cur.managed.pu.map != non.habitat.indicator )
    
    } else {
    
      # In this case there was no reserved planning unit map, so assume
      # that no reserves were selected
      managed.habitat.indices <- integer(0)
    }

  } else {

    # In this case using the database directly for input/output.
    # need to get the indicies of managed PUs from DB

    # Get the IDs of managed PUs from the DB
    query <- paste( 'select ID from ', dynamicPUinfoTableName,
                   ' where MANAGED = 1 ', sep ='' )
                   #'and TENURE = "', PAR.tenure.of.parcels.to.evolve, '"', sep ='' )
    
    managed.habitat.PU.IDs <- sql.get.data(PUinformationDBname , query)

    # Work out the idices of the PUs based on the list of PUs
    managed.habitat.indices <-
      which(  GLOBAL.all.PU.IDs.with.given.tenure %in%  managed.habitat.PU.IDs )
  }

  return( managed.habitat.indices )
  
}

#-----------------------------------------------------------------------------
get.unmanaged.habitat.indices <- function( hab.map ) { 

  if( OPT.use.raster.maps.for.input.and.output) {
    # generate the current managed PU file name
    cur.managed.pu.map.file.name <-
      paste (managed.planning.units.filename.base, '.',
             (current.time.step - step.interval),
             '.txt', sep="")

    if( file.exists( cur.managed.pu.map.file.name ) ) {
      # read in the reserved PU file
      cur.managed.pu.map <-
        as.matrix( read.table( cur.managed.pu.map.file.name ) )
    
      # select the UNreserved pixels that contain any habitat
      unmanaged.habitat.indices <-
        which( cur.managed.pu.map == non.habitat.indicator )

    } else {
    
      # In this case there was no reserved planning unit map, so assume
      # that no reserves were selected also assume that everwhere is
      # unreserved habiat. So get the values of everywhere that is in
      # the map note the which( hab.map > -9999 ) is just to select
      # every pixel

      unmanaged.habitat.indices <- which( hab.map > -9999 )

    }

  } else {

    # In this case using the database directly for input/output.
    # need to get the indices of managed PUs from DB

    # Get the IDs of unmanaged PUs from the DB
    query <- paste( 'select ID from ', dynamicPUinfoTableName,
                   ' where MANAGED = 0 ', sep ='' )
                   #'and TENURE = "', PAR.tenure.of.parcels.to.evolve, '"', sep ='' )
    
    unmanaged.habitat.PU.IDs <- sql.get.data(PUinformationDBname , query)

    # Work out the indices of the PUs based on the list of PUs
    unmanaged.habitat.indices <-
      which(  GLOBAL.all.PU.IDs.with.given.tenure %in%  unmanaged.habitat.PU.IDs )

  }

  return( unmanaged.habitat.indices )
  
}

#-----------------------------------------------------------------------------
#---------------------------------------
#  Updated to work from managed/unmanaged PUs instead of 
#  reserves. - DWM 22/09/2009
#----------------------------------------


update.grassland.condtion.model <- function( cond.scores, current.time.step) {
  
  cat( '\n----\n'
      ,'Running Grassland Condition Model',
      '\n----\n')

  cond.scores.init <- cond.scores
  
  managed.habitat.indices   <- get.managed.habitat.indices()
  unmanaged.habitat.indices <- get.unmanaged.habitat.indices( cond.scores )

#browser()
  
  #=======================================================
  # Evolve each pixel of grassland based on the curves defined
  # in define.reference.curves()
  # The reserved and unreseved grassland pixels are
  # evolved separately
  #=======================================================

  # evolve the reserved (managed) grassland

  if( length(managed.habitat.indices ) > 0 ) {
    # extract current condition of each reserved pixel
    curr.managed.condition <- cond.scores[ managed.habitat.indices ]

    curr.managed.condition2 <- evolve.condition( curr.managed.condition,
                                                step.interval,
                                                "MANAGED" )
    cond.scores[ managed.habitat.indices ] <- curr.managed.condition2

  }


  # evolve the unreserved (unmanaged) grassland
  
  if(!OPT.unmanaged.is.stable){
  
    if( length( unmanaged.habitat.indices ) > 0 ) {
      
      # extract current condition of each unreserved pixel
      curr.unmanaged.condition <- cond.scores[ unmanaged.habitat.indices ]

      curr.unmanaged.condition2 <- evolve.condition( curr.unmanaged.condition,
                                                    step.interval,
                                                    "UNMANAGED" )
    
      cond.scores[ unmanaged.habitat.indices ] <- curr.unmanaged.condition2
    }
  }

  return( cond.scores )
}


#-----------------------------------------------------------------------------

run.condition.model <- function( input.map.filename, time.step  ){

  if( OPT.use.raster.maps.for.input.and.output ) {

    input.condition.scores <- as.matrix( read.table( input.map.filename ) )

  } else {
    
    # In this case using the database directly for input/output.

    # First get the full list of PUs from the database
    query <- paste( "select ID from ", dynamicPUinfoTableName, sep='' )
                   #' where TENURE = "', PAR.tenure.of.parcels.to.evolve, '"', sep='' )

    # Note: make this GLOBAL so it doesn't need to be passed between
    # multiple levels of functions
    GLOBAL.all.PU.IDs.with.given.tenure <<- sql.get.data(PUinformationDBname , query )


    # Now get the condition scores of all the PUs
    
    query <- paste( 'select ', PAR.aggregate.parcel.condition.db.table.field, ' from ',
                   dynamicPUinfoTableName, sep ='')
                   #' where TENURE = "', PAR.tenure.of.parcels.to.evolve, '"', sep ='')
    input.condition.scores <- sql.get.data(PUinformationDBname , query)

  }

  updated.map <- update.grassland.condtion.model( input.condition.scores, time.step )

  if( OPT.use.smoothing.in.grassland.cond.model ) {
    
    # smooth the map using moving window smoothing (see utility.functions.R)
    k.vals <- c(
                0.003, 0.013, 0.022, 0.013, 0.003,
                0.013, 0.060, 0.098, 0.060, 0.013,
                0.022, 0.098, 1.000, 0.098, 0.022,
                0.013, 0.060, 0.098, 0.060, 0.013,
                0.003, 0.013, 0.022, 0.013, 0.003
                )
    
    kernel <- matrix ( k.vals, nrow = 5, ncol = 5, byrow = TRUE )

    
    #updated.map <- smooth.map( updated.map,
    #                          PAR.grassland.smoothing.window.size,
    #                          PAR.weight.of.non.focal.pixels.in.smoothing
    #                          )
    
    updated.map <- kernel.smooth.map( updated.map,kernel )

    
    # Note: the smoothoothing might bump some pixels over the
    # threshold and make others below min (if using zeros in mean calc).
    ind <- which( (updated.map < PAR.grassland.min.cond.score) &
                  (updated.map > 0 ) )
    
    if( length(ind) > 0 ) {
      updated.map[ind] <- PAR.grassland.min.cond.score
    }

  }

  write.outputs( updated.map, time.step ) 

}

#-----------------------------------------------------------------------------

readin.cond.file <- function( filename ) {
  
  return( scan(filename) )

  
}

#-----------------------------------------------------------------------------

define.reference.curves <- function() {

  # note the way the score is defined with habitat hectare 0.75 is the
  # highest possible score

  time.steps          <- readin.cond.file( PAR.time.steps.filename )
  above.thresh.points <- readin.cond.file( PAR.managed.above.thresh.filename)
  below.thresh.points <- readin.cond.file( PAR.managed.below.thresh.filename)
  unmanaged.points    <- readin.cond.file( PAR.unmanaged.filename)


  # check that all the files have the same number of entires
  lts <- length( time.steps )
  if(length(above.thresh.points) != lts |
     length(below.thresh.points) != lts |
     length(unmanaged.points ) != lts ) {

    cat( '\nError. There are inconsistancies with the grassland input',
        '\n  files in the initialisation_files directory' )
    stop()
  }
            

  PAR.max.time <<- max( time.steps )

  
  if( DEBUG ){
    
    # plot the curves
    par( mfrow = c( 2,2)) 
    x.limit <- c(0,100)
  
    plot( time.steps, above.thresh.points, ylim = c(0,0.8), xlim = x.limit,
         main = 'Initial points - managed', xlab = 'Time (years)',
         ylab = 'Condition Score (0-1)' )
    points( time.steps, below.thresh.points )
  
    plot( time.steps, unmanaged.points, ylim = c(0,0.8), xlim = x.limit,
         main = 'Initial points - unmanaged', xlab = 'Time (years)',
         ylab = 'Condition Score (0-1)' )
  }


  # use 'approxfun' to return a list of points which linearly
  # interpolate given data points, or a function performing the linear
  # (or constant) interpolation.

  cond.v.time.above.thresh <<- approxfun( time.steps, above.thresh.points)
  cond.v.time.below.thresh <<- approxfun( time.steps, below.thresh.points )
  cond.v.time.unmanaged    <<- approxfun( time.steps, unmanaged.points )

  time.v.cond.above.thresh <<- approxfun( above.thresh.points, time.steps)
  time.v.cond.below.thresh <<- approxfun( below.thresh.points, time.steps )
  time.v.cond.unmanaged    <<- approxfun( unmanaged.points, time.steps )

  

  
  # plot the functions
  if( DEBUG ) { 
    t <- 1:PAR.max.time
    plot( t, cond.v.time.above.thresh(t), type = 'l', ylim = c(0,0.8),
         xlim = x.limit, main = 'Function created from points' )
    lines( t, cond.v.time.below.thresh(t) )
    

    plot( t, cond.v.time.unmanaged(t), type = 'l', ylim = c(0,0.8),
         xlim = x.limit, main = 'Function created from points' )
  }


}

#-----------------------------------------------------------------------------


move.along.condition.curve <- function( current.cond, time.step, curve.type){


  # work out which function to move along based on whether above or
  # below the condition threshold

  if( curve.type == "GT_THRESH" ){
    
    cond.v.time.function <- cond.v.time.above.thresh
    time.v.cond.function <- time.v.cond.above.thresh
    
  } else {
    
    if( curve.type == "LT_THRESH" ) {

      cond.v.time.function <- cond.v.time.below.thresh
      time.v.cond.function <- time.v.cond.below.thresh
      
    } else {

      if( curve.type == "UNMANAGED" ) {
        
        cond.v.time.function <-  cond.v.time.unmanaged
        time.v.cond.function <- time.v.cond.unmanaged


      } else {

        cat( '\nError. Unknown curve.type:', curve.type, '\n' )
        stop()

      }
      
    }
  }
    
  # work out the current time possition on the curve.
  current.time <- time.v.cond.function( current.cond )

  # work out the next time step
  next.time.step <- time.step + current.time

  # make sure no indices went over the max num time steps
  ind <- which( next.time.step > PAR.max.time)
  if( length(ind) > 0 ) next.time.step[ind] <- PAR.max.time

  # get the final condition
  next.condition <- cond.v.time.function( next.time.step )
  
  return( next.condition )

}

#-----------------------------------------------------------------------------

grassland.cond.change <- function( current.cond, time.step, status){


  # make a vector to store the final condition
  final.cond <- rep( -1, length( current.cond ))
  
  # check the condition score is within appropriate bounds
  more.than.max <- which( current.cond > PAR.grassland.max.cond.score )
  less.than.min <- which( current.cond < PAR.grassland.min.cond.score )
  
  if( length( less.than.min)>0 | length( more.than.max)>0 ) {

    cat( '\nError:  a value in the current condition score is\n',
        'outside allowable range of [', PAR.grassland.min.cond.score, ',',
        PAR.grassland.max.cond.score, '].\n\n' )
    
    cat( "current.cond = ", current.cond, "\n" )
    
    stop()
  }

    #------------------------------------------------------------
    # Managed grassland
    #------------------------------------------------------------


  if( status == 'MANAGED' ) {
  
    # work out which pixels are are above or below the threshold

    # NOTE: you need to use <= when specifying pixesl below threshold
    
    indices.above.threshold <- which(current.cond>PAR.grassland.threshold.value)
    indices.below.threshold <- which(current.cond<=PAR.grassland.threshold.value)


    # update the conditon of the pixels above the threshold
    if( length( indices.above.threshold ) > 0 ) {

      cur.cond.gt.thresh <- current.cond[ indices.above.threshold ]

      next.cond.gt.thresh <- move.along.condition.curve(cur.cond.gt.thresh,
                                                        time.step, "GT_THRESH")
      # set the values in the final condition matrix
      final.cond[indices.above.threshold ] <- next.cond.gt.thresh
    
    }
                      
    # update the conditon of the pixels below the threshold
    if( length( indices.below.threshold) > 0 ) {
    
      cur.cond.lt.thresh <- current.cond[ indices.below.threshold ]

      next.cond.lt.thresh <- move.along.condition.curve(cur.cond.lt.thresh,
                                                        time.step, "LT_THRESH")
      # set the values in the final condition matrix
      final.cond[indices.below.threshold ] <- next.cond.lt.thresh
      
    }
  } else {
    
    if( status == 'UNMANAGED' ) {
      
      final.cond <- move.along.condition.curve( current.cond, time.step,
                                               "UNMANAGED")      
    } else {
      
      cat( '\nError. Unknown status:', status, '\n' )
      stop()
      
    }
   
  }

  return( final.cond )
}

#-----------------------------------------------------------------------------

jitter.by.fixed.proportion.with.limits <- function( proportion, values,
                                                   lower.lim, upper.lim) {
  
  variability.factor <- values * proportion
  num <- length( values )
  variability.value <-
    runif( num, 0, 2*variability.factor) - variability.factor

  # jitter the values
  jittered.value <- values + variability.value


  # check that no values were jittered outside the limits. If they
  # were, then set them to the limits

  ind <- which( jittered.value < lower.lim )
  if( length( ind ) > 0 ) jittered.value[ind] <- lower.lim
  
  ind <- which( jittered.value > upper.lim )
  if( length( ind ) > 0 ) jittered.value[ind] <- upper.lim


  return( jittered.value )
  

}
#-----------------------------------------------------------------------------

jitter.using.normal.dist.with.limits.and.thresh <- function( values,
                                                         standard.deviation,
                                                         lower.lim,
                                                         upper.lim,
                                                         thresh.crossing.prob)
{
  
  num <- length( values )

  variability.values <- rnorm( num, mean = 0, sd = standard.deviation )

  # jitter the values
  jittered.values <- values + variability.values


  # find the indices that were intitially below the grassland threshold
  # NOTE: you need to use <= when specifying pixesl below threshold

  ind.below.thresh <- which( values <= PAR.grassland.threshold.value )

  # see if any of these went above the threshold
  ind.of.ind.below.that.jittered.over.thresh <-
    which(jittered.values[ind.below.thresh] > PAR.grassland.threshold.value)

  # the list of indices that crossed
  ind.that.crossed <-
    ind.below.thresh[ind.of.ind.below.that.jittered.over.thresh]


  if( DEBUG ) {
    cat('\nind.that initially crossed = ', ind.that.crossed, '\n\n' )
  }


 # use thresh.crossing.prob to determine which if those that crossed
 # can stay coreseed and which should be set back the the threshold
  
  random.vals <- runif( length(ind.that.crossed), 0, 1)

  sub.indices.that.dont.cross <-
    which( random.vals > PAR.prob.of.crossing.thresh )

  ind.that.dont.cross <- ind.that.crossed[sub.indices.that.dont.cross ] 


  if( DEBUG ) {
    cat( '\n ind.that.dont.cross  = ', ind.that.dont.cross,
        '  random.vals = ',random.vals,
        '\n\n' )
  cat( '\n\n jittered.values =', jittered.values )
  }

  jittered.values[ind.that.dont.cross] <- PAR.grassland.threshold.value

  if( DEBUG ) {
    cat( '\n\n adjusted jittered.values =', jittered.values, '\n\n' )
  }

  # finally make a check that no values went over the upper and lower
  # limits. If they were, then set them to the limits
  
  ind <- which( jittered.values < lower.lim )
  if( length( ind ) > 0 ) jittered.values[ind] <- lower.lim
  
  ind <- which( jittered.values > upper.lim )
  if( length( ind ) > 0 ) jittered.values[ind] <- upper.lim


  return( jittered.values )
  

}

#-----------------------------------------------------------------------------

evolve.condition <- function(current.cond, time.step, status ) {


  # this function sets up the curves that determine the evolution of
  # the grasslands.
  
  define.reference.curves()
  current.cond.init <- current.cond

  # extract all the non-zero condition values
  ind <- which( current.cond != non.habitat.indicator )
  current.cond.scores <- current.cond[ind]

  next.cond <- grassland.cond.change( current.cond.scores, time.step, status )

  jittered.cond <- next.cond
  
  jittered.cond <- jitter.using.normal.dist.with.limits.and.thresh(
                                    next.cond,
                                    PAR.grassland.variability.std.dev,
                                    PAR.grassland.min.cond.score,
                                    PAR.grassland.max.cond.score,
                                    PAR.prob.of.crossing.thresh)

  
  current.cond[ind] <- jittered.cond


  return( current.cond )
  
}
#-----------------------------------------------------------------------------

write.outputs <- function( updated.condition, time.step ) {

  if( OPT.use.raster.maps.for.input.and.output ) {
    
    cur.cond.model.file.name <- paste( cond.model.root.filename,
                                      time.step, sep = '' )
    write.pgm.txt.files( updated.condition, cur.cond.model.file.name , rows, cols )
    
  } else {

    # Otherwise using the database. In this case need to update the db
    # values with the evloved condition scores

    # In this case updated.condition is the condition scores of parcels
    # that are in the tenure specified by
    # PAR.tenure.of.parcels.to.evolve. See need to make a vector of
    # the conditions of all parcels and then set the ones with tenure
    # = PAR.tenure.of.parcels.to.evolve to be the new conditions
    # just calculated

    #query <- paste( 'select TENURE from', dynamicPUinfoTableName )
    #tenure.all.PUs <- sql.get.data(PUinformationDBname, query)

    query <- paste( 'select', PAR.aggregate.parcel.condition.db.table.field, 'from',
                   dynamicPUinfoTableName )
    condition.all.PUs <- sql.get.data(PUinformationDBname, query)

    #indices.to.update <- which( tenure.all.PUs ==  PAR.tenure.of.parcels.to.evolve )

    #new.condition.all.PUs <- condition.all.PUs
    #new.condition.all.PUs[indices.to.update] <- updated.condition
    new.condition.all.PUs <- updated.condition
    update.column.in.db.table.via.dataframe( dynamicPUinfoTableName,
                                            PAR.aggregate.parcel.condition.db.table.field,
                                            new.condition.all.PUs)
    

  }
  

}

#-----------------------------------------------------------------------------

