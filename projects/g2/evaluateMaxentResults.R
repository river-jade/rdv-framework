#===============================================================================

#                               evaluateMaxentResults.R

# source ('evaluateMaxentResults.R')

#===============================================================================

#  History:

#  2014.02.09 - BTL 
#  Copied from guppy/evalauteMaxentResultsPyper.R.  Also compared with 
#  guppy/evaluateMaxentResults.R.

#  2013.08.14 - BTL
#  Created from evaluateMaxentResults.R.
#       - Added arguments to the function call so that python can hand them in.
#           Currently, the R code assumed that these were globally known values.

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#=========================================================================================

evaluateMaxentResults = function (numSppToCreate,
                                  doMaxentReplicates,
                                  trueProbDistFilePrefix,
                                  showRawErrorInDist,
                                  showAbsErrorInDist,
                                  showPercentErrorInDist,
                                  showAbsPercentErrorInDist,
                                  showTruncatedPercentErrImg,
                                  showHeatmap,
                                  
                                  fullMaxentOutputDirWithSlash,
                                  
                                  
                                  #  I think this now needs to point to SppGenOutputs instead.
                                  #  BTL - 2013 12 10
                                  #                                    probDistLayersDirWithSlash,
                                  sppGenOutputDirWithSlash,
                                  
                                  fullAnalysisDirWithSlash,    #  analysisDirWithSlash,
                                  useOldMaxentOutputForInput,
                                  writeToFile,
                                  useDrawImage
                                  )
    {
    cat ("\n\n>>>>>>>>>>>>>  STARTING evaluateMaxentResults()\n\n")
    
    cat ("\n\nIn evaluateMaxentResults:")
    cat ("\n    numSppToCreate = '", numSppToCreate, "'", sep='')
    cat ("\n    doMaxentReplicates = '", doMaxentReplicates, "'", sep='')
    cat ("\n    trueProbDistFilePrefix = '", trueProbDistFilePrefix, "'", sep='')
    cat ("\n    showRawErrorInDist = '", showRawErrorInDist, "'", sep='')
    cat ("\n    showAbsErrorInDist = '", showAbsErrorInDist, "'", sep='')
    cat ("\n    showPercentErrorInDist = '", showPercentErrorInDist, "'", sep='')
    cat ("\n    showAbsPercentErrorInDist = '", showAbsPercentErrorInDist, "'", sep='')
    cat ("\n    showTruncatedPercentErrImg = '", showTruncatedPercentErrImg, "'", sep='')
    cat ("\n    showHeatmap = '", showHeatmap, "'", sep='')
    cat ("\n    fullMaxentOutputDirWithSlash = '", fullMaxentOutputDirWithSlash, "'", sep='')
    
    #	cat ("\n    probDistLayersDirWithSlash = '", probDistLayersDirWithSlash, "'", sep='')
    cat ("\n    sppGenOutputDirWithSlash = '", sppGenOutputDirWithSlash, "'", sep='')
    
    cat ("\n    fullAnalysisDirWithSlash = '", fullAnalysisDirWithSlash, "'", sep='')
    cat ("\n    useOldMaxentOutputForInput = '", useOldMaxentOutputForInput, "'", sep='')
    cat ("\n    writeToFile = '", writeToFile, "'", sep='')
    cat ("\n    useDrawImage = '", useDrawImage, "'", sep='')
    
    cat ("\n\n===========  DONE echoing arguments  =============\n\n")
    
    for (sppID in 1:numSppToCreate)
#    for (sppID in 0:(numSppToCreate - 1))      #  now created by python so 0 base...
        {
        sppName = paste ('spp.', sppID, sep='')
        
        #===========================================================================
        
        #---------------------------------------------------------------------
        #  When you use the replicates option in maxent (e.g., bootstrapping
        #  or cross-validation), it changes its naming convention.
        #  Instead of spp.1.asc, you get spp.1_0.asc, spp.1_1.asc, etc.
        #  I'm just going to arbitrarily copy the first replicate into a
        #  spp.?.asc file so that all of the naming conventions from before
        #  still hold up.
        #  I don't think that it matters which replicate you choose and I
        #  don't think that using a single more "representative" one like the
        #  median of the replicates will necessarily preserve the spatial
        #  errors.
        #---------------------------------------------------------------------
        
        if (doMaxentReplicates)
            {
            maxentFirstReplicateFilename =
                paste (fullMaxentOutputDirWithSlash, '/', sppName, "_0.asc", sep='')
            maxentNoReplicateFilename =
                paste (fullMaxentOutputDirWithSlash, '/', sppName, ".asc", sep='')
            
            #  NOTE:  Could use the stopifnot() function for things like this...
            
            if (! file.copy (maxentFirstReplicateFilename,
                             maxentNoReplicateFilename,
                             overwrite = TRUE ))
                {
                cat ('\nCould not copy ', maxentFirstReplicateFilename, ' to ',
                     maxentNoReplicateFilename);
                stop ('\nAborted due to error.', call. = FALSE);
                }
            }
        
        #===========================================================================
        
        #-------------------------------------------------------------------
        #  Get maxent's resulting probability distribution.
        #  Then, subtract it from the true distribution to see the spatial
        #  pattern of error.
        #-------------------------------------------------------------------
        
        #  Load the maxent output distribution into a matrix.
        maxentRelProbDist =
            read.asc.file.to.matrix (
                sppName,
                ##									paste (sppName, ".asc", sep=''),
                fullMaxentOutputDirWithSlash)
        
        #  Normalize the matrix to allow comparison with true distribution.
        totMaxentRelProbDist = sum (maxentRelProbDist)
        maxentNormProbDist = maxentRelProbDist / totMaxentRelProbDist
        
        #  Make sure it's a prob dist, i.e., sums to 1
        cat ("\n\n sum (maxentNormProbDist) = '", sum (maxentNormProbDist),
             "'.  Should == 1.\n\n")
        
        ################################################################################
        #####  2013 04 25 - BTL
        #####  THIS IS A TOTAL HACK THAT NEEDS TO BE CLEANED UP.
        #####  normProbMatrix WAS SUPPOSED TO ALREADY HAVE BEEN NORMALIZED BEFORE
        #####  IT WAS WRITTEN TO A FILE, BUT IT ISN'T, SO I'M NORMALIZING IT HERE.
        #####  THIS WASN'T NECESSARY WHEN I WAS CREATING PROBABILITY DISTRIBUTIONS
        #####  USING ARITHMETIC SINCE IT WAS DONE CORRECTLY THEN.
        #####  NOW, I'M USING MAXENT OUTPUT FILES AS THE TRUE PROB DIST AND THEY
        #####  DON'T SEEM TO BE NORMALIZED.
        
        normProbMatrix =
            #			read.asc.file.to.matrix (paste (probDistLayersDirWithSlash,
            read.asc.file.to.matrix (paste (sppGenOutputDirWithSlash,
                                            trueProbDistFilePrefix,
                                            ".", sppName,
                                            ##									'.asc',
                                            sep=''))
        
        #####  start of hack
        totNormProbMatrix = sum (normProbMatrix)
        normProbMatrix = normProbMatrix / totNormProbMatrix
        #####  end of hack
        
        cat ("\n\n sum (normProbMatrix) = '", sum (normProbMatrix),
             "'.  Should also == 1.\n\n")
        ################################################################################
        
        #  Compute the difference between the correct and maxent probabilities
        #  and save it to a file for display.
        
        errBetweenMaxentAndTrueProbDists =
            maxentNormProbDist - normProbMatrix
        
        numImgRows = dim (errBetweenMaxentAndTrueProbDists) [1]
        numImgCols = dim (errBetweenMaxentAndTrueProbDists) [2]
        
        #cat ("\n\n=============================\n")
        #cat ("\nshowRawErrorInDist = '",
        #	showRawErrorInDist, "'", sep='')
        #cat ("\n\n=============================\n")
        
        if (showRawErrorInDist)
            {
            #cat ("\n\n=============  Inside the if statement  ================\n")
            
            #  NECESSARY TO WRITE THESE ASC AND PGM FILES OUT?
            #  DOESN'T SEEM LIKE THEY'RE USED FOR ANYTHING.
            write.asc.file (errBetweenMaxentAndTrueProbDists,
                            paste (fullAnalysisDirWithSlash, "raw.error.in.dist.", sppName, sep=''),
                            numImgRows, numImgCols
                            , xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
                            , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
                            #  is not actually on the map.  It's just off the lower
                            #  left corner.
                            , no.data.value = -9999
                            , cellsize = 1
                            )
#             write.pgm.file (errBetweenMaxentAndTrueProbDists,
#                             paste (fullAnalysisDirWithSlash, "raw.error.in.dist.", sppName, sep=''),
#                             numImgRows, numImgCols)
            }
        #stop()
        
        #===========================================================================
        
        #-------------------------------------------------------------------------
        #  Plot that pattern.
        #  Compute non-spatial statistics that compare the two distributions.
        #    - rank correlation
        #    - correlation
        #    - KS test  (is KS the test that compares two distributions?)
        #  One question: are there any computer arithmetic issues with all these
        #  small numbers in these distributions?
        #-------------------------------------------------------------------------
        
        #--------------------------------------------------------------------
        #  IMPORTANT
        #  NOTE:  May want to do these tests using several different views
        #         that reflect something like a cost-sensitive view.
        #         For example, what is most important in a Madagascar-style
        #         use of maxent + zonation is how the true top 10% of the
        #         distribution performs.
        #         So, you may want to use which() to pull out certain
        #         subsets of locations to analyze.
        #         More importantly, probably want to do a which() that
        #         selects the top 10% or so of locations in the true
        #         distribution and the true Zonation ranking.  Then,
        #         do various statistics on just those locations in the
        #         Maxent data to get an idea of how well it does on those.
        #         One more thing - percent error may not be the right
        #         error to look at in a probability distribution.
        #         May want to look at the absolute error instead.
        #         Not sure...
        #--------------------------------------------------------------------
        
        errMagnitudes = abs (errBetweenMaxentAndTrueProbDists)
        if (showAbsErrorInDist)
            {
            write.asc.file (errMagnitudes,
                            paste (fullAnalysisDirWithSlash, "abs.error.in.dist.", sppName, sep=''),
                            numImgRows, numImgCols
                            , xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
                            , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
                            #  is not actually on the map.  It's just off the lower
                            #  left corner.
                            , no.data.value = -9999
                            , cellsize = 1
                            )
            
#             write.pgm.file (errMagnitudes,
#                             paste (fullAnalysisDirWithSlash, "abs.error.in.dist.", sppName, sep=''),
#                             numImgRows, numImgCols)
            }
        
        
        
        png (paste (fullAnalysisDirWithSlash, "histErrBetweenMaxentAndTrueProbDists.", sppName, ".png", sep=''))
        #	hist (percentErrMagnitudes [percentErrMagnitudes <= 100])
        hist (errBetweenMaxentAndTrueProbDists)
        dev.off()
        
        png (paste (fullAnalysisDirWithSlash, "histErrMagnitudes.", sppName, ".png", sep=''))
        hist (errMagnitudes)
        dev.off()
        
        
        
        totErrMagnitude = sum (errMagnitudes)    #  Is this ever used anywhere?  Vestigal?
        maxErrMagnitude = max (errMagnitudes)    #  Is this ever used anywhere?  Vestigal?
        
        ####  PROBLEM: normProbMatrix not defined?  maxent.norm.prob.dist not defined?
        ####  Actually, normProbMatrix IS defined.  Not sure why this comment is here.
        ####  May be vestigial. Will leave it though until I clean everything up and
        ####  make sure it's ok to delete it.
        ####  BTL - 2011.09.22
        
        ########  Should these be cor and app instead?
        ########  I.e., npmVec ----> normProbCorVec and
        ########       mnpdVec ----> normProbAppVec ???
        ########  BTL - 2013.05.06
        
        npmVec = as.vector (normProbMatrix)
        mnpdVec = as.vector (maxentNormProbDist)
        
        #-----------------------------------------------
        #  Should compute rank error here?
        #  Also, rank error in top n % only?
        #       Maybe do a cumulative rank error starting from best rank?
        #  What about % rank error?
        #       Seems like that would automatically weight best ranks most important,
        #       although it's not in a way that you've made explicit, so it's
        #       probably better to just do raw error and then transform that with
        #       an explicit weight that can be based on rank as well.
        #-----------------------------------------------
        
        png (paste (fullAnalysisDirWithSlash, "histErrBetweenMaxentAndTrueProbDists.", sppName, ".png", sep=''))
        #	hist (percentErrMagnitudes [percentErrMagnitudes <= 100])
        hist (errBetweenMaxentAndTrueProbDists)
        dev.off()

        
        
###  *****  THIS RANK STUFF LOOKS WRONG!  *****
###  npmVec and mnpdVec are not ranks AND they're in the reverse order to rank
###  aren't they?
###  BTL - 2014.02.09

        corRank = npmVec
corRank = rank (npmVec)
        appRank = mnpdVec
appRank = rank (mnpdVec)
        #plot (corRank, appRank)
        
        rankError = appRank - corRank
        #plot (corRank, rankError)
        
        pctRankError = rankError/corRank
        #plot (corRank, pctRankError)
        
        png (paste (fullAnalysisDirWithSlash, "hist.rank.err.", sppName, ".png", sep=''))
        
        rankError = appRank - corRank
        #plot (corRank, rankError)
        hist (rankError)
        dev.off()
        
        png (paste (fullAnalysisDirWithSlash, "hist.pct.rank.err.", sppName, ".png", sep=''))
        pctRankError = rankError/corRank
        #plot (corRank, pctRankError)
        hist (pctRankError)

###  *****  END - THIS RANK STUFF LOOKS WRONG!  *****




        dev.off()
        
        
        pearson.cor = cor (npmVec, mnpdVec,
                            method = "pearson"
                            )
cat ("\n\npearson.cor = ", pearson.cor)

        spearman.rank.cor = cor (npmVec, mnpdVec,
                                  method = "spearman"
                                )
cat ("\n\nspearman.cor = ", spearman.cor)

        
        #  this one hung R every time I used it...
        ##kendall.cor = cor (npmVec, mnpdVec,
        ##     			    method = "kendall"
        ##     			   )
        
        ##par (mfrow=c(4,2))    #  4 rows, 2 cols
        par (mfrow=c(2,2))    #  2 rows, 2 cols
        
        ## 	cur.idx = 0
        ## 	zemCt = 0
        ## 	znpmCt = 0
        ## 	infCt = 0
        ## 	infLocs = NULL
        ## 	for (row in 1:numImgRows)
        ## 		for (col in 1:numImgCols)
        ## 			{
        ## 			cur.idx = cur.idx + 1
        ## 			if (errMagnitudes[row,col] == 0)
        ## 				zemCt = zemCt + 1
        ## 			if (normProbMatrix[row,col] == 0)
        ## 				znpmCt = znpmCt + 1
        ## #				cat ("\ne.m [", row, ",", col, "] = 0 at idx = ", cur.idx, sep='')
        ## 			if (is.infinite (errMagnitudes[row,col] / normProbMatrix[row,col]))
        ## 				{
        ## 				infCt = infCt + 1
        ## 				infLocs = c(infLocs,cur.idx)
        ## 			}
        ## 	cat ("\n\nvvvvvvvvvvvvvvvvvvvvv")
        ## 	cat ("\nerrMagnitudes = 0 for ", zemCt, " entries.", sep='')
        ## 	cat ("\nnormProbMatrix = 0 for ", znpmCt, " entries.", sep='')
        ## 	cat ("\ninfCt = ", infCt, sep='')
        ## 	cat ("\ninfLocs = ", infLocs, sep='')
        ## 	cat ("\n\n^^^^^^^^^^^^^^^^^^^^^")

###  *****  THE USE OF EPSILON IN PLACE OF ZERO AS A DIVISOR MAY BE WRONG.  *****
###         MAY BE BLOWING SOMETHING UP THAT SHOULDN'T BE DONE AT ALL?

        epsilon = 1e-09
        
        #normProbMatrix.epsilon = normProbMatrix
        #normProbMatrix.epsilon [normProbMatrix == 0] = epsilon
        #	percentErrMagnitudes = (errMagnitudes / normProbMatrix.epsilon) * 100
        
        #  Create percent err magnitudes matrix.
        #  Could zero or NA it to start but all will be overwritten, so
        #  I'll just copy the errMagnitudes array as a quick initialization
        #  that matches whatever byrow conventions are used there.
        percentErrMagnitudes = errMagnitudes
        
        #cat ("\n\nComputing percentErrMagnitudes\n")
        for (curIdx in 1:length(errMagnitudes))
            {
            #  %% indicates x mod y and
            #  %/% indicates integer division
            
            #	if ((curIdx %% 50) == 0)  cat("\n")
            
            retVal = NA
            curErrMag = errMagnitudes [curIdx]
            corVal = normProbMatrix [curIdx]
            if (curErrMag == 0)
                {
                retVal = 0
                #		cat ("0")
                } else if (corVal == 0)
                {
                retVal = 100 * curErrMag / epsilon    ###  *****  Bad idea???  *****
                #		cat ("1")
                } else
                {
                retVal = 100 * curErrMag / corVal
                #		cat ("3")
                }
            percentErrMagnitudes [curIdx] = retVal
            }
        #cat ("\n\nDone computing percentErrMagnitudes\n")

###  *****  END - THE USE OF EPSILON IN PLACE OF ZERO AS A DIVISOR MAY BE WRONG.  *****

        ## percentErrMagnitudes [(errMagnitudes == 0)] = 0
        ## minAndMax = range(x[(!is.infinite(x) & !is.nan(x))])
        ## minVal = minAndMax[1]
        ## maxVal = minAndMax[2]
        ## x[is.infinite(x) & (x < 0)] = minVal
        ## x[is.infinite(x) & (x > 0)] = maxVal
        ## x[is.nan(x)] = mean(x)
        
        cat ("\n\nrange (normProbMatrix) = ", range (normProbMatrix))
        cat ("\n\nrange (errMagnitudes) = ", range (errMagnitudes))
        cat ("\n\nrange (percentErrMagnitudes) = ", range (percentErrMagnitudes))
        cat ("\n\n")
        
        png (paste (fullAnalysisDirWithSlash, "hist.percent.error.in.dist.", sppName, ".png", sep='')
            )
        #	hist (percentErrMagnitudes [percentErrMagnitudes <= 100])
        hist (percentErrMagnitudes)
        dev.off()
        
        if (showPercentErrorInDist)
            {
            
            #####  PROBABLY NEED TO REWRITE THE WRITE.PGM.FILE() FUNCTION OR CREATE A
            #####  DIFFERENT/OPTIONAL VERSION OF IT TO HANDLE FILES WHERE THERE ARE A
            #####  A SMALL NUMBER OF VERY EXTREME VALUES THAT MESS UP THE LINEAR
            #####  SCALING USED NOW.  FOR EXAMPLE, I THINK THAT IF YOU HAVE JUST ONE VALUE
            #####  THAT'S MUCH LARGER THAN ALL THE OTHERS (E.G., NOISE), THEN IT WILL
            #####  CURRENTLY SCALE EVERYTHING TO MAKE THAT PIXEL WHITE BUT ALL OTHER
            #####  PIXELS WILL BE SMASHED DOWN INTO THE LOWEST PIXEL COLOR, I.E., BLACK,
            #####  MAKING AN ALL BLACK IMAGE.
            #####  MIGHT BE BETTER TO RUN HIST() AND USE THE BOUNDS OF SOME QUANTILES
            #####  AS THE BOUNDS OF ALL BUT THE BLACKEST AND WHITEST PIXELS.
            #####  Note that this might apply to other things besides pgms, but they're
            #####  plotted by built-in R functions.  Not sure about this...
            #####  BTL - 2013.04.18.
            
            write.pgm.file (percentErrMagnitudes,
                            paste (fullAnalysisDirWithSlash, "percent.error.in.dist.", sppName, sep=''),
                            numImgRows, numImgCols)
            }
        
        absPercentErrMagnitudes = abs (percentErrMagnitudes)
        if (showAbsPercentErrorInDist)
            {
            write.pgm.file (absPercentErrMagnitudes,
                            paste (fullAnalysisDirWithSlash, "abs.percent.error.in.dist.", sppName, sep=''),
                            numImgRows, numImgCols)
            }
        
        ##    #  Reset the largest errors to one fairly large value so that
        ##    #  you can reduce the dynamic range of the image and make it
        ##    #  easier to differentiate among smaller values.
        
        truncatedErrImg = absPercentErrMagnitudes
        truncatedErrImg [absPercentErrMagnitudes >= 50] = 50
        
        if (showTruncatedPercentErrImg)
            {
            write.pgm.file (truncatedErrImg,
                            paste (fullAnalysisDirWithSlash, "truncated.percent.err.img.", sppName, sep=''),
                            numImgRows, numImgCols)
            }
        
        if (showHeatmap)
            {
            #-----------------------------------------------------------------------
            #  standard color schemes that I know of that you can use:
            #  heat.colors(n), topo.colors(n), terrain.colors(n), and cm.colors(n)
            #
            #  I took this code from an example I found on the web and it uses
            #  some options that I don't know anything about but it works.
            #  May want to refine it later.
            #-----------------------------------------------------------------------
            
            cat ("\n\nDrawing heatmap of err between maxent and true prob dists as PNG.\n")
            heatmapOutputFilename =
                paste (fullAnalysisDirWithSlash,
                       "heatmap.errBetweenMaxentAndTrueProbDists.",
                       sppName,
                       sep='')
            
            png (paste (heatmapOutputFilename, ".png", sep='')
                 #, width=600, height=589
                )
            heatmap (errBetweenMaxentAndTrueProbDists,
                     Rowv = NA, Colv = NA,
                     col = heat.colors (256),
                     ###		 scale="column",     #  This can rescale colors within columns.
                     margins = c (5,10)
                     
                     #  more options found on the web
                     #cexRow=0.5,
                     #labRow=row_names, labCol=col_names,
                     #ColSideColors = patient_colours,
                     #col = r.topo_colors(50))
                     
                    )
            dev.off()
            cat ("\nDone with PNG heatmap.\n")
            
            
            ## 		cat ("\n\nDrawing heatmap of err between maxent and true prob dists as PDF.\n")
            ## 		pdf (paste (heatmapOutputFilename, ".pdf", sep='')
            ## 		     #, width=600, height=589
            ## 			)
            ## 		heatmap (errBetweenMaxentAndTrueProbDists,
            ## 					Rowv = NA, Colv = NA,
            ## 					col = topo.colors (256),
            ## 					###		 scale="column",     #  This can rescale colors within columns.
            ## 					margins = c (5,10)
            ##
            ## 				#  more options found on the web
            ##           	#cexRow=0.5,
            ##           	#labRow=row_names, labCol=col_names,
            ##           	#ColSideColors = patient_colours,
            ##           	#col = r.topo_colors(50))
            ##
            ## 					)
            ## 		dev.off()
            ## 		cat ("\nDone with PDF heatmap.\n")
            
            }
        
        #===============================================================================
        
        ####  NOTES
        
        ##  This part works but I'm not sure if it's what we want to do...
        
        #### quantile (normProbMatrix, c(0.1,0.9))
        #### top.10 = which(normProbMatrix >= quantile (normProbMatrix, 0.9))
        #### truncated.err = percentErrMagnitudes
        #### truncated.err [percentErrMagnitudes >= quantile (percentErrMagnitudes, 0.95)] = 50
        #### write.pgm.file (truncated.err,
        #### 				paste (fullAnalysisDirWithSlash, "truncatedErrImg", sep=''),
        ####             	numImgRows, numImgCols)
        
        
        ##  This part is a copy of the fooling around I did in R to get the stuff
        ##  above to work...
        
        #### > x = pixmap (as.vector(percentErrMagnitudes), nrow=1025)
        #### > plot(x)
        #### Error in t(x@index[nrow(x@index):1, , drop = FALSE]) :
        ####   subscript out of bounds
        #### > x
        #### Pixmap image
        ####   Type          : pixmap
        ####   Size          : 1025x1025
        ####   Resolution    : 1x1
        ####   Bounding box  : 0 0 1025 1025
        ####
        #### > img = read.pnm ('./ResultsAnalysis/percent.error.in.dist.pgm')
        #### Read 1050625 items
        #### > plot(img)
        #### > truncated.err = normProbMatrix
        #### > truncated.err [normProbMatrix >= quantile (normProbMatrix, 0.95)] = 50
        #### >
        #### > truncated.err = percentErrMagnitudes
        #### > truncated.err [percentErrMagnitudes >= quantile (percentErrMagnitudes, 0.95)] = 50
        #### >
        #### > write.pgm.file (truncated.err,
        #### + 				paste (fullAnalysisDirWithSlash, "truncatedErrImg", sep=''),
        #### +             	numImgRows, numImgCols)
        ####
        #### wrote ./ResultsAnalysis/truncatedErrImg.pgm
        #### >
        #### > img = read.pnm ('./ResultsAnalysis/truncatedErrImg.pgm')
        #### Read 1050625 items
        #### > plot(img)
        #### >
        
        #===============================================================================
        
        #numCols = 1025
        #numRows = 1025
        numRows = dim (truncatedErrImg)[1]
        numCols = dim (truncatedErrImg)[2]
        
        par (mfrow=c(1,1))
        
        #img.matrix = truncatedErrImg
        #jpeg (paste (fullAnalysisDirWithSlash, "test.jpg", sep=''))
        #draw.img (img.matrix)
        #points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
        
        #  NOTE: There is one issue with comparing the outputs of filled.contour().
        #        It rescales to fit the data, so the same color scheme may give
        #        different colors to the same values on different maps.
        #        I think that you Can control the max and min values in the
        #        scaling though.  Need to look at some of the arguments that
        #        I commented out when I cloned the example from R help or the web.
        
        if (! useOldMaxentOutputForInput)
            {
            if (writeToFile)
                tiff (paste (fullAnalysisDirWithSlash, "env.layer.1.tiff", sep=''))
            #    draw.img (env.layers [[1]])
            #    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
            #    plot.main.title = "Env Layer 1"
            #    plot.key.title = "Env\nMeasure1"
            #    map.colors = cm.colors
            #    point.color = "red"
            
            cat ("\n\n***  Would draw.filled.contour.img (env.layers [[1]], ... here.")
            #####		draw.filled.contour.img (env.layers [[1]],
            #####								 "Env Layer 1", "Env\nMeasure1",
            #####								 cm.colors, "red")
            if (writeToFile)  dev.off()
            }
        
        # writeToFile = TRUE
        # fullAnalysisDirWithSlash = "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/ResultsAnalysis/"
        # test.img = matrix (1:256, nrow=256,ncol=256)
        #     if (writeToFile)  tiff (paste (fullAnalysisDirWithSlash, "test.tiff", sep=''))
        #     draw.filled.contour.img (test.img,
        #                              "Test Image", "Env\nMeasure1",
        #                              cm.colors, "red")
        #     if (writeToFile)  dev.off()
        
        
        
        if (! useOldMaxentOutputForInput)
            {
            if (writeToFile)
                tiff (paste (fullAnalysisDirWithSlash, "env.layer.2.tiff", sep=''))
            #    draw.img (env.layers [[2]])
            #    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
            cat ("\n\n***  Would draw.filled.contour.img (env.layers [[2]], ... here.")
            #####		draw.filled.contour.img (env.layers [[2]],
            #####								 "Env Layer 2", "Env\nMeasure2",
            #####								 cm.colors, "red")
            if (writeToFile)  dev.off()
            }
        
        if (writeToFile)
            tiff (paste (fullAnalysisDirWithSlash, "true.prob.dist.", sppName,".tiff",sep=''))
        #    draw.img (normProbMatrix)
        #    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
        draw.filled.contour.img (normProbMatrix,
                                 "True Prob Distribution", "Prob",
                                 terrain.colors, "red")
        if (writeToFile)  dev.off()
        
        if (writeToFile)  tiff (paste (fullAnalysisDirWithSlash, "maxent.prob.dist.", sppName,".tiff",sep=''))
        #    draw.img (maxent.norm.prob.dist)
        #    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
        draw.filled.contour.img (maxentNormProbDist,
                                 "Maxent Prob Distribution", "Prob",
                                 terrain.colors, "red")
        if (writeToFile)  dev.off()
        
        
        if (writeToFile)  tiff (paste (fullAnalysisDirWithSlash, "raw.error.map.", sppName,".tiff", sep=''))
        #    plot.main.title = "Raw error in Maxent Probability"
        #    plot.key.title = "Error"
        #    draw.filled.contour.img (truncatedErrImg, plot.main.title, plot.key.title)
        contour.levels.to.draw = c (20)
        draw.contours = TRUE
        draw.filled.contour.img (errBetweenMaxentAndTrueProbDists,
                                 "Raw error in Maxent Probability",
                                 "Error",
                                 heat.colors, "turquoise",
                                 draw.contours,
                                 contour.levels.to.draw
                                )
        if (writeToFile)  dev.off()
        #write.table (errBetweenMaxentAndTrueProbDists,
        #             file = paste (fullAnalysisDirWithSlash, "raw.error.map.", sppName,".table", sep=''))
        # x = "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/ResultsAnalysis/raw.error.map.spp.2.table"
        
        if (writeToFile)
            tiff (paste (fullAnalysisDirWithSlash, "abs.raw.error.map.", sppName,".tiff", sep=''))
        #    plot.main.title = "Abs value of raw error in Maxent Probability"
        #    plot.key.title = "Error\nAbs Value"
        #    draw.filled.contour.img (truncatedErrImg, plot.main.title, plot.key.title)
        contour.levels.to.draw = c (20)
        draw.contours = TRUE
        draw.filled.contour.img (errMagnitudes,
                                 "Abs value of raw error in Maxent Probability",
                                 "Error\n(Abs Value)",
                                 heat.colors, "turquoise",
                                 draw.contours,
                                 contour.levels.to.draw
                                )
        if (writeToFile)  dev.off()
        if (writeToFile)  tiff (paste (fullAnalysisDirWithSlash, "error.map.", sppName,".tiff", sep=''))
        #    plot.main.title = "Percent error in Maxent Probability"
        #    plot.key.title = "Error\n(percent)"
        #    draw.filled.contour.img (truncatedErrImg, plot.main.title, plot.key.title)
        contour.levels.to.draw = c (20)
        draw.contours = TRUE
        draw.filled.contour.img (truncatedErrImg,
                                 "Percent error in Maxent Probability",
                                 "Error\n(percent)",
                                 heat.colors, "turquoise",
                                 draw.contours,
                                 contour.levels.to.draw
                                )
        if (writeToFile)  dev.off()
        
        
        ###########
        
        if (doMaxentReplicates)
            {
            maxentBootstrapSD =
                read.asc.file.to.matrix (
                    paste ("/", sppName, "_stddev", sep=''),
                    ##									paste ("/", sppName, "_stddev", ".asc", sep=''),
                    fullMaxentOutputDirWithSlash)
            
            #  Just realized this is probably not necessary because maxent
            #  writes a .png of the sd values in the plots directory.
            if (writeToFile)
                tiff (paste (fullMaxentOutputDirWithSlash, "maxentBootstrapSD.", sppName,".tiff", sep=''))
            
            #    plot.main.title = "Percent error in Maxent Probability"
            #    plot.key.title = "Error\n(percent)"
            #    draw.filled.contour.img (truncatedErrImg, plot.main.title, plot.key.title)
            
            contour.levels.to.draw = c (20)
            draw.contours = TRUE
            draw.filled.contour.img (maxentBootstrapSD,
                                     paste ("Maxent ", sppName, ".bootstrapSD", sep=''),
                                     "StdDev",
                                     terrain.colors, "red",
                                     draw.contours,
                                     contour.levels.to.draw
                                    )
            if (writeToFile)  dev.off()
            }
        
        
        #  Not using this at the moment since I've gotten the filled.contour()
        #  code to behave pretty well.  May need this more stripped down stuff
        #  later though.  It also will draw contour lines on the image instead
        #  of just doing a graded image.  (However, I've just figured out how
        #  to draw contour lines on the filled.contour maps too, so maybe it
        #  doesn't matter.)
        
        if (useDrawImage)
            {
            par (mfrow=c(1,2))
            
            if (! useOldMaxentOutputForInput)
                {
                cat ("\n\n***  Would draw.img (env.layers [[1]]) here.")
                #####			draw.img (env.layers [[1]], numRows, numCols)
                cat ("\n\n***  Would draw.img (env.layers [[2]]) here.")
                #####			draw.img (env.layers [[2]], numRows, numCols)
                }
            
            draw.img (normProbMatrix, numRows, numCols)
            cat ('\n\n***  Would points (sampled.locs.x.y, pch = 19, bg = "red", col = "red") here.')
            #####		points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
            draw.img (maxentNormProbDist, numRows, numCols)
            cat ('\n\n***  Would points (sampled.locs.x.y, pch = 19, bg = "red", col = "red") here.')
            #####		points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
            
            draw.img (truncatedErrImg, numRows, numCols)
            cat ('\n\n***  Would points (sampled.locs.x.y, pch = 19, bg = "red", col = "red") here.')
            #####		points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
            }
        
        #===============================================================================
        
        #  This "weird function" is taken from the R help file for levelplot.
        #  It makes an interesting radially banded pattern that could be a useful
        #  synthetic test as a landscape pattern.
        ## library(lattice)
        ## x = seq(pi/4, 5 * pi, length.out = 100)
        ## y = seq(pi/4, 5 * pi, length.out = 100)
        ## r = as.vector(sqrt(outer(x^2, y^2, "+")))
        ## grid = expand.grid(x=x, y=y)
        ## grid$z = cos(r^2) * exp(-r/(pi^3))
        ## levelplot(z~x*y, grid, cuts = 50, scales=list(log="e"), xlab="",
        ##            ylab="", main="Weird Function", sub="with log scales",
        ##            colorkey = FALSE, region = TRUE)
        
        #  That help file also gives an example of labelled contours that
        #  could be useful too.
        ## require(stats)
        ## attach(environmental)
        ## ozo.m = loess((ozone^(1/3)) ~ wind * temperature * radiation,
        ##        parametric = c("radiation", "wind"), span = 1, degree = 2)
        ## w.marginal = seq(min(wind), max(wind), length.out = 50)
        ## t.marginal = seq(min(temperature), max(temperature), length.out = 50)
        ## r.marginal = seq(min(radiation), max(radiation), length.out = 4)
        ## wtr.marginal = list(wind = w.marginal, temperature = t.marginal,
        ##         radiation = r.marginal)
        ## grid = expand.grid(wtr.marginal)
        ## grid[, "fit"] = c(predict(ozo.m, grid))
        ## contourplot(fit ~ wind * temperature | radiation, data = grid,
        ##             cuts = 10, region = TRUE,
        ##             xlab = "Wind Speed (mph)",
        ##             ylab = "Temperature (F)",
        ##             main = "Cube Root Ozone (cube root ppb)")
        ## detach()

        }  #  end - for each species
    
    }  #  end function - evaluateMaxentResults

#===============================================================================



