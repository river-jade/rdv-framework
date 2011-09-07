#==============================================================================

                    #  source ("ErrorAmtGenerator.R")

#==============================================================================

#  History:

#  - Extracted from original ErrorModel.R class - 2011.01.19 - BTL

#==============================================================================

library(msm)    #  To get the truncated normal function rtnorm().
#library(mvtnorm)    #  To get the truncated normal function rtnorm().

source ('ErrorModel/Interval.R')

#==============================================================================

    #----------------------------------------------------------------------
    #  ErrorAmtGenerator:  Error Function base class
    #----------------------------------------------------------------------
    
setClass ("ErrorAmtGenerator", 
          representation (name = "character",
                          description = "character"
                          ),
                          
	 	  prototype = prototype (name = "ErrorAmtGenerator", 
	 	                         description = "Error Amount Generator base class"
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
setMethod ("name", "ErrorAmtGenerator", 
           function (x) x@name);

    #  Set    
setGeneric ("name<-", signature = "x", 
            function (x, value) standardGeneric ("name<-"))
setMethod ("name<-", "ErrorAmtGenerator", 
           function (x, value) initialize (x, name = value))

                #-----  description  -----#
    #  Get    
setGeneric ("description", signature = "x", 
            function (x) standardGeneric ("description"))            
setMethod ("description", "ErrorAmtGenerator", 
           function (x) x@description);

    #  Set    
setGeneric ("description<-", signature = "x", 
            function (x, value) standardGeneric ("description<-"))
setMethod ("description<-", "ErrorAmtGenerator", 
           function (x, value) initialize (x, description = value))

#==============================================================================

                  #-----  generate.err.amt  -----#

setGeneric ("generate.err.amt", signature = ".Object", 
			function (.Object, base.value, legal.err.interval) standardGeneric ("generate.err.amt"))
			
#--------------------
 
setMethod ("generate.err.amt", "ErrorAmtGenerator", 
function (.Object, base.value, legal.err.interval)
    {
    stop ("Function generate.err.amt() is not defined for base class ErrorAmtGenerator.\n")
    }
)  
         
#==============================================================================

    #----------------------------------------------------------------------
    #  ErrorAmtGenerator.Const:  constant error generator
    #
    #  A constant error term is returned, regardless of the  
    #  specified base value.  
    #----------------------------------------------------------------------
    
setClass ("ErrorAmtGenerator.Const", 
          representation (const.err.amt = "numeric"
                          ),
	 	  prototype = prototype (name = "ErrorAmtGenerator.Const", 
	 	                         description = "constant error generator", 
	 	                         const.err.amt = NaN
	 	                        ),
	 	  contains = "ErrorAmtGenerator"
         );
         
#------------------------------------------------------------------------------

    #  Create generic and specific get and set routines for 
    #  all instance variables.

#------------------------------------------------------------------------------

                #-----  const.err.amt  -----#
    #  Get    
setGeneric ("const.err.amt", signature = "x", 
            function (x) standardGeneric ("const.err.amt"))            
setMethod ("const.err.amt", "ErrorAmtGenerator.Const", 
           function (x) x@const.err.amt);

    #  Set    
setGeneric ("const.err.amt<-", signature = "x", 
            function (x, value) standardGeneric ("const.err.amt<-"))
setMethod ("const.err.amt<-", "ErrorAmtGenerator.Const", 
           function (x, value) initialize (x, const.err.amt = value))

#------------------------------------------------------------------------------

setMethod ("generate.err.amt", "ErrorAmtGenerator.Const", 
function (.Object, base.value, legal.err.interval)
    {
        #-----------------------------------------------------------------
        #  This assumes that all error checking has been done before now 
        #  or will be done afterwards.
        #-----------------------------------------------------------------

    return (.Object@const.err.amt)
    }
)  
         
#------------------------------------------------------------------------------

setMethod ("as.string", "ErrorAmtGenerator.Const", 
function (.Object)
    {
    return (paste (.Object@name, ': ', 
                    ' const ', .Object@const.err.amt, 
                   sep=''))
    }
)

#==============================================================================

    #----------------------------------------------------------------------
    #  ErrorAmtGenerator.UnifRand:  uniform random error generator
    #
    #  A uniformly distributed random error term is generated based on the  
    #  legal error interval and the base value.
    #----------------------------------------------------------------------
    
setClass ("ErrorAmtGenerator.UnifRand", 
	 	  prototype = prototype (name = "ErrorAmtGenerator.UnifRand", 
	 	                         description = "uniform random error generator"
	 	                        ),
	 	  contains = "ErrorAmtGenerator"
         );
         
#------------------------------------------------------------------------------

setMethod ("as.string", "ErrorAmtGenerator.UnifRand", 
function (.Object)
    {
    return (.Object@name)
    }
)

#------------------------------------------------------------------------------

setMethod ("generate.err.amt", "ErrorAmtGenerator.UnifRand", 
function (.Object, base.value, legal.err.interval)
    {
        #-----------------------------------------------------------------
        #  This assumes that all error checking has been done before now 
        #  or will be done afterwards.
        #
        #  NOTE:  BTL - 2011.01.19
        #  One small issue here is that in R, the uniform random number 
        #  generator will exclude the interval endpoints except in the 
        #  case where the length of the interval is very small in 
        #  comparison to the lower bound of the interval (according 
        #  to the runif help page).  If you need to have a good chance 
        #  of the endpoints being included, then I'm not sure what to 
        #  do to fix this.  Might be able to do some kind of a rescaling 
        #  trick to give use an arbitrary interval that is really small 
        #  with respect to its min and then rescale the value returned 
        #  by runif() so that it falls into the real interval that you 
        #  want.  For now though, I don't think this is likely to be an 
        #  issue.
        #-----------------------------------------------------------------
#browser()  

    if (is.infinite (lower.bound (legal.err.interval))  || 
        is.infinite (upper.bound (legal.err.interval)))
        stop ("Both bounds of legal.err.interval must be finite when using uniform random error generator.")

    return (runif (1, 
                   min=lower.bound (legal.err.interval), 
                   max=upper.bound (legal.err.interval)))
    }
)  
         
#==============================================================================

    #----------------------------------------------------------------------
    #  ErrorAmtGenerator.NormRand:  normal random error generator
    #
    #  A normally distributed random error term is generated based on the  
    #  legal error interval and the base value.
    #----------------------------------------------------------------------
    
setClass ("ErrorAmtGenerator.NormRand", 
          representation (use.point.itself.as.mean = "logical",           
                          em.mean = "numeric",
                          em.sd = "numeric"
                          ),
                          
	 	  prototype = prototype (name = "ErrorAmtGenerator.NormRand", 
	 	                         description = "normal random error generator", 
	 	                         
	 	                         use.point.itself.as.mean = FALSE,           
                                 em.mean = NaN,
                                 em.sd = NaN
	 	                        ),
	 	  contains = "ErrorAmtGenerator"
         );
         
#------------------------------------------------------------------------------

    #  Create generic and specific get and set routines for 
    #  all instance variables.

#------------------------------------------------------------------------------

                #-----  use.point.itself.as.mean  -----#
    #  Get    
setGeneric ("use.point.itself.as.mean", signature = "x", 
            function (x) standardGeneric ("use.point.itself.as.mean"))            
setMethod ("use.point.itself.as.mean", "ErrorAmtGenerator.NormRand", 
           function (x) x@use.point.itself.as.mean);

    #  Set    
setGeneric ("use.point.itself.as.mean<-", signature = "x", 
            function (x, value) standardGeneric ("use.point.itself.as.mean<-"))
setMethod ("use.point.itself.as.mean<-", "ErrorAmtGenerator.NormRand", 
           function (x, value) initialize (x, use.point.itself.as.mean = value))

                #-----  em.mean  -----#
    #  Get    
setGeneric ("em.mean", signature = "x", 
            function (x) standardGeneric ("em.mean"))            
setMethod ("em.mean", "ErrorAmtGenerator.NormRand", 
           function (x) x@em.mean);

    #  Set    
setGeneric ("em.mean<-", signature = "x", 
            function (x, value) standardGeneric ("em.mean<-"))
setMethod ("em.mean<-", "ErrorAmtGenerator.NormRand", 
           function (x, value) initialize (x, em.mean = value))

                #-----  em.sd  -----#
    #  Get    
setGeneric ("em.sd", signature = "x", 
            function (x) standardGeneric ("em.sd"))            
setMethod ("em.sd", "ErrorAmtGenerator.NormRand", 
           function (x) x@em.sd);

    #  Set    
setGeneric ("em.sd<-", signature = "x", 
            function (x, value) standardGeneric ("em.sd<-"))
setMethod ("em.sd<-", "ErrorAmtGenerator.NormRand", 
           function (x, value) initialize (x, em.sd = value))

#------------------------------------------------------------------------------

setMethod ("as.string", "ErrorAmtGenerator.NormRand", 
function (.Object)
    {
    return (paste (.Object@name, ': ', 
                    ' use.point.as.mean ', .Object@use.point.itself.as.mean, 
                    ' mean ', .Object@em.mean, 
                    ' sd ', .Object@em.sd, 
                   sep=''))

    }
)

#------------------------------------------------------------------------------

setMethod ("generate.err.amt", "ErrorAmtGenerator.NormRand", 
function (.Object, base.value, legal.err.interval)
    {
        #-----------------------------------------------------------------
        #  This assumes that all error checking has been done before now 
        #  or will be done afterwards.
        #-----------------------------------------------------------------

##### BTL - 2011.02.16
##### THERE IS A PROBLEM HERE WITH WHAT TO USE AS THE MEAN VALUE.
##### SHOULD YOU ALWAYS USE 0 AND THEN SHIFT IT LATER?
##### THE CODE AT LINES 493 TO 507 IN ERRORMODEL.R DOES THE BACKCALCULATION 
##### OF WHAT THE LEGAL ERROR INTERVAL SHOULD BE BUT SEEMS TO DO IT WITH RESPECT 
##### TO 0 AS THE MEAN.  NOT SURE HOW ALL OF THAT INTERACTS WITH THE DIFFERENT 
##### ERRORFUNC CLASSES.  HERE, I COULD JUST MAKE THIS ALWAYS BE WITH RESPECT TO 
##### A MEAN OF 0 AND THEN SHIFT IT TO THE BASE VALUE IN THE ADDITIVE ERROR FUNC 
##### BUT I'M NOT SURE WHAT THAT WOULD MEAN FOR CONST AND MULT ERROR FUNCS AND 
##### FOR THE MORE GENERIC USE OF ANY TYPE OF ERROR GENERATOR AS DRIVEN BY THE 
##### CODE AT 493-507 IN ERRORMODEL.R [NOTE: THAT'S CURRENTLY CODE STARTING WITH 
##### A CALL TO 
#####     err.func.inverse.err.bounds <- 
#####         new ("Interval", 
#####              lower.bound = min.err,
#####              lower.bound.is.exclusive = lower.bound.is.exclusive (.Object@err.bounds),
#####              upper.bound = max.err,
#####              upper.bound.is.exclusive = upper.bound.is.exclusive (.Object@err.bounds))
##### AND ENDING WITH THE CALL
#####     new.err.bounds <- 
#####         restrict.interval.to.inner.bounds (err.func.inverse.err.bounds, 
##### #                                           .Object@result.bounds)    #  BTL - 2011.02.16 
#####                                            .Object@err.bounds)
##### 
##### IN TESTING THE SIMPLE EXAMPLE FROM ASCELIN WHERE THE BASE VALUE IS 0.7 AND THE SD IS 0.1,
##### THE LEGAL.ERR.INTERVAL IS DERIVED TO BE [-0.7,0.3], BUT THOSE VALUES ARE WITH RESPECT TO 
##### AN ERROR ASSUMED TO HAVE A MEAN OF 0, NOT 0.7.  THAT'S BECAUSE OF THE WAY THAT THE CALL 
##### ABOVE TO BUILD err.func.inverse.err.bounds WORKS.  HERE, THE USE.POINT.ITSELF.AS.MEAN 
##### SETS THE MEAN TO 0.7, BUT THE LEGAL.ERR.INTERVAL THAT ASSUMES A MEAN OF 0 DOESN'T EVEN INCLUDE 
##### 0.7, SO YOU GET A BUNCH OF VALUES THAT ARE ALL JUST UNDER 0.3.  WHAT YOU WANT IN THIS 
##### ROUTINE THE WAY IT WORKS NOW FOR THIS CASE OF ADDITIVE ERRORFUNC AND TRUNCATED NORMAL ERROR 
##### IS TO IGNORE THE USE.POINT.ITSELF.AS.MEAN INSIDE OF HERE AND ALWAYS USE 0 AS THE MEAN.  
##### HOWEVER, I'M NOT SURE WHAT HAPPENS TO ALL THE OTHER ERRORFUNCS USING THIS IF I DO THAT.  
##### NEED CAREFUL THOUGHT HERE...

    
    mean.value <- .Object@em.mean
    if (.Object@use.point.itself.as.mean)  mean.value <- base.value
    
    
##### temporary hack - BTL - 2011.02.16
mean.value <- 0.0

        #--------------------------------------------------------------------
        #  If the legal interval for the error to be returned is bounded 
        #  at one or both ends, then use the truncated normal distribution.
        #  Otherwise, use the full usual normal distribution.  
        #--------------------------------------------------------------------
        
    ret.value <- NA
    if ((lower.bound (legal.err.interval) > -Inf)  || 
        (upper.bound (legal.err.interval) < Inf))
        {
        if(DEBUG) cat ("\nUsing truncated norm...\n")
        ret.value <- rtnorm (1, mean.value, .Object@em.sd, 
                             lower.bound (legal.err.interval), 
                             upper.bound (legal.err.interval))
        } else
        {
        cat ("\nUsing usual norm...\n")
        ret.value <- rnorm (1, mean.value, .Object@em.sd)
        }

#####browser()
    return (ret.value)
    }
)  
         
#==============================================================================

test.err.amt.generator <- function ()
    {
    legal.bounds <- new ("Interval", 
                         lower.bound = 2, 
                         lower.bound.is.exclusive = TRUE,
                         upper.bound = 12, 
                         upper.bound.is.exclusive = FALSE)
                         
    cat ("\nlegal.bounds = ", as.string (legal.bounds), "\n")
##    print (legal.bounds)
    
        #----------
        
    eag.c <- new ("ErrorAmtGenerator.Const")
    const.err.amt (eag.c) <- 3
    
    cat ("\neag.c = ", as.string(eag.c))
##    print (eag.c)
    
    cat ("\ngenerate.err.amt (eag.c, 5, legal.bounds) = ", 
         generate.err.amt (eag.c, 5, legal.bounds), "\n\n")

        #----------
        
    eag.u <- new ("ErrorAmtGenerator.UnifRand")
    
    cat ("\neag.u = ", as.string(eag.u))
##    print (eag.u)
    
    cat ("\ngenerate.err.amt (eag.m, 5, legal.bounds) = ", 
         generate.err.amt (eag.u, 5, legal.bounds), "\n\n")

        #----------

    eag.n <- new ("ErrorAmtGenerator.NormRand", 
                  use.point.itself.as.mean = FALSE, 
                  em.mean = 3, 
                  em.sd = 2)

        #  Get around the need for rtnorm() until I can download msm library...    
#    lower.bound (legal.bounds) <- -Inf
#    upper.bound (legal.bounds) <- Inf
    
    cat ("\nNew legal.bounds = ", as.string(legal.bounds))
##    print (legal.bounds)
        
    cat ("\n\neag.n = ", as.string(eag.n))
##    print (eag.n)
    
    cat ("\ngenerate.err.amt (eag.n, 5, legal.bounds) = ", 
         generate.err.amt (eag.n, 5, legal.bounds), "\n\n")
    }
    
#--------------------
 
###test.err.amt.generator()

#==============================================================================

