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

    print "\n\n====>>  In readAscFileToMatrix(), \n" + \
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

#===============================================================================

# THIS ALSO NEEDS TO BE MODIFIED TO HANDLE THE REMOTE URL LOOKUP CASE.
# IT MAY BE BETTER TO DO THAT AS A SEPARATE FUNCTION, BUT I'LL CHECK THAT
# OUT LATER.  JUST WANT TO GET THIS TO DO SOMETHING FOR THE MOMENT...

        #  This is a utility that will end up elsewhere as well as being used
        #  to replace the code that it was cloned from.
        #  Cloned from GuppyGenTrueRelProbPres.py function getTrueRelProbDistMapsForAllSpp().
        #  Currently (2013.09.19), this code is in the area of lines 269-341.

        #  NOTE:  The file handling logic below is derived from code at:
        #      http://stackoverflow.com/questions/1274506/how-can-i-create-a-list-of-files-in-the-current-directory-and-its-subdirectories

from pprint import pprint
import glob
import fnmatch
import os
import shutil

    #----------

def buildNamesOfSrcFiles (srcDir, filespec):
        #  Get a list of the source files to copy from.
        #  The copy command will need the names to have their full path
        #  so include that for each file name retrieved.
    srcFiles = []
    for root, dirs, files in os.walk (srcDir):
        srcFiles += glob.glob (os.path.join (root, filespec))
    print "\n\nsrcFiles = "
    pprint (srcFiles)
    print "\n\n"

    return srcFiles

    #----------

def buildDestFileRootNames (srcDir, filespec):

        #  Need a list of the destination names for the file copies.
        #  Want the results of the copy to have the same root file names,
        #  so get the source file names without the path prepended.
    fileRootNames = []
    for root, dirs, files in os.walk (srcDir):
        fileRootNames += fnmatch.filter (files, filespec)
    print "\n\nfilesRootnames = "
    pprint (fileRootNames)
    print "\n\n"

    return fileRootNames

    #----------

def buildNamesOfDestFiles (srcDir, filespec, targetDirWithSlash):

    fileRootNames = buildDestFileRootNames (srcDir, filespec)

    destFilesPrefix = targetDirWithSlash
    destFiles = [destFilesPrefix + fileRootNames[i] for i in range (len (fileRootNames))]
    pprint (destFiles)
    print "\n\n"

    return destFiles

    #----------

def copyFiles (srcFiles, destFiles):

        #  Have src and dest file names now, so copy the files.
    for k in range (len (srcFiles)):
        shutil.copyfile (srcFiles [k], destFiles [k])

    print "\n\nDone copying files...\n\n"

    #----------

# def copyFiles_Matt (srcDir, filespec, targetDirWithSlash = "./tempTarget/"):
#
#     srcFiles = buildNamesOfSrcFiles (srcDir, filespec)
#     destFiles = buildNamesOfDestFiles (srcDir, filespec, targetDirWithSlash)
#
#     copyFiles (srcFiles, destFiles)

#=========================================================================================

