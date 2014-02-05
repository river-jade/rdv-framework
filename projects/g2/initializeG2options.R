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

sppGenOutputDir               = ""
#envLayersWorkingDirWithSlash = [has already been set above]
numSpp                        = NA
randomSeed                    = 17

    #  ***  Need to derive this from the images rather than set it.  ***
numImgRows = 512
numImgCols = 512

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

#===============================================================================

#===============================================================================

#===============================================================================

#===============================================================================

#===============================================================================

