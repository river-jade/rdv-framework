#===============================================================================

                #  guppyGenProbDistFromExistingClusters.R

#  History:

#   2013.11.29 - BTL
#   Cloned from guppyClusterTest.R.

#===============================================================================

#  options warn:
#    sets the handling of warning messages.

#    If warn is negative all warnings are ignored.

#    If warn is 0 (the default) warnings are stored until
#    the top–level function returns.
#    If 10 or fewer warnings were signalled they will be printed
#    otherwise a message saying how many were signalled.
#    An object called last.warning is created and can be printed
#    through the function warnings.

#    If warn is 1, warnings are printed as they occur.

#    If warn is 2 or larger all warnings are turned into errors.

#options (warn = -1)
options (warn = 0)
#options (warn = 1)
#options (warn = 2)

#-------------------------------------------------------------------------------

library (cluster)

source ('read.R')
source ('w.R')

#-------------------------------------------------------------------------------

#  Possible changes to make:

#       - Is there a bug here?  Am I including the IDs in the clustering too
#         i.e., column 1?

#       - Currently, clustering includes the x,y coordinates.
#         Not sure if that's always what you want to do, so try without.
#         Might want to include them in the clustering, but then remove
#         them (and the IDs if they're being included) when you do the
#         distance calculations.  That way, the distance calculations would
#         only be based on environmental niche.

#       - Currently not including 4 rainfall variables either.
#         Not sure why.

#       - Should probably change to the other principal components routine.

#       - May want to change the function that shapes the falloff in
#         distance from cluster center to get a faster falloff.
#         Could increase the distance exponent or replace the distance
#         measure with a gaussian or exponential in assigning a value to
#         be used as the probability.
#         Should also rephrase the function naming that way too so that it's
#         clear that distance is just a convenience as a way to shape.
#         Shaping is what it's really about.

#       - Currently using all variables in the clustering and pca calculations.
#         May want to choose subsets instead ("subspaces" in that paper on
#         nearest neighbor).  Could choose them randomly, or with some
#         ecological reasoning, or using the subspace method from that paper.
#           - "Karin Kailing et al - "Ranking interesting subspaces for clustering
#             high dimensional data", Proc. Europ. Conf. on Principles and
#             Practice of Knowledge Discovery in Databases (PKDD), Dubrovnic,
#             Croatia, 2003.  Lecture Notes in Artificial Intelligence (LNAI),
#             Vol. 2838, pp. 241-252, SpringerVerlag, 2003.

#-------------------------------------------------------------------------------

getPrincipalComponents = function (data, OPT.pca.cum.var.explained.cutoff = 0.75)
    {
    cat ("\nOPT.pca.cum.var.explained.cutoff = ",
            OPT.pca.cum.var.explained.cutoff, "\n");

    num.plot.rows <- 1;
    num.plot.cols <- 1;

    plot3across = FALSE
    if (plot3across)
        num.plot.cols <- 3;

    par (mfrow = c(num.plot.rows, num.plot.cols));

    data.pca.cor <- princomp (data, cor = T);
    #data.pca.cor <- prcomp (data, cor = T);
            #  Note that prcomp also has a screeplot function that you can
            #  run on the data.pca.cor structure instead of the straight plot
            #  function that John specified.  Both outputs look almost identical.
    ###plot (data.pca.cor, main= 'Screeplot (COR Approach)');
    ###screeplot (data.pca.cor);
            #  The R Help example has a line with dots instead of bars.
            #  It's quite a bit easier to use to pick out the elbow.
            #  I'm not sure what the "$sdev" is, but it was in the sample
            #  argument and gets at the total number of variables in the pca.
            #  It also works fine just plugging in any value like 75.
    screeplot(data.pca.cor, npcs=length(data.pca.cor$sdev), type="lines");

    #browser();
            #  The R help also mentions a biplot function for prcomp.
            #  I have run it here, but it's such a mess that I'm not sure
            #  what it's supposed to show.
            #
            #  NOTE/QUESTION: If you use prcomp() instead of princomp(),
            #                 you get the following warning which you don't get
            #                 if you used princomp():
            #  Warning message:
            #  In arrows(0, 0, y[, 1L] * 0.8, y[, 2L] * 0.8, col = col[2L], length = arrow.len) :
            #    zero-length arrow is of indeterminate angle and so skipped
    ####biplot (data.pca.cor);

            #  NOTE/QUESTION: These two commands work fine after princomp()
            #                 but return NULL if you use prcomp().
    ##print (data.pca.cor$scores [1:5,1:6]);
    ##print (data.pca.cor$loadings);
    ##print (data.pca.cor$loadings [1:5,1:6]);
            #  "scores" contains the transformed data points.
    dim (data.pca.cor$scores)
            #  "loadings" contains the transforms to apply to the data to get the
            #  scores.
    dim (data.pca.cor$loadings)
            #  "predict" applies the pca loadings to transform a data point into
            #  the new pca space.
            #  This call to predict produces the first line of data.pca.cor$scores,
            #  i.e., e1 == data.pca.cor$scores[1,].
    ####e1 <- predict (data.pca.cor, data[1,]);

    #data.pca.cov <- princomp (data, cor = F);
    ##data.pca.cov <- prcomp (data, cor = F);
    #plot (data.pca.cov, main= 'Screeplot (COV Approach)');
    #print (data.pca.cov$scores [1:5,1:6]);

        #  Look at the scree plot and pick the last pca coordinate to include,
        #  i.e., the "elbow".

        #  Or, since it shows the amount of variance explained to that point,
        #  pick a cutoff value and use that to choose the last coordinate to
        #  include.

    #browser();

    num.pca.coords <- length (data.pca.cor$sdev);
    variances <- data.pca.cor$sdev * data.pca.cor$sdev;
    cum.var.explained <- cumsum (variances) / num.pca.coords;
    plot (cum.var.explained);
    cat ("\n\ncumulative variance explained at each pca coordinate: \n");
    for (pca.coord in 1:num.pca.coords)
      {
      cat ("  ", pca.coord, "  ",
           variances [pca.coord], "  ",
           cum.var.explained [pca.coord],
           "\n",  sep='');
      }
    cat ("\n\n");

        #  Eleventh change...
        #  When I wanted to include all coordinates, I just set the cutoff to be 1.0,
        #  but floating point arithmetic meant that cum.var.explained didn't quite make
        #  it to 1.0 even when all values were added up.  So, I had to create an epsilon
        #  to bump it up slightly.
        #  Here's the error message that I got:
        #      pca.elbow =  Inf  (i.e., last pca coord to include)
        #
        #      Error in 1:pca.elbow : result would be too long a vector
        #      In addition: Warning message:
        #      In min(which(cum.var.explained >= OPT.pca.cum.var.explained.cutoff)) :
        #        no non-missing arguments to min; returning Inf
        #  I picked 0.00001 out of thin air.  If it hadn't worked, I would have tried
        #  something slightly larger.  I might be able to go with something much smaller
        #  too, but I don't feel like messing with it right now...
    epsilon <- 0.00001;
    pca.elbow <-
        min (which ((cum.var.explained + epsilon) >= OPT.pca.cum.var.explained.cutoff));

    cat ("pca.elbow = ", pca.elbow, " (i.e., last pca coord to include)\n\n");

    #pca.elbow <- 8;
    ###data.to.cluster <- data.pca.cor$scores [ , 1:pca.elbow];
    if (pca.elbow < 2)
    {
    pca.output.points <- as.matrix (data.pca.cor$scores, nrow = length (data.pca.cor$scores), ncol = 1);
    plot(0);

    } else
    {
    pca.output.points <- data.pca.cor$scores [ , 1:pca.elbow];
    ###plot (data.to.cluster [ , 1:2]);
    plot (pca.output.points [ , 1:2]);
    }

    data <- pca.output.points;
    #  pca.output.distances <- daisy (pca.output.points);

    return (data)
    }

#-------------------------------------------------------------------------------

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

OPT.PCA = FALSE
OPT.pca.cum.var.explained.cutoff = 0.75
mismatchCt = 0

#dataSrc = "fractalData"
#imgFileType = "pgm"

dataSrc = "mattData"
imgFileType = "asc"

numClusters = 3
maxNumPixelsToCluster = 500

randomSeed = 17

callingFromGuppy = TRUE
if (callingFromGuppy & exists ("rSppGenOutputDir"))
    {
    sppGenOutputDir = rSppGenOutputDir
    curFullMaxentEnvLayersDirName = rCurFullMaxentEnvLayersDirName
    numSpp = rNumSpp
    randomSeed = rRandomSeed

    numClusters = numSpp
    }

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

##    imgSrcDir = "/Users/Bill/Downloads/environment.MattClusteringData.2013.08.29/"
#    imgSrcDir = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloEnvVars/"
    imgSrcDir = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloEnvVars_Originals/"

#  weights at end of following lines...
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



numPixelsPerImg = numImgRows * numImgCols
numRecordsToCluster = min (maxNumPixelsToCluster, numPixelsPerImg)
#OLD#  numNonEnvDataCols = 3    #  1 col for IDs and 2 cols for x,y
numNonEnvDataCols = 1    #  1 col for IDs
#OLD#  numColsInEnvLayersTable = numEnvLayers + 3
numColsInEnvLayersTable = numEnvLayers + 1

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

#OLD#  #numPixelsInImg = 12
#OLD#  #numImgRows = 3
#OLD#  #numImgCols = 4
#OLD#  y = ((0:(numPixelsPerImg - 1)) %/% numImgRows) + 1
#OLD#  x = 1:numPixelsPerImg %% numImgCols
#OLD#      #  Modulo operator leaves the last column of each row set to 0 instead of
#OLD#      #  set to the last column number, i.e., numImgCols, so replace the 0 in
#OLD#      #  each row's y value
#OLD#  for (kkk in 1:numPixelsPerImg) { if (x[kkk] == 0) x[kkk] = numImgCols }

#OLD#  cat ("\n\nlength (combinedEnvLayersTable [,2]) = ", length (combinedEnvLayersTable [,2]))
#OLD#  cat ("\n    length (x) = ", length (x))
#OLD#  cat ("\nlength (combinedEnvLayersTable [,3]) = ", length (combinedEnvLayersTable [,3]))
#OLD#  cat ("\n    length (y) = ", length (y))
#OLD#  combinedEnvLayersTable [,2] = x
#OLD#  combinedEnvLayersTable [,3] = y

    #------------------------------------------------
    #  Load all of the data layers to be clustered.
    #
    #  That is, read each env layer file into a
    #  single column of a large table with one row
    #  for each pixel's set of all env feature
    #  values.
    #------------------------------------------------

curImgFileIdx = 0
#OLD#  firstNonXYCol = 4
firstNonXYCol = 1 + numNonEnvDataCols
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

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
    #  WHY IS THIS ID.COL VARIABLE HERE, EVEN IN THE GUPPYCLUSTERTEST VERSION?
    #  DOESN'T SEEM LIKE IT'S EVER EVEN LOADED, MUCH LESS USED...
id.col <- 1
##data <- data [order (data [ , id.col]), ]

##dataPointIDs <- data [ , id.col]
##rownames (data) <- dataPointIDs
#data <- data [ , -id.col]

combinedEnvLayersTable = combinedEnvLayersTable [ , -id.col]
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------




if (scaleInputs)
    combinedEnvLayersTable = scale (combinedEnvLayersTable)









    #----------------------------------------------------------------------
    #  Draw the subsample of records to be clustered from the full set of
    #  pixels.
    #----------------------------------------------------------------------

#OLD#  idsOfRecordsToCluster = sample (1:numPixelsPerImg, numRecordsToCluster, replace=FALSE)#clusterInputTable =
#cat ("\nidsOfRecordsToCluster = ", idsOfRecordsToCluster, "\n")

#####recordsToCluster = combinedEnvLayersTable [idsOfRecordsToCluster,]
##### #cat ("\n\nrecordsToCluster = \n")
##### #print (recordsToCluster)

combinedEnvLayersTableInPCAcoords = NULL
#OLD#  recordsToCluster = NULL
envDataSrc = NULL

    #----------------------------------------------------------------------
    #  Convert input data to pca coordinates if desired.
    #----------------------------------------------------------------------

cat ("\n\nOPT.PCA = ", OPT.PCA, "\n")

if (OPT.PCA)
    {
        #  Doing PCA, so compute the principal components and
        #  convert the env layers to pca coordinates to use
        #  as inputs.

    OPT.pca.cum.var.explained.cutoff = 0.75
#    recordsToCluster = getPrincipalComponents (recordsToCluster,
#                                               OPT.pca.cum.var.explained.cutoff)
    combinedEnvLayersTableInPCAcoords = getPrincipalComponents (combinedEnvLayersTable,
                                               OPT.pca.cum.var.explained.cutoff)

    envDataSrc = combinedEnvLayersTableInPCAcoords

    } else
    {
        #  Not doing PCA, so just use the raw env values for input.
    envDataSrc = combinedEnvLayersTable
    }

#OLD#  recordsToCluster = envDataSrc [idsOfRecordsToCluster,]
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

#OLD#  cat("\nStarting kmeans...\n");
#OLD#  clusterSet = kmeans (recordsToCluster, numClusters)
#OLD#  #clusterSet = kmeans (recordsToCluster, initialClusterCenters)

#OLD#  print (clusterSet)
#OLD#  cat ("\n\n>>>>>>>>>>> class(clusterSet$centers) = ", class(clusterSet$centers), "\n\n")
#OLD#  print (clusterSet$centers)

#OLD#  original.data.distances <- daisy (recordsToCluster);
#OLD#  data.distances <- original.data.distances;

#OLD#  data.clus <- clusterSet$cluster    	#  If you don't do this, you get error msg...
#OLD#  clusplot (data.distances,
#OLD#            data.clus,
#OLD#            diss = TRUE,
#OLD#            main = 'kmeans results',
#OLD#            asp = 1,
#OLD#            col.p = data.clus,
#OLD#            labels = 4);  # color points and label ellipses
#OLD#  #          labels = 5);  # color points and label ellipses and identify pts

#=====================
#=====================
#=====================
#=====================
#=====================
#=====================
#=====================

#-------------------------------------------------------------------------------

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

#-------------------------------------------------------------------------------

sumSquaredDist = function (point1, point2)
    {
    if (length (point1) != length (point2))
        {
        mismatchCt <<- mismatchCt + 1
        if (mismatchCt < 10)
            {
            cat ("\n\n--------------------------------------\n")
            cat ("\nIn sumSquareDist(), lengths don't match.  mismatchCt = ",
                mismatchCt, ".")
            cat ("\n    length (point1) = ", length (point1))
            cat ("\n    length (point2) = ", length (point2))
            cat ("\n    point1 = ", point1)
            cat ("\n    point2 = ", point2)
            cat ("\n")
            }
        }
    vs = vecSquared (point1 - point2)
    #cat ("\nvs = ", vs)
    retValue = vs
#    retValue = sqrt (vs)
    #cat ("\nretValue = ", retValue)

    if ((length (point1) != length (point2)) & (mismatchCt < 10))
        {
        cat ("\nvs = ", vs)
        cat ("\nretValue = ", retValue)
        cat ("\n--------------------------------------\n\n")
        }

    return (retValue)
    }

#-------------------------------------------------------------------------------

eucDist = function (point1, point2)
    {
    return (sqrt (sumSquaredDist (point1, point2)))
    }

#-------------------------------------------------------------------------------

distVecs = matrix (0, nrow=numPixelsPerImg, ncol=numClusters)
#cat ("\n>>>>>>>>>>>>>>>>>>>>>>>>>>  new distVec = ", distVec)

numHistIntervals = 10
curClusterID = 1

for (curClusterID in 1:numClusters)
    {
#OLD#      curClusterCenter = clusterSet$centers[curClusterID,]
    curClusterCenter = clusterCenters [curClusterID,]
    cat ("\n\n------------------\ncurClusterCenter = ", curClusterCenter, "\n------------------\n\n")

    for (curRow in 1:numPixelsPerImg)
        {
        #cat ("\nLOOP START: curRow = ", curRow)

###        point1 = combinedEnvLayersTable [curRow,]
        point1 = combinedEnvLayersTableInPCAcoords [curRow,]

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
            #  Maybe that suggests using higher powers than just squares?

            #  BTL - 2013.10.29
#        distVecs [curRow, curClusterID] = eucDist (point1, point2)

##########  btl - 11/08/13 - noon - I think this is fixed now...
##########                          Leaving the comment below just in
##########                          case it's still not right.
#####  btl - 10/28/13 - 7 pm
#####  FORGOT THAT WHEN I CONVERT THE POINTS TO PCA VALUES,
#####  I NEED TO ALSO CONVERT THE POINTS IN THIS CALCULATION.
#####  RIGHT NOW, IT IS COMPUTING THE DIFF BETWEEN THE RAW POINT
#####  VALUES (18D) AND THE PCA VALUES (5D))

#browser()

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
                    paste (curDir, "distToCluster.", (curClusterID - 1), sep=''),
                    numImgRows, numImgCols)


    #---------------
        #  BTL - 11/8/13 - added for compatibility with tzar runs

    filenameRoot = paste (curDir, "spp.", (curClusterID - 1), sep='')
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

