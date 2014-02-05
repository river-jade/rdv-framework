#===============================================================================

#  source ("getTrueSppDistFromExistingClusters.R")

#===============================================================================

#  History

#  2014 02 01 - BTL - Created.
#  Extracted from clusterReadingTest.R from guppy project and turned into 
#  a function.

#===============================================================================

source (paste0 (g2ProjectRsrcDirWithSlash, 'distanceFunctionsAndTransforms.R'))
source (paste0 (g2ProjectRsrcDirWithSlash, 'getEnvDataSrc.R'))
source (paste0 (g2ProjectRsrcDirWithSlash, 'getClusterSuitabilities.R'))
source (paste0 (g2ProjectRsrcDirWithSlash, 'writeClusterSuitabilityFile.R'))

#===============================================================================

#  NOTE: This section has to come after the distance function definitions 
#        since some functions may be referenced here.
#  SHOULD BECOME GUPPY OPTIONS IN YAML FILE.

centerFunc            = mean    #  mean, median, ...
deviationFunc         = sd    #  sd, mad, ...
distMeasure           = sumSquaredDist
#hardClusterDist
#sumSquaredDist
#eucDist

#-------------------------------------------------------------------------------

getTrueSppDistFromExistingClusters = 
    function (envLayersWorkingDirWithSlash, numImgRows, numImgCols, 
              sppGenOutputDir, 
              asciiImgFileNameRoots, scaleInputs, 
              imgFileType, numNonEnvDataCols, 
              clusterFilePath, clusterFileNameStem
            )
    {        
    numPixelsPerImg = numImgRows * numImgCols    
    
    envDataSrc = getEnvDataSrc (envLayersWorkingDirWithSlash, numPixelsPerImg, 
                                asciiImgFileNameRoots, scaleInputs, 
                                imgFileType, numNonEnvDataCols)
    
stop ("\nR will say this is an error, but it's just the end of a test invoked by a stop() command.\n\n")
    
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
        
        #  Read the cluster IDs image from an asc file 
        #  (ignoring missing values, i.e., -9999).
    
    clusterPixelValuesLayer = 
        read.asc.file.to.matrix (clusterFileNameStem, clusterFilePath)
    
    cat ("\n\ndim(clusterPixelValuesLayer) after read.asc.file.to.matrix() = ",
         dim (clusterPixelValuesLayer))
        
    #-------------------------------------------------------------------------
    #  Identify and count the clusters that occur in the cluster pixels
    #  input file.
    #
    #  NOTE: "unique" returns the entire matrix if I don't apply as.vector()
    #        to the matrix first.  Not sure why.
    #-------------------------------------------------------------------------
    
    clusterIDs = sort (unique (as.vector(clusterPixelValuesLayer[])))
    cat ("\n\nclusterIDs = ", clusterIDs)
    
    numClusters = length (clusterIDs)
    cat ("\n\nnumClusters = ", numClusters)
    
browser()
    
    #-------------------------------------------------------------------------
    #  Initialize summary matrices with one row for each cluster and
    #  one column for each feature.
    #  For example, a single cell in ClusterCenters would have the mean or
    #  median of the corresponding feature (column) for pixels in the
    #  corresponding cluster (row).
    #-------------------------------------------------------------------------
    
    clusterCenters = matrix (0, nrow=numClusters, ncol=numColsInEnvLayersTable)
    clusterDeviations = matrix (0, nrow=numClusters, ncol=numColsInEnvLayersTable)
    clusterMins = matrix (0, nrow=numClusters, ncol=numColsInEnvLayersTable)
    clusterMaxs = matrix (0, nrow=numClusters, ncol=numColsInEnvLayersTable)
    
    clusterSizes = rep (0, numClusters)
    clusterPctsOfImg = rep (0, numClusters)
    curClusterSuitabilities = rep (0.0, numPixelsPerImg)
    
    #-------------------------------------------------------------------------
    #  Compute summary statistics for each cluster.
    #  These will be used later, in the calculation of the distance metrics.
    #-------------------------------------------------------------------------
    
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
        clusterPctsOfImg  [curClusterTableIndex] =
            100 * (clusterSizes [curClusterTableIndex] / numPixelsPerImg)
        
        #    cat ("\n\nenvDataSrc [curClusterPixelLocs, ] = ", envDataSrc [curClusterPixelLocs, ])
        
        #------------------------------------------------------------------
        #  BTL - 2013.08.13
        #  Added this test because I found that the cbind was doing weird
        #  things when the sampled.locs.x.y had just one row in it but
        #  had not been created as a matrix. The cbind would treat the
        #  2 element vector of x and y as a column vector and replicate
        #  the species and split x and y onto separate rows, making a
        #  2x2 matrix instead of a 1 row x 3 column matrix.
        #  Making it explicit here that that sampled.locs.x.y is to be
        #  treated as a matrix instead of a vector fixed the problem.
        #------------------------------------------------------------------
        
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
    
    #------------------------------------------------
        
    distVecs = matrix (0, nrow=numPixelsPerImg, ncol=numClusters)
    #cat ("\n>>>>>>>>>>>>>>>>>>>>>>>>>>  new distVec = ", distVec)
    
    numHistIntervals = 10
    sppClusterDistanceMapsDir = paste (sppGenOutputDir, "/", sep='')
    
    #-------------------------------------------------------------------------
    #  Build a suitability map for each cluster and write it to a .asc file.
    #-------------------------------------------------------------------------
    
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
        
        insideCurCluster = (clusterPixelValuesLayer == curClusterID)
        cat ("\ncurrent cluster size = ", sum (insideCurCluster))
        
        
        point2 = curClusterCenter
        #cat ("\npoint2 = ", point2)
        
        curSuitabilityImg = getClusterSuitabilities ()

        writeClusterSuitabilityFile (curSuitabilityImg, 
                                     sppClusterDistanceMapsDir, 
                                     curClusterTableIndex, 
                                     numImgRows, numImgCols,
                                     xllcorner = 2618380.652817,
                                     yllcorner = 2529528.47684,
                                     no.data.value = -9999,
                                     cellsize = 75, 
                                     trueProbDistSppFilenameBase)
        
        if (FALSE)
            {
            if (curClusterTableIndex > 1)
                {
                distDiff = sum(distVecs[,curClusterTableIndex] - distVecs[,curClusterTableIndex-1])
                cat ("\n\nFor curClusterTableIndex = ", curClusterTableIndex, ", distDiff = ", distDiff, "\n", sep='')
                }
            }        
        }  #  end - for all clusterIDs
    
    #---------------
    
    if (FALSE)
        {
        sppIDs = 0:(numClusters - 1)
        sppIDvsClusterID = cbind (sppIDs, clusterIDs, clusterSizes, clusterPctsOfImg)
        write.csv (sppIDvsClusterID,
                   paste (sppClusterDistanceMapsDir, "sppIDvsClusterIDvsClusterSizeAndPct.csv", sep=''),
                   row.names=FALSE)
        }  #  end if - FALSE
    
    #plot (1:numPixelsPerImg, distVecs[,1])
    #lines (distVecs [,1], lty=1)
    #lines (distVecs [,2], lty=2)
    ##plot (distVecs [,2], lty=1)
    ##lines (distVecs [,1], lty=2)
    ##lines (distVecs [,2], lty=1)
}


#===============================================================================

