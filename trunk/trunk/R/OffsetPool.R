#==============================================================================

# source( 'OffsetPool.R' );

#==============================================================================
#==============================================================================

    #      NOTE: These comments are cut from the old code in offset.model.R
    #            Not sure if they still hold
    
    
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

#  History:

#  2011.01.20 - BTL
#  Added code to use rule sets rather than individual rules when looking 
#  for remaining offsets.

#==============================================================================

source( 'dbms.functions.R' )  
source( 'variables.R' )

source ('PartialOffset.R');

#==============================================================================
#==============================================================================
#==============================================================================

    #--------------------------------
    #  Extra code for debugging only.
    #--------------------------------

if (DEBUG) 
  {
  cat ("\n\n********  STARTING offset model  ************\n\n");

        #---------------------------------------------------------------
        #  Create counters for different branches of the code so that
        #  you can see if every branch gets exercised in testing.
        #  These counters just get bumped each time the specified region
        #  is entered.
        #  This stuff can be removed once we know that everything is
        #  behaving correctly.
        #  BTL - 2009.07.23
        #---------------------------------------------------------------
 
  max.num.cases <- 7;
  test.case.cts <<- rep (0,max.num.cases);

      #  counters for the hh score for each PU developed/offset
      
  net.development.score <- 0;
  excess.offset.score <- 0;
  overflow <<- 0;
  }


  max.num.cases <- 7;
  test.case.cts <<- rep (0,max.num.cases);

      #----------
      
count.test.case <- function (case.num)
  {
  test.case.cts [case.num] <<- test.case.cts [case.num] + 1;
  if(DEBUG.OFFSETTING) cat ("\n- ", case.num, " -");
  }

#==============================================================================
#==============================================================================
#==============================================================================

# Increase the number of recursions so that we won't reach the limit
# if there are a large number of parcels to develop. Note that even
# developing 200 parcels per time step wen't over the 5000 limit. This
# must be because it counts multiple function calls within the
# recursive offset algorithm. The default value is 5000, here we're
# setting it 20000

# To get the current recursion limit use
# options("expressions")

options(expressions = 20000)
 
#==============================================================================

    #------------
    #  Constants.
    #------------

            #------------------------------------------------
            #  Is there already a constant like this defined?
            #  BTL - 2009.05.31
            #------------------------------------------------
CONST.UNINITIALIZED.PU.ID.VALUE <- -999;

        #---------------------------------------------------------------
        #  There were a couple of references to -99 in the code but no 
        #  indication of what it meant, so I am giving it a name.
        #  BTL - 2010.12.07
        #---------------------------------------------------------------

CONST.NO.OFFSETS.LEFT <- -99

CONST.NO.PU.LEFT.TO.DEVELOP <- -88

#==============================================================================

    #---------------------------------------------------------------------
    #  TODO:  The more.development.allowed variable doesn't seem to be
    #         affected by the offsetting right now.
    #         It's only the request for a PU to develop that changes it
    #         right now.  Need to see what that implies about either a
    #         bug or not needing to return it from the recursive calls.
    #---------------------------------------------------------------------

more.development.allowed <<- TRUE;

#==============================================================================

melb.grassland.offset.criteria <- paste (' DEVELOPED = 0 ',
                                        ' and RESERVED = 0 ',
                                        ' and IN_OFFSET_POOL = 1 ',
                                        ' and NEUTRAL_ASSESSED_TOTAL_HH_SCORE_SUM > 0 '
                                        )
                                        
    #--------------------       
    #--------------------     
 
    #-----------------------------------------------------------------
    #  To add a new compound offset rule to the existing set below, 
    #  just clone one of the existing rules and add it to the bottom 
    #  of the list.  You'll have to substitute whicher Par.??.dev... 
    #  rules you want to include in your compound rule and you 
    #  have to make sure that they are in the yaml file.
    #-----------------------------------------------------------------

offsetRules <- list()
offsetRules [["PAR.offsetRule.A"]] <- c(PAR.ii1.dev.IN.offset.IN.criteria)

offsetRules [["PAR.offsetRule.B"]] <- c(PAR.io1.dev.IN.offset.OUT.criteria)

offsetRules [["PAR.offsetRule.C"]] <- c(PAR.oo1.dev.OUT.offset.OUT.criteria)

offsetRules [["PAR.offsetRule.D"]] <- c(PAR.io2.dev.IN.offset.OUT.criteria,
                                        PAR.io3.dev.IN.offset.OUT.criteria,
                                        PAR.io1.dev.IN.offset.OUT.criteria )

offsetRules [["PAR.offsetRule.E"]] <- c(PAR.oo2.dev.OUT.offset.OUT.criteria,
                                        PAR.oo3.dev.OUT.offset.OUT.criteria,
                                        PAR.oo1.dev.OUT.offset.OUT.criteria)

    #--------------------       
    #--------------------       

# Moving these to the yaml file - Ascelin Gordon 2011.01.19
# Bill: delete all these comments whne you're happy that the new code is correct.

## dev.IN.offset.IN.criteria <- paste (' DEVELOPED = 0 ',
##                                     ' and RESERVED = 0 ',
##                                     ' and TENURE = "Unprotected"',                    
##                                     ' and GROWTH_CENTRE = 1',
##                                     ' and GC_NOTCERT = 1',
##                                     ' and UNDEV_LAND = 0',   # Ascelin - addition
##                                     ' and AREA_OF_CPW > 0 '
##                                     )  

##     #--------------------       
    
## dev.IN.offset.OUT.criteria <- paste (' DEVELOPED = 0 ',
##                                      ' and RESERVED = 0 ',
##                                      ' and TENURE = "Unprotected"',                    
##                                      ' and GROWTH_CENTRE = 0',
##                                      ' and AREA_OF_CPW > 0 '    #  HAS another unknown criteria too
##                                      )  

##     #--------------------       
    
## dev.OUT.offset.OUT.criteria <- paste (' DEVELOPED = 0 ',
##                                       ' and RESERVED = 0 ',
##                                       ' and TENURE = "Unprotected"',                    
##                                       ' and GROWTH_CENTRE = 0',
##                                       ' and AREA_OF_CPW > 0 '    #  HAS another unknown criteria too
##                                       )  

#==============================================================================

setClass ("OffsetPool", 
          representation (OP.db.field.label = "character",

                          name = "character",
                          more.dev.allowed = "logical",
          
                          tot.strat.offset.non.leak = "numeric",
                          tot.non.strat.offset.leak = "numeric",
                          tot.non.strat.offset.non.leak = "numeric", 
                          
                          partial.offset = "PartialOffset", 
                          available.for.offset.criteria = "character"
						  ),

	 	   prototype (OP.db.field.label = "STRING NOT INITIALIZED YET", 

                          name = "STRING NOT INITIALIZED YET",
                          more.dev.allowed = FALSE,
	 	     #  TODO:
	 	     #  THIS SHOULD REALLY JUST HAVE A LEAKAGE AND A NON-LEAKAGE 
	 	     #  ELEMENT HERE SINCE THE STRATEGIC/NON-STRATEGIC IS ESSENTIALLY 
	 	     #  THE SAME IDEA AS THE IN.GC AND OUT.GC SEPARATION OF POOLS.
	 	     
                          tot.strat.offset.non.leak = 0.0,
                          
                          tot.non.strat.offset.leak = 0.0,
                          tot.non.strat.offset.non.leak = 0.0, 
                          
                          partial.offset = new ("PartialOffset"), 

                          available.for.offset.criteria =  "STRING NOT INITIALIZED YET"

                      )
              );

#==============================================================================
#==============================================================================
#==============================================================================
    #  Create generic and specific get and set routines for 
    #  all instance variables.
#==============================================================================

                #-----  OP.db.field.label  -----#
    #  Get    
setGeneric ("OP.db.field.label", signature = "x", 
            function (x) standardGeneric ("OP.db.field.label"))            
setMethod ("OP.db.field.label", "OffsetPool", 
           function (x) x@OP.db.field.label);

    #  Set    
setGeneric ("OP.db.field.label<-", signature = "x", 
            function (x, value) standardGeneric ("OP.db.field.label<-"))
setMethod ("OP.db.field.label<-", "OffsetPool", 
           function (x, value) initialize (x, OP.db.field.label = value))

                #-----  name  -----#
    #  Get    
setGeneric ("name", signature = "x", 
            function (x) standardGeneric ("name"))            
setMethod ("name", "OffsetPool", 
           function (x) x@name);

    #  Set    
setGeneric ("name<-", signature = "x", 
            function (x, value) standardGeneric ("name<-"))
setMethod ("name<-", "OffsetPool", 
           function (x, value) initialize (x, name = value))

                #-----  more.dev.allowed  -----#    
    #  Get    
setGeneric ("more.dev.allowed", signature = ".Object", 
            function (.Object) standardGeneric ("more.dev.allowed"))
setMethod ("more.dev.allowed", "OffsetPool", 
           function (.Object) .Object@more.dev.allowed);

    #  Set    
setGeneric ("more.dev.allowed<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("more.dev.allowed<-"))
setMethod ("more.dev.allowed<-", "OffsetPool", 
           function (.Object, value) initialize (.Object, more.dev.allowed = value))

                #-----  tot.non.strat.offset.non.leak  -----#    
    #  Get    
setGeneric ("tot.non.strat.offset.non.leak", signature = ".Object", 
            function (.Object) standardGeneric ("tot.non.strat.offset.non.leak"))
setMethod ("tot.non.strat.offset.non.leak", "OffsetPool", 
           function (.Object) .Object@tot.non.strat.offset.non.leak);

    #  Set    
setGeneric ("tot.non.strat.offset.non.leak<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("tot.non.strat.offset.non.leak<-"))
setMethod ("tot.non.strat.offset.non.leak<-", "OffsetPool", 
           function (.Object, value) initialize (.Object, tot.non.strat.offset.non.leak = value))

                #-----  tot.non.strat.offset.leak  -----#    
    #  Get    
setGeneric ("tot.non.strat.offset.leak", signature = ".Object", 
            function (.Object) standardGeneric ("tot.non.strat.offset.leak"))
setMethod ("tot.non.strat.offset.leak", "OffsetPool", 
           function (.Object) .Object@tot.non.strat.offset.leak);

    #  Set    
setGeneric ("tot.non.strat.offset.leak<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("tot.non.strat.offset.leak<-"))
setMethod ("tot.non.strat.offset.leak<-", "OffsetPool", 
           function (.Object, value) initialize (.Object, tot.non.strat.offset.leak = value))

                #-----  tot.strat.offset.non.leak  -----#    
    #  Get    
setGeneric ("tot.strat.offset.non.leak", signature = ".Object", 
            function (.Object) standardGeneric ("tot.strat.offset.non.leak"))
setMethod ("tot.strat.offset.non.leak", "OffsetPool", 
           function (.Object) .Object@tot.strat.offset.non.leak);

    #  Set    
setGeneric ("tot.strat.offset.non.leak<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("tot.strat.offset.non.leak<-"))
setMethod ("tot.strat.offset.non.leak<-", "OffsetPool", 
           function (.Object, value) initialize (.Object, tot.strat.offset.non.leak = value))

                #-----  partial.offset  -----#    
    #  Get    
setGeneric ("partial.offset", signature = ".Object", 
            function (.Object) standardGeneric ("partial.offset"))
setMethod ("partial.offset", "OffsetPool", 
           function (.Object) .Object@partial.offset);

    #  Set    
setGeneric ("partial.offset<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("partial.offset<-"))
setMethod ("partial.offset<-", "OffsetPool", 
           function (.Object, value) initialize (.Object, partial.offset = value))

                #-----  available.for.offset.criteria  -----#    
    #  Get    
setGeneric ("available.for.offset.criteria", signature = ".Object", 
            function (.Object) standardGeneric ("available.for.offset.criteria"))
setMethod ("available.for.offset.criteria", "OffsetPool", 
           function (.Object) .Object@available.for.offset.criteria);

    #  Set    
setGeneric ("available.for.offset.criteria<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("available.for.offset.criteria<-"))
setMethod ("available.for.offset.criteria<-", "OffsetPool", 
           function (.Object, value) initialize (.Object, available.for.offset.criteria = value))

#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================

                #-----  initialize.offset.pool  -----#

setGeneric ("initialize.offset.pool", signature = ".Object", 
			function (.Object) standardGeneric ("initialize.offset.pool"))
			
#--------------------
 
setMethod ("initialize.offset.pool", "OffsetPool", 
function (.Object)
  {
  nameObject <- deparse (substitute (.Object))

      #  TODO:  THIS NEEDS TO LOAD FROM THE DATABASE IF NOT TIME STEP 0 
###  partial.offset (.Object) <- new (PartialOffset) 
                                        
  assign (nameObject, .Object, envir=parent.frame())
  }
)

#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================

                #-----  save.running.totals  -----#

setGeneric ("save.running.totals", signature = ".Object", 
			function (.Object) standardGeneric ("save.running.totals"))
			
#--------------------
 
setMethod ("save.running.totals", "OffsetPool", 
function (.Object)
  {
      #-----------------------------------------------------------------------
      #  Build a data frame holding the running totals as of this time step 
      #  rounded to 5 decimal places.  
      #  Having it in the data frame form makes is just to make it easier to 
      #  write it to the database.
      #-----------------------------------------------------------------------
      
  offsetting.globals.vec <- c (current.time.step,
                               tot.strat.offset.non.leak (.Object),
                               tot.non.strat.offset.leak (.Object),
                               tot.non.strat.offset.non.leak (.Object)
                               );
  
  offsetting.globals.vec <- round (offsetting.globals.vec, 5);

  globals.col.names <- c ('TIME_STEP',
                          'TOT_STRATEGIC_OFFSET_SCORE_NON_LEAKAGE',
                          'TOT_NON_STRATEGIC_OFFSET_SCORE_LEAKAGE',
                          'TOT_NON_STRATEGIC_OFFSET_SCORE_NON_LEAKAGE'
                          );
  
  offsetting.globals.data.frame <- data.frame (t (offsetting.globals.vec));
  colnames (offsetting.globals.data.frame) <- globals.col.names;

      #-----------------------------------------------------------------------------
      #  Now have the data in the data frame form that the write.data.to.db wants, 
      #  so dump it to the database.
      #-----------------------------------------------------------------------------      
                         
  connect.to.database (CondDBname);
  write.data.to.db (offsettingGlobalsTableName, offsetting.globals.data.frame)
  close.database.connection ();
  }
)

#==============================================================================

                #-----  save.offsetting.global.variables  -----#

setGeneric ("save.offsetting.global.variables", signature = ".Object", 
			function (.Object) standardGeneric ("save.offsetting.global.variables"))
			
#--------------------
 
setMethod ("save.offsetting.global.variables", "OffsetPool", 
function (.Object)
  {
  save.running.totals (.Object);  
  save.global.values.for.any.active.partial.offset (partial.offset (.Object))
  }
)

#==============================================================================

                #-----  add.to.tot.non.strat.offset.non.leak  -----#

setGeneric ("add.to.tot.non.strat.offset.non.leak", signature = ".Object", 
			function (.Object, amount.of.offset.required) standardGeneric ("add.to.tot.non.strat.offset.non.leak"))
			
#--------------------
 
setMethod ("add.to.tot.non.strat.offset.non.leak", "OffsetPool", 
function (.Object, amount.of.offset.required)
  {
  nameObject <- deparse (substitute (.Object))

  tot.non.strat.offset.non.leak (.Object) <- 
      tot.non.strat.offset.non.leak (.Object) +
      amount.of.offset.required;

  assign (nameObject, .Object, envir=parent.frame())
  }
)

#==================================

                #-----  add.to.tot.strat.offset.non.leak  -----#

setGeneric ("add.to.tot.strat.offset.non.leak", signature = ".Object", 
			function (.Object, amount.of.offset.required) standardGeneric ("add.to.tot.strat.offset.non.leak"))
			
#--------------------
 
setMethod ("add.to.tot.strat.offset.non.leak", "OffsetPool", 
function (.Object, amount.of.offset.required)
  {
  nameObject <- deparse (substitute (.Object))

  tot.strat.offset.non.leak (.Object) <- 
      tot.strat.offset.non.leak (.Object) +
      amount.of.offset.required;

  assign (nameObject, .Object, envir=parent.frame())
  }
)

#==================================

                #-----  add.cur.offset.to.tot.leakage  -----#

setGeneric ("add.cur.offset.to.tot.leakage", signature = ".Object", 
			function (.Object, amount.of.offset.required) standardGeneric ("add.cur.offset.to.tot.leakage"))
			
#--------------------
 
setMethod ("add.cur.offset.to.tot.leakage", "OffsetPool", 
function (.Object, amount.of.offset.required)
  {
  nameObject <- deparse (substitute (.Object))

  tot.non.strat.offset.leak (.Object) <- 
          tot.non.strat.offset.leak (.Object) +
          amount.of.offset.required;
          
  assign (nameObject, .Object, envir=parent.frame())          
  }
)

#==============================================================================

                #-----  open.new.active.partial.offset  -----#

setGeneric ("open.new.active.partial.offset", signature = ".Object", 
			function (.Object, offset.PU.ID) standardGeneric ("open.new.active.partial.offset"))
			
#--------------------
 
setMethod ("open.new.active.partial.offset", "OffsetPool", 
function (.Object, offset.PU.ID)
  {
  nameObject <- deparse (substitute (.Object))
  
      #----------
  
#------------------------------------------------------------------------
          #  NOTE:  This is a weird quirk of the OOP system.
          #         If I don't create a temporary variable here and do 
          #         the assignment via the temporary, the values 
          #         set in close.active.partial.offser() don't stick 
          #         in the object here, so I have to reassign via x.
          #    NEED TO LOOK FOR OTHER PLACES WHERE THIS MIGHT BE 
          #    HAPPENING, I.E., ASSIGNMENTS TO partial.offset (.Object)
          #    INSIDE A CALL'S ARGUMENT LIST.
#------------------------------------------------------------------------
tmpAssignPO <- partial.offset (.Object)

#cat ("\n\nAt start of open.new.active.partial.offset()\n")
#cat ("tmpAssignPO = \n")

#  partial.is.active (partial.offset (.Object)) <- TRUE
  partial.is.active (tmpAssignPO) <- TRUE
  
#cat ("\n\njust after partial.is.active (tmpAssignPO) <- TRUE\n")
#cat ("tmpAssignPO = \n")
#print (tmpAssignPO)
    
#  partial.PU.ID (partial.offset (.Object)) <- offset.PU.ID
  partial.PU.ID (tmpAssignPO) <- offset.PU.ID

#cat ("\n\njust after partial.PU.ID (tmpAssignPO) <- ", offset.PU.ID, "\n")
#cat ("tmpAssignPO = \n")
#print (tmpAssignPO)
  
      #  Initially setting the amount remaining to be the assessed score
      #  for the whole offset patch.
      #  Not sure, but might want to have this be an argument passed in
      #  to this routine instead or just make this be the default...
  
      # ASSESSMENT UNCERTAINTY CHANGE
  if (OPT.use.assessment.uncertainty)
    {
#    partial.sum.score.remaining (partial.offset (.Object)) <- get.offset.seller.assessed.score.of.pu (.Object, offset.PU.ID) 
    partial.sum.score.remaining (tmpAssignPO) <- get.offset.seller.assessed.score.of.pu (.Object, offset.PU.ID) 
#cat ("\n\njust after partial.sum.score.remaining (tmpAssignPO) <- get.offset.seller.assessed.score.of.pu (.Object, offset.PU.ID)\n")
#cat ("tmpAssignPO = \n")
#print (tmpAssignPO)
  
    } else 
    { 
#    partial.sum.score.remaining (partial.offset (.Object)) <- get.neutral.assessed.score.of.pu (.Object, offset.PU.ID)                     
    partial.sum.score.remaining (tmpAssignPO) <- get.neutral.assessed.score.of.pu (.Object, offset.PU.ID)                     
#cat ("\n\njust after partial.sum.score.remaining (tmpAssignPO) <- get.neutral.assessed.score.of.pu (.Object, offset.PU.ID)\n")
#cat ("tmpAssignPO = \n")
#print (tmpAssignPO)
      }

#cat ("\n\nAt end of open.new.active.partial.offset()\n")
if(DEBUG.OFFSETTING) cat ("tmpAssignPO = \n")
if(DEBUG.OFFSETTING) print (tmpAssignPO)

partial.offset (.Object) <- tmpAssignPO
#cat ("partial.offset (.Object) = \n")
#print (partial.offset (.Object))
#------------------------------------------------------------------------


  assign (nameObject, .Object, envir=parent.frame())
  }
)

#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================

                #-----  find.remaining.offsets  -----#

setGeneric ("find.remaining.offsets", signature = ".Object", 
			function (.Object, PU.to.develop) standardGeneric ("find.remaining.offsets"))
			
#--------------------
 
setMethod ("find.remaining.offsets", "OffsetPool", 
function (.Object, PU.to.develop)
  {
  result <- NA
  
###cat ("\n\nStarting find.remaining.offsets()...\n")
  
  offset.rule.set <- available.for.offset.criteria (.Object)  
  num.rules <- length (offset.rule.set)

###cat ("\n\nIn find.remaining.offsets()...\n")
  
  for (cur.rule.idx in 1:num.rules)
      {
      cur.available.for.offset.criteria <- offset.rule.set [cur.rule.idx]
  
      query <- paste ('select ID from ', dynamicPUinfoTableName,
                  ' where ',
                  cur.available.for.offset.criteria,

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

      if(DEBUG.OFFSETTING) {
        cat ("\n\nIn find.remaining.offsets (cur.offset.pool, ", PU.to.develop,
             "), where cur.offset.pool = \n")
        print (.Object)
        cat ("\n>>>>>>>>>>>>>>>>>>> query = ", query, "\n\n")
      }

      result <- sql.get.data (PUinformationDBname, query)
      if (selection.not.empty (result))
        {

          # ---------------------------------------------------------------------
          # NOTE: this is for debugging only..
          
          area.query <- paste ('select AREA_OF_CPW from ', dynamicPUinfoTableName,
                               ' where ',
                               cur.available.for.offset.criteria,
                               ' and ID != ', PU.to.develop,
                               sep='');
          
          area.result <- sql.get.data (PUinformationDBname, area.query)
          if(DEBUG.OFFSETTING) cat( '\n @@@@', name(.Object),
                                   ' Total area of CPW for remaining offset candidate parcels=',
                                   sum(area.result), '\n', sep='' )
          # ---------------------------------------------------------------------

          break
        }
      
      }  #  end for 
      
  return (result)
  
  }
)

#==============================================================================

                #-----  choose.offset.PU  -----#

setGeneric ("choose.offset.PU", signature = ".Object", 
			function (.Object, PU.to.develop) standardGeneric ("choose.offset.PU"))
			
#--------------------
 
setMethod ("choose.offset.PU", "OffsetPool", 
function (.Object, PU.to.develop)
  {
###cat ("\n\nStarting choose.offset.PU...\n")
  remaining.offset.candidate.PUs <- find.remaining.offsets (.Object, PU.to.develop);

    if(DEBUG.OFFSETTING) cat ("\n\nJust after find.remaining.offsets(), remaining.offset.candidate.PUs = ")
    if(DEBUG.OFFSETTING) print (remaining.offset.candidate.PUs)

      #--------------------------------------------------
      #  For now, just pick any candidate at random.
      #  May want more complex rules for closer matches
      #  to development PU later.
      #--------------------------------------------------
  
#  if( length(remaining.offset.candidate.PUs) != 0 )
  if (selection.not.empty (remaining.offset.candidate.PUs))    #  BTL - Changed 2010.12.18
    {
    offset.PU.ID <- sample.rdv (remaining.offset.candidate.PUs, 1);
    
    } else 
    {
    offset.PU.ID <- CONST.NO.OFFSETS.LEFT;
    }
    
  return (offset.PU.ID);
  }
)

#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================

                #-----  set.scores.for.all.PUs  -----#

setGeneric ("set.scores.for.all.PUs", signature = ".Object", 
			function (.Object) standardGeneric ("set.scores.for.all.PUs"))
			
#--------------------
 
setMethod ("set.scores.for.all.PUs", "OffsetPool", 
function (.Object)
  {
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
    #---------------------------------------------------------

  query <- paste ('select ID, ', PAR.db.table.field.to.calc.offsets,
                  ', DEVELOPER_ASSESSMENT_BIAS, ',
                  'SELLER_ASSESSMENT_BIAS from ',
                  dynamicPUinfoTableName, sep='');
  
  cur.pu.ids.and.cond.scores <- sql.get.data (PUinformationDBname, query);

  cur.pu.ids <- cur.pu.ids.and.cond.scores [,1];
  
      #--------------------------------------------------------------------
      #  Calculate the new pu scores using the biases set in the database
      #--------------------------------------------------------------------
  
  neutral.pu.scores <- cur.pu.ids.and.cond.scores [, 2];
  
  if (OPT.use.assessment.uncertainty) 
    {    
    developer.biased.pu.scores <-
        cur.pu.ids.and.cond.scores [, 2] * cur.pu.ids.and.cond.scores [, 3]
    
    seller.biased.pu.scores <-
        cur.pu.ids.and.cond.scores [, 2] * cur.pu.ids.and.cond.scores [, 4]    
    }  

      #---------------------------------
      #  Then update the new pu scores 
      #---------------------------------

  update.column.in.db.table.via.dataframe (dynamicPUinfoTableName,
                                           'NEUTRAL_ASSESSED_TOTAL_HH_SCORE_SUM',
                                           neutral.pu.scores)

  if (OPT.use.assessment.uncertainty) 
    {    
    update.column.in.db.table.via.dataframe (dynamicPUinfoTableName,
                                             'UNDEREST_ASSESSED_TOTAL_HH_SCORE_SUM',
                                             developer.biased.pu.scores)
    
    update.column.in.db.table.via.dataframe (dynamicPUinfoTableName,
                                             'OVEREST_ASSESSED_TOTAL_HH_SCORE_SUM',
                                             seller.biased.pu.scores)
    }  
  }
)

    #--------------------------------------------------
    # End ASSESSMENT UNCERTAINTY BIAS CALCS
    #--------------------------------------------------

#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================

                #-----  determine.if.offset.required  -----#

setGeneric ("determine.if.offset.required", signature = ".Object", 
			function (.Object, PU.to.develop) standardGeneric ("determine.if.offset.required"))
			
#--------------------
 
setMethod ("determine.if.offset.required", "OffsetPool", 
function (.Object, PU.to.develop)
  {

  # First check to see the offseting option is turned on  
  if( ! OPT.use.offsetting.in.CPW.project )
    {
      # if not, then no offset is ever required so always return FALSE
      offset.required <- FALSE
      if(DEBUG.OFFSETTING) cat( '\n Offsetting is not being used (OPT.use.offsetting.in.CPW.project==FALSE)' )
      return( offset.required )
    }

  
  offset.required <- TRUE
  
      #-------------------------------------------------------------------
      #  First get the area of CPW of the parcel and see if it meets the
      #  area threshold for offsetting
      #-------------------------------------------------------------------

          #---------------------------------------------------------------------  
          #  IMPORTANT NOTE: BTL - 2010.12.20
          #        THIS IS WHERE WE SHOULD ALSO TRY A TEST FOR THE SIZE OF THE 
          #        CPW PATCH THAT THE PU OVERLAPS INSTEAD OF JUST THE SIZE OF 
          #        THE PU TO DEVELOP.  THIS WOULD HELP AVOID SHATTERING BIG 
          #        CPW PATCHES WITH LITTLE INCREMENTAL LOSSES FROM SMALL 
          #        SUBDIVISION LOTS.  However, we need another layer to 
          #        be able to do this query.
          #---------------------------------------------------------------------      
      
  query <- paste ('select AREA_OF_CPW from', dynamicPUinfoTableName, 'where ID =', PU.to.develop )
  area.of.cpw.on.current.PU <- sql.get.data (PUinformationDBname, query)

  if(DEBUG.OFFSETTING) cat ('\nArea of PU:', area.of.cpw.on.current.PU)
  
  if (area.of.cpw.on.current.PU < PAR.threshold.area.required.for.offset) 
    {    
    if(DEBUG.OFFSETTING) cat ( '\nNO OFFSET REQUIRED ') 
    offset.required <- FALSE    
    }
  
      #--------------------------------------------------------------------
      # Next test if an offset is required (the assumption is that if
      # the parcel was cleared illegally then no offset is needed)
      #--------------------------------------------------------------------
  
  query <- paste ('select GROWTH_CENTRE from', dynamicPUinfoTableName, 'where ID =', PU.to.develop )
  parcel.is.in.growth.center <- sql.get.data (PUinformationDBname, query)

  if (parcel.is.in.growth.center) 
    {
    if(DEBUG.OFFSETTING) cat ('\nParcel IS in growth centre')

    if (runif(1) < PAR.prob.no.offset.required.in.growth.centres) 
      {
      offset.required <- FALSE
      if(DEBUG.OFFSETTING) cat ('\nNO OFFSET REQUIRED ')
      }
      
    } else 
    {
    if(DEBUG.OFFSETTING) cat ('\nParcel is NOT in growth centre')
    if (runif(1) < PAR.prob.no.offset.required.outside.growth.centres) 
      {
      offset.required <- FALSE
      if(DEBUG.OFFSETTING) cat ('\nNO OFFSET REQUIRED ') 
      }
    }
  return (offset.required)
  }  
)

#==============================================================================
#==============================================================================
#==============================================================================

                #-----  set.PU.prob.res.expiring.per.time.step  -----#

setGeneric ("set.PU.prob.res.expiring.per.time.step", signature = ".Object", 
			function (.Object, cur.offset.PU.ID, probResExpiringPerTimeStep) standardGeneric ("set.PU.prob.res.expiring.per.time.step"))
			
#--------------------
 
setMethod ("set.PU.prob.res.expiring.per.time.step", "OffsetPool", 
function (.Object, cur.offset.PU.ID, probResExpiringPerTimeStep)
  {
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         cur.offset.PU.ID,
                                         probResExpiringPerTimeStep,
                                         "PROB_RES_EXPIRING_PER_TIMESTEP");
  }
)

#==============================================================================

                #-----  x  -----#

setGeneric ("set.PU.prob.man.expiring.per.time.step", signature = ".Object", 
			function (.Object, cur.offset.PU.ID, probManExpiringPerTimeStep) standardGeneric ("set.PU.prob.man.expiring.per.time.step"))
			
#--------------------
 
setMethod ("set.PU.prob.man.expiring.per.time.step", "OffsetPool", 
function (.Object, cur.offset.PU.ID, probManExpiringPerTimeStep)
  {
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         cur.offset.PU.ID,
                                         probManExpiringPerTimeStep,
                                         "PROB_MAN_EXPIRING_PER_TIMESTEP");
  }
)

#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================

                #-----  get.neutral.assessed.score.of.pu  -----#

setGeneric ("get.neutral.assessed.score.of.pu", signature = ".Object", 
			function (.Object, PU.to.develop) standardGeneric ("get.neutral.assessed.score.of.pu"))
			
#--------------------
 
setMethod ("get.neutral.assessed.score.of.pu", "OffsetPool", 
function (.Object, PU.to.develop)
  {
      #-------------------------------------------------------
      #  THIS IS ONE PLACE TO INSERT OFFSET UNCERTAINTY, I.E.,
      #  UNCERTAINTY IN ASSESSMENT.
      #-------------------------------------------------------

  # return (get.field.value.of.pu (PU.to.develop, 'TOTAL_HH_SCORE_SUM'));
#  return (get.field.value.of.pu (PU.to.develop, PAR.db.table.field.to.calc.offsets));
  return (get.field.value.of.pu (PU.to.develop,
                                 'NEUTRAL_ASSESSED_TOTAL_HH_SCORE_SUM'));
  }
)

#==============================================================================

                #-----  get.offset.seller.assessed.score.of.pu  -----#

setGeneric ("get.offset.seller.assessed.score.of.pu", signature = ".Object", 
			function (.Object, PU.to.develop) standardGeneric ("get.offset.seller.assessed.score.of.pu"))
			
#--------------------
 
setMethod ("get.offset.seller.assessed.score.of.pu", "OffsetPool", 
function (.Object, PU.to.develop)
  {
      #-------------------------------------------------------
      #  THIS IS ONE PLACE TO INSERT OFFSET UNCERTAINTY, I.E.,
      #  UNCERTAINTY IN ASSESSMENT.
      #-------------------------------------------------------

  # return (get.field.value.of.pu (PU.to.develop, 'TOTAL_HH_SCORE_SUM'));
#  return (get.field.value.of.pu (PU.to.develop, PAR.db.table.field.to.calc.offsets));
  return (get.field.value.of.pu (PU.to.develop,
                                 'OVEREST_ASSESSED_TOTAL_HH_SCORE_SUM'));
  }
)

#==============================================================================

                #-----  get.developer.assessed.score.of.pu  -----#

setGeneric ("get.developer.assessed.score.of.pu", signature = ".Object", 
			function (.Object, PU.to.develop) standardGeneric ("get.developer.assessed.score.of.pu"))
			
#--------------------
 
setMethod ("get.developer.assessed.score.of.pu", "OffsetPool", 
function (.Object, PU.to.develop)
  {
      #-------------------------------------------------------
      #  THIS IS ONE PLACE TO INSERT OFFSET UNCERTAINTY, I.E.,
      #  UNCERTAINTY IN ASSESSMENT.
      #-------------------------------------------------------

  # return (get.field.value.of.pu (PU.to.develop, 'TOTAL_HH_SCORE_SUM'));
#  return (get.field.value.of.pu (PU.to.develop, PAR.db.table.field.to.calc.offsets));
  return (get.field.value.of.pu (PU.to.develop,
                                 'UNDEREST_ASSESSED_TOTAL_HH_SCORE_SUM'));
  }
)

#==============================================================================

                #-----  record.PU.where.last.offset.was.made  -----#

setGeneric ("record.PU.where.last.offset.was.made", signature = ".Object", 
			function (.Object, PU.to.develop, offset.target.PU) standardGeneric ("record.PU.where.last.offset.was.made"))
			
#--------------------
 
setMethod ("record.PU.where.last.offset.was.made", "OffsetPool", 
function (.Object, PU.to.develop, offset.target.PU)
  {
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.develop,
                                         offset.target.PU,
                                         "OFFSET_INTO_PU");
  }
)

#==============================================================================

                #-----  mark.PU.as.leaked  -----#

setGeneric ("mark.PU.as.leaked", signature = ".Object", 
			function (.Object, PU.to.develop) standardGeneric ("mark.PU.as.leaked"))
			
#--------------------
 
setMethod ("mark.PU.as.leaked", "OffsetPool", 
function (.Object, PU.to.develop)
  {
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.develop,
                                         1,
                                         "LEAKED");
  }
)

#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================

                #-----  reserve.and.manage.PU  -----#

setGeneric ("reserve.and.manage.PU", signature = ".Object", 
			function (.Object, PU.to.reserve) standardGeneric ("reserve.and.manage.PU"))
			
#--------------------
 
setMethod ("reserve.and.manage.PU", "OffsetPool", 
function (.Object, PU.to.reserve)
  {

  query <- paste ('select TIME_RESERVED from',
                  dynamicPUinfoTableName,
                  'where ID = ', PU.to.reserve );
  
  cur.time.reserved <- sql.get.data (PUinformationDBname, query)


  # If time reserved is > 0 then this means that the parcel has
  # already been reserved as an offset in the past and that there was
  # an overflow that is still being filled. If this is the case we
  # don't want to update all the info below as it would have already
  # been set when the parcels was first used as an offset. Ascelin Gordon 2011.01.19
  
  if( cur.time.reserved < 0 ) {
      update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                            PU.to.reserve,
                                            current.time.step,
                                            'TIME_RESERVED');
    
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
                                             'TIME_MANAGEMENT_COMMENCED');
      
      set.PU.prob.res.expiring.per.time.step (.Object, 
                                              PU.to.reserve,
                                              OPT.probResExpiringPerTimeStep);
      
      set.PU.prob.man.expiring.per.time.step (.Object, 
                                              PU.to.reserve,
                                              OPT.probManExpiringPerTimeStep);

      query <- paste ('select', PAR.db.table.field.to.calc.offsets,  'from',
                      dynamicPUinfoTableName,
                      'where ID = ', PU.to.reserve );
  
      cur.cond.score.sum <- sql.get.data (PUinformationDBname, query)
      update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                             PU.to.reserve,
                                             cur.cond.score.sum,
                                             'HH_SCORE_AT_OFFSET_TIME' );

  }

  # For debugging
  if ( .Object@name == "outside.gc.offset.pool" ) {

    cur.partial <- .Object@partial.offset
    
    if( cur.time.reserved < 0 ) {
      if(DEBUG.OFFSETTING) cat( '\n%%o T=',current.time.step, 'PU offset', PU.to.reserve,
                               ' HH score at offset time =', cur.cond.score.sum  )
    }
    if(DEBUG.OFFSETTING) cat( '\n%%po T=',current.time.step, 'partial info: ', 'ID:',
                             partial.PU.ID (cur.partial), 'is.active:',
                             partial.is.active (cur.partial),
                             'sum score remaining=', partial.sum.score.remaining (cur.partial))
  }

  if(DEBUG.OFFSETTING) cat ("\n\nIn reserve.and.manage:  <<OFFSETTING IN PU ID ", PU.to.reserve, ">>\n", sep='');
  }
)

#==============================================================================

                #-----  recursive.offset  -----#

setGeneric ("recursive.offset", signature = ".Object", 
			function (.Object, PU.to.develop, amount.of.offset.required, 
			#more.development.allowed, 
			rec.ct) standardGeneric ("recursive.offset"))
			
#--------------------
 
setMethod ("recursive.offset", "OffsetPool", 
function (.Object, PU.to.develop, amount.of.offset.required, 
          #more.development.allowed, 
          rec.ct)
  {
  nameObject <- deparse (substitute (.Object))

    #---------------------------------------------------------------------
    #  NOTE:  The more.development.allowed variable doesn't seem to be
    #         affected by the offsetting right now.
    #         It's only the request for a PU to develop that changes it
    #         right now.  Need to see what that implies about either a
    #         bug or not needing to return it from the recursive calls.
    #---------------------------------------------------------------------

options (warn = 3)   #  Make R warnings be fatal

rec.ct <- rec.ct + 1

  count.test.case (1);        
#  if (DEBUG) 
#    {    
    count.test.case (1);        
     if(DEBUG.OFFSETTING) cat ("\n\n>>>>> STARTING RECURSIVE.OFFSET:",
         "\n    rec.ct = ", rec.ct, 
         "\n    amount.of.offset.required = ", amount.of.offset.required,
         "\n    PU.to.develop             = ", PU.to.develop
#         "\n    vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv", 
#         "\n    tot cpw of PU.to.develop  = ", get.cpw.of (PU.to.develop), 
#         "\n    tot cpw of partial        = ", get.cpw.of (partial.PU.ID (partial.offset (.Object))), 
#         "\n    -----------------------------------------",
#         "\n    tot area of PU.to.develop = ", get.area.of (PU.to.develop), 
#         "\n    tot area of partial       = ", get.area.of (partial.PU.ID (partial.offset (.Object))),
#         "\n    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
         );
    if(DEBUG.OFFSETTING) cat ("\npartial.is.active = ", partial.is.active (partial.offset (.Object)));
    if(DEBUG.OFFSETTING) cat ("\npartial.PU.ID = ", partial.PU.ID (partial.offset (.Object)));
    if(DEBUG.OFFSETTING) cat ("\npartial.sum.score.remaining = ", 
         partial.sum.score.remaining (partial.offset (.Object)));
#    }
    
#  cat ("\n\nIn recursive.offset(), partial.offset (.Object) = ");
#  print (partial.offset (.Object));

  if (partial.is.active (partial.offset (.Object)))
    {
    count.test.case (2);
    if (DEBUG) 
      {
      count.test.case (2);
      if(DEBUG.OFFSETTING) cat ("\n  In recursive.offset()  --  partial offset is active.");
      }

    offset.PU.ID <- partial.PU.ID (partial.offset (.Object));
    offset.remaining.in.partial <- partial.sum.score.remaining (partial.offset (.Object));
    
#  TODO:  NEED TO DEAL WITH THIS GLOBAL VARIABLE.  
#         FIRST, CHANGE NAME TO OFFSET.OVERFLOW.
#         SECOND, MAKE IT AN INSTANCE VARIABLE OF THIS CLASS?

    overflow <<- amount.of.offset.required - offset.remaining.in.partial;

    if( DEBUG ) 
      {
      if( overflow <= 0 ) net.development.score <<- net.development.score + amount.of.offset.required;
      if(DEBUG.OFFSETTING) cat ("\n\n  In recursive.offset()  --  net development score = ",
                                net.development.score);
      }

    if( DEBUG) 
      {
      #cat( "\nlength offset.remaining.in.partial = ", length(offset.remaining.in.partial) );
      #cat( "\nlength overflow = ", length(overflow) );

      if(DEBUG.OFFSETTING) cat ("\n\n  ----------------  In recursive.offset()  --  ");
      if(DEBUG.OFFSETTING) cat ("\n  offset.remaining.in.partial = ", offset.remaining.in.partial);
      if(DEBUG.OFFSETTING) cat ("\n  amount.of.offset.required = ", amount.of.offset.required);
      if(DEBUG.OFFSETTING) cat ("\n  overflow = ", overflow);
  
      #if( overflow <= 0 ) net.development.score <<- net.development.score + amount.of.offset.required;
      #excess.offset.score <<- excess.offset.score + overflow;
      
      #cat ("\n\n  net development score = ", net.development.score);
      #cat ("\n  excess offset score = ", excess.offset.score);
      }

#    if (rec.ct > 10) 
#      {
#      cat ("\n\nrec.ct > 10\n")
#      }

    if (overflow > 0)
      {
      count.test.case (3);        
#      if (DEBUG) 
        {        
        count.test.case (3);        
        if(DEBUG.OFFSETTING) cat ("\n    --------------  In recursive.offset()  --  ");      
        if(DEBUG.OFFSETTING) cat ("\n    offset doesn't fit in partial (overflow > 0)");
        }

          #----------------------------------------------------------        
          #  Offset doesn't fit in current partial.
          #  Add what does fit and then go find a new site to put the
          #  overflow in.
          #----------------------------------------------------------
        
      reserve.and.manage.PU (.Object, offset.PU.ID);  
                                             #  sometimes has already been
                                             #  done, but this also flags
                                             #  the place where you do partial 
                                             #  reserve and manage if that ever
                                             #  becomes an option

      record.PU.where.last.offset.was.made (.Object, PU.to.develop, offset.PU.ID);

      add.to.tot.non.strat.offset.non.leak (.Object, 
                                               offset.remaining.in.partial);
      if(DEBUG) 
        {
        insert.into.offset.testing.db (PU.to.develop, offset.PU.ID, 
                    amount.of.offset.required, offset.remaining.in.partial);
        }
      
    if (rec.ct > 10) 
      {
      if(DEBUG.OFFSETTING) cat ("\n\njust before close.active.partial.offset()\n")
      if(DEBUG.OFFSETTING) print (partial.offset (.Object))
      }
          #  NOTE:  This is a weird quirk of the OOP system.
          #         If I don't create a temporary variable here and do 
          #         the assignment via the temporary, the values 
          #         set in close.active.partial.offser() don't stick 
          #         in the object here, so I have to reassign via x.
          #    NEED TO LOOK FOR OTHER PLACES WHERE THIS MIGHT BE 
          #    HAPPENING, I.E., ASSIGNMENTS TO partial.offset (.Object)
          #    INSIDE A CALL'S ARGUMENT LIST.
          
tmpAssignPO <- partial.offset (.Object)

      close.active.partial.offset (tmpAssignPO);
      
if(DEBUG.OFFSETTING) cat ("tmpAssignPO = \n")
if(DEBUG.OFFSETTING) print (tmpAssignPO)
if(DEBUG.OFFSETTING) cat ("partial.offset (.Object) = \n")
if(DEBUG.OFFSETTING) print (partial.offset (.Object))

      partial.offset (.Object) <- tmpAssignPO
      
if(DEBUG.OFFSETTING) cat ("partial.offset (.Object) = tmpAssignPO = \n")
if(DEBUG.OFFSETTING) print (partial.offset (.Object))      
if(DEBUG.OFFSETTING) cat ("\n\njust after close.active.partial.offset()\n")

          #------------------------------------------------------------------
          #  Recursively call this routine to get new offset for the overflow
          #  that didn't fit in the currently open partial offset.
          #------------------------------------------------------------------

#      more.development.allowed <-     #  Added this assignment 2010.12.21 - BTL      
      .Object <-      #  Added this assignment 2010.12.21 - BTL  
          recursive.offset (.Object, PU.to.develop, overflow, 
#                            more.development.allowed,
                            rec.ct); 
                            
if(DEBUG.OFFSETTING) cat ("\n\nJust after MIDDLE call to recursive.offset() inside recursive.offset(), .Object = \n")
if(DEBUG.OFFSETTING) print (.Object)
                            
                            
        
      } else  #  no overflow, i.e., offset fits in current partial
      {
        count.test.case (4);
      if (DEBUG) 
        {        
        count.test.case (4);
        if(DEBUG.OFFSETTING) cat ("\n    --------------  In recursive.offset()  --  ");      
        if(DEBUG.OFFSETTING) cat ("\n    offset fits completely within partial (overflow <= 0)");
        }

          #------------------------------------------------
          #  Offset fits completely within current partial.
          #  Add what does fit to the total offset so far.
          #------------------------------------------------        
        
      add.to.tot.non.strat.offset.non.leak (.Object, amount.of.offset.required);

      reserve.and.manage.PU (.Object, offset.PU.ID);  
                                             #  sometimes has already been
                                             #  done, but this also flags
                                             #  the place where you do partial 
                                             #  reserve and manage if that ever
                                             #  becomes an option

      record.PU.where.last.offset.was.made (.Object, PU.to.develop, offset.PU.ID);
      
      if(DEBUG) 
        {
        insert.into.offset.testing.db (PU.to.develop, offset.PU.ID, 
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
          count.test.case (5);          
        if (DEBUG) 
          {          
          count.test.case (5);          
          if(DEBUG.OFFSETTING) cat ("\n      ------------  In recursive.offset()  --  ");      
          if(DEBUG.OFFSETTING) cat ("\n      offset exactly uses up partial (overflow == 0)");
          }

      tmpAssignPO <- partial.offset (.Object)
      close.active.partial.offset (tmpAssignPO);
      partial.offset (.Object) <- tmpAssignPO

        } else  #  overflow is not 0
        {
            #-----------------------------------------------------
            #  The amount of leftover is just the underflow, i.e.,
            #  the negative of the overflow value.
            #-----------------------------------------------------          
      
        count.test.case (6);
        if (DEBUG) 
          {          
          count.test.case (6);
            
          if(DEBUG.OFFSETTING) cat ("\n      ------------  In recursive.offset()  --  ");      
          if(DEBUG.OFFSETTING) cat ("\n      offset doesn't use up partial (overflow < 0)");
          }

tmpAssignPO <- partial.offset (.Object)
#      partial.sum.score.remaining (partial.offset (.Object)) <- -overflow;
      partial.sum.score.remaining (tmpAssignPO) <- -overflow;
partial.offset (.Object) <- tmpAssignPO

        }  #  end else - there is more remaining in partial after this offset
      }  #  end else - offset completely fits in current partial
    
    #  -------------------------------------------------------
    #  No partial offset active, so find a new one
    #  -------------------------------------------------------
  } else  
  {
    count.test.case (7);                          
  if (DEBUG) 
    {      
    count.test.case (7);                          
    if(DEBUG.OFFSETTING) cat ("\n  In recursive.offset()  --  no partial offset active.");
    }

        #-----------------------      
        #  Find a new offset PU.
        #-----------------------
      
  offset.PU.ID <- choose.offset.PU (.Object, PU.to.develop);

        # -----------------------
        # Check that there are offsets left in pool. 
        # If none, end offset loop
        # ----------------------
    
  if( offset.PU.ID == CONST.NO.OFFSETS.LEFT )
    {
#    more.development.allowed <- FALSE
    more.dev.allowed (.Object) <- FALSE
    
    } else 
    {
          #--------------
          #  Activate the new offset PU
          #--------------
          
    if(DEBUG.OFFSETTING) cat ("\n\nActivate the new offset PU: ")
    if(DEBUG.OFFSETTING) cat (offset.PU.ID, " ")
    if(DEBUG.OFFSETTING) cat ("\n    with area = ", get.area.of (offset.PU.ID))
    if(DEBUG.OFFSETTING) cat ("\n          cpw = ", get.cpw.of (offset.PU.ID))
    if(DEBUG.OFFSETTING) cat ("\n          hmv = ", get.hmv.of (offset.PU.ID))
    if(DEBUG.OFFSETTING) cat ("\n          mmv = ", get.mmv.of (offset.PU.ID))
    if(DEBUG.OFFSETTING) cat ("\n          lmv = ", get.lmv.of (offset.PU.ID))
    
    if(DEBUG.OFFSETTING) cat ("\n\n------------------------------------------------------------------------------\n") 
#cat ("\n    Just BEFORE open.new.active.partial.offset() that SHOULD MODIFY .Object:",
#     "\n    .Object = \n")
#print (.Object)         
    
    open.new.active.partial.offset (.Object, offset.PU.ID);
  
    if(DEBUG.OFFSETTING) cat ("\n\n--------------------------------------", 
                              "\n    Just AFTER open.new.active.partial.offset() that SHOULD HAVE MODIFIED .Object:",
                              "\n    .Object = \n")
    if(DEBUG.OFFSETTING) print (.Object)         
if(DEBUG.OFFSETTING) cat ("\n\n------------------------------------------------------------------------------\n\n") 

          #----------------
          #  Do the offset - continue offset loop
          #----------------    
  
    .Object <- 
          recursive.offset (.Object, PU.to.develop, amount.of.offset.required,
#                            more.development.allowed, 
                            rec.ct);
                            
#    more.development.allowed <- more.dev.allowed (returned.recursive.offset.pool)

if(DEBUG.OFFSETTING) cat ("\n\nJust after LAST call to recursive.offset() inside recursive.offset(), .Object = \n")
if(DEBUG.OFFSETTING) print (.Object)
                            

    }
  }  #  end else - no partial offset active

  assign (nameObject, .Object, envir=parent.frame())          

#  return (more.development.allowed);
  return (.Object);
  }  #  end function - recursive.offset()
)

#==============================================================================

                #-----  develop.PU  -----#

setGeneric ("develop.PU", signature = ".Object", 
			function (.Object, PU.to.develop, raw.score.of.PU.to.develop) standardGeneric ("develop.PU"))
			
#--------------------
 
setMethod ("develop.PU", "OffsetPool", 
function (.Object, PU.to.develop, raw.score.of.PU.to.develop)
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

  # For debugging
  if ( .Object@name == "outside.gc.offset.pool" ) {
    
    if(DEBUG.OFFSETTING) cat( '\n%%d T=',current.time.step, 'PU developed', PU.to.develop, ' HH score at dev time =', raw.score.of.PU.to.develop )
  }
  
 #----------------------------
      # Note need to connect to the database as sql.send.operation is a
      # low level function that does not automatically connect to
      # PU.to.develop database

  connect.to.database( PUinformationDBname )
  ret <- sql.send.operation (paste ('update', dynamicPUinfoTableName,
                                    'set AREA_OF_C1_CPW_AT_DEV_TIME =
                                    AREA_OF_C1_CPW where ID =',
                                    PU.to.develop))

  ret <- sql.send.operation (paste ('update', dynamicPUinfoTableName,
                                    'set AREA_OF_C2_CPW_AT_DEV_TIME =
                                    AREA_OF_C2_CPW where ID =',
                                    PU.to.develop))

  ret <- sql.send.operation (paste ('update', dynamicPUinfoTableName,
                                    'set AREA_OF_C3_CPW_AT_DEV_TIME =
                                    AREA_OF_C3_CPW where ID =',
                                    PU.to.develop))
  close.database.connection()
#----------------------------


#  TODO:  THIS IS CPW-SPECIFIC.  NEED TO MAKE IT MORE ABSTRACT OR ELSE 
#         SPECIALIZE IT IN A SUBCLASS.

  if (! OPT.use.raster.maps.for.input.and.output) 
    {
        #--------------------------------------------------------------
        #  In this case we want to set the all the CPW entries in the
        #  database to zero for this particular PU
        #--------------------------------------------------------------
    
    set.pu.cpw.fields.zero.in.db (PU.to.develop)
    }
  }
)

#==============================================================================

                #-----  apply.offset.multiplier.to.raw.score  -----#

setGeneric ("apply.offset.multiplier.to.raw.score", signature = ".Object", 
			function (.Object, raw.score.of.PU.to.develop, cur.dev.pool) standardGeneric ("apply.offset.multiplier.to.raw.score"))
			
#--------------------
 
setMethod ("apply.offset.multiplier.to.raw.score", "OffsetPool", 
function (.Object, raw.score.of.PU.to.develop, cur.dev.pool)
  {
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


    amount.of.offset.required <-
        offset.multiplier (cur.dev.pool) * raw.score.of.PU.to.develop;



#  TODO:  This "if" will be eliminated when OffsetPool gets subclassed.

##  if (OPT.do.strategic.offsetting)
##    {
##    amount.of.offset.required <-
##        OPT.strategic.offset.multiplier * raw.score.of.PU.to.develop;
    
##    } else
##    {
##    amount.of.offset.required <-
##        OPT.private.offset.multiplier * raw.score.of.PU.to.develop;
##    }

    if(DEBUG.OFFSETTING) cat ("\n\n+++++  At end of apply.offset.multiplier.to.raw.score(), ",
                              "\n    raw.score.of.PU.to.develop = ", raw.score.of.PU.to.develop,
                              "\n    amount.of.offset.required = ", amount.of.offset.required,
                              "\n"
                              )

  return (amount.of.offset.required);
  }
)

#==============================================================================

                #-----  determine.offset  -----#

setGeneric ("determine.offset", signature = ".Object", 
			function (.Object, PU.to.develop, cur.dev.pool) standardGeneric ("determine.offset"))
			
#--------------------
 
setMethod ("determine.offset", "OffsetPool", 
function (.Object, PU.to.develop, cur.dev.pool)
  {
  nameObject <- deparse (substitute (.Object))

#DEBUG <- TRUE
  
#  more.development.allowed <- TRUE;
#        more.dev.allowed (.Object) <- more.development.allowed
        more.dev.allowed (.Object) <- TRUE


  amount.of.offset.required <- 0.0;

    if (DEBUG) 
      { 
      if(DEBUG.OFFSETTING) cat ("\n\nIn determine.offset() -- Found PU to develop = ", PU.to.develop);
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
    
  if (OPT.use.assessment.uncertainty)
    {
    raw.score.of.PU.to.develop <- get.developer.assessed.score.of.pu (.Object, PU.to.develop);
    
    } else 
    {
    raw.score.of.PU.to.develop <- get.neutral.assessed.score.of.pu (.Object, PU.to.develop);  
    }  
    
    if (DEBUG) 
      {
      if(DEBUG.OFFSETTING) cat ("\n    In determine.offset()  -- raw.score.of.PU.to.develop = ", 
                                raw.score.of.PU.to.develop);
      }


    # Ascelin - new function to determine if offsets are required. 
    
  amount.of.offset.required <- 0
  if(DEBUG.OFFSETTING) cat ("\n    In determine.offset()  -- about to determine.if...() \n")   
  if (determine.if.offset.required (.Object, PU.to.develop)) 
    {
    amount.of.offset.required <-
        apply.offset.multiplier.to.raw.score (.Object, raw.score.of.PU.to.develop, cur.dev.pool);

      # For debugging
      if ( .Object@name == "outside.gc.offset.pool" ) {
        if(DEBUG.OFFSETTING) cat( '\n%%dv T=',current.time.step, 'PU to dev', PU.to.develop,
                                 'Raw score of PU to dev:', raw.score.of.PU.to.develop,
                                 'Full Amt of offset req=', amount.of.offset.required )
      }
    
    
    
    }

OFFSET.SIZE.FOR.DEBUG.OUTPUT <<- amount.of.offset.required
    
    if (DEBUG) 
      {
      if(DEBUG.OFFSETTING) cat ("\n    In determine.offset()  -- amount.of.offset.required = ",
                                amount.of.offset.required);
      }
    
    #-------------------------------------------------
    #   If HH score of PU = 0 then no need to offset
    #-------------------------------------------------

  if (amount.of.offset.required == 0) 
    {
    if(DEBUG.OFFSETTING) cat ("\nIn determine.offset()  --  Zero offset required so moving to next PU");
    
    develop.PU (.Object, PU.to.develop, raw.score.of.PU.to.develop);
    
    } else 
    {
      #--------------------------------------------------------------------------

    if(DEBUG.OFFSETTING) cat ("\nIn determine.offset()  --  Offset required");
      
            #--------------------------------------------------------------
            #  If offsets can leak outside the study area, then with some
            #  probability, you won't have to look for an offset inside the
            #  study area.
            #--------------------------------------------------------------      
        
    if ((OPT.leak.offsets.outside.study.area) && (runif(1) <= OPT.offset.leakage.prob))
      {

            #-------------------------------------------------------------
            #  Leakage is allowed (i.e., offsets can be chosen outside the
            #  study area) and this offset should be leaked.
            #-------------------------------------------------------------
  
      if(DEBUG.OFFSETTING) cat ("\nIn determine.offset()  --  leaking offset");

      develop.PU (.Object, PU.to.develop, raw.score.of.PU.to.develop);
      mark.PU.as.leaked (.Object, PU.to.develop);
  
      add.cur.offset.to.tot.leakage (.Object, amount.of.offset.required);      
  
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
  
        if(DEBUG.OFFSETTING) cat ("\n\nIn determine.offset()  --  Doing strategic offsetting.  ",
                   "Don't need to choose offset.",
                   "\nDevelop the chosen PU.");
  
        develop.PU (.Object, PU.to.develop, raw.score.of.PU.to.develop);
  
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
  
        add.to.tot.strat.offset.non.leak (.Object, amount.of.offset.required);
  
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
  
            if(DEBUG.OFFSETTING) cat ("\n\nIn determine.offset()  --  Doing non-strategic offsetting.  Need to choose offset.");
            if(DEBUG.OFFSETTING) cat ("\n    About to develop.PU() and then recursive.offset().\n\n")
  
        develop.PU (.Object, PU.to.develop, raw.score.of.PU.to.develop);
  
                  #---------------------------------------------------
                  #  Need to look for an offset inside the study area.
                  #---------------------------------------------------
  
  rec.ct <- 0

        .Object <-   
              recursive.offset (.Object, 
                                PU.to.develop,
                                amount.of.offset.required,
#                                more.development.allowed, 
                                rec.ct);
              
###        more.development.allowed <- more.dev.allowed (.Object)


if(DEBUG.OFFSETTING) cat ("\n\nJust after call to recursive.offset() in DETERMINE.OFFSET(), .Object = \n")
if(DEBUG.OFFSETTING) print (.Object)
if(DEBUG.OFFSETTING) cat ("\n\nmore.development.allowed = ", more.development.allowed)


        
  #            do.one.non.strategic.offset (PU.to.develop,
  #                                         more.development.allowed,
  #                                         amount.of.offset.required,
  #                                         raw.score.of.PU.to.develop);
              
              
              if (DEBUG) 
                {
                # connect.to.database( CondDBname );
                #query <- paste( "select TIME_STEP from ",  offsettingGlobalsTableName );
                # ts <- sql(query);  
                #close.database.connection();
                
                if(DEBUG.OFFSETTING) cat ("\n\n  ###----------------");
                if(DEBUG.OFFSETTING) cat ("\n  ###----------------");
                if(DEBUG.OFFSETTING) cat ("\n  In determine.offset()  --  End recursive.offset loop for one PU\n\n");
                #cat ( "\n TIME_STEP = ", ts);
                #cat ("\n  offset.remaining.in.partial = ", offset.remaining.in.partial);
                #cat ("\n  amount.of.offset.required = ", amount.of.offset.required);
                
                #cat ("\n\n  Current PU to develop = ", PU.to.develop);
                #cat ("\n\n  more.development.allowed = ", more.development.allowed);
                }
                    
        }  #  end else - at least one offset left
      }  #  end else - doing non-strategic offsetting
    }  #  end else - offset required

#DEBUG <- FALSE
      
  assign (nameObject, .Object, envir=parent.frame())
  
#  return (more.development.allowed)
  return (.Object)
  
  }  #  end function - determine offset
)

#==============================================================================

    #  Currently, this is not a member of the OffsetPool class, but 
    #  I have moved it in here from loss.model.R because it's most 
    #  related to the offsetting.  

#==============================================================================





