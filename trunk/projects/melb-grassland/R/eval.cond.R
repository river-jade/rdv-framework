#=============================================================================
#
#                            eval.cond.R
#
#  Evaluate the condition of the landscape by summing various subsets of the
#  condition map: the whole map, the unreserved polygons, and the reserved
#  polygons.
#
#  To run:
#      source( 'eval.cond.R' )
#
#
#  Create 23/02/09 - BTL.
#  
#  Added code 
#
#
#=============================================================================


rm( list = ls( all=TRUE ))


    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'w.R' )
source( 'utility.functions.R' )
source( 'variables.R' )

source( 'dbms.functions.R' )      

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

#==============================================================================

    #------------------------------------------------------------------
    #  Get the master habitat map so that you can find which pixels are
    #  masked out.
    #------------------------------------------------------------------

#master.habitat.map.pid.filename <-
#    paste( master.habitat.map.pid.base.filename,'.txt', sep = '' )

# new!
master.habitat.map.pid.filename <-
    paste( master.habitat.map.zo1.base.filename,'.txt', sep = '' )

hab.master.pid.map <- as.matrix (read.table (master.habitat.map.pid.filename))


    #---------------------------------------------------
    #  Determine which are masked out and which are not.
    #---------------------------------------------------

# new!
non.habitat.indicator <- 0

indices.of.masked.out.pixels <- which (hab.master.pid.map ==
                                       non.habitat.indicator)
num.masked.out.pixels <- length (indices.of.masked.out.pixels)

indices.of.unmasked.pixels <- which (hab.master.pid.map !=
                                     non.habitat.indicator)
num.unmasked.pixels <- length (indices.of.unmasked.pixels)

if( DEBUG ) {
  cat ("\n\nnum.masked.out.pixels = ", num.masked.out.pixels)
  cat ("\nnum.unmasked.pixels = ", num.unmasked.pixels)
}
    #-------------------------------------------------------------
    #  Get the planning units that are currently reserved amd unreserved.
    #-------------------------------------------------------------

cur.res.pu.file.name <-  paste (reserved.planning.units.filename.base, '.', 
                                current.time.step, '.txt', sep = "")

if( file.exists( cur.res.pu.file.name ) ) {
  cur.res.pu.map <- as.matrix (read.table (cur.res.pu.file.name))

  indices.of.reserved <- which (cur.res.pu.map != non.habitat.indicator)
  #indices.of.reserved <- indices.of.reserved [indices.of.reserved %in%
   #                                           indices.of.unmasked.pixels]
  
  indices.of.unreserved <- which (cur.res.pu.map == non.habitat.indicator)
  #indices.of.unreserved <- indices.of.unreserved [indices.of.unreserved %in%
  #                                              indices.of.unmasked.pixels]
  num.unreserved.pixels = length (indices.of.unreserved)
  if( DEBUG ) cat ("\nnum.unreserved.pixels = ", num.unreserved.pixels)

  
} else {
  
  # in this case there was no reserved planning unit map, so assume
  # that no reserves were selected
  
  indices.of.reserved <- integer(0)
  
  # also assume that everwhere is unreserved habiat. So get the
  # values of everywhere that is in the map
  # note the which( hab.map > -9999 ) is just to select every pixel
  
  indices.of.unreserved <- which( hab.master.pid.map > -999 )
  
}

   
num.reserved.pixels = length (indices.of.reserved)
if( DEBUG ) cat ("\n\nnum.reserved.pixels = ", num.reserved.pixels)

    #-------------------------------------------------------------
    #  Get the planning units that are currently managed and unmanaged.
    #-------------------------------------------------------------

cur.manag.pu.file.name <-  paste (managed.planning.units.filename.base, '.', 
                                current.time.step, '.txt', sep = "")

if( file.exists( cur.manag.pu.file.name ) ) {
  cur.manag.pu.map <- as.matrix (read.table (cur.manag.pu.file.name))

  indices.of.managed <- which (cur.manag.pu.map != non.habitat.indicator)
  #indices.of.reserved <- indices.of.reserved [indices.of.reserved %in%
   #                                           indices.of.unmasked.pixels]
  
  indices.of.unmanaged <- which (cur.manag.pu.map == non.habitat.indicator)
  #indices.of.unreserved <- indices.of.unreserved [indices.of.unreserved %in%
  #                                              indices.of.unmasked.pixels]
  num.unmanaged.pixels = length (indices.of.unmanaged)
  if( DEBUG ) cat ("\nnum.unmanaged.pixels = ", num.unmanaged.pixels)

  
} else {
  
  #as per the reserves case immediately above..
  
  indices.of.managed <- integer(0)
 
  indices.of.managed <- which( hab.master.pid.map > -999 )
}

   
num.managed.pixels = length (indices.of.managed)
if( DEBUG ) cat ("\n\nnum.managed.pixels = ", num.managed.pixels)

    #-------------------------------------------
    #  Get the current map of habitat condition.
    #-------------------------------------------

cur.cond.map.filename <-  paste (cond.model.root.filename, 
                                  current.time.step, '.txt', sep = "")
cur.cond.map <- as.matrix (read.table (cur.cond.map.filename))

    #-------------------------------------------
    #  Get indicies of the areas in development
    #  and offset pools - 
	#  or use all planning units if no pools specified
    #-------------------------------------------
if( OPT.specify.development.pool.with.map )
{
	dev.pool.map.filename    <- PAR.development.pool.map.filename
	
	dev.pool.map    <- as.matrix ( read.table( dev.pool.map.filename ) )
	
	indices.of.dev.pool    <- which( dev.pool.map == 1 )
} else {
	
	indices.of.dev.pool    <- which( cur.cond.map >= 0 )
}


if ( OPT.specify.offset.pool.with.map ) 
{
	offset.pool.map.filename <- PAR.offset.pool.map.filename

	offset.pool.map <- as.matrix ( read.table( offset.pool.map.filename ))

	indices.of.offset.pool  <- which( offset.pool.map == 1 )
        
} else {
	
	indices.of.offset.pool  <- which( cur.cond.map >= 0 )
}


    #------------------------------------------------------------------
    #  Now we are ready to compute the total, mean, and median habitat
    #  condition for all pixels and then just the reserved and just the
    #  unreserved.
    #  Be sure not to include any masked out pixels.
    #------------------------------------------------------------------

if( DEBUG ) cat ("\n---------------------\n")
if( DEBUG ) cat ("current.time.step = ", current.time.step)


# Total condition score  -----------
if( DEBUG ) cat ("\n---------------------\n")

total.cond.score.sum <- sum (cur.cond.map [indices.of.unmasked.pixels])
if( DEBUG ) cat ("\ntotal.cond.score.sum = ", total.cond.score.sum)

total.cond.score.mean <- mean (cur.cond.map [indices.of.unmasked.pixels])
if( DEBUG ) cat ("\ntotal.cond.score.mean = ", total.cond.score.mean)

total.cond.score.median <- median (cur.cond.map [indices.of.unmasked.pixels])
if( DEBUG ) cat ("\ntotal.cond.score.median = ", total.cond.score.median)

# Reserved condition score  -----------
if( DEBUG ) cat ("\n---------------------\n")
reserved.cond.score.sum <- sum (cur.cond.map [indices.of.reserved])
if( DEBUG ) cat ("\nreserved.cond.score.sum = ", reserved.cond.score.sum)

reserved.cond.score.mean <- mean (cur.cond.map [indices.of.reserved])
if( DEBUG ) cat ("\nreserved.cond.score.mean = ", reserved.cond.score.mean)

reserved.cond.score.median <- median (cur.cond.map [indices.of.reserved])
if( DEBUG ) cat ("\nreserved.cond.score.median = ", reserved.cond.score.median)


# Unreserved condition score  -----------
if( DEBUG ) cat ("\n---------------------\n")

unreserved.cond.score.sum <- sum (cur.cond.map [indices.of.unreserved])
if( DEBUG ) cat ("\nunreserved.cond.score.sum = ", unreserved.cond.score.sum)

unreserved.cond.score.mean <- mean (cur.cond.map [indices.of.unreserved])
if( DEBUG ) cat ("\nunreserved.cond.score.mean = ", unreserved.cond.score.mean)

unreserved.cond.score.median <- median (cur.cond.map [indices.of.unreserved])
if( DEBUG ) cat ("\nunreserved.cond.score.median = ", unreserved.cond.score.median)
    
# Managed condition score     -----------
if( DEBUG ) cat ("\n---------------------\n")
managed.cond.score.sum <- sum (cur.cond.map [indices.of.managed])
if( DEBUG ) cat ("\nmanaged.cond.score.sum = ", managed.cond.score.sum)

managed.cond.score.mean <- mean (cur.cond.map [indices.of.managed])
if( DEBUG ) cat ("\nmanaged.cond.score.mean = ", managed.cond.score.mean)

managed.cond.score.median <- median (cur.cond.map [indices.of.managed])
if( DEBUG ) cat ("\nmanaged.cond.score.median = ", managed.cond.score.median)

# Unmanaged condition score     -----------


if( file.exists( cur.manag.pu.file.name ) ) {
  if( DEBUG ) cat ("\n---------------------\n")

  unmanaged.cond.score.sum <- sum (cur.cond.map [indices.of.unmanaged])
  if( DEBUG ) cat ("\nunmanaged.cond.score.sum = ", unmanaged.cond.score.sum)

  unmanaged.cond.score.mean <- mean (cur.cond.map [indices.of.unmanaged])
  if( DEBUG ) cat ("\nunmanaged.cond.score.mean = ", unmanaged.cond.score.mean)

  unmanaged.cond.score.median <- median (cur.cond.map [indices.of.unmanaged])
  if( DEBUG ) cat ("\nunmanaged.cond.score.median = ", unmanaged.cond.score.median)

} else {

  unmanaged.cond.score.sum <- 0
  unmanaged.cond.score.mean <- 0
  unmanaged.cond.score.median <- 0

}


if( DEBUG ) cat ("\n---------------------\n")

dev.pool.cond.score.sum <- sum (cur.cond.map [indices.of.dev.pool])
if( DEBUG ) cat ("\ndev.pool.cond.score.sum = ", dev.pool.cond.score.sum )

dev.pool.cond.score.mean <- mean (cur.cond.map [indices.of.dev.pool])
if( DEBUG ) cat ("\ndev.pool.cond.score.mean = ", dev.pool.cond.score.mean )

dev.pool.cond.score.median <- median (cur.cond.map [indices.of.dev.pool])
if( DEBUG ) cat ("\ndev.pool.cond.score.median = ", dev.pool.cond.score.median )

if( DEBUG ) cat ("\n---------------------\n")

offset.pool.cond.score.sum <- sum (cur.cond.map [indices.of.offset.pool])
if( DEBUG ) cat ("\noffset.pool.cond.score.sum = ", offset.pool.cond.score.sum )

offset.pool.cond.score.mean <- mean (cur.cond.map [indices.of.offset.pool])
if( DEBUG ) cat ("\noffset.pool.cond.score.mean = ", offset.pool.cond.score.mean )

offset.pool.cond.score.median <- median (cur.cond.map[indices.of.offset.pool])
if( DEBUG ) cat ("\noffset.pool.cond.score.median = ", offset.pool.cond.score.median )

    #---------------------------------------------------
    #  Now work out the number of pixels of habit above and below the
    #  threshold
    #---------------------------------------------------

ind.above.thresh <- which( cur.cond.map > PAR.grassland.threshold.value )
ind.below.thresh <- which( cur.cond.map <= PAR.grassland.threshold.value
                          & cur.cond.map > 0 )

summed.cond.above.thresh <- sum(cur.cond.map [ind.above.thresh])
summed.cond.below.thresh <- sum (cur.cond.map [ind.below.thresh])
mean.cond.above.thresh   <- mean(cur.cond.map [ind.above.thresh])
mean.cond.below.thresh   <- mean(cur.cond.map [ind.below.thresh])
median.cond.above.thresh <- median(cur.cond.map [ind.above.thresh])
median.cond.below.thresh <- median(cur.cond.map [ind.below.thresh])
sd.cond.above.thresh     <- sd(cur.cond.map [ind.above.thresh])
sd.cond.below.thresh     <- sd (cur.cond.map [ind.below.thresh])

if( DEBUG ) cat ("\n---------------------\n")
if( DEBUG ) cat ("\n")

landscape.cond.vec <- c(current.time.step, 
                        total.cond.score.sum,
                        total.cond.score.mean,
                        total.cond.score.median, 
                        reserved.cond.score.sum,
                        reserved.cond.score.mean,
                        reserved.cond.score.median, 
                        unreserved.cond.score.sum,
                        unreserved.cond.score.mean,
                        unreserved.cond.score.median,
                        managed.cond.score.sum,
                        managed.cond.score.mean,
                        managed.cond.score.median, 
                        unmanaged.cond.score.sum,
                        unmanaged.cond.score.mean,
                        unmanaged.cond.score.median,
                        summed.cond.above.thresh,
                        summed.cond.below.thresh,
                        mean.cond.above.thresh,
                        mean.cond.below.thresh, 
                        median.cond.above.thresh, 
                        median.cond.below.thresh,
                        sd.cond.above.thresh,
                        sd.cond.below.thresh,
                        dev.pool.cond.score.sum,
                        dev.pool.cond.score.mean,
                        dev.pool.cond.score.median,
                        offset.pool.cond.score.sum,
                        offset.pool.cond.score.mean,
                        offset.pool.cond.score.median
                        )

# round the numbers to 5 decimal places
landscape.cond.vec <- round(landscape.cond.vec, 5)

col.names <- c( 'TIME_STEP',
               'TOTAL_COND_SCORE_SUM',
               'TOTAL_COND_SCORE_MEAN',
               'TOTAL_COND_SCORE_MEDIAN', 
               'RESERVED_COND_SCORE_SUM',
               'RESERVED_COND_SCORE_MEAN',
               'RESERVED_COND_SCORE_MEDIAN', 
               'UNRESERVED_COND_SCORE_SUM',
               'UNRESERVED_COND_SCORE_MEAN',
               'UNRESERVED_COND_SCORE_MEDIAN',
               'MANAGED_COND_SCORE_SUM',
               'MANAGED_COND_SCORE_MEAN',
               'MANAGED_COND_SCORE_MEDIAN', 
               'UNMANAGED_COND_SCORE_SUM',
               'UNMANAGED_COND_SCORE_MEAN',
               'UNMANAGED_COND_SCORE_MEDIAN',
               'SUMMED_COND_ABOVE_THRESH',
               'SUMMED_COND_BELOW_THRESH',
               'MEAN_COND_ABOVE_THRESH',
               'MEAN_COND_BELOW_THRESH',
               'MEDIAN_COND_ABOVE_THRESH',
               'MEDIAN_COND_BELOW_THRESH',
               'SD_COND_ABOVE_THRESH',
               'SD_COND_BELOW_THRESH',
               'DEV_POOL_COND_SCORE_SUM',
               'DEV_POOL_COND_SCORE_MEAN',
               'DEV_POOL_COND_SCORE_MEDIAN',
               'OFFSET_POOL_COND_SCORE_SUM',
               'OFFSET_POOL_COND_SCORE_MEAN',
               'OFFSET_POOL_COND_SCORE_MEDIAN'
               )

landscape.cond.data.frame <- data.frame( t(landscape.cond.vec) )

colnames( landscape.cond.data.frame ) <- col.names

connect.to.database( CondDBname )

write.data.to.db( LandscapeCondTableName, landscape.cond.data.frame )

close.database.connection()

#=============================================================================
