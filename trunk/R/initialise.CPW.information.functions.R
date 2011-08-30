

#   initialise.CPW.information.functions.R
#
#  Create 2/12/2010 - AG.

# source( 'initialise.CPW.information.functions.R' )

library( msm )                                            # needed for rtnorm()
source( "GIS.utility.functions.R" )

    #------------------------------------------------------------------
    #  Loop through each of the PUs and calculate the condition 
    #  scores for each planning unit. The store this
    #  
    #------------------------------------------------------------------

initialise.using.CPW.info.from.shapefile <- function() {

  #PAR.PU.information.shapefile <- "/Users/ascelin/analysis/gis_data/CPW/4th_dataset/cpw_cadastre_FINAL_13jan.shp"

  PU.att.df <-
    extract.shape.file.attribute.table.to.data.frame( PAR.PU.information.shapefile )


  # Make any NAs that occur in the undev.land column are set to zero
  # (or else this causes probles when writing to the sql db
  PU.att.df$undev_land[ which(is.na(PU.att.df$undev_land) ) ] <- 0
  
  no.entries <- length(PU.att.df$CAD_GEOM_P)
  
   if( Debug.Test.With.given.num.of.PUs ) {
     num.to.extract <- Debug.Num.of.PUs.to.test.with
   } else {
     num.to.extract <- no.entries
   }

  
  # Code for debugging
  #subset.dev.in.GC <- subset( PU.att.df, growth_cen == 1 & gc_cert ==1 & undev_land==0 )
  #subset.dev.in.GC <- subset( PU.att.df, growth_cen == 1 & gc_cert ==1 & undev_land==0  & is.na(tenure) )
  #subset.dev.in.GC <- subset( PU.att.df, growth_cen == 1 & gc_cert ==1 & undev_land==0  & is.na(tenure) )
  #sum(subset.dev.in.GC$hmv_cpw)
  #sum(PU.att.df$total_cpw)
  #browser()

  # Update the CPW info
  
  pu.ids.vec <- as.numeric( as.vector( PU.att.df$CAD_GEOM_P[1:num.to.extract] ) )
  area.CPW <- as.numeric( as.vector( PU.att.df$total_cpw[1:num.to.extract] ) )
  area.HMV.CPW <- as.numeric( as.vector( PU.att.df$hmv_cpw[1:num.to.extract] ) )
  area.MMV.CPW <- as.numeric( as.vector( PU.att.df$mmv_cpw[1:num.to.extract] ) )
  area.LMV.CPW <- as.numeric( as.vector( PU.att.df$lmv_cpw[1:num.to.extract] ) )

  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'AREA_OF_CPW',
                                          area.CPW)
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName,'AREA_OF_C1_CPW',
                                          area.HMV.CPW)
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName,'AREA_OF_C2_CPW',
                                          area.MMV.CPW)
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName,'AREA_OF_C3_CPW',
                                          area.LMV.CPW)

  
  # Now we need a category to record the condition change of [H,M,L]MM CPW. This will
  # be given initial values based on CPW score, but this can then evolve 
  # into different condition categories. This I've called them c1, c2, c3 instead of
  # HMV, MMV, LMV.  
  
  c1.CPW.cond <- rep(0, length(area.HMV.CPW))
  c2.CPW.cond <- rep(0, length(area.MMV.CPW))
  c3.CPW.cond <- rep(0, length(area.LMV.CPW))


  # ---------

  # Create error model classes

    ## unif.em.HMV <- new ("ErrorModel.201", em.error.min = 0.7, em.error.max = 1.0)
  ## unif.em.MMV <- new ("ErrorModel.201", em.error.min = 0.3, em.error.max = 0.8)
  ## unif.em.LMV <- new ("ErrorModel.201", em.error.min = 0, em.error.max = 0.6)

  ## # An example of using a normal distriution ( the 300 class)
  ## norm.em.HMV <- new ("ErrorModel.301", em.mean = 0.8, em.sd = 0.1)
  ## norm.em.MMV <- new ("ErrorModel.301", em.mean = 0.5, em.sd = 0.2)
  ## norm.em.LMV <- new ("ErrorModel.301", em.mean = 0.2, em.sd = 0.3)
  # ---------

  #ret.value <- rtnorm (length(which(area.HMV.CPW > 0 )), PAR.init.cond.of.HMV.CPW, 0.1, 0, 1)
  HMV.init.vals <-
    rtnorm (length(which(area.HMV.CPW > 0)), PAR.mean.init.cond.of.HMV.CPW,PAR.sd.init.cond.of.HMV.CPW,0,1)
  MMV.init.vals <-
    rtnorm (length(which(area.MMV.CPW > 0)), PAR.mean.init.cond.of.MMV.CPW,PAR.sd.init.cond.of.MMV.CPW,0,1)
  LMV.init.vals <-
    rtnorm (length(which(area.LMV.CPW > 0)), PAR.mean.init.cond.of.LMV.CPW,PAR.sd.init.cond.of.LMV.CPW,0,1)

  
  c1.CPW.cond[ which(area.HMV.CPW > 0 ) ] <- HMV.init.vals
  c2.CPW.cond[ which(area.MMV.CPW > 0 ) ] <- MMV.init.vals
  c3.CPW.cond[ which(area.LMV.CPW > 0 ) ] <- LMV.init.vals

  par(mfrow=c(2,2))
  hist(HMV.init.vals, xlim=c(0,1))
  hist(MMV.init.vals, xlim=c(0,1))
  hist(LMV.init.vals, xlim=c(0,1))
       
  browser()
  # store these values as a dataframe to be accessed by other bits of R code
  CPW.init.vals <- data.frame( c1.init.vals=c1.CPW.cond, c2.init.vals=c2.CPW.cond, C3.init.vals=c3.CPW.cond )
  
  dump( "CPW.init.vals", file = PAR.init.CPW.score.filename )

  
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'SCORE_OF_C1_CPW',
                                          c1.CPW.cond)
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'SCORE_OF_C2_CPW',
                                          c2.CPW.cond)
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'SCORE_OF_C3_CPW',
                                          c3.CPW.cond)

  # Update the other info such as whether in growth center, whether
  # certified and whether Secured, protected or unsecured

  # GROWTH_CEN = presence in a growth centre (1 =True)
  
  growth.cen <- as.numeric( as.vector( PU.att.df$growth_cen[1:num.to.extract] ) )
  gc.notcert <- as.numeric( as.vector( PU.att.df$gc_notcert[1:num.to.extract] ) )
  gc.cert <- as.numeric( as.vector( PU.att.df$gc_cert[1:num.to.extract] ) )
  priority <- as.numeric( as.vector( PU.att.df$priority[1:num.to.extract] ) )
  tenure <- as.vector( PU.att.df$tenure[1:num.to.extract] )

  undev.land <- as.numeric( as.vector( PU.att.df$undev_land[1:num.to.extract] ) )

  # for the tenure we want to make the NA entires be unprotected
  indices.of.nas <- which( is.na(tenure) )
  old.tenure <- tenure
  tenure[indices.of.nas] <- "Unprotected"


  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'GROWTH_CENTRE',
                                          growth.cen)
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'GC_CERT',
                                          gc.cert)
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'GC_NOTCERT',
                                           gc.notcert )
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'PRIORITY',
                                          priority)
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'UNDEV_LAND',
                                          undev.land)
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'TENURE',
                                          tenure)

  # Mark all parcels with tenure = Protected, as reserved and managed
  # in the database. Note assuming that nothing is marked managed or
  # reserved as yet (ie reserved and managed have been initialised to
  # zero for all parcels)

  protected.indices <- which( tenure == "Protected")

  
  gc.notcert.indices <- which( gc.notcert == 1 )
  undev.land.indices <- which( undev.land == 1 )

  managed.vec <- reserved.vec <- rep( 0, num.to.extract )
  time.reserved.vec <- rep( -999, num.to.extract )

  # set all the protected areas to be both reserved and managed 
  reserved.vec[protected.indices] <- 1
  managed.vec[protected.indices] <- 1
  time.reserved.vec[protected.indices] <- 0


  # Commenting out this section for now as will be getting further
  # info from the feds re which not cert areas are aviable for offsets
  # and which should be just dead land that can't be developed of
  # offset, and so just sits there and degrades.
  
  ## set all the non cert areas in the growth centre to be reserved and NOT managed 
  ## reserved.vec[gc.notcert.indices] <- 1
  ## time.reserved.vec[gc.notcert.indices] <- 0
  ## update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'RESERVED',
  ##                                         reserved.vec)
  ## update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'MANAGED',
  ##                                         managed.vec)
  ## update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'TIME_RESERVED',
  ##                                         time.reserved.vec)
  
  # set all the parcels in the growth centre with UNDEV_LAND=1 to be reserved and NOT managed 
  reserved.vec[undev.land.indices] <- 1
  time.reserved.vec[undev.land.indices] <- 0
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'RESERVED',
                                          reserved.vec)
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'MANAGED',
                                          managed.vec)
  update.column.in.db.table.via.dataframe(dynamicPUinfoTableName, 'TIME_RESERVED',
                                          time.reserved.vec)



  if( OPT.set.shanes.park.as.offsettable ) {

    # Set Shanes Park to be Offsettable and NOT government land.
    
    connect.to.database (PUinformationDBname)
    
    PAR.shanes.park.PU.id : 100138120
    query <- paste ( 'update ', dynamicPUinfoTableName,
                    'set RESERVED=0, DEVELOPED=0, TENURE="Unprotected", UNDEV_LAND=0,',
                    'GC_CERT=0, GC_NOTCERT=1',
                    'where ID =', PAR.shanes.park.PU.id)
    sql.send.operation (query)


    close.database.connection ()

  }

  
}

test.initialise.using.grassland.map.and.PUs <- function() {
  cur.cond.map.filename <- paste( master.habitat.map.zo1.base.filename, '.txt', sep = '')

  cur.cond.map <- as.matrix (read.table (cur.cond.map.filename))

  pu.map <- as.matrix ( read.table( planning.units.filename  ) )

  plan.units.vec <- get.unique.ids.from.map( planning.units.filename,
                                            non.habitat.indicator )

  if( Debug.Test.With.given.num.of.PUs ) {
    plan.units.vec <- plan.units.vec[1:Debug.Num.of.PUs.to.test.with]
  }


  # make a data.frame to store the results for each pu

  col.names <- c( 'TIME_STEP', 'ID', 'AREA', 'COST', 'AREA_OF_GRASSLAND',
                 'MANAGEMENT_COST', 'TOTAL_COND_SCORE_SUM',
                 'TOTAL_COND_SCORE_MEAN', 'TOTAL_COND_SCORE_MEDIAN',
                 'TOTAL_COND_SCORE_SD', 'RESERVED',
                 'DEVELOPED', 'LEAKED', 'IN_DEV_POOL', 'IN_OFFSET_POOL',
                 'OFFSET_INTO_PU' );

  PU.cond.data.frame <- data.frame( matrix( nrow = length(plan.units.vec),
                                          ncol = length(col.names) ) )
  colnames(PU.cond.data.frame) <- col.names;


  ctr <- 0;
  for( cur.pu in plan.units.vec ){

    ctr <- ctr + 1;
  
    indices.of.pixels.in.cur.pu <- which (pu.map == cur.pu);
  
    # work out the number of pixels in the current PU
    num.pixels.in.cur.pu <- length( indices.of.pixels.in.cur.pu );

    # the condition scores of all the pixels in the PU
    cur.pixel.cond.scores <- cur.cond.map[indices.of.pixels.in.cur.pu]

    # calculate statistics for the PU condition scores
    pu.cond.score.sum <- sum( cur.pixel.cond.scores );
    pu.cond.score.mean <- mean( cur.pixel.cond.scores );
    pu.cond.score.median <- median( cur.pixel.cond.scores );
    pu.cond.score.sd <- sd( cur.pixel.cond.scores );
    pu.num.pixels.grassland <- length( which( cur.pixel.cond.scores > 0 ));
    pu.managment.cost <- PAR.management.cost.per.pixel * pu.num.pixels.grassland;
  
    if(DEBUG)  cat( '\nPU num:', ctr, ' PU id:', cur.pu,
                   '\n    num pixels =', num.pixels.in.cur.pu,
                   '\n    cond score sum  =', pu.cond.score.sum,
                   '\n    cond score mean  =', pu.cond.score.mean,
                   '\n    cond score median  =', pu.cond.score.median,
                   '\n    cond score sd  =', pu.cond.score.sd,
                   '\n' );
    
    query <- paste( "select COST, RESERVED, DEVELOPED, LEAKED, IN_DEV_POOL,",
                   "IN_OFFSET_POOL, OFFSET_INTO_PU from", dynamicPUinfoTableName,
                   "where ID = ", cur.pu );
    cur.PU.info <- sql.get.data(PUinformationDBname , query);
    
    # Need the following format
  
    # 'TIME_STEP', 'ID', 'AREA', 'COST', 'AREA_OF_GRASSLAND',
    # 'MANAGEMENT_COST', 'TOTAL_COND_SCORE_SUM',
    # 'TOTAL_COND_SCORE_MEAN', 'TOTAL_COND_SCORE_MEDIAN',
    # 'TOTAL_COND_SCORE_SD' 'RESERVED' 'DEVELOPED' 'LEAKED'
    # 'IN_DEV_POOL' 'IN_OFFSET_POOL' 'OFFSET_INTO_PU'

    summary.PU.cond.vector <- c(current.time.step, 
                                cur.pu,
                                num.pixels.in.cur.pu,
                                cur.PU.info$COST,
                                pu.num.pixels.grassland,
                                pu.managment.cost,
                                pu.cond.score.sum, 
                                pu.cond.score.mean,
                                pu.cond.score.median, 
                                pu.cond.score.sd,
                                cur.PU.info$RESERVED,
                                cur.PU.info$DEVELOPED,
                                cur.PU.info$LEAKED,
                                cur.PU.info$IN_DEV_POOL,
                                cur.PU.info$IN_OFFSET_POOL,
                                cur.PU.info$OFFSET_INTO_PU
                                )

  
    PU.cond.data.frame[ctr,] <- summary.PU.cond.vector;
  }
  
 
    #------------------------------------------------------------------
    #  Now upate the PUinformation.dbms file that keeps track of all the 
    #  current info for each planning unit.
    #  
    #------------------------------------------------------------------


  # save the resulst to the database

  connect.to.database( CondDBname );
  write.data.to.db(  PUcondTableName, PU.cond.data.frame )

  close.database.connection();


  # save the total cond score

  pu.id.tot.pixels.grassland <-
    cbind( plan.units.vec, PU.cond.data.frame$AREA_OF_GRASSLAND );

  update.db.pu.ids.with.multiple.values(dynamicPUinfoTableName,
                                        pu.id.tot.pixels.grassland,
                                        'AREA_OF_GRASSLAND')
  pu.managment.cost.vec <-
    cbind( plan.units.vec, PU.cond.data.frame$MANAGEMENT_COST);
  
  update.db.pu.ids.with.multiple.values(dynamicPUinfoTableName,
                                        pu.managment.cost.vec,
                                        'MANAGEMENT_COST')

  pu.id.tot.cond <-
    cbind( plan.units.vec, PU.cond.data.frame$TOTAL_COND_SCORE_SUM );

  update.db.pu.ids.with.multiple.values(dynamicPUinfoTableName,
                                        pu.id.tot.cond, 'TOTAL_COND_SCORE_SUM' );
  

  pu.id.mean.cond <-
    cbind( plan.units.vec, PU.cond.data.frame$TOTAL_COND_SCORE_MEAN );

  update.db.pu.ids.with.multiple.values(dynamicPUinfoTableName,pu.id.mean.cond,
                                        'TOTAL_COND_SCORE_MEAN' );

  pu.id.median.cond <-
    cbind( plan.units.vec, PU.cond.data.frame$TOTAL_COND_SCORE_MEDIAN );
  
  update.db.pu.ids.with.multiple.values(dynamicPUinfoTableName,pu.id.median.cond,
                                        'TOTAL_COND_SCORE_MEDIAN' );


  # note that PUs with area of 1 pixel will have a SD of NA as taking the SD of
  # a single value is undefined.

  pu.id.sd.cond <-
    cbind( plan.units.vec, PU.cond.data.frame$TOTAL_COND_SCORE_SD );
  update.db.pu.ids.with.multiple.values(dynamicPUinfoTableName,pu.id.sd.cond,
                                        'TOTAL_COND_SCORE_SD' )
  
} 

#-----------------------------------------------------------------------------------
