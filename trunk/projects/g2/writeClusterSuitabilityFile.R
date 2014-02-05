#===============================================================================

#  source ("writeClusterSuitabilityFile.R")

#===============================================================================

#  History

#  2014 02 01 - BTL - Created.
#  Extracted from clusterReadingTest.R from guppy project and turned into 
#  a function.

#===============================================================================

writeClusterSuitabilityFile = function (curSuitabilityImg, 
                                        sppClusterDistanceMapsDir, 
                                        curClusterTableIndex, 
                                        numImgRows, numImgCols,
                                        xllcorner = 2618380.652817,
                                        yllcorner = 2529528.47684,
                                        no.data.value = -9999,
                                        cellsize = 75, 
                                        trueProbDistSppFilenameBase = "true.prob.dist.spp.")
    {
#     filenameRoot = paste (sppClusterDistanceMapsDir, 
#                           "spp.", 
#                           (curClusterTableIndex - 1), sep='')
    filenameRoot = paste (sppClusterDistanceMapsDir, 
                          trueProbDistSppFilenameBase, 
                          (curClusterTableIndex - 1), sep='')
    write.asc.file (curSuitabilityImg,
                    filenameRoot,
                    numImgRows, numImgCols,
                    xllcorner,
                    yllcorner,
                    no.data.value,
                    cellsize
                    ##                    , xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
                    ##                    , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
                    ##                    #  is not actually on the map.  It's just off the lower
                    ##                    #  left corner.
                    ##                    , no.data.value = -9999
                    ##                    , cellsize = 1
    )
    #                            xllcorner = 0.0,    	#  BTL - 2011.02.15 - Added.
    #                            yllcorner = 0.0,
    #                            no.data.value = 0,      #  BTL - 2011.02.13 - Added.
    #							cellsize = 1			#  BTL - 2011.02.15 - Added.
    #                            )
    
    #----------------------------------
    
    if (FALSE)
        {
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
        
        }  #  end if - FALSE
    
    }

#===============================================================================

