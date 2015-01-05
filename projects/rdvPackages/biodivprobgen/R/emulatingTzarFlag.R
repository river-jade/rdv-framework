#===============================================================================

                #  source ("emulatingTzarFlag.R")

#  Control flag to tell whether your code should be run under the tzar 
#  emulator or under normal tzar.  

#  This file only exists because more than one R file may need to know 
#  the value of this flag simultaneously and having its value sourced 
#  through this file makes sure that they all agree on the value.

#  History

#  BTL - 2014 11 28 - Created.

#  BTL - 2014 12 28 - Changed flag's name to emulatingTzar.

#===============================================================================

    #  Comment out whichever line is no longer appropriate.
emulatingTzar = TRUE
#emulatingTzar = FALSE

#===============================================================================
