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

#  One problem with these distance functions is that it has often been shown 
#  that as the number of dimensions goes up, distances all converge to being 
#  very similar.

#  How might we get around that?  Would it make sense to convert to PCA 
#  coordinates and use far less coordinates?  Matt explained why using PCA 
#  coordinates was a bad thing for clustering, but I've forgotten his 
#  explanation.  Was it in general or just for these kinds of ecological 
#  clusters?  

#  One possibility might also be to do the pca separately for each clustering 
#  and just use the values inside that cluster as the fodder for the PCA 
#  calculation.  

#===============================================================================

sumSquaredDist_givenDiffVec = function (aVector)
    {
    return (sum (aVector ^ 2))
    }

#-------------------------------------------------------------------------------

sumSquaredDist = function (vector1, vector2)
    {
    if (length (vector1) != length (vector2))
        {
        cat ("\nIn sumSquareDist(), lengths don't match.",
             "\n    length (vector1) = ", length (vector1), 
             "\n    length (vector2) = ", length (vector2),
             "\n\n")
        }
    
    return (sumSquaredDist_givenDiffVec (vector1 - vector2))
    }

#-------------------------------------------------------------------------------

eucDist_givenDistVec = function (aVector)
    {
    return (sqrt (sumSquaredDist_givenDiffVec (aVector)))
    }

#-------------------------------------------------------------------------------

eucDist = function (vector1, vector2)
    {
    return (eucDist_givenDistVec (vector1 - vector2))
    }

#-------------------------------------------------------------------------------

const_sqrt2pi = sqrt(2*pi)
gaussian = function (aVector, centerVector, sdVector)
    {
    exponentNumerator = -(aVector - centerVector) ^ 2
    cat ("\n\ngaussian exponentNumerator = ", exponentNumerator)
    
    exponentDenominator = 2 * (sdVector ^ 2)
    cat ("\n\ngaussian exponentDenominator = ", exponentDenominator)
    
    fullFractionDenominator = sdVector * const_sqrt2pi
    cat ("\n\ngaussian fullFractionDenominator = ", fullFractionDenominator)
        
    gaussianValue = (exp (exponentNumerator / exponentDenominator) / 
                    fullFractionDenominator)
    cat ("\n\ngaussian gaussianValue = ", gaussianValue)
    
    cat ("\n\n")
    
    return (gaussianValue)
    }

#----------------------------------

gaussianInverseWeightedDist = function (aVector, centerVector, sdVector)
    {
    gaussianWtVec = gaussian (aVector, centerVector, sdVector)
    
    gaussianWeightedDiffVec = (aVector - centerVector) / gaussianWtVec
    
    return (eucDist_givenDistVec (gaussianWeightedDiffVec))
    }

#----------------------------------

outOfEnvelopeValue = Inf     #  Not sure what to put here...
#outOfEnvelopeValue = 40     #  Not sure what to put here...
                            #  In the current case, there are 20 features, 
                            #  each scaled to be roughly 0-1, so the maximum 
                            #  distance among them is close to 20.

envelopeDist = function (aVector, centerVector, minVector, maxVector)
    {
        #  If the point is fully inside the cluster's envelope, 
        #  i.e., all feature values between the cluster's min and max 
        #  values for the corresponding feature, then return the 
        #  euclidean distance to the center of the cluster in feature 
        #  space (e.g., the mean or median).

    #cat ("\n\nIN ENVELOPEDIST:")
    #cat ("\n    minVector = ", minVector)
    #cat ("\n    maxVector = ", maxVector)
    
    numInBoundMins = sum (aVector >= minVector)
    #cat ("\n     numInBoundMins = ", numInBoundMins)
    if (numInBoundMins < length (minVector))
        return (outOfEnvelopeValue)

    numInBoundMaxs = sum (aVector <= maxVector)
    #cat ("\n     numInBoundMaxs = ", numInBoundMaxs)
    if (sum (aVector <= maxVector) < length (minVector))
        return (outOfEnvelopeValue)
    
    return (eucDist (aVector, centerVector))
    }

#----------------------------------

outOfClusterValue = Inf     #  Not sure what to put here...
#outOfClusterValue = 40     #  Not sure what to put here...
#  In the current case, there are 20 features, 
#  each scaled to be roughly 0-1, so the maximum 
#  distance among them is close to 20.

#  NOTE:  For now at least, using this distance assumes that the po
hardClusterDist = function (aVector, centerVector, insideCluster=TRUE)
{
    #  If the point is fully inside the cluster, 
    #  then return the euclidean distance to the 
    #  center of the cluster in feature 
    #  space (e.g., the mean or median).
    #  You could also just return a constant value 
    #  instead, but this would at least make some 
    #  differentiation among values inside the clusters.
    
    if (insideCluster) 
    {
        return (eucDist (aVector, centerVector))
        #        return (1)
    } else
    {
        return (outOfClusterValue)
        #        return (0)
    }
}
#----------------------------------

hardClusterDist_01only = function (aVector, centerVector, insideCluster=TRUE)
    {
        #  If the point is fully inside the cluster, 
        #  then return the euclidean distance to the 
        #  center of the cluster in feature 
        #  space (e.g., the mean or median).
        #  You could also just return a constant value 
        #  instead, but this would at least make some 
        #  differentiation among values inside the clusters.
    
    if (insideCluster) 
        {
        return (0)
        } else
        {
        return (1)
        }
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
clusterMins = matrix (0, nrow=numClusters, ncol=numColsInEnvLayersTable)
clusterMaxs = matrix (0, nrow=numClusters, ncol=numColsInEnvLayersTable)

clusterSizes = rep (0, numClusters)
curClusterSuitabilities = rep (0.0, numPixelsPerImg)

curPixelCt = 0
curClusterTableIndex = 0
for (curClusterID in clusterIDs)
    {
    cat ("\n\n>>>>>  curClusterID = ", curClusterID)
    
    curClusterTableIndex = curClusterTableIndex + 1
    cat ("\n\n>>>>>  curClusterTableIndex = ", curClusterTableIndex)
    
    curClusterPixelLocs = which (clusterPixelValuesLayer == curClusterID)
    cat ("\nlength (curClusterPixelLocs) = ", length (curClusterPixelLocs))
    clusterSizes [curClusterTableIndex] = length (curClusterPixelLocs)

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
        colMins = envDataSrc [curClusterPixelLocs, ]
        colMaxs = envDataSrc [curClusterPixelLocs, ]
        
        } else 
        {
            #  More than one pixel in this cluster.
        colCenters = apply (envDataSrc [curClusterPixelLocs, ], 2, centerFunc) 
        colDeviations = apply (envDataSrc [curClusterPixelLocs, ], 2, deviationFunc)                    
        colMins = apply (envDataSrc [curClusterPixelLocs, ], 2, min)
        colMaxs = apply (envDataSrc [curClusterPixelLocs, ], 2, max)
        }
    
    cat ("\n\ncolCenters = ", colCenters)
    cat ("\nlength (colCenters) = ", length (colCenters))
    clusterCenters [curClusterTableIndex, ] = colCenters
    
    cat ("\n\ncolDeviations = ", colDeviations)
    cat ("\nlength (colDeviations) = ", length (colDeviations))
    clusterDeviations [curClusterTableIndex, ] = colDeviations
    
    cat ("\n\ncolMins = ", colMins)
    cat ("\nlength (colMins) = ", length (colMins))
    clusterMins [curClusterTableIndex, ] = colMins
    
    cat ("\n\ncolMaxs = ", colMaxs)
    cat ("\nlength (colMaxs) = ", length (colMaxs))
    clusterMaxs [curClusterTableIndex, ] = colMaxs
    
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
sppClusterDistanceMapsDir = "./SppClusterDistanceMaps/"    

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
    
    curClusterMin = clusterMins [curClusterTableIndex, ]
    cat ("\ncurClusterMin = ", curClusterMin)
    
    curClusterMax = clusterMaxs [curClusterTableIndex, ]
    cat ("\ncurClusterMax = ", curClusterMax)
    
    useHardClusterDistance = TRUE    #  also need to do this for envelope dist
    if (useHardClusterDistance)
        {
        insideCluster = (clusterPixelValuesLayer == curClusterID)
        cat ("\ncurrent cluster size = ", sum (insideCluster))
        }
    

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
            cat ("\nenvelopeDist (point1, point2, curClusterMin, curClusterMax) = ", envelopeDist (point1, point2, curClusterMin, curClusterMax))
                
            cat ("\n\n")
            }
        
#        distVecs [curRow, curClusterTableIndex] = sumSquaredDist (point1, point2)
#        distVecs [curRow, curClusterTableIndex] = eucDist (point1, point2)
        
        distVecs [curRow, curClusterTableIndex] = envelopeDist (point1, point2, curClusterMin, curClusterMax)
#        distVecs [curRow, curClusterTableIndex] = hardClusterDist (point1, point2, insideCluster [curRow])
#        distVecs [curRow, curClusterTableIndex] = hardClusterDist_01only (point1, point2, insideCluster [curRow])
                
        
        }  #  end for - all pixels
    
    
    cat ("\n\nDone computing distVecs for curClusterTableIndex = ", curClusterTableIndex)
    
    #cat ("\n\ndistVecs = \n")
    #print (distVecs)
    #cat ("\n\n")

    
    if (FALSE)  
    {
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
    
    #  *** Need to write these to files in the output area too.
    #  Can't remember the command right now...
    hist (distVecs[,curClusterTableIndex], breaks=seq(0,histTop,histIntervalLength),
          main = paste ("Distance hist for spp ", (curClusterTableIndex-1), ", cluster ", curClusterID, sep=''))
    }
    
    
    
    

    #----------------------------------    

    #  *** Need to convert these distances to suitabilities/relativeProbabilities 
    #      instead and write those out to the tzar output area.
    
    curClusterDistVec = distVecs[,curClusterTableIndex]
    finiteRange = range (curClusterDistVec, finite = TRUE)
    curMaxDistValue = finiteRange [2]

    pixelIsInCurCluster = (clusterPixelValuesLayer == curClusterID)
    curInClusterPixelLocs = which (pixelIsInCurCluster)
#    curOutOfClusterPixelLocs = which (! pixelIsInCurCluster)

    curClusterSuitabilities [] = 0.0
    
    epsilonValue = 0.25 * curMaxDistValue    #  to give a little space above 0
#    epsilonValue = 9 * curMaxDistValue    #  to give a little space above 0
    
    curMaxPlusEpsilonValue = curMaxDistValue + epsilonValue
    curClusterSuitabilities [curInClusterPixelLocs] = curMaxPlusEpsilonValue - curClusterDistVec [curInClusterPixelLocs]
#    curClusterSuitabilities [curOutOfClusterPixelLocs] = 0.0
    
    curSuitabilityImg = matrix (curClusterSuitabilities, nrow=numImgRows, ncol=numImgCols, byrow=TRUE)
    

    
    maxHistSuit = 1.1* max (curClusterSuitabilities)
    
    #histIntervalLength = 0.1
    histIntervalLength = maxHistSuit / numHistIntervals
    
    #histTop = 1.0
    histTop = (histIntervalLength * numHistIntervals) + 0.1
    
    cat ("\n\nShow histogram for distances to cluster ", curClusterTableIndex, sep='')
    cat ("\n    numHistIntervals = ", numHistIntervals, sep='')
    cat ("\n    maxSuit = ", maxSuit, sep='')
    cat ("\n    histIntervalLength = ", histIntervalLength, sep='')
    cat ("\n    histTop = ", histTop, sep='')
    
    #  *** Need to write these to files in the output area too.
    #  Can't remember the command right now...
    hist (curClusterSuitabilities, breaks=seq(0,histTop,histIntervalLength),
          main = paste ("SUITABILITY hist for spp ", (curClusterTableIndex-1), ", cluster ", curClusterID, sep=''))
    
    
    
    
    
    filenameRoot = paste (sppClusterDistanceMapsDir, "spp.", (curClusterTableIndex - 1), sep='')
    write.asc.file (curSuitabilityImg,
                    filenameRoot,
                    numImgRows, numImgCols
                    , xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
                    , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
                    #  is not actually on the map.  It's just off the lower
                    #  left corner.
                    , no.data.value = -9999
                    , cellsize = 1
    )
    
    #----------------------------------    
    
    curDistImg = matrix (distVecs[,curClusterTableIndex], nrow=numImgRows, ncol=numImgCols, byrow=TRUE)
    
            #  IS THIS NECESSARY SINCE THE MAC FINDER PROGRAM SEEMS TO 
            #  BE ABLE TO DISPLAY .ASC FILES AND ONE OF THOSE IS WRITTEN  
            #  BELOW?
            #  BUT THAT ASSUMES THE PROGRAM IS ONLY RUNNING ON MACS, SINCE 
            #  I DON'T THINK THE WINDOWS VIEWER CAN READ .ASC.  
            #  NOT SURE ABOUT EITHER PGM OR ASC UNDER LINUX...
    write.pgm.file (curDistImg,
                    paste (sppClusterDistanceMapsDir, "distToSpp.", (curClusterTableIndex - 1), ".Cluster.", curClusterID, sep=''),
                    numImgRows, numImgCols)
    
    
    #---------------
    #  BTL - 11/8/13 - added for compatibility with tzar runs
    
    filenameRoot = paste (sppClusterDistanceMapsDir, "distToSpp.", (curClusterTableIndex - 1), sep='')
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
    
#if (curClusterTableIndex > 5) 
#    break
    
}  #  end - for all clusterIDs

sppIDs = 0:(numClusters - 1)
sppIDvsClusterID = cbind (sppIDs, clusterIDs, clusterSizes)
write.csv (sppIDvsClusterID, 
           paste (sppClusterDistanceMapsDir, "sppIDvsClusterIDvsClusterSize.csv", sep=''),
           row.names=FALSE)

#plot (1:numPixelsPerImg, distVecs[,1])
#lines (distVecs [,1], lty=1)
#lines (distVecs [,2], lty=2)
##plot (distVecs [,2], lty=1)
##lines (distVecs [,1], lty=2)
##lines (distVecs [,2], lty=1)

#===============================================================================
