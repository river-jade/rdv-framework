#==============================================================================

#source( 'initialize.offset.test.R' );

# During testing, clear all R objects from memory, but remove this after that.
rm( list = ls( all=TRUE ));

#------------------------------------------------------------------------
#  These are set in calling source('dbms.initialise.R')
#  routine, but resetting here just for testing.
#  Get rid of this when you are no longer running this file standalone.

DEBUGGING.DBMS <<- FALSE;

source('variables.R');
source('dbms.initialise.R');

#------------------------------------------------------------------------

    #-------------------------------------------------------------------
    #  Here are the definitions of the tables as they are initialized in
    #  dbms.initialise.R.
    #  They're just here for reference so that you get the column names
    #  right.
    #-------------------------------------------------------------------

####  table.defn.dynamic <- matrix( c(
####                       'ID', 'int',
####                       'COST', 'float',
####                       'RESERVED', 'int',
####                       'TIME_RESERVED', 'int',
####                       'RES_EXPIRY_TIME', 'int',
####                       'PROB_RES_EXPIRING_PER_TIMESTEP', 'float',
####                       'LANDUSE', 'char(60)',
####                       'LANDUSE_CHANGE_TIME', 'int',
####                       'DEVELOPED', 'int',
####                       'IN_DEV_POOL', 'int',
####                       'IN_OFFSET_POOL', 'int',
####                       'TOTAL_COND_SCORE_SUM', 'float', 
####                       'TOTAL_HH_SCORE_SUM', 'float'
####                       ),
####                    byrow = TRUE,
####                    ncol = 2 );

####  table.defn.static <- matrix( c(
####                       'ID', 'int',
####                       'AREA', 'float',
####                       'BOUNDARY_LENGTH', 'float',
####                       'EDGE_TO_AREA_RATIO', 'float'
####                       ),
####                    byrow = TRUE,
####                    ncol = 2 );

#==============================================================================

test.seed.value <- 23;
set.seed (test.seed.value);

#==============================================================================

##AG.OPT.draw.offsets.from.same.pool.as.development <- TRUE;
AG2.OPT.leak.offsets.outside.study.area <- TRUE;
AG2.OPT.offset.leakage.prob <- 0.5;

AG2.OPT.do.strategic.offsetting <- FALSE;

test.seed.value <- 23;
set.seed (test.seed.value);

AG2.num.units.in.test <- 10;
##AG.units.eligible.for.loss <- sample (1:(AG.num.units.in.test + 2),
####AG.units.eligible.for.loss <- sample (1:AG.num.units.in.test, 
####                                      AG.num.units.in.test,
####                                      replace = FALSE);
####AG.num.PU.IDs <- max (AG.units.eligible.for.loss);
AG2.num.PU.IDs <- AG2.num.units.in.test;

    #------------------------------------------------------------------
    #  Load the PU IDs into both the static and dynamic PU info tables.
    #------------------------------------------------------------------

pu.ids.vec <- 1:AG2.num.PU.IDs;

insert.pu.ids.to.db (staticPUinfoTableName, pu.ids.vec, 'ID');
insert.pu.ids.to.db (dynamicPUinfoTableName, pu.ids.vec, 'ID');

    #-------------------------------------------------------------------
    #  Load the static data for the PUs.
    #  For the offset test, the only static values other than the PU IDs
    #  are the AREAs.
    #-------------------------------------------------------------------

AG2.pu.areas <- sample (1:500, AG2.num.PU.IDs, replace = TRUE);

pu.ids.and.areas.matrix <- cbind (pu.ids.vec, AG2.pu.areas);
####insert.pu.id.and.value.to.db (staticPUinfoTableName,
update.db.pu.ids.with.multiple.values (staticPUinfoTableName,
                                       pu.ids.and.areas.matrix,
                                       'AREA');

    #-------------------------------------------------------------------
    #  Load the dynamic data for the PUs.
    #  Need to load the PU IDs here as well.
    #-------------------------------------------------------------------

    #-------------------------------
    #  Mark all PUs as not reserved.
    #-------------------------------

##AG.pu.is.protected <- rep (0, AG.num.PU.IDs);

update.db.pu.ids.with.single.value (dynamicPUinfoTableName,
                                    pu.ids.vec, 0, 'RESERVED' );

    #------------------------------------
    #  Mark all PUs as being undeveloped.
    #------------------------------------

##AG.pu.is.developed <- rep (0, AG.num.PU.IDs);

update.db.pu.ids.with.single.value (dynamicPUinfoTableName,
                                    pu.ids.vec, 0, 'DEVELOPED' );

    #------------------------------------------------
    #  Mark all PUs as being in the development pool.
    #------------------------------------------------

##AG.pu.is.in.dev.pool <- rep (1, AG.num.PU.IDs);

update.db.pu.ids.with.single.value (dynamicPUinfoTableName,
                                    pu.ids.vec, 1, 'IN_DEV_POOL' );

    #-------------------------------------------
    #  Mark all PUs as being in the offset pool.
    #-------------------------------------------

##AG.pu.is.in.offset.pool <- rep (1, AG.num.PU.IDs);

update.db.pu.ids.with.single.value (dynamicPUinfoTableName,
                                    pu.ids.vec, 1, 'IN_OFFSET_POOL' );

    #----------------------------------------
    #  Give each PU a random condition score.
    #----------------------------------------

AG2.pu.cond.scores <- runif (AG2.num.PU.IDs);

        #---------------------------------------------------
        #  Because the scores are aggregated across the PU,
        #  first draw an average score for the PU and then
        #  multiply it by the area of the PU.
        #  This will give scores that are more like the real
        #  scores.
        #---------------------------------------------------

random.tot.scores <-
    pu.ids.and.areas.matrix [,2] * AG2.pu.cond.scores;
pu.ids.and.random.cond.scores <- cbind (pu.ids.vec, random.tot.scores);

update.db.pu.ids.with.multiple.values (dynamicPUinfoTableName,
                                       pu.ids.and.random.cond.scores,
                                       "TOTAL_COND_SCORE_SUM");

    #-----------------------------
    #  Give each PU a random cost.
    #-----------------------------

AG2.pu.costs <- 100.0 * runif (AG2.num.PU.IDs);

pu.ids.and.random.costs <- cbind (pu.ids.vec, AG2.pu.costs);
update.db.pu.ids.with.multiple.values (dynamicPUinfoTableName,
                                       pu.ids.and.random.costs,
                                       "COST");

    #------------------------------------------------------------------------
    #  Initially give each PU an HH score that is the same as its cond score,
    #  i.e., no error in the HH score.
    #------------------------------------------------------------------------

AG2.pu.HH.scores <- random.tot.scores;
pu.ids.and.HH.scores <- cbind (pu.ids.vec, AG2.pu.HH.scores);
update.db.pu.ids.with.multiple.values (dynamicPUinfoTableName,
                                       pu.ids.and.random.cond.scores,
                                       "TOTAL_HH_SCORE_SUM");

####AG.pu.data <- cbind (pu.ids.vec,
####                     AG.pu.is.in.dev.pool,
####                     AG.pu.is.in.offset.pool,
####                     AG.pu.is.developed,
####                     AG.pu.is.protected,
####                     AG.pu.costs,
####                     AG.pu.areas,
####                     AG.pu.cond.scores,
####                     AG.pu.HH.scores);



#==============================================================================

