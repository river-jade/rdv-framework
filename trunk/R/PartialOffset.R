#==============================================================================

# source ('PartialOffset.R');

#==============================================================================

setClass ("PartialOffset", 
          representation (PO.db.field.label = "character",
          
                          partial.is.active = "logical", 
                          partial.PU.ID = "numeric", 
                          partial.sum.score.remaining = "numeric" 
						  ),

	 	   prototype (PO.db.field.label = "", 
	 	     
                      partial.is.active = FALSE, 
                      partial.PU.ID = CONST.UNINITIALIZED.NUM, 
                      partial.sum.score.remaining = 0.0 
                      )
              );

#==============================================================================
#==============================================================================
#==============================================================================
    #  Create generic and specific get and set routines for 
    #  all instance variables.
#==============================================================================

                #-----  PO.db.field.label  -----#

    #  Get    
setGeneric ("PO.db.field.label", signature = ".Object", 
            function (.Object) standardGeneric ("PO.db.field.label"))            
setMethod ("PO.db.field.label", "PartialOffset", 
           function (.Object) .Object@PO.db.field.label);

    #  Set    
setGeneric ("PO.db.field.label<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("PO.db.field.label<-"))
setMethod ("PO.db.field.label<-", "PartialOffset", 
           function (.Object, value) initialize (.Object, PO.db.field.label = value))

                #-----  partial.is.active  -----#
    
    #  Get    
setGeneric ("partial.is.active", signature = ".Object", 
            function (.Object) standardGeneric ("partial.is.active"))
setMethod ("partial.is.active", "PartialOffset", 
           function (.Object) .Object@partial.is.active);

    #  Set    
setGeneric ("partial.is.active<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("partial.is.active<-"))
setMethod ("partial.is.active<-", "PartialOffset", 
           function (.Object, value) initialize (.Object, partial.is.active = value))

                #-----  partial.PU.ID  -----#
    
    #  Get    
setGeneric ("partial.PU.ID", signature = ".Object", 
            function (.Object) standardGeneric ("partial.PU.ID"))
setMethod ("partial.PU.ID", "PartialOffset", 
           function (.Object) .Object@partial.PU.ID);

    #  Set    
setGeneric ("partial.PU.ID<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("partial.PU.ID<-"))
setMethod ("partial.PU.ID<-", "PartialOffset", 
           function (.Object, value) initialize (.Object, partial.PU.ID = value))

                #-----  partial.sum.score.remaining  -----#
    
    #  Get    
setGeneric ("partial.sum.score.remaining", signature = ".Object", 
            function (.Object) standardGeneric ("partial.sum.score.remaining"))
setMethod ("partial.sum.score.remaining", "PartialOffset", 
           function (.Object) .Object@partial.sum.score.remaining);

    #  Set    
setGeneric ("partial.sum.score.remaining<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("partial.sum.score.remaining<-"))
setMethod ("partial.sum.score.remaining<-", "PartialOffset", 
           function (.Object, value) initialize (.Object, partial.sum.score.remaining = value))

#==============================================================================
#==============================================================================
#==============================================================================

                #-----  get.global.values.for.any.active.partial.offset  -----#

setGeneric ("get.global.values.for.any.active.partial.offset", signature = ".Object", 
			function (.Object) standardGeneric ("get.global.values.for.any.active.partial.offset"))
			
#--------------------
 
      #  Need to reload the running totals from the database.
      #  This really should be done in the initialize routine for the classes, 
      #  but I haven't got that working correctly yet.
    
setMethod ("get.global.values.for.any.active.partial.offset", "PartialOffset", 
function (.Object)
  {
  nameObject <- deparse (substitute (.Object))
  
  #-----------------------------------------------------------------------------------------  
  #  TODO:  Need to convert these names and fields to concatenate inside_gc and outside_gc 
  #         like the dev pools do.  Will leave them as is until I'm sure that the 
  #         conversion to a class system works before specializing to inside and 
  #         outside classes.
  #-----------------------------------------------------------------------------------------  

  if(DEBUG.OFFSETTING) cat ("In get.global.values.for.any.active.partial.offset: \n");
  if(DEBUG.OFFSETTING) cat ("    current.time.step = ", current.time.step, "\n");

      #  Figure out whether the field names use "INSIDE_GC" or "OUTSIDE_GC". 
  cur.PO.db.field.label <- PO.db.field.label (.Object)
  
  if(DEBUG.OFFSETTING) cat ("     cur.PO.db.field.label = <", cur.PO.db.field.label, ">\n")
    
      #----------
  
  query <- paste ('select ',
                  'PARTIAL_OFFSET_IS_ACTIVE_', cur.PO.db.field.label, 
                  ' from ',
                  offsettingWorkingVarsTableName, sep='');
  partial.is.active (.Object) <- as.logical (sql.get.data (PUinformationDBname, query));

      #----------
  
  query <- paste ('select ',
                  'PARTIAL_OFFSET_PU_ID_', cur.PO.db.field.label,
                  ' from ',
                  offsettingWorkingVarsTableName, sep='');
  partial.PU.ID (.Object) <- sql.get.data (PUinformationDBname, query)

      #----------
  
  query <- paste ('select ',
                  'PARTIAL_OFFSET_SUM_SCORE_REMAINING_', cur.PO.db.field.label,
                  ' from ',
                  offsettingWorkingVarsTableName, sep='');
  partial.sum.score.remaining (.Object) <- sql.get.data (PUinformationDBname,
                                                                query);
	  
###	  cat ("\n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", 
###		   "\n    Pausing GET.GLOBAL.VALUES.FOR.ANY.ACTIVE.PARTIAL.OFFSET () ", 
###		   "so you can check the ",
###		   offsettingWorkingVarsTableName,
###		   " table for those values.",
###		   "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", 
###		   "\n\n",
###		   sep='');	  
#     browser();
	  
  assign (nameObject, .Object, envir=parent.frame())
  }
)

#==============================================================================

                #-----  close.active.partial.offset  -----#

setGeneric ("close.active.partial.offset", signature = ".Object", 
			function (.Object) standardGeneric ("close.active.partial.offset"))
			
#--------------------
 
setMethod ("close.active.partial.offset", "PartialOffset", 
function (.Object)
  {
  nameObject <- deparse (substitute (.Object))
  
  if(DEBUG.OFFSETTING) cat ("\n---------- In close.active.partial.offset(), nameObject = ",
                            nameObject, " ----------\n")
#  browser()
      #----------
  
     #  Close the active partial offset.
    
  partial.is.active (.Object) <- FALSE
  partial.PU.ID (.Object) <- CONST.UNINITIALIZED.PU.ID.VALUE
  partial.sum.score.remaining (.Object) <- 0.0
    
      #----------
  
  assign (nameObject, .Object, envir=parent.frame())
  }
)

#==============================================================================

                #-----  save.global.values.for.any.active.partial.offset  -----#

setGeneric ("save.global.values.for.any.active.partial.offset", signature = ".Object", 
			function (.Object) standardGeneric ("save.global.values.for.any.active.partial.offset"))
			
#--------------------
 
setMethod ("save.global.values.for.any.active.partial.offset", "PartialOffset", 
function (.Object)
  {
  #-----------------------------------------------------------------------------------------  
  #  TODO:  Need to convert these names and fields to concatenate inside_gc and outside_gc 
  #         like the dev pools do.  Will leave them as is until I'm sure that the 
  #         conversion to a class system works before specializing to inside and 
  #         outside classes.
  #-----------------------------------------------------------------------------------------  

  if(DEBUG.OFFSETTING) cat ("In save.global.values.for.any.active.partial.offset: \n");
  if(DEBUG.OFFSETTING) cat ("    current.time.step = ", current.time.step, "\n");

      #  Figure out whether the field names use "INSIDE_GC" or "OUTSIDE_GC". 
  cur.PO.db.field.label <- PO.db.field.label (.Object) 
  if(DEBUG.OFFSETTING) cat ("     cur.PO.db.field.label = <", cur.PO.db.field.label, ">\n")
    
      #----------
  
  connect.to.database (PUinformationDBname);

      #----------------------------------------------------------
      #  Save flag indicating whether there is an active partial.
      #----------------------------------------------------------

  query <- paste ('update ', offsettingWorkingVarsTableName,
                  ' set ', 'PARTIAL_OFFSET_IS_ACTIVE_', cur.PO.db.field.label, ' = ',
                  as.integer (partial.is.active (.Object)),  #  bool must be int in db
                  sep = '' );  
  sql.send.operation (query);

      #----------------------------
      #  Save ID of active partial.
      #----------------------------

  query <- paste ('update ', offsettingWorkingVarsTableName,
                  ' set ', 'PARTIAL_OFFSET_PU_ID_', cur.PO.db.field.label, ' = ',
                  partial.PU.ID (.Object),
                  sep = '' );
  sql.send.operation (query);

      #----------------------------------------------------------
      #  Save amount of offset still available in active partial.
      #----------------------------------------------------------

  query <- paste ('update ', offsettingWorkingVarsTableName,
                  ' set ', 'PARTIAL_OFFSET_SUM_SCORE_REMAINING_', cur.PO.db.field.label, ' = ',
                  round (partial.sum.score.remaining (.Object), 5),
                  sep = '' );  
  sql.send.operation (query);

      #-----
  
  close.database.connection ();
  }
)
  
#==============================================================================

    #  Currently, this function is not a part of the class but I have moved 
    #  it in here from loss.model.R since it's about partials.
    
#==============================================================================

initialize.partial.offset.db.values <- function ()
  {  
  connect.to.database (PUinformationDBname);

      #----------

  inside.gc.string <- "INSIDE_GC"
  
  query <- paste( 'insert into ', offsettingWorkingVarsTableName,
                   ' ( PARTIAL_OFFSET_IS_ACTIVE_', inside.gc.string, ' ) values (', 0, ')', 
                   sep = '');
    
  sql.send.operation (query);

  if(DEBUG.OFFSETTING) cat ("\n\nIn initialize.partial.offset.db.values(), init actions are:\n");
  if(DEBUG.OFFSETTING) cat ("\n    ", query);
  
      #----------
  CONST.UNINITIALIZED.PU.ID.VALUE <- -999;
  
  query <- paste ('update ', offsettingWorkingVarsTableName,
                   ' set ', 'PARTIAL_OFFSET_PU_ID_', inside.gc.string, ' = ', 
                   CONST.UNINITIALIZED.PU.ID.VALUE, 
                   sep = '');
  sql.send.operation (query);

  if(DEBUG.OFFSETTING) cat ("\n    ", query);
  
      #----------
  
  query <- paste( 'update ', offsettingWorkingVarsTableName,
                   ' set ', 'PARTIAL_OFFSET_SUM_SCORE_REMAINING_', inside.gc.string, ' = ', 
                   0.0, 
                   sep = '');
  sql.send.operation (query);

  if(DEBUG.OFFSETTING) cat ("\n    ", query);
  
      #----------  
      #----------

  outside.gc.string <- "OUTSIDE_GC"
  
  query <- paste( 'update ', offsettingWorkingVarsTableName,
                   ' set ', 'PARTIAL_OFFSET_IS_ACTIVE_', outside.gc.string, ' = ', 0, 
                   sep = '');
    
  sql.send.operation (query);

  if(DEBUG.OFFSETTING) cat ("\n\nIn initialize.partial.offset.db.values(), init actions are:\n");
  if(DEBUG.OFFSETTING) cat ("\n    ", query);
  
      #----------
  CONST.UNINITIALIZED.PU.ID.VALUE <- -999;
  
  query <- paste ('update ', offsettingWorkingVarsTableName,
                   ' set ', 'PARTIAL_OFFSET_PU_ID_', outside.gc.string, ' = ', 
                   CONST.UNINITIALIZED.PU.ID.VALUE, 
                   sep = '');
  sql.send.operation (query);

  if(DEBUG.OFFSETTING) cat ("\n    ", query);
  
      #----------
  
  query <- paste( 'update ', offsettingWorkingVarsTableName,
                   ' set ', 'PARTIAL_OFFSET_SUM_SCORE_REMAINING_', outside.gc.string, ' = ', 
                   0.0, 
                   sep = '');
  sql.send.operation (query);

  if(DEBUG.OFFSETTING) cat ("\n    ", query);
  
      #----------
  
  close.database.connection ();

###	  cat ("\n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", 
###		   "\n    Pausing INITIALIZE.PARTIAL.OFFSET.DB.VALUES () ", 
###		   "so you can check the ",
###		   offsettingWorkingVarsTableName,
###		   " table for those values.",
###		   "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", 
###		   "\n\n",
###		   sep='');
#browser();
  
  }  #  end function - initialize.partial.offset.db.values

#==============================================================================

test.PartialOffset <- function ()
  {
  x <- new ("PartialOffset")
  if(DEBUG.OFFSETTING) print (x)

  partial.is.active(x)
  partial.PU.ID(x)
  partial.sum.score.remaining(x)
 
  partial.is.active(x) <- TRUE
  partial.PU.ID(x) <- 13
  partial.sum.score.remaining(x) <- 234
  x
  }
  
#test.PartialOffset ()

#==============================================================================

