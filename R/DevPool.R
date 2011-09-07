#==============================================================================

                        # source ('DevPool.R');

#rm (list = ls());

#==============================================================================

#  History:

#  BTL - 2010.12.10ish
#  Created for the Sydney Cumberland Plains Woodland project to replace the 
#  existing loss model / offset model call to choose a fixed number of PUs to 
#  develop each time step.  The new version is aimed at averaging a certain 
#  number of hectares developed per time step instead of a certain number of 
#  planning units.  At the moment, it has lots of things specific to Sydney 
#  in it, but these may factor out later if we can convert it to an OOP 
#  representation instead.

#  BTL - 2010.12.12
#  Have attempted to convert this to use R's OOP system.  

#==============================================================================

#  Things that still need work

#  1) Are these hmv or cpw loss rates?  Need to also make sure they're named  
#     correctly in the yaml file:

      #  PAR.initial.inside.gc.cpw.loss.rate <- 39.6    # hectares per yr
      #  PAR.initial.outside.gc.cpw.loss.rate <- 48     
      #      +/- 10 per yr, so, could runif or truncated normal 
      #      in [38 to 58] to get cur rate

#  2) offsetting constraints
#     #90% offset inside gc until 797 ha reached and then all go outside

#  4) may need to update the loss rate(s) on each time step, particularly for outside gc, 
#     e.g., if you want the loss rate to increase over time

#  4a)   #  The label "cur." is used here because we may want to have the target value change 
         #  over the run of the model, e.g., to accomodate increasing development rates.
         
#  4b)   #***  Need to add an runif() call to each time step?
         #initial.outside.gc.cpw.loss.rate <- 48     # +/- 10 per yr, so, could runif or truncated normal 
                                                     #                    in [38 to 58] to get cur rate
         #cur.outside.gc.target.loss.rate.for.ts <- initial.outside.gc.cpw.loss.rate * step.interval
         
#  4c)   #  In the initialization routines for the target rate, I'm using hmv.
         #  Should I be using cpw instead?
         #  See notes around the initialization routines:
         #  initialize.inside.gc.dev.pool.target.loss.rate() and analogous for outside.
         
#  4d)   #  The initialize.inside.gc.dev.pool...() and outside...() need to be converted 
         #  into initialize methods for the corresponding classes, but R doesn't like the 
         #  way I did it.  For the moment, I've just moved the logic into some stanalone 
         #  routines outside the classes.         
         
#  5) assign.PU.to.cur.ts (cur.dev.pool, PU.to.develop)
      #  WHAT HAPPENS WITH ALL THESE RUNNING TOTALS IF OFFSETTING FAILS?
      #  DO WE NEED TO HAVE THESE ONLY AS SCRATCH VALUES UNTIL OFFSET SUCCEEDS
      #  (WHICH IS ALSO MAKING THE ASSUMPTION THAT OFFSETTING IS EVEN BEING DONE).
      
#  6) May need to have a test about the SECURED status of the parcel when building 
      #  the eligibility query since there are interactions between protection 
      #  and tenure security.   
      #  For example, TENURE = "Secured"  (a form of catastrophic loss)

#  7) Clean up final overflow calculation
      
#  8) Make it so that inside and outside are chosen probabilistically instead of 
      #  doing all inside and then all outside.
      
#  9) Probably need to make some kind of distinction between not allowing any more development
      #  this time step and not allowing any more at all (e.g., if all parcels 
      #  have been developed).  However, runs that have to do with protection 
      #  expiring may allow things to change and what formerly could not happen 
      #  will suddenly become possible.  So, maybe this is not such a good idea.
      #  Have to think about it.  
      
# 10) First creation of the dev pools in loss.model.R initializes the running 
      #  totals to 0 by assuming that their prototype values are 0, but 
      #  that's bad to do for several reasons.  Need to change that to 
      #  explicitly set them to zero.  One problem is that in the class 
      #  prototype here, the values are set to CONST.UNINITIALIZED.NON.NEG.NUM, 
      #  which is in fact, already non-negative number so it can't be 
      #  distinguished as unitialized.  Need to clean this up and go back 
      #  to using -77 or something as soon as you get the code in loss.model.R 
      #  corrected to set the 0's explicitly instead of implicitly.
      
# 11) Need to write up intro to using OOP in R.  
      #  One important thing to add is what I discovered this morning about 
      #  the cryptic error message you get when you use the same slot name in 
      #  multiple classes and redefine the generic accessor functions for it 
      #  in each class rather than just once.  It reinforces the need to add 
      #  the check for existance code for generics that is shown in some of 
      #  the tutorial examples.  It should be done automatically!

#==============================================================================

library (methods);

#==============================================================================

    #------------------------------------------------------
    #  Global initializations before starting time steps.
    #------------------------------------------------------

#==============================================================================

source ('constants.R')

CONST.NO.PU.LEFT.TO.DEVELOP <- -88
CONST.NO.ELIGIBLE.PU.TO.DEVELOP <- -33
CONST.NO.OVERFLOW.PU.TO.DEV <- 0

#CONST.UNINITIALIZED.NON.NEG.NUM <- -77
CONST.UNINITIALIZED.NON.NEG.NUM <- 0.0

#==============================================================================
#==============================================================================
#==============================================================================

get.hmv.of <- function (PU.to.develop) 
  {
  query <- paste ('select AREA_OF_C1_CPW from', dynamicPUinfoTableName, 
                  "where ID =", PU.to.develop);
  return (sql.get.data (PUinformationDBname, query))
  }
  
get.mmv.of <- function (PU.to.develop) 
  {
  query <- paste ('select AREA_OF_C2_CPW from', dynamicPUinfoTableName, 
                  "where ID =", PU.to.develop);
  return (sql.get.data (PUinformationDBname, query))
  }
  
get.lmv.of <- function (PU.to.develop) 
  {
  query <- paste ('select AREA_OF_C3_CPW from', dynamicPUinfoTableName, 
                  "where ID =", PU.to.develop);
  return (sql.get.data (PUinformationDBname, query))
  }
  
get.cpw.of <- function (PU.to.develop) 
  {
  query <- paste ('select AREA_OF_CPW from', dynamicPUinfoTableName, 
                  "where ID =", PU.to.develop);

                  retval <- sql.get.data (PUinformationDBname, query)                
                  
#                  cat ("\n\nIn get.cpw.of (", PU.to.develop, "), query = \n")
#                  cat (query)                  
#                  cat ("\nretval = ", retval, "\n\n")
                  
#  return (sql.get.data (PUinformationDBname, query))
  return (retval)
  }
  
get.area.of <- function (PU.to.develop) 
  {
  query <- paste ('select AREA from', dynamicPUinfoTableName, 
                  "where ID =", PU.to.develop);

                  retval <- sql.get.data (PUinformationDBname, query)                
                  
#                  cat ("\n\nIn get.area.of (", PU.to.develop, "), query = \n")
#                  cat (query)                  
#                  cat ("\nretval = ", retval, "\n\n")
                  
#  return (sql.get.data (PUinformationDBname, query))
  return (retval)
  }
  
#==============================================================================
#==============================================================================
#==============================================================================

setClass ("DevPool", 
          representation (DP.db.field.label = "character",

                          name = "character",
                          more.dev.allowed.in.cur.ts = "logical", 
                          cur.tot.cpw.for.ts = "numeric", 

          
                          cur.cpw.tot.developed = "numeric", 
                          cur.hmv.tot.developed = "numeric", 
                          cur.mmv.tot.developed = "numeric", 
                          cur.lmv.tot.developed = "numeric", 
                          
                          offset.multiplier = "numeric",

                              #------------------------------------------------
                              #  The label "cur." is used here because we may 
                              #  want to have the target value change over 
                              #  the run of the model, e.g., to accomodate 
                              #  increasing development rates.
                              #------------------------------------------------
	 	     
                          cur.target.loss.rate.for.ts = "numeric"
						  ),

	 	     prototype (DP.db.field.label = "", 
                                name = "",
	 	                more.dev.allowed.in.cur.ts = TRUE,
	 	                cur.tot.cpw.for.ts = 0.0, 
	 	     
                        cur.cpw.tot.developed = CONST.UNINITIALIZED.NON.NEG.NUM, 
                        cur.hmv.tot.developed = CONST.UNINITIALIZED.NON.NEG.NUM, 
                        cur.mmv.tot.developed = CONST.UNINITIALIZED.NON.NEG.NUM, 
                        cur.lmv.tot.developed = CONST.UNINITIALIZED.NON.NEG.NUM, 
                        
                        offset.multiplier = CONST.UNINITIALIZED.NON.NEG.NUM,

                        cur.target.loss.rate.for.ts = CONST.UNINITIALIZED.NON.NEG.NUM
                        )
              );

###setValidity ("DevPool",
###             function (object) {
###             if (FALSE)
###             {
###               cat ("\n\nDebugging: at start of DevPool::validObject()\n",
###                    "    object@cur.cpw.tot.developed = ", object@cur.cpw.tot.developed, "\n",
###                    "    object@cur.hmv.tot.developed = ", object@cur.hmv.tot.developed, "\n",
###                    "    object@cur.mmv.tot.developed = ", object@cur.mmv.tot.developed, "\n",
###                    "    object@cur.lmv.tot.developed = ", object@cur.lmv.tot.developed, "\n",
###                    "    object@cur.target.loss.rate.for.ts = ", object@cur.target.loss.rate.for.ts, "\n"
###                    );
###               }
###               
###               if (object@cur.cpw.tot.developed < 0)
###                 "cur.cpw.tot.developed must be >= 0"
###               else if (object@cur.hmv.tot.developed < 0)
###                 "cur.hmv.tot.developed must be >= 0"
###               else if (object@cur.mmv.tot.developed < 0)
###                 "cur.mmv.tot.developed must be >= 0"
###               else if (object@cur.lmv.tot.developed < 0)
###                 "cur.lmv.tot.developed must be >= 0"
###               else if (object@cur.tot.cpw.for.ts < 0)
###                 "cur.tot.cpw.for.ts must be >= 0"               
###               else if (object@cur.target.loss.rate.for.ts < 0)
###                 "cur.target.loss.rate.for.ts must be >= 0"
###               else
###                 TRUE
###             }
###             );
                 
#==============================================================================

    #-------------------------------------------------------------
    #  Create the specializations of the DevPool class to handle 
    #  things that are very specific to inside and outside the 
    #  growth center in Sydney.
    #  
    #  Nearly everything can be handled through data values, but
    #  a couple of things currently require the use of special 
    #  methods.
    #-------------------------------------------------------------
   

setClass ("DevPool.inside.gc", 
	 	  prototype = prototype (DP.db.field.label = "INSIDE_GC"),
	 	  contains = "DevPool"
         );
         
#----------

setClass ("DevPool.outside.gc", 
	 	  prototype = prototype (DP.db.field.label = "OUTSIDE_GC"),
	 	  contains = "DevPool"
         );
         
#==============================================================================
#==============================================================================
#==============================================================================
    #  Create generic and specific get and set routines for 
    #  all instance variables.
#==============================================================================

                #-----  DP.db.field.label  -----#
    #  Get    
setGeneric ("DP.db.field.label", signature = "x", 
            function (x) standardGeneric ("DP.db.field.label"))            
setMethod ("DP.db.field.label", "DevPool", 
           function (x) x@DP.db.field.label);

    #  Set    
setGeneric ("DP.db.field.label<-", signature = "x", 
            function (x, value) standardGeneric ("DP.db.field.label<-"))
setMethod ("DP.db.field.label<-", "DevPool", 
           function (x, value) initialize (x, DP.db.field.label = value))


                #-----  name  -----#
    #  Get    
setGeneric ("name", signature = "x", 
            function (x) standardGeneric ("name"))            
setMethod ("name", "DevPool", 
           function (x) x@name);

    #  Set    
setGeneric ("name<-", signature = "x", 
            function (x, value) standardGeneric ("name<-"))
setMethod ("name<-", "DevPool", 
           function (x, value) initialize (x, name = value))


                #-----  more.dev.allowed.in.cur.ts  -----#    
    #  Get    
setGeneric ("more.dev.allowed.in.cur.ts", signature = "x", 
            function (x) standardGeneric ("more.dev.allowed.in.cur.ts"))
setMethod ("more.dev.allowed.in.cur.ts", "DevPool", 
           function (x) x@more.dev.allowed.in.cur.ts);

    #  Set    
setGeneric ("more.dev.allowed.in.cur.ts<-", signature = "x", 
            function (x, value) standardGeneric ("more.dev.allowed.in.cur.ts<-"))
setMethod ("more.dev.allowed.in.cur.ts<-", "DevPool", 
           function (x, value) initialize (x, more.dev.allowed.in.cur.ts = value))


                #-----  cur.tot.cpw.for.ts  -----#    
    #  Get    
setGeneric ("cur.tot.cpw.for.ts", signature = "x", 
            function (x) standardGeneric ("cur.tot.cpw.for.ts"))
setMethod ("cur.tot.cpw.for.ts", "DevPool", 
           function (x) x@cur.tot.cpw.for.ts);

    #  Set    
setGeneric ("cur.tot.cpw.for.ts<-", signature = "x", 
            function (x, value) standardGeneric ("cur.tot.cpw.for.ts<-"))
setMethod ("cur.tot.cpw.for.ts<-", "DevPool", 
           function (x, value) initialize (x, cur.tot.cpw.for.ts = value))


                #-----  cur.cpw.tot.developed  -----#        
    #  Get    
setGeneric ("cur.cpw.tot.developed", signature = "x", 
            function (x) standardGeneric ("cur.cpw.tot.developed"))
setMethod ("cur.cpw.tot.developed", "DevPool", 
           function (x) x@cur.cpw.tot.developed);

    #  Set    
setGeneric ("cur.cpw.tot.developed<-", signature = "x", 
            function (x, value) standardGeneric ("cur.cpw.tot.developed<-"))
setMethod ("cur.cpw.tot.developed<-", "DevPool", 
           function (x, value) initialize (x, cur.cpw.tot.developed = value))


                #-----  cur.hmv.tot.developed  -----#        
    #  Get    
setGeneric ("cur.hmv.tot.developed", signature = "x", 
            function (x) standardGeneric ("cur.hmv.tot.developed"))
setMethod ("cur.hmv.tot.developed", "DevPool", 
           function (x) x@cur.hmv.tot.developed);

    #  Set    
setGeneric ("cur.hmv.tot.developed<-", signature = "x", 
            function (x, value) standardGeneric ("cur.hmv.tot.developed<-"))
setMethod ("cur.hmv.tot.developed<-", "DevPool", 
           function (x, value) initialize (x, cur.hmv.tot.developed = value))


                #-----  cur.mmv.tot.developed  -----#        
    #  Get    
setGeneric ("cur.mmv.tot.developed", signature = "x", 
            function (x) standardGeneric ("cur.mmv.tot.developed"))
setMethod ("cur.mmv.tot.developed", "DevPool", 
           function (x) x@cur.mmv.tot.developed);

    #  Set    
setGeneric ("cur.mmv.tot.developed<-", signature = "x", 
            function (x, value) standardGeneric ("cur.mmv.tot.developed<-"))
setMethod ("cur.mmv.tot.developed<-", "DevPool", 
           function (x, value) initialize (x, cur.mmv.tot.developed = value))


                #-----  cur.lmv.tot.developed  -----#        
    #  Get    
setGeneric ("cur.lmv.tot.developed", signature = "x", 
            function (x) standardGeneric ("cur.lmv.tot.developed"))
setMethod ("cur.lmv.tot.developed", "DevPool", 
           function (x) x@cur.lmv.tot.developed);

    #  Set    
setGeneric ("cur.lmv.tot.developed<-", signature = "x", 
            function (x, value) standardGeneric ("cur.lmv.tot.developed<-"))
setMethod ("cur.lmv.tot.developed<-", "DevPool", 
           function (x, value) initialize (x, cur.lmv.tot.developed = value))


                #-----  offset.multiplier  -----#        
    #  Get    
setGeneric ("offset.multiplier", signature = "x", 
            function (x) standardGeneric ("offset.multiplier"))
setMethod ("offset.multiplier", "DevPool", 
           function (x) x@offset.multiplier);

    #  Set    
setGeneric ("offset.multiplier<-", signature = "x", 
            function (x, value) standardGeneric ("offset.multiplier<-"))
setMethod ("offset.multiplier<-", "DevPool", 
           function (x, value) initialize (x, offset.multiplier = value))


                #-----  cur.target.loss.rate.for.ts  -----#        
    #  Get    
setGeneric ("cur.target.loss.rate.for.ts", signature = "x", 
            function (x) standardGeneric ("cur.target.loss.rate.for.ts"))
setMethod ("cur.target.loss.rate.for.ts", "DevPool", 
           function (x) x@cur.target.loss.rate.for.ts);

    #  Set    
setGeneric ("cur.target.loss.rate.for.ts<-", signature = "x", 
            function (x, value) standardGeneric ("cur.target.loss.rate.for.ts<-"))
setMethod ("cur.target.loss.rate.for.ts<-", "DevPool", 
           function (x, value) initialize (x, cur.target.loss.rate.for.ts = value))

#==============================================================================
    #  Initializers for the classes. 
#==============================================================================

###  FOR SOME REASON, R IS UNHAPPY WITH HOW I'VE DEFINED THESE INITIALIZERS, 
###  BUT I CAN'T FIGURE OUT WHAT THE ERROR MESSAGE MEANS:
###
###    Error in conformMethod(signature, mnames, fnames, f, fdef, definition) : 
###    in method for ‘initialize’ with signature ‘.Object="DevPool.inside.gc"’: 
###    formal arguments (.Object = "DevPool.inside.gc") omitted in the method 
###    definition cannot be in the signature
###
###  SO, FOR THE MOMENT, I'M JUST GOING TO DO THE INITIALIZATION BY HAND 
###  WHEN THE OBJECTS ARE CREATED AND COME BACK TO THIS LATER...


###setMethod (f = "initialize",
###           signature = "DevPool.inside.gc",
###           definition = 
###             function (object, initial.hmv.loss.rate, step.interval)
###               {
###               cat("~~~ DevPool.inside.gc: initializer ~~~ \n")

    #  ARE THESE SUPPOSED TO BE USING THE HMV LOSS RATE?
    #  AREN'T THEY SUPPOSED TO BE USING THE TOTAL CPW LOSS RATE INSTEAD?

                   #  PAR.initial.inside.gc.cpw.loss.rate <- 39.6    # hectares per yr
###               object@cur.target.loss.rate.for.ts <- initial.cpw.loss.rate * step.interval

###               return (object)
###               }
###           )
                 
#----------

###setMethod (f = "initialize",
###           signature = "DevPool.outside.gc",
###           definition = 
###             function (object, initial.hmv.loss.rate, step.interval)
###               {
###               cat("~~~ DevPool.outside.gc: initializer ~~~ \n")

    #  ARE THESE SUPPOSED TO BE USING THE HMV LOSS RATE?
    #  AREN'T THEY SUPPOSED TO BE USING THE TOTAL CPW LOSS RATE INSTEAD?

                   #  PAR.initial.outside.gc.cpw.loss.rate <- 48     
                   #      +/- 10 per yr, so, could runif or truncated normal 
                   #      in [38 to 58] to get cur rate
###               object@cur.target.loss.rate.for.ts <- initial.cpw.loss.rate * step.interval

###               return (object)
###               }
###           )
                 
#==============================================================================

                #-----  initialize.dev.pool.running.totals.at.start.of.ts  -----#

setGeneric ("initialize.dev.pool.running.totals.at.start.of.ts", signature = "cur.dev.pool", 
			function (cur.dev.pool) standardGeneric ("initialize.dev.pool.running.totals.at.start.of.ts"))
			
#--------------------
 
      #  Need to reload the running totals from the database.
      #  This really should be done in the initialize routine for the classes, 
      #  but I haven't got that working correctly yet.
    
setMethod ("initialize.dev.pool.running.totals.at.start.of.ts", "DevPool", 
function (cur.dev.pool)
  {	    
  nameObject <- deparse (substitute (cur.dev.pool))

      #  Figure out whether the field names use "INSIDE_GC" or "OUTSIDE_GC". 
  cur.DP.db.field.label <- DP.db.field.label (cur.dev.pool) 
  if(DEBUG.OFFSETTING) cat ("     cur.DP.db.field.label = <", cur.DP.db.field.label, ">\n")
  
      #  CPW running total
  query <- paste ('select CPW_TOT_DEV_', cur.DP.db.field.label, ' from ', offsettingWorkingVarsTableName,
                  sep='')
  cur.cpw.tot.developed (cur.dev.pool) <- sql.get.data (PUinformationDBname, query)

      #  HMV running total
  query <- paste ('select HMV_TOT_DEV_', cur.DP.db.field.label, ' from ', offsettingWorkingVarsTableName,
                  sep='')
  cur.hmv.tot.developed (cur.dev.pool) <- sql.get.data (PUinformationDBname, query)

      #  MMV running total
  query <- paste ('select MMV_TOT_DEV_', cur.DP.db.field.label, ' from ', offsettingWorkingVarsTableName,
                  sep='')
  cur.mmv.tot.developed (cur.dev.pool) <- sql.get.data (PUinformationDBname, query)

      #  LMV running total
  query <- paste ('select LMV_TOT_DEV_', cur.DP.db.field.label, ' from ', offsettingWorkingVarsTableName,
                  sep='')
  cur.lmv.tot.developed (cur.dev.pool) <- sql.get.data (PUinformationDBname, query)

####  dummy setting to see if it registers anywhere...
####  cur.dev.pool@cur.lmv.tot.developed <- 52

  if(DEBUG.OFFSETTING) cat ("In initialize.dev.pool.running.totals.at.start.of.ts: \n");
  if(DEBUG.OFFSETTING) cat ("    current.time.step = ", current.time.step, "\n");
  if(DEBUG.OFFSETTING) cat ("    cur.dev.pool = \n");
  if(DEBUG.OFFSETTING) print (cur.dev.pool)
  
  assign (nameObject, cur.dev.pool, envir=parent.frame())
  }
 )
 
#==============================================================================

                #-----  save.cur.dev.pool.running.totals  -----#

setGeneric ("save.cur.dev.pool.running.totals", signature = "cur.dev.pool", 
			function (cur.dev.pool) standardGeneric ("save.cur.dev.pool.running.totals"))
			
#--------------------
 
setMethod ("save.cur.dev.pool.running.totals", "DevPool", 
function (cur.dev.pool)
  {	  
      #  Set these to 0 at the very start of the model.
      #  DON'T reset them to 0 every time you start a time step.
      #  DO retrieve their values from the database at the start of 
      #  each time step.
          
      #  Need to initialize all of these in the workingvars database at the start of the model and 
      #  then reload their values into these variables at the start of each time step 
      #  by reading their values out of the database.

  connect.to.database( PUinformationDBname );
  
      #-----

  if(DEBUG.OFFSETTING) cat ("\n\nIn save.cur.dev.pool.running.totals():")                          

      #  Figure out whether the field names use "INSIDE_GC" or "OUTSIDE_GC". 
  cur.DP.db.field.label <- DP.db.field.label (cur.dev.pool)
  if(DEBUG.OFFSETTING) cat ("\n    cur.DP.db.field.label = ", cur.DP.db.field.label)
  
      #  CPW running total
  query <- paste ('update ', offsettingWorkingVarsTableName,
                             ' set CPW_TOT_DEV_', cur.DP.db.field.label, ' = ', 
                             cur.cpw.tot.developed (cur.dev.pool), 
                             sep = '' )
  if(DEBUG.OFFSETTING) cat ("\n    CPW running total query = ", query)
  sql.send.operation (query)

      #  HMV running total
  query <- paste ('update ', offsettingWorkingVarsTableName,
                             ' set HMV_TOT_DEV_', cur.DP.db.field.label, ' = ',  
                             cur.hmv.tot.developed (cur.dev.pool), 
                             sep = '' )
  if(DEBUG.OFFSETTING) cat ("\n    HMV running total query = ", query)
  sql.send.operation (query)


      #  MMV running total
  query <- paste ('update ', offsettingWorkingVarsTableName,
                             ' set MMV_TOT_DEV_', cur.DP.db.field.label, ' = ',  
                             cur.mmv.tot.developed (cur.dev.pool), 
                             sep = '' )
  if(DEBUG.OFFSETTING) cat ("\n    MMV running total query = ", query)
  sql.send.operation (query)

      #  LMV running total
  query <- paste ('update ', offsettingWorkingVarsTableName,
                             ' set LMV_TOT_DEV_', cur.DP.db.field.label, ' = ',  
                             cur.lmv.tot.developed (cur.dev.pool), 
                             sep = '' )
  if(DEBUG.OFFSETTING) cat ("\n    LMV running total query = ", query)
  sql.send.operation (query)


      #-----

  close.database.connection();    
  
  if(DEBUG.OFFSETTING) cat ("\n\nAt end of DevPool::save.cur.dev.pool.running.totals()\n")
  if(DEBUG.OFFSETTING) cat ("    Are these totals saved correctly in the db?\n",
                            "    They're 0 when reloaded at the start of the next time step (except for tot cpw).\n")
  if(DEBUG.OFFSETTING) print (cur.dev.pool)
  }
)

#==============================================================================
#***
#------------------------------------------------------------------------------
    #  These things should be in the initialize() routine for each class, but 
    #  R is giving me an error message that I can't figure out, so I'll do it 
    #  by hand here.
#------------------------------------------------------------------------------
#***
#------------------------------------------------------------------------------
#  ARE THESE SUPPOSED TO BE USING THE HMV LOSS RATE?
#  AREN'T THEY SUPPOSED TO BE USING THE TOTAL CPW LOSS RATE INSTEAD?
#------------------------------------------------------------------------------

                #-----  initialize.inside.gc.dev.pool.target.loss.rate  -----#

setGeneric ("initialize.dev.pool.target.loss.rate", signature = "cur.dev.pool", 
			function (cur.dev.pool) standardGeneric ("initialize.dev.pool.target.loss.rate"))
			
#--------------------
 
                                  #  inside gc  #

setMethod ("initialize.dev.pool.target.loss.rate", "DevPool.inside.gc", 
function (cur.dev.pool)
  {
  nameObject <- deparse (substitute (cur.dev.pool))
  
  #step.interval <- 5
  cur.target.loss.rate.for.ts (cur.dev.pool) <- 
                                   PAR.initial.inside.gc.cpw.loss.rate * step.interval

if(DEBUG.OFFSETTING) cat ("\n\nIn initialize.dev.pool.target.loss.rate:  INSIDE gc.\n")
if(DEBUG.OFFSETTING) cat ("    current.time.step = ", current.time.step, "\n");
if(DEBUG.OFFSETTING) cat ("    PAR.initial.inside.gc.cpw.loss.rate = ", PAR.initial.inside.gc.cpw.loss.rate, "\n")
if(DEBUG.OFFSETTING) cat ("    step.interval = ", step.interval, "\n")
if(DEBUG.OFFSETTING) cat ("    cur.target.loss.rate.for.ts (cur.dev.pool) = ", cur.target.loss.rate.for.ts (cur.dev.pool), "\n")

  assign (nameObject, cur.dev.pool, envir=parent.frame())
  }
)

#---------------------------------------------

                                  #  outside gc  #

setMethod ("initialize.dev.pool.target.loss.rate", "DevPool.outside.gc", 
function (cur.dev.pool)
  {
  nameObject <- deparse (substitute (cur.dev.pool))

  #step.interval <- 5
  cur.target.loss.rate.for.ts (cur.dev.pool) <- 
                                   PAR.initial.outside.gc.cpw.loss.rate * step.interval

if(DEBUG.OFFSETTING) cat ("\n\nIn initialize.dev.pool.target.loss.rate:  OUTSIDE gc.\n")
if(DEBUG.OFFSETTING) cat ("    current.time.step = ", current.time.step, "\n");
if(DEBUG.OFFSETTING) cat ("    PAR.initial.outside.gc.cpw.loss.rate = ", PAR.initial.outside.gc.cpw.loss.rate, "\n")
if(DEBUG.OFFSETTING) cat ("    step.interval = ", step.interval, "\n")
if(DEBUG.OFFSETTING) cat ("    cur.target.loss.rate.for.ts (cur.dev.pool) = ", cur.target.loss.rate.for.ts (cur.dev.pool), "\n")
                                   
  assign (nameObject, cur.dev.pool, envir=parent.frame())
  }
)

#==============================================================================

                #-----  choose.offset.pool  -----#

setGeneric ("choose.offset.pool", signature = ".Object", 
			function (.Object) standardGeneric ("choose.offset.pool"))
			
#--------------------
 
      #---------------------------------------------------------------------
      #  This function is where you would designate an offset to be leaked 
      #  outside the study area, but I haven't done that yet because 
      #  we haven't discussed how that would work yet.
      #---------------------------------------------------------------------
  
#--------------------
 
setMethod ("choose.offset.pool", "DevPool.outside.gc", 
function (.Object)
  {
  if(DEBUG.OFFSETTING) cat ('\nOffset should go OUTSIDE GC')
  
  return ( CONST.dev.OUT.offset.OUT)
  }
)

#--------------------
 
setMethod ("choose.offset.pool", "DevPool.inside.gc", 
function (.Object)
  {  
  offset.location <- CONST.dev.IN.offset.IN
  
  if (runif(1) < PAR.prob.that.inside.gc.is.offset.inside.gc) 
    {
    if(DEBUG.OFFSETTING) cat ('\nOffset should go INSIDE GC')
    
    } else 
    {
    offset.location <- CONST.dev.IN.offset.OUT    
    if(DEBUG.OFFSETTING) cat ('\nOffset should go OUTSIDE GC')
    }

  return (offset.location)
  }  
)

#==============================================================================

    #-----------------------------------------------------------------------
    #  Utility functions, particularly related to dealing with overflow of 
    #  development from one time step to the next.
    #
    #  At the moment, these are just dummy calls that need to be replaced 
    #  with database interactions whose tables have not been set up yet.
    #-----------------------------------------------------------------------    

#==============================================================================

                #-----  assign.PU.to.cur.ts  -----#

setGeneric ("assign.PU.to.cur.ts", signature = "cur.dev.pool", 
			function (cur.dev.pool, PU.to.develop) standardGeneric ("assign.PU.to.cur.ts"))
			
#--------------------
 
setMethod ("assign.PU.to.cur.ts", "DevPool", 
function (cur.dev.pool, PU.to.develop)
  {	  
  nameObject <- deparse (substitute (cur.dev.pool))

        #  WHAT HAPPENS WITH ALL THESE RUNNING TOTALS IF OFFSETTING FAILS?
        #  DO WE NEED TO HAVE THESE ONLY AS SCRATCH VALUES UNTIL OFFSET SUCCEEDS
        #  (WHICH IS ALSO MAKING THE ASSUMPTION THAT OFFSETTING IS EVEN BEING DONE).
        
        #  May need to store the incremental values added in the working table as well 
        #  (e.g., the result of the get.cpw.of (PU.to.develop), get.hmv.of... calls here) 
        #  so that you can undo the changes made here if offsetting fails.

  cur.cpw.tot.developed (cur.dev.pool) <- cur.cpw.tot.developed (cur.dev.pool) + get.cpw.of (PU.to.develop) 
  cur.hmv.tot.developed (cur.dev.pool) <- cur.hmv.tot.developed (cur.dev.pool) + get.hmv.of (PU.to.develop)
  cur.mmv.tot.developed (cur.dev.pool) <- cur.mmv.tot.developed (cur.dev.pool) + get.mmv.of (PU.to.develop)
  cur.lmv.tot.developed (cur.dev.pool) <- cur.lmv.tot.developed (cur.dev.pool) + get.lmv.of (PU.to.develop)

      #  The values above are for overall running totals over the whole run.
      #  This one is just for what's been developed in the current time step.
      #  It's used for doing overflow calculations.
  cur.tot.cpw.for.ts (cur.dev.pool) <- cur.tot.cpw.for.ts (cur.dev.pool) + get.cpw.of (PU.to.develop)


  if(DEBUG.OFFSETTING) cat ("\n\nIn assign.PU.to.cur.ts:  <DEVELOPING PU ID ", PU.to.develop, ">\n");


  assign (nameObject, cur.dev.pool, envir=parent.frame())
  }
)  #  end - setMethod assign.PU.to.cur.ts

#==============================================================================

                #-----  select.PUs.currently.eligible.for.dev  -----#

setGeneric ("select.PUs.currently.eligible.for.dev", signature = "cur.dev.pool", 
			function (cur.dev.pool) standardGeneric ("select.PUs.currently.eligible.for.dev")) 
			
#--------------------
 
setMethod ("select.PUs.currently.eligible.for.dev", "DevPool", 
function (cur.dev.pool)
  {
  query <- build.eligibility.query (cur.dev.pool)
  
  eligible.PUs <- (sql.get.data (PUinformationDBname, query))
  if(DEBUG.OFFSETTING) cat ("\n\nIn select.PUs.currently.eligible.for.dev:\n")
  if(DEBUG.OFFSETTING) cat ("    current.time.step = ", current.time.step, "\n");
  if(DEBUG.OFFSETTING) cat ("    num of eligible.PUs = ", length (eligible.PUs), "\n")
  if(DEBUG.OFFSETTING) cat ("    eligible.PUs = ", eligible.PUs [1:5], "...\n")
  if(DEBUG.OFFSETTING) cat ("    Dev Query = ", query, "\n" )
  return (eligible.PUs)
  }
)

#==============================================================================

                #-----  build.eligibility.query  -----#

setGeneric ("build.eligibility.query", signature = "cur.dev.pool", 
			function (cur.dev.pool) standardGeneric ("build.eligibility.query"))
			
#--------------------
 
      #  NEED TO TEST FOR 2 DIFFERENT KINDS OF THINGS HERE?
      #  I.E., ONE IS ABOUT OVERFLOW TO THE NEXT STEP AND THE OTHER IS ABOUT EXCEEDING THE TOTAL
      #  ALLOWED AMOUNT OF DEVELOPMENT FOR EACH CPW CLASS (HMV, MMV, LMV).
      #  ONCE A CHOSEN PARCEL WOULD EXCEED ONE OR MORE OF THE LIMITS, THEN IT NEEDS TO BE REMOVED 
      #  FROM THE DEVELOPMENT POOL SINCE IT WILL NEVER BE UNDER THE LIMIT AFTER THAT.
		
#  *****
#  NOTE: THAT ASSUMES THAT THE LIMITS WILL NOT BE RESET LATER IN THE MODEL RUN AND 
#        THAT THE LIMIT IS ON AMOUNT DEVELOPED, NOT ON TOTAL AVAILABLE IN THE LANDSCAPE.  
#        IF MANAGEMENT ALLOWED FOR INCREASE IN CONDITION, THE TOTAL AMOUNT COULD INCREASE 
#        (OR DECREASE) OVER TIME.  THIS SUGGESTS A POLICY QUESTION ABOUT WHETHER THE 
#        DEVELOPMENT SHOULD BE GOVERNED BY MECHANISM OR BY OUTCOME.  
#        SHOULD MODEL THESE TWO CHOICES TO HIGHLIGHT THIS.
		
#        If mechanism is the driver, then you do not have to make the check again once you 
#        have exceeded the limit.  If outcome is the driver, then you have to keep checking.  
#        One other thing though - outcome could be phrased as trying to stay around the 
#        target with falling back to the target from a higher point allowed (i.e., if your 
#        proposed development does not drop the total below the target level, then go ahead, 
#        even though it does cause loss) 
#        or it could be phrased as never allowing any gain to be lost.
#  *****

#--------------------
 
setMethod ("build.eligibility.query", "DevPool.inside.gc", 
function (cur.dev.pool)
  {	  		
        #  Need to compute the amount of space left under each cpw cap
        
    hmv.space.left.under.limit.inside.gc <- 
            PAR.hmv.limit.inside.gc - cur.hmv.tot.developed (cur.dev.pool)
    mmv.space.left.under.limit.inside.gc <- 
            PAR.mmv.limit.inside.gc - cur.mmv.tot.developed (cur.dev.pool)
    lmv.space.left.under.limit.inside.gc <- 
            PAR.lmv.limit.inside.gc - cur.lmv.tot.developed (cur.dev.pool)

    query <- paste ('select ID from ', dynamicPUinfoTableName, 
                    'where DEVELOPED = 0',
                    'and GROWTH_CENTRE = 1',
                    'and TENURE = "Unprotected"',                    
                    'and RESERVED = 0',
                    'and GC_CERT = 1', 
                    'and AREA_OF_C1_CPW <=', hmv.space.left.under.limit.inside.gc,
                    'and AREA_OF_C2_CPW <=', mmv.space.left.under.limit.inside.gc,
                    'and AREA_OF_C3_CPW <=', lmv.space.left.under.limit.inside.gc
                   )

  return (query)
  }
)

#--------------------
 
setMethod ("build.eligibility.query", "DevPool.outside.gc", 
function (cur.dev.pool)
  {	  
      #  for OUTSIDE gc, there are no tests other than staying around the 
      #  outside gc loss rate.


  # Moving part of this to the yaml file - Ascelin Gordon 2011.01.19
  ## query <- paste ('select ID from ', dynamicPUinfoTableName, 
  ##                 'where DEVELOPED = 0',
  ##                 'and GROWTH_CENTRE = 0',
  ##                 'and TENURE = "Unprotected"',                                      
  ##                 'and RESERVED = 0'
  ##                )

  query <- paste ('select ID from', dynamicPUinfoTableName,  'where', PAR.dev.outside.GC.criteria )

  return (query)
  }
)
 
#==============================================================================

                #-----  make.sure.overflow.dev.PU.is.still.legal  -----#

setGeneric ("make.sure.overflow.dev.PU.is.still.legal", signature = "cur.dev.pool", 
			function (cur.dev.pool, overflow.PU) standardGeneric ("make.sure.overflow.dev.PU.is.still.legal"))
			
#--------------------
 
setMethod ("make.sure.overflow.dev.PU.is.still.legal", "DevPool", 
function (cur.dev.pool, overflow.PU)
  {
  eligible.PUs <- select.PUs.currently.eligible.for.dev (cur.dev.pool) 
  
  if(DEBUG.OFFSETTING) cat ("\n\nIn make.sure.overflow.dev.PU.is.still.legal:\n")
  if(DEBUG.OFFSETTING) cat ("    current.time.step = ", current.time.step, "\n");
  if(DEBUG.OFFSETTING) cat ("    overflow.PU = ", overflow.PU, "\n")
  if(DEBUG.OFFSETTING) cat ("    num of eligible.PUs = ", length (eligible.PUs), "\n")
  if(DEBUG.OFFSETTING) cat ("    any (eligible.PUs == overflow.PU) = ", any (eligible.PUs == overflow.PU), "\n")
  if(DEBUG.OFFSETTING) cat ("    eligible.PUs = ", eligible.PUs [1:5], "...\n")
  
  return (any (eligible.PUs == overflow.PU))    #  Returns TRUE of overflow.PU is in the list
  }
)
  
#==============================================================================

                #-----  get.overflow.PU.from.prev.ts.to.develop  -----#

setGeneric ("get.overflow.PU.from.prev.ts.to.develop", signature = "cur.dev.pool", 
			function (cur.dev.pool) standardGeneric ("get.overflow.PU.from.prev.ts.to.develop"))
			
#--------------------
 
setMethod ("get.overflow.PU.from.prev.ts.to.develop", "DevPool", 
function (cur.dev.pool)
  {	  
  query <- paste ('select ', 
                  DP.db.field.label (cur.dev.pool), '_DEV_OVERFLOW_PU_ID from ', 
                  offsettingWorkingVarsTableName, sep = '');

  return (sql.get.data (PUinformationDBname, query));    #  overflow PU to develop
  }
)

#==============================================================================

                #-----  prev.ts.left.overflow.PU.to.develop  -----#

setGeneric ("prev.ts.left.overflow.PU.to.develop", signature = "cur.dev.pool", 
			function (cur.dev.pool) standardGeneric ("prev.ts.left.overflow.PU.to.develop"))
			
#--------------------
 
setMethod ("prev.ts.left.overflow.PU.to.develop", "DevPool", 
function (cur.dev.pool)
  {
  if(DEBUG.OFFSETTING) cat ("\n\nIn prev.ts.left.overflow.PU.to.develop:\n")     
  if(DEBUG.OFFSETTING) cat ("    current.time.step = ", current.time.step, "\n");
  
  overflow.PU.from.prev <- get.overflow.PU.from.prev.ts.to.develop (cur.dev.pool) 
  
  if(DEBUG.OFFSETTING) cat ("    overflow.PU.from.prev = ", overflow.PU.from.prev)
  
  return (overflow.PU.from.prev
              != 
          CONST.NO.OVERFLOW.PU.TO.DEV)
  }
)

#==============================================================================

                #-----  compute.overflow.fraction.for.PU.to.develop  -----#

setGeneric ("compute.overflow.fraction.for.PU.to.develop", signature = "cur.dev.pool", 
			function (cur.dev.pool, PU.to.develop) standardGeneric ("compute.overflow.fraction.for.PU.to.develop"))
			
#--------------------
 
setMethod ("compute.overflow.fraction.for.PU.to.develop", "DevPool", 
function (cur.dev.pool, PU.to.develop)
  {
  overflow.fraction <- 0.0
  
  cur.PU.cpw <- get.cpw.of (PU.to.develop)
  if (cur.PU.cpw < 0)
    {
    errMsg <- paste ("\n\nERROR in compute.overflow.fraction.for.PU.to.develop():",
                     "\n    cur.PU.cpw = ", cur.PU.cpw, "  --  Must be >= 0.\n\n", sep='')
    stop (errMsg)
    
    } else if (cur.PU.cpw > 0)
    {
  
        #----------------------------------------------------------------------
       #  Compute what the running cpw total will be if this PU is developed
        #  and what fraction of the PU's area will be overflowing the current 
        #  target rate for development in this time step.
        #----------------------------------------------------------------------

    next.inside.gc.tot.cpw.for.ts <- cur.tot.cpw.for.ts (cur.dev.pool) + cur.PU.cpw  	  
    overflow.fraction <- 
        (next.inside.gc.tot.cpw.for.ts - cur.target.loss.rate.for.ts (cur.dev.pool)) / 
	    cur.PU.cpw
    
    if(DEBUG.OFFSETTING) cat ("\n\nIn compute.overflow.fraction.for.PU.to.develop\n")
    if(DEBUG.OFFSETTING) cat ("    current.time.step = ", current.time.step, "\n");
    if(DEBUG.OFFSETTING) cat ("    PU.to.develop = ", PU.to.develop, "\n")
    if(DEBUG.OFFSETTING) cat ("    --- cur.cpw.tot.developed (cur.dev.pool)       = ",
                              cur.cpw.tot.developed (cur.dev.pool), "\n")
    if(DEBUG.OFFSETTING) cat ("    --- cur.tot.cpw.for.ts (cur.dev.pool)          = ",
                              cur.tot.cpw.for.ts (cur.dev.pool), "\n")
    if(DEBUG.OFFSETTING) cat ("    --- cur.PU.cpw                      = ", cur.PU.cpw, "\n")
    if(DEBUG.OFFSETTING) cat ("    --- next.inside.gc.tot.cpw.for.ts              = ",
                              next.inside.gc.tot.cpw.for.ts, "\n")
    if(DEBUG.OFFSETTING) cat ("    --- cur.target.loss.rate.for.ts (cur.dev.pool) = ",
                              cur.target.loss.rate.for.ts (cur.dev.pool), "\n\n")
    if(DEBUG.OFFSETTING) cat ("    overflow.fraction = ", overflow.fraction, "\n")
  }

  return (overflow.fraction)		             
  }		  
)

#==============================================================================

                #-----  set.dev.overflow.PU.from.prev.ts  -----#

setGeneric ("set.dev.overflow.PU.from.prev.ts", signature = "cur.dev.pool", 
			function (cur.dev.pool, value) standardGeneric ("set.dev.overflow.PU.from.prev.ts"))
			
#--------------------

setMethod ("set.dev.overflow.PU.from.prev.ts", "DevPool", 
function (cur.dev.pool, value)
  {
  query <- paste ('update ', offsettingWorkingVarsTableName, ' set ', 
                  DP.db.field.label (cur.dev.pool), '_DEV_OVERFLOW_PU_ID = ',
                  value,
                  sep = '')
    
  connect.to.database( PUinformationDBname );
  sql.send.operation (query); 
  close.database.connection();    
  }
)

#==============================================================================

                #-----  clear.record.of.dev.overflow.from.prev.ts  -----#

setGeneric ("clear.record.of.dev.overflow.from.prev.ts", signature = "cur.dev.pool", 
			function (cur.dev.pool) standardGeneric ("clear.record.of.dev.overflow.from.prev.ts"))
			
#--------------------
 
setMethod ("clear.record.of.dev.overflow.from.prev.ts", "DevPool", 
function (cur.dev.pool)
  {
  set.dev.overflow.PU.from.prev.ts (cur.dev.pool, CONST.NO.OVERFLOW.PU.TO.DEV)
  }
)

#==============================================================================

                #-----  push.PU.to.next.ts  -----#

setGeneric ("push.PU.to.next.ts", signature = "cur.dev.pool", 
			function (cur.dev.pool, PU.to.develop) standardGeneric ("push.PU.to.next.ts"))
			
#--------------------
 
setMethod ("push.PU.to.next.ts", "DevPool", 
function (cur.dev.pool, PU.to.develop)
  {
  set.dev.overflow.PU.from.prev.ts (cur.dev.pool, PU.to.develop)
  }
)

#==============================================================================

                #-----  choose.dev.PU.from.set.that.has.been.restricted.to.only.legal.possibilities  -----#

setGeneric ("choose.dev.PU.from.set.that.has.been.restricted.to.only.legal.possibilities", signature = "cur.dev.pool", 
			function (cur.dev.pool, PUs.currently.eligible.for.dev) standardGeneric ("choose.dev.PU.from.set.that.has.been.restricted.to.only.legal.possibilities"))
			
#--------------------
 
setMethod ("choose.dev.PU.from.set.that.has.been.restricted.to.only.legal.possibilities", "DevPool", 
function (cur.dev.pool, PUs.currently.eligible.for.dev)
  {
      #  By default, just choose one at random.  
      #  However, this could be a fancier, project or pool-specific choice, 
      #  e.g., using a distribution that weights some sizes or types more heavily.
      
      #  That's why I have put the cur.dev.pool argument in the list 
      #  even though it's currently not used.
      #  I anticipate this to be an instance method of the dev.pool class 
      #  and that would require the pool.
      
  PU.to.develop <- sample.rdv (PUs.currently.eligible.for.dev, 1);
  
  return (PU.to.develop)
  }
)  

#==============================================================================
#==============================================================================

                #-----  choose.PU.to.develop  -----#

#setGeneric ("choose.PU.to.develop", signature = "cur.dev.pool", 
#			function (cur.dev.pool) standardGeneric ("choose.PU.to.develop"))
setGeneric ("choose.PU.to.develop.OOP", signature = "cur.dev.pool", 
			function (cur.dev.pool) standardGeneric ("choose.PU.to.develop.OOP"))
			
#--------------------
 
#setMethod ("choose.PU.to.develop", "DevPool", 
setMethod ("choose.PU.to.develop.OOP", "DevPool", 
function (cur.dev.pool)
  {  
  nameObject <- deparse (substitute (cur.dev.pool))

  PU.to.develop <- CONST.NO.ELIGIBLE.PU.TO.DEVELOP
  
  if(DEBUG.OFFSETTING) cat ("\n\n===================================================================================\n\n",
               "At start of choose.PU.to.develop.OOP at ", "\n",
               "  >>>>> current.time.step = ", current.time.step, "\n", 
               "  >>>>> cur.dev.pool@DP.db.field.label = ", cur.dev.pool@DP.db.field.label, "\n",
               "  >>>>> cur.tot.cpw.for.ts (cur.dev.pool)          = ", cur.tot.cpw.for.ts (cur.dev.pool), "\n",
               "  >>>>> cur.target.loss.rate.for.ts (cur.dev.pool) = ", cur.target.loss.rate.for.ts (cur.dev.pool), "\n\n",
               "    cur.dev.pool@cur.cpw.tot.developed = ", cur.dev.pool@cur.cpw.tot.developed, "\n",
               "    cur.dev.pool@cur.hmv.tot.developed = ", cur.dev.pool@cur.hmv.tot.developed, "\n",
               "    cur.dev.pool@cur.mmv.tot.developed = ", cur.dev.pool@cur.mmv.tot.developed, "\n",
               "    cur.dev.pool@cur.lmv.tot.developed = ", cur.dev.pool@cur.lmv.tot.developed, "\n",
               "    cur.dev.pool@cur.target.loss.rate.for.ts = ", cur.dev.pool@cur.target.loss.rate.for.ts
               );

  more.dev.allowed.in.cur.ts (cur.dev.pool) <- TRUE  
  select.new.PU.to.dev <- TRUE
  dev.PU.in.this.ts <- TRUE

      #--------------------------------------------------
      #  Check for overflow PU from previous time step.  
      #  If there is one, then just return that PU.  
      #  Otherwise, have to look for one.
      #--------------------------------------------------

  if(DEBUG.OFFSETTING) cat ("\n\nAbout to test prev.ts.left.overflow.PU.to.develop at ts = ",
                            current.time.step, "\n")        
  if (prev.ts.left.overflow.PU.to.develop (cur.dev.pool))
    {	  
        #----------------------------------------------------------------------
        #  Parcel overflowed from previous time step.
        #  Get its ID and turn off the overflow marker since you're using up
        #  the overflow now.
        #----------------------------------------------------------------------

    if(DEBUG.OFFSETTING) cat ("\n\nAbout to test prev.ts.left.overflow.PU.to.develop.\n")        
    PU.to.develop <- get.overflow.PU.from.prev.ts.to.develop (cur.dev.pool)
    if(DEBUG.OFFSETTING) cat ("\n\nAbout to clear.record.of.dev.overflow.from.prev.ts.\n")        
    clear.record.of.dev.overflow.from.prev.ts (cur.dev.pool)
    
    PU.to.dev.is.legal <- 
        make.sure.overflow.dev.PU.is.still.legal (cur.dev.pool, PU.to.develop)
    if(DEBUG.OFFSETTING) cat ("\n\nAfter make.sure.overflow.dev.PU.is.still.legal (cur.dev.pool, ",
                              PU.to.develop, ").\n")        
    if(DEBUG.OFFSETTING) cat ("    PU.to.dev.is.legal = ", PU.to.dev.is.legal, "\n")
            
    if (PU.to.dev.is.legal)
      {
          #----------------------------------------------------------------------------
          #  The previous step pushed a development to this step and it's still legal
          #  so do it.
          #----------------------------------------------------------------------------

#      assign.PU.to.cur.ts (cur.dev.pool, PU.to.develop)
      select.new.PU.to.dev <- FALSE
      dev.PU.in.this.ts <- TRUE   #  already true, but just want to point it out here 

      } else
      {
      
          #--------------------------------------------------------------------------          
          #  Overflow PU is no longer legal.
          #  This shouldn't happen, but it does.
          #  Not sure if it's a bug or what...
          ###### There may be a problem here with overflow PU not getting marked 
          ###### as ineligible for development, e.g., after inside.gc claims it 
          ###### for overflow, but doesn't mark it as developed and then outside.gc
          ###### or offsetting come along and use it before inside.gc gets another 
          ###### chance at it?
          ###### 
          ###### If you mark it as DEVELOPED though, then it won't be seen as 
          ###### eligible on the next round, so it probably needs a bit more 
          ###### special attention than it's getting right now...
          #--------------------------------------------------------------------------
          
      more.dev.allowed.in.cur.ts (cur.dev.pool) <- FALSE 
            
      if(DEBUG.OFFSETTING) cat ("\n\nWARNING, POSSIBLE BUG:\n",
                                "    In choose.PU.to.develop: <<FAILED OVERFLOW PU ", PU.to.develop, ">> ", 
                                " for ", DP.db.field.label (cur.dev.pool), "\n",
                                "    Overflow from previous time step is no longer legal.\n", sep='');
             
             #----------------------------------------------------------------------------          
             #  UNTIL WE HAVE THIS STRAIGHTENED OUT, JUST GET A DIFFERENT PU TO DEVELOP.
             #----------------------------------------------------------------------------          

      select.new.PU.to.dev <- TRUE   #  already true, but just want to point it out here          
#      stop ()
      }  #  end else - PU to develop is not legal
    }   #  end if - previous time step left overflow PU to develop
    
        #-------------------------------------------------------------------------------------
        #  Have now determined that either:
        #    a) there was no overflow from previous step and we need to pick a PU to develop
        #          or
        #    b) there was an overflow and it's still legal so it has now been developed 
        #       and there's nothing left to do in this call except check that developing 
        #       that PU has not overflowed the current time step as well.  We'll do that 
        #       check at the very end of the routine and the only consequence if it does 
        #       overflow is to say that we shouldn't develop any more PUs this time step.
        #          or
        #    c) there was an overflow but for some reason, it is no longer legal. 
        #       While this is probably a bug that we need to fix, for the moment we want 
        #       to just ignore the problem and just pick a new PU to develop so that we 
        #       can get some runs done.  If it IS an error, then it only happens very 
        #       occasionally and doesn't screw anything up other than the probability 
        #       of the offending patch getting picked.
        #-------------------------------------------------------------------------------------
    
    if (select.new.PU.to.dev)
      {	  
      PUs.currently.eligible.for.dev <- select.PUs.currently.eligible.for.dev (cur.dev.pool)
      
      if (length (PUs.currently.eligible.for.dev) < 1)  #  is.null()?  is.NA()??
        {
        more.dev.allowed.in.cur.ts (cur.dev.pool) <- FALSE
        dev.PU.in.this.ts <- FALSE
      
            #      cat ("\n\nERROR: In choose.PU.to.develop, ", 
            #             "\n           no legal PUs to develop.\n\n");
            #      stop ()
        } else    # end if - no PUs eligible to develop
        {
            #---------------------------------------------------------------------------------
            #  There ARE PUs eligible to develop.
            #  Choose one and see whether it overflows the target amount for this time step.
            #---------------------------------------------------------------------------------
          
        PU.to.develop <- 
          choose.dev.PU.from.set.that.has.been.restricted.to.only.legal.possibilities (
                                               cur.dev.pool, PUs.currently.eligible.for.dev)
      
            #----------------------------------------------------
            #  See if it fits in current time step's allotment.
            #----------------------------------------------------

        overflow.fraction <- compute.overflow.fraction.for.PU.to.develop (cur.dev.pool, PU.to.develop)
    
                if(DEBUG.OFFSETTING) cat ("\n\noverflow.fraction = ", overflow.fraction, "\n")    
    
        if (overflow.fraction > 0)
          {
		  			#----------------------------------------------------------------------		  		
                    #  Parcel does not fit inside current time step.
		  			#  Flip a biased coin to see whether to include it anyway. 
		  			#   
		  			#  Bias the flip in inverse proportion to the amount of overflow, 
		  			#  i.e., the more overflow, the less chance of including in 
		  			#  current time step.
		  			#
		  			#  Also mark the fact that you have come to the end of the time step.
		  			#----------------------------------------------------------------------
		  			
          if (runif (1) < overflow.fraction)
            {
		        #---------------------------------------------------
			    #  Lost the toss.  Move this PU to next time step.
			    #---------------------------------------------------

                    if(DEBUG.OFFSETTING) cat ("\n\nIn choose.PU.to.develop:  lost the toss, <<PUSHING PU ID ",
                                              PU.to.develop, 
                                              ">> to next time step for ",
                                              DP.db.field.label (cur.dev.pool), "\n", sep='');
            push.PU.to.next.ts (cur.dev.pool, PU.to.develop)
            dev.PU.in.this.ts <- FALSE
        
            }  else  #  end if - lost the runif() toss  
            {
                    if(DEBUG.OFFSETTING) cat ("\n\nIn choose.PU.to.develop:  won the toss for ", PU.to.develop, 
                         " in ", DP.db.field.label (cur.dev.pool), "\n", sep='');
                         
            }  #  end else - won the toss
          }  #  end if - PU to develop overflows current time step	
        }  #  end else - there were PUs eligible to develop                  
      }  #  end if - no overflow from previous time step

    if (dev.PU.in.this.ts)	
      {
      assign.PU.to.cur.ts (cur.dev.pool, PU.to.develop)
      }		                 

        #---------------------------------------------------------------------------
        #  No matter what action was taken in this routine, there is a possibility 
        #  that it has led to an overflow that has been accepted.  
        #  Check for that now and if it has occurred, then you should not allow 
        #  any more development in this time step.
        #---------------------------------------------------------------------------

    final.overflow <- cur.dev.pool@cur.tot.cpw.for.ts - cur.dev.pool@cur.target.loss.rate.for.ts   
    if(DEBUG.OFFSETTING) cat ("\n\nAt end of choose.PU.to.develop, final overflow = ", 
                              final.overflow, "\n")        
    if (final.overflow > 0)
      {
           if(DEBUG.OFFSETTING) cat ("\n\nIn choose.PU.to.develop:  ", DP.db.field.label (cur.dev.pool), 
                                     "\n    Positive overflow, so stopping dev for this time step.\n", sep='');
      more.dev.allowed.in.cur.ts (cur.dev.pool) <- FALSE
      }
     
         #-------------------------------------------------------------------------
         #  If you're ending the time step, save the running totals to use on the 
         #  next time step.
         #-------------------------------------------------------------------------
         
     if (! more.dev.allowed.in.cur.ts (cur.dev.pool))
       {
       save.cur.dev.pool.running.totals (cur.dev.pool)
       }
    

  assign (nameObject, cur.dev.pool, envir=parent.frame())    
  return (PU.to.develop)
  
  }  #  end function - choose.PU.to.develop  
) 
	  
#==============================================================================

    #---------------------------------------------
    #  Functions that are not part of the class.
    #---------------------------------------------
    
#==============================================================================

example.model.code <- function ()
  {
      #  At start of model, need to initialize running totals, etc.
      
  inside.gc.dev.pool <- new ("DevPool.inside.gc")
      #  Initialize dev pool running totals in db to 0.
      #  Can use the save...() routine because the dev pool initial values 
      #  are 0 when they are created.
  stopifnot (cur.cpw.tot.developed (cur.dev.pool) == 0.0)  #  Check that assumption.
  save.cur.dev.pool.running.totals (inside.gc.dev.pool)
  }

#==============================================================================

initialize.dev.pools.at.start.of.model  <- function ()
  {
  initialize.dev.pool.running.totals.at.start.of.model ("INSIDE_GC")
  initialize.dev.pool.running.totals.at.start.of.model ("OUTSIDE_GC")
  }
  
#==============================================================================
#==============================================================================

    #--------------------------------------------------------------------------
    #  Dummy global control code to emulate running a full set of time steps.
    #--------------------------------------------------------------------------

#==============================================================================

                #-----  execute.cpw.test.ts  -----#

    #  Strictly for testing inside a dummy loop over model time steps.  
    #  Can remove this routine if desired.
    #  It DOES show how things are expected to be set up and called.
    
execute.cpw.test.ts <- function ()
  {    
  inside.gc.dev.pool <- new ("DevPool.inside.gc")  
  outside.gc.dev.pool <- new ("DevPool.outside.gc")
  
      #-----------------------------------------------
  
  initialize.dev.pools.at.start.of.model ()

      #-----------------------------------------------
      
###  while (more.dev.allowed.in.cur.ts (inside.gc.dev.pool))
###    {
###    cat ("\n\n====================================================",
###         "\n\nAt ts = ", cur.ts, ", before choose.PU...()", 
###         PU.to.develop);
    
######    PU.to.develop <- choose.PU.to.develop (cur.dev.pool)        
    
###    }
  }
  
#==============================================================================

##current.time.step <- 15
##step.interval <- 5
##PAR.initial.inside.gc.cpw.loss.rate <- 10
##x <- new ("DevPool.inside.gc")
##cat ("\n\nx after new = \n")
##print (x)
##initialize.dev.pool.target.loss.rate (x)
##cat ("\n\nx after initialize.dev.pool.target.loss.rate = \n")
##print (x)




