#==============================================================================

                    #  source ("ErrorFunc.R")

#==============================================================================

#  History:

#  - Extracted from original ErrorModel.R class - 2011.01.19 - BTL

#==============================================================================

source ('ErrorModel/Interval.R')    #  to get the generic for as.string()

#==============================================================================

    #----------------------------------------------------------------------
    #  ErrorFunc:  Error Function base class
    #----------------------------------------------------------------------
    
setClass ("ErrorFunc", 
          representation (name = "character",
                          description = "character"
                          ),
                          
	 	  prototype = prototype (name = "ErrorFunc", 
	 	                         description = "Error Function base class"
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
setMethod ("name", "ErrorFunc", 
           function (x) x@name);

    #  Set    
setGeneric ("name<-", signature = "x", 
            function (x, value) standardGeneric ("name<-"))
setMethod ("name<-", "ErrorFunc", 
           function (x, value) initialize (x, name = value))

                #-----  description  -----#
    #  Get    
setGeneric ("description", signature = "x", 
            function (x) standardGeneric ("description"))            
setMethod ("description", "ErrorFunc", 
           function (x) x@description);

    #  Set    
setGeneric ("description<-", signature = "x", 
            function (x, value) standardGeneric ("description<-"))
setMethod ("description<-", "ErrorFunc", 
           function (x, value) initialize (x, description = value))

#==============================================================================

setMethod ("as.string", "ErrorFunc", 
function (.Object)
    {
    return (.Object@name)
    }
)

#------------------------------------------------------------------------------

                  #-----  apply.legal.err.to.base.value  -----#

setGeneric ("apply.legal.err.to.base.value", signature = ".Object", 
			function (.Object, base.value, err.amt) standardGeneric ("apply.legal.err.to.base.value"))
			
#--------------------
 
setMethod ("apply.legal.err.to.base.value", "ErrorFunc", 
function (.Object, base.value, err.amt)
    {
    stop ("Function apply.legal.err.to.base.value() is not defined for base class ErrorFunc.\n")
    }
)  
         
#------------------------------------------------------------------------------

                #-----  compute.min.err.from.base.value -----#

setGeneric ("compute.min.err.from.base.value", signature = ".Object", 
			function (.Object, base.value, result.min, result.max) standardGeneric ("compute.min.err.from.base.value"))
			
#--------------------
 
setMethod ("compute.min.err.from.base.value", "ErrorFunc", 
function (.Object, base.value, result.min, result.max)
    {
    stop ("Function compute.min.err.from.base.value() is not defined for base class ErrorFunc.\n")
    }
)  
                              
#------------------------------------------------------------------------------

                #-----  compute.max.err.from.base.value -----#

setGeneric ("compute.max.err.from.base.value", signature = ".Object", 
			function (.Object, base.value, result.min, result.max) standardGeneric ("compute.max.err.from.base.value"))
			
#--------------------
 
setMethod ("compute.max.err.from.base.value", "ErrorFunc", 
function (.Object, base.value, result.min, result.max)
    {
    stop ("Function compute.max.err.from.base.value() is not defined for base class ErrorFunc.\n")
    }
)  
                              
#==============================================================================

    #----------------------------------------------------------------------
    #  ErrorFunc.Const:  constant error function
    #
    #  A specified error term is returned, regardless of the  
    #  specified base value.  
    #----------------------------------------------------------------------
    
setClass ("ErrorFunc.Const", 
	 	  prototype = prototype (name = "ErrorFunc.Const", 
	 	                         description = "constant error function"
	 	                        ),
	 	  contains = "ErrorFunc"
         );
         
#------------------------------------------------------------------------------
    #  These should really all be class methods since they make no use of 
    #  the object itself, but I don't know the syntax for that at the 
    #  moment...
#------------------------------------------------------------------------------
 
                  #-----  apply.legal.err.to.base.value  -----#

setMethod ("apply.legal.err.to.base.value", "ErrorFunc.Const", 
function (.Object, base.value, err.amt)
    {
#    browser()
    if (is.na (err.amt))
        stop ("No err.amt given to ErrorFunc.Const.")
        
    return (err.amt)
    }
)  
         
#------------------------------------------------------------------------------

                #-----  compute.min.err.from.base.value -----#

setMethod ("compute.min.err.from.base.value", "ErrorFunc.Const", 
function (.Object, base.value, result.min, result.max)
    {
    return (result.min - base.value)
    }
)  
                              
#------------------------------------------------------------------------------

                #-----  compute.max.err.from.base.value -----#

setMethod ("compute.max.err.from.base.value", "ErrorFunc.Const", 
function (.Object, base.value, result.min, result.max)
    {
    return (result.max - base.value)
    }
)  

#==============================================================================

    #----------------------------------------------------------------------
    #  ErrorFunc.Add:  additive error function
    #
    #  A specified error term is added to the specified base value.  
    #----------------------------------------------------------------------
    
setClass ("ErrorFunc.Add", 
	 	  prototype = prototype (name = "ErrorFunc.Add", 
	 	                         description = "additive error function"
	 	                        ),
	 	  contains = "ErrorFunc"
         );
         
#------------------------------------------------------------------------------
    #  These should really all be class methods since they make no use of 
    #  the object itself, but I don't know the syntax for that at the 
    #  moment...
#------------------------------------------------------------------------------

                #-----  apply.legal.err.to.base.value -----#

setMethod ("apply.legal.err.to.base.value", "ErrorFunc.Add", 
function (.Object, base.value, err.amt)
    {
        #-----------------------------------------------------------------
        #  This assumes that all error checking has been done before now 
        #  or will be done afterwards.
        #-----------------------------------------------------------------
        
    return (base.value + err.amt)
    }
)  
         
#------------------------------------------------------------------------------

                #-----  compute.min.err.from.base.value -----#

setMethod ("compute.min.err.from.base.value", "ErrorFunc.Add", 
function (.Object, base.value, result.min, result.max)
    {
    return (result.min - base.value)
    }
)  
                              
#------------------------------------------------------------------------------

                #-----  compute.max.err.from.base.value -----#

setMethod ("compute.max.err.from.base.value", "ErrorFunc.Add", 
function (.Object, base.value, result.min, result.max)
    {
    return (result.max - base.value)
    }
)  

#==============================================================================

    #----------------------------------------------------------------------
    #  ErrorFunc.Mult:  multiplicative error function
    #
    #  A specified error term is multiplied times the specified base value.  
    #----------------------------------------------------------------------
    
setClass ("ErrorFunc.Mult", 
	 	  prototype = prototype (name = "ErrorFunc.Mult", 
	 	                         description = "multiplicative error function"
	 	                        ),
	 	  contains = "ErrorFunc"
         );
         
#------------------------------------------------------------------------------
    #  These should really all be class methods since they make no use of 
    #  the object itself, but I don't know the syntax for that at the 
    #  moment...
#------------------------------------------------------------------------------

                #-----  apply.legal.err.to.base.value -----#

setMethod ("apply.legal.err.to.base.value", "ErrorFunc.Mult", 
function (.Object, base.value, err.amt)
    {
        #-----------------------------------------------------------------
        #  This assumes that all error checking has been done before now 
        #  or will be done afterwards.
        #-----------------------------------------------------------------
        
    return (base.value * err.amt)
    }
)  
         
#------------------------------------------------------------------------------

                #-----  compute.min.err.from.base.value -----#

setMethod ("compute.min.err.from.base.value", "ErrorFunc.Mult", 
function (.Object, base.value, result.min, result.max)
    {
    if (base.value > 0)  result.min / base.value  else
    if (base.value < 0)  result.max / base.value  else
    result.min
    }
)  
                              
#------------------------------------------------------------------------------

                #-----  compute.max.err.from.base.value -----#

setMethod ("compute.max.err.from.base.value", "ErrorFunc.Mult", 
function (.Object, base.value, result.min, result.max)
    {
    if (base.value > 0)  result.max / base.value  else
    if (base.value < 0)  result.min / base.value  else
    result.max
    }
)  

#==============================================================================

test.err.func <- function ()
    {
    ef.c <- new ("ErrorFunc.Const")
    
    cat ("\nef.c = ", as.string (ef.c), "\n")
    print (ef.c)
    
    cat ("\napply.legal.err.to.base.value (ef.m, 5, 10) = ", 
         apply.legal.err.to.base.value (ef.c, 5, 10), "\n\n")

        #----------
        
    ef.a <- new ("ErrorFunc.Add")
    
    cat ("\nef.a = ", as.string (ef.a), "\n")
    print (ef.a)
    
    cat ("\napply.legal.err.to.base.value (ef.m, 5, 10) = ", 
         apply.legal.err.to.base.value (ef.a, 5, 10), "\n\n")

        #----------
        
    ef.m <- new ("ErrorFunc.Mult")
    
    cat ("\n\nef.m = ", as.string (ef.m), "\n")
    print (ef.m)
    
    cat ("\napply.legal.err.to.base.value (ef.m, 5, 10) = ", 
         apply.legal.err.to.base.value (ef.m, 5, 10), "\n\n")
    }
    
#--------------------
 
###test.err.func()

#==============================================================================

