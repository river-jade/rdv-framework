#===============================================================================

#  source ("getEnvDataSrc.R")

#===============================================================================

#  History

#  2014 02 01 - BTL - Created.
#  Extracted from clusterReadingTest.R from guppy project and turned into 
#  a function.

#===============================================================================

getEnvDataSrc = function (envLayersDir, numImgRows, numImgCols)
    {
    #-------------------
    #  initializations
    #-------------------
    
    imgFileType           = NULL
#    numImgRows            = NULL
#    numImgCols            = NULL
    imgSrcDir             = NULL
    imgFileNames          = NULL
    asciiImgFileNameRoots = NULL
    numEnvLayers          = NULL
    imgFileType           = "asc"
    
    
    if (dataSrc == "mattData")
        {
        imgFileType = "asc"
#        numImgRows  = 512
#        numImgCols  = 512
        imgSrcDir   = envLayersDir
            #"/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloEnvVars_Originals/"
        
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
    
    #-------------------------------------
    
    rownames (combinedEnvLayersTable) = arrayIdxBase:numPixelsPerImg
    
    if (scaleInputs)
        combinedEnvLayersTable = scale (combinedEnvLayersTable)
    
    #-------------------------------------
    
    return (combinedEnvLayersTable)
    }

#===============================================================================

