#==============================================================================

# source( 'loss.model.R' );

#==============================================================================

rm( list = ls( all=TRUE ));

#==============================================================================

# CONST.in.dev.in.offset <- 1
# CONST.in.dev.out.offset <- 2
# CONST.out.dev.out.offset <- 3
source ('constants.R')

    #----------------------------------------------------------------------    
    #  NEED TO MOVE THESE 4 VARIABLES OUT OF HERE AND INTO THE YAML FILE.
    #----------------------------------------------------------------------    
    

#==============================================================================

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'w.R' )
source( 'dbms.functions.R' )
source( 'variables.R' )
source( 'random.development.R' )

source ('DevPool.R')

#source( 'offset.model.R' )
if( OPT.use.offsetting.in.loss.model ) source( 'OffsetPool.R' )   # xxx 

source( 'utility.functions.R' )
source( 'loss.model.functions.R' )

#==============================================================================

# for now this assumes that loss units are Planning Units.
# can make PUs and patches the same if you want to have
# patches being lost.

# Note this needs to be called with current.time.step = 0.
# This initialises the time zero hab map with no loss 

#------------------------------------------------------------------------------

initialise.loss.model <- function() 
  {
  cat( '\nIn initialise offset model' );

  if( OPT.use.raster.maps.for.input.and.output ) 
    {
    # write out time zero hab map without any loss
    init.hab.map <- as.matrix ( read.table( master.habitat.map.zo1.filename ))

    cur.loss.model.file.name <-  paste (loss.model.root.filename,
                                        '0', sep = "")
    write.to.3.forms.of.files(init.hab.map, cur.loss.model.file.name,rows,cols)    
    }

  # also initialise the offset model if being used

  # this code reads in the maps dev_pool_mask.txt and
  # offset_pool_mask.txt and the calculates which PUs are in each
  # pool and sets IN_DEV_POOL IN_OFFSET_POOL values for those PUs in
  # dynamicPUinfoTableName table in the PUinformationDBname database.
  
  if( OPT.specify.development.pool.with.map |
     OPT.specify.offset.pool.with.map ) 
    {

    # only call this code if either offset pool or development pool is
    # specified with a map
      
    source( "determine.PUs.in.offset.and.dev.pools.R" )
    }

#----------


   if( OPT.use.offsetting.in.loss.model ) initialize.partial.offset.db.values ()  # xxx  

#  THIS PARTIAL INFORMATION ISN'T EVEN USED ANYWHERE ON TIME STEP 0 IS IT?
#  CAN WE JUST GET RID OF IT ALTOGETHER ON TIME STEP 0.
#  THE LACK OF USE MAY EXPLAIN THE COMMENT BELOW AS WELL.

      #  Added this call to make sure that the db values are retrieved AFTER 
      #  they have been loaded by the initializer on this first time step.
      #  Until now, the call to get.global...() was only done in offset.model.R 
      #  and that is sourced at the start of this file, so on the first step,
      #  the get was done before there was anything in the database since it 
      #  had not been initialized yet.  
      #  It did not seem to cause any problems, but I am not sure why.  
      #  In any case, I will fix it here, now.  
      #  I have also added an if statement around the call to get...() in 
      #  offset.model.R so that it no longer calls get...() on time step 0.
      #  BTL - 2010.12.01
	
  stopifnot (current.time.step == 0);  #  The following call assumes first time step.


   # xxx PUT AN if( OPT.use.offsetting.in.loss.model )  AROUND ALL THE REST OF THIS FUNCTION


  #----------------------
  if( OPT.use.offsetting.in.loss.model ) {
  
    inside.gc.offset.pool <- new ("OffsetPool", name="inside.gc.offset.pool" )
    if(DEBUG.OFFSETTING) cat ("\n\nAfter inside.gc.offset.pool <- new (OffsetPool)\n")
    if(DEBUG.OFFSETTING) print (inside.gc.offset.pool)

    tmpAssignPO <- partial.offset (inside.gc.offset.pool)
    PO.db.field.label (tmpAssignPO) <- "INSIDE_GC"
    #  get.global.values.for.any.active.partial.offset (partial.offset (inside.gc.offset.pool))
    get.global.values.for.any.active.partial.offset (tmpAssignPO)
    partial.offset (inside.gc.offset.pool) <- tmpAssignPO
    
  
  
    #----------------------
  
    outside.gc.offset.pool <- new ("OffsetPool", name="outside.gc.offset.pool")
    if(DEBUG.OFFSETTING) cat ("\n\nAfter outside.gc.offset.pool <- new (OffsetPool)\n")
    if(DEBUG.OFFSETTING) print (outside.gc.offset.pool)

    tmpAssignPO <- partial.offset (outside.gc.offset.pool)
    PO.db.field.label (tmpAssignPO) <- "OUTSIDE_GC"
    #  get.global.values.for.any.active.partial.offset (partial.offset (outside.gc.offset.pool))
    get.global.values.for.any.active.partial.offset (tmpAssignPO)
    partial.offset (outside.gc.offset.pool) <- tmpAssignPO

  
  
    #-------------------------------------------------------------------
    #  Initialize running totals for development to be 0.
    #  Can use the save...() routine because the dev pool initial values 
    #  are 0 when they are created.
    #  Added 2010.12.12 - BTL.      
    #
    #  NOTE: These calls currently need to made after the call to 
    #        initialize the partial offset db values because that 
    #        call creates the working vars db record that these will 
    #        update.  Otherwise, you have to do an "insert into" to 
    #        create the record and then the initialization of offset 
    #        partials needs to do an update instead of an "insert into".
    #
    #  TODO: It's a bad idea to do this based on an external assumption.
    #        Need to fix the code here to set the values to 0 explicitly.
    #-------------------------------------------------------------------
    inside.gc.dev.pool <- new ("DevPool.inside.gc", name="inside.gc.dev.pool")
    if(DEBUG.OFFSETTING) cat ("\n\ninside.gc.dev.pool = \n");
    if(DEBUG.OFFSETTING) print (inside.gc.dev.pool);
    stopifnot (cur.cpw.tot.developed (inside.gc.dev.pool) == 0.0)  #  Check 0 assumption.
    
    save.cur.dev.pool.running.totals (inside.gc.dev.pool)
    set.dev.overflow.PU.from.prev.ts (inside.gc.dev.pool, CONST.NO.OVERFLOW.PU.TO.DEV)
    
    outside.gc.dev.pool <- new ("DevPool.outside.gc", name="outside.gc.dev.pool")
    if(DEBUG.OFFSETTING) cat ("\n\noutside.gc.dev.pool = \n");
    if(DEBUG.OFFSETTING) print (outside.gc.dev.pool);
    stopifnot (cur.cpw.tot.developed (outside.gc.dev.pool) == 0.0)  #  Check 0 assumption.
    
    save.cur.dev.pool.running.totals (outside.gc.dev.pool)
    set.dev.overflow.PU.from.prev.ts (outside.gc.dev.pool, CONST.NO.OVERFLOW.PU.TO.DEV)
    
  } # end  if( OPT.use.offsetting.in.loss.model )  xxx
  
  #-------------------------------------------------------------------
  
  }  #  end - initialise.loss.model function

#==============================================================================

    #--------------------------------------------------------------------------
    #  Replacing test.offsetting.standalone() with a new version of it called 
    #  test.offsetting.fixed.num.PUs.per.time.step().  
    #  Have renamed a copy of the old routine above just to have as a backup.
    #  It is called test.offsetting.fixed.num.PUs.per.time.step().
    #  Will probably want to put the two routines back together into one 
    #  again once everything is working separately and we have figured out 
    #  a generic way to control them, but for now, this is safer.
    #
    #  The main difference between the two routines is that in the new one 
    #  we want to be able to control the area that gets developed rather than 
    #  just the number of parcels.
    #
    #  BTL - 2010.12.12
    #--------------------------------------------------------------------------

##test.offsetting.standalone <- function (num.PUs.to.develop)
#test.offsetting.approx.dev.rate.per.time.step <- function ()

        #  Changing the name to reflect what it really does.
develop.with.offsets.using.approx.dev.rate.for.one.time <- function ()
  {
  if (DEBUG) 
    {    
    if(DEBUG.OFFSETTING) cat ("\n\n================================================================");
    }
    
      #------------------------
      #  Create offset pools.
      #------------------------

        #-------------------------
        #  inside.gc OFFSET pool
        #-------------------------

  if(DEBUG.OFFSETTING) cat ("\n\nAbout to create offset pools and partials.\n\n")

  inside.gc.offset.pool <- new ("OffsetPool", name="inside.gc.offset.pool" )
  OP.db.field.label (inside.gc.offset.pool) <- "INSIDE_GC"
  #cat ("\n\nAfter inside.gc.offset.pool <- new (OffsetPool)\n")
  #print (inside.gc.offset.pool)

  tmpAssignPO <- partial.offset (inside.gc.offset.pool)
  PO.db.field.label (tmpAssignPO) <- "INSIDE_GC"
  #  get.global.values.for.any.active.partial.offset (partial.offset (inside.gc.offset.pool))
  get.global.values.for.any.active.partial.offset (tmpAssignPO)
  partial.offset (inside.gc.offset.pool) <- tmpAssignPO

  cur.offset.pool <- inside.gc.offset.pool    #  default - value may change during offsetting

  if(DEBUG.OFFSETTING) cat ("\nInitalized inside.gc.offset.pool = \n")
  if(DEBUG.OFFSETTING) print (inside.gc.offset.pool)

        #--------------------------
        #  outside.gc OFFSET pool
        #--------------------------
      
  outside.gc.offset.pool <- new ("OffsetPool", name="outside.gc.offset.pool")
  OP.db.field.label (outside.gc.offset.pool) <- "OUTSIDE_GC"
  #cat ("\n\nAfter outside.gc.offset.pool <- new (OffsetPool)\n")
  #print (outside.gc.offset.pool)

  tmpAssignPO <- partial.offset (outside.gc.offset.pool)
  PO.db.field.label (tmpAssignPO) <- "OUTSIDE_GC"
  #  get.global.values.for.any.active.partial.offset (partial.offset (outside.gc.offset.pool))
  get.global.values.for.any.active.partial.offset (tmpAssignPO)
  partial.offset (outside.gc.offset.pool) <- tmpAssignPO

  if(DEBUG.OFFSETTING) cat ("\nInitalized outside.gc.offset.pool = \n")
  if(DEBUG.OFFSETTING) print (outside.gc.offset.pool)

      #--------------------------------------------------------------------    
      #  This is very important:
      #  Need to update the HH scores to match the current condition.
      #  If we do it here, then we don't have to make sure HH is updated
      #  every time condition is updated in the condition model.
      #  Also, this gives us one central place to add error to the HH score
      #  if want to.
      #--------------------------------------------------------------------

  set.scores.for.all.PUs (inside.gc.offset.pool);
  set.scores.for.all.PUs (outside.gc.offset.pool);

          #-----------------------------------------------------------------
          #  Sometimes they want to start the offsetting into a particular 
          #  planning unit (e.g., Shane's Park).  
          #  If they've given a planning unit ID for that, then open a 
          #  partial offset on it as a way of forcing that to be where 
          #  offsets go until it is exhausted.
          #-----------------------------------------------------------------
          #  Added the second test to make sure this is only called on the first
          #  nonzero timestep: 
          #  (current.time.step == step.interval) 
          #  BTL and AG 2011.01.06
          #-----------------------------------------------------------------
          #  Moved this "if" block down so that it occurs after the 
          #  calls to set.scores.for.all.PUs().  
          #  When it was called earlier, the assessed value of the 
          #  specified planning unit had not been intialized from the 
          #  database yet and later attempts to access it would get 
          #  an integer(0) error indicating that it did not have a value.
          #  BTL - 2011.01.17
          #-----------------------------------------------------------------
  
  if ( (PAR.initial.inside.gc.offset.PU.ID > 0) & (current.time.step == step.interval)  )
    {
    open.new.active.partial.offset (inside.gc.offset.pool, PAR.initial.inside.gc.offset.PU.ID)
    if(DEBUG.OFFSETTING) cat ("\n\nAfter open.new.active...() on inside.gc.offset.pool")
    }
    
  if (DEBUG) 
    {
    if(DEBUG.OFFSETTING) cat ("\n\nDone setting HH scores for all PUs.");
    }
    
      #------------------------------------------------------------------
      #  Initialize the inside gc and outside gc development pools.
      #
      #  Have to a couple of extra calls beyond the "new" here because 
      #  I was doing something wrong in R's eyes when I tried to create 
      #  an initializer directly.  Will have to fix that later when I 
      #  understand more.  For now, this will take care of getting the 
      #  running totals and the target development rates initialized.
      #------------------------------------------------------------------

      #----------------------
      #  inside.gc DEV pool
      #----------------------
      
  inside.gc.dev.pool <- new ("DevPool.inside.gc", name="inside.gc.dev.pool")  
  initialize.dev.pool.target.loss.rate (inside.gc.dev.pool)
  initialize.dev.pool.running.totals.at.start.of.ts (inside.gc.dev.pool)
  offset.multiplier (inside.gc.dev.pool) <- PAR.inside.gc.offset.multiplier

  if(DEBUG.OFFSETTING) cat ("\n\nAfter inside.gc.dev.pool <- new (DevPool.inside.gc)\n")
  if(DEBUG.OFFSETTING) print (inside.gc.dev.pool)

      #----------------------
      #  outside.gc DEV pool
      #----------------------
      
  outside.gc.dev.pool <- new ("DevPool.outside.gc", name="outside.gc.dev.pool")
  initialize.dev.pool.target.loss.rate (outside.gc.dev.pool)
  initialize.dev.pool.running.totals.at.start.of.ts (outside.gc.dev.pool)
  offset.multiplier (outside.gc.dev.pool) <- PAR.outside.gc.offset.multiplier

  if(DEBUG.OFFSETTING) cat ("\n\nAfter outside.gc.dev.pool <- new (DevPool.outside.gc)\n")
  if(DEBUG.OFFSETTING) print (outside.gc.dev.pool)

      #------------------------------------------------------
      #  Now ready to loop through developing and offsetting.
      #------------------------------------------------------
#ascelin testing

#  TODO:  CHANGE THESE SO THAT YOU DON'T DO ALL OF ONE AREA BEFORE THE OTHER.
#         NEED TO CHOOSE PROBABILISTICALLY AT EVERY STEP.

  for (cur.dev.pool in c(inside.gc.dev.pool, outside.gc.dev.pool))
#  for (cur.dev.pool in c(outside.gc.dev.pool))
#  for (cur.dev.pool in c(inside.gc.dev.pool))
    {
    i = 0

#----------------------------------------------------------------------------------- 
#        Something like this will go here but it will require changing the while() 
#        below and the for() above to make it work.  
#        For the moment, I don't want to break anything so I won't include it yet.
#
#    cur.dev.pool <- choose.dev.pool (inside.gc.dev.pool, outside.gc.dev.pool)
#----------------------------------------------------------------------------------- 
    
    while (more.dev.allowed.in.cur.ts (cur.dev.pool))
      {
      i = i + 1
      if(DEBUG.OFFSETTING) cat ("\n\n>>> At try.to.dev call number ", i, "\n")
#-------------------------------------------------------      
#  REPLACING THIS CALL WITH THE INLINE CODE BELOW
#      if (! try.to.develop.one.PU.OOP (cur.dev.pool))
      
      more.development.allowed <- TRUE;
  
      PU.to.develop <- choose.PU.to.develop.OOP (cur.dev.pool);

      if(DEBUG.OFFSETTING) cat ("\n\nAfter choose.PU.to.develop.OOP (cur.dev.pool), cur.dev.pool = \n")
      if(DEBUG.OFFSETTING) print (cur.dev.pool)
    
      if (more.dev.allowed.in.cur.ts (cur.dev.pool))
        {
            #----------------------------------  
            #  There is something to develop.
            #  Determine the offset.
            #----------------------------------     
        
                #----------------------------------------------------------------
                #  Figure out whether the offset goes inside or outside the gc.
                #----------------------------------------------------------------

        cur.offset.loc <- choose.offset.pool (cur.dev.pool)

                #------------------------------------------------------------
                #  Set offsetting to use the corresponding search criteria.
                #------------------------------------------------------------

        currently.offsetting.inside <- TRUE
        if (cur.offset.loc == CONST.dev.IN.offset.IN)
          {
          cur.offset.pool <- inside.gc.offset.pool
###cat ("\n\nJust before available...\n")
          available.for.offset.criteria (cur.offset.pool) <- offsetRules [[PAR.offsetRule.in.in]]
          if(DEBUG.OFFSETTING) cat ("\n--- available...() is IN IN")
          
          } else
          {
          if (cur.offset.loc == CONST.dev.IN.offset.OUT)
            {
            cur.offset.pool <- outside.gc.offset.pool
            available.for.offset.criteria (cur.offset.pool) <- offsetRules [[PAR.offsetRule.in.out]]
            currently.offsetting.inside <- FALSE
            if(DEBUG.OFFSETTING) cat ("\n--- available...() is IN OUT")
            
            } else
            {
            cur.offset.pool <- outside.gc.offset.pool
            available.for.offset.criteria (cur.offset.pool) <- offsetRules [[PAR.offsetRule.out.out]]
            currently.offsetting.inside <- FALSE
            if(DEBUG.OFFSETTING) cat ("\n--- available...() is OUT OUT")
            }
          }

                      
        if(DEBUG.OFFSETTING) cat ("\n\nIn develop.with.offsets.using.approx.dev.rate.for.one.time() ")
        if(DEBUG.OFFSETTING) cat ("\nJust BEFORE determine.offset()\n")
        if(DEBUG.OFFSETTING) cat ("\ncurrently.offsetting.inside = ", currently.offsetting.inside)
        if(DEBUG.OFFSETTING) cat ("\n    PU.to.develop = ", PU.to.develop);
        if(DEBUG.OFFSETTING) cat ("\n    cur.offset.pool = \n");
        if(DEBUG.OFFSETTING) print (cur.offset.pool)

OFFSET.SIZE.FOR.DEBUG.OUTPUT <<- 0


#        more.development.allowed <- 

        cur.offset.pool <- 
                determine.offset (cur.offset.pool, PU.to.develop, cur.dev.pool)

        more.development.allowed <- more.dev.allowed (cur.offset.pool)

        if (currently.offsetting.inside)
          {
          inside.gc.offset.pool <- cur.offset.pool
          
          } else
          {
          outside.gc.offset.pool <- cur.offset.pool
          }
 
 if(DEBUG.OFFSETTING) cat ("\n\n---------------------                                  ---------------------\n")
 if(DEBUG.OFFSETTING) cat ("\n    more.development.allowed = ", more.development.allowed)
 if(DEBUG.OFFSETTING) cat ("\n    cur.offset.pool = \n")
 if(DEBUG.OFFSETTING) print (cur.offset.pool)
 if(DEBUG.OFFSETTING) cat ("\n\nOFFSET.SIZE.FOR.DEBUG.OUTPUT = ", OFFSET.SIZE.FOR.DEBUG.OUTPUT)
 if(DEBUG.OFFSETTING) cat ("\n\n---------------------  Just AFTER determine.offset().  ---------------------\n")
 
        } else
        {
            #-----------------------------------
            #  Nothing left to develop, so quit.
            #-----------------------------------
      
        more.development.allowed <- FALSE;
    
#        cat ("\n\nNOTHING LEFT TO DEVELOP, so, stopping development.\n");

        if(DEBUG.OFFSETTING) cat ("\n\nIn develop.with.offsets.using.approx.dev.rate.for.one.time() ",
             "\n    set more.dev.allowed.in.cur.ts (cur.dev.pool) ",
             "to FALSE.\n    Now setting more.development.allowed to FALSE");
        if(DEBUG.OFFSETTING) cat ("\nPU.to.develop = ", PU.to.develop);
        if(DEBUG.OFFSETTING) cat ("\ncur.offset.pool = \n");
        if(DEBUG.OFFSETTING) print (cur.offset.pool)
        
        } 
    
      if (DEBUG) 
        {  
        if(DEBUG.OFFSETTING) cat ("\n\n");
        }
      
      if (! more.development.allowed)
      
#  END OF INLINE REPLACEMENT
#-------------------------------------------------------      
        {
          if(DEBUG.OFFSETTING) cat ("---------------------------------------");        
          if(DEBUG.OFFSETTING) cat ("\n\n---- In test.offsetting.approx.dev.rate.per.time.step() for loop at i = ", i,
               ".\n",
               "---- try.to.develop.one.PU.OOP() returned FALSE.  ",
               "\n---- Breaking now.", sep='');          
          if(DEBUG.OFFSETTING) cat ("\n\n---------------------------------------");          
          
        break;    #  develop failed - break out of for num.PUs.to.develop
        
        }  #  end if - ! try.to.develop.one.PU()

        if(DEBUG.OFFSETTING) cat ("\n\n---------------------------------------");
      }  #  end while - more dev allowed this time step
      
    save.cur.dev.pool.running.totals (cur.dev.pool)
    
    }  #  end for - cur.dev.pool  
      
  if(DEBUG.OFFSETTING) cat ("\n\nAt end of loss model step, about save.offsetting.global.variables.",
     "\n    outside.gc.offset.pool = \n")
  if(DEBUG.OFFSETTING) print (outside.gc.offset.pool)
      
  save.offsetting.global.variables (outside.gc.offset.pool);

  if(DEBUG.OFFSETTING) cat ("\n\nAt end of loss model step, about save.offsetting.global.variables.",
     "\n    inside.gc.offset.pool = \n")
  if(DEBUG.OFFSETTING) print (inside.gc.offset.pool)
     
  save.offsetting.global.variables (inside.gc.offset.pool);

  if (DEBUG) {
    if(DEBUG.OFFSETTING) cat ("\n\n At end of test.offsetting.approx.dev.rate.per.time.step():",
         
         "\n    tot.STRATEGIC.offset.score.non.leakage = ",
         tot.strat.offset.non.leak (cur.offset.pool),
         "\n        NOTE: *** Is the final offset total > what was set aside ",
         "in DSE's pooled strategic set-aside? ***\n", 
         
         "\n    tot.non.strategic.offset.score.NON.leakage = ",
         tot.non.strat.offset.non.leak (cur.offset.pool),
         
         "\n    tot.non.strategic.offset.score.LEAKAGE = ",       
         tot.non.strat.offset.leak (cur.offset.pool),
         
         ##       "\n    tot.COST.of.NON.leaked.RANDOM.offsets = ",       
         ##       tot.cost.of.non.leaked.random.offsets,
         
         sep='');
  }

  if(DEBUG.OFFSETTING) cat ("\n\n---------------------------------------");
  if(DEBUG.OFFSETTING) cat ("\n\n");
  
  if(DEBUG.OFFSETTING) cat( '\n', current.time.step, '\t',
                           tot.strat.offset.non.leak (cur.offset.pool),'\t',
                           tot.non.strat.offset.non.leak (cur.offset.pool),'\t',
                           tot.non.strat.offset.leak (cur.offset.pool),'\t',
                           sep='', file = running.totals.for.offset.scores.filename, append = 'TRUE' );
  
  }

#==============================================================================

choose.dev.pool <- function (inside.gc.dev.pool, outside.gc.dev.pool)
  {
  retval <- NULL
    
  if (more.dev.allowed.in.cur.ts (inside.gc.dev.pool)  &  
      more.dev.allowed.in.cur.ts (inside.gc.dev.pool))
    {
    retval <- ifelse ((runif(1) <= PAR.develop.inside.gc.prob), 
                      inside.gc.dev.pool, 
                      outside.gc.dev.pool)
                      
    } else
    {
   if (more.dev.allowed.in.cur.ts (inside.gc.dev.pool)) 
     {
     retval <- inside.gc.dev.pool     
    
     } else
     {
     if (more.dev.allowed.in.cur.ts (inside.gc.dev.pool)) 
       {
       retval <- outside.gc.dev.pool
       }
     }
   }
    
  return (retval)
  }
  
#==============================================================================
#==============================================================================

    #-------------------------------------------------------------
    #  start inline code - no functions defined below this point
    #-------------------------------------------------------------

#==============================================================================
#==============================================================================

if (use.run.number.as.seed) 
  {
  set.seed (random.seed)
  }

if( current.time.step == 0 ) 
  {  
  initialise.loss.model()
  
  } else 
  {
    #------------------------------------------------------------
    #  see any reserves expire becuase they were only managed for a
    #  fixed amount of time. If so set them to unerserved/unmanaged
    #------------------------------------------------------------
    
    overflow <<- 0;

      # get the reserves that expire this time step
  query <- paste( 'select ID from ',dynamicPUinfoTableName,
                 'where RES_EXPIRY_TIME =', current.time.step);
  reserves.expiring.this.timestep <- sql.get.data(PUinformationDBname, query);

#  TODO: SHOULD THIS BE THE TEST FOR SELECTION.NOT.EMPTY() INSTEAD?

  if (length (reserves.expiring.this.timestep) > 0) 
    {
    # if there are any that expire...
    
    # set them to unreserved
    update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                       reserves.expiring.this.timestep,
                                       0, 'RESERVED');
    
    # NOTE: adding this code so that when reserves expire, management
    # also expires - need this for the old public private code to
    # work. But this is probably not what is wanted for the offsetting
    # code
    
    update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                       reserves.expiring.this.timestep,
                                       0, 'MANAGED');
                                       
    }  #  end if - there are reserves expiring this time step

    #------------------------------------------------------------
    #  check if the reserved or managed status of any PUs expires this
    #  time step because it had a non zero prob of expiring every time
    #  step. This is done through the function
    #  stochastically.expire.reserve.or.management() defined above
    #------------------------------------------------------------
  
  stochastically.expire.reserve.or.management( 'RESERVED' )
  stochastically.expire.reserve.or.management( 'MANAGED' )  
  
    #------------------------------------------------------------
    #  set any expired management of reserves to unmanaged
    #------------------------------------------------------------

  timestep.with.mgmt.expiring <- current.time.step - PAR.management.duration;
  
   #   cat( '\n timestep.with.mgmt.expiring:', timestep.with.mgmt.expiring);
   #   cat('\n');
    
  if (timestep.with.mgmt.expiring > 0) 
    {    
    query <- paste( 'select ID from ', dynamicPUinfoTableName,
                    'where MANAGED = 1 AND TIME_MANAGEMENT_COMMENCED <= ',
                    timestep.with.mgmt.expiring);
      
    management.expiring.this.timestep <- sql.get.data (PUinformationDBname, query);
  
      #  ------------------------------
      #  We may want to insert a Pr curve for management expiring here
      #  rather than the effective step function - DWM 21/09/2009
      #  ------------------------------

#  TODO: SHOULD THIS BE THE TEST FOR SELECTION.NOT.EMPTY() INSTEAD?

      if (length (management.expiring.this.timestep) > 0) 
        {
        # if there are any that expire...
        # set them to unmanaged
        update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                           management.expiring.this.timestep,
                                           0, 'MANAGED');
        }
    }  #  end if - timestep.with.mgmt.expiring > 0


    #------------------------------------------------------------
    #  If doing offsetting, do it now 
    #------------------------------------------------------------
  
  if( OPT.use.offsetting.in.loss.model ) 
    {
    cat('\n -----Starting offset model called from loss model')
    cat('\n      Will try and develop', PAR.pus.lost.per.timestep, 'parcels\n' )
    cat('\n The following parcels will be used as offsets: ' )
    
    #test.offsetting.standalone ( PAR.pus.lost.per.timestep )
    develop.with.offsets.using.approx.dev.rate.for.one.time ()

    cat('\n -----End offset called from loss model \n')
    
    } else  #  not offsetting
    {
    pus.developed <-
      randomly.develop.pus (PAR.pus.lost.per.timestep, current.time.step)
    
    if( length(pus.developed) >0 ) 
      {
      cat( "\nThe PUs developed without offset are:", pus.developed )
      }
    }  #  end else - not offsetting
  



  if (OPT.use.raster.maps.for.input.and.output) 
    {    
      #------------------------------------------------------------
      #  Calculate the new maps based on what has been lost (and
      #  possibly reserved if doing offsetting)
      #------------------------------------------------------------
  
    # read in the planning unit id map
    pu.id.map <- as.matrix ( read.table( planning.units.filename ));
  
    # Read in the master habitat map. Will alter this based on the
    # PUs lost per time step
    cur.loss.model.map <-
      as.matrix ( read.table( master.habitat.map.zo1.filename ));

    # read in the current reserved PU map

    cur.reserved.PU.map.filename.base <-
      paste (reserved.planning.units.filename.base, '.', current.time.step,
             sep="");

    cur.reserved.PU.map.filename <-
      paste(cur.reserved.PU.map.filename.base, '.txt', sep = '') 

    if( file.exists( cur.reserved.PU.map.filename ) ) 
      {      
          # if the map exists read it in
      cur.reserved.PU.map <- as.matrix(read.table(cur.reserved.PU.map.filename));
      
      } else  # there is no reserve map yet so create one
      {
      cur.reserved.PU.map <- matrix (0, nrow = rows, ncol = cols);      
      }

        # read in the current managed PU map

    cur.managed.PU.map.filename.base <-
      paste (managed.planning.units.filename.base, '.', current.time.step,
             sep="");

    cur.managed.PU.map.filename <-
      paste(cur.managed.PU.map.filename.base, '.txt', sep = '') 

    if( file.exists( cur.managed.PU.map.filename ) ) 
      {
      
      # if the map exists read it in
      cur.managed.PU.map <- as.matrix(read.table(cur.managed.PU.map.filename));     
      
      } else  # there is no managed map yet so create one
      {            
      cur.managed.PU.map <- matrix ( 0, nrow = rows, ncol = cols ); 
      }

  
        # determine the name to write the current maps to 
    
    cur.loss.model.file.name <-
      paste (loss.model.root.filename, current.time.step,sep="");

    cur.cond.model.base.file.name <- paste( cond.model.root.filename,
                                           current.time.step, sep = '' );
  
    cur.cond.model.file.name <- paste( cond.model.root.filename,
                                      current.time.step, '.txt', sep = '' );
  
    cur.cond.model.map <-
      as.matrix ( read.table( cur.cond.model.file.name ));

    #print( "\n ------Getting all unit indices from DB\n");
  
    # get the all  developed units
    query <- paste( 'select ID from ',dynamicPUinfoTableName,
                   'where DEVELOPED = 1');
    all.previously.developed.units <- sql.get.data(PUinformationDBname, query);

    # get the previously reserved units
    query <- paste( 'select ID from ',dynamicPUinfoTableName,
                   'where RESERVED = 1');
    all.previously.reserved.units <- sql.get.data(PUinformationDBname, query);
  
    # get the previously managed units
    query <- paste( 'select ID from ',dynamicPUinfoTableName,
                   'where MANAGED = 1');
    all.previously.managed.units <- sql.get.data(PUinformationDBname, query);
  
    # get the reserved + unmanaged units
    query <- paste( 'select ID from ',dynamicPUinfoTableName,
                   'where MANAGED = 0');
    all.unmanaged.units <- sql.get.data(PUinformationDBname, query);

  
        # update the PUs lost 
    for (id.of.PU.to.remove in all.previously.developed.units ) 
      {      
      cur.loss.model.map[ pu.id.map == id.of.PU.to.remove] <- 
        as.integer(non.habitat.indicator);
      
      cur.cond.model.map[ pu.id.map == id.of.PU.to.remove] <-
        as.integer(non.habitat.indicator);
      }

        # update extra PUs reserved
    
    for (id.of.PU.to.reserve in all.previously.reserved.units ) 
      {    
      cur.reserved.PU.map[ pu.id.map == id.of.PU.to.reserve] <- 1;
      }
   
        # update extra PUs managed/unmanaged

    for (id.of.PU.to.manage in all.previously.managed.units ) 
      {    
      cur.managed.PU.map[ pu.id.map == id.of.PU.to.manage] <- 1;
      #cur.managed.PU.map[ pu.id.map != id.of.PU.to.manage] <- 0;
      }
  
    for (id.of.PU.to.unmanage in all.unmanaged.units )  
      {
      cur.managed.PU.map[ pu.id.map == id.of.PU.to.unmanage] <- 0;
      }

    #------------------------------------------------------------
    #  write output
    #------------------------------------------------------------

    # write the loss  map.
    write.to.3.forms.of.files (cur.loss.model.map, 
                               cur.loss.model.file.name, 
                               rows, cols);

    # also write to
    write.to.3.forms.of.files (cur.cond.model.map,
                               cur.cond.model.base.file.name,
                               rows, cols);
    # also write to
    write.to.3.forms.of.files (cur.reserved.PU.map,
                               cur.reserved.PU.map.filename.base,
                               rows, cols);

    # also write to
    write.to.3.forms.of.files (cur.managed.PU.map,
                               cur.managed.PU.map.filename.base,
                               rows, cols);

    } # end - if( OPT.use.raster.maps.for.input.and.output )

  }  # end if / else (current.time.step == 0  )
  
#==============================================================================

    #  end of code not included in any function

#==============================================================================

