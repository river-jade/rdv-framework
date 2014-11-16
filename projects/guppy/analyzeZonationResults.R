source ('/Users/Bill/D/rdv-framework/projects/guppy/read.R')

CONST.imgSize.hardCodedMatrix = -1
CONST.imgSize.inputFile = 0
CONST.defaultBufSize = 0.05

test = function (imgSize, 
                 numPlotIntervals, 
                 corRankFileNameBase, 
                 appRankFileNameBase, 
                 corInputDir,
                 appInputDir,
                 algLegendString="algorithm's selection",
                 seed=17, 
                 verbose=FALSE,
                 plotTitle="True Positive fraction above each threshold", 
#                 plotTitle="Fraction of pixels for whom both their apparent and correct\nranks are at least as good as the given apparent rank", 
                 buffer=CONST.defaultBufSize
                 )
    {
        #---------------------------
        #  Set random number seed.
        #---------------------------

    set.seed (seed)
    cat ("\n\n    seed = '", seed, "'", sep='')
    
        #------------------------------------
        #  Load correct and apparent ranks.  
        #------------------------------------
        
    cat ("\n\n    imgSize = '", imgSize, "'", sep='')
        if (imgSize == CONST.imgSize.hardCodedMatrix)
        {
            #--------------------------------------
            #  Load ranks from hard-coded matrix.  
            #--------------------------------------
            
            cat ("\n\n*** Loading zonation ranks from hard-coded matrix.\n\n")
            
            corZonationRanks = 
                c (-1.0000000,-1.0000000,-1.0000000,-1.0000000,-1.0000000,-1.0000000,0.9392399,0.6112437,0.4881890,-1.0000000,-1.0000000,0.9587234,0.8095046,0.7898196,-1.0000000,-1.0000000,0.6328818,0.5053320,0.5057350,-1.0000000,-1.0000000,-1.0000000,-1.0000000,-1.0000000,-1.0000000)
            
            appZonationRanks = 
                c (-1.0000000,-1.0000000,-1.0000000,-1.0000000,-1.0000000,-1.0000000,0.9997830,0.9988685,0.9920640,-1.0000000,-1.0000000,0.9990700,0.9996280,0.9955050,-1.0000000,-1.0000000,0.9960010,0.9974735,0.9989770,-1.0000000,-1.0000000,-1.0000000,-1.0000000,-1.0000000,-1.0000000)
            
            imgSize = length (corZonationRanks)
            appSize = length (appZonationRanks)
            if (appSize != imgSize)
            {
                cat ("\n\nCorrect and apparent rank files must be same size.",
                     "\nCor size = ", imgSize, ", and App size = ", appSize, 
                     "\nQuitting.\n\n")
                stop()
            }
            
        } else if (imgSize == CONST.imgSize.inputFile)
            {
                #------------------------------------------
                #  Load ranks from zonation output files.  
                #------------------------------------------
                
                verbose = FALSE
                
                cat ("\n\n*** Loading ranks from asc file.\n\n")
                
                #corZonationRanks = 
                #    read.asc.file.to.matrix (corRankFileNameBase, input.dir = "/Users/Bill/tzar/outputdata/Guppy/WindowsRuns/101_Scen_1/Zonation/") #/Users/Bill/D/rdv-framework/projects/guppy/")
                corZonationRanks = 
                    read.asc.file.to.matrix (corRankFileNameBase, 
                                             input.dir = corInputDir)
                
                #appZonationRanks = 
                #    read.asc.file.to.matrix (appRankFileNameBase, input.dir = "/Users/Bill/tzar/outputdata/Guppy/WindowsRuns/101_Scen_1/Zonation/") #/Users/Bill/D/rdv-framework/projects/guppy/")
                appZonationRanks = 
                    read.asc.file.to.matrix (appRankFileNameBase, 
                                             input.dir = appInputDir)
                
                imgSize = length (corZonationRanks)
                appSize = length (appZonationRanks)
                if (appSize != imgSize)
                {
                    cat ("\n\nCorrect and apparent rank files must be same size.",
                         "\nCor size = ", imgSize, ", and App size = ", appSize, 
                         "\nQuitting.\n\n")
                    stop()
                }
                
            } else
            {
            #--------------------------
            #  Generate random ranks.  
            #--------------------------
            
        cat ("\n\n*** Generating random ranks.\n\n")
            
        appZonationRanks = sample (1:imgSize, imgSize, replace=FALSE)
        cat ("\n\n    appZonationRanks = '", appZonationRanks, "'", sep=',')
        
        corZonationRanks = sample (1:imgSize, imgSize, replace=FALSE)
        cat ("\n\n    corZonationRanks = '", corZonationRanks, "'", sep=',')        
        }
            
        #------------------------------------------------
        #  Determine the plot intervals on x axis based 
        #  on the number of ranks in the files.
        #------------------------------------------------
        
    numRanks = imgSize
    cat ("\n\n    numRanks = '", numRanks, "'", sep='')

    if (numRanks < numPlotIntervals)
        {
        cat ("\n\nNot enough points to allow plotting ", numPlotIntervals, 
             " intervals.", sep='')
        stop()
        }
    
    if ((numRanks %% numPlotIntervals) == 0)
        {
        xInterval = round (numRanks / numPlotIntervals)
        }  else  
        {
        xInterval = 1 + (floor (numRanks / numPlotIntervals))
        }
    
    cat ("\n\n    xInterval = '", xInterval, "'", sep='')
    
    pointsToPlotX = (1:numPlotIntervals) * xInterval
    cat ("\n\n    pointsToPlotX = '", pointsToPlotX, "'", sep=',')
    
    if (pointsToPlotX [numPlotIntervals] > numRanks)  
        pointsToPlotX [numPlotIntervals] = numRanks
    cat ("\n\n    pointsToPlotX = '", pointsToPlotX, "'", sep=',')
        
        #------------------------------------------------
        #  Find the locations of each of the app ranks.
        #------------------------------------------------
        
    positionOfAppRanks = order (appZonationRanks, decreasing=TRUE)
    if (verbose)
        {
        cat ("\n\n    positionOfAppRanks = '", positionOfAppRanks, "'", sep=',')        
        cat ("\n    app [positionOfAppRanks] = '", appZonationRanks [positionOfAppRanks], "'", sep=',')
        cat ("\n    cor [positionOfAppRanks] = '", corZonationRanks [positionOfAppRanks], "'", sep=',')        
        }
        
    positionOfCorRanks = order (corZonationRanks, decreasing=TRUE)
        if (verbose)
        {
        cat ("\n\n    positionOfCorRanks = '", positionOfCorRanks, "'", sep=',')
        cat ("\n    app [positionOfCorRanks] = '", appZonationRanks [positionOfCorRanks], "'", sep=',')
        cat ("\n    cor [positionOfCorRanks] = '", corZonationRanks [positionOfCorRanks], "'", sep=',')        
        }
        
        #---------------------------------------------------------
        #  Zonation appears to express ranks as decimal numbers 
        #  between 0 and 1 with better scores being closer to 1, 
        #  rather than the usual sort of rank that uses integers 
        #  and 1 is best, 2 is second best, etc.
        #  Also, the Zonation rank files have a border composed 
        #  of the value -1 at all pixel locations on the edge 
        #  of the image.
        #---------------------------------------------------------

                    ###  TOSS THIS SECTION COMPLETELY ???
        
                            ###appTPRank = (appZonationRanks [positionOfAppRanks] >= 
                            ###corZonationRanks [positionOfAppRanks])
                            ###cat ("\n\n    appTPRank = '", appTPRank, "'", sep=',')
    
                            ###curveOfCorRankOfAppRank = cumsum (appTPRank)
                            ###cat ("\n\n    curveOfCorRankOfAppRank = '", curveOfCorRankOfAppRank, "'", sep=',')
                            
                            ###fractionalCurveOfCorRankOfAppRank = curveOfCorRankOfAppRank / numRanks
                            ###cat ("\n\n    fractionalCurveOfCorRankOfAppRank = '", fractionalCurveOfCorRankOfAppRank, "'", sep=',')

        #  Should do this loop for random values as well, 
        #  since it seems like the zonation results are barely 
        #  better than random.
        
    numTPRanks = rep(-1,numPlotIntervals)
    fracTPRanks = rep(0,numPlotIntervals)
    fracTPRanksMinus.1 = rep(0,numPlotIntervals)
        
    for (curIdx in 1:numPlotIntervals)
        {
        n = pointsToPlotX [curIdx]
        cat ("\n----------------\nAt curIdx = ", curIdx, ", n = ", n, sep='')
        
        topNAppLocs = positionOfAppRanks [1:n]
        
        corTopNThresholdValue = corZonationRanks [positionOfCorRanks [n]]
        cat ("\n    corTopNThresholdValue = ", corTopNThresholdValue)

        corTopNThresholdValueMinus.1 = max (corTopNThresholdValue - buffer, 0)
        cat ("\n    corTopNThresholdValueMinus.1 = ", corTopNThresholdValueMinus.1)
        
##        TPs = (corZonationRanks [topNAppLocs] >= corTopNThresholdValue)
        
##        numTPRanks [curIdx] = sum (TPs)
##        cat ("\n    numTPRanks [", curIdx, "] = ", numTPRanks [curIdx])
        
##        fracTPRanks [curIdx] = numTPRanks [curIdx] / n
##        cat ("\n    fracTPRanks [curIdx] = ", fracTPRanks [curIdx])

        fracTPRanks [curIdx] = sum (corZonationRanks [topNAppLocs] >= corTopNThresholdValue) / n
        cat ("\n    fracTPRanks [curIdx] = ", fracTPRanks [curIdx])

        fracTPRanksMinus.1 [curIdx] = sum (corZonationRanks [topNAppLocs] >= corTopNThresholdValueMinus.1) / n
        cat ("\n    fracTPRanksMinus.1 [curIdx] = ", fracTPRanksMinus.1 [curIdx])

        if (verbose)
            {            
            cat ("\n\n    topNAppLocs = ")
            print (topNAppLocs)
            cat ("\n    appZonationRanks [topNAppLocs] = ", appZonationRanks [topNAppLocs])
            cat ("\n    corZonationRanks [topNAppLocs] = ", corZonationRanks [topNAppLocs])
            cat ("\n    TPs = ", TPs)
            }        
        }

    cat ("\n\n==================================================")

    cat ("\n\n    xInterval = '", xInterval, "'", sep='')        
  ##  cat ("\nnumTPRanks = ")
  ##  print (numTPRanks)
    cat ("\nfracTPRanks = ")
    print (fracTPRanks)
    cat ("\nfracTPRanksMinus.1 = ")
    print (fracTPRanksMinus.1)
        
        #  Create labels for x axis.
            #  Old code labelled X axis with absolute ranks but 
            #  normalized to 0-1 makes it easier to compare among 
            #  graphs.  
            #  This may not be exactly exactly correct in that 
            #  the pixel at rank 0.1 might not have a normalized 
            #  rank in Zonation of 0.1 since there could have been 
            #  ties?  Close enough though...
    ###topXOfRandomDiagonal = numRanks
    ###xValues = c(0,pointsToPlotX)
    topXOfRandomDiagonal = 1
    pointsToLabelX = (1:numPlotIntervals) / numPlotIntervals
        cat ("\n\n    pointsTo:LabelX = '", pointsToLabelX, "'", sep=',')        
    xValues = c(0,pointsToLabelX)
        cat ("\n\n    xValues = '", xValues, "'")
        
        #  Create labels for y axis.        
    #pointsToPlotY = fracTPRanks [pointsToPlotX]
    #cat ("\n\n    pointsToPlotY = '", pointsToPlotY, "'", sep=',')
    yValues = c(0,fracTPRanks)      #pointsToPlotY)
    cat ("\n    yValues = '", yValues, "'")
        
        #  See http://www.harding.edu/fmccown/r/ for simple example using 
        #  lots of options that would be useful here when I want to make 
        #  this fancier and/or save it to a file.
#         plot (xValues, yValues, 
#                          xlab="Apparent Rank", 
#                          ylab="True Positive Fraction",
#               type='l', 
#               col='red')
        plot (xValues, yValues, 
              ann=FALSE,
              xaxt='n', yaxt='n',
              #           xlab="Apparent Rank", 
              #           ylab="True Positive Fraction",
              type='l', 
              col='red')
        
    lines(xValues, c(0,fracTPRanksMinus.1),  #  TP for thresh - 0.1              
            type="l", lty=2,  # lwd=2
            col='blue'
            )
        
    lines(c(0,topXOfRandomDiagonal),c(0,1),  #  expected result for random selection              
            type="l", lty=3, # lwd=2
            col='black'
            )

text (0.8, 0.4, algLegendString) 
#    title(main=plotTitle)                
#         legend("right", 
#                c(algLegendString,
#                  paste ("TP for thresh - ", buffer, sep=''), 
#                  "random selection"), 
#                cex=0.9, #col=plot_colors, 
#                lty=1:3, #lwd=2, 
#                bty="n",
#                col=c('red','blue','black')
#         );
        
    }

#test(18)
testHardCodedMatrix = function (seed=18, verbose=FALSE, 
                                buffer=CONST.defaultBufSize)
    {
    testDir = "/Users/Bill/D/rdv-framework/projects/guppy/"
    corTestRankFileNameBase = "small.z.rank.test.cor" 
    appTestRankFileNameBase = "small.z.rank.test.app"
    
    imgSize = -1
    numPlotIntervals = 5
    test (CONST.imgSize.hardCodedMatrix, 
            numPlotIntervals,                      
            corRankFileNameBase, 
            appRankFileNameBase, 
            testDir,
            testDir,
            "hard-coded matrix",
            seed,
            verbose,
            buffer=buffer
            )
    }

testZonation = function (numPlotIntervals=100, seed=18, 
                         verbose=FALSE,
                         buffer=CONST.defaultBufSize)
    {
#     zonationInputDir = "/Users/Bill/tzar/outputdata/Guppy/WindowsRuns/101_Scen_1/Zonation/"
#     corRankFileNameBase="zonation_app_output.rank"
#     appRankFileNameBase="zonation_cor_output.rank"

    zonationInputDir = "/Users/Bill/tzar/outputdata/g2/default_runset/WindowsRuns/33_UpperRight256/Zonation/"
    corRankFileNameBase="zonation_app_output.rank"
    appRankFileNameBase="zonation_cor_output.rank"
    
    test (CONST.imgSize.inputFile, 
             numPlotIntervals, 
             corRankFileNameBase, 
             appRankFileNameBase, 
             zonationInputDir,
             zonationInputDir,
            "zonation",
             seed,
             verbose,
             buffer=buffer
            )
    }

testMaxent = function (startSppNum=1, endSppNum=1, 
                       numPlotIntervals=100, seed=18, 
                       verbose=FALSE, 
                       buffer=CONST.defaultBufSize)
    {
    op = par()
    par (mfrow=c(10,10), mar=c(0.1,0.1,0.1,0.1))
    
        #  2013.05.16 - BTL
        #  WARNING:  NOT SURE IF THIS IS CORRECT FOR MAXENT.
        #               THE MAXENT EVALUATION CODE DOES SOME 
        #               NORMALIZING OF VARIOUS FILES BEFORE 
        #               COMPUTING ERRORS AND THIS DOESN'T 
        #               TAKE THAT INTO ACCOUNT.  
        #               ALSO, NOT SURE IF THIS WORKS EXACTLY 
        #               THE SAME FOR PROBABILITIES AS IT DOES 
        #               FOR ZONATION'S NORMALIZED RANKS.
        #               NEED TO GO BACK AND VERY CAREFULLY 
        #               EVALUATE ALL OF THIS.  I THINK THAT 
        #               THE BASIC IDEA IS PROBABLY RIGHT, BUT 
        #               PROBABLY STILL NEEDS SOME TWEAKING.
#     corMaxentInputDir = "/Users/Bill/tzar/outputdata/Guppy/WindowsRuns/101_Scen_1/MaxentGenOutputs/"
#     appMaxentInputDir = "/Users/Bill/tzar/outputdata/Guppy/WindowsRuns/101_Scen_1/MaxentOutputs/"

    corMaxentInputDir = "/Users/Bill/tzar/outputdata/g2/default_runset/WindowsRuns/33_UpperRight256/SppGenOutputs/"
    appMaxentInputDir = "/Users/Bill/tzar/outputdata/g2/default_runset/WindowsRuns/33_UpperRight256/MaxentOutputs/"
    

    for (curSppNum in startSppNum:endSppNum)
        {
#        sppFileNameBase = paste ("spp.", curSppNum, sep='')

        corSppFileNameBase = paste ("true.prob.dist.spp.", curSppNum, sep='')
        appSppFileNameBase = paste ("spp.", curSppNum, sep='')
        
        test (CONST.imgSize.inputFile, 
                numPlotIntervals, 
                corSppFileNameBase, 
                appSppFileNameBase, 
                corMaxentInputDir,
                appMaxentInputDir,
#                paste ("maxent spp ", curSppNum, sep=''), 
              paste(curSppNum),
                seed,
                verbose, 
                buffer=buffer
                )
        }
#    par (mfrow=c(1,1))
    par (op)
    }

testRandom = function (imgSize=25, numPlotIntervals=5, 
                       seed=18, verbose=FALSE, 
                       buffer=CONST.defaultBufSize)
    {
    test (imgSize, 
            numPlotIntervals, 
            '', 
            '', 
            '', 
            '', 
            'testRandom',
            seed,
            verbose, 
#            plotTitle="testRandom TP of apparent ranks",
            buffer=buffer
            )
    }

#setwd ("/Users/Bill/D/rdv-framework/projects/guppy")
#source ("analyzeZonationResults.R")
testAll = function (bufSize=CONST.defaultBufSize)
{
    #    testMaxent (1,100, buffer=bufSize)
    #    testMaxent (1,20, buffer=bufSize)
    testHardCodedMatrix (buffer=bufSize)
    testRandom (buffer=bufSize)
    testZonation (buffer=bufSize)
}
bufSize=CONST.defaultBufSize

