#===============================================================================

                            #-----------------------------------#
                            #               model.R             #
                            #                 for               #
                            #  example-tzar-emulator-R project  #
                            #-----------------------------------#

#===============================================================================

cat ("\n\nCurrent working directory = '", getwd(), "'\n\n")

if (!exists ("sourceCodeLocationWithSlash"))
    sourceCodeLocationWithSlash = 
#        "/Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/"
        "./"
        
source (paste0 (sourceCodeLocationWithSlash, "emulatingTzarFlag.R"))

tzarEmulation_scratchFileName = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/tzarEmulation_scratchFile.txt"

if (! emulatingTzar)  
    {
cat ("\n\n=====>  In model.R: NOT emulatingTzar")

    source (paste0 (sourceCodeLocationWithSlash, "generateSetCoverProblem.R"))    #  not emulating, running regular tzar
    
    } else    #  emulating
    {
    parameters$tzarEmulation_scratchFileName = tzarEmulation_scratchFileName

    cat (parameters$fullOutputDirWithSlash, "\n",
       file = tzarEmulation_scratchFileName, sep='' )
    }

#===============================================================================

