#===============================================================================

#                           emulateRunningUnderTzar.R

#  source ('emulateRunningUnderTzar.R')

#===============================================================================

    #  Probably never need to change these...

tzarParametersSrcFileName           = "parameters.R"
tzarEmulation_completedDirExtension = ".completedTzarEmulation"
tzarInProgressExtension             = ".inprogress/"
tzarFinishedExtension               = ""

#===============================================================================

emulateRunningTzar = function (projectPath, 
                               tzarJarPath, 
                               #current.os, 
                               tzarEmulation_scratchFileName)
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
    current.os = sessionInfo()$R.version$os

    if (current.os == 'mingw32')
        {
        tzarsim.exit.code = system (paste0 ('java ', tzarCmd))
        } else
        {
        tzarsim.exit.code = system2 ('java', tzarCmd, env="DISPLAY=:1")
        }

        #----------------------------------------------------------
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
        #
        #  - Read the inProgress dir name from the dumped file that
        #       contains nothing but that name.
        #       That file was written out at the end of the model.R 
        #       code that does nothing but that when emulation is to be 
        #       done.
        #
        #  - Next, strip off the inProgress extension to get
        #       the finished dir name and rename the finished dir
        #       back to inProgress.
        #
        #-----------------------------------------------------------------------

            #  Read dir name from something like: 
            #      tzarEmulation_scratchFile.txt
            #  Resulting dir name is something like:
            #      "/Users/bill/tzar/outputdata/biodivprobgen/default_runset/827_default_scenario.inprogress/"
    tzarInProgressDirName = readLines (tzarEmulation_scratchFileName)
    
            #  Build the name of the directory that would result if tzar 
            #  successfully ran to completion without emulation, e.g., 
            #      /Users/bill/tzar/outputdata/biodivprobgen/default_runset/828_default_scenario
    
    tzarFinishedDirName = 
        gsub (tzarInProgressExtension,  #  e.g., ".inprogress/"
              tzarFinishedExtension,    #  e.g., ""
              tzarInProgressDirName)    #  The name loaded in previous command

            #  That is the name that will have been hung on the results of 
            #  using the dummy model.R code to get tzar to build the 
            #  directory structures and parameters list.  
            #  However, the parameters list will have used the .inprogress 
            #  extension instead of the finished directory name.  
            #  So, to be able to use the parameters.R file as it was built  
            #  during the dummy model.R run, we need to change the finished 
            #  directory's name back to the .inprogress extension.
    
    file.rename (tzarFinishedDirName, tzarInProgressDirName)

        #-----------------------------------------------------------
        #  Finally, load the parameters list that tzar created and
        #  saved as an R file.
        #----------------------------------------------------------

    parametersListSourceFilename = paste0 (tzarInProgressDirName,
                                           "metadata/", 
                                           tzarParametersSrcFileName)
    source (parametersListSourceFilename)

        #-----------------------------------------------------------
        #  Save directory names into the parameters list so that 
        #  they can be used when cleaning up after emulation
        #  finishes, if it finishes successfully.
        #----------------------------------------------------------

    parameters$tzarInProgressDirName = tzarInProgressDirName
    
    parameters$tzarEmulationCompletedDirName =
        paste0 (tzarFinishedDirName, tzarEmulation_completedDirExtension)
    
    parameters$tzarEmulation_scratchFileName = tzarEmulation_scratchFileName

    return (parameters)
    }

#-------------------------------------------------------------------------------

cleanUpAfterTzarEmulation = function (parameters)
    {
        #  Need to rename the output directory to something to do 
        #  with emulation so that if you go back to a pile of directories 
        #  and find runs with strange output, you know that it's because 
        #  you were playing around with the code in the emulator.  
        #  Otherwise, you might have partial results in a run that 
        #  appeared to have run to completion because tzar DID run to 
        #  completion on the dummy model.R code that enabled the 
        #  emulation to build the tzar directories and parameters.
        #  
        #  Can't do this earlier because you don't know how many 
        #  things inside the parameters list have the inprogress name 
        #  built into them by tzar.  If you changed the inprogress 
        #  directory name before running the user code, then the run 
        #  would be looking for the wrong directory.  
        #
        #  However, if tzar itself knew that this was going to be an 
        #  emulation name, it could just use the emulation name wherever 
        #  it now uses the in progress name and it could skip the renaming 
        #  after the run is complete.  If those two things were happening, 
        #  then this cleanup code would be unnecessary.
    
    file.rename (parameters$tzarInProgressDirName,
                 parameters$tzarEmulationCompletedDirName)

    file.remove (parameters$tzarEmulation_scratchFileName)
    }

#===============================================================================

