#==============================================================================

# source( 'offset.model.R' );

#  HISTORY:

#      BTL - Nov 11, 2009
#      Modified some calls related to uncertainty of assessment.
#      Replaced call to get.neutral...() with calls to get the
#      developer and offset seller variants of the assessment.
#      Still haven't added the code to add the uncertainty to them yet though.
#      The changes that I've added today should mean that there is no
#      difference in the outcomes of the program since everything is still
#      using the neutral value despite all of the renaming.
#      All I've done today is effectively to flag where the changes are
#      going to happen when we do (carefully) add the uncertainty.

#==============================================================================

    #------------------------------------------------------
    #  Temporary actions just for testing standalone before
    #  incorporating in framework.
    #  BTL - 2009.07.25
    #------------------------------------------------------

#rm (list = ls());
#source( 'initialize.offset.test.R' );
#current.time.step <- 1;

#==============================================================================
#==============================================================================

    #--------------------------------
    #  Extra code for debugging only.
    #--------------------------------

#==============================================================================

    #---------------------------------------------------------------
    #  Create counters for different branches of the code so that
    #  you can see if every branch gets exercised in testing.
    #  These counters just get bumped each time the specified region
    #  is entered.
    #  This stuff can be removed once we know that everything is
    #  behaving correctly.
    #  BTL - 2009.07.23
    #---------------------------------------------------------------

DEBUG <<- TRUE;

if (DEBUG) {
    max.num.cases <- 7;
    test.case.cts <- rep (0,max.num.cases);

    # counters for the hh score for each PU developed/offset
    net.development.score <- 0;
    excess.offset.score <- 0;
    overflow <<- 0;

}

count.test.case <- function (case.num)
  {
      test.case.cts [case.num] <<-
          test.case.cts [case.num] + 1;
  }

#==============================================================================
#==============================================================================

    #  Things that still need to be done somewhere:

    #  - Initialize values of new db fields related to partial offsets
    #      - MANAGED = 0

    #  - Need to change initialization of PU costs to be less random
    #    since the partial offset code will now eliminate the reason
    #    for using totally random costs (i.e., forcing the selection of
    #    at least some large patches)
    #    May want to go to storing a cost per square meter instead of
    #    a total cost.

#==============================================================================

    #-----------------------------------------------------------------------
    #  Load all of the variables and database tables for standalone testing.
    #  This will be removed after standalone testing is done.
    #-----------------------------------------------------------------------

#source( 'initialize.offset.test.R' );

source( 'dbms.functions.R' )  
#source( 'offset.model.variables.R' )


if (DEBUG) cat ("\n\n********  STARTING offset model  ************\n\n");


#==============================================================================

    #------------
    #  Constants.
    #------------

            #------------------------------------------------
            #  Is there already a constant like this defined?
            #  BTL - 2009.05.31
            #------------------------------------------------
CONST.UNINITIALIZED.PU.ID.VALUE <- -999;


available.for.dev.criteria <- paste (' DEVELOPED = 0 ',
                                     ' and RESERVED = 0 ', 
                                     ' and IN_DEV_POOL = 1 '
                                     );
  
available.for.offset.criteria <- paste (' DEVELOPED = 0 ',
                                        ' and RESERVED = 0 ',
                                        ' and IN_OFFSET_POOL = 1 ',
                                        ' and NEUTRAL_ASSESSED_TOTAL_HH_SCORE_SUM > 0 '
                                        );

#==============================================================================

    #------------------------------------------------------------------
    #  User options and parameters.
    #
    #  These are set in offset.variables.R, which is currently built by
    #  the python code (2009.07.25).
    #------------------------------------------------------------------

#OPT.partial.offsets.allowed <- TRUE;

#OPT.leak.offsets.outside.study.area <- FALSE;
#OPT.offset.leakage.prob <- 0.2;

#OPT.do.strategic.offsetting <- FALSE;
    
            #------------------------------------------------------------
            #  Regarding the offset multiplier to use:
            #      (from Ascelin's email to Bill on 13/05/2009)
            #
            #  after chatting with James a little more, it seems that the
            #  random offset scenario should be modeled as follows:
            #
            #  for every pixel lost to development inside the new UGB,
            #      pick N pixels randomly outside the new UGB that
            #      each have equal or greater condition.
            #          N = 3.5 for a private land offset
            #          N = 2.5 "reserved" offset
            #------------------------------------------------------------

#OPT.private.offset.multiplier <- 3.5;
#OPT.strategic.offset.multiplier <- 2.5;

#==============================================================================

    #---------------------------------------------------------------------
    #  Working variable initialization.
    #
    #  The global variables here need to be replaced by database entries
    #  so that they survive between repeated calls to the R code by
    #  the python controller.  Otherwise, their values are lost between
    #  time steps of the framework.
    #---------------------------------------------------------------------

tot.strategic.offset.score.non.leakage <<- 0.0;

tot.non.strategic.offset.score.leakage <<- 0.0;
tot.non.strategic.offset.score.non.leakage <<- 0.0;

more.development.allowed <<- TRUE;

#==============================================================================

get.global.values.for.any.active.partial.offset <- function ()
  {
  query <- paste ('select ',
                  'PARTIAL_OFFSET_IS_ACTIVE ',
                  ' from ',
                  offsettingWorkingVarsTableName);
  partial.offset.is.active <<- sql.get.data (PUinformationDBname, query);

      #----------
  
  query <- paste ('select ',
                  'PARTIAL_OFFSET_PU_ID ',
                  ' from ',
                  offsettingWorkingVarsTableName);
  partial.offset.PU.ID <<- sql.get.data (PUinformationDBname, query);

      #----------
  
  query <- paste ('select ',
                  'PARTIAL_OFFSET_SUM_SCORE_REMAINING ',
                  ' from ',
                  offsettingWorkingVarsTableName);
  partial.offset.sum.score.remaining <<- sql.get.data (PUinformationDBname,
                                                       query);
  }

#==============================================================================

partial.offset.is.active <<- FALSE;
partial.offset.PU.ID <<- CONST.UNINITIALIZED.PU.ID.VALUE;
partial.offset.sum.score.remaining <<- 0.0;

get.global.values.for.any.active.partial.offset ();



#==============================================================================
#==============================================================================

                  #-----------------------------------
                  #  Utility functions for offsetting.
                  #-----------------------------------

#==============================================================================
#==============================================================================

save.running.totals <- function ()
  {
  offsetting.globals.vec <- c (current.time.step,
                               tot.strategic.offset.score.non.leakage,
                               tot.non.strategic.offset.score.leakage,
                               tot.non.strategic.offset.score.non.leakage
                               );
  
          #----------------------------------------
          #  Round the numbers to 5 decimal places.
          #----------------------------------------  
  
  offsetting.globals.vec <- round (offsetting.globals.vec, 5);


  globals.col.names <- c ('TIME_STEP',
                          'TOT_STRATEGIC_OFFSET_SCORE_NON_LEAKAGE',
                          'TOT_NON_STRATEGIC_OFFSET_SCORE_LEAKAGE',
                          'TOT_NON_STRATEGIC_OFFSET_SCORE_NON_LEAKAGE'
                          );
  
  offsetting.globals.data.frame <- data.frame( t(offsetting.globals.vec) );
#  globals.colnames( offsetting.globals.data.frame ) <- globals.col.names;
  colnames( offsetting.globals.data.frame ) <- globals.col.names;

##  connect.to.database( PUinformationDBname );
  connect.to.database( CondDBname );  
  write.data.to.db( offsettingGlobalsTableName, offsetting.globals.data.frame )
  close.database.connection();
}

#-----------------------------------------------------------------------------

save.offsetting.global.variables <- function ()
  {
      #--------------------------------    
      #  Save the running totals first.
      #--------------------------------

  save.running.totals ();
    
      #--------------------------------------------------------------
      #  Now save the information related to any open partial offset.
      #--------------------------------------------------------------
  
              #--------------------------------------------------------    
              #  Need to convert the boolean variable to an integer for
              #  storing in db.
              #--------------------------------------------------------
  
  if (partial.offset.is.active)
    {
    integer.partial.offset.is.active <- 1;
    } else
    {
    integer.partial.offset.is.active <- 0;
    }
  
  connect.to.database( PUinformationDBname );

      #----------------------------------------------------------
      #  Save flag indicating whether there is an active partial.
      #----------------------------------------------------------

  query <- paste ('update ', offsettingWorkingVarsTableName,
                  ' set ', 'PARTIAL_OFFSET_IS_ACTIVE', ' = ',
                  integer.partial.offset.is.active,
                  sep = '' );  
  sql.send.operation (query);

      #----------------------------
      #  Save ID of active partial.
      #----------------------------

  query <- paste ('update ', offsettingWorkingVarsTableName,
                  ' set ', 'PARTIAL_OFFSET_PU_ID', ' = ',
                  partial.offset.PU.ID,
                  sep = '' );
  sql.send.operation (query);

      #----------------------------------------------------------
      #  Save amount of offset still available in active partial.
      #----------------------------------------------------------

  query <- paste ('update ', offsettingWorkingVarsTableName,
                  ' set ', 'PARTIAL_OFFSET_SUM_SCORE_REMAINING', ' = ',
                  round (partial.offset.sum.score.remaining, 5),
                  sep = '' );  
  sql.send.operation (query);

      #-----
  
  close.database.connection();
}
  
#-----------------------------------------------------------------------------




    #-----------------------------------------------
    #  NOTE the global assignments here...
    #       This needs to change to a database call.
    #       BTL - 2009.07.12
    #-----------------------------------------------

#------------------------------------------------------------------------------

set.partial.offset.is.active <- function (newValue)
  { 
  partial.offset.is.active <<- newValue;
  }
get.partial.offset.is.active <- function ()
  {
  return (partial.offset.is.active);
  }

#------------------------------------------------------------------------------

set.partial.offset.PU.ID <- function (newValue)
  {
  partial.offset.PU.ID <<- newValue;
  }
get.partial.offset.PU.ID <- function ()
  {
  return (partial.offset.PU.ID);
  }

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

set.partial.offset.sum.score.remaining <- function (newValue)
  {
  partial.offset.sum.score.remaining <<- newValue;
  }

get.partial.offset.sum.score.remaining <- function ()
  {
  return (partial.offset.sum.score.remaining);
  }

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

close.active.partial.offset <- function ()
  {
      #  Close the active partial offset.
    
  set.partial.offset.is.active (FALSE);
  set.partial.offset.PU.ID (CONST.UNINITIALIZED.PU.ID.VALUE);
  set.partial.offset.sum.score.remaining (0.0);
  }

#------------------------------------------------------------------------------

open.new.active.partial.offset <- function (offset.PU.ID)
{
  set.partial.offset.is.active (TRUE);
  set.partial.offset.PU.ID (offset.PU.ID);

      #  Initially setting the amount remaining to be the assessed score
      #  for the whole offset patch.
      #  Not sure, but might want to have this be an argument passed in
      #  to this routine instead or just make this be the default...
  
      # ASSESSMENT UNCERTAINTY CHANGE
  if(OPT.use.assessment.uncertainty)
  {
    set.partial.offset.sum.score.remaining (
                      get.offset.seller.assessed.score.of.pu (offset.PU.ID)); 
  } else { 
    set.partial.offset.sum.score.remaining (    
                      get.neutral.assessed.score.of.pu (offset.PU.ID));                     
  }
}

#==============================================================================

set.PU.prob.res.expiring.per.time.step <-
    function (cur.offset.PU.ID, probResExpiringPerTimeStep)
  {
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         cur.offset.PU.ID,
                                         probResExpiringPerTimeStep,
                                         "PROB_RES_EXPIRING_PER_TIMESTEP");
  }
#==============================================================================

set.PU.prob.man.expiring.per.time.step <-
    function (cur.offset.PU.ID, probManExpiringPerTimeStep)
  {
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         cur.offset.PU.ID,
                                         probManExpiringPerTimeStep,
                                         "PROB_MAN_EXPIRING_PER_TIMESTEP");
  }

#==============================================================================

choose.offset.PU <- function (PU.to.develop)
  {
  #----------------------------------------------------------
  # Added as.list as a workaround - because R's 'sample' function (below) 
  #  will treat a  single integer 'x' as a vector from o:x, 
  #  ie not as a single object  - DWM, 17/09/2009 
  # -----------------------------------------------------------
  remaining.offset.candidate.PUs <- as.list( find.remaining.offsets(  
                                                          PU.to.develop ));
  if( DEBUG)
  {
    cat( "\n\n XXXXX  remaining.offset.candidate.PUs: ");
    print( remaining.offset.candidate.PUs );
    cat('\n');
  }
      #------------------------------------------------
      #  For now, just pick any of candidate at random.
      #  May want more complex rules for closer matches
      #  to development PU later.
      #------------------------------------------------
  
  # Check if the database returns an offset from the pool
  if( length(remaining.offset.candidate.PUs) != 0 )
  {
    offset.PU.ID <- sample.rdv( remaining.offset.candidate.PUs, 1 );
  } else {
    offset.PU.ID <- -99;
  }
  return (offset.PU.ID);
  }

#==============================================================================

    #------------------------------------------------------------------------
    #  ASSESSMENT UNCERTAINTY 
    #  This routine is where you probably need to insert code to add 
    #  uncertainty to the assessments of offset habitat hectares scores.
    #  Elsewhere, the routines for the offset seller's and the developer's
    #  assessments of the score assume that they are getting the overestimate
    #  and the underestimate respectively.  However, if we aren't trying to
    #  add that strong of a bias, we can set the overestimate and the
    #  underestimate to be the same and derive that value from just drawing
    #  some random distortion of the true value.  This would represent a
    #  simple error by the assessor with no malice.
    #
    #  One other thing that we need to add is the ability to choose between
    #  having a fixed bias (e.g., always off by 20%) and a variable but
    #  bounded bias (e.g., a uniform or normally distributed random percent
    #  of error withing some range like +/- 30% error).
    #
    #  We should probably change the db names
    #  to say developer and offset seller instead of under and over and then
    #  get rid of the call to neutral since it's no longer used.
    #  BTL - Nov 11, 2009
    #------------------------------------------------------------------------

    #---------------------------------------------------------
    # Start ASSESSMENT UNCERTAINTY BIAS CALCS
    #
set.scores.for.all.PUs <- function ()
  {
  query <- paste ('select ID, TOTAL_COND_SCORE_SUM, DEVELOPER_ASSESSMENT_BIAS, ',
                    'SELLER_ASSESSMENT_BIAS from ',
                  dynamicPUinfoTableName, sep='');
  
  cur.pu.ids.and.cond.scores <- sql.get.data (PUinformationDBname, query);

  cur.pu.ids <- cur.pu.ids.and.cond.scores [,1];
  
 
  #  Calculate the new pu scores using the biases set in the database
  
  neutral.pu.scores <- cur.pu.ids.and.cond.scores [, 2];
  
  if(OPT.use.assessment.uncertainty)
  {
    developer.biased.pu.scores <- cur.pu.ids.and.cond.scores [, 2] *
                                     cur.pu.ids.and.cond.scores [, 3]; 
    seller.biased.pu.scores <- cur.pu.ids.and.cond.scores [, 2] *
                                     cur.pu.ids.and.cond.scores [, 4]; 
  }  
  
  # Then update the new pu scores 
  
  for (cur.row in 1:length (cur.pu.ids))
    {
    update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                           cur.pu.ids [cur.row],
                                           neutral.pu.scores[cur.row],
                                           #cur.pu.ids.and.cond.scores [cur.row,
                                           #                            2],
                                           #"TOTAL_HH_SCORE_SUM");
##                                           "TOTAL_COND_SCORE_SUM");
                                     "NEUTRAL_ASSESSED_TOTAL_HH_SCORE_SUM");

    if(OPT.use.assessment.uncertainty)
      {
        update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                               cur.pu.ids [cur.row],
                                               developer.biased.pu.scores[cur.row],
                                               #cur.pu.ids.and.cond.scores [cur.row,
                                               #                            2],
                                               #"TOTAL_HH_SCORE_SUM");
    ##                                           "TOTAL_COND_SCORE_SUM");
                                         "UNDEREST_ASSESSED_TOTAL_HH_SCORE_SUM");
    
        update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                               cur.pu.ids [cur.row],
                                               seller.biased.pu.scores[cur.row],
                                               #cur.pu.ids.and.cond.scores [cur.row,
                                               #                            2],
                                               #"TOTAL_HH_SCORE_SUM");
    ##                                           "TOTAL_COND_SCORE_SUM");
                                         "OVEREST_ASSESSED_TOTAL_HH_SCORE_SUM");
      }

    
    }
  }

    # End ASSESSMENT UNCERTAINTY BIAS CALCS
    #--------------------------------------------------
#==============================================================================



get.PUs.available.for.development <- function ()
  {
  query <- paste ('select ID from ', dynamicPUinfoTableName,
                  'where ',
                  available.for.dev.criteria);
  
  return (sql.get.data (PUinformationDBname, query));
  }

#==============================================================================

get.field.value.of.pu <- function (PU.ID, field.name)
  {
  query <- paste ('select ', field.name, ' from ', dynamicPUinfoTableName,
                 'where ID = ', PU.ID);
  
  return (sql.get.data (PUinformationDBname, query));
  }

#==============================================================================

    #-------------------------------------------------------
    #  THIS IS ONE PLACE TO INSERT OFFSET UNCERTAINTY, I.E.,
    #  UNCERTAINTY IN ASSESSMENT.
    #-------------------------------------------------------

get.neutral.assessed.score.of.pu <- function (PU.to.develop)
  {
  # return (get.field.value.of.pu (PU.to.develop, 'TOTAL_HH_SCORE_SUM'));
#  return (get.field.value.of.pu (PU.to.develop, 'TOTAL_COND_SCORE_SUM'));
  return (get.field.value.of.pu (PU.to.develop,
                                 'NEUTRAL_ASSESSED_TOTAL_HH_SCORE_SUM'));
  }

#==============================================================================

    #-------------------------------------------------------
    #  THIS IS ONE PLACE TO INSERT OFFSET UNCERTAINTY, I.E.,
    #  UNCERTAINTY IN ASSESSMENT.
    #-------------------------------------------------------

get.offset.seller.assessed.score.of.pu <- function (PU.to.develop)
  {
  # return (get.field.value.of.pu (PU.to.develop, 'TOTAL_HH_SCORE_SUM'));
#  return (get.field.value.of.pu (PU.to.develop, 'TOTAL_COND_SCORE_SUM'));
  return (get.field.value.of.pu (PU.to.develop,
                                 'OVEREST_ASSESSED_TOTAL_HH_SCORE_SUM'));
  }

#==============================================================================

    #-------------------------------------------------------
    #  THIS IS ONE PLACE TO INSERT OFFSET UNCERTAINTY, I.E.,
    #  UNCERTAINTY IN ASSESSMENT.
    #-------------------------------------------------------

get.developer.assessed.score.of.pu <- function (PU.to.develop)
  {
  # return (get.field.value.of.pu (PU.to.develop, 'TOTAL_HH_SCORE_SUM'));
#  return (get.field.value.of.pu (PU.to.develop, 'TOTAL_COND_SCORE_SUM'));
  return (get.field.value.of.pu (PU.to.develop,
                                 'UNDEREST_ASSESSED_TOTAL_HH_SCORE_SUM'));
  }

#==============================================================================

record.PU.where.last.offset.was.made <- function (PU.to.develop, offset.target.PU)
  {
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.develop,
                                         offset.target.PU,
                                         "OFFSET_INTO_PU");
  }

#==============================================================================

mark.PU.as.leaked <- function (PU.to.develop)
  {
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.develop,
                                         1,
                                         "LEAKED");
  }

#==============================================================================
#==============================================================================

    #-------------------------------------              
    #  NOTE the global assignments here...
    #-------------------------------------

add.to.tot.non.strategic.offset.score.non.leakage <-
  function (amount.of.offset.required)
  {
  tot.non.strategic.offset.score.non.leakage <<-
      tot.non.strategic.offset.score.non.leakage +
      amount.of.offset.required;
  }

#==================================

add.to.tot.strategic.offset.score.non.leakage <-
  function (amount.of.offset.required)
  {
  tot.strategic.offset.score.non.leakage <<-
      tot.strategic.offset.score.non.leakage +
      amount.of.offset.required;
  }

#==================================

add.cur.offset.to.tot.leakage <- function (amount.of.offset.required)
  {
  tot.non.strategic.offset.score.leakage <<-
          tot.non.strategic.offset.score.leakage +
          amount.of.offset.required;
  }

#==============================================================================
#==============================================================================

develop.PU <- function (PU.to.develop, raw.score.of.PU.to.develop)
{
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.develop,
                                         1,
                                         "DEVELOPED");
  
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.develop,
                                         current.time.step,
                                         "TIME_DEVELOPED");

  
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.develop,
                                         raw.score.of.PU.to.develop,
                                         "HH_SCORE_AT_DEV_TIME"); 
}

#==============================================================================

reserve.and.manage.PU <- function (PU.to.reserve)
{
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.reserve,
                                         1,
                                         "RESERVED");
  
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.reserve,
                                         1,
                                         "MANAGED");

  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                        PU.to.reserve,
                                        current.time.step,
                                        'TIME_RESERVED');
                                        
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                        PU.to.reserve,
                                        current.time.step,
                                        'TIME_MANAGEMENT_COMMENCED');

  set.PU.prob.res.expiring.per.time.step (PU.to.reserve,
                                          OPT.probResExpiringPerTimeStep);

  set.PU.prob.man.expiring.per.time.step (PU.to.reserve,
                                          OPT.probManExpiringPerTimeStep);

  # get the current habitat score
  query <- paste ('select TOTAL_COND_SCORE_SUM from',
                  dynamicPUinfoTableName,
                  'where ID = ', PU.to.reserve );
  cur.cond.score.sum <- sql.get.data( PUinformationDBname, query)

  # record it
  update.single.db.pu.with.single.value( dynamicPUinfoTableName,
                                        PU.to.reserve,
                                        cur.cond.score.sum,
                                        'HH_SCORE_AT_OFFSET_TIME' );

}

#==============================================================================

insert.into.offset.testing.db <- function(PU.to.develop, offset.PU.ID, 
                     hh.score.required.for.offset, offset.remaining.in.partial) 
{ 
  #browser();
  
  query.dev <- paste ('select TOTAL_COND_SCORE_SUM from',
                      dynamicPUinfoTableName,
                        'where ID =', PU.to.develop, sep = ' ');
  development.PU.cond.score <- round( sql.get.data( 
                                      PUinformationDBname, query.dev), 5);
  
  query.res <- paste ('select TOTAL_COND_SCORE_SUM from ',
                      dynamicPUinfoTableName,
                        ' where ID = ', offset.PU.ID, sep = '');
  offset.PU.cond.score <- round( sql.get.data( 
                                      PUinformationDBname, query.res), 5);
  
  
  
  # Prepare and insert a dbase record for a development PU
  
  # add case for zero denominator here
  if( development.PU.cond.score == 0 ) 
  {    pctg.dev.pu.avail <- 0; 
  } else {
    pctg.dev.pu.avail <- round( 
                     hh.score.required.for.offset/offset.remaining.in.partial, 5);                                                                                
    #pctg.dev.pu.used <- round( 
    #                 hh.score.required.for.offset/development.PU.cond.score, 5); 
  } 
  if(  pctg.dev.pu.avail > 1 ) 
    { pctg.dev.pu.avail <- 1; }
  
  #HH.score.developed <-  pctg.dev.pu.used * development.PU.cond.score;
  HH.score.developed <-  pctg.dev.pu.avail * offset.remaining.in.partial;
  
  pctg.dev.pu.used <- round( HH.score.developed/development.PU.cond.score, 5);
  
  insert.new.record.for.offset.test.info.to.db(   offsettingTestingInfoTableName, 
                                                  current.time.step, 
                                                  PU.to.develop, 
                                                  "DEVELOPED", 
                                                  HH.score.developed,
                                                  development.PU.cond.score, 
                                                  pctg.dev.pu.used, 
                                                  offset.PU.ID);
  
  # Prepare and insert a dbase record for an offset PU

  if( offset.PU.cond.score == 0 ) 
  {  HH.score.reserved <- 0;
     pctg.offset.pu.used  <- 0;
     
  } else {
     HH.score.reserved <- HH.score.developed;
      
     pctg.offset.pu.used <-  round( HH.score.reserved/offset.PU.cond.score, 5);
  }   
  insert.new.record.for.offset.test.info.to.db(   offsettingTestingInfoTableName, 
                                                  current.time.step, 
                                                  offset.PU.ID, 
                                                  "RESERVED", 
                                                  HH.score.reserved,
                                                  offset.PU.cond.score, 
                                                  pctg.offset.pu.used, 
                                                  PU.to.develop);
}

#==============================================================================

choose.PU.to.develop <- function (cur.dev.pool)
  {
      #----------------------------------------------------------------------
      #  For the moment, just choose one at random from the development pool.
      #----------------------------------------------------------------------

  dev.pool.idx.of.PU.to.develop <- sample.rdv( 1:length (cur.dev.pool), 1 );
  PU.to.develop <- cur.dev.pool [dev.pool.idx.of.PU.to.develop];

  return (PU.to.develop);
  }

#==============================================================================

        #-------------------------------------------------------------------
        #  The amount to actually offset by may be a multiple of the
        #  original HH score, so apply the appropriate multiplier here.
        #  This will give the amount of offset that needs to be procured.
        #  NOTE:
        #      At the moment there is a multiplier for strategic offsetting,
        #      but it doesn't have any affect since we don't do any
        #      computations for strategic offsetting.
        #      I'll still apply the multiplier now though, in case we do 
        #      end up doing some computation for strategic offsets later on.
        #      BTL - 2009.05.30
        #-------------------------------------------------------------------

apply.offset.multiplier.to.raw.score <- 
                                  function (raw.score.of.PU.to.develop)
  {
  if (OPT.do.strategic.offsetting)
    {
    amount.of.offset.required <-
        OPT.strategic.offset.multiplier * raw.score.of.PU.to.develop;
    
    } else
    {
    amount.of.offset.required <-
        OPT.private.offset.multiplier * raw.score.of.PU.to.develop;
    }

  return (amount.of.offset.required);
  }

#==============================================================================

find.remaining.offsets <- function (PU.to.develop)
  {
  query <- paste ('select ID from ', dynamicPUinfoTableName,
                  ' where ',
                  available.for.offset.criteria,

                      #----------------------------------------------------
                      #  NOTE:  This test could/should change at some point
                      #         since offsets are sometimes done on the
                      #         same property as the development.
                      #         However, when this changes, there will be
                      #         lots of downstream effects in the code so
                      #         leaving it alone right now.
                      #----------------------------------------------------
                  
                  ' and ID != ', PU.to.develop,
                  
                  sep='');
  
  return (sql.get.data (PUinformationDBname, query));
  }

#==============================================================================

    #----------------------------------------------------------------------
    #  SQL QUESTION:
    #  Not sure if this is the right way to test for an empty return from
    #  an sql selection.
    #  Tried is.null(), but that didn't work.
    #  Seems to return a 0 instead instead of a null when nothing is found.
    #  It chokes if I test it against 0 and something Has been returned
    #  (I think that's because it's comparing to every array element).
    #  Best thing I can come up with so far is testing to see if the
    #  value returned is an integer (as opposed to an array or a matrix).
    #----------------------------------------------------------------------

selection.not.empty <- function (value.returned.from.sql.select)
  {
  return (! is.integer (value.returned.from.sql.select));
  }

#==============================================================================
#==============================================================================
          
    #-----------------------
    #  Main offsetting code.
    #-----------------------

#==============================================================================
#==============================================================================

    #---------------------------------------------------------------------
    #  NOTE:  The more.development.allowed variable doesn't seem to be
    #         affected by the offsetting right now.
    #         It's only the request for a PU to develop that changes it
    #         right now.  Need to see what that implies about either a
    #         bug or not needing to return it from the recursive calls.
    #---------------------------------------------------------------------

recursive.offset <- function (PU.to.develop,
                              amount.of.offset.required,
                              more.development.allowed)
  {
  if (DEBUG) {    
    count.test.case (1);        
    cat ("\n\n>>>>> STARTING RECURSIVE.OFFSET:",
         "\n    PU.to.develop = ", PU.to.develop,
         "\n    amount.of.offset.required = ", amount.of.offset.required);
    cat ("\npartial.offset.is.active = ", partial.offset.is.active);
    cat ("\npartial.offset.PU.ID = ", partial.offset.PU.ID);
    cat ("\npartial.offset.sum.score.remaining = ", 
         partial.offset.sum.score.remaining);
  }

  if (get.partial.offset.is.active ())
    {
    if (DEBUG) {
      count.test.case (2);
      cat ("\n  partial offset is active.");
    }

    offset.PU.ID <- get.partial.offset.PU.ID ();
    offset.remaining.in.partial <- 
        get.partial.offset.sum.score.remaining ();
    
    if( DEBUG) 
    { 
      if( overflow <= 0 ) net.development.score <<- net.development.score + amount.of.offset.required;
      cat ("\n\n  net development score = ", net.development.score);
    }

    overflow <<- amount.of.offset.required - offset.remaining.in.partial;

    if( DEBUG) 
    {
      #cat( "\nlength offset.remaining.in.partial = ", length(offset.remaining.in.partial) );
      #cat( "\nlength overflow = ", length(overflow) );

      cat ("\n\n  ----------------");
      cat ("\n  offset.remaining.in.partial = ", offset.remaining.in.partial);
      cat ("\n  amount.of.offset.required = ", amount.of.offset.required);
      cat ("\n  overflow = ", overflow);
  
      #if( overflow <= 0 ) net.development.score <<- net.development.score + amount.of.offset.required;
      #excess.offset.score <<- excess.offset.score + overflow;
      
      #cat ("\n\n  net development score = ", net.development.score);
      #cat ("\n  excess offset score = ", excess.offset.score);
  
    }

    #browser()

    if (overflow > 0)
    {
      if (DEBUG) {        
        count.test.case (3);        
        cat ("\n    --------------");      
        cat ("\n    offset doesn't fit in partial (overflow > 0)");
      }

          #----------------------------------------------------------        
          #  Offset doesn't fit in current partial.
          #  Add what does fit and then go find a new site to put the
          #  overflow in.
          #----------------------------------------------------------
        
      reserve.and.manage.PU (offset.PU.ID);  
                                             #  sometimes has already been
                                             #  done, but this also flags
                                             #  the place where you do partial 
                                             #  reserve and manage if that ever
                                             #  becomes an option

      record.PU.where.last.offset.was.made (PU.to.develop, offset.PU.ID);

      add.to.tot.non.strategic.offset.score.non.leakage (
                                               offset.remaining.in.partial);
      if(DEBUG) 
      {
        insert.into.offset.testing.db(PU.to.develop, offset.PU.ID, 
                    amount.of.offset.required, offset.remaining.in.partial);
      }
      
      close.active.partial.offset ();

          #------------------------------------------------------------------
          #  Recursively call this routine to get new offset for the overflow
          #  that didn't fit in the currently open partial offset.
          #------------------------------------------------------------------

      recursive.offset (PU.to.develop, overflow, more.development.allowed);
        
      } else  #  no overflow, i.e., offset fits in current partial
      {
      if (DEBUG) {        
        count.test.case (4);
        cat ("\n    --------------");      
        cat ("\n    offset fits completely within partial (overflow <= 0)");
      }

          #------------------------------------------------
          #  Offset fits completely within current partial.
          #  Add what does fit to the total offset so far.
          #------------------------------------------------        
        
      add.to.tot.non.strategic.offset.score.non.leakage (
                                               amount.of.offset.required);

      reserve.and.manage.PU (offset.PU.ID);  
                                             #  sometimes has already been
                                             #  done, but this also flags
                                             #  the place where you do partial 
                                             #  reserve and manage if that ever
                                             #  becomes an option

      record.PU.where.last.offset.was.made (PU.to.develop, offset.PU.ID);
      
      if(DEBUG) 
      {
        insert.into.offset.testing.db(PU.to.develop, offset.PU.ID, 
                        amount.of.offset.required, offset.remaining.in.partial);
      }
          #-------------------------------------------------------------    
          #  If this offset exactly uses up what is left in the partial
          #  and has no overflow, then go ahead and close it.
          #  Otherwise, something is leftover and you need to update the
          #  partial's amount remaining to reflect the new amount after
          #  this offset.  
          #-------------------------------------------------------------
      if (overflow == 0.0)
        {
        if (DEBUG) {          
          count.test.case (5);          
          cat ("\n      ------------");      
          cat ("\n      offset exactly uses up partial (overflow == 0)");
        }

        close.active.partial.offset ();
        
        } else 
        {
            #-----------------------------------------------------
            #  The amount of leftover is just the underflow, i.e.,
            #  the negative of the overflow value.
            #-----------------------------------------------------          
      
          if (DEBUG) {          
            count.test.case (6);
            
            cat ("\n      ------------");      
            cat ("\n      offset doesn't use up partial (overflow < 0)");
          }

        set.partial.offset.sum.score.remaining (-overflow);

        }  #  end else - there is more remaining in partial after this offset
      }  #  end else - offset completely fits in current partial
    
    #  -------------------------------------------------------
    #  No partial offset active, so find a new one
    #  -------------------------------------------------------
    } else  
    {
      if (DEBUG) {      
        count.test.case (7);                          
        cat ("\n  no partial offset active.");
      }

        #-----------------------      
        #  Find a new offset PU.
        #-----------------------
      
    offset.PU.ID <- choose.offset.PU (PU.to.develop);

        # -----------------------
        # Check that there are offsets left in pool. 
        # If none, end offset loop
        # ----------------------
    
    if( offset.PU.ID == -99 )
    {
      more.development.allowed <- FALSE;
    } else {

          #--------------
          #  Activate the new offset PU
          #--------------
      
      open.new.active.partial.offset (offset.PU.ID);
  
          #----------------
          #  Do the offset - continue offset loop
          #----------------    
  
      more.development.allowed <- 
          recursive.offset (PU.to.develop, amount.of.offset.required,
                            more.development.allowed);

    }
   }  #  end else - no partial offset active

  return (more.development.allowed);
  }

#==============================================================================

try.to.develop.one.PU <- function ()
  {
  more.development.allowed <- TRUE;
  amount.of.offset.required <- 0.0;
  
  cur.dev.pool <- get.PUs.available.for.development ();

  #---------------------------------------------------------------------
  
  if (length (cur.dev.pool) < 1)
    {
        #-----------------------------------
        #  Nothing left to develop, so quit.
        #-----------------------------------
      
    more.development.allowed <- FALSE;
    cat ("\n\nNOTHING LEFT TO DEVELOP, so, stopping development.");

    } else
    {
        #--------------------------------   
        #  There is something to develop.
        #
        #  Choose which PU to develop.
        #--------------------------------      

    if (DEBUG) {      
      cat ("\n\n", length (cur.dev.pool),
           " PUs left to develop, so, choosing which PU to develop.", sep='');
    }

    PU.to.develop <- choose.PU.to.develop (cur.dev.pool);

    if (DEBUG) {
      cat ("\n    PU.to.develop = ", PU.to.develop);
    }

        #----------------------------------------    
        #  Get the HH score of the PU to develop.
        #----------------------------------------

                #------------------------------------------------------
                #  ASSESSMENT UNCERTAINTY
                #  Eventually, this call may change to use
                #  get.underestimated.assessed.score.of.pu() instead,
                #  since that's what the developer would like.
                #  Then again, it may be that there should be an option
                #  about which score to use here.
                #
                #  Updated below to use get.developer.assessed.score
                #  can still run as neutral assessed score, will depend 
                #  on python implementation settings.    - DWM 12 November 2009
                #------------------------------------------------------
    
    # ASSESSMENT UNCERTAINTY CHANGE
    if(OPT.use.assessment.uncertainty)
    {
        raw.score.of.PU.to.develop <-  
                         get.developer.assessed.score.of.pu (PU.to.develop);
    } else {
        raw.score.of.PU.to.develop <-
                         get.neutral.assessed.score.of.pu (PU.to.develop);  
    }  
    
    if (DEBUG) {
      cat ("\n    raw.score.of.PU.to.develop = ", raw.score.of.PU.to.develop);
    }

    amount.of.offset.required <-
        apply.offset.multiplier.to.raw.score (raw.score.of.PU.to.develop);

    if (DEBUG) {
      cat ("\n    amount.of.offset.required = ",
           amount.of.offset.required);
    }
    
    #-------------------------------------------------
    #   If HH score of PU = 0 then no need to offset
    #-------------------------------------------------
    
    if( amount.of.offset.required == 0 ) 
    {
      cat( "\nZero offset required so moving to next PU" );
      develop.PU (PU.to.develop, raw.score.of.PU.to.develop);
    
    } else {
      #--------------------------------------------------------------------------
      
            #--------------------------------------------------------------
            #  If offsets can leak outside the study area, then with some
            #  probability, you won't have to look for an offset inside the
            #  study area.
            #--------------------------------------------------------------      
        
      if ((OPT.leak.offsets.outside.study.area) &&
          (runif(1) <= OPT.offset.leakage.prob))
        {
            #-------------------------------------------------------------
            #  Leakage is allowed (i.e., offsets can be chosen outside the
            #  study area) and this offset should be leaked.
            #-------------------------------------------------------------
  
        develop.PU (PU.to.develop, raw.score.of.PU.to.develop);
        mark.PU.as.leaked (PU.to.develop);
  
        add.cur.offset.to.tot.leakage (amount.of.offset.required);      
  
                #---------------------------
        } else  #  don't leak current offset
                #---------------------------      
        {
        if (OPT.do.strategic.offsetting)
          {
              #----------------------------------------------------------------
              #  Doing strategic offsetting, so don't need to choose offset PU.
              #  Just go ahead and develop the chosen PU.  
              #----------------------------------------------------------------
  
            if (DEBUG) {          
              cat ("\n\nDoing strategic offsetting.  ",
                   "Don't need to choose offset.",
                   "\nDevelop the chosen PU.");
            }
  
          develop.PU (PU.to.develop, raw.score.of.PU.to.develop);
  
              #------------------------------------------------------------
              #  Add the multiplied score of the PU to develop into the
              #  total strategic offset HH score.
              #  Want to be able to can see how much strategic offset 
              #  would have been required by the time the whole development
              #  sequence finishes.
              #  For the grassland study, we want to make sure that there
              #  really was that much included in the strategic offset.
              #  NOTE:  Since no computations are done, we don't know how
              #         much would have been offset under the random
              #         strategy.  We'll use the multiplier version of HH
              #         score of the PU as an estimate since that's the
              #         exact amount that we want to be offsetting.
              #------------------------------------------------------------
        
                      #------------------------------------
                      #  NOTE the global assignment here...
                      #------------------------------------
  
          add.to.tot.strategic.offset.score.non.leakage (
              amount.of.offset.required);
  
          } else  #  Doing non-strategic offsetting
          {
              #----------------------------------------------------------
              #  Doing non-strategic offsetting, so need to try to choose 
              #  offset.
              #  Develop the chosen PU before you look for the offset
              #  so that you're sure it gets done and doesn't get lost
              #  or done multiple times in the course of any splitting
              #  of offsets across patches, etc.
              #  If something goes wrong with the offsetting process,
              #  then this will leave you need to back this development
              #  out, but for the moment, I'm going to ignore this
              #  because all kinds of other things will be in trouble
              #  then too and I'm not dealing with any of that at the
              #  moment.  I'm going to assume that offsetting just works.
              #  BTL - 2009.07.25
              #----------------------------------------------------------
  
          if (DEBUG) {          
            cat ("\n\nDoing non-strategic offsetting.  Need to choose offset.");
          }
  
          develop.PU (PU.to.develop, raw.score.of.PU.to.develop);
  
                  #---------------------------------------------------
                  #  Need to look for an offset inside the study area.
                  #---------------------------------------------------
  
  
          more.development.allowed <-
  #            do.one.non.strategic.offset (PU.to.develop,
  #                                         more.development.allowed,
  #                                         amount.of.offset.required,
  #                                         raw.score.of.PU.to.develop);
              recursive.offset (PU.to.develop,
                                amount.of.offset.required,
                                more.development.allowed);
              
              
              
              if (DEBUG) {
               # connect.to.database( CondDBname );
                #query <- paste( "select TIME_STEP from ",  offsettingGlobalsTableName );
               # ts <- sql(query);  
               #close.database.connection();
                
                cat ("\n\n  ###----------------");
                cat ("\n  ###----------------");
                cat ("\n  End recursive.offset loop for one PU\n\n");
                #cat ( "\n TIME_STEP = ", ts);
                #cat ("\n  offset.remaining.in.partial = ", offset.remaining.in.partial);
                #cat ("\n  amount.of.offset.required = ", amount.of.offset.required);
                #cat ("\n  overflow = ", overflow);
                
                #cat ("\n\n  Current PU to develop = ", PU.to.develop);
                #cat ("\n\n  more.development.allowed = ", more.development.allowed);
              }
                    
          }  #  end else - at least one offset left
        }  #  end else - doing non-strategic offsetting
      }  #  end else - there is something to develop
    }
  if (DEBUG) 
  {  
    cat ("\n\n");
  }
  
  return (more.development.allowed);
  
  }  #  end function - try.to.develop.one.PU()

#==============================================================================

test.offsetting.standalone <- function (num.PUs.to.develop)
  {
  if (DEBUG) {    
    cat ("\n\n================================================================");
  }
      #--------------------------------------------------------------------    
      #  This is very important:
      #  Need to update the HH scores to match the current condition.
      #  If we do it here, then we don't have to make sure HH is updated
      #  every time condition is updated in the condition model.
      #  Also, this gives us one central place to add error to the HH score
      #  if want to.
      #--------------------------------------------------------------------
    
  set.scores.for.all.PUs();

  if (DEBUG) {
    cat ("\n\nDone setting HH scores for all PUs.");
  }
      #------------------------------------------------------
      #  Now ready to loop through developing and offsetting.
      #------------------------------------------------------
  
  if( num.PUs.to.develop >= 1 )
  {
    for (i in 1:num.PUs.to.develop)
    {
      if (! try.to.develop.one.PU())
      {
        if (DEBUG) 
        {        
          cat ("---------------------------------------");
        
          cat ("\n\n---- In test.offsetting.standalone() for loop at i = ", i,
               ".\n",
               "---- try.to.develop.one.PU() returned FALSE.  ",
               "\n---- Breaking now.", sep='');
          
          cat ("\n\n---------------------------------------");
        }
        
        break;
      }

      if (DEBUG) 
      {    
        cat ("\n\n---------------------------------------");
      }
    }
  } else 
  {
      cat( "\n\nNumber of PUs to develop is < 1!\n\n" );
  }
      
      
  save.offsetting.global.variables ();

  if (DEBUG) {
    cat ("\n\n At end of test.offsetting.standalone():",
         
         "\n    tot.STRATEGIC.offset.score.non.leakage = ",
         tot.strategic.offset.score.non.leakage,
         "\n        NOTE: *** Is the final offset total > what was set aside ",
         "in DSE's pooled strategic set-aside? ***\n", 
         
         "\n    tot.non.strategic.offset.score.NON.leakage = ",
         tot.non.strategic.offset.score.non.leakage,
         
         "\n    tot.non.strategic.offset.score.LEAKAGE = ",       
         tot.non.strategic.offset.score.leakage,
         
         ##       "\n    tot.COST.of.NON.leaked.RANDOM.offsets = ",       
         ##       tot.cost.of.non.leaked.random.offsets,
         
         sep='');
  }

  cat ("\n\n---------------------------------------");
  cat ("\n\n");
  
  cat( '\n', current.time.step, '\t',
      tot.strategic.offset.score.non.leakage,'\t',
      tot.non.strategic.offset.score.non.leakage,'\t',
      tot.non.strategic.offset.score.leakage,'\t',
      sep='', file = 'running.totals.for.scores.txt', append = 'TRUE' );
  
  }

#==============================================================================

    #---------------
    #  Run the test.
    #---------------

#test.offsetting.standalone (1);

#cat ("\n\nAt end of everything:");
#cat ("\ntot.non.strategic.offset.score.leakage = ", 
#     tot.non.strategic.offset.score.leakage, sep='');
##cat ("\ntot.cost.of.non.leaked.random.offsets = ", 
##     tot.cost.of.non.leaked.random.offsets, sep='');

#cat ("\n\n---------------------------------------");
#cat ("\n\n");

#cat ("test.case.cts = ", test.case.cts, "\n\n");
##browser();

#==============================================================================
#==============================================================================
#==============================================================================


