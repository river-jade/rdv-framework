#===============================================================================

#                                 g2.R

# source( 'g2.R' )

#  To run under tzar:
#      cd /Users/Bill/D/rdv-framework
#      java -jar tzar.jar execlocalruns ./projects/g2/

#===============================================================================

#  History:

#  2014 01 31 - BTL
#  Created as the beginning of stripping the guppy project down and getting
#  rid of all the python code in it.
#  Largely basing it on runMaxent.R from:
#  GuppyRev256_from2013.05.20_justBeforePython_exportedFromCornerstone_2014.01.20/guppy.
#  Will also mix in things from the latest version of guppy as well, but
#  runMaxent.R from guppy revision 256 (on google code repository) is pretty
#  much the last version of the code after submitting the sewpac first year
#  report and before I started adding python to the project (other than the
#  overarching dummy model.py code that was required for using tzar at the
#  time, but all that did was immediately call runMaxent.R).

#===============================================================================

#  To run this code locally using tzar (by calling the R code from model.py):

#      cd /Users/bill/D/rdv-framework

#      java -jar tzar.jar execlocalruns ./projects/g2/
    
#    The only yaml file variables that seem to be referenced in the code here.
# PAR.current.run.directory = outputFiles$'PAR.current.run.directory'
# PAR.path.to.maxent = variables$'PAR.path.to.maxent'
# PAR.input.directory = inputFiles$'PAR.input.directory'
# PAR.maxent.env.layers.base.name = variables$'PAR.maxent.env.layers.base.name'
# PAR.path.to.maxent.input.data = variables$'PAR.path.to.maxent.input.data'

#===============================================================================

                        #  Conventions

#  get...() functions
#       A common pattern in here is that some piece of data could
#       come from multiple possible sources, e.g., copying from the
#       current hard disk or from a url or being generated from a
#       sampling or simulation process.  At the highest level,
#       I will call those functions get...() rather than load...()
#       or generate...(), etc.  Wherever get...() occurs, my
#       intent is to have it eventually be a generic routine.

#  SrcDir vs. WorkingDir
#       Trying to make names differentiate between the source of information
#       before the experiment is run and the working copy of information that
#       is copied into the tzar output area as part of the experiment.
#       For example, the environmental input layers generally exist in some
#       independent data storage location (possibly not even on the same disk)
#       and are often selected and then copied into a working area that is part
#       the experiment's output area under tzar.  So, envLayersSrcDir
#       may get copied into envLayersWorkingDir.


#===============================================================================

#  Can't do this under tzar because it erases the parameters list passed in 
#  from yaml!!
#rm (list = ls())    #  Make sure there are no old variables lying around.

#===============================================================================

#  options (warn = 2)  =>  warnings are treated as errors, i.e., they're fatal.
#  Here's what the options() help page in R says:
#
#    warn:
#    sets the handling of warning messages. If warn is negative all warnings
#    are ignored. If warn is zero (the default) warnings are stored until
#    the top–level function returns. If fewer than 10 warnings were signalled
#    they will be printed otherwise a message saying how many were signalled.
#    An object called last.warning is created and can be printed through the
#    function warnings. If warn is one, warnings are printed as they occur.
#    If warn is two or larger all warnings are turned into errors.

#options (warn = 2)    #  This will eventually come from yaml file
options (warn = parameters$warningLevel)    #  This will eventually come from yaml file
#options (warn = variables$PAR.RwarningLevel)

#===============================================================================

#  self.randomSeed = self.variables['PAR.random.seed']
#randomSeed                    = 17
randomSeed                    = parameters$randomSeed
set.seed (randomSeed)

#===============================================================================

# First get the OS so you can deal with OS-specific issues.
#   for linux this returns linux-gnu
#   for mac this returns darwin9.8.0
#   for windows this returns mingw32

current.os <- sessionInfo()$R.version$os
cat ("\n\nos = '", current.os, "'\n", sep='')

    #  ISN'T THERE AN R FUNCTION RELATED TO THIS?
    #  In fact, does it even matter in R?
    #  Does R already manage this in strings for file functions?
dir.slash = "/"

#if (current.os == 'mingw32')  dir.slash = "\\"
if (current.os == "mingw32")  dir.slash = "\\"
cat ("\n\ndir.slash = '", dir.slash, "'\n", sep='')

arrayIdxBase = 1    #  1 is index base in R, need 0 if python

#===============================================================================

rdvRootDir = "/Users/Bill/D/rdv-framework"
rdvSharedRsrcDir = paste (rdvRootDir, "/R", sep='')
g2ProjectRsrcDir = paste (rdvRootDir, "/projects/g2", sep='')
g2ProjectRsrcDirWithSlash = paste (g2ProjectRsrcDir, "/", sep='')

cat ("\n\nrdvRootDir = ", rdvRootDir, sep='')
cat ("\nrdvSharedRsrcDir = ", rdvSharedRsrcDir, sep='')
cat ("\ng2ProjectRsrcDirWithSlash = ", g2ProjectRsrcDirWithSlash, sep='')
cat ("\n\n")

#  I think that this may already be done by tzar, but I'm not sure 
#  exactly where it does cd to at the start.  Need to put that in 
#  the documentation.
#  Just did a quick check.  Looks like it sets the working directory to 
#  projects/g2 in this case, which is the directory given on the command 
#  line for the execlocalruns command.  Not sure what it does when 
#  running from a repository instead of a local directory.
setwd (rdvRootDir)    #  Is this still necessary (and correct to do)?

#===============================================================================

    #-------------------------------------------------------------
    #  Need to set option values first, since many functions are
    #  likely to make use of them.
    #  This will later be taken care of by the yaml file and
    #  tzar's RRunner loading them into the list called
    #  "variables".  Until then, I need to set them by hand.
    #-------------------------------------------------------------

source (paste0 (g2ProjectRsrcDirWithSlash, 'read.R'))    #  Required for init...
source (paste0 (g2ProjectRsrcDirWithSlash, 'initializeG2options.R'))

    #-------------------------------------------------------------
    #  Utility functions for reading and writing that are shared
    #  among projects but want to have available locally in case
    #  I need to modify them.
    #-------------------------------------------------------------

source (paste0 (g2ProjectRsrcDirWithSlash, 'w.R'))
source (paste0 (g2ProjectRsrcDirWithSlash, 'g2Utilities.R'))

    #---------------------
    #  Define functions.
    #---------------------

source (paste0 (g2ProjectRsrcDirWithSlash, 'getEnvFiles.R'))
source (paste0 (g2ProjectRsrcDirWithSlash, 'getTrueSppDistFromExistingClusters.R'))
source (paste0 (g2ProjectRsrcDirWithSlash, 'getNumTruePresForEachSpp.R'))
source (paste0 (g2ProjectRsrcDirWithSlash, 'getTruePresForEachSpp.R'))
source (paste0 (g2ProjectRsrcDirWithSlash, 'getSampledPresForEachSpp.R'))
source (paste0 (g2ProjectRsrcDirWithSlash, 'runMaxentCmd.R'))
source (paste0 (g2ProjectRsrcDirWithSlash, 'evaluateMaxentResults.R'))

    #-------------------------------------------------------------------------
    #  Do initializations that are more than just retrieving option settings
    #  that are or should be in the yaml file.
    #  This needs to be done after all of the other sourcing above because
    #  some of these actions may assume the existance of some of the
    #  functions referenced above.
    #-------------------------------------------------------------------------

source (paste0 (g2ProjectRsrcDirWithSlash, 'initializeBeyondSettingOptions.R'))

#===============================================================================
#===============================================================================

#  *******************************  DESIGN NOTE  *******************************
#  Need to make multiple sub-g2's so that I can run various sub-jobs alone so
#  that you were constantly regenerating exactly the same maps or other outputs,
#  e.g.:
#    - generate species distribution maps for the species library
#    - run SDM over species drawn from the species library
#    - run learning algorithm over SDM results to learn to predict
#      performance
#    - run evaluation code over SDM results and store in results library
#  *******************************               *******************************

    #--------------------------------
	#  Get environment layers.
	#--------------------------------

getEnvFiles (envLayersSrcDir, envLayersWorkingDirWithSlash)

#===============================================================================

	#--------------------------------------------
	#  Get true species distributions.
	#
	#  For now, this means getting the true
	#  probability maps.
	#  It could eventually mean something like
	#  running an individual-based model, etc.
	#--------------------------------------------

        #  BTL - 2014 02 05
        #  CHANGED ARGUMENT envLayersSrcDir TO BE envLayersWorkingDirWithSlash
        #  INSTEAD SINCE THAT SEEMS SAFER WHEN SRC DIR FILES HAVE BEEN SELECTED
        #  AS A SUBSET, PLUS IT KEEPS ALL USED DATA IN ONE PLACE FOR LATER
        #  AUDITING IF THERE IS A PROBLEM.

        #  BTL - 2014 02 16
        #  ADDED ARGUMENTS FOR ASCII FILE HEADER (corner, noData, cellSize) 
        #  SINCE I AM NOW DERIVING THE CORRECT VALUES FROM THE ENV LAYERS 
        #  RATHER THAN USING HARD-CODED VALUES.

numSpp = getTrueSppDistFromExistingClusters (envLayersWorkingDirWithSlash, # envLayersSrcDir,
                                             numImgRows, numImgCols,
                                             
                                             ascFileHeaderAsStrVals, 
                                             
                                             sppGenOutputDirWithSlash,
                                             asciiImgFileNameRoots, scaleInputs,
                                             imgFileType, numNonEnvDataCols,
                                             clusterFilePath, clusterFileNameStem,
                                             arrayIdxBase
                                             )

#===============================================================================

    #----------------------------
	#  Get true presences.
    #  Taken from guppy/genTruePresencesPyper.R.
	#----------------------------

        #---------------------------------------------------------------
        #  Determine the number of true presences for each species.
        #  At the moment, you can specify the number of true presences
        #  drawn for each species either by specifying a count for each
        #  species to be created or by specifying the bounds of a
        #  random fraction for each species.  The number of true
        #  presences will then be that fraction multiplied times the
        #  total number of pixels in the map.
        #---------------------------------------------------------------

#  *******************************  DESIGN NOTE  *******************************
#  Need to replace these kinds of boolean switches with a single
#  variable indicating the action that can be used in a switch statement.
#  Otherwise, the yaml file gets cluttered with lots of possibly
#  conflicting and out of date booleans.
#  This idea needs to be listed in the design criteria too.
#  *******************************               *******************************

#  *******************************  DESIGN NOTE  *******************************
#  QUESTION FOR RIVER:
#  Is there a way to have options in the yaml file that don't require massive
#  switch statements in the code yet are not vulnerable to injection attacks?
#
#  Nearly everything that I want to do involves subclassing generic functions
#  to allow reusability of many variations of a small number of basic actions.
#  If I'm coding things up directly (i.e., without using yaml inputs to
#  select options), then it's easy to reuse these objects/generics.
#  However, as soon as I add yaml to the mix, I'm not sure it's possible.
#  Then again, there are other issues with that too, because each variant of
#  the generic function will probably have a different set of arguments that
#  would be hard to encode in yaml too.
#  Maybe I have to be restricting myself to having a set of basic sub-g2
#  programs and having specific yaml files that correspond to each of those
#  sub-g2 files and know exactly which options need to be set.
#  This might require or work well with some kind of a convention where every
#  sub-g2 was expected to have a corresponding yaml template with default
#  values for each option.
#  The user would then just fill in any values on that template where they
#  didn't want the defaults.
#  Could this yaml file also be used as the input for a generic program that
#  dynamically built a gui for each sub-g2 and then wrote the user's entries
#  on the gui back to a yaml file for that run?
#  *******************************               *******************************

#  *******************************  DESIGN NOTE  *******************************
#  QUESTION FOR RIVER and/or LUCY:
#  How to build a species distribution map library that had attributes that
#  could evolve over time (or even just be different for each run or project)
#  and be efficient for lookup, transmission, and storage both locally and
#  over the web?
#  *******************************               *******************************

if (useRandomNumTruePresForEachSpp)
    {
    numTruePresForEachSpp =
        getNumTruePresForEachSpp_usingRandom (numSpp,
                                              minTruePresFracOfLandscape,
                                              maxTruePresFracOfLandscape,
                                              numImgCells)

    } else
    {
    numTruePresForEachSpp =
        getNumTruePresForEachSpp_usingSpecifiedCts (numTruePresForEachSpp_string,
                                                    numSpp)
    }

    #---------------------------------------------
    #  Get the true presences for each species.
    #  Taken from guppy/genTruePresencesPyper.R.
    #---------------------------------------------

allSppTruePresLocsXY = getTruePresForEachSpp (numTruePresForEachSpp,
                                              trueProbDistFilePrefix,
                                              fullSppSamplesDirWithSlash,
                                              combinedTruePresFilename,
                                              numImgRows,
                                              numImgCols,
                                              llcorner,
                                              cellsize,
                                              nodataValue
                                              )

    #-----------------------------------------------
    #  Get the sampled presences for each species.
    #  Taken from guppy/genTruePresencesPyper.R.
    #-----------------------------------------------

getSampledPresForEachSpp (numTruePresForEachSpp,
                          allSppTruePresLocsXY,
                          PARuseAllSamples,
                          fullSppSamplesDirWithSlash,    #  cur.full.maxent.samples.dir.name,
                          combinedSampledPresFilename
                          )

#===============================================================================

    #----------------------------------------------------------------
    #  Run maxent to generate a predicted relative probability map.
    #----------------------------------------------------------------

cat ("\n\n+++++\tJust before", "runMaxentCmd", "\n\n")

runMaxentCmd (maxentSamplesFileName,
              fullMaxentOutputDirWithSlash,    #  maxentOutputDir,
              doMaxentReplicates,
              maxentReplicateType,
              numMaxentReplicates,
              maxentFullPathName,
              curFullMaxentEnvLayersDirName,
              numProcessors,
              verboseMaxent
              )

cat ("\n\n+++++\tJust after", "runMaxentCmd", "\n\n")

    #----------------------------------------------------------------
    #  Evaluate the results of maxent by comparing its output maps
    #  to the true relative probability maps.
    #----------------------------------------------------------------

cat ("\n\n+++++\tBefore", "evaluateMaxentResults", "\n")

evaluateMaxentResults (numSpp,
                       doMaxentReplicates,
                       trueProbDistFilePrefix,
                       showRawErrorInDist,
                       showAbsErrorInDist,
                       showPercentErrorInDist,
                       showAbsPercentErrorInDist,
                       showTruncatedPercentErrImg,
                       showHeatmap,
                       fullMaxentOutputDirWithSlash,
                       sppGenOutputDirWithSlash,
                       fullAnalysisDirWithSlash,
                       useOldMaxentOutputForInput,
                       writeToFile,
                       useDrawImage)

#===============================================================================

    #----------------------------------------------------------------
    #  Set up input files and paths to run zonation, then run it.
    #----------------------------------------------------------------
    
cat ("\n\n+++++\tBefore", "runZonation.R", "\n")

        #  At the moment, I can't get wine to run properly anywhere,
        #  so I can only run zonation if we're on a Windows system.
if (current.os == "mingw32")
	{
    cat ("\n\nOn Windows system, so go ahead with running Zonation.\n\n")
    #############source (paste (guppyProjectRsrcDirWithSlash, 'runZonation.R', sep=''))
    
	} else
	{
	cat ("\n\n=====>  Can't run zonation on non-Windows system yet ",
         "\n=====>  since wine doesn't work properly yet.\n\n",
         sep='')
	}

cat ("\n\nAt end of runMaxent.R.  \n\n             -----  ALL DONE WITH G2 RUN NOW  -----\n\n")

#===============================================================================

    #-----------------------------------------------------------------
	#  Set up input files and paths to run actions based on results.
	#-----------------------------------------------------------------


    #----------------------------------------------------------------
    #  Act on Zonation results
    #
    #  (e.g., offset or randomly subset (or add to) the zonation
    #  choices to imitate drawing an inclusion or exclusion around
    #  the premier's brother's property regardless of its zonation
    #  rank - this is essentially a CorruptionError model that might
    #  have a lot of significance in 3rd world countries and be
    #  denied in 1st world but still exist).
    #----------------------------------------------------------------


    #----------------------------------------------------------------
    #  Evaluate final action result.
    #
    #  Assign credit to each element of the chain in terms of
    #  their contribution to Ultimate Measurement Error.
    #----------------------------------------------------------------

#===============================================================================
#===============================================================================

    #----------------------------------------------------------------
    #
    #  Job spawning
    #
    #  Things like on-line active learning could examine results and
    #  generate new job requests when trying to learn to predict
    #  something.
    #
    #  Ensemble algorithms might also spawn jobs to build their
    #  ensemble predictor.
    #
    #  Are there any other kinds of activities that might do spawning?
    #
    #----------------------------------------------------------------

    #----------------------------------------------------------------
    #
    #  Halting (monitors)
    #
    #  Another function that might be necessary would be something
    #  that tells when to stop spawning things or stop looking for
    #  things.  Not sure if this would be part of the spawning code
    #  or something separate.  Maybe both could exist.  For example,
    #  a non-spawning job could be running solely to monitor and make
    #  sure that some $ or time or disk quota is not exceeded or that
    #  some point of diminishing returns has not been passed or
    #  it could be looking for convergence or the point in training
    #  curve that tells you to stop training.
    #
    #----------------------------------------------------------------

    #----------------------------------------------------------------
    #
    #  Anytime algorithms (similar to or superclass of halting monitors?)
    #
    #  - Online learning
    #
    #  - Online harvesting and incremental aggregation of results
    #
    #----------------------------------------------------------------


#===============================================================================

