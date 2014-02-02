#===============================================================================

#  source ("getTrueSppDistFromExistingClusters.R")

#===============================================================================

#  History

#  2014 02 01 - BTL - Created.
#  Extracted from clusterReadingTest.R from guppy project and turned into 
#  a function.

#===============================================================================

getTrueSppDistFromExistingClusters = function ()
{
    envDataSrc = getEnvDataSrc (envLayersDir, numImgRows, numImgCols)
    
    distVecs = matrix (0, nrow=numPixelsPerImg, ncol=numClusters)
    #cat ("\n>>>>>>>>>>>>>>>>>>>>>>>>>>  new distVec = ", distVec)
    
    numHistIntervals = 10
    #sppClusterDistanceMapsDir = "./SppClusterDistanceMapsTEST/"
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
        
        writeClusterSuitabilityFile ()
        
        if (FALSE)
        {
            if (curClusterTableIndex > 1)
            {
                distDiff = sum(distVecs[,curClusterTableIndex] - distVecs[,curClusterTableIndex-1])
                cat ("\n\nFor curClusterTableIndex = ", curClusterTableIndex, ", distDiff = ", distDiff, "\n", sep='')
            }
        }
        
        #if (curClusterTableIndex > 5)
        #    break
        
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

