#===============================================================================

#  source ("getClusterSuitabilities.R")

#===============================================================================

#  History

#  2014 02 01 - BTL - Created.
#  Extracted from clusterReadingTest.R from guppy project and turned into 
#  a function.

#===============================================================================

source (paste0 (g2ProjectRsrcDirWithSlash, 'getClusterDistVecs.R'))

#===============================================================================

getClusterSuitabilities = function (numPixelsPerImg, 
                                    envDataSrc, 
                                    curClusterTableIndex, 
                                    distVecs, 
                                    curClusterCenter, 
                                    curClusterMin, 
                                    curClusterMax, 
                                    insideCurCluster, 
                                    numHistIntervals, 
                                    histIntervalLength, 
                                    curClusterSuitabilities, 
                                    curClusterID, 
                                    clusterSizes, 
                                    clusterPctsOfImg, 
                                    sppGenOutputDirWithSlash)
    {
        #----------------------------------
        #  NOTE: In the grey scale .asc and .pgm images that are written out,
        #        black shows small values and white shows large values, which
        #        means that colors for good and bad are reversed in distance
        #        maps compared to suitability maps.
        #        For suitability, black is bad and white is good.
        #        For distance, black is close to feature center (i.e., suitable)
        #        and white is large distance from feature center (i.e.,
        #        not suitable.)
        #----------------------------------
        #  *** Need to write those out to the tzar output area.
    
    distVecs = getClusterDistVecs (numPixelsPerImg, 
                                   envDataSrc, 
                                   curClusterTableIndex, 
                                   distVecs, 
                                   curClusterCenter, 
                                   curClusterMin, curClusterMax, insideCurCluster, 
                                   numHistIntervals, histIntervalLength)
        
    curClusterDistVec = distVecs [,curClusterTableIndex]
    
    finiteRange = range (curClusterDistVec, finite = TRUE)
    curMaxDistValue = finiteRange [2]
    epsilonValue = 0.25 * curMaxDistValue    #  to give a little space above 0
    curMaxPlusEpsilonValue = curMaxDistValue + epsilonValue
    
    curClusterSuitabilities [] = 0.0
    
    if (FALSE)    #  this should be irrelevant now
        {
        pixelIsInCurCluster = (clusterPixelValuesLayer == curClusterID)
        curInClusterPixelLocs = which (pixelIsInCurCluster)
        curClusterSuitabilities [curInClusterPixelLocs] = curMaxPlusEpsilonValue - curClusterDistVec [curInClusterPixelLocs]
        }
    
    #  Replacement code for the if FALSE that tested for pixel in cluster...
    finiteValueLocs = which (is.finite (curClusterDistVec))
    curClusterSuitabilities [finiteValueLocs] = curMaxPlusEpsilonValue - curClusterDistVec [finiteValueLocs]
    
    curClusterSuitabilities = curClusterSuitabilities / max (curClusterSuitabilities)
    
    if (smoothSuitabilitiesWithGaussian)
        curClusterSuitabilities = gaussian (curClusterSuitabilities, gaussianSuitabilitySmoothingMean, gaussianSuitabilitySmoothingSD)
    
    curSuitabilityImg = matrix (curClusterSuitabilities, nrow=numImgRows, ncol=numImgCols, byrow=TRUE)
    
    maxHistSuit = 1.1* max (curClusterSuitabilities)
    
    #histIntervalLength = 0.1
    histIntervalLength = maxHistSuit / numHistIntervals
    
    #histTop = 1.0
    histTop = (histIntervalLength * numHistIntervals) + 0.1
    
    cat ("\n\nShow histogram for distances to cluster ", curClusterTableIndex, sep='')
    cat ("\n    numHistIntervals = ", numHistIntervals, sep='')
    cat ("\n    maxHistSuit = ", maxHistSuit, sep='')
    cat ("\n    histIntervalLength = ", histIntervalLength, sep='')
    cat ("\n    histTop = ", histTop, sep='')
    
    curSppNum = curClusterTableIndex - 1
    histTitle = paste ("SUITABILITY hist for spp ", curSppNum, 
                       ", cluster ", curClusterID,
                       "\nsize ", clusterSizes [curClusterTableIndex],
                       ", ", clusterPctsOfImg [curClusterTableIndex],
                       "% of img", sep='')
    if ((histTop > 0)  & (histIntervalLength > 0))
        {
        histogramFileName = paste0 (sppGenOutputDirWithSlash, 
                                    "suitabilityHistogram.spp.", curSppNum, 
                                    ".cluster.", curClusterID, ".pdf")
            #  Plot histogram on screen first.
        hist (curClusterSuitabilities, 
              breaks=seq (0, histTop, histIntervalLength), 
              main = histTitle)
        
            #  Save same histogram to file.
        pdf (histogramFileName)
        hist (curClusterSuitabilities, 
              breaks=seq (0, histTop, histIntervalLength), 
              main = histTitle)
        dev.off()
        
        } else
        {
        cat ("\n\nNot showing histogram for \n\n    '", histTitle, "'",
             "\nbecause histTop and bottom both equal 0 (e.g., when ",
             "the cluster only has one point.\n\n", sep='')
        }
    
    return (curSuitabilityImg)
    }
