
setwd ("/Users/Bill/D/rdv-framework/projects/aMinusBoverAplusB")
getwd ()

# A,B values to use (from Lola in combinations.xlsx)
# A/B    A	B				
# ~1	530	570	5.19E-02	5.15E-02	1.01E+00
# 1.13  550 530 5.89E-02    5.19E-02    1.13E+00
# 1.71  720 740 0.26 	    0.152 	    1.71E+00
# 1.5	550	510	5.89E-02	3.25E-02	1.81E+00	
# 2	    700	670	5.93E-02	2.99E-02	1.98E+00	
# 4	    800	705	3.13E-01	7.94E-02	3.94E+00	
# 6	    800	550	3.13E-01	5.89E-02	5.31E+00	
# 10	800	670	3.13E-01	2.99E-02	1.05E+01	this would be the NDVI, for this spectrum the ratio is even higher

A_wavelengths = c ("530", "550", "720", "550", "700", "800", "800", "800")
B_wavelengths = c ("570", "530", "740", "510", "670", "705", "550", "670")
A_values = c (5.19E-02, 5.89E-02, 0.260, 5.89E-02, 5.93E-02, 3.13E-01, 3.13E-01, 3.13E-01)
B_values = c (5.15E-02, 5.19E-02, 0.152, 3.25E-02, 2.99E-02, 7.94E-02, 5.89E-02, 2.99E-02)
AoverB_values = c (1.01E+00, 1.13E+00, 1.71E+00, 1.81E+00, 1.98E+00, 3.94E+00, 5.31E+00, 1.05E+01)
AoverB_fileLabels = c ("AoverB_1.01__A_5.19E-02__B_5.15E-02__", 
                       "AoverB_1.13__A_5.89E-02__B_5.19E-02__", 
                       "AoverB_1.71__A_0.26__B_0.152__", 
                       "AoverB_1.81__A_5.89E-02__B_3.25E-02__", 
                       "AoverB_1.98__A_5.93E-02__B_2.99E-02__", 
                       "AoverB_3.94__A_3.13E-01__B_7.94E-02__", 
                       "AoverB_5.31__A_3.13E-01__B_5.89E-02__", 
                       "AoverB_10.5__A_3.13E-01__B_2.99E-02__")


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

library(lattice)
library(MASS)

makeLevelPlots = function (numRows, numCols, mat, plot.title, csv.filename)
    {
    #  Legend values here refer to the plot legends, 
    #  while Data values refer to the values in the matrix.
    minLegendVal = 0.0   
    maxLegendVal = 20.0
    
    numCutPts = 200
    cutPts <- seq (minLegendVal, maxLegendVal, maxLegendVal/numCutPts)
    
    #  Create the first matrix so that it has high values that are 
    #  still within the range of the legend's values.
    #  Plot the matrix.
    minDataVal = 0.0
    maxDataVal = maxLegendVal
    #    mat <- matrix (runif (numRows*numCols, minDataVal, maxDataVal), nrow=numRows, ncol=numCols)
    
    #    write.csv (mat, file=csv.filename, row.names=FALSE, col.names=NA)
    write.matrix(mat, file = csv.filename, sep = ",")
    
    plot (levelplot (mat,
                     pretty=FALSE,
                     at=cutPts,
                     xlab = "Error in A",
                     ylab = "Error in B",
                     col.regions=colorRampPalette(c("blue","yellow","red")),
                     main=plot.title
                     )
          )    
    }

computeErrors = function (index.appMat, index.cor, largestInputErr.absValMat)
    {
    absErrMat = index.appMat - index.cor
    relErrMat = absErrMat / index.cor
    errMagMat = abs (relErrMat) / largestInputErr.absValMat
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
    
    return (list (absErr=absErrMat, relErr=relErrMat, errMag=errMagMat))
    }

#par (mfrow = c (1,3))    #  pdf() seems to ignore this, so commenting out...

pdf ("aOverBplots.pdf")

for (kkk in 1:length (AoverB_values))
    {
    # A.cor = 0.22
    # B.cor = 0.20
    A.cor = A_values [kkk]
    B.cor = B_values [kkk]
    
    minFracErr = -0.1
    maxFracErr = 0.1
    fracErrStepSize = 0.001
    
 
    A.errSeq = seq (from = minFracErr, to = maxFracErr, by = fracErrStepSize)
    B.errSeq = A.errSeq
    
    A.errMultSeq = 1 + A.errSeq
    B.errMultSeq = 1 + B.errSeq
    
    numRows = length (A.errSeq)
    numCols = length (B.errSeq)
    
    largestInputErr.absValMat = matrix (NA, nrow = numRows, ncol = numCols, byrow = TRUE)
    
    AoverB.appMat = matrix (NA, nrow = numRows, ncol = numCols, byrow = TRUE)
    AminusB.appMat = matrix (NA, nrow = numRows, ncol = numCols, byrow = TRUE)
    AminusBoverAplusB.appMat = 
                        matrix (NA, nrow = numRows, ncol = numCols, byrow = TRUE)
    
    AoverB.cor = A.cor / B.cor
    AminusB.cor = A.cor - B.cor
    AminusBoverAplusB.cor = (A.cor - B.cor) / (A.cor + B.cor)
    
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
            AminusB.appMat [A.curRow, B.curCol] = 
                A.app - B.app        
            AminusBoverAplusB.appMat [A.curRow, B.curCol] = 
                (A.app - B.app) / (A.app + B.app)
            
                #  Compute which input error is larger.
            largestInputErr.absValMat [A.curRow, B.curCol] = 
                max (abs (A.errSeq [A.curRow]), abs (B.errSeq [B.curCol]))
            }
        }
    
    AoverB.errors = 
        computeErrors (AoverB.appMat, AoverB.cor, largestInputErr.absValMat)
    AminusB.errors = 
        computeErrors (AminusB.appMat, AminusB.cor, largestInputErr.absValMat)
    AminusBoverAplusB.errors = 
        computeErrors (AminusBoverAplusB.appMat, AminusBoverAplusB.cor, 
                       largestInputErr.absValMat)
    
    diff = AminusB.errors$absErr - AminusBoverAplusB.errors$absErr
    cat ("\n\n*** (A-B absErr) - ((A-B)/(A+B) absErr) = ", sum (diff), "\n")
    head (diff)
    cat ("\n\n***\n\n")
    
    
    AB.values.title.line = paste0 ("\n", 
                                   "A=", A_values [kkk], 
                                   ", B=", B_values [kkk], 
                                   ", A/B=", AoverB_values [kkk])
    
    plot.title = paste0 ("A/B\nAbsolute Error", AB.values.title.line)
    csv.filename = paste0 (AoverB_fileLabels [kkk], "AoverB.absErr", ".csv")
    makeLevelPlots (numRows, numCols, AoverB.errors$absErr, plot.title, csv.filename)
    
    plot.title = paste0 ("A-B\nAbsolute Error", AB.values.title.line)
    csv.filename = paste0 (AoverB_fileLabels [kkk], "AminusB.absErr", ".csv")
    makeLevelPlots (numRows, numCols, AminusB.errors$absErr, plot.title, csv.filename)
    
    plot.title = paste0 ("A-B/A+B\nAbsolute Error", AB.values.title.line)
    csv.filename = paste0 (AoverB_fileLabels [kkk], "AminusBoverAplusB.absErr", ".csv")
    makeLevelPlots (numRows, numCols, AminusBoverAplusB.errors$absErr, plot.title, csv.filename)
    
    
    
    plot.title = paste0 ("A/B\nRelative Error", AB.values.title.line)
    csv.filename = paste0 (AoverB_fileLabels [kkk], "AoverB.relErr", ".csv")
    makeLevelPlots (numRows, numCols, AoverB.errors$relErr, plot.title, csv.filename)
    
    plot.title = paste0 ("A-B\nRelative Error", AB.values.title.line)
    csv.filename = paste0 (AoverB_fileLabels [kkk], "AminusB.relErr", ".csv")
    makeLevelPlots (numRows, numCols, AminusB.errors$relErr, plot.title, csv.filename)
    
    plot.title = paste0 ("A-B/A+B\nRelative Error", AB.values.title.line)
    csv.filename = paste0 (AoverB_fileLabels [kkk], "AminusBoverAplusB.relErr", ".csv")
    makeLevelPlots (numRows, numCols, AminusBoverAplusB.errors$relErr, plot.title, csv.filename)
    
    
    
    plot.title = paste0 ("A/B\nError magnification", AB.values.title.line)
    csv.filename = paste0 (AoverB_fileLabels [kkk], "AoverB.errMag", ".csv")
    makeLevelPlots (numRows, numCols, AoverB.errors$errMag, plot.title, csv.filename)
    
    plot.title = paste0 ("A-B\nError magnification", AB.values.title.line)
    csv.filename = paste0 (AoverB_fileLabels [kkk], "AminusB.errMag", ".csv")
    makeLevelPlots (numRows, numCols, AminusB.errors$errMag, plot.title, csv.filename)
    
    plot.title = paste0 ("A-B/A+B\nError magnification", AB.values.title.line)
    csv.filename = paste0 (AoverB_fileLabels [kkk], "AminusBoverAplusB.errMag", ".csv")
    makeLevelPlots (numRows, numCols, AminusBoverAplusB.errors$errMag, plot.title, csv.filename)
    
    
    # write.table (results,
    #              file = paste (experiment.name, ".csv", sep = ''),
    #              sep = ",",
    #              col.names = TRUE,
    #              row.names = FALSE
    # );
    
    }

dev.off()

