#==============================================================================

                         #  source ("Interval.R")

#==============================================================================

#  History:

#  - Created 2011.01.19 - BTL
#    Parts extracted from in.interval.R.

#==============================================================================

    #--------------------------------------------------------------
    #  Interval:  
    #--------------------------------------------------------------
    
setClass ("Interval", 
          representation (lower.bound = "numeric",
                          lower.bound.is.exclusive = "logical",
                          
                          upper.bound = "numeric",
                          upper.bound.is.exclusive = "logical"

						  ),

	 	   prototype (    lower.bound = NaN,
                          lower.bound.is.exclusive = NA, 
                          
                          upper.bound = NaN,
                          upper.bound.is.exclusive = NA
                      )
              );

#==============================================================================

    #  Create generic and specific get and set routines for 
    #  all instance variables.

#==============================================================================

                #-----  lower.bound  -----#
    #  Get    
setGeneric ("lower.bound", signature = "x", 
            function (x) standardGeneric ("lower.bound"))            
setMethod ("lower.bound", "Interval", 
           function (x) x@lower.bound);

    #  Set    
setGeneric ("lower.bound<-", signature = "x", 
            function (x, value) standardGeneric ("lower.bound<-"))
setMethod ("lower.bound<-", "Interval", 
           function (x, value) initialize (x, lower.bound = value))

                #-----  lower.bound.is.exclusive  -----#
    #  Get    
setGeneric ("lower.bound.is.exclusive", signature = "x", 
            function (x) standardGeneric ("lower.bound.is.exclusive"))            
setMethod ("lower.bound.is.exclusive", "Interval", 
           function (x) x@lower.bound.is.exclusive);

    #  Set    
setGeneric ("lower.bound.is.exclusive<-", signature = "x", 
            function (x, value) standardGeneric ("lower.bound.is.exclusive<-"))
setMethod ("lower.bound.is.exclusive<-", "Interval", 
           function (x, value) initialize (x, lower.bound.is.exclusive = value))

                #-----  upper.bound  -----#
    #  Get    
setGeneric ("upper.bound", signature = "x", 
            function (x) standardGeneric ("upper.bound"))            
setMethod ("upper.bound", "Interval", 
           function (x) x@upper.bound);

    #  Set    
setGeneric ("upper.bound<-", signature = "x", 
            function (x, value) standardGeneric ("upper.bound<-"))
setMethod ("upper.bound<-", "Interval", 
           function (x, value) initialize (x, upper.bound = value))

                #-----  upper.bound.is.exclusive  -----#
    #  Get    
setGeneric ("upper.bound.is.exclusive", signature = "x", 
            function (x) standardGeneric ("upper.bound.is.exclusive"))            
setMethod ("upper.bound.is.exclusive", "Interval", 
           function (x) x@upper.bound.is.exclusive);

    #  Set    
setGeneric ("upper.bound.is.exclusive<-", signature = "x", 
            function (x, value) standardGeneric ("upper.bound.is.exclusive<-"))
setMethod ("upper.bound.is.exclusive<-", "Interval", 
           function (x, value) initialize (x, upper.bound.is.exclusive = value))

#==============================================================================

                #-----  as.string  -----#

#setGeneric ("as.string", signature = ".Object", 
#			function (.Object) standardGeneric ("as.string"))
			
#--------------------
 
setMethod ("as.string", "Interval", 
function (.Object)
    {
    lower.bracket <- '['
    if (.Object@lower.bound.is.exclusive)  lower.bracket <- '('

    upper.bracket <- ']'
    if (.Object@upper.bound.is.exclusive)  upper.bracket <- ')'
        
    return (paste (lower.bracket, 
                   .Object@lower.bound, 
                   ',', 
                   .Object@upper.bound,
                   upper.bracket, 
                   sep=''))
    }
)

#==============================================================================

                #-----  restrict.interval.to.inner.bounds  -----#

setGeneric ("restrict.interval.to.inner.bounds", signature = ".Object", 
			function (.Object, interval2) standardGeneric ("restrict.interval.to.inner.bounds"))
			
#--------------------
 
setMethod ("restrict.interval.to.inner.bounds", "Interval", 
function (.Object, interval2)
    {
    new.interval <- new ("Interval")
    
        #------------------
        #  Lower bound...
        #------------------


##### THIS IS NOT RIGHT FOR ASCELIN'S EXAMPLE WHERE IT'S A TRUNCATED NORMAL WITH AN SD OF 0.1 
##### CENTERED ON THE VALUE OF 0.7 AS THE MEAN AND RESULT BOUNDS OF [0,1] BUT NO ERROR BOUNDS.
##### WHAT'S HAPPENING IS THAT THIS IS TAKING THE RESULT BOUND OF 0 AND APPLYING IT TO THE 
##### ERROR BOUND WHOSE RESTRICTED RANGE WAS [-0.7, 0.3] AND COMING UP WITH A NEW RESTRICTED 
##### RANGE OF [0,0.3] INSTEAD OF LEAVING IT AT [-0.7 FOR THE LOWER BOUND.  
##### THE PROBLEM IS THAT THE THING THAT ALREADY RESTRICTED THE INVERSE INTERVAL TO BE AT 
##### -0.7 WAS ALREADY FIGURING IN THE BOUND THAT WOULD KEEP THE RESULT >= 0.  
##### SO, IS THE CALL TO THIS RESTRICT...() FUNCTION ACTUALLY REDUNDANT BECAUSE THE EARLIER 
##### RESTRICTION HAS ALREADY FIXED THIS?  AND WOULD THAT HOLD UP FOR OTHER TYPES OF ERROR 
##### OR IS THIS STRICTLY AN ARTIFACT OF THE NORMAL DISTRIBUTION'S CASE?
##### 
##### (note: the troublesome call to this restrict...() function is made at line 507 of ErrorModel.R)



    tighter.lower.bound.interval <- .Object    #  arbitrary initial value
#####    browser()
    if (lower.bound (.Object) == lower.bound (interval2))
        {
            #---------------------------------------------------
            #  If both lower bounds are the same, use the more 
            #  restrictive exclusivity of the two.
            #---------------------------------------------------

        if ( ! lower.bound.is.exclusive (.Object))
            tighter.lower.bound.interval <- interval2
            
        } else
        {
            #----------------------------------------------------
            #  The lower bounds are not the same, use the  
            #  tighter of the two and use the exclusivity level 
            #  that it has.  
            #----------------------------------------------------

        if (lower.bound (.Object) < lower.bound (interval2))
            tighter.lower.bound.interval <- interval2
            
        }
        
    lower.bound (new.interval) <- lower.bound (tighter.lower.bound.interval)
    lower.bound.is.exclusive (new.interval) <- 
                     lower.bound.is.exclusive (tighter.lower.bound.interval)

        #----------------------------------------
        
        #------------------
        #  upper bound...
        #------------------

    tighter.upper.bound.interval <- .Object    #  arbitrary initial value
        
    if (upper.bound (.Object) == upper.bound (interval2))
        {
            #---------------------------------------------------
            #  If both upper bounds are the same, use the more 
            #  restrictive exclusivity of the two.
            #---------------------------------------------------

        if ( ! upper.bound.is.exclusive (.Object))
            tighter.upper.bound.interval <- interval2
            
        } else
        {
            #----------------------------------------------------
            #  The upper bounds are not the same, use the  
            #  tighter of the two and use the exclusivity level 
            #  that it has.  
            #----------------------------------------------------

        if (upper.bound (.Object) > upper.bound (interval2))
            tighter.upper.bound.interval <- interval2
            
        }
        
    upper.bound (new.interval) <- upper.bound (tighter.upper.bound.interval)
    upper.bound.is.exclusive (new.interval) <- 
                     upper.bound.is.exclusive (tighter.upper.bound.interval)
                                          
        #----------------------------------------

####PROBABLY NEED TO REPLACE THIS WITH EXCEPTION CODE THAT USES 
####TRYCATCH() SOMEHOW...  NOT SURE HOW TO DO THAT AT THE MOMENT.
####The catching of this needs to be done way outside of it, i.e., 
####out where the err.amt is being generated.  That way I can 
####turn on/off whether the error should be fatal, but still always 
####be sure that the bad err.amt is never used, even if the error 
####is not fatal.

    if (lower.bound (new.interval) > upper.bound (new.interval))
        {
        stop (paste ("No restricted inner bounds possible (e.g., intervals don't overlap): ",
              as.string (.Object), ", ", as.string (interval2)))
        }

        
    return (new.interval)
    }
)

#==============================================================================

                #-----  in.interval  -----#

setGeneric ("in.interval", signature = ".Object", 
			function (.Object, value) standardGeneric ("in.interval"))
			
#--------------------
 
setMethod ("in.interval", "Interval", 
function (.Object, value)
    {
    value.is.inside <- TRUE

        #-----------------------------------------------------
        #  First see if the value is inside the lower bound.    
        #-----------------------------------------------------

    if (.Object@lower.bound.is.exclusive)
        {
        if (value <= .Object@lower.bound)  value.is.inside <- FALSE
       
        } else
        {
        if (value < .Object@lower.bound)  value.is.inside <- FALSE
        }

    if (value.is.inside)
        {
            #------------------------------------
            #  Value is inside the lower bound.
            #  Try the upper bound now.
            #------------------------------------
            
        if (.Object@upper.bound.is.exclusive)
            {
            if (value >= .Object@upper.bound)  value.is.inside <- FALSE
       
            } else
            {
            if (value > .Object@upper.bound)  value.is.inside <- FALSE
            }
        }

    return (value.is.inside)
    }
 )
 
#==============================================================================

test.interval <- function ()
    {
    interval1 <- new ("Interval", 
                      lower.bound = 3, 
                      lower.bound.is.exclusive = TRUE, 
                      upper.bound = 9, 
                      upper.bound.is.exclusive = TRUE 
                     )
    cat ("\ninterval1 = ", as.string (interval1))

    interval2 <- new ("Interval", 
              lower.bound = 5, 
              lower.bound.is.exclusive = FALSE, 
              upper.bound = 10, 
              upper.bound.is.exclusive = FALSE 
              )
    cat ("\ninterval2 = ", as.string (interval2))
    
    restricted.interval <- restrict.interval.to.inner.bounds (interval1, interval2)
    cat ("\nrestricted.interval = ", as.string (restricted.interval))

    cat ("\nin.interval (interval1, 3) = ", in.interval (interval1, 3))
    cat ("\nin.interval (interval2, 4) = ", in.interval (interval2, 4))
    cat ("\nin.interval (interval1, 13) = ", in.interval (interval1, 13))
    cat ("\nin.interval (interval2, 3) = ", in.interval (interval2, 3))

    cat ("\n")
    for (i in 1:10)
        {
        cat ("\nin.interval (restricted.interval, ", i, ") = ", 
             in.interval (restricted.interval, i))
        }
    cat ("\n")
    }
    
#--------------------
 
#test.interval()

#==============================================================================

