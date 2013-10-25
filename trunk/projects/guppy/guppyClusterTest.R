#===============================================================================

                    #  GuppyClusterTest.R

#===============================================================================

library (cluster)

source ('read.R')
source ('w.R')

    #----------------
    #  user options
    #----------------

    #  I was making scaling of input features optional, but when I removed
    #  scaling, it all crashed with the following error messages:
    #
    #            Starting hclust single...
    #
    #            Starting hclust complete...
    #
    #            Starting hclust average...
    #
    #            Starting divisive...
    #            Error in plot.window(...) : need finite 'xlim' values
    #            In addition: Warning message:
    #                In sqrt(detA * pmax(0, yl2 - y^2)) : NaNs produced
    #
    #  So, for now, I'm going to leave the "if" statements in place but
    #  set scaleInputs to TRUE.
    #
    #  GENERAL QUESTION (FOR ML BOOK TOO):
    #  How do scaling and PCA interact?
    #  Do you need to scale before doing PCA?
    #  Does it change the results of PCA if you do or don't scale beforehand?
    #  Does it make any sense to scale afterwards?
    #  Is there an analytical answer to all this?
    #  I don't think I've seen it discussed in a book, but I need to go back
    #  and look to be sure...
scaleInputs = TRUE  #  DO NOT CHANGE THIS VALUE FOR NOW.  SEE COMMENT ABOVE.

#dataSrc = "fractalData"
#imgFileType = "pgm"

dataSrc = "mattData"
imgFileType = "asc"

numClusters = 15
maxNumPixelsToCluster = 500

randomSeed = 12



    #-------------------
    #  initializations
    #-------------------

set.seed (randomSeed)

cat ("\n\n")

imgFileType = NULL
numImgRows = NULL
numImgCols = NULL
imgSrcDir = NULL
imgFileNames = NULL
asciiImgFileNameRoots = NULL
numEnvLayers = NULL


if (dataSrc == "fractalData")
    {
    cat ("\n\nInitializing fractalData options...")

    imgFileType = "pgm"

    numImgRows = 256
    numImgCols = 256

    imgSrcDir = '/Users/Bill/tzar/outputdata/Guppy/default_runset/201_Scen_1/MaxentEnvLayers/'
    imgFileNames = c("e04_H03_27.pgm",
                     "e05_H03_27.pgm",
                     "e06_H01_33.pgm",
                     "e07_H03_57.pgm",
                     "e00_H07_79.pgm",
                     "e01_H05_52.pgm",
                     "e02_H04_100.pgm",
                     "e03_H03_15.pgm"
                    )

    numEnvLayers = length (imgFileNames)
    }

cat ("\n\nimgFileType = '", imgFileType, "'")


if (dataSrc == "mattData")
    {
    cat ("\n\nInitializing mattData options...")

    imgFileType = "asc"

    numImgRows = 512
    numImgCols = 512

#    imgSrcDir = "/Users/Bill/Downloads/environment.MattClusteringData.2013.08.29/"
    imgSrcDir = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloEnvVars/"

    asciiImgFileNameRoots = c("aniso_heat",
                                "evap_jan",
                                "evap_jul",
                                "insolation",
                                "max_temp",
                                "min_temp",
                                "modis_evi",
                                "modis_mir",
                                "ndmi",
                                "pottassium",
                              #####  "raindays_jan",
                              #####  "raindays_jul",
                              #####  "rainfall_jan",
                              #####  "rainfall_jul",
                                "thorium",
                                "twi_topocrop",
                                "vert_major",
                                "vert_minor",
                                "vert_saline",
                                "vis_sky"
                            )

    numEnvLayers = length (asciiImgFileNameRoots)
    }



numPixelsPerImg = numImgRows * numImgCols
numRecordsToCluster = min (maxNumPixelsToCluster, numPixelsPerImg)
numNonEnvDataCols = 3    #  1 col for IDs and 2 cols for x,y
numColsInEnvLayersTable = numEnvLayers + 3

combinedEnvLayersTable = matrix (0, nrow=numPixelsPerImg, ncol=numColsInEnvLayersTable, byrow=TRUE)
cat ("\n\ndim (combinedEnvLayersTable) = ", dim (combinedEnvLayersTable), "\n\n")
idColIdx = 1
#combinedEnvLayersTable [,idColIdx] = 1:numPixelsPerImg

    #--------------------------------------------------------------------------
    #  Build x and y values for each selected pixel record.
    #  Need to replace this section with a call to the function that computes
    #  the x,y locations for building maxent files, but this works for now
    #  since it just has to get things close together.
    #--------------------------------------------------------------------------

#numPixelsInImg = 12
#numImgRows = 3
#numImgCols = 4
y = ((0:(numPixelsPerImg - 1)) %/% numImgRows) + 1
x = 1:numPixelsPerImg %% numImgCols
    #  Modulo operator leaves the last column of each row set to 0 instead of
    #  set to the last column number, i.e., numImgCols, so replace the 0 in
    #  each row's y value
for (kkk in 1:numPixelsPerImg) { if (x[kkk] == 0) x[kkk] = numImgCols }

cat ("\n\nlength (combinedEnvLayersTable [,2]) = ", length (combinedEnvLayersTable [,2]))
cat ("\n    length (x) = ", length (x))
cat ("\nlength (combinedEnvLayersTable [,3]) = ", length (combinedEnvLayersTable [,3]))
cat ("\n    length (y) = ", length (y))
combinedEnvLayersTable [,2] = x
combinedEnvLayersTable [,3] = y

    #------------------------------------------------
    #  Load all of the data layers to be clustered.
    #------------------------------------------------

curImgFileIdx = 0
firstNonXYCol = 4
for (curCol in firstNonXYCol:numColsInEnvLayersTable)
    {
    curImgFileIdx = curImgFileIdx + 1
    cat ('\n\nAbout to test whether imgFileType == "pgm"...')

    if (imgFileType == "pgm")
        {
            "PGM input images"
        curImgFileFullPath = paste (imgSrcDir, imgFileNames [curImgFileIdx], sep='')
        curEnvLayer = get.img.matrix.from.pnm (curImgFileFullPath)
        } else if (imgFileType == "asc")
        {
            "ASC input images"
        curEnvLayer = read.asc.file.to.matrix (asciiImgFileNameRoots [curImgFileIdx], imgSrcDir)
        } else
        {
            "Unknown input images"
        cat ("\n\nFATAL ERROR:  Unknown input image file type = '", imgFileType, "'.\n\n")
        quit()
        }

    #curEnvLayer = matrix (sample (0:255, numPixelsPerImg, replace=TRUE), nrow = numImgRows, ncol=numImgCols)
    #curEnvLayer = get.img.matrix.from.pnm ('/Users/Bill/tzar/outputdata/Guppy/default_runset/201_Scen_1/MaxentEnvLayers/e04_H03_27.pgm')

    cat ("\n\ndim (curEnvLayer) = ", dim (curEnvLayer), "\n\n")
#    print (curEnvLayer)

#    cat ("\n\ncombinedEnvLayersTable [,curCol] = \n")
#    print (combinedEnvLayersTable [,curCol])

#    cat ("\n\nas.vector (t(curEnvLayer)) = \n")
#    print (as.vector (t(curEnvLayer)))

    combinedEnvLayersTable [,curCol] = as.vector (t(curEnvLayer))
#    cat ("\n\n")
#    print (combinedEnvLayersTable)
    }

id.col <- 1
##data <- data [order (data [ , id.col]), ]

##dataPointIDs <- data [ , id.col]
##rownames (data) <- dataPointIDs
#data <- data [ , -id.col]

combinedEnvLayersTable = combinedEnvLayersTable [ , -id.col]

if (scaleInputs)
    combinedEnvLayersTable = scale (combinedEnvLayersTable)

    #----------------------------------------------------------------------
    #  Draw the subsample of records to be clustered from the full set of
    #  pixels.
    #----------------------------------------------------------------------

idsOfRecordsToCluster = sample (1:numPixelsPerImg, numRecordsToCluster, replace=FALSE)#clusterInputTable =
#cat ("\nidsOfRecordsToCluster = ", idsOfRecordsToCluster, "\n")

recordsToCluster = combinedEnvLayersTable [idsOfRecordsToCluster,]
#cat ("\n\nrecordsToCluster = \n")
#print (recordsToCluster)

    #------------------------------------------------------------------------
    #  Choose initial cluster centers.
    #  I was initially trying to choose them as corners of the space,
    #  k-means didn't like those and threw some kind of error message
    #  that I can't remember at the moment, so I'm not doing this anymore.
    #  At some point though, I may want to replace this logic so I'll leave
    #  it here as a reminder.
    #------------------------------------------------------------------------

if (FALSE)
    {
    initialClusterCenters =
        matrix (0, nrow=numClusters, ncol=numColsInEnvLayersTable, byrow=TRUE)
    cat ("\n\ndim (initialClusterCenters) = ", dim (initialClusterCenters), "\n\n")
    cat ("\n")

    curCol = numNonEnvDataCols+1
    for (curRow in 1:min(numClusters,(numColsInEnvLayersTable-numNonEnvDataCols)))
        {
        cat ("\ncurRow = ", curRow, ", curCol = ", curCol, sep='')

        initialClusterCenters [curRow,curCol] = 0.5
        curCol = curCol + 1
        }
    print (initialClusterCenters)
    }

    #-------------------------
    #  Cluster with k-means.
    #-------------------------

cat("\nStarting kmeans...\n");
clusterSet = kmeans (recordsToCluster, numClusters)
#clusterSet = kmeans (recordsToCluster, initialClusterCenters)

print (clusterSet)
cat ("\n\n>>>>>>>>>>> class(clusterSet$centers) = ", class(clusterSet$centers), "\n\n")
print (clusterSet$centers)

original.data.distances <- daisy (recordsToCluster);
data.distances <- original.data.distances;

data.clus <- clusterSet$cluster    	#  If you don't do this, you get error msg...
clusplot (data.distances,
          data.clus,
          diss = TRUE,
          main = 'kmeans results',
          asp = 1,
          col.p = data.clus,
          labels = 4);  # color points and label ellipses
#          labels = 5);  # color points and label ellipses and identify pts

#=====================
#=====================
#=====================
#=====================
#=====================
#=====================
#=====================
vecSquared = function (aVector)
    {
    curSumSquares = 0
    for (curIdx in firstNonXYCol:length(aVector))
        {
        #cat ("\n    curIdx = ", curIdx)
        curSumSquares = curSumSquares + (aVector [curIdx] ^ 2)
        #cat (", curSumSquares = ", curSumSquares)
        }
    #cat ("\nAT END OF vecSquared()")
    return (curSumSquares)
    }

sumSquaredDist = function (point1, point2)
    {
    #cat ("\n\nIn eucDist, point1 = ", point1, ", and point2 = ", point2)
    #cat ("\n\nabout to sqrt(vecSquared(point1-point2))")
    #cat ("\n    point1 = ", point1)
    #cat ("\n    point2 = ", point2)
    #cat ("\n")
    vs = vecSquared (point1 - point2)
    #cat ("\nvs = ", vs)
    retValue = vs
#    retValue = sqrt (vs)
    #cat ("\nretValue = ", retValue)

    return (retValue)
    }

eucDist = function (point1, point2)
    {
    return (sqrt (sumSquaredDist (point1, point2)))
    }

distVecs = matrix (0, nrow=numPixelsPerImg, ncol=numClusters)
#cat ("\n>>>>>>>>>>>>>>>>>>>>>>>>>>  new distVec = ", distVec)

numHistIntervals = 10
curClusterID = 1

for (curClusterID in 1:numClusters)
    {
    curClusterCenter = clusterSet$centers[curClusterID,]
    cat ("\n\n------------------\ncurClusterCenter = ", curClusterCenter, "\n------------------\n\n")

    for (curRow in 1:numPixelsPerImg)
        {
        #cat ("\nLOOP START: curRow = ", curRow)
        point1 = combinedEnvLayersTable [curRow,]
        #cat ("\npoint1 = ", point1)
        point2 = curClusterCenter
        #cat ("\npoint2 = ", point2)
        #ed = eucDist (point1, point2)
        #cat ("\ned = ", ed)
        #cat ("\nLOOP END: curRow = ", curRow, ", length (distVec) = ", length(distVec))
            #  Using Euclidean distance doesn't seem to give as much
            #  distance separation in the output images as using the
            #  square of the Euclidean distance (i.e., just don't take the
            #  square root of the squared sums), so I'm going to try the
            #  latter for now.
            #  BTL - 2013.08.23
#        distVecs [curRow, curClusterID] = eucDist (point1, point2)
        distVecs [curRow, curClusterID] = sumSquaredDist (point1, point2)
        }
    #cat ("\n\ndistVecs = \n")
    #print (distVecs)
    #cat ("\n\n")
    maxDist = max (distVecs [,curClusterID]) + 0.5

    #histIntervalLength = 0.1
    histIntervalLength = maxDist/numHistIntervals

    #histTop = 1.0
    histTop = (histIntervalLength * numHistIntervals) + 0.1

    cat ("\n\nShow histogram for distances to cluster ", curClusterID, sep='')
    cat ("\n    numHistIntervals = ", numHistIntervals, sep='')
    cat ("\n    maxDist = ", maxDist, sep='')
    cat ("\n    histIntervalLength = ", histIntervalLength, sep='')
    cat ("\n    histTop = ", histTop, sep='')
    hist (distVecs[,curClusterID], breaks=seq(0,histTop,histIntervalLength),
          main = paste ("Distance hist for cluster", curClusterID))
    curDir = "./"
    curDistImg = matrix (distVecs[,curClusterID], nrow=numImgRows, ncol=numImgCols, byrow=TRUE)
    write.pgm.file (curDistImg,
                    paste (curDir, "distToCluster.", curClusterID, sep=''),
                    numImgRows, numImgCols)

    if (curClusterID > 1)
        {
        distDiff = sum(distVecs[,curClusterID] - distVecs[,curClusterID-1])
        cat ("\n\nFor curClusterID = ", curClusterID, ", distDiff = ", distDiff, "\n", sep='')
        }

    }


#plot (1:numPixelsPerImg, distVecs[,1])
#lines (distVecs [,1], lty=1)
#lines (distVecs [,2], lty=2)
##plot (distVecs [,2], lty=1)
##lines (distVecs [,1], lty=2)
##lines (distVecs [,2], lty=1)

#===============================================================================

