#==============================================================================

                       # source ("ErrorModel.R")

#  Base class for error models to apply to correct data to generate 
#  apparent data or to do other things like jitter data.

#  The basic idea of this class is that you have a function to 
#  generate an error amount (e.g., a uniform or normally distributed number) 
#  and an error function for applying that error amount to some base value 
#  (e.g., add it to the base value or multiply it times the base value).  
#  You can also specify bounds on the amount of error and on the result 
#  of applying the error.  For example, you may want the amount of error 
#  to be in the range of 70 to 130% of the base value but you want to be 
#  sure that the resulting value after applying that error can't be less 
#  than 5.  

#  There are 2 main functions to use:
#    - determine.legal.err.amt (.Object, base.value, err.amt = NA)
#      Computes the amount of error to apply and returns that value.
#      You would use this function if you wanted to save the amount of 
#      error to use later, etc.  
#      However, if you don't want to reuse that value later, you can 
#      call the function that calls this one and then applies it to 
#      some base value:
#    - apply.err.to.base.value (.Object, base.value, err.amt = NaN)
#      This function takes a base value (e.g., the "correct" value that 
#      you want to damage) and then applies an error to it.  
#      You can either pass the amount of error in as an argument (e.g., 
#      using a value you computed and saved earlier by calling the 
#      function determine.legal.err.amt() or you can let the function 
#      compute the amount of error itself (in which case, it calls 
#      determine.legal.err.amt() directly).

#  You create different error models by setting the err.func and 
#  err.amt.generator instance variables to be objects of the appropriate 
#  class for your error.  The ErrorFunc classes provide constant, additive, 
#  and multiplicative application of the error amount.  The ErrorAmtGenerator 
#  classes control whether the error amount to be applied is a constant or 
#  a random number, e.g., drawn from a uniform, normal, or truncated normal 
#  distribution.

#  I really need to split this class into an ErrorModel.NoError and an 
#  ErrorModel.SimpleError class, but right now, there's no time to do 
#  a  careful job of it so I will leave it for sometime when it becomes 
#  important.  For the moment, you can duplicate the NoError model by 
#  using the Additive error function and the Constant error generator 
#  with a 0 constant.

#==============================================================================

#  History:

#  Created January 2011 - BTL

#==============================================================================

                #-----  as.string  -----#

setGeneric ("as.string", signature = ".Object", 
			function (.Object) standardGeneric ("as.string"))
DEBUG <- FALSE

#--------------------
source ('constants.R')

source ('ErrorModel/Interval.R')
###cat("\n\nAfter sourcing Interval.R\n")
###showMethods("as.string")

source ('ErrorModel/ErrorFunc.R')
###cat("\n\nAfter sourcing ErrorFunc.R\n")
###showMethods("as.string")

source ('ErrorModel/ErrorAmtGenerator.R')
###cat("\n\nAfter sourcing ErrorAmtGenerator.R\n")
###showMethods("as.string")

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
          representation (name = "character",
                          description = "character", 
                          
                          result.bounds = "Interval",
                          err.bounds = "Interval", 
                          
                          err.func = "ErrorFunc",
                          err.amt.generator = "ErrorAmtGenerator"                          
						  ),

	 	   prototype (    name = "ErrorModel",
                          description = "error model base class",
                          
                          result.bounds = new ("Interval", 
                                               lower.bound = -Inf,
                                               lower.bound.is.exclusive = TRUE,
                                               upper.bound = Inf,
                                               upper.bound.is.exclusive = TRUE),
                          
                          err.bounds = new ("Interval", 
                                            lower.bound = -Inf,
                                            lower.bound.is.exclusive = TRUE,
                                            upper.bound = Inf,
                                            upper.bound.is.exclusive = TRUE), 
                                               
                          err.func = new ("ErrorFunc"),
                          err.amt.generator = new ("ErrorAmtGenerator")
                      )
              )

#==============================================================================

    #  Create generic and specific get and set routines for 
    #  all instance variables.

#==============================================================================

                #-----  name  -----#
    #  Get    
setGeneric ("name", signature = "x", 
            function (x) standardGeneric ("name"))            
setMethod ("name", "ErrorModel", 
           function (x) x@name)

    #  Set    
setGeneric ("name<-", signature = "x", 
            function (x, value) standardGeneric ("name<-"))
setMethod ("name<-", "ErrorModel", 
           function (x, value) initialize (x, name = value))

                #-----  description  -----#
    #  Get    
setGeneric ("description", signature = "x", 
            function (x) standardGeneric ("description"))            
setMethod ("description", "ErrorModel", 
           function (x) x@description)

    #  Set    
setGeneric ("description<-", signature = "x", 
            function (x, value) standardGeneric ("description<-"))
setMethod ("description<-", "ErrorModel", 
           function (x, value) initialize (x, description = value))

                #-----  result.bounds  -----#    
    #  Get    
setGeneric ("result.bounds", signature = ".Object", 
            function (.Object) standardGeneric ("result.bounds"))
setMethod ("result.bounds", "ErrorModel", 
           function (.Object) .Object@result.bounds)

    #  Set    
setGeneric ("result.bounds<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("result.bounds<-"))
setMethod ("result.bounds<-", "ErrorModel", 
           function (.Object, value) initialize (.Object, result.bounds = value))

                #-----  err.bounds  -----#    
    #  Get    
setGeneric ("err.bounds", signature = ".Object", 
            function (.Object) standardGeneric ("err.bounds"))
setMethod ("err.bounds", "ErrorModel", 
           function (.Object) .Object@err.bounds)

    #  Set    
setGeneric ("err.bounds<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("err.bounds<-"))
setMethod ("err.bounds<-", "ErrorModel", 
           function (.Object, value) initialize (.Object, err.bounds = value))

                #-----  err.func  -----#    
    #  Get    
setGeneric ("err.func", signature = ".Object", 
            function (.Object) standardGeneric ("err.func"))
setMethod ("err.func", "ErrorModel", 
           function (.Object) .Object@err.func)

    #  Set    
setGeneric ("err.func<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("err.func<-"))
setMethod ("err.func<-", "ErrorModel", 
           function (.Object, value) initialize (.Object, err.func = value))

                #-----  err.amt.generator  -----#    
    #  Get    
setGeneric ("err.amt.generator", signature = ".Object", 
            function (.Object) standardGeneric ("err.amt.generator"))
setMethod ("err.amt.generator", "ErrorModel", 
           function (.Object) .Object@err.amt.generator)

    #  Set    
setGeneric ("err.amt.generator<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("err.amt.generator<-"))
setMethod ("err.amt.generator<-", "ErrorModel", 
           function (.Object, value) initialize (.Object, err.amt.generator = value))

#==============================================================================

    #  Convenience set and get routines for instance variables inside the 
    #  result interval and the error interval.
    
    #  NOTE that the set() routines MUST return the object itself.  
    #  If they don't, then the original object in the calling routine 
    #  gets reassigned to whatever was the last thing in the set routine.
    #  For example without the last line returning the object here, 
    
    #      em <- new ("ErrorModel")
    #      result.lower.bound(em) <- 5
    
    #  resets em to be an Interval, not the ErrorModel that it started out as
    #  and so if the next line is:
    
    #      result.upper.bound(em) <- 20
    
    #  then R chokes and says something cryptic likeß:
    
    #      Error in function (classes, fdef, mtable)  : 
    #        unable to find an inherited method for function "result.upper.bound<-", for signature "Interval"


#==============================================================================

                #-----  result.lower.bound  -----#    
    #  Get    
setGeneric ("result.lower.bound", signature = ".Object", 
            function (.Object) standardGeneric ("result.lower.bound"))
setMethod ("result.lower.bound", "ErrorModel", 
           function (.Object) lower.bound (.Object@result.bounds))

    #  Set    
setGeneric ("result.lower.bound<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("result.lower.bound<-"))
setMethod ("result.lower.bound<-", "ErrorModel", 
           function (.Object, value) 
               {
               temp.result.bounds <- .Object@result.bounds
               lower.bound (temp.result.bounds) <- value
               .Object@result.bounds <- temp.result.bounds
               return (.Object)
               }
)

#------------------------------------------------------------------------------

                #-----  res.lower.bound.is.exclusive  -----#    
    #  Get    
setGeneric ("res.lower.bound.is.exclusive", signature = ".Object", 
            function (.Object) standardGeneric ("res.lower.bound.is.exclusive"))
setMethod ("res.lower.bound.is.exclusive", "ErrorModel", 
           function (.Object) lower.bound.is.exclusive (.Object@result.bounds))

    #  Set    
setGeneric ("res.lower.bound.is.exclusive<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("res.lower.bound.is.exclusive<-"))
setMethod ("res.lower.bound.is.exclusive<-", "ErrorModel", 
           function (.Object, value) 
               {
               temp.result.bounds <- .Object@result.bounds
               lower.bound.is.exclusive (temp.result.bounds) <- value
               .Object@result.bounds <- temp.result.bounds               
               return (.Object)
               }
)

#------------------------------------------------------------------------------

                #-----  result.upper.bound  -----#    
    #  Get    
setGeneric ("result.upper.bound", signature = ".Object", 
            function (.Object) standardGeneric ("result.upper.bound"))
setMethod ("result.upper.bound", "ErrorModel", 
           function (.Object) upper.bound (.Object@result.bounds))

    #  Set    
setGeneric ("result.upper.bound<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("result.upper.bound<-"))
setMethod ("result.upper.bound<-", "ErrorModel", 
           function (.Object, value) 
               {
               temp.result.bounds <- .Object@result.bounds
               upper.bound (temp.result.bounds) <- value
               .Object@result.bounds <- temp.result.bounds   
               return (.Object)
               }
)

#------------------------------------------------------------------------------

                #-----  res.upper.bound.is.exclusive  -----#    
    #  Get    
setGeneric ("res.upper.bound.is.exclusive", signature = ".Object", 
            function (.Object) standardGeneric ("res.upper.bound.is.exclusive"))
setMethod ("res.upper.bound.is.exclusive", "ErrorModel", 
           function (.Object) upper.bound.is.exclusive (.Object@result.bounds))

    #  Set    
setGeneric ("res.upper.bound.is.exclusive<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("res.upper.bound.is.exclusive<-"))
setMethod ("res.upper.bound.is.exclusive<-", "ErrorModel", 
           function (.Object, value) 
               {
               temp.result.bounds <- .Object@result.bounds
               upper.bound.is.exclusive (temp.result.bounds) <- value
               .Object@result.bounds <- temp.result.bounds               
               return (.Object)
               }
)

#------------------------------------------------------------------------------

                #-----  err.lower.bound  -----#    
    #  Get    
setGeneric ("err.lower.bound", signature = ".Object", 
            function (.Object) standardGeneric ("err.lower.bound"))
setMethod ("err.lower.bound", "ErrorModel", 
           function (.Object) lower.bound (.Object@err.bounds))

    #  Set    
setGeneric ("err.lower.bound<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("err.lower.bound<-"))
setMethod ("err.lower.bound<-", "ErrorModel", 
           function (.Object, value) 
               {
               temp.err.bounds <- .Object@err.bounds
               lower.bound (temp.err.bounds) <- value
               .Object@err.bounds <- temp.err.bounds               
               return (.Object)
               }
)

#------------------------------------------------------------------------------

                #-----  err.lower.bound.is.exclusive  -----#    
    #  Get    
setGeneric ("err.lower.bound.is.exclusive", signature = ".Object", 
            function (.Object) standardGeneric ("err.lower.bound.is.exclusive"))
setMethod ("err.lower.bound.is.exclusive", "ErrorModel", 
           function (.Object) lower.bound.is.exclusive (.Object@err.bounds))

    #  Set    
setGeneric ("err.lower.bound.is.exclusive<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("err.lower.bound.is.exclusive<-"))
setMethod ("err.lower.bound.is.exclusive<-", "ErrorModel", 
           function (.Object, value) 
               {
               temp.err.bounds <- .Object@err.bounds
               lower.bound.is.exclusive (temp.err.bounds) <- value
               .Object@err.bounds <- temp.err.bounds               
               return (.Object)
               }
)

#------------------------------------------------------------------------------

                #-----  err.upper.bound  -----#    
    #  Get    
setGeneric ("err.upper.bound", signature = ".Object", 
            function (.Object) standardGeneric ("err.upper.bound"))
setMethod ("err.upper.bound", "ErrorModel", 
           function (.Object) lower.bound (.Object@err.bounds))

    #  Set    
setGeneric ("err.upper.bound<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("err.upper.bound<-"))
setMethod ("err.upper.bound<-", "ErrorModel", 
           function (.Object, value) 
               {
               temp.err.bounds <- .Object@err.bounds
               lower.bound (temp.err.bounds) <- value
               .Object@err.bounds <- temp.err.bounds               
               return (.Object)
               }
)

#------------------------------------------------------------------------------

                #-----  err.upper.bound.is.exclusive  -----#    
    #  Get    
setGeneric ("err.upper.bound.is.exclusive", signature = ".Object", 
            function (.Object) standardGeneric ("err.upper.bound.is.exclusive"))
setMethod ("err.upper.bound.is.exclusive", "ErrorModel", 
           function (.Object) upper.bound.is.exclusive (.Object@err.bounds))

    #  Set    
setGeneric ("err.upper.bound.is.exclusive<-", signature = ".Object", 
            function (.Object, value) standardGeneric ("err.upper.bound.is.exclusive<-"))
setMethod ("err.upper.bound.is.exclusive<-", "ErrorModel", 
           function (.Object, value) 
               {
               temp.err.bounds <- .Object@err.bounds
               upper.bound.is.exclusive (temp.err.bounds) <- value
               .Object@err.bounds <- temp.err.bounds               
               return (.Object)
               }
)

#==============================================================================

setMethod ("as.string", "ErrorModel", 
function (.Object)
    {
#    browser()
    return (paste ('[', .Object@name, ':', 
                    ' rb=', as.string (.Object@result.bounds), 
                    ' eb=', as.string (.Object@err.bounds), 
                    ' ef=', as.string (.Object@err.func), 
                    ' eg=', as.string (.Object@err.amt.generator), 
                    ']', 
                   sep=''))

    }
)

#------------------------------------------------------------------------------

                #-----  handle.illegal.err.amt  -----#

setGeneric ("handle.illegal.err.amt", signature = ".Object", 
			function (.Object, err.amt, legal.err.bounds) standardGeneric ("handle.illegal.err.amt"))
			
#--------------------
 
setMethod ("handle.illegal.err.amt", "ErrorModel", 
function (.Object, err.amt, legal.err.bounds)
    {
        #    possible actions to repair a bad err.amt:
        #        - stop
        #        - generate a new value using the legal bounds
        #        - modify the old value as best you can, e.g., pick the  
        #          closest interval endpoint (though this could be 
        #          difficult if the endpoint is not an inclusive value - 
        #          you'd have to use some delta or something...)
        
        #  For the moment, just stop.
    err.msg <- paste ("Illegal error amount = ", err.amt, 
                      ".  Must be in interval ", 
                      as.string (legal.err.bounds), sep='')
                      
    stop (err.msg)                  
    }      
)

#------------------------------------------------------------------------------

                #-----  generate.err.bounds  -----#

setGeneric ("generate.err.bounds", signature = ".Object", 
			function (.Object, base.value) standardGeneric ("generate.err.bounds"))
			
#--------------------
 
setMethod ("generate.err.bounds", "ErrorModel", 
function (.Object, base.value)
    {
    min.err <- compute.min.err.from.base.value (.Object@err.func,
                                                base.value, 
                                                lower.bound (.Object@result.bounds), 
                                                upper.bound (.Object@result.bounds))
    max.err <- compute.max.err.from.base.value (.Object@err.func,
                                                base.value, 
                                                lower.bound (.Object@result.bounds), 
                                                upper.bound (.Object@result.bounds))

    err.func.inverse.err.bounds <- 
        new ("Interval", 
             lower.bound = min.err,
             lower.bound.is.exclusive = lower.bound.is.exclusive (.Object@err.bounds),
             upper.bound = max.err,
             upper.bound.is.exclusive = upper.bound.is.exclusive (.Object@err.bounds))

    if(DEBUG) cat ("\nerr.func.inverse.err.bounds = ", as.string (err.func.inverse.err.bounds))

#browser()
#efieb = (-6,-4)  results
#.orb = (-1,1)    error
    new.err.bounds <- 
        restrict.interval.to.inner.bounds (err.func.inverse.err.bounds, 
#####                                           .Object@result.bounds)    #  BTL - 2011.02.16 
                                           .Object@err.bounds)

#        err.func.inverse.err.bounds

    if(DEBUG) cat ("\nnew.err.bounds = ", as.string (new.err.bounds))

#browser()
                                           
    return (new.err.bounds)                                       
    }
)

#------------------------------------------------------------------------------

                #-----  determine.legal.err.amt -----#

setGeneric ("determine.legal.err.amt", signature = ".Object", 
			function (.Object, base.value, err.amt = NA) standardGeneric ("determine.legal.err.amt"))
			
#--------------------
setMethod ("determine.legal.err.amt", "ErrorModel", 
determine.legal.err.amt <- function (.Object, base.value, err.amt = NA)
    {
        #-------------------------------------------------------------
        #  The amount of error that can be applied to the base value 
        #  may depend on the base value, so determine what bounds 
        #  should be placed on the error applied to this base value 
        #  right now.
        #-------------------------------------------------------------
        
    legal.err.bounds <- generate.err.bounds (.Object, base.value)
#browser()    
    
        #------------------------------------------------------------
        #  The caller can either supply an amount of error to apply 
        #  (e.g., one that was stored in the database) or they can 
        #  ask for one to be generated right now.  
        #  In either case, the value needs to be checked to be sure 
        #  that it's in the range of legal error values.
        #------------------------------------------------------------
        
    if (is.na (err.amt))
        {
            #------------------------------------------------------
            #  No error amount specified in call, so generate one 
            #  using the legal bounds just generated.
            #------------------------------------------------------
            
#        err.amt <- apply.legal.err.to.base.value (.Object@err.func, 
        err.amt <- generate.err.amt (.Object@err.amt.generator, 
                                     base.value, 
                                     legal.err.bounds)
                                     
#cat ("\ngenerate.err.amt::err.amt = ", err.amt)
#cat ("\n")
#browser()
                                                                          
                                                          
        } else
        {
            #------------------------------------------------------
            #  Error amount was given in the call.  
            #  Make sure it's within the legal bounds.  
            #  If it's not, then 
            #------------------------------------------------------
            
        if (! in.interval (legal.err.bounds, err.amt))
            err.amt <- 
##                handle.illegal.err.amt (.Object@err.amt.generator, 
                handle.illegal.err.amt (.Object, 
                                        err.amt, 
                                        legal.err.bounds)
        }
        
    return (err.amt)
    }
)

#------------------------------------------------------------------------------

                #-----  apply.err.to.base.value  -----#

setGeneric ("apply.err.to.base.value", signature = ".Object", 
			function (.Object, base.value, err.amt = NA) standardGeneric ("apply.err.to.base.value"))
			
#--------------------
 
setMethod ("apply.err.to.base.value", "ErrorModel", 
apply.err.to.base.value <- function (.Object, base.value, err.amt = NaN)
    {
    ret.value <- NaN

    err.amt <- determine.legal.err.amt (.Object, base.value, err.amt)
#browser()

    if (is.na (err.amt))  
        {
        stop ("Illegal error amount.")       
        
        } else 
        {
            #  Compute the new erroneous result using the err.amt 
            #  that is now guaranteed to produce a legal result.
        ret.value <- 
            apply.legal.err.to.base.value (.Object@err.func, 
                                           base.value, 
                                           err.amt)
        }

#browser()
        
    return (ret.value)        
    }
)

#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================

test.ErrorModel <- function ()
    {
    go.through.combinations()
#    stop("Done with go.through.combinations().")
    
    
    em <- new ("ErrorModel")
    
#    ef <- new ("ErrorFunc.Const")
    ef <- new ("ErrorFunc.Add")
#    ef <- new ("ErrorFunc.Mult")
    err.func (em) <- ef

#    eag <- new ("ErrorAmtGenerator.Const", const.err.amt = 3)

    eag <- new ("ErrorAmtGenerator.UnifRand")
#    result.lower.bound (em) <- -1
    err.lower.bound (em) <- -1
cat ("\nAfter assigning result.lower.bound(em):\n")
print (em)
#    result.upper.bound (em) <- 1
    err.upper.bound (em) <- 1
cat ("\nAfter assigning result.upper.bound(em):\n")
print (em)
    
#    eag <- new ("ErrorAmtGenerator.NormRand", em.mean = 1, em.sd = 1)
#    use.point.itself.as.mean (eag) <- TRUE

    err.amt.generator (em) <- eag
    
    cat ("\nem = \n")
    print (em)
    
    base.value <- 5
#    app.value <- apply.err.to.base.value (em, base.value, 3)
    app.value <- apply.err.to.base.value (em, base.value)
    cat ("\n\napp.value = ", app.value, "\n")
    }

#==============================================================================

go.through.combinations <- function()
    {
cat("\n\nAt start of go.through.combinations()\n")
showMethods("as.string")
    
    
    test.base.value <- 5
    test.constant <- 3
    test.mean.value <- 0
    test.sd <- 1
              
    test.res.lower.bound <- 0
    test.res.upper.bound <- 1
    test.err.lower.bound <- 0
    test.err.upper.bound <- 0.5

    ef.c <- new ("ErrorFunc.Const", name="ef.c")
    ef.a <- new ("ErrorFunc.Add", name="ef.a")
    ef.m <- new ("ErrorFunc.Mult", name="ef.m")

    eag.c <- new ("ErrorAmtGenerator.Const", name="eag.c", 
                    const.err.amt = test.constant)
    eag.u <- new ("ErrorAmtGenerator.UnifRand", name="eag.u")
    eag.n <- new ("ErrorAmtGenerator.NormRand", name="eag.n", 
                    use.point.itself.as.mean = TRUE,           
                    em.mean = test.mean.value,
                    em.sd = test.sd)

    em <- new ("ErrorModel")    
    result.lower.bound (em) <- test.res.lower.bound
    result.upper.bound (em) <- test.res.upper.bound
    err.lower.bound (em) <- test.err.lower.bound
    err.lower.bound (em) <- test.err.lower.bound

    eag.set <- c(eag.c, eag.u, eag.n)
    idx.of.eag.n <- 3
#    for (eag.idx in 1:length(eag.set))
        {
#        browser()
#        err.amt.generator (em) <- eag.set [eag.idx]

#        eag.idx <- 1
#       err.amt.generator (em) <- eag.c

        eag.idx <- 2
        err.amt.generator (em) <- eag.u
        
#        eag.idx <- 3
#        err.amt.generator (em) <- eag.n

        for (ef in c(ef.c, ef.a, ef.m))
            {
            cat ("\n\n")
            err.func (em) <- ef
            for (test.res.lower.bound.is.exclusive in c(TRUE, FALSE))
                {
                res.lower.bound.is.exclusive (em) <- test.res.lower.bound.is.exclusive
                for (test.res.upper.bound.is.exclusive in c(TRUE, FALSE))
                    {
                    res.upper.bound.is.exclusive (em) <- test.res.upper.bound.is.exclusive
                    for (test.err.lower.bound.is.exclusive in c(TRUE, FALSE))
                        {
                        err.lower.bound.is.exclusive (em) <- test.err.lower.bound.is.exclusive
                        for (test.err.upper.bound.is.exclusive in c(TRUE, FALSE))
                            {
                            err.upper.bound.is.exclusive (em) <- test.err.upper.bound.is.exclusive
                            tryCatch (
                                { 
                                if (eag.idx == idx.of.eag.n)
                                    {
                                        #  If using normal distribution, also have 
                                        #  to change another variable.
                                    for (test.use.point.itself.as.mean in c(TRUE, FALSE))
                                        {
                                        use.point.itself.as.mean (eag.n) <- test.use.point.itself.as.mean
                                        err.amt.generator (em) <- eag.n
                                    
                                        cat ("\n", as.string(em))                                
                                        cat ("\n    app.value = ", apply.err.to.base.value (em, test.base.value))
                                        }    
                                    } else    #  not using normal distribution
                                    {
                                    cat ("\n", as.string(em))    
                                    cat ("\n    app.value = ", apply.err.to.base.value (em, test.base.value))
                                    }
                                }, 
                                condition = function (ex) { cat ("\nCaught exception: "); print (ex)  }  
                                )
                            }
                        }
                    }
                }
            }
        }
    cat ("\n")
    }

#==============================================================================


	#-------------------------------------------------------------------
	#  Not sure what's going on here.  This may just be leftovers from 
	#  playing around with exceptions.  Not using it at the moment.
	#-------------------------------------------------------------------
	
test.tryCatch <- function ()
    {
    for (i in 1:3)
      {
      x <- 0
      y <- 
      tryCatch(
           { stop("some kind of an error called stop") }, 
           condition = function(ex) { cat ("\n\nclass(ex) = ", class(ex)); 
                                      cat ("\nex = ", ex);
                                      cat ("\ni = ", i, "\n"); 
                                      x <<- i; 
                                      i + 10
                                    }, 
           finally = 100
           ) 
      cat ("\nx = ", x, " y = ", y, "\n")         
      }     
  }
  
#==============================================================================


test.trunc.norm.err.model <- function()
  {
    cat("\n\nAt start of test.trunc.norm.err.model()\n")
    showMethods("as.string")
    
    
    test.base.value <- 0.7
    test.mean.value <- 0
    test.sd <- 0.01
              
    test.res.lower.bound <- 0
    test.res.upper.bound <- 1
    #test.err.lower.bound <- 0
    #test.err.upper.bound <- 0.5

    ef.a <- new ("ErrorFunc.Add", name="ef.a")

    eag.n <- new ("ErrorAmtGenerator.NormRand", name="eag.n", 
                  use.point.itself.as.mean = TRUE,           
                  #em.mean = test.mean.value,
                  em.sd = test.sd)

    em <- new ("ErrorModel")
    
    result.lower.bound (em) <- test.res.lower.bound
    result.upper.bound (em) <- test.res.upper.bound
    #err.lower.bound (em) <- test.err.lower.bound
    #err.lower.bound (em) <- test.err.lower.bound

    err.amt.generator (em) <- eag.n
    err.func (em) <- ef.a

    print (em)

    num.reps <- 1000
    ret.values <- rep (-1, num.reps)

    for(i in 1:num.reps ){
      tryCatch (
                {
                  ret.values [i] <- apply.err.to.base.value (em, test.base.value)
                  cat ("\n test.base.value=",test.base.value, "   app.value = ",
                       ret.values [i])
                },
                condition = function (ex) { cat ("\nCaught exception: "); print (ex)  }  
                )

    }

    plot (ret.values)
    hist (ret.values)
    
    cat ("\n")
  }


#==============================================================================


#test.ErrorModel ()
#test.trunc.norm.err.model()
#==============================================================================
