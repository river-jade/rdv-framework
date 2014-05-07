#===============================================================================
#
#               ndviPaper_denseRangeWithAggregationPlot.R
#
#===============================================================================

#                   Abbreviations used in this code

#  cor = correct
#  app = apparent, i.e., correct plus error
#  err = error
#  abs = absolute
#  absVal = absolute value
#  frac = fractional
#  rel = relative
#  seq = sequence
#  mult = multiplier
#  mat = matrix
#  cur = current
#  mag = magnification

#===============================================================================

#library(lattice)
library(MASS)    #  Needed for write.matrix().

setwd ("/Users/Bill/D/rdv-framework/projects/aMinusBoverAplusB")
getwd ()

use_oldAoverB_values = FALSE
saveErrors = FALSE
verbose = TRUE
top = 5

showFullPlotSet = FALSE

#===============================================================================

computeErrors = function (index.appMat, index.cor, largestInputErr.absValMat)
    {
    if (verbose)
        {
        cat ("\n\nvvvvvvvvvvvvvvvvvvvv  In computeErrors()  vvvvvvvvvvvvvvvvvvvv")
        cat ("\n\nindex.appMat = ")
        print (index.appMat[1:top,1:top])
        cat ("\n\nindex.cor = ", index.cor, sep='')
        cat ("\n\nlargestInputErr.absValMat = ")
        print (largestInputErr.absValMat)
        }

    absErrMat = index.appMat - index.cor
    if (verbose)
        {
        cat ("\n\nabsErrMat = ")
        print (absErrMat[1:top,1:top])
        }

    absErrMat.absVal = abs (absErrMat)
    if (verbose)
        {
        cat ("\n\nabsErrMat.absVal = ")
        print (absErrMat.absVal[1:top,1:top])
        }

    relErrMat = absErrMat / index.cor
    if (verbose)
        {
        cat ("\n\nrelErrMat = ")
        print (relErrMat[1:top,1:top])
        }

    relErrMat.absVal = abs (relErrMat)
    if (verbose)
        {
        cat ("\n\nrelErrMat.absVal = ")
        print (relErrMat.absVal[1:top,1:top])
        }

    errMagMat = abs (relErrMat) / largestInputErr.absValMat
    if (verbose)
        {
        cat ("\n\nerrMagMat BEFORE zero correction = ")
        print (errMagMat[1:top,1:top])
        }

    #  BTL - 2014 03 19 - bug fix
    #  A problem occurs when the input errors are both zero.
    #  There is neither amplification nor correction then, so the
    #  magnification value should be 1.
    #  Instead, here you will divide by 0 and get a NaN or else,
    #  your divisor will be a very small approximation to 0 due to
    #  inexact floating point arithmetic and you'll get some kind
    #  of calculation done with 0 (or approximately 0) in the numerator
    #  (since there's no error), and some minute value in the denominator.
    #  This will often give a result that is 0, which implies perfect
    #  correction of the input error, but there is no input error to
    #  correct.  So, need to explicitly fix that here by looking for
    #  any cell that has no input error.  This should only occur in
    #  one cell, i.e., the center of the matrix, so you should be
    #  able to just set that cell to 1.  Unfortunately, there's nothing
    #  to stop someone from handing this routine a matrix that doesn't
    #  have the zero point at the center of the matrix, so you need to
    #  explicitly test for it to be safe.
    #  The "isTrue (all.equal())" in the test below is to catch values
    #  that are not exactly 0 because of floating point arithmetic.
    #  It's taken from an answer I found in a stackoverflow answer:
    #  http://stackoverflow.com/questions/9508518/why-are-these-numbers-not-equal

    errMagMat [isTRUE (all.equal (largestInputErr.absValMat, 0))] = 1
    #    errMagMat [3,3] = 1
    if (verbose)
        {
        cat ("\n\nerrMagMat AFTER zero correction = ")
        print (errMagMat[1:top,1:top])
        cat ("\n\n^^^^^^^^^^^^^^^^^^^^^^  end of computeErrors()  ^^^^^^^^^^^^^^^^^^^^^^")
        }

    #browser()

    return (list (absErr=absErrMat, absErr.absVal=absErrMat.absVal,
                  relErr=relErrMat, relErr.absVal=relErrMat.absVal,
                  errMag=errMagMat))
    }

#===============================================================================

computeAggregateScores = function (aMatrix, curRow, aggScores, numCells,
                                   matrixIsErrMag=TRUE)
    {
    cat ("\n\n-------------- aMatrix [1:5,1:5] in computeAggregateScores --------------\n")
    print (aMatrix[1:5,1:5])

    aggScores [curRow, "median"] = median (aMatrix, na.rm=TRUE)
    aggScores [curRow, "mad"] = mad (aMatrix, na.rm=TRUE)

    if (matrixIsErrMag)
        {
        numNaNcells = length (which (is.na (aMatrix)))
        numLegalCells = numCells - numNaNcells

        lt1 = length (which (aMatrix < 1.0))
        aggScores [curRow, "fracErrMagLT1"] = lt1 / numLegalCells
        gt1 = length (which (aMatrix > 1.0))
        aggScores [curRow, "fracErrMagGT1"] = gt1 / numLegalCells
        eq1 = numCells - lt1 - gt1
        aggScores [curRow, "fracErrMagEQ1"] = eq1 / numLegalCells
        }

    quantileValues = quantile (aMatrix, na.rm=TRUE)
    aggScores [curRow, "min"] = quantileValues [1]
    aggScores [curRow, "quant25"] = quantileValues [2]
    aggScores [curRow, "quant50"] = quantileValues [3]
    aggScores [curRow, "quant75"] = quantileValues [4]
    aggScores [curRow, "max"] = quantileValues [5]

    aMatrix [is.infinite (aMatrix)] = NaN

    aggScores [curRow, "mean"] = mean (aMatrix, na.rm=TRUE)
    aggScores [curRow, "sd"] = sd (aMatrix, na.rm=TRUE)

    #browser()

    return (aggScores)
    }

#===============================================================================

plotErrMagAndCorrection = function (plotTitle,
                                    normDiff_aggScores,
                                    simpleRatio_aggScores,
                                    xAxisRange, yAxisRange,
                                    showReferenceLineForSimpleRatio=FALSE
                                    )
    {
    cat ("\n\nxAxisRange = ", xAxisRange)
    cat ("\nyAxisRange = ", yAxisRange)

    if (showReferenceLineForSimpleRatio)
        plotTitle = paste0 (plotTitle, "\n(same as above but smoothed values for simple ratio)")

    plot (normDiff_aggScores [,"AoverB"],
          normDiff_aggScores [,"fracErrMagLT1"],
          type="l",
          lty=1,
          main=plotTitle,
          xlab="A/B value",
          ylab="fraction with given err magnitude",
          xlim=xAxisRange,
          ylim=yAxisRange
          )

    lines (normDiff_aggScores [,"AoverB"],
           normDiff_aggScores [,"fracErrMagLT1"],
           lty=1
           )

    lines (normDiff_aggScores [,"AoverB"],
           normDiff_aggScores [,"fracErrMagGT1"],
           lty=3
           )

    if (showReferenceLineForSimpleRatio)
        {
        # add dashed horizontal line at y=0.5 for simple ratio.
        abline(h=0.5, lty=2)

        } else
        {
        lines (simpleRatio_aggScores [,"AoverB"],
               simpleRatio_aggScores [,"fracErrMagLT1"],
               lty=2
               )
        }

    # add red, solid vertical line at x=1
    abline(v=1, lty=1, col="red")

#    legendLocation=c(3.95,0.4)    #bottomright"
#    legend (legendLocation,
    legend (3.95, 0.4,
            c("NormDiff < 1 (correcting)", "NormDiff > 1 (magnifiying)", "Simple ratio"),
            lty=c(1,3, 2),
            cex=0.5
            )
    }

#===============================================================================

plotAggregateMeasure = function (plotTitle,
                                 statisticName,
                                 #                  errMeasureType,
                                 normDiff_aggScores,
                                 simpleRatio_aggScores,
                                 xAxisRange, yAxisRange,
                                 showReferenceLine=TRUE,
                                 autoscale = TRUE,
                                 legendLocation="topright"
)
{
    #    plotTitle = paste0 (plotTitleLead, " for ", errMeasureType)

    # plot (normDiff_aggScores [,"AoverB"],
    #       normDiff_aggScores [,statisticName],
    #       main=plotTitle,
    #       type="l", lty=1,
    #       xlim=c(0,6), xlab="A/B value",
    #       ylim=c(0,1), ylab=statisticName
    #       )

    cat ("\n\nxAxisRange = ", xAxisRange)
    cat ("\nyAxisRange = ", yAxisRange)
    cat ("\nautoscale = ", autoscale)

    if (autoscale)
    {
        cat ("\n--- autoscaling ---")
        plot (normDiff_aggScores [,"AoverB"],
              normDiff_aggScores [,statisticName],
              type="l",
              lty=1,
              main=plotTitle,
              xlab="A/B value",
              ylab=statisticName,
              xlim=xAxisRange
        )
    } else
    {
        cat ("\n--- NOT autoscaling ---")
        plot (normDiff_aggScores [,"AoverB"],
              normDiff_aggScores [,statisticName],
              type="l",
              lty=1,
              main=plotTitle,
              xlab="A/B value",
              ylab=statisticName,
              xlim=xAxisRange,
              #  The only part that's different from the autoscale above.
              ylim=yAxisRange
        )
    }

    lines (normDiff_aggScores [,"AoverB"],
           normDiff_aggScores [,statisticName],
           lty=1
    )

    lines (simpleRatio_aggScores [,"AoverB"],
           simpleRatio_aggScores [,statisticName],
           lty=2
    )

    # add red, solid vertical line at x=1
    abline(v=1, lty=1, col="red")

    if (showReferenceLine)
    {
        # add red, solid horizontal line at y=1
        abline(h=1, lty=1, col="red")
    }

    legend (legendLocation,
            c("Normalized difference", "Simple ratio"),
            lty=c(1,2),
            cex=0.5
    )
}

#===============================================================================

#  Here, we only care about stepping through the A/B values
#  from 0 up through around 10.
#  We don't care about their correspondence with the reflectance values
#  of any particular wavelengths.
#  Since the error results are the same for all A,B pairs with the same A/B
#  value, then we can set A and B to anything that we want as long as it
#  generates the A/B value we want.  (Note that this is only true for the
#  metrics A/B and (A-B)/(A+B).  It's not true for the A-B metric.  However,
#  in this paper we're ignoring that metric since it's hardly ever used.)
#  This means that we can just set B=1 and let A vary.  Conveniently, that
#  means that whatever value A has, that will be the value of A/B.


if (use_oldAoverB_values)
    {
    A_values = c (5.19E-02, 1.05E+00, 5.89E-02, 0.260, 5.89E-02, 5.93E-02, 3.13E-01, 3.13E-01)
    B_values = c (5.15E-02, 1.00E+00, 5.19E-02, 0.152, 3.25E-02, 2.99E-02, 7.94E-02, 5.89E-02)
    AoverB_values = c (1.01E+00, 1.05E+00, 1.13E+00, 1.71E+00, 1.81E+00, 1.98E+00, 3.94E+00, 5.31E+00)
    } else
    {
    A_values = c (seq (0.1, 2, 0.05), seq (2.25, 5, 0.25))
    B_values = rep (1, length (A_values))
    AoverB_values = A_values
    }

buildFileroot = function (A_value)
    { paste0 ("AoverB_", A_value, "__A_", A_value, "__B_1__") }

AoverB_fileLabels = buildFileroot (A_values)

numAoverBvalues = length (AoverB_values)

aggScoreColNames = c ("AoverB", "mean", "sd", "median", "mad",
                      "min", "quant25", "quant50", "quant75", "max",
                      "fracErrMagLT1", "fracErrMagEQ1", "fracErrMagGT1"
                      )

#par (mfrow = c (1,3))    #  pdf() seems to ignore this, so commenting out...


###############################  2014 05 07  ###################################
#pdf ("aOverBplots_aggregated_part1.pdf")

#tiff ("aOverBplots_aggregated_meanErrMap_sdErrMag.tiff")
#pdf ("aOverBplots_aggregated_meanErrMap_sdErrMag.pdf")
#png ("aOverBplots_aggregated_meanErrMap_sdErrMag.png")
svg ("aOverBplots_aggregated_meanErrMap_sdErrMag.svg")
################################################################################

    #---------------------------------------------------------------------
    #  Create empty dataframes to hold aggregated scores for each of the
    #  indices and measures.
    #---------------------------------------------------------------------

aggScoresTemplate =
    data.frame (
    matrix (NA, nrow=numAoverBvalues,
                                        ncol=length (aggScoreColNames),
                                        byrow=TRUE)
    )
names (aggScoresTemplate) = aggScoreColNames
aggScoresTemplate [,"AoverB"] = AoverB_values

AoverB_relErr_aggScores = aggScoresTemplate
AoverB_relErr.absVal_aggScores = aggScoresTemplate
AoverB_errMag_aggScores = aggScoresTemplate

AminusBoverAplusB_relErr_aggScores = aggScoresTemplate
AminusBoverAplusB_relErr.absVal_aggScores = aggScoresTemplate
AminusBoverAplusB_errMag_aggScores = aggScoresTemplate

#===============================================================================

    #---------------------------------------------------------------------------
    #  Compute aggregate scores for each index/measure pair for each A/B value.
    #
    #  Start by specifying the range and step size of error values to be
    #  computed over.  Very small step sizes will allow you to get very close
    #  to A/B=1 and will show huge blowups there in error magnfication.
    #  This can make the plot scaling hide all detail away from A/B=1 since
    #  the scale has to capture the huge blowups.  So, it's probably good not
    #  to have really tiny step sizes if you want to see detail in any other
    #  part of the error magnification plots away from A/B=1.
    #---------------------------------------------------------------------------

minFracErr = -0.1
maxFracErr = 0.1
#numSteps = 100
fracErrStepSize = 0.01    #maxFracErr / numSteps
#    fracErrStepSize = 0.05

#minFracErr = -0.01
#maxFracErr = 0.01
#fracErrStepSize = 0.001    #maxFracErr / numSteps

for (kkk in 1:numAoverBvalues)
    {
    A.cor = A_values [kkk]
    B.cor = B_values [kkk]

    A.errSeq = seq (from = minFracErr, to = maxFracErr, by = fracErrStepSize)
    B.errSeq = A.errSeq

    A.errMultSeq = 1 + A.errSeq
    B.errMultSeq = 1 + B.errSeq

    numRows = length (A.errSeq)
    numCols = length (B.errSeq)
    numCells = numRows * numCols

    largestInputErr.absValMat = matrix (NA, nrow = numRows, ncol = numCols, byrow = TRUE)

    AoverB.appMat = matrix (NA, nrow = numRows, ncol = numCols, byrow = TRUE)
    AminusBoverAplusB.appMat =
                        matrix (NA, nrow = numRows, ncol = numCols, byrow = TRUE)

    AoverB.cor = A.cor / B.cor
    AminusBoverAplusB.cor = (A.cor - B.cor) / (A.cor + B.cor)

        #-----------------------------------------------------------------------
        #  Build the matrix of apparent index values for the current A/B value.
        #-----------------------------------------------------------------------

    for (A.curRow in 1:numRows)
        {
        for (B.curCol in 1:numCols)
            {
                #  Compute apparent values of input variables A and B.
            A.app = A.cor * A.errMultSeq [A.curRow]
            B.app = B.cor * B.errMultSeq [B.curCol]

                #  Compute apparent values of indices.
            AoverB.appMat [A.curRow, B.curCol] =
                A.app / B.app
            AminusBoverAplusB.appMat [A.curRow, B.curCol] =
                (A.app - B.app) / (A.app + B.app)

                #  Compute which input error is larger.
            largestInputErr.absValMat [A.curRow, B.curCol] =
                max (abs (A.errSeq [A.curRow]), abs (B.errSeq [B.curCol]))
            }
        }

#browser()

    AoverB = AoverB_values [kkk]
    cat ("\n\n*** Loop is at AoverB = ", AoverB)

        #--------------
        #  A/B errors
        #--------------

    AoverB.errors =
        computeErrors (AoverB.appMat, AoverB.cor, largestInputErr.absValMat)

            #----------------------
            #  A/B relative error
            #----------------------

    cat ("\n\n----  AoverB : relative error")
    if (saveErrors)    #  AoverB : relative error
        {
        csv.filename = paste0 (AoverB_fileLabels [kkk], "AoverB.relErr", ".csv")
        write.matrix (AoverB.errors$relErr, file = csv.filename, sep = ",")
        }
    AoverB_relErr_aggScores =
        computeAggregateScores (AoverB.errors$relErr, kkk,
                                AoverB_relErr_aggScores, numCells, FALSE)

            #-----

    cat ("\n\n----  AoverB : relative error - absolute value")
    if (saveErrors)    #  AoverB : relative error absolute value
        {
        csv.filename = paste0 (AoverB_fileLabels [kkk], "AoverB.relErr.absVal", ".csv")
        write.matrix (AoverB.errors$relErr.absVal, file = csv.filename, sep = ",")
        }
    AoverB_relErr.absVal_aggScores =
        computeAggregateScores (AoverB.errors$relErr.absVal, kkk,
                                AoverB_relErr.absVal_aggScores, numCells, FALSE)

            #---------------------------
            #  A/B error magnification
            #---------------------------

    cat ("\n\n----  AoverB : error magnification")
    if (saveErrors)    #  AoverB : error magnification
        {
        csv.filename = paste0 (AoverB_fileLabels [kkk], "AoverB.errMag", ".csv")
        write.matrix (AoverB.errors$errMag, file = csv.filename, sep = ",")
        }
    AoverB_errMag_aggScores =
        computeAggregateScores (AoverB.errors$errMag, kkk,
                                AoverB_errMag_aggScores, numCells, TRUE)

        #------------------
        #  A-B/A+B errors
        #------------------

    AminusBoverAplusB.errors =
        computeErrors (AminusBoverAplusB.appMat, AminusBoverAplusB.cor,
                       largestInputErr.absValMat)

            #--------------------------
            #  A-B/A+B relative error
            #--------------------------

    cat ("\n\n----  AminusBoverAplusB : relative error")
    if (saveErrors)    #  AminusBoverAplusB : relative error
        {
        csv.filename = paste0 (AoverB_fileLabels [kkk], "AminusBoverAplusB.relErr", ".csv")
        write.matrix (AminusBoverAplusB.errors$relErr, file = csv.filename, sep = ",")
        }
    AminusBoverAplusB_relErr_aggScores =
        computeAggregateScores (AminusBoverAplusB.errors$relErr, kkk,
                                AminusBoverAplusB_relErr_aggScores, numCells, FALSE)

            #-----

    cat ("\n\n----  AminusBoverAplusB : relative error - absolute value")
    if (saveErrors)    #  AminusBoverAplusB : relative error absolute value
        {
        csv.filename = paste0 (AminusBoverAplusB_fileLabels [kkk], "AminusBoverAplusB.relErr.absVal", ".csv")
        write.matrix (AminusBoverAplusB.errors$relErr.absVal, file = csv.filename, sep = ",")
        }
    AminusBoverAplusB_relErr.absVal_aggScores =
        computeAggregateScores (AminusBoverAplusB.errors$relErr.absVal, kkk,
                                AminusBoverAplusB_relErr.absVal_aggScores, numCells, FALSE)

            #-------------------------------
            #  A-B/A+B error magnification
            #-------------------------------

    cat ("\n\n----  AminusBoverAplusB : error magnification")
    if (saveErrors)    #  AminusBoverAplusB : error magnification
        {
        csv.filename = paste0 (AoverB_fileLabels [kkk], "AminusBoverAplusB.errMag", ".csv")
        write.matrix (AminusBoverAplusB.errors$errMag, file = csv.filename, sep = ",")
        }
    AminusBoverAplusB_errMag_aggScores =
        computeAggregateScores (AminusBoverAplusB.errors$errMag, kkk,
                                AminusBoverAplusB_errMag_aggScores, numCells, TRUE)

    #-------------------------------
    # write.table (results,
    #              file = paste (experiment.name, ".csv", sep = ''),
    #              sep = ",",
    #              col.names = TRUE,
    #              row.names = FALSE
    # );
    #-------------------------------

    }


cat ('\nAminusBoverAplusB_relErr_aggScores [,"AoverB"] = \n')
print (AminusBoverAplusB_relErr_aggScores [,"AoverB"])

cat ('\nAminusBoverAplusB_relErr_aggScores [,"median"] = \n')
print (AminusBoverAplusB_relErr_aggScores [,"median"])



cat ("\n\n==================================================================\n")
cat ("\nAt end of loop, here are the aggregated scores:")

cat ("\n\nAoverB_relErr_aggScores = \n\n")
print (AoverB_relErr_aggScores)

cat ("\n\nAoverB_relErr.absVal_aggScores = \n\n")
print (AoverB_relErr.absVal_aggScores)

cat ("\n\nAminusBoverAplusB_relErr_aggScores = \n\n")
print (AminusBoverAplusB_relErr_aggScores)

cat ("\n\nAminusBoverAplusB_relErr.absVal_aggScores = \n\n")
print (AminusBoverAplusB_relErr.absVal_aggScores)

cat ("\n\nAoverB_errMag_aggScores = \n\n")
print (AoverB_errMag_aggScores)

cat ("\n\nAminusBoverAplusB_errMag_aggScores = \n\n")
print (AminusBoverAplusB_errMag_aggScores)

cat ("\n\n==================================================================\n")

xAxisRange = c(0, 5)
yAxisRange = c(0, 1)

#===============================================================================
#                       Plots for error magnification.
#===============================================================================

errMeasureType = "ErrMag"
normDiff_aggScores = AminusBoverAplusB_errMag_aggScores
simpleRatio_aggScores = AoverB_errMag_aggScores

    #------------------------------------------------
    #  Error CORRECTION and AMPLIFICATION of ErrMag
    #------------------------------------------------

        #-----------------------------------------------------------------------
        #  NOTE:  These 3 metrics only apply for error magnification
        #         since the relative error being above or below 1
        #         isn't of interest.
        #         Error magnification below 1 means error correction.
        #         Error magnfication above 1 means error amplification.
        #         Error magnification equal 1 means garbage in, garbage out.
        #    Also note that because these are all fractions, we can always scale
        #    the y axis to go from 0 to 1.  For other measures, we have to
        #    adapt the scale to the data.
        #-----------------------------------------------------------------------

if (FALSE)
{
if (showFullPlotSet)
{
par (mfrow = c (3,1))    #  pdf() seems to ignore this, so commenting out...
autoscale = FALSE

plotAggregateMeasure ("Fraction of cells with ErrMag < 1\n(i.e., error CORRECTING cells)",
                      "fracErrMagLT1",
#                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=FALSE,
                      autoscale=FALSE,
                      "bottomright"
                      )


plotAggregateMeasure ("Fraction of cells with ErrMag > 1\n(i.e., error AMPLIFYING cells)",
                      "fracErrMagGT1",
#                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=FALSE,
                      autoscale=FALSE,
                      "topright"
                      )

plotAggregateMeasure ("Fraction of cells with ErrMag = 1\n(i.e., garbage-in garbage-out cells)",
                      "fracErrMagEQ1",
#                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=FALSE,
                      autoscale=FALSE,
                      "topright"
                      )
}  #  end - if show full plot set

par (mfrow = c (2,1))
plotErrMagAndCorrection ("Fraction of cells amplifying or correcting errors",
                         normDiff_aggScores,
                         simpleRatio_aggScores,
                         xAxisRange, yAxisRange,
                         showReferenceLineForSimpleRatio=FALSE
                         )

plotErrMagAndCorrection ("Fraction of cells amplifying or correcting errors",
                         normDiff_aggScores,
                         simpleRatio_aggScores,
                         xAxisRange, yAxisRange,
                         showReferenceLineForSimpleRatio=TRUE
                         )

# statisticName = "min"
# statisticName = "max"
# statisticName = "quant25"
# statisticName = "quant75"
# statisticName = "quant50"
}##########

#-----------------------------
#  MEAN and SD as well as MEDIAN and MAD of ErrMag
#-----------------------------

#dev.off()
#tiff ("aOverBplots_aggregated_meanErrMap_sdErrMag.tiff")
#png ("aOverBplots_aggregated_meanErrMap_sdErrMag.png")
#svg ("aOverBplots_aggregated_meanErrMap_sdErrMag.svg")

#par (mfrow = c (2,2))
############par (mfrow = c (2,1))
par (mfrow = c (1,2))

plotAggregateMeasure ("Mean Error Magnification\nacross A/B values",
                      "mean",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=TRUE,
                      autoscale=TRUE,
                      "topright"
                    )

plotAggregateMeasure ("SD of Error Magnification\nacross A/B values",
                      "sd",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=FALSE,
                      autoscale=TRUE,
                      "topright"
                    )

dev.off()  #############

if (showFullPlotSet)
{
plotAggregateMeasure ("Median Error Magnification\nacross A/B values",
                      "median",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=TRUE,
                      autoscale=TRUE,
                      "topright"
)

plotAggregateMeasure ("Median Abs Dev of Error Magnification\nacross A/B values",
                      "mad",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=FALSE,
                      autoscale=TRUE,
                      "topright"
)

    #-----------------------------
    #  QUANT25 and QUANT75 of ErrMag
    #-----------------------------

#dev.off()
pdf ("aOverBplots_aggregated_part2.pdf")

par (mfrow = c (2,2))    #  pdf() seems to ignore this, so commenting out...
#yAxisRange = c(0,3)

plotAggregateMeasure ("25% quantile of Error Magnification\nacross A/B values",
                      "quant25",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=TRUE,
                      autoscale=TRUE,
                      "topright"
                    )

plotAggregateMeasure ("BLOWUP OF: 25% quantile of Error Magnification\nacross A/B values",
                      "quant25",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange=c(0,3),
                      showReferenceLine=TRUE,
                      autoscale=FALSE,
                      "topright"
                    )

plotAggregateMeasure ("75% quantile of Error Magnification\nacross A/B values",
                      "quant75",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=TRUE,
                      autoscale=TRUE,
                      "topright"
                    )

plotAggregateMeasure ("BLOWUP OF: 75% quantile of Error Magnification\nacross A/B values",
                      "quant75",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange=c(0,3),
                      showReferenceLine=TRUE,
                      autoscale=FALSE,
                      "topright"
                    )

#===============================================================================
#                           Plots for relative error.
#===============================================================================

errMeasureType = "RelErr"
normDiff_aggScores = AminusBoverAplusB_relErr_aggScores
simpleRatio_aggScores = AoverB_relErr_aggScores

#-----------------------------
#  MEAN and MEDIAN as well as SD and MAD of Relative Error
#-----------------------------

par (mfrow = c (2,2))    #  pdf() seems to ignore this, so commenting out...
#yAxisRange = c(0,3)

plotAggregateMeasure ("Mean Relative Error\nacross A/B values",
                      "mean",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=TRUE,
                      autoscale=TRUE,
                      "topright"
)

plotAggregateMeasure ("Standard deviation of Relative Error\nacross A/B values",
                      "sd",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=FALSE,
                      autoscale=TRUE,
                      "topright"
)

plotAggregateMeasure ("Median Relative Error\nacross A/B values",
                      "median",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=TRUE,
                      autoscale=TRUE,
                      "topright"
)

plotAggregateMeasure ("Median absolute deviation of Relative Error\nacross A/B values",
                      "mad",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=FALSE,
                      autoscale=TRUE,
                      "topright"
)

}  #  end - if show full plot set

#===============================================================================
#                   Plots for relative error absolute value.
#===============================================================================

errMeasureType = "RelErr.absVal"
normDiff_aggScores = AminusBoverAplusB_relErr.absVal_aggScores
simpleRatio_aggScores = AoverB_relErr.absVal_aggScores

#-----------------------------
#  MEAN and MEDIAN as well as SD and MAD of Relative Error
#-----------------------------

#par (mfrow = c (2,2))
par (mfrow = c (2,1))

#yAxisRange = c(0,3)

plotAggregateMeasure ("Mean Abs Value Of Relative Error\nacross A/B values",
                      "mean",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=FALSE,
                      autoscale=TRUE,
                      "topright"
                      )

plotAggregateMeasure ("Standard deviation of Abs Value Of Relative Error\nacross A/B values",
                      "sd",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=FALSE,
                      autoscale=TRUE,
                      "topright"
)

if (showFullPlotSet)
{
plotAggregateMeasure ("Median Abs Value Of Relative Error\nacross A/B values",
                      "median",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=FALSE,
                      autoscale=TRUE,
                      "topright"
)

plotAggregateMeasure ("Median absolute deviation of Abs Value Of Relative Error\nacross A/B values",
                      "mad",
                      #                      errMeasureType,
                      normDiff_aggScores,
                      simpleRatio_aggScores,
                      xAxisRange, yAxisRange,
                      showReferenceLine=FALSE,
                      autoscale=TRUE,
                      "topright"
)
}  #  end - if show full plot set

#===============================================================================

diffBetweenMedianAndMean = normDiff_aggScores [,"median"] - normDiff_aggScores [,"mean"]

dev.off()

#===============================================================================


