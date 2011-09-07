#==============================================================================

# source ("ErrorModel.R")

#==============================================================================

source ('constants.R')

#source( 'variables.R' )

#==============================================================================

    #--------------------------------------------------------------
    #  ErrorModel:  
    #
    #  Errors that can be recreated using a single value that can 
    #  be stored in the database.  This factor may be given by 
    #  the user or computed and then stored to reuse later.  
    #
    #  The initial impetus for this is that we sometimes want 
    #  to apply the same error multiplier or bias repeatedly to 
    #  something whose value changes over time and we don't want 
    #  change the amount of error applied to that change every 
    #  time the erroneous result has to be recalculated.  
    #  For example, a parcel's condition may change over time and 
    #  we want to simulate a random amount of assessment error 
    #  for that parcel, but don't want to use a different amount 
    #  of error on every time step.  We want to randomly choose it 
    #  one time and then reapply the same amount of error each 
    #  time we need the erroneous value of the parcel since in the 
    #  real world, you would not send an assessor out every time 
    #  you wanted to know the value of the parcel.  You would be 
    #  more likely to base it on previous assessment.  This means 
    #  that we need to be able to calculate the random value to 
    #  use in creating the error (e.g., 32.7% overestimation) and 
    #  save it to reapply at each subsequent request for the 
    #  apparent condition of the parcel.
    #--------------------------------------------------------------
    
setClass ("ErrorModel", 
          representation (em.name = "character",
                          em.description = "character", 
                          
                          em.result.min = "numeric",
                          em.result.max = "numeric",
                          
                          em.error.min = "numeric",
                          em.error.max = "numeric"
						  ),

	 	   prototype (    em.name = "STRING NOT INITIALIZED YET",
                          em.description = "STRING NOT INITIALIZED YET",
                          
                          em.result.min = CONST.UNINITIALIZED.NUM,
                          em.result.max = CONST.UNINITIALIZED.NUM,
                          
                          em.error.min = CONST.UNINITIALIZED.NUM,
                          em.error.max = CONST.UNINITIALIZED.NUM
                      )
              );

#==============================================================================

    #  Create generic and specific get and set routines for 
    #  all instance variables.

#==============================================================================

                #-----  em.name  -----#
    #  Get    
setGeneric ("em.name", signature = "x", 
            function (x) standardGeneric ("em.name"))            
setMethod ("em.name", "ErrorModel", 
           function (x) x@em.name);

    #  Set    
setGeneric ("em.name<-", signature = "x", 
            function (x, value) standardGeneric ("em.name<-"))
setMethod ("em.name<-", "ErrorModel", 
           function (x, value) initialize (x, em.name = value))

                #-----  em.description  -----#
    #  Get    
setGeneric ("em.description", signature = "x", 
            function (x) standardGeneric ("em.description"))            
setMethod ("em.description", "ErrorModel", 
           function (x) x@em.description);

    #  Set    
setGeneric ("em.description<-", signature = "x", 
            function (x, value) standardGeneric ("em.description<-"))
setMethod ("em.description<-", "ErrorModel", 
           function (x, value) initialize (x, em.description = value))

                #-----  em.result.min  -----#    
    #  Get    
setGeneric ("em.result.min", signature = ".Object", 
            function (.Object) standardGeneric ("em.result.min"))
setMethod ("em.result.min", "ErrorModel", 
           function (.Object) .Object@em.result.min);

    #  Set    
setGeneric ("em.result.min<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("em.result.min<-"))
setMethod ("em.result.min<-", "ErrorModel", 
           function (.Object, value) initialize (.Object, em.result.min = value))

                #-----  em.result.max  -----#    
    #  Get    
setGeneric ("em.result.max", signature = ".Object", 
            function (.Object) standardGeneric ("em.result.max"))
setMethod ("em.result.max", "ErrorModel", 
           function (.Object) .Object@em.result.max);

    #  Set    
setGeneric ("em.result.max<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("em.result.max<-"))
setMethod ("em.result.max<-", "ErrorModel", 
           function (.Object, value) initialize (.Object, em.result.max = value))

                #-----  em.error.min  -----#    
    #  Get    
setGeneric ("em.error.min", signature = ".Object", 
            function (.Object) standardGeneric ("em.error.min"))
setMethod ("em.error.min", "ErrorModel", 
           function (.Object) .Object@em.error.min);

    #  Set    
setGeneric ("em.error.min<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("em.error.min<-"))
setMethod ("em.error.min<-", "ErrorModel", 
           function (.Object, value) initialize (.Object, em.error.min = value))

                #-----  em.error.max  -----#    
    #  Get    
setGeneric ("em.error.max", signature = ".Object", 
            function (.Object) standardGeneric ("em.error.max"))
setMethod ("em.error.max", "ErrorModel", 
           function (.Object) .Object@em.error.max);

    #  Set    
setGeneric ("em.error.max<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("em.error.max<-"))
setMethod ("em.error.max<-", "ErrorModel", 
           function (.Object, value) initialize (.Object, em.error.max = value))

#==============================================================================

                #-----  values.were.initialized  -----#

setGeneric ("values.were.initialized", signature = ".Object", 
			function (.Object) standardGeneric ("values.were.initialized"))
			
#--------------------
 
setMethod ("values.were.initialized", "ErrorModel", 
function (.Object)
    {
    stop ("Function values.were.initialized() is not defined for base class ErrorModel.\n")
    }
)  

#==============================================================================

                #-----  error.computation  -----#

setGeneric ("error.computation", signature = ".Object", 
			function (.Object, base.value, err.factor) standardGeneric ("error.computation"))
			
#--------------------
 
setMethod ("error.computation", "ErrorModel", 
function (.Object, base.value, err.factor)
    {
    stop ("Function error.computation() is not defined for base class ErrorModel.\n")
    }
)  

#==============================================================================

                #-----  compute.error.factor  -----#

setGeneric ("compute.error.factor", signature = ".Object", 
			function (.Object, base.value) standardGeneric ("compute.error.factor"))
			
#--------------------
 
setMethod ("compute.error.factor", "ErrorModel", 
function (.Object, base.value)
    {
    new.factor <- NA
    
        #------------------------------------------------------
        #  Need to do this error check in here rather than in 
        #  apply.error.to() because the error factor may be 
        #  generated on its own and then saved rather than 
        #  done inside the error application.
        #------------------------------------------------------
        
    if (values.were.initialized (.Object))
        new.factor <- 
            compute.error.factor.with.initialized.values (.Object, 
                                                          base.value)

    return (new.factor)
    }
)  
         
#==============================================================================

                #-----  compute.error.factor.with.initialized.values  -----#

setGeneric ("compute.error.factor.with.initialized.values", signature = ".Object", 
			function (.Object, base.value) standardGeneric ("compute.error.factor.with.initialized.values"))
			
#--------------------
 
setMethod ("compute.error.factor.with.initialized.values", "ErrorModel", 
function (.Object, base.value)
    {
    stop ("Function compute.error.factor.with.initialized.values() is not defined for base class ErrorModel.\n")
    }
)  
         
#==============================================================================

                #-----  apply.error.to  -----#

setGeneric ("apply.error.to", signature = ".Object", 
			function (.Object, base.value, err.factor = NA) standardGeneric ("apply.error.to"))
			
#--------------------
 
setMethod ("apply.error.to", "ErrorModel", 
function (.Object, base.value, err.factor = NA)
    {
    new.value <- NA
    
    if (is.na (err.factor))
        err.factor <- compute.error.factor (.Object, base.value)
        
    new.value <- error.computation (.Object, base.value, err.factor)

    return (new.value)
    }
)  
         
#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================

    #---------------------------
    #  ErrorModel.000:  No error  
    #---------------------------
    
setClass ("ErrorModel.000", 
	 	  prototype = prototype (em.name = "ErrorModel.000", 
	 	                         em.description = "no error"),
	 	  contains = "ErrorModel"
         );
         
#------------------------------------------------------------------------------

setMethod ("values.were.initialized", "ErrorModel.000", 
function (.Object)
    {
    return (TRUE)
    }
)  

#------------------------------------------------------------------------------

setMethod ("error.computation", "ErrorModel.000", 
function (.Object, base.value, err.factor)
    {
    return (base.value)
    }
)  
         
#------------------------------------------------------------------------------

setMethod ("compute.error.factor.with.initialized.values", "ErrorModel.000", 
function (.Object, base.value)
    {
        #  In theory, this could return anything, since it's 
        #  ignored.  However, in some cases, the result of 
        #  this call will be stored in the db, so it needs 
        #  to be something that can be stored.  I think that 
        #  NA may not store well, so it's out.  Similarly, 
        #  CONST.UNINITIALIZED.NUMBER might be set to NA 
        #  instead of some storable number, so it's out too.
        
    return (0)  
    }
)  
         
#------------------------------------------------------------------------------

test.ErrorModel.000 <- function ()    #  no error
    {
    cat ("\n\n---------------------\n\nTesting ErrorModel.000")
    
    test.em <- new ("ErrorModel.000")
    cat ("    < ", em.description (test.em), " >\n")

        #--------------------
        
    x.true <- 100
    x.apparent <- apply.error.to (test.em, x.true)
    cat ("\nx.true = ", x.true, "\nx.apparent = ", x.apparent, "\n")

        #--------------------
        
    cat ("\nRepeating using error factor:")
    x.error.factor <- compute.error.factor (test.em, x.true)    
    cat ("\nx.error.factor = ", x.error.factor, "\n")     
    
    x.apparent <- apply.error.to (test.em, x.true, x.error.factor)
    cat ("\nAfter repeating using error factor:")
    cat ("\nx.true = ", x.true, "\nx.apparent = ", x.apparent, "\n") 

        #--------------------
        
#    num.reps <- 100    
    ef <- rep (0, num.reps)
    app <- rep (0, num.reps)
    cat ("\n\nErrorModel.000\n")
    for (cur.idx in 1:num.reps)
        {
        ef [cur.idx] <- compute.error.factor (test.em, x.true)
        app [cur.idx] <- apply.error.to (test.em, x.true,  ef [cur.idx])
        
###        cat ("\n    ", cur.idx, ":    ", ef [cur.idx], "    ", app [cur.idx])
        }
    cat ("\n\nmean.ef = ", mean (ef), "    sd.ef = ", sd (ef), "    median.ef = ", median (ef))
    cat ("\nmean.app = ", mean (app), "    sd.app = ", sd (app), "    median.app = ", median (app))
    cat ("\n    where base.value   = ", x.true)
        
#    print (test.em)
    }
    
#==============================================================================

    #--------------------------------------------------------------
    #  ErrorModel.100:  constant error base
    #
    #  Returns some form of error derived from a constant.
    #--------------------------------------------------------------
    
setClass ("ErrorModel.100", 
          representation (em.constant = "numeric"
						  ),
	 	  prototype = prototype (em.name = "ErrorModel.100", 
	 	                         em.description = "constant error base", 
	 	                         em.constant = CONST.UNINITIALIZED.NUM
	 	                        ),
	 	  contains = "ErrorModel"
         );

#------------------------------------------------------------------------------

                #-----  em.constant  -----#    
    #  Get    
setGeneric ("em.constant", signature = ".Object", 
            function (.Object) standardGeneric ("em.constant"))
setMethod ("em.constant", "ErrorModel.100", 
           function (.Object) .Object@em.constant);

    #  Set    
setGeneric ("em.constant<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("em.constant<-"))
setMethod ("em.constant<-", "ErrorModel.100", 
           function (.Object, value) initialize (.Object, em.constant = value))

#------------------------------------------------------------------------------

setMethod ("values.were.initialized", "ErrorModel.100", 
function (.Object)
    {
    if (is.uninitialized.number (.Object@em.constant))
        stop ("em.constant was never set.\n")

        #------------------------------------------------------------
        #  If it makes it to here without stopping, then the values 
        #  were initialized.  Otherwise, there should have been a 
        #  fatal error.
        #------------------------------------------------------------
        
    return (TRUE)
    }
)  
         
#------------------------------------------------------------------------------

setMethod ("compute.error.factor.with.initialized.values", "ErrorModel.100", 
function (.Object, base.value)
    {
    return (.Object@em.constant)  
    }
)  
         
#------------------------------------------------------------------------------

test.ErrorModel.100 <- function (name.of.class.to.test)    #  constant errors
    {
    cat ("\n\n---------------------\n\nTesting ", name.of.class.to.test, sep='')
    
#    test.em <- new (name.of.class.to.test)    #  Test error trapping by removing "#"

    test.em <- new (name.of.class.to.test, em.constant = 1.30)
    cat ("    < ", em.description (test.em), " >\n")
          
        #--------------------
        
    x.true <- 100
    x.apparent <- apply.error.to (test.em, x.true)
    cat ("\nx.true = ", x.true, "\nx.apparent = ", x.apparent, "\n")

        #--------------------
        
    cat ("\nRepeating using error factor:")
    x.error.factor <- compute.error.factor (test.em, x.true)    
    cat ("\nx.error.factor = ", x.error.factor, "\n")     
    
    x.apparent <- apply.error.to (test.em, x.true, x.error.factor)
    cat ("\nAfter repeating using error factor:")
    cat ("\nx.true = ", x.true, "\nx.apparent = ", x.apparent, "\n") 

        #--------------------
        
#    num.reps <- 100    
    ef <- rep (0, num.reps)
    app <- rep (0, num.reps)
    cat ("\n\nErrorModel.100\n")
    for (cur.idx in 1:num.reps)
        {
        ef [cur.idx] <- compute.error.factor (test.em, x.true)
        app [cur.idx] <- apply.error.to (test.em, x.true,  ef [cur.idx])
        
###        cat ("\n    ", cur.idx, ":    ", ef [cur.idx], "    ", app [cur.idx])
        }
    cat ("\n\nmean.ef = ", mean (ef), "    sd.ef = ", sd (ef), "    median.ef = ", median (ef))
    cat ("\nmean.app = ", mean (app), "    sd.app = ", sd (app), "    median.app = ", median (app))
    cat ("\n    where base.value   = ", x.true)
    cat ("\n          em.constant  = ", em.constant (test.em))
        
        #--------------------
        
#    print (test.em)
    }
    
#==============================================================================

    #--------------------------------------------------------------
    #  ErrorModel.101:  constant return
    #
    #  A fixed constant error returned regardless of input value.  
    #--------------------------------------------------------------
    
setClass ("ErrorModel.101", 
	 	  prototype = prototype (em.name = "ErrorModel.101", 
	 	                         em.description = "constant return"
	 	                        ),
	 	  contains = "ErrorModel.100"
         );

#------------------------------------------------------------------------------

setMethod ("error.computation", "ErrorModel.101", 
function (.Object, base.value, err.factor)
    {
    return (err.factor)
    }
)  
         
#==============================================================================

    #-------------------------------------------------------
    #  ErrorModel.102:  constant additive bias
    #
    #  A fixed constant error is added to the input value.  
    #-------------------------------------------------------
    
setClass ("ErrorModel.102", 
	 	  prototype = prototype (em.name = "ErrorModel.102", 
	 	                         em.description = "constant additive bias"
	 	                        ),
	 	  contains = "ErrorModel.100"
         );

#------------------------------------------------------------------------------

setMethod ("error.computation", "ErrorModel.102", 
function (.Object, base.value, err.factor)
    {
    return (base.value + err.factor)
    }
)  
         
#==============================================================================

    #---------------------------------------------------------
    #  ErrorModel.103:  constant multiplicative bias
    #
    #  A fixed constant is multiplied times the input value.  
    #
    #  This is what you would use to create a fixed 
    #  percentage error.  For example, a 30% overestimate 
    #  would come from using a constant of 1.30.
    #---------------------------------------------------------
    
setClass ("ErrorModel.103", 
	 	  prototype = prototype (em.name = "ErrorModel.103", 
	 	                         em.description = "constant multiplicative bias"
	 	                        ),
	 	  contains = "ErrorModel.100"
         );

#------------------------------------------------------------------------------

setMethod ("error.computation", "ErrorModel.103", 
function (.Object, base.value, err.factor)
    {
    return (base.value * err.factor)
    }
)  
         
#==============================================================================

    #----------------------------------------------------------------------
    #  ErrorModel.200:  random uniform error base
    #
    #  Returns some form of error related to uniform random distribution.
    #----------------------------------------------------------------------
    
setClass ("ErrorModel.200", 
	 	  prototype = prototype (em.name = "ErrorModel.200", 
	 	                         em.description = "random uniform error base"),
	 	  contains = "ErrorModel"
         );

#------------------------------------------------------------------------------

setMethod ("values.were.initialized", "ErrorModel.200", 
function (.Object)
    {
    if (is.uninitialized.number (.Object@em.error.min))
        stop ("em.error.min was never set.\n")

    if (is.uninitialized.number (.Object@em.error.max))
        stop ("em.error.max was never set.\n")

        #------------------------------------------------------------
        #  If it makes it to here without stopping, then the values 
        #  were initialized.  Otherwise, there should have been a 
        #  fatal error.
        #------------------------------------------------------------
        
    return (TRUE)
    }
)  
         
#------------------------------------------------------------------------------

setMethod ("compute.error.factor.with.initialized.values", "ErrorModel.200", 
function (.Object, base.value)
    {
        #----------------------------------------------------------------------
        #  NOTE: runif includes both endpoints of the interval as allowable 
        #        values.  Not sure what you have to do to exclude one or both
        #        if you want to do that.
        #----------------------------------------------------------------------
 
    return (runif (1, .Object@em.error.min, .Object@em.error.max))
    }
)  
         
#------------------------------------------------------------------------------

test.ErrorModel.200 <- function (name.of.class.to.test)    #  random uniform errors
    {
    cat ("\n\n---------------------\n\nTesting ", name.of.class.to.test, sep='')
    
#    test.em <- new (name.of.class.to.test)    #  Test error trapping by removing "#"
##    test.em <- new (name.of.class.to.test, em.error.min = 0.0)

    test.em <- new (name.of.class.to.test, em.error.min = 0.0, em.error.max = 1.0)
    cat ("    < ", em.description (test.em), " >\n")
    
        #--------------------
        
    x.true <- 100
    
    x.apparent <- apply.error.to (test.em, x.true)
    cat ("\nUsing interval [-1, 1]:")
    cat ("\nx.true = ", x.true, "\nx.apparent = ", x.apparent, "\n")

        #--------------------
        
    em.error.min (test.em) <- 1.5
    em.error.max (test.em) <- 2
    
    x.apparent <- apply.error.to (test.em, x.true)
    cat ("\nAfter resetting interval to [1.5, 2]:")
    cat ("\nx.true = ", x.true, "\nx.apparent = ", x.apparent, "\n") 

        #--------------------
        
    cat ("\nRepeating using error factor:")
    x.error.factor <- compute.error.factor (test.em, x.true)    
    cat ("\nx.error.factor = ", x.error.factor, "\n")     
    
    x.apparent <- apply.error.to (test.em, x.true, x.error.factor)
    cat ("\nAfter repeating using error factor:")
    cat ("\nx.true = ", x.true, "\nx.apparent = ", x.apparent, "\n") 

        #--------------------
        
#    num.reps <- 100    
    ef <- rep (0, num.reps)
    app <- rep (0, num.reps)
    cat ("\n\nErrorModel.200\n")
    for (cur.idx in 1:num.reps)
        {
        ef [cur.idx] <- compute.error.factor (test.em, x.true)
        app [cur.idx] <- apply.error.to (test.em, x.true,  ef [cur.idx])
        
###        cat ("\n    ", cur.idx, ":    ", ef [cur.idx], "    ", app [cur.idx])
        }
    cat ("\n\nmean.ef = ", mean (ef), "    sd.ef = ", sd (ef), "    median.ef = ", median (ef))
    cat ("\nmean.app = ", mean (app), "    sd.app = ", sd (app), "    median.app = ", median (app))
    cat ("\n    where base.value    = ", x.true)
    cat ("\n          em.error.min  = ", em.error.min (test.em))
    cat ("\n          em.error.max  = ", em.error.max (test.em))
    em.error.min (test.em) <- 1.5
    em.error.max (test.em) <- 2
        
#    print (test.em)
    }
    
#==============================================================================

    #---------------------------------------------------------------------
    #  ErrorModel.201:  random uniform return
    #
    #  Returns a random uniform number - completely ignores input value.
    #---------------------------------------------------------------------
    
setClass ("ErrorModel.201", 
	 	  prototype = prototype (em.name = "ErrorModel.201", 
	 	                         em.description = "random uniform return"),
	 	  contains = "ErrorModel.200"
         );

#------------------------------------------------------------------------------

setMethod ("error.computation", "ErrorModel.201", 
function (.Object, base.value, err.factor)
    {
    return (err.factor)
    }
)  
         
#==============================================================================

    #--------------------------------------------------------------------
    #  ErrorModel.202:  random uniform additive error
    #
    #  A random uniform value from a specified interval is added to the 
    #  input value.  
    #--------------------------------------------------------------------
    
setClass ("ErrorModel.202", 
	 	  prototype = prototype (em.name = "ErrorModel.202", 
	 	                         em.description = "random uniform additive error"),
	 	  contains = "ErrorModel.200"
         );
         
#------------------------------------------------------------------------------

setMethod ("error.computation", "ErrorModel.202", 
function (.Object, base.value, err.factor)
    {
            #----------------------------------------------------------------------
            #  NOTE: runif includes both endpoints of the interval as allowable 
            #        values.  Not sure what you have to do to exclude one or both
            #        if you want to do that.
            #----------------------------------------------------------------------
 
    return (base.value + err.factor)
    }
)  
         
#==============================================================================

    #------------------------------------------------------------------
    #  ErrorModel.203:  random uniform multiplicative error
    #
    #  A random uniform value from a specified interval is multiplied  
    #  times the input value.  
    #------------------------------------------------------------------
    
setClass ("ErrorModel.203", 
	 	  prototype = prototype (em.name = "ErrorModel.203", 
	 	                         em.description = "random uniform multiplicative error"),
	 	  contains = "ErrorModel.200"
         );
         
#------------------------------------------------------------------------------

setMethod ("error.computation", "ErrorModel.203", 
function (.Object, base.value, err.factor)
    {
            #----------------------------------------------------------------------
            #  NOTE: runif includes both endpoints of the interval as allowable 
            #        values.  Not sure what you have to do to exclude one or both
            #        if you want to do that.
            #----------------------------------------------------------------------
 
    return (base.value * err.factor)
    }
)  
         
#==============================================================================

    #---------------------------------------------------------------------
    #  ErrorModel.300:  random normal error base
    #
    #  Returns some form of error related to normal random distribution.
    #---------------------------------------------------------------------
    
setClass ("ErrorModel.300", 
          representation (em.mean = "numeric",
                          em.sd = "numeric"
						  ),
	 	  prototype = prototype (em.name = "ErrorModel.300", 
	 	                         em.description = "random normal base", 
	 	                         em.mean = CONST.UNINITIALIZED.NUM,
                                 em.sd = CONST.UNINITIALIZED.NUM
	 	                        ),
	 	  contains = "ErrorModel"
         );

#------------------------------------------------------------------------------

                #-----  em.mean  -----#    
    #  Get    
setGeneric ("em.mean", signature = ".Object", 
            function (.Object) standardGeneric ("em.mean"))
setMethod ("em.mean", "ErrorModel.300", 
           function (.Object) .Object@em.mean);

    #  Set    
setGeneric ("em.mean<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("em.mean<-"))
setMethod ("em.mean<-", "ErrorModel.300", 
           function (.Object, value) initialize (.Object, em.mean = value))

                #-----  em.sd  -----#    
    #  Get    
setGeneric ("em.sd", signature = ".Object", 
            function (.Object) standardGeneric ("em.sd"))
setMethod ("em.sd", "ErrorModel.300", 
           function (.Object) .Object@em.sd);

    #  Set    
setGeneric ("em.sd<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("em.sd<-"))
setMethod ("em.sd<-", "ErrorModel.300", 
           function (.Object, value) initialize (.Object, em.sd = value))

#------------------------------------------------------------------------------

setMethod ("values.were.initialized", "ErrorModel.300", 
function (.Object)
    {
    if (is.uninitialized.number (.Object@em.mean))
        stop ("em.mean was never set.\n")

    if (is.uninitialized.number (.Object@em.sd))
        stop ("em.sd was never set.\n")

        #------------------------------------------------------------
        #  If it makes it to here without stopping, then the values 
        #  were initialized.  Otherwise, there should have been a 
        #  fatal error.
        #------------------------------------------------------------
        
    return (TRUE)
    }
)  
         
#------------------------------------------------------------------------------

setMethod ("compute.error.factor.with.initialized.values", "ErrorModel.300", 
function (.Object, base.value)
    {
    return (rnorm (1, .Object@em.mean, .Object@em.sd))
    }
)  
         
#------------------------------------------------------------------------------

test.ErrorModel.300 <- function (name.of.class.to.test)    #  random normal errors
    {
    cat ("\n\n---------------------\n\nTesting ", name.of.class.to.test, sep='')
    
#    test.em <- new (name.of.class.to.test)    #  Test error trapping by removing "#"
##    test.em <- new (name.of.class.to.test, em.mean = 3.0)

    test.em <- new (name.of.class.to.test, em.mean = 3.0, em.sd = 2.0)
    cat ("    < ", em.description (test.em), " >\n")
    
        #--------------------
        
    x.true <- 100
    
    x.apparent <- apply.error.to (test.em, x.true)
    cat ("\nUsing mean = 3.0, sd = 2.0:")
    cat ("\nx.true = ", x.true, "\nx.apparent = ", x.apparent, "\n")

        #--------------------
        
    em.mean (test.em) <- 0.0
    em.sd (test.em) <- 1.0

    cat ("\nAfter resetting mean = 0.0 and sd = 1.0 and using error factor:")
    x.error.factor <- compute.error.factor (test.em, x.true)    
    cat ("\nx.error.factor = ", x.error.factor, "\n")     
    
    x.apparent <- apply.error.to (test.em, x.true, x.error.factor)
    cat ("\nAfter resetting mean = 0.0 and sd = 1.0 and using error factor:")
    cat ("\nx.true = ", x.true, "\nx.apparent = ", x.apparent, "\n") 

        #--------------------
        
    cat ("\nRepeating using error factor:")
    x.error.factor <- compute.error.factor (test.em, x.true)    
    cat ("\nx.error.factor = ", x.error.factor, "\n")     
    
    x.apparent <- apply.error.to (test.em, x.true, x.error.factor)
    cat ("\nAfter repeating using error factor:")
    cat ("\nx.true = ", x.true, "\nx.apparent = ", x.apparent, "\n") 

        #--------------------
        
#    num.reps <- 100   
    ef <- rep (0, num.reps)
    app <- rep (0, num.reps)
    cat ("\n\nErrorModel.300\n")
    for (cur.idx in 1:num.reps)
        {
        ef [cur.idx] <- compute.error.factor (test.em, x.true)
        app [cur.idx] <- apply.error.to (test.em, x.true, ef [cur.idx])
        
###        cat ("\n    ", cur.idx, ":    ", ef [cur.idx], "    ", app [cur.idx])
        }
    cat ("\n\nmean.ef = ", mean (ef), "    sd.ef = ", sd (ef), "    median.ef = ", median (ef))
    cat ("\nmean.app = ", mean (app), "    sd.app = ", sd (app), "    median.app = ", median (app))
    cat ("\n    where base.value  = ", x.true)
    cat ("\n          em.mean     = ", em.mean (test.em))
    cat ("\n          em.sd       = ", em.sd (test.em))
    
#    print (test.em)
    }
    
#==============================================================================

    #-------------------------------------------------------------
    #  ErrorModel.301:  random normal return
    #
    #  Returns a uniform normal number - completely ignores input value.
    #-------------------------------------------------------------
    
setClass ("ErrorModel.301", 
	 	  prototype = prototype (em.name = "ErrorModel.301", 
	 	                         em.description = "random normal return"
	 	                        ),
	 	  contains = "ErrorModel.300"
         );

#------------------------------------------------------------------------------

setMethod ("error.computation", "ErrorModel.301", 
function (.Object, base.value, err.factor)
    {
    return (err.factor)
    }
)  
         
#==============================================================================

    #----------------------------------------------------------------------
    #  ErrorModel.302:  random normal additive error
    #
    #  A random normal value with a specified mean and standard deviation 
    #  is added to the input value.  
    #----------------------------------------------------------------------
    
setClass ("ErrorModel.302", 
	 	  prototype = prototype (em.name = "ErrorModel.302", 
	 	                         em.description = "random normal additive error"
	 	                        ),
	 	  contains = "ErrorModel.300"
         );
         
#------------------------------------------------------------------------------

setMethod ("error.computation", "ErrorModel.302", 
function (.Object, base.value, err.factor)
    {
    return (base.value + err.factor)
    }
)  
         
#==============================================================================

    #----------------------------------------------------------------------
    #  ErrorModel.303:  random normal multiplicative error
    #
    #  A random normal value with a specified mean and standard deviation 
    #  is multiplied times the input value.  
    #----------------------------------------------------------------------
    
setClass ("ErrorModel.303", 
	 	  prototype = prototype (em.name = "ErrorModel.303", 
	 	                         em.description = "random normal multiplicative error"
	 	                        ),
	 	  contains = "ErrorModel.300"
         );
         
#------------------------------------------------------------------------------

setMethod ("error.computation", "ErrorModel.303", 
function (.Object, base.value, err.factor)
    {
    return (base.value * err.factor)
    }
)  
         
#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================

                          #  Test routines.
    
#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================

num.reps <- 1000    

test.ErrorModel <- function ()
    {
    test.ErrorModel.000 ()    #  no error    
    
    for (em in c("ErrorModel.101", "ErrorModel.102", "ErrorModel.103"))
        {
        test.ErrorModel.100 (em)
        }

    for (em in c("ErrorModel.201", "ErrorModel.202", "ErrorModel.203"))
        {
        test.ErrorModel.200 (em)
        }

    for (em in c("ErrorModel.301", "ErrorModel.302", "ErrorModel.303"))
        {
        test.ErrorModel.300 (em)
        }
    }

#==============================================================================

#test.ErrorModel ()

#==============================================================================

