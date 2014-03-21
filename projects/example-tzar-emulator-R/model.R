                            #-----------------------------------#
                            #               model.R             #
                            #                 for               #
                            #  example-tzar-emulator-R project  #
                            #-----------------------------------#

source ('emulateRunningUnderTzar.R')

if (! emulateRunningUnderTzar)  
    {
    cat ("\n\nNot emulating running under tzar.\n\n")
    
    source ("example-tzar-emulator-R.R")  
    
    } else
    {
    cat ("\n\nEmulating running under tzar.\n\n")
    
    cat (parameters$fullOutputDirWithSlash, "\n",
       file = tzarEmulation_scratchFileName, sep='' )
    }
    