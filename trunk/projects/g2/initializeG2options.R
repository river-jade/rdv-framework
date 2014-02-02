#===============================================================================

#  source ("initializeG2options.R")

#===============================================================================

#  History

#  2014 02 01 - BTL - Created.

#===============================================================================

#  Most (if not all) of these will come from the yaml file eventually...

#===============================================================================

    #  For getEnvLayers()

envLayersDir                  = "/Users/Bill/D/Data/MattsVicTestLandscape/MtBuffaloEnvVars_Originals/"
curFullMaxentEnvLayersDirName = "/Users/Bill/tzar/outputdata/g2/default_runset/400_Scen_1/InputEnvLayers"

#===============================================================================

#----------------
#  user options
#
#  NOTE: This section has to come after the distance function definitions 
#        since some functions may be referenced here.
#----------------

#  Should become guppy options in yaml file...
centerFunc            = mean    #  mean, median, ...
deviationFunc         = sd    #  sd, mad, ...
distMeasure           = sumSquaredDist
#hardClusterDist
#sumSquaredDist
#eucDist

smoothSuitabilitiesWithGaussian  = TRUE
gaussianSuitabilitySmoothingMean = 0
gaussianSuitabilitySmoothingSD   = 1

scaleInputs           = TRUE  #  DO NOT CHANGE THIS VALUE FOR NOW.  SEE COMMENT in original code.
dataSrc               = "mattData"    #  Should become a guppy option...

sppGenOutputDir               = ""
#curFullMaxentEnvLayersDirName = [has already been set above]
numSpp                        = NA
randomSeed                    = 17

    #  ***  Need to derive this from the images rather than set it.  ***
numImgRows = 512
numImgCols = 512

#===============================================================================

#===============================================================================

#===============================================================================

#===============================================================================

#===============================================================================

#===============================================================================

