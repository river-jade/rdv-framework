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

getTrueSppDist = 
    function (trueSppSourceType, 
              
              envLayersWorkingDirWithSlash, 
              numImgRows, numImgCols, 
              
              ascFileHeaderAsStrVals, 
              
              sppGenOutputDirWithSlash, 
              asciiImgFileNameRoots, scaleInputs, 
              imgFileType, numNonEnvDataCols, 
              clusterFilePath, clusterFileNameStem, 
              arrayIdxBase = 1, 
              
              sppLibDir=""    #  new argument 2014 06 05 - BTL
             )
    {
    numSpp = NA
        
    #--------------------------------------------------------
    if (trueSppSourceType == CONST_sppSource_sppLibraryLocal)
    #--------------------------------------------------------    
        {
        cat ("\n\nAbout to call getTrueSppDistFromSppLibraryLocal().")
            quit ("\n\ngetTrueSppDistFromSppLibraryLocal() not implemented yet.\n\n")
#         numSpp = getTrueSppDistFromSppLibraryLocal (
#                                         envLayersWorkingDirWithSlash, 
#                                         numImgRows, numImgCols, 
#                                         
#                                         ascFileHeaderAsStrVals, 
#                                         
#                                         sppGenOutputDirWithSlash, 
#                                         asciiImgFileNameRoots, scaleInputs, 
#                                         imgFileType, numNonEnvDataCols, 
#                                         clusterFilePath, clusterFileNameStem, 
#                                         arrayIdxBase
#                                         )        
        #--------------------------------------------------------------
        } else if (trueSppSourceType == CONST_sppSource_sppLibraryTzar)
        #--------------------------------------------------------------    
        {
        cat ("\n\nAbout to call getTrueSppDistFromSppLibraryTzar().")
            #        quit ("\n\ngetTrueSppDistFromSppLibraryTzar() not implemented yet.\n\n")
        numSpp = getTrueSppDistFromSppLibraryTzar (
                                        envLayersWorkingDirWithSlash, 
                                        numImgRows, numImgCols, 
                                        
                                        ascFileHeaderAsStrVals, 
                                        
                                        sppGenOutputDirWithSlash, 
                                        asciiImgFileNameRoots, scaleInputs, 
                                        imgFileType, numNonEnvDataCols, 
                                        clusterFilePath, clusterFileNameStem, 
                                        arrayIdxBase, 
                                        
                                        sppLibDir    #  new argument 2014 06 05 - BTL                                        
                                        )        
        #-------------------------------------------------------------------            
        } else if (trueSppSourceType == CONST_sppSource_sppLibraryRemoteURL)
        #-------------------------------------------------------------------
        {
        cat ("\n\nAbout to call getTrueSppDistFromSppLibraryRemoteURL().")
            quit ("\n\ngetTrueSppDistFromSppLibraryRemoteURL() not implemented yet.\n\n")
#         numSpp = getTrueSppDistFromSppLibraryRemoteURL (
#                                         envLayersWorkingDirWithSlash, 
#                                         numImgRows, numImgCols, 
#                                         
#                                         ascFileHeaderAsStrVals, 
#                                         
#                                         sppGenOutputDirWithSlash, 
#                                         asciiImgFileNameRoots, scaleInputs, 
#                                         imgFileType, numNonEnvDataCols, 
#                                         clusterFilePath, clusterFileNameStem, 
#                                         arrayIdxBase
#                                         )        
        #----------------------------------------------------------------            
        } else if (trueSppSourceType == CONST_sppSource_existingClusters)
        #----------------------------------------------------------------    
        {
        cat ("\n\nAbout to call getTrueSppDistExistingClusters().")
            numSpp = 
            getTrueSppDistFromExistingClusters (
                                        envLayersWorkingDirWithSlash, 
                                        numImgRows, numImgCols, 
                                          
                                        ascFileHeaderAsStrVals, 
                                          
                                        sppGenOutputDirWithSlash, 
                                        asciiImgFileNameRoots, scaleInputs, 
                                        imgFileType, numNonEnvDataCols, 
                                        clusterFilePath, clusterFileNameStem, 
                                        arrayIdxBase
                                        )
        #----------------------------------------------------------------            
        } else 
        #----------------------------------------------------------------            
        {
        quit (paste0 ("\n\ngetTrueSppDist():  Unknown species source type = ", 
                      trueSppSourceType, "\n\n"))
        }
    
    return (numSpp)
    }
        
#-------------------------------------------------------------------------------

getTrueSppDistFromSppLibraryLocal = 
    function (envLayersWorkingDirWithSlash, 
             numImgRows, numImgCols, 
             
             ascFileHeaderAsStrVals, 
             
             sppGenOutputDirWithSlash, 
             asciiImgFileNameRoots, scaleInputs, 
             imgFileType, numNonEnvDataCols, 
             clusterFilePath, clusterFileNameStem, 
             arrayIdxBase
            )
    {
    numSpp = NA
    
    cat ("\n\nIn getTrueSppDistFromSppLibraryLocal().")
    cat ("\n    dummy version...")
    
    return (numSpp)
    }

#-------------------------------------------------------------------------------

    #  Remove trailing slash if there is one.
removeTrailingSlash = function (aPath)
    {
    aPathNoSlash = aPath
    lengthOfString = nchar (aPath)
    lastChar = substr (aPath, lengthOfString, lengthOfString)
    if (lastChar == '/')  aPathNoSlash = strtrim (aPath, lengthOfString-1)
    return (aPathNoSlash)
    }

#----------

getTrueSppDistFromSppLibraryTzar = 
    function (envLayersWorkingDirWithSlash, 
              numImgRows, numImgCols, 
              
              ascFileHeaderAsStrVals, 
              
              sppGenOutputDirWithSlash, 
              asciiImgFileNameRoots, scaleInputs, 
              imgFileType, numNonEnvDataCols, 
              clusterFilePath, clusterFileNameStem, 
              arrayIdxBase, 
              
              sppLibDir
    )
    {
        numSpp = NA
        
#         cat ("\n\nIn getTrueSppDistFromSppLibraryTzar().")
#         cat ("\n    dummy version...")
        
        #---------------------------------------------------------
        #  Get species layers from a library downloaded by tzar.
        #---------------------------------------------------------
    
sppLayersWorkingDir = removeTrailingSlash (sppGenOutputDirWithSlash)

sppFileNames = getEnvFiles (sppLibDir, sppLayersWorkingDir, 
                            overwrite=TRUE)

cat ("\n\nspp layers just after getEnvFiles = \n")
print (sppFileNames)

numSpp = length (sppFileNames)    
cat ("\n\nnumSpp  = \n", numSpp, sep='')

stop ("\n\nTemporary quit after trying to read spp library files.\n\n")
#quit(save="no")

return (numSpp)

# 
# #--------------
# 
# b01211027b-02:g2 Bill$ grep -in envLayersWorkingDirWithSlash *.R
# 
# initializeG2options.R:162:envLayersWorkingDirWithSlash = paste0 (envLayersWorkingDir, dir.slash)
# initializeG2options.R:164:cat ("\n\nenvLayersWorkingDirWithSlash = '",
# initializeG2options.R:165:     envLayersWorkingDirWithSlash, "'\n\n", sep='')
# initializeG2options.R:556:curFullMaxentEnvLayersDirName = envLayersWorkingDirWithSlash
# 
# lengthOfString = nchar (envLayersWorkingDirWithSlash)
# lastChar = substr (envLayersWorkingDirWithSlash, lengthOfString, lengthOfString)
# if (lastChar == '/')
#     envLayersWorkingDirNoSlash = sub_str (envLayersWorkingDirWithSlash, 
#                                           1, lengthOfString - 1)
# 
# envLayersWorkingDirNoSlash = removeTrailingSlash (envLayersWorkingDirWithSlash)
# 
# b01211027b-02:g2 Bill$ 
#      
# 
# #--------------
# 
# envLayersSrcDir = parameters$envLayersSrcDir.linux
# clusterFilePath = parameters$clusterFilePath.linux
# 
# envLayersWorkingDirName = parameters$envLayersWorkingDirName
# 
# cat ("\n\nenvLayersWorkingDirName = '",
#      envLayersWorkingDirName, "'\n\n", sep='')
# 
# envLayersWorkingDir = paste0 (curFullTzarExpOutputDirRootWithSlash,
#                               envLayersWorkingDirName)
# envLayersWorkingDirWithSlash = paste0 (envLayersWorkingDir, dir.slash)
# 
# cat ("\n\nenvLayersWorkingDirWithSlash = '",
#      envLayersWorkingDirWithSlash, "'\n\n", sep='')
# 
# ascFileHeaderAsNumAndStr =
#     #    getAscFileHeaderAsNamedList (paste0 (envLayersSrcDir,
#     getAscFileHeaderAsNamedList (paste0 (envLayersSrcDir, dir.slash,
#                                          asciiImgFileNameRoots [arrayIdxBase],
#                                          ".asc"))
# curFullMaxentEnvLayersDirName = envLayersWorkingDirWithSlash
# 
# #----------------
 
    }

#-------------------------------------------------------------------------------

getTrueSppDistFromSppLibraryRemoteURL = 
    function (envLayersWorkingDirWithSlash, 
              numImgRows, numImgCols, 
              
              ascFileHeaderAsStrVals, 
              
              sppGenOutputDirWithSlash, 
              asciiImgFileNameRoots, scaleInputs, 
              imgFileType, numNonEnvDataCols, 
              clusterFilePath, clusterFileNameStem, 
              arrayIdxBase
            )
    {
    numSpp = NA
    
    cat ("\n\nIn getTrueSppDistFromSppLibraryRemote().")
    cat ("\n    dummy version...")

    #         useRemoteEnvDir = variables$PAR.useRemoteEnvDir
    #         cat ("\n\nvariables$PAR.useRemoteEnvDir = '", variables$PAR.useRemoteEnvDir, "'", sep='')
    #         cat ("\n\nuseRemoteEnvDir = '", useRemoteEnvDir, "'", sep='')
    #         
    #         cat ("\n\nvariables$PAR.remoteEnvDir = '", variables$PAR.remoteEnvDir, "'", sep='')
    #         cat ("\n\nvariables$PAR.localEnvDirMac = '", variables$PAR.localEnvDirMac, "'", sep='')
    #         cat ("\n\nvariables$PAR.localEnvDirWin = '", variables$PAR.localEnvDirWin, "'", sep='')
    #         
    #         #envLayersDir = "http://glass.eres.rmit.edu.au/tzar_input/guppy/AlexFractalData/H"
    #         envLayersDir = variables$PAR.remoteEnvDir
    #         
    #         if (!useRemoteEnvDir)
    #         {
    #             ##    	envLayersDir = variables$PAR.localEnvDir
    #             #envLayersDir = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H"
    #             
    #             if (current.os == "mingw32")
    #             {
    #                 envLayersDir = variables$PAR.localEnvDirWin
    #                 
    #             } else
    #             {
    #                 envLayersDir = variables$PAR.localEnvDirMac
    #             }
    #         }
    #         cat ("\n\nenvLayersDir = '", envLayersDir, "'", sep='')
    #         
    #         for (suffix in c(".asc", ".pgm"))   #
    #         {
    #             imgFileName = paste (imgFileRoot, suffix, sep='')
    #             fullImgFileDestPath = paste (cur.full.maxent.env.layers.dir.name, "/",
    #                                          eLayerFileNamePrefix, imgFileName, sep='')
    #             cat ("\n\nfullImgFileDestPath = '", fullImgFileDestPath,  "'", sep='')
    #             
    #             srcImgFileName = paste (imgFileRoot, fileSizeSuffix, suffix, sep='')
    #             srcFile = paste (envSrcDir, srcImgFileName, sep='')
    #             cat ("\nsrcFile = '", srcFile, "'")
    #             
    #             if (useRemoteEnvDir)
    #             {
    #                 err = try (download.file (srcFile, destfile = fullImgFileDestPath,
    #                                           quiet = TRUE),
    #                            silent = TRUE)
    #                 if (class (err) == "try-error")
    #                 {
    #                     #  you may be hitting the server too hard , so backoff and try again later.
    #                     Sys.sleep (5)  #  in seconds , adjust as necessary
    #                     try (download.file (srcFile,
    #                                         destfile = fullImgFileDestPath,
    #                                         quiet = TRUE),
    #                          silent = TRUE )
    #                 }
    #             }  else
    #             {
    #                 #  Copy file from local directory to fullImgFileDestPath
    #                 
    #                 file.copy (srcFile, fullImgFileDestPath)
    #                 
    #             }  #  end else - using local env dir files
    #             
    #             cat ("\n\nsuffix = '", suffix, "'\n", sep='')
    #             #			if (suffix == ".pnm")
    #             if (suffix == ".pgm")
    #             {
    #                 cat ("\n\nsuffix is .pnm so adding env.layer\n", sep='')
    #                 cat ("\nlength (env.layers) before = '", length(env.layers), sep='')
    #                 new.env.layer = get.img.matrix.from.pnm (fullImgFileDestPath)
    #                 cat ("\ndim (new.env.layer) before = '", dim (new.env.layer), sep='')
    #                 cat ("\n\nis.matrix(new.env.layer) in get.img.matrix.from.pnm = '", is.matrix(new.env.layer), "\n", sep='')
    #                 cat ("\n\nis.vector(new.env.layer) in get.img.matrix.from.pnm = '", is.vector(new.env.layer), "\n", sep='')
    #                 cat ("\n\nclass(new.env.layer) in get.img.matrix.from.pnm = '", class(new.env.layer), "\n", sep='')
    #                 
    #                 env.layers [[curEnvLayerIdx]]= new.env.layer
    #                 
    #                 cat ("\nlength (env.layers) AFTER = '", length(env.layers), sep='')
    #                 cat ("\n\nnew.env.layer [1:3,1:3] = \n", new.env.layer [1:3,1:3], "\n", sep='')    #  Echo a bit of the result...
    #                 for (row in 1:3)
    #                     for (col in 1:3)
    #                     {
    #                         cat ("\nnew.env.layer [", row, ", ", col, "] = ", new.env.layer[row,col], ", and class = ", class(new.env.layer[row,col]), sep='')
    #                     }
    #                 #	print (new.env.layer [1:3,1:3])    #  Echo a bit of the result...
    #                 
    #             }  #  end if - pnm file
    #         }  #  end for - suffixes
    
    return (numSpp)
    }

#-------------------------------------------------------------------------------

getTrueSppDistFromExistingClusters = 
    function (envLayersWorkingDirWithSlash, 
              numImgRows, numImgCols, 
              
              ascFileHeaderAsStrVals, 
              
              sppGenOutputDirWithSlash, 
              asciiImgFileNameRoots, scaleInputs, 
              imgFileType, numNonEnvDataCols, 
              clusterFilePath, clusterFileNameStem, 
              arrayIdxBase = 1
            )
    {        
        
    numSpp = NA
    
    cat ("\n\nIn getTrueSppDistFromExistingClusters().")
                
    numPixelsPerImg = numImgRows * numImgCols    
    numEnvLayers = length (asciiImgFileNameRoots)    
    numColsInEnvLayersTable = numEnvLayers + numNonEnvDataCols
    
    envDataSrc = getEnvDataSrc (envLayersWorkingDirWithSlash, 
                                numPixelsPerImg, 
                                asciiImgFileNameRoots, 
                                numEnvLayers, 
                                numColsInEnvLayersTable, 
                                scaleInputs, 
                                numNonEnvDataCols, 
                                imgFileType, 
                                arrayIdxBase)
    
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
    
    numSpp = numClusters
    
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
    sppClusterDistanceMapsDir = sppGenOutputDirWithSlash

        #-------------------------------------------------------------------------
        #  Build a suitability map for each cluster and write it to a .asc file.
        #-------------------------------------------------------------------------
       
        #------------------------------------------------
        #  Build a suitability map for each cluster and 
        #  write it to a .asc file.
        #------------------------------------------------
    
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
        
        
        ###  point2 = curClusterCenter  ###  BTL - 2014 02 05 - changed call to use curClusterCenter directly rather than renaming to point2
        #cat ("\npoint2 = ", point2)
        
        curSuitabilityImg = getClusterSuitabilities (numPixelsPerImg, 
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

#THIS IS WRONG.  NEED TO FIX IT SO THAT IT HAS THE CORRECT CORNER VALUES 
#INSTEAD OF THESE HARD-CODED VALUES.  NEED TO GET THE CORRECT VALUES WHEN 
#THE ENV LAYERS ARE READ IN OR WHEN THE CLUSTERS ARE READ IN.  ALL SHOULD 
#BE THE SAME.

        writeClusterSuitabilityFile (curSuitabilityImg, 
                                     sppClusterDistanceMapsDir, 
                                     curClusterTableIndex, 
                                     numImgRows, numImgCols,
                                     
                                     ascFileHeaderAsStrVals, 
                                     
#                                      xllcorner = 2618380.652817,
#                                      yllcorner = 2529528.47684,
#                                      no.data.value = -9999,
#                                      cellsize = 75, 
#                                      xllcorner,
#                                      yllcorner,
#                                      no.data.value,
#                                      cellsize, 
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

    #---------------

    return (numSpp)
    }


#===============================================================================

