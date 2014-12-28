#===============================================================================

                            #-----------------------------------#
                            #               model.R             #
                            #                 for               #
                            #  example-tzar-emulator-R project  #
                            #-----------------------------------#

#===============================================================================

source ("/Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/emulatingTzarFlag.R")

tzarEmulation_scratchFileName = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/tzarEmulation_scratchFile.txt"

if (! emulatingTzar)  
    {
cat ("\n\n=====>  In model.R: NOT emulatingTzar")

    source ("generateSetCoverProblem.R")    #  not emulating, running regular tzar
    
    } else    #  emulating
    {
    parameters$tzarEmulation_scratchFileName = tzarEmulation_scratchFileName

    cat (parameters$fullOutputDirWithSlash, "\n",
       file = tzarEmulation_scratchFileName, sep='' )
    }

#===============================================================================

