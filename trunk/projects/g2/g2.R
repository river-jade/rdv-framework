#===============================================================================

#emulateRunningUnderTzar = TRUE

#===============================================================================

#                                 g2.R

# source( 'g2.R' )

#  To run under tzar on mac:
#      Set emulateRunningUnderTzar = FALSE in emulateRunningUnderTzar.R
#      cd /Users/Bill/D/rdv-framework
#      java -jar tzar.jar execlocalruns ./projects/g2/

#  To run under tzar on vmware windows emulator:
#      Set emulateRunningUnderTzar = FALSE in emulateRunningUnderTzar.R
#          #  Have to use "pushd" instead of "cd" to access shared files.
#      pushd \\vmware-host\Shared Folders\Bill\D\rdv-framework
#          #  Have to use tzar file name rather than symbolic link since 
#          #  windows doesn't recognize the link.
#      java -jar tzar-0.5.1.jar execlocalruns projects/g2
#      or
#      java -jar tzar.jar execlocalruns projects/g2    

#-------------------------------------------------------------------------------

#  To EMULATE running under tzar on a mac:  ***
#      Set emulateRunningUnderTzar = TRUE in emulateRunningUnderTzar.R
#      cd /Users/Bill/D/rdv-framework/projects/g2/
#      source ('g2.R')

#===============================================================================

#  Sometimes, particularly when you're debugging, you'd like to 
#  get parameters and create an output directory in the same way that 
#  tzar would do it if you were running under tzar, but you still want 
#  to be able to use debugging tools such as the browse() command and 
#  you can't do that under tzar.

#  In that case, set emulateRunningUnderTzar=TRUE in the 
#  emulateRunningUnderTzar.R file.  
#  If you really do want to run under tzar rather than emulating it, 
#  then set emulateRunningUnderTzar=FALSE there.

#  If you don't want to do either of the above, then you have to somehow 
#  build your parameters list data structure yourself.

#  In that case, if emulation is turned off, there is no problem.
#  If you've left emulation turned on, then there are likely to be errors 
#  in here when the emulation code tries to figure out where to read the 
#  parameters file, etc.

source ('emulateRunningUnderTzar.R')

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

#  Currently requires the following R packages:

#      pixmap    (used in read.R)
#      grDevices    (used in g2Utilities.R)

#  Install necessary R libraries.

library (dismo)
library (randomForest)
library (maptools)        #  for wrld_simpl?
library (kernlab)

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
#  Unfortunately, you do have to pay attention to this because 
#  when file names are written out (e.g., to hand to Zonation), 
#  all the slashes in a file name have to be going in the right 
#  direction.
dir.slash = "/"

if (current.os == "mingw32")  
    dir.slash = "\\"
cat ("\n\ndir.slash = '", dir.slash, "'\n", sep='')

arrayIdxBase = 1    #  1 is index base in R, need 0 if python

#-------------------------------------------------------------------------------

if (emulateRunningUnderTzar)
    parameters = emulateRunningTzar (current.os, tzarEmulation_scratchFileName)

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

#  Windows and mac and linux have different path conventions.
#  While R can deal with most of these, it can't handle things like
#  VMware Windows on the mac having a special way of specifying where a
#  shared file is even though it's on the same mac.
#  So, I have to make a special variable for the lead-in on lots of path
#  names to have this work across OS variations.



#**********
#  BTL - 2014 04 04
#  Is one of these two if statements that start with mingw32 wrong, i.e., 
#  has it been superceded by the other but I forgot to eliminate the other 
#  one or is this right?  Seems like the second one is going to overwrite the 
#  first one.

if (current.os == "mingw32")
    {
    userPath = parameters$userPath.windows.vmware
    
    } else
    {
    if (regexpr ("darwin*", current.os) != -1)
        {
        userPath = parameters$userPath.mac
        
        } else
        {
        userPath = parameters$userPath.linux
        }
    }

#---------------------

if (current.os == "mingw32")
    {
        #  -- Windows --
    #    output_path = output_path.windows.vmware
    userPath = parameters$userPath.windows.vmware      
    rdvRootDir = parameters$rdvRootDir.windows.vmware
    
    } else if (regexpr ("darwin*", current.os) != -1)
    {
        #  -- Mac --
    #    output_path = output_path.mac
    userPath = parameters$userPath.mac     
    rdvRootDir = parameters$rdvRootDir.mac
    
    } else    #  Assume linux...
    {
    #    output_path = output_path.linux
    userPath = parameters$userPath.linux     
    rdvRootDir = parameters$rdvRootDir.linux
    }

#===============================================================================

#rdvRootDir = file.path (userPath, parameters$rdvRootDir)
rdvRootDir = paste0 (userPath, dir.slash, rdvRootDir)

#  No longer used since the addition of the libraries command in the yaml file?
#  Can't find any other references to it in this code anyway.
#  BTL - 2014 04 04
#rdvSharedRsrcDir = paste0 (rdvRootDir, dir.slash, "R")

#  Doesn't work on linux.  
#  Instead, need to assume that we've been dropped in the project R souce 
#  directory.
#  BTL - 2014 04 04
#cat ("\n\nrdvRootDir = ", rdvRootDir, sep='')
#g2ProjectRsrcDir = paste0 (rdvRootDir, dir.slash, "projects/g2")
g2ProjectRsrcDir = "."
#g2ProjectRsrcDirWithSlash = paste0 (g2ProjectRsrcDir, dir.slash)
g2ProjectRsrcDirWithSlash = "./"
#cat ("\nrdvSharedRsrcDir = ", rdvSharedRsrcDir, sep='')
#cat ("\ng2ProjectRsrcDirWithSlash = ", g2ProjectRsrcDirWithSlash, sep='')
cat ("\n\n")

#  I think that this may already be done by tzar, but I'm not sure 
#  exactly where it does cd to at the start.  Need to put that in 
#  the documentation.
#  Just did a quick check.  Looks like it sets the working directory to 
#  projects/g2 in this case, which is the directory given on the command 
#  line for the execlocalruns command.  Not sure what it does when 
#  running from a repository instead of a local directory.
#####setwd (rdvRootDir)    #  Is this still necessary (and correct to do)?
#  It was done in runZonation.R as well, so maybe 
#  this is related to running external code?
#  Probably shouldn't be doing this at all and 
#  should just be running things with full paths 
#  so that this g2 code works no matter where it's 
#  running from.

#===============================================================================

    #-------------------------------------------------------------
    #  Need to set option values first, since many functions are
    #  likely to make use of them.
    #  This will later be taken care of by the yaml file and
    #  tzar's RRunner loading them into the list called
    #  "variables".  Until then, I need to set them by hand.
    #-------------------------------------------------------------

source (file.path (g2ProjectRsrcDir, 'read.R'))    #  Required for init...
source (file.path (g2ProjectRsrcDir, 'initializeG2options.R'))

    #-------------------------------------------------------------
    #  Utility functions for reading and writing that are shared
    #  among projects but want to have available locally in case
    #  I need to modify them.
    #-------------------------------------------------------------

source (file.path (g2ProjectRsrcDir, 'w.R'))
source (file.path (g2ProjectRsrcDir, 'g2Utilities.R'))

    #---------------------
    #  Define functions.
    #---------------------

source (file.path (g2ProjectRsrcDir, 'getEnvFiles.R'))
source (file.path (g2ProjectRsrcDir, 'getTrueSppDistFromExistingClusters.R'))
source (file.path (g2ProjectRsrcDir, 'getNumTruePresForEachSpp.R'))
source (file.path (g2ProjectRsrcDir, 'getTruePresForEachSpp.R'))
source (file.path (g2ProjectRsrcDir, 'getSampledPresForEachSpp.R'))
source (file.path (g2ProjectRsrcDir, 'runMaxentCmd.R'))
source (file.path (g2ProjectRsrcDir, 'evaluateMaxentResults.R'))
source (file.path (g2ProjectRsrcDir, 'setUpAndRunZonation.R'))
source (file.path (g2ProjectRsrcDir, 'evaluateZonationResults.R'))

    #-------------------------------------------------------------------------
    #  Do initializations that are more than just retrieving option settings
    #  that are or should be in the yaml file.
    #  This needs to be done after all of the other sourcing above because
    #  some of these actions may assume the existance of some of the
    #  functions referenced above.
    #-------------------------------------------------------------------------

source (file.path (g2ProjectRsrcDir, 'initializeBeyondSettingOptions.R'))

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

#envFileNames = getEnvFiles (envLayersSrcDir, envLayersWorkingDirWithSlash)  #  Was adding an extra slash before file name.  Leaving here until I'm sure it works correctly.
envFileNames = getEnvFiles (envLayersSrcDir, envLayersWorkingDir)

cat ("\n\nenvironment layers just after getEnvFiles = \n")
print (envFileNames)

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

if (FALSE)
{
    #  Set up for dismo SDM runs.

        #  The original code from the dismo vignette:
        # files <- list.files (path = '/Users/Bill/tzar/outputdata/g2/default_runset/464_default_scenario_dismoTestCopy/InputEnvLayers', 
        #                      pattern='asc', 
        #                      full.names=TRUE )
        #predictors <- stack (files)

        #----------------------------------------------------------------------
        #  envFileNames is just a list of the full paths for all of the input 
        #  environmental layers.
        #----------------------------------------------------------------------
    
    cat ("\n\nenvironment layers = \n")
    print (envFileNames)
    
    predictors <- stack (envFileNames)



#library(maptools)
data (wrld_simpl)
plot (wrld_simpl, xlim=c(-80,70), ylim=c(-60,10), 
      axes=TRUE, col='light yellow')

# restore the box around the map    
box ()

for (curSppID in 1:2)
#for (curSppID in 1:numSpp)
    {
    cat ("\n\n==================================================================\n\n")
    cat ("Starting new species = ", curSppID, "\n\n", sep='')
    
    #  Build file name for current species sample file.
    
    sampleFileRoot = paste ("spp.", curSppID, ".sampledPres", sep='')
    sampledPresFilename = paste0 (fullSppSamplesDirWithSlash, #  "/",
                                  sampleFileRoot, ".csv")
    
#     file = 
#         paste0 ("/Users/Bill/tzar/outputdata/g2/default_runset/495_default_scenario.inprogress/", 
#                 "MaxentSamples/", 
#                 "spp.", 
#                 curSppID, 
#                 ".sampledPres.csv")
#     
#     file <- "/Users/Bill/tzar/outputdata/g2/default_runset/495_default_scenario.inprogress/MaxentSamples/spp.1.sampledPres.csv"

    file = sampledPresFilename
    
#    "/Users/Bill/tzar/outputdata/g2/default_runset/464_default_scenario_dismoTestCopy/MaxentSamples/spp.4.sampledPres.csv"

        #  Load sample presences for current species.
    curSpp <- read.table (file, header=TRUE, sep=',')
    curSpp <- curSpp [,-1]
    
    presvals <- extract (predictors, curSpp)
    backgr <- randomPoints (predictors, 500)
    absvals <- extract (predictors, backgr)
    pb <- c (rep (1, nrow (presvals)), rep(0, nrow (absvals)))
    
    sdmDataFrame <- data.frame (cbind (pb, rbind (presvals, absvals)))
    sdmDataFrame [,'simpletenure2'] = as.factor (sdmDataFrame [,'simpletenure2'])
    
    pred_noFactors <- dropLayer (predictors, 'simpletenure2')
    
    group <- kfold (curSpp, 5)
    pres_train <- curSpp [group != 1, ]
    pres_test <- curSpp [group == 1, ]
    
    numBackgroundPts = 1000
    backg <- randomPoints (pred_noFactors, n=numBackgroundPts)
    colnames (backg) = c ('longitude', 'latitude')
    
    group <- kfold (backg, 5)
    backg_train <- backg [group != 1, ]
    backg_test <- backg [group == 1, ]
    
    r = raster (pred_noFactors, 1)
    
        #  Unnecessary?  In fact, would do nothing at all under tzar?
    if (TRUE)
        {
        plot(!is.na (r), col=c ('white', 'light grey'), legend=FALSE)
        points (backg_train, pch='-', cex=0.5, col='yellow')
        points (backg_test, pch='-', cex=0.5, col='black')
        points (pres_train, pch= '+', col='green')
        points (pres_test, pch='+', col='blue')
        }
    
    
        #-------------------------------------------------------------------------
        #  Set up for regression models    
        #  NOTE:  simpletenure2 uses 0:2 as its factor range, but is that right?
        #  Can it take on more values than that?  ASK MATT
        #-------------------------------------------------------------------------
    
    train <- rbind (pres_train, backg_train)
    pb_train <- c (rep (1, nrow (pres_train)), 
                   rep (0, nrow (backg_train)))
    envtrain <- extract (predictors, train)
    envtrain <- data.frame ( cbind (pa=pb_train, envtrain) )
    envtrain [,'simpletenure2'] = factor (envtrain [,'simpletenure2'], levels=0:2)
    
    testpres <- data.frame (extract (predictors, pres_test) )
    testbackg <- data.frame (extract (predictors, backg_test) )
    testpres [ ,'simpletenure2'] = factor (testpres [ ,'simpletenure2'], levels=0:2)
    testbackg [ ,'simpletenure2'] = factor (testbackg [ ,'simpletenure2'], levels=0:2)
    
        #------------------------------------------------------------------------------
        #  Run maxent via dismo
        #
        #  The data elements that maxent needs to have in place before it runs here are:
        #      - location of maxent jar
        #  - predictors
        #  - pres_train
        #  - names of predictors that are factors (not sure what form this has to take)
        #  - pres_test
        #  - backg_test
        #------------------------------------------------------------------------------
    
    jar <- paste0 (system.file (package="dismo"), "/java/maxent.jar")
        #  BTL mac location of jar file
        #  maxent doesn't come with dismo, so either need to copy 
        #  it to the location that this code expects or point it 
        #  to the correct location.
        #  For the moment, I'm just going to point to the right 
        #  place because that's what's going to have to happen 
        #  eventually when running on different operating systems.
        #  This location will actually be set using the yaml file.
        #  Just tried using this and it failed because 
        #  dismo is still looking in the dismo directory.
        #  If that's the case, not sure why you need to 
        #  set the value for jar out here in the first place.
        #  Here's the error I get:
        ## Error: file missing:
        ## /Users/Bill/D/R_libraries/dismo/java/maxent.jar.
        ## Please download it here: http://www.cs.princeton.edu/~schapire/maxent/
        #  So, will comment this out and just copy the maxent 
        #  jar where they want it to be...
        #jar = "/Users/Bill/D/rdv-framework/lib/maxent/maxent.jar"
    
    if (file.exists (jar)) 
        {
        cat ("\n\nAbout to call dismo's maxent.")
        xm <- maxent (predictors, pres_train, factors='simpletenure2')
        #####    xm <- maxent (predictors, pres_train)
        cat ("\n\nBack from call to dismo's maxent.")
        plot (xm)
        } else 
        {
        cat ('cannot run this example because maxent is not available')
        plot (1)
        }
    
    if (file.exists (jar)) 
        {
        cat ("\n\nAbout to call dismo's response(xm)")
        response (xm)
        cat ("\n\nBack from call to dismo's response(xm)")
    } else 
        {
        cat ('cannot run this example because maxent is not available')
        }
    
    if (file.exists (jar)) 
        {
        cat ("\n\nAbout to call to dismo's evaluate(pres_test, backg_test, xm, predictors)")
        e <- evaluate (pres_test, backg_test, xm, predictors)
        cat ("\n\nBack from call to dismo's evaluate(pres_test, backg_test, xm, predictors)")
        
            #  Here are the things that evaluate() returns:
            ## class          : ModelEvaluation 
            ## n presences    : 3 
            ## n absences     : 200 
            ## AUC            : 0.4617 
            ## cor            : -0.01735 
            ## max TPR+TNR at : 0.3157    
        print (e)
        
        str(e)
        }
    
    
        #  Make maxent predictions.
    if (file.exists (jar)) 
        {
        cat ("\n\nAbout to call to dismo's predict(predictors, xm, progress=))")
        px <- predict (predictors, xm, progress='')    
        cat ("\n\nBack from call to dismo's predict(predictors, xm, progress=))")
        par (mfrow=c (1,2))
        plot (px, main='Maxent, raw values')
        plot (wrld_simpl, add=TRUE, border='dark grey') 
        
        tr <- threshold (e, 'spec_sens')    
        plot (px > tr, main='presence/absence')
        plot (wrld_simpl, add=TRUE, border='dark grey')
        points (pres_train, pch='+') 
        } else 
        {
        plot (1)
        }    
    }

#browser()
cat ("\n\n==================================================================\n\n")
}
if (TRUE)    #  temporarily removing non-dismo maxent code
{
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
              
              #####curFullMaxentEnvLayersDirName,
              envLayersWorkingDir, 
              
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
}  #  end if - temporarily removing non-dismo maxent call

    #  Since I can't get wine working on the mac yet, 
    #  I have to bail out before trying to run zonation if on the mac.
    #  If I can ever get it to run, then this little chunk should be removed.

if (runZonation)
    {
        #-------------------------------------------------------------------
        #  Run zonation on apparent species maps and then on correct maps.
        #-------------------------------------------------------------------
        
    cat ("\n\n+++++\tBefore", "runZonation.R", "\n")
    
            #  These two commands were at the start of runZonation.R.
            #  Not sure if they're necessary or not.
        #library (pixmap)
        #setwd (rdvRootDir)
    
        #  BTL - 2014 03 30 
        #  A quick hack to give zonation the correct number of species for the 
        #  reserve selection.  
        #  The current value for this is set in initializeG2options.R based on a 
        #  value handed in from the yaml file.  However, that's based on old 
        #  code that specified the number of species to be created in the yaml file.
        #  Currently, the number of species is derived from counting the number 
        #  of clusters in the cluster image, so it can be different from any other 
        #  image and it can be different from what the yaml file thinks.  
        #  So, just to get a few quick runs going tonight, I'm going to set 
        #  the value right here to the number of species that the cluster counts 
        #  showed.
    #sppUsedInReserveSelectionVector = 1:numSppInReserveSelection  #  code in initializeG2options.R
    sppUsedInReserveSelectionVector = 1:numSpp
    
        #  APPARENT
    setUpAndRunZonation (zonationAppSppListFilename,
                         fullPathToZonationFilesDir,
                         zonationAppInputMapsDir,
                         sppUsedInReserveSelectionVector,
                         zonationAppOutputFilename,
                         fullPathToZonationParameterFile,
                         fullPathToZonationExe,
                         runZonation,
                         sppFilePrefix,
                         closeZonationWindowOnCompletion, 
                         dir.slash
                        )
    
        #  CORRECT
    setUpAndRunZonation (zonationCorSppListFilename,
                         fullPathToZonationFilesDir,
                         zonationCorInputMapsDir,
                         sppUsedInReserveSelectionVector,
                         zonationCorOutputFilename,
                         fullPathToZonationParameterFile,
                         fullPathToZonationExe,
                         runZonation,
                         "true.prob.dist.spp",
                         closeZonationWindowOnCompletion, 
                         dir.slash
                        )
    
    if (regexpr ("darwin*", current.os) != -1)
        {
        #        if (emulateRunningUnderTzar)  cleanUpAfterTzarEmulation (parameters)    
        
        cat ("\n\n=====>  Can't run or evaluate zonation on Mac yet since ", 
             "wine doesn't work properly yet.", sep='')
            
        } else 
        {                
            #----------------------------------------------------------------
            #  Evaluate the results of Zonation by comparing its output for
            #  apparent species maps with its output for correct species 
            #  maps.
            #  This doesn't give you its "correctness" since we don't know 
            #  the optimal result, but it gives you a measure of regret. 
            #
            #  *** Note that conceivably, the apparent maps could lead to a 
            #  better result than the correct maps lead to.  This suggests 
            #  that I need to better define what is a good result here so 
            #  that it's possible to recognize that.  It would probably 
            #  have to be phrased in terms of the total representation for 
            #  each species at any rank cutoff and the better result would 
            #  be the one that dominated the other one at every level.  
            #  However, full domination wouldn't be required to happen, 
            #  so some other notion of "better than" is necessary.  
            #----------------------------------------------------------------
        
        cat ("\n\n+++++\tBefore", "evaluateZonationResults", "\n")
        
        evaluateZonationResults (#zonation.files.dir.with.slash, 
                                 paste0 (fullPathToZonationFilesDir, dir.slash), 
                                 #analysis.dir.with.slash, 
                                 fullAnalysisDirWithSlash, 
                                 #write.to.file, 
                                 writeToFile
                                 )    
        
        cat ("\n\nAt end of running and evaluation Zonation results.\n\n")
        
        }  #  end else - Not running on mac, so ok to run zonation
    }  #  end if - runZonation

#===============================================================================

cat ("\n\n             -----  ALL DONE WITH G2 RUN NOW  -----\n\n")

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

if (emulateRunningUnderTzar)  cleanUpAfterTzarEmulation (parameters)    

#===============================================================================

