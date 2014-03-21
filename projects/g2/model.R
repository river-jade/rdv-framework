
cat ("\n\nCurrent directory is: '", getwd(), "'\n\n")

cat ("\n\nJust before sourcing g2.R, parameters = \n")
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

source ('emulateRunningUnderTzar.R')

    #---------------------------------------------------------
    #  If doing a normal tzar run, then start the model now.
    #---------------------------------------------------------

if (! emulateRunningUnderTzar)
    {
    source ("g2.R")

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
