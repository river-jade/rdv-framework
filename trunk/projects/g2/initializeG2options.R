#===============================================================================

#  source ("initializeG2options.R")

#===============================================================================

#  History

#  2014 02 01 - BTL - Created.

#===============================================================================

#  Most (if not all) of these will come from the yaml file eventually...

#===============================================================================

tzarOutputdataRootWithSlash = "/Users/Bill/tzar/outputdata/g2/default_runset/"
dir.slash = "/"
curExpOutputDirName = "401_Scen_1"


createFullTzarExpOutputDirRoot = function (curExpOutputDirName, 
                                           tzarOutputdataRootWithSlash, 
                                           dir.slash = "/")
    {
    curFullTzarExpOutputDirRootWithSlash = 
        paste0 (tzarOutputdataRootWithSlash, 
                curExpOutputDirName, dir.slash)
    
    cat ("\n\ncurFullTzarExpOutputDirRootWithSlash = ", 
         curFullTzarExpOutputDirRootWithSlash, "\n\n", sep='')
    
    if (file.exists (curFullTzarExpOutputDirRootWithSlash))
        {
        errMsg = paste0 ("\n\n*** curFullTzarExpOutputDirRootWithSlash = \n***     ", 
                         curFullTzarExpOutputDirRootWithSlash, 
                         "\n*** already exists.  ", 
                         "\n*** Need to change curExpOutputDirName in ", 
                         "initializeG2options.R\n\n")
        stop (errMsg)
        
        } else
        {
        cat ("\n\ncurFullTzarExpOutputDirRootWithSlash DOES NOT exist.  ", 
             "Creating it.\n\n", sep='')  
        dir.create (curFullTzarExpOutputDirRootWithSlash, 
                    showWarnings = TRUE, 
                    recursive = TRUE, #  Not sure about this, but it's convenient.
                    mode = "0777")    #  Not sure if this is what we want for mode.        
        }
    return (curFullTzarExpOutputDirRootWithSlash)
    }

curFullTzarExpOutputDirRootWithSlash = 
    createFullTzarExpOutputDirRoot (curExpOutputDirName, 
                                    tzarOutputdataRootWithSlash, dir.slash)

#===============================================================================

#  For getEnvLayers()

    #  This used to be called envLayersDir.
    #  Trying to make names differentiate between the source of information 
    #  before the experiment is run and the working copy of information that 
    #  is copied into the tzar output area as part of the experiment.
envLayersSrcDir          = "/Users/Bill/D/Data/MattsVicTestLandscape/MtBuffaloEnvVars_Originals/"
    #  This used to be called curFullMaxentEnvLayersDirName.
    #  I'm trying to get rid of references to maxent in cases where things 
    #  are not specific just to maxent.  
    #
#envLayersWorkingDir = "/Users/Bill/tzar/outputdata/g2/default_runset/400_Scen_1/InputEnvLayers"
envLayersWorkingDirName = "InputEnvLayers"
envLayersWorkingDirWithSlash = paste0 (curFullTzarExpOutputDirRootWithSlash, 
                                       envLayersWorkingDirName, dir.slash)

#===============================================================================

#----------------
#  user options
#----------------

smoothSuitabilitiesWithGaussian  = TRUE
gaussianSuitabilitySmoothingMean = 0
gaussianSuitabilitySmoothingSD   = 1

scaleInputs           = TRUE  #  DO NOT CHANGE THIS VALUE FOR NOW.  SEE COMMENT in original code.
dataSrc               = "mattData"    #  Should become a guppy option...

#envLayersWorkingDirWithSlash = [has already been set above]
numSpp                        = NA
randomSeed                    = 17

    #  ***  Need to derive this from the images rather than set it.  ***
numImgRows  = 512
numImgCols  = 512
numImgCells = numImgRows * numImgCols

#  Matt's suggested weights are recorded at end of following lines...
#  Not using those weights yet.
asciiImgFileNameRoots = c("aniso_heat",      #  0-1
                          "evap_jan",  #  0.5
                          "evap_jul",  #  0.5
                          "insolation",      #  0-1
                          "max_temp",  #  0.5
                          "min_temp",  #  0.5
                          "modis_evi",  #  0.5
                          "modis_mir",  #  0.5
                          "ndmi",  #  0.5
                          "pottassium",      #  0-1
                          "raindays_jan",  #  0.5
                          "raindays_jul",  #  0.5
                          "rainfall_jan",  #  0.5
                          "rainfall_jul",  #  0.5
                          "thorium",      #  0-1
                          "twi_topocrop",      #  0-1
                          "vert_major",      #  0-1
                          "vert_minor",      #  0-1
                          "vert_saline",      #  0-1
                          "vis_sky"      #  0-1
                        )
imgFileType = "asc"
numNonEnvDataCols = 0

#----------

#envClustersFileNameWithPath= "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/env_clusters.asc"
clusterFileNameStem = "env_clusters"

##clusterFilePath = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/"
#clusterFilePath = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/"
clusterFilePath = "/Users/Bill/D/Data/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/"
#clusterFilePath = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/LowerLeft/"
#clusterFileNameWithPath = envClustersFileNameWithPath

#----------

trueProbDistSppFilenameBase = "true.prob.dist.spp."

#===============================================================================

sppGenOutputDirWithSlash = paste0 (curFullTzarExpOutputDirRootWithSlash, 
                                   "SppGenOutputs", dir.slash)

if (file.exists (sppGenOutputDirWithSlash))
    {
    errMsg = paste0 ("\n\n*** In initializeG2options.R: ", 
                     "\n*** sppGenOutputDirWithSlash = \n***     ", 
                     sppGenOutputDirWithSlash, 
                     "\n*** already exists.  ", 
                     "\n*** Need to change sppGenOutputDirWithSlash in ", 
                     "initializeG2options.R\n\n")
    stop (errMsg)
    
    } else
    {
    cat ("\n\nsppGenOutputDirWithSlash DOES NOT exist.  ", 
         "Creating it.\n\n", sep='')  
    dir.create (sppGenOutputDirWithSlash, 
                showWarnings = TRUE, 
                recursive = TRUE, #  Not sure about this, but it's convenient.
                mode = "0777")    #  Not sure if this is what we want for mode.        
    }

#===============================================================================

#  This used to be called curFullMaxentSamplesDirName.
#  I'm trying to get rid of references to maxent in cases where things 
#  are not specific just to maxent.  
#
#  From Guppy.py initializations and yaml
# self.curFullMaxentSamplesDirName = \
# PARcurrentRunDirectory + self.variables['PAR.maxent.samples.base.name']
# PAR.maxent.samples.base.name:  "MaxentSamples"

fullSppSamplesDirWithSlash = paste0 (curFullTzarExpOutputDirRootWithSlash, 
                                     "MaxentSamples", dir.slash)

if (file.exists (fullSppSamplesDirWithSlash))
    {
    errMsg = paste0 ("\n\n*** fullSppSamplesDirWithSlash = \n***     ", 
                     fullSppSamplesDirWithSlash, 
                     "\n*** already exists.  ", 
                     "\n*** Need to change fullSppSamplesDirWithSlash in ", 
                     "initializeG2options.R\n\n")
    stop (errMsg)
    
    } else
    {
    cat ("\n\nfullSppSamplesDirWithSlash DOES NOT exist.  ", 
         "Creating it.\n\n", sep='')  
    dir.create (fullSppSamplesDirWithSlash, 
                showWarnings = TRUE, 
                recursive = TRUE, #  Not sure about this, but it's convenient.
                mode = "0777")    #  Not sure if this is what we want for mode.        
    }


#self.trueProbDistFilePrefix = self.variables["PAR.trueProbDistFilePrefix"]
#PAR.trueProbDistFilePrefix: "true.prob.dist"
trueProbDistFilePrefix = "true.prob.dist"


#===============================================================================

useRandomNumTruePresForEachSpp = TRUE    #  variables$PAR.use.random.num.true.presences

numSpp = 28    #  variables$PAR.num.spp.to.create

minTruePresFracOfLandscape = 0.0002    #  0.002    #  variables$PAR.min.true.presence.fraction.of.landscape
maxTruePresFracOfLandscape = 0.002     #  0.2      # variables$PAR.max.true.presence.fraction.of.landscape

numTruePresForEachSpp_string = "50,100,75"    #  variables$PAR.num.true.presences

#-------------------------------------------------------------------------------

#  Values for setting values in .asc headers.
#  These were passed in from Pyper before.
#  Hard coding for now.  
#  Need to read them from one of the env files or something.
#  yaml file shows:
# PAR.ascFileNcols: 512
# PAR.ascFileNrows: 512
# PAR.ascFileXllcorner: 2618380.652817
# PAR.ascFileYllcorner: 2529528.47684
# PAR.ascFileCellsize: 75.0
# PAR.ascFileNodataValue: -9999

llcorner = c (2618380.65282, 2529528.47684)
cellsize = 75.0
nodataValue = -9999

#===============================================================================

PARuseAllSamples = FALSE

#===============================================================================

#===============================================================================

#===============================================================================

