#===============================================================================

                        #  gscp_2_tzar_emulation.R

#===============================================================================
                    #  START EMULATION CODE
#===============================================================================

    #  Need to set emulation flag every time you swap between emulating 
    #  and not emulating.  
    #  This is the only variable you should need to set for that.
    #  Make the change in the file called emulatingTzarFlag.R so that 
    #  every file that needs to know the value of this flag is using 
    #  the synchronized to the same value.

        #  2014 12 29 - BTL 
        #  Moving this to the top level code (i.e., generateSetCoverProblem.R) 
        #  so that it's easier to see and control.  I was forgetting where 
        #  it was done before...
#source ("/Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/emulatingTzarFlag.R")

#--------------------

    #  Need to set these variables just once, i.e., at start of a new project. 
    #  Would never need to change after that for that project unless 
    #  something strange like the path to the project or to tzar itself has 
    #  changed.  
    #  Note that the scratch file can go anywhere you want and it will be 
    #  erased after the run if it is successful and you have inserted the 
    #  call to the cleanup code at the end of your project's code.  
    #  However, if your code crashes during the emulation, you may have to 
    #  delete the file yourself.  I don't think it hurts anything if it's 
    #  left lying around though.

projectPath = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R"
tzarJarPath = "~/D/rdv-framework/tzar.jar"
tzarEmulation_scratchFileName = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/tzarEmulation_scratchFile.txt"

#-------------------------------------------------------------------------------

    #  This is the only code you need to run the emulator.
    #  However, if you want it to clean up the tzar directory name extensions 
    #  after it is finished, you also need to run the routine called 
    #  cleanUpAfterTzarEmulation() after your project code has finished 
    #  running, e.g., as the last act in this file. 

source ('/Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/emulateRunningUnderTzar.R')

if (emulatingTzar)
    {
    cat ("\n\nIn generateSetCoverProblem:  emulating running under tzar...")

    parameters = emulateRunningTzar (projectPath, 
                                     tzarJarPath, 
                                     tzarEmulation_scratchFileName)
    }

#===============================================================================
                    #  END EMULATION CODE
#===============================================================================

