#=========================================================================================

#                       guppySupportFunctions.py

#  Usage:
#      import guppySupportFunctions

#=========================================================================================

#  History:

#  2013.08.09 - BTL
#  Started converting from R to python.

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#=========================================================================================

from re import split
import numpy
import csv

#=========================================================================================

    #  NOTE: The R version of this routine seems to have been wrong.
    #        For one thing, it only asked for the number of columns
    #        rather than both rows and columns, since it assumed that
    #        the image would be square.
    #        Not sure if everything else about the routine was right.
    #        Needs to be tested if it's going to be used again.
    #        This routine could be converted back to R, but if so,
    #        need to modify to account for the fact that python arrays
    #        start at 0 and R arrays start at 1.

def xyRelToLowerLeft (n, numRows, numCols):
    """  Compute the x,y coordinates of a given
    index into the image array where the index starts with 0 in the
    UPPER left and goes row by row.  The x,y coordinates that are
    output (to give to maxent) have their origin in the LOWER left
    and go row by row upward like a typical x,y plot.
    Also, numbering of the rows and columns in the output considers
    the origin to be just outside the array, so that the lower left
    corner of the array is called location [1,1] instead of [0,0].
    """

        #  (n // numCols) gives the number of rows from the top of the arrray.

    return [ (n % numCols) + 1   ,   numRows - (n // numCols) ]

#===============================================================================

def strOfCommaSepNumbersToVec (numberString):
    '''Take a string of numbers separated by commas or spaces and
    turn it into an array of numbers.'''

        #  Break up the string into a string for each number, then
        #  convert each of these substrings into an integer individually.

    strValues = re.split (r"[, ]", numberString)

    return [int (aNumString) for aNumString in strValues]

#=========================================================================================

    #  Derived from same function in read.R file of R version of guppy.
    #  BTL - 2013.08.12

def readAscFileToMatrix (baseAscFilenameToRead, numRows, numCols, inputDir = ""):

    nameOfFileToRead = baseAscFilenameToRead + ".asc"    #  extension should be made optional...
    filenameHandedIn = inputDir + nameOfFileToRead

    print "\n\n====>>  In read.asc.file.to.matrix(), \n" + \
		"\tnameOfFileToRead = '" + nameOfFileToRead + "\n" + \
		"\tbaseAscFilenameToRead = '" + baseAscFilenameToRead + "\n" + \
		"\tinput.dir = '" + inputDir + "\n" + \
		"\tfilenameHandedIn = '" + filenameHandedIn + "\n"

#  ascFileAsMatrix = \
#      as.matrix (read.table (paste (input.dir, nameOfFileToRead, sep=''),
#	                       skip=6))

    numHeaderLines = 6
    ascFileAsMatrix = numpy.zeros ((numRows, numCols))

        #  csv reading code here is based on example in:
        #      http://pymotw.com/2/csv/#module-csv
    f = open (filenameHandedIn, 'rt')
    try:
        reader = csv.reader(f, delimiter=' ')

            #  Skip header lines.
        for k in range (numHeaderLines):
            next (reader)

            #  Read lines after header and convert them from strings to
            #  numbers since the csv reader only returns them as strings.
        nonHeaderLineNum = 0
        for row in reader:
            ascFileAsMatrix [nonHeaderLineNum,:] = row
            nonHeaderLineNum += 1

    finally:
        f.close()

    return ascFileAsMatrix

#=========================================================================================

