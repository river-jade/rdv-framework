

library (cluster)

source ('read.R')
source ('w.R')

randomSeed = 1
set.seed (randomSeed)

numImgRows = 256
numImgCols = 256
numPixelsPerImg = numImgRows * numImgCols

numRecordsToCluster = 25000

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

#numEnvLayers = 4
numEnvLayers = length (imgFileNames)

numNonEnvDataCols = 3    #  1 col for IDs and 2 cols for x,y
numColsInEnvLayersTable = numEnvLayers + 3

combinedEnvLayersTable = matrix (0, nrow=numPixelsPerImg, ncol=numColsInEnvLayersTable, byrow=TRUE)
cat ("\n\ndim (combinedEnvLayersTable) = ", dim (combinedEnvLayersTable), "\n\n")
#print (combinedEnvLayersTable)


idColIdx = 1
#combinedEnvLayersTable [,idColIdx] = 1:numPixelsPerImg


curImgFileIdx = 0
firstNonXYCol = 4
for (curCol in firstNonXYCol:numColsInEnvLayersTable)
    {
    curImgFileIdx = curImgFileIdx + 1
    curImgFileFullPath = paste (imgSrcDir, imgFileNames [curImgFileIdx], sep='')
    curEnvLayer = get.img.matrix.from.pnm (curImgFileFullPath)

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

idsOfRecordsToCluster = sample (1:numPixelsPerImg, numRecordsToCluster, replace=FALSE)#clusterInputTable =
#cat ("\nidsOfRecordsToCluster = ", idsOfRecordsToCluster, "\n")

recordsToCluster = combinedEnvLayersTable [idsOfRecordsToCluster,]
#cat ("\n\nrecordsToCluster = \n")
#print (recordsToCluster)

cat ("\n\n")
numClusters = 5

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

eucDist = function (point1, point2)
    {
    #cat ("\n\nIn eucDist, point1 = ", point1, ", and point2 = ", point2)
    #cat ("\n\nabout to sqrt(vecSquared(point1-point2))")
    #cat ("\n    point1 = ", point1)
    #cat ("\n    point2 = ", point2)
    #cat ("\n")
    vs = vecSquared (point1 - point2)
    #cat ("\nvs = ", vs)
    retValue = sqrt (vs)
    #cat ("\nretValue = ", retValue)

    return (retValue)
    }


distVecs = matrix (0, nrow=numPixelsPerImg, ncol=numClusters)
#cat ("\n>>>>>>>>>>>>>>>>>>>>>>>>>>  new distVec = ", distVec)

numHistIntervals = 10
clusterID = 1

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
        ed = eucDist (point1, point2)
        #cat ("\ned = ", ed)
        #cat ("\nLOOP END: curRow = ", curRow, ", length (distVec) = ", length(distVec))
        distVecs [curRow, curClusterID] = eucDist (point1, point2)
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
    hist (distVecs[,clusterID], breaks=seq(0,histTop,histIntervalLength),
          main = paste ("Distance hist for cluster", curClusterID))
    curDir = "./"
    curDistImg = matrix (distVecs[,clusterID], nrow=numImgRows, ncol=numImgCols, byrow=TRUE)
    write.pgm.file (curDistImg,
                    paste (curDir, "distToCluster.", curClusterID, sep=''),
                    numImgRows, numImgCols)
    }


#plot (1:numPixelsPerImg, distVecs[,1])
#lines (distVecs [,1], lty=1)
#lines (distVecs [,2], lty=2)
##plot (distVecs [,2], lty=1)
##lines (distVecs [,1], lty=2)
##lines (distVecs [,2], lty=1)

if (FALSE)
{
imgSrcDir = '/Users/Bill/tzar/outputdata/Guppy/default_runset/201_Scen_1/MaxentEnvLayers/'
#testLayer = get.img.matrix.from.pnm ('/Users/Bill/tzar/outputdata/Guppy/default_runset/201_Scen_1/MaxentEnvLayers/e04_H03_27.pgm')

curImgFileIdx = 1
curImgFileFullPath = paste (imgSrcDir, imgFileNames [curImgFileIdx], sep='')
curEnvLayer = get.img.matrix.from.pnm (curImgFileFullPath)
nr = dim(curEnvLayer)[1]
nc = dim(curEnvLayer)[2]
numPixelsPerImg = nr * nc


numHistIntervals = 10
clusterID = 1
maxDist = max (distVecs [,clusterID])
histIntervalLength = ceiling (maxDist/numHistIntervals)
histTop = histIntervalLength * numHistIntervals

hist(distVecs[,clusterID], breaks=seq.int(0,histTop,histIntervalLength))

numImgRows = 3
numImgCols = 4
y = matrix (1:12,nrow=3,ncol=4,byrow=TRUE)
print (y)
ty = as.vector(t(y))
print (ty)
x = matrix (ty,nrow=numImgRows,ncol=numImgCols,byrow=TRUE)
print (x)

for (kkk in 5:3)
    print (kkk)
}
