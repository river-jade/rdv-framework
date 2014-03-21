                        #-----------------------------#
                        #  example-tzar-emulator-R.R  #
                        #-----------------------------#

source ('emulateRunningUnderTzar.R')

if (emulateRunningUnderTzar)
    {
    current.os = sessionInfo()$R.version$os
    parameters = emulateRunningTzar (current.os, tzarEmulation_scratchFileName)

    cat ("\n\n========  parameters IN emulation = \n")
    print (parameters)
    cat ("\n\n========  END parameters = \n")

    } else
    {
    cat ("\n\nNOT emulating running under tzar...")

    cat ("\n\n========  parameters NOT IN emulation = \n")
    print (parameters)
    cat ("\n\n========  END parameters = \n")

    }


if (emulateRunningUnderTzar)
    {
    cat ("\n\nCleaning up after running emulation...\n\n")
    cleanUpAfterTzarEmulation (parameters)
    }
