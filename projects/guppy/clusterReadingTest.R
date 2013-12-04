#===============================================================================

source ("read.R")

#===============================================================================

#----------------
#  user options
#----------------

#  Should become guppy options in yaml file...
centerFunc            = median    #  mean, median, ...
deviationFunc         = mad    #  sd, mad, ...
distMeasure           = sumSquaredDist

scaleInputs           = TRUE  #  DO NOT CHANGE THIS VALUE FOR NOW.  SEE COMMENT in original code.
dataSrc               = "mattData"    #  Should become a guppy option...

callingFromGuppy = FALSE
if (callingFromGuppy & exists ("rSppGenOutputDir"))
 {
    sppGenOutputDir               = rSppGenOutputDir
    curFullMaxentEnvLayersDirName = rCurFullMaxentEnvLayersDirName
    numSpp                        = rNumSpp
 }

#===============================================================================

#  options warn:
#    sets the handling of warning messages.

#    If warn is negative all warnings are ignored.

#    If warn is 0 (the default) warnings are stored until
#    the top–level function returns.
#    If 10 or fewer warnings were signalled they will be printed
#    otherwise a message saying how many were signalled.
#    An object called last.warning is created and can be printed
#    through the function warnings.

#    If warn is 1, warnings are printed as they occur.

#    If warn is 2 or larger all warnings are turned into errors.

#options (warn = -1)
#options (warn = 0)
#options (warn = 1)
options (warn = 2)

#===============================================================================
#                    Distance functions and transforms
#===============================================================================

vecSquared = function (aVector, baseIdx = 1)
    {
    curSumSquares = 0
    for (curIdx in baseIdx:length(aVector))
        {
        #cat ("\n    curIdx = ", curIdx)
        curSumSquares = curSumSquares + (aVector [curIdx] ^ 2)
        #cat (", curSumSquares = ", curSumSquares)
        }
    #cat ("\nAT END OF vecSquared()")
    return (curSumSquares)
    }

#-------------------------------------------------------------------------------

sumSquaredDist = function (vector1, vector2)
    {
    if (length (vector1) != length (vector2))
        {
        mismatchCt <<- mismatchCt + 1
        if (mismatchCt < 10)
            {
            cat ("\n\n--------------------------------------\n")
            cat ("\nIn sumSquareDist(), lengths don't match.  mismatchCt = ",
                 mismatchCt, ".")
            cat ("\n    length (vector1) = ", length (vector1))
            cat ("\n    length (vector2) = ", length (vector2))
            cat ("\n    vector1 = ", vector1)
            cat ("\n    vector2 = ", vector2)
            cat ("\n")
            }
        }
    vs = vecSquared (vector1 - vector2)
    #cat ("\nvs = ", vs)
    retValue = vs
    #    retValue = sqrt (vs)
    #cat ("\nretValue = ", retValue)
    
    if ((length (vector1) != length (vector2)) & (mismatchCt < 10))
        {
        cat ("\nvs = ", vs)
        cat ("\nretValue = ", retValue)
        cat ("\n--------------------------------------\n\n")
        }
    
    return (retValue)
    }

#-------------------------------------------------------------------------------

eucDist = function (vector1, vector2)
    {
    return (sqrt (sumSquaredDist (vector1, vector2)))
    }

#-------------------------------------------------------------------------------

const_sqrt2pi = sqrt(2*pi)
gaussian = function (xVector, muVector, sdVector)
    {
    exponentNumerator = -(xVector - muVector) ^ 2
    cat ("\n\ngaussian exponentNumerator = ", exponentNumerator)
    
    exponentDenominator = 2 * (sdVector ^ 2)
    cat ("\n\ngaussian exponentDenominator = ", exponentDenominator)
    
    fullFractionDenominator = sdVector * const_sqrt2pi
    cat ("\n\ngaussian fullFractionDenominator = ", fullFractionDenominator)
    cat ("\n\n")
        
    gaussianVector = 
        exp (exponentNumerator / exponentDenominator) / 
        fullFractionDenominator
    
    return (gaussianVector)
    }

#----------------------------------

gaussianInverseWeightedDist = function (vector1,vector2, sdVector)
    {
    gaussianWeight = 
    return (eucDist (vector1, vector2) / gaussian (vector1, vector1, sdVector))
    }

#===============================================================================

#-------------------
#  initializations
#-------------------

imgFileType           = NULL
numImgRows            = NULL
numImgCols            = NULL
imgSrcDir             = NULL
imgFileNames          = NULL
asciiImgFileNameRoots = NULL
numEnvLayers          = NULL
mismatchCt            = 0
imgFileType           = "asc"


if (dataSrc == "mattData")
{
    imgFileType = "asc"
    numImgRows  = 512
    numImgCols  = 512
    imgSrcDir   = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloEnvVars_Originals/"
    
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
    
    numEnvLayers = length (asciiImgFileNameRoots)
}

numPixelsPerImg         = numImgRows * numImgCols
numNonEnvDataCols       = 0
numColsInEnvLayersTable = numEnvLayers + numNonEnvDataCols
combinedEnvLayersTable  = matrix (0, nrow=numPixelsPerImg, ncol=numColsInEnvLayersTable, byrow=TRUE)

#------------------------------------------------
#  Load all of the env data layers.
#
#  That is, read each env layer file into a
#  single column of a large table with one row
#  for each pixel's set of all env feature
#  values.
#------------------------------------------------

arrayIdxBase    = 1    #  1 is index base in R, need 0 if python
curImgFileIdx   = arrayIdxBase - 1
firstFeatureCol = arrayIdxBase + numNonEnvDataCols

for (curCol in firstFeatureCol:numColsInEnvLayersTable)
{
    curImgFileIdx = curImgFileIdx + 1
    
    if (imgFileType == "asc")
    {
        #  ASC input images
        curEnvLayer = read.asc.file.to.matrix (asciiImgFileNameRoots [curImgFileIdx], imgSrcDir)
        
    } else
    {
        #  Unknown input images
        cat ("\n\nFATAL ERROR:  Unknown input image file type = '", imgFileType, "'.\n\n")
        quit()
    }
    
    combinedEnvLayersTable [,curCol] = as.vector (t(curEnvLayer))
}

#-----------------------------------------------------------------------------

rownames (combinedEnvLayersTable) = arrayIdxBase:numPixelsPerImg

if (scaleInputs)
    combinedEnvLayersTable = scale (combinedEnvLayersTable)

envDataSrc = combinedEnvLayersTable


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-------------------------
#  Need to:
#    - read the cluster IDs image from an asc file (ignoring missing values, i.e., -9999)
#    - make a list of locations for each of the unique cluster IDs in the
#      file
#    - compute the cluster center for each of those unique clusters
#        - this could be the mean or the mediod
#        - may want to save the mean and sd to use in specifying a gaussian 
#          transform on the distance to the cluster center as a measure of 
#          suitability.  otherwise, have to invent an sd to use.
#          Might also suggest fitting some kind of a function to the features 
#          of points in the cluster and have that function produce a probability
#          for any given point in the image.  For example, Japkowicz was 
#          talking about not needing any negative examples for one kind of a 
#          learning algorithm.
#            - see also mad() and IQR() for more robust measures...
#            - also see fivenum() [Tukey's five number summary (minimum, 
#              lower-hinge, median, upper-hinge, maximum)]
#               - what are hinges?
#    - save the centers (and sd's?) in a table indexed by cluster ID
#-------------------------

envClustersFileNameWithPath= "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/env_clusters.asc"

clusterFileNameStem = "env_clusters"
#clusterFilePath = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/"
clusterFilePath = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers/"

clusterFileNameWithPath = envClustersFileNameWithPath

#    - read the cluster IDs image from an asc file (ignoring missing values, i.e., -9999)
clusterPixelValuesLayer = read.asc.file.to.matrix (clusterFileNameStem, clusterFilePath)

cat ("\n\ndim(clusterPixelValuesLayer) after read.asc.file.to.matrix() = ", 
     dim(clusterPixelValuesLayer))

    #  NOTE: unique returns the entire matrix if I don't apply as.vector() 
    #        to the matrix first.  Not sure why.
clusterIDs = sort (unique (as.vector(clusterPixelValuesLayer[])))
numClusters = length (clusterIDs)

cat ("\n\nclusterIDs = ", clusterIDs)
cat ("\n\nnumClusters = ", numClusters)

clusterCenters = matrix (0, nrow=numClusters, ncol=numColsInEnvLayersTable)
clusterDeviations = matrix (0, nrow=numClusters, ncol=numColsInEnvLayersTable)


curPixelCt = 0
curClusterTableIndex = 0
for (curClusterID in clusterIDs)
    {
    cat ("\n\n>>>>>  curClusterID = ", curClusterID)
    
    curClusterTableIndex = curClusterTableIndex + 1
    cat ("\n\n>>>>>  curClusterTableIndex = ", curClusterTableIndex)
    
    curClusterPixelLocs = which (clusterPixelValuesLayer == curClusterID)
    cat ("\nlength (curClusterPixelLocs) = ", length (curClusterPixelLocs))

#    cat ("\n\nenvDataSrc [curClusterPixelLocs, ] = ", envDataSrc [curClusterPixelLocs, ])
    
    #  BTL - 2013.08.13
    #  Added this test because I found that the cbind was doing weird
    #  things when the sampled.locs.x.y had just one row in it but
    #  had not been created as a matrix. The cbind would treat the
    #  2 element vector of x and y as a column vector and replicate
    #  the species and split x and y onto separate rows, making a
    #  2x2 matrix instead of a 1 row x 3 column matrix.
    #  Making it explicit here that that sampled.locs.x.y is to be
    #  treated as a matrix instead of a vector fixed the problem.
    if (is.vector (envDataSrc [curClusterPixelLocs, ]))
        {
            #  Only one pixel in this cluster.
        colCenters = envDataSrc [curClusterPixelLocs, ]
        colDeviations = rep (0, length (colCenters))
        
        } else 
        {
            #  More than one pixel in this cluster.
        colCenters = apply (envDataSrc [curClusterPixelLocs, ], 2, centerFunc) 
        colDeviations = apply (envDataSrc [curClusterPixelLocs, ], 2, deviationFunc)                    
        }
    
    cat ("\n\ncolCenters = ", colCenters)
    cat ("\nlength (colCenters) = ", length (colCenters))
    clusterCenters [curClusterTableIndex, ] = colCenters
    
    cat ("\n\ncolDeviations = ", colDeviations)
    cat ("\nlength (colDeviations) = ", length (colDeviations))
    clusterDeviations [curClusterTableIndex, ] = colDeviations
    
    curPixelCt = curPixelCt + length (curClusterPixelLocs)
    }

cat ("\n\ncurPixelCt at end = ", curPixelCt)
cat ("\narray size = ", 512*512)

cat ("\n\n")


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

distVecs = matrix (0, nrow=numPixelsPerImg, ncol=numClusters)
#cat ("\n>>>>>>>>>>>>>>>>>>>>>>>>>>  new distVec = ", distVec)

numHistIntervals = 10

curClusterTableIndex = 0
for (curClusterID in clusterIDs)
    {
    cat ("\n\n>>>>>  curClusterID = ", curClusterID)
    
    curClusterTableIndex = curClusterTableIndex + 1
    cat ("\n\ncurClusterTableIndex = ", curClusterTableIndex)
    
    curClusterCenter = clusterCenters [curClusterTableIndex, ]
    cat ("\ncurClusterCenter = ", curClusterCenter)
    
    curClusterDeviation = clusterDeviations [curClusterTableIndex, ]
    cat ("\ncurClusterDeviation = ", curClusterDeviation)
    
    for (curRow in 1:numPixelsPerImg)
        {
        #cat ("\nLOOP START: curRow = ", curRow)
        
        point1 = envDataSrc [curRow,]        
        #cat ("\npoint1 = ", point1)
        
        point2 = curClusterCenter
        #cat ("\npoint2 = ", point2)
        
        #ed = eucDist (point1, point2)
        #cat ("\ned = ", ed)
        #cat ("\nLOOP END: curRow = ", curRow, ", length (distVec) = ", length(distVec))
        
        if (curRow < 2)
            {
            cat ("\ncurRow = ", curRow)
            cat ("\ncurClusterTableIndex = ", curClusterTableIndex)

            cat ("\n\ndim (distVecs) = ", dim (distVecs))
            
            cat ("\n\npoint1 = ", point1)
            #cat ("\n\nlength (point1) = ", length (point1))
            
            cat ("\n\npoint2 = ", point2)
            #cat ("\n\nlength (point2) = ", length (point2))
            
            cat ("\n\nsumSquaredDist (point1, point2) = ", sumSquaredDist (point1, point2))
            cat ("\neucDist (point1, point2) = ", eucDist (point1, point2))   
            cat ("\ngaussianInverseWeightedDist (point1, point2, curClusterDeviation) = ", gaussianInverseWeightedDist (point1, point2, curClusterDeviation))
            
            cat ("\n\n")
            }
        
        distVecs [curRow, curClusterTableIndex] = sumSquaredDist (point1, point2)
        
        }  #  end for - all pixels

    cat ("\n\nDone computing distVecs for curClusterTableIndex = ", curClusterTableIndex)
    
    #cat ("\n\ndistVecs = \n")
    #print (distVecs)
    #cat ("\n\n")
    
    maxDist = max (distVecs [,curClusterTableIndex]) + 0.5
    
    #histIntervalLength = 0.1
    histIntervalLength = maxDist / numHistIntervals
    
    #histTop = 1.0
    histTop = (histIntervalLength * numHistIntervals) + 0.1
    
    cat ("\n\nShow histogram for distances to cluster ", curClusterTableIndex, sep='')
    cat ("\n    numHistIntervals = ", numHistIntervals, sep='')
    cat ("\n    maxDist = ", maxDist, sep='')
    cat ("\n    histIntervalLength = ", histIntervalLength, sep='')
    cat ("\n    histTop = ", histTop, sep='')
    
    hist (distVecs[,curClusterTableIndex], breaks=seq(0,histTop,histIntervalLength),
          main = paste ("Distance hist for cluster", curClusterTableIndex))
        
    if (TRUE)
    {
    curDir = "./"    
    curDistImg = matrix (distVecs[,curClusterTableIndex], nrow=numImgRows, ncol=numImgCols, byrow=TRUE)
    
            #  IS THIS NECESSARY SINCE THE MAC FINDER PROGRAM SEEMS TO 
            #  BE ABLE TO DISPLAY .ASC FILES AND ONE OF THOSE IS WRITTEN  
            #  BELOW?
            #  BUT THAT ASSUMES THE PROGRAM IS ONLY RUNNING ON MACS, SINCE 
            #  I DON'T THINK THE WINDOWS VIEWER CAN READ .ASC.  
            #  NOT SURE ABOUT EITHER PGM OR ASC UNDER LINUX...
    write.pgm.file (curDistImg,
                    paste (curDir, "distToCluster.", (curClusterTableIndex - 1), sep=''),
                    numImgRows, numImgCols)
    
    
    #---------------
    #  BTL - 11/8/13 - added for compatibility with tzar runs
    
    filenameRoot = paste (curDir, "spp.", (curClusterTableIndex - 1), sep='')
    write.asc.file (curDistImg,
                    filenameRoot,
                    numImgRows, numImgCols
                    , xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
                    , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
                    #  is not actually on the map.  It's just off the lower
                    #  left corner.
                    , no.data.value = -9999
                    , cellsize = 1
                    )
    #---------------
        
    if (curClusterTableIndex > 1)
        {
        distDiff = sum(distVecs[,curClusterTableIndex] - distVecs[,curClusterTableIndex-1])
        cat ("\n\nFor curClusterTableIndex = ", curClusterTableIndex, ", distDiff = ", distDiff, "\n", sep='')
        }
    
    }  #  end - if FALSE

if (curClusterTableIndex > 5) 
    break
    
}  #  end - for all clusterIDs


#plot (1:numPixelsPerImg, distVecs[,1])
#lines (distVecs [,1], lty=1)
#lines (distVecs [,2], lty=2)
##plot (distVecs [,2], lty=1)
##lines (distVecs [,1], lty=2)
##lines (distVecs [,2], lty=1)

#===============================================================================
