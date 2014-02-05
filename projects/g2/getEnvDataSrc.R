#===============================================================================

#  source ("getEnvDataSrc.R")

#===============================================================================

#  History

#  2014 02 01 - BTL - Created.
#  Extracted from clusterReadingTest.R from guppy project and turned into 
#  a function.

#===============================================================================


getEnvDataSrc = function (envLayersWorkingDir, numPixelsPerImg, 
                          asciiImgFileNameRoots, scaleInputs, 
                          imgFileType = "asc", numNonEnvDataCols = 0
                        )
    {
        #-------------------
        #  initializations
        #-------------------
    
    numEnvLayers = length (asciiImgFileNameRoots)    
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
            curEnvLayer = 
                read.asc.file.to.matrix (asciiImgFileNameRoots [curImgFileIdx], 
                                         envLayersWorkingDir)
            
            } else
            {
            #  Unknown input images
            errMsg = 
                paste0 ("\n\nFATAL ERROR:  Unknown input image file type = '", 
                        imgFileType, "'.\n\n")
            stop (errMsg)
            }
        
        combinedEnvLayersTable [,curCol] = as.vector (t(curEnvLayer))        
        }
    
    #-------------------------------------
    
    rownames (combinedEnvLayersTable) = arrayIdxBase:numPixelsPerImg
    
    if (scaleInputs)
        combinedEnvLayersTable = scale (combinedEnvLayersTable)
    
    #-------------------------------------
    
    return (combinedEnvLayersTable)
    }

#===============================================================================

