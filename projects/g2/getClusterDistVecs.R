#===============================================================================

#  source ("getClusterDistVecs.R")

#===============================================================================

#  History

#  2014 02 01 - BTL - Created.
#  Extracted from clusterReadingTest.R from guppy project and turned into 
#  a function.

#===============================================================================

getClusterDistVecs = function ()
    {
        for (curRow in 1:numPixelsPerImg)
            {
            #cat ("\nLOOP START: curRow = ", curRow)
            
            point1 = envDataSrc [curRow,]
            #cat ("\npoint1 = ", point1)
            
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
                #            cat ("\ngaussianInverseWeightedDist (point1, point2, curClusterDeviation) = ", gaussianInverseWeightedDist (point1, point2, curClusterDeviation))
                cat ("\nenvelopeDist (point1, point2, curClusterMin, curClusterMax) = ", envelopeDist (point1, point2, curClusterMin, curClusterMax))
                
                cat ("\n\n")
                }
            
            distVecs [curRow, curClusterTableIndex] = distMeasure (point1, point2, curClusterMin, curClusterMax, insideCurCluster [curRow])
            
            #        distVecs [curRow, curClusterTableIndex] = sumSquaredDist (point1, point2)
            #        distVecs [curRow, curClusterTableIndex] = eucDist (point1, point2)
            
            
            #        distVecs [curRow, curClusterTableIndex] = envelopeDist (point1, point2, curClusterMin, curClusterMax)
            #        distVecs [curRow, curClusterTableIndex] = hardClusterDist (point1, point2, insideCurCluster [curRow])
            #        distVecs [curRow, curClusterTableIndex] = hardClusterDist_01only (point1, point2, insideCurCluster [curRow])
                        
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

        return (distVecs)
        
    }  #  end function

#===============================================================================

