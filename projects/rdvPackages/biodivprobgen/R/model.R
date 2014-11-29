#===============================================================================

                            #-----------------------------------#
                            #               model.R             #
                            #                 for               #
                            #  example-tzar-emulator-R project  #
                            #-----------------------------------#

#===============================================================================

source ("emulatingTzarFlag.R")

tzarEmulation_scratchFileName = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/tzarEmulation_scratchFile.txt"

if (! emulateRunningUnderTzar)  
    {
    source ("generateSetCoverProblem.R")    #  not emulating, running regular tzar
    
    } else    #  emulating
    {
    parameters$tzarEmulation_scratchFileName = tzarEmulation_scratchFileName
    
    cat (parameters$fullOutputDirWithSlash, "\n",
       file = tzarEmulation_scratchFileName, sep='' )
    }

#===============================================================================

