#===============================================================================

#                               model.R

#  source ('model.R')

#===============================================================================

#  History:

#  2014 11 23 - BTL - cloned from the g2 version of this same file.

#===============================================================================

cat ("\n\nCurrent directory is: '", getwd(), "'\n\n")

cat ("\n\nJust before sourcing generateSetCoverProblem.R, parameters = \n")
print (parameters)
cat ("\n\n")

    #----------------------------------------------------------------
    #  Need to see whether emulating tzar run or really doing one.
    #
    #  First, need to get emulateRunningUnderTzar flag value that
    #  indicates whether to emulate or not.  Also get name of file
    #  where tzar output directory will be written if emulating,
    #  i.e., tzarEmulation_scratchFileName.
    #----------------------------------------------------------------

#source ('emulateRunningUnderTzar.R')
emulateRunningUnderTzar = FALSE

    #---------------------------------------------------------
    #  If doing a normal tzar run, then start the model now.
    #---------------------------------------------------------

if (! emulateRunningUnderTzar)
    {
    source ("generateSetCoverProblem.R")

    } else
    {
        #-------------------------------------------------------
        #  Emulating rather than doing a normal tzar run.
        #  Capture the tzar output directory name and write it
        #  to a file in the project directory that can be read
        #  after tzar exits.
        #-------------------------------------------------------

    cat (parameters$fullTzarExpOutputDirRootWithSlash,
         "\n",
         file = tzarEmulation_scratchFileName,
         sep='' )
    
    }

#===============================================================================

