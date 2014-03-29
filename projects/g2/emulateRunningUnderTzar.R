#===============================================================================

#                           emulateRunningUnderTzar.R

#  source ('emulateRunningUnderTzar.R')

#===============================================================================

    #  Need to change this every time you swap between emulating tzar and 
    #  doing real tzar runs.

#emulateRunningUnderTzar = TRUE
emulateRunningUnderTzar = FALSE

#-------------------------------------------------------------------------------

    #  Once initially set up for a particular user and project, 
    #  probably won't need to change these.

projectPath = "/Users/Bill/D/rdv-framework/projects/g2/"
tzarJarPath = "/Users/Bill/D/rdv-framework/tzar.jar"      

#-------------------------------------------------------------------------------

    #  Probably never need to change these...

tzarEmulation_scratchFileName = "./tzarEmulation_scratchFile.txt"
tzarParametersSrcFileName = "parameters.R"

tzarEmulation_completedDirExtension = ".completedTzarEmulation"
tzarInProgressExtension = ".inprogress/"
tzarFinishedExtension = ""

#===============================================================================

#  Sometimes, particularly when you're debugging, you'd like to 
#  get parameters and create an output directory in the same way that 
#  tzar would do it if you were running under tzar, but you still want 
#  to be able to use debugging tools such as the browse() command and 
#  you can't do that under tzar.
#
#  In that case, set emulateRunningUnderTzar=TRUE in the 
#  emulateRunningUnderTzar.R file.  
#  If you really do want to run under tzar rather than emulating it, 
#  then set emulateRunningUnderTzar=FALSE there.
#
#  Ideally, I'd like to be able to do this just in the yaml file, but 
#  if we're running in emulation mode, then we don't have access to the 
#  parameters from the yaml file yet because tzar isn't the one who 
#  has sourced g2.R.  model.R also needs to see the value of the 
#  emulateRunningUnderTzar flag so that it knows whether to source g2.R.  
#  It has access to the yaml file values, but putting the flag in there 
#  would mean having to maintain the flag's value in the yaml file and 
#  in either this file.  So, I've split the setting of the flag out into 
#  a separate source file that both model.R and g2.R can call.

#  One problem here is if you forget to reset emulateRunningUnderTzar to FALSE 
#  when you're doing real tzar runs.  That will show up pretty immediately 
#  because tzar will start up and quickly finish and g2 will not be run at all.
#  This isn't great, but I'm willing to pay this price to be able to get 
#  access to debugging functionality in R and RStudio when I need them.

#===============================================================================

#  Steps required to use the emulation code:
#
#  1)  In model.R, replace the line that sources g2.R with the following code 
#      that captures the location of the tzar output directory and saves it to 
#      a file for g2.R to read later:
#
#               source ('emulateRunningUnderTzar.R')
#               if (! emulateRunningUnderTzar)  source ("g2.R")  else 
#                   cat (parameters$fullTzarExpOutputDirRootWithSlash, "\n",
#                        file = tzarEmulation_scratchFileName, sep='' )
#
#  2)  In g2.R, 
#      a)  Load value of emulateRunningUnderTzar control flag and 
#          definition of emulateRunningTzar() before you call it.
#
#               source ('emulateRunningUnderTzar.R')
#
#      b)  After you've figured out what OS you have, see whether emulating and 
#          if so, call the emulation code.  Note that you have to have determined 
#          which OS you're running under so because the system call to invoke 
#          tzar is slightly different on Windows:
#
#               if (emulateRunningUnderTzar)
#                   parameters = 
#                       emulateRunningTzar (current.os, 
#                                           tzarEmulation_scratchFileName)
#
#      c)  At end of everything, insert a call to the cleanup code for the 
#          emulation.  This is not absolutely necessary, but it gets rid of 
#          the temporary file and renames the output directory to show that 
#          it finished without incident.
#
#               if (emulateRunningUnderTzar)  
#                   cleanUpAfterTzarEmulation (parameters)    
#
#  3)  In emulateRunningUnderTzar.R, set the value emulateRunningUnderTzar to 
#      TRUE or FALSE depending on whether you want to emulate tzar or not.
#      All other steps above only have to be done when you first create the 
#      code.  This last step has to be done any time you want to switch 
#      between emulating and not emulating.
#
#               emulateRunningUnderTzar = TRUE
#
#      Note that you can also change the name of some of the strings used 
#      in the program, e.g., the name of the scratch file.  However, 
#      I would imagine you'd almost never have any reason to do this.

#===============================================================================

emulateRunningTzar = function (current.os, tzarEmulation_scratchFileName)
    {
        #-----------------------------------------------------------------------
        #  Basing all of the stuff below on reading the rrunner.R file.
        #
        #  Run tzar with the current project.yaml file and a model.R file
        #  that does nothing other than
        #      - returns a successful completion
        #      - causes tzar to expand wildcards and create the output directory
        #        and write the json file and the parameters.R file,
        #      - then
        #
        #  To emulate the running under tzar, you just need to
        #  -  go to the output directory that tzar created
        #  -  source the parameters.R file from that directory
        #  -  start your normal code that would have run from the tzar
        #     output directory.
        #-----------------------------------------------------------------------

    tzarCmd = paste ("-jar", tzarJarPath, "execlocalruns", projectPath)
        
    if (current.os == 'mingw32')
        {
        tzarsim.exit.code = system (paste0 ('java ', tzarCmd))            
        } else 
        {
        tzarsim.exit.code = system2 ('java', tzarCmd, env="DISPLAY=:1")
        }
    
        #----------------------------------------------------------
        #  Read the inProgress dir name from the dumped file that 
        #  contains nothing but that name.  
        #  Then, strip off the inProgress extension to get 
        #  the finished dir name and rename the finished dir 
        #  back to inProgress.
        #
        #  tzar has wildcard-substituted the inProgress name throughout
        #  the parameters file, but when it completed its run, it renamed
        #  the directory to the finished name.
        #  We now want to reuse the parameters file, so we need to rename
        #  the directory back to the inProgress name.  Otherwise, we'd
        #  have to go through and substitute the finished directory name
        #  for all occurrences of the inProgress name in the parameters list.
        #  It might also be a bit misleading if the directory was left with
        #  the finished name after all is done even if the run may have
        #  crashed while running it outside tzar, so I think it's better
        #  to leave it named with inProgress.
        #-----------------------------------------------------------------------
    
    tzarInProgressDirName = readLines (tzarEmulation_scratchFileName)
    tzarFinishedDirName = gsub (tzarInProgressExtension, 
                                tzarFinishedExtension, 
                                tzarInProgressDirName)        
    file.rename (tzarFinishedDirName, tzarInProgressDirName)
    
        #-----------------------------------------------------------
        #  Finally, load the parameters list that tzar created and 
        #  saved as an R file.
        #----------------------------------------------------------
    
    parametersListSourceFilename = paste0 (tzarInProgressDirName, 
                                           tzarParametersSrcFileName)
    source (parametersListSourceFilename)
    
        #-----------------------------------------------------------
        #  Save directory names to use when cleaning up after emulation 
        #  finishes if it finishes successfully.
        #----------------------------------------------------------
    
    parameters$tzarInProgressDirName = tzarInProgressDirName
    parameters$tzarEmulationCompletedDirName = 
        paste0 (tzarFinishedDirName, tzarEmulation_completedDirExtension)
    parameters$tzarEmulation_scratchFileName = tzarEmulation_scratchFileName
    
#browser()
    
    return (parameters)
    }

#-------------------------------------------------------------------------------

cleanUpAfterTzarEmulation = function (parameters)
    {
    file.rename (parameters$tzarInProgressDirName, 
                 parameters$tzarEmulationCompletedDirName) 
    
    file.remove (parameters$tzarEmulation_scratchFileName)
    }

#===============================================================================

