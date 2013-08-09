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

#=========================================================================================

