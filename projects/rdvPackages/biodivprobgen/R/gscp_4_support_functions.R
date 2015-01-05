#===============================================================================

                        #  gscp_4_support_functions.R

#===============================================================================

library (plyr)    #  For count()
library (marxan)

#-------------------------------------------------------------------------------

#seed = 19
seed = parameters$seed
set.seed (seed)

#-------------------------------------------------------------------------------

default_integerize_string = "round"
integerize_string = default_integerize_string

integerize_string = parameters$integerize_string

#integerize_string = "round"
#integerize_string = "ceiling"
#integerize_string = "floor"

integerize = switch (integerize_string, 
                     round=round, 
                     ceiling=ceiling, 
                     floor=floor, 
                     round)    #  default to round()

# integerize = function (x) 
#     { 
#     round (x) 
# #    ceiling (x)
# #    floor (x)
#     }

#-------------------------------------------------------------------------------

    #  Run marxan.
        #  Should include this in the marxan package.

    #*******
    #  NOTE:  Random seed is set to -1 in the cplan input.dat.
    #           I think that means to use a different seed each time.
    #           I probably need to change this to any positive number, 
    #           at least in the default input.dat that I'm using now 
    #           so that I get reproducible results.
    #*******

run_marxan = function ()
    {
    marxan_dir = "/Users/bill/D/Marxan/"
    
    original_dir = getwd()
    cat ("\n\noriginal_dir =", original_dir)
    
    cat ("\n\nImmediately before calling marxan, marxan_dir = ", marxan_dir)
    setwd (marxan_dir)
    
    cat("\n =====> The current wd is", getwd() )
    
        #  The -s deals with the problem of Marxan waiting for you to hit 
        #  return at the end of the run when you're running in the background.  
        #  Without it, the system() command never comes back.
        #       (From p. 24 of marxan.net tutorial:
        #        http://marxan.net/tutorial/Marxan_net_user_guide_rev2.1.pdf
        #        I'm not sure if it's even in the normal user's manual or 
        #        best practices manual for marxan.)
    
    system.command.run.marxan = "./MarOpt_v243_Mac64 -s"    
    cat( "\n\n>>>>>  The system command to run marxan will be:\n'", 
         system.command.run.marxan, "'\n>>>>>\n\n", sep='')
    
    retval = system (system.command.run.marxan)    #  , wait=FALSE)
    cat ("\n\nmarxan retval = '", retval, "'.\n\n", sep='')        
    
    setwd (original_dir)
    cat ("\n\nAfter setwd (original_dir), sitting in:", getwd(), "\n\n")
    
    return (retval)
    }

#===============================================================================

