# Version: Sunday 12th March 2006
#
# Array Utilities, including populate from file, filter.
# Also contains file utilities which use arrays to hold
# the data that has been read.
#
# Lucy Bastin 8th March 2006
#

import os, sys, math, string
from numpy import *

# Functions for reading arrays from file
# 

# readASCIIarray: arguments are
# the file name (full path)
# type (a string, the same as the Python array definition strings)
#     Int, Character, Float (and NOT Complex!)
# colNo - number of columns: this is necessary because programs like RULE write a
# string of more than 1000 characters across several lines, so we may need to skip down.
#
# file should be space-delimited - no spaces within values are currently possible
# NB - if "Int" is specified, the reader will throw an error if it
# encounters floating point values. However, "Float" will read Integers.
# "Character" should take the first letter of each string it encouters, but is untested
# as of 10/3/06
#
# returns the loaded array, plus its width and height
#
def readASCIIarray(filename, type, cn):

    print "-----------------------------"
    print "Reading %s" % filename
    print "-----------------------------\n"
    f = open(filename,'r')
    firstline = f.readline()

    linesToRead = 1 #default will be reading just one line, with all the values on it
    
    # print "Line length is %d" % len(firstline)
    # Split the line (by default, on whitespace) and see how many elements there are
    contents = firstline.split()
    columnsRead = len(contents)
    print "Column count = %d" % columnsRead

    colNo = int(cn)
    # How much more int can you get? This is because 'zeros' is throwing an error later
    
    # Check the file to see that the values (even if spread across several rows) will make a full column
    if (columnsRead == colNo):
        print "Correct number of columns found"
    elif (columnsRead > colNo):
        print "Too many columns found"
        f.close()
        return None,0,0
    elif (columnsRead < colNo):
        while (columnsRead < colNo):
            firstline = f.readline()
            contents = firstline.split()
            columnsRead += len(contents)
            linesToRead+=1
        print "Array rows span %d file lines" % linesToRead
        # end of adding to 'linestoread'
        if (columnsRead != colNo):
            print "Wrong number of columns found: %d" % columnsRead
            f.close()
            return None,0,0

    # Set up a 1D array (a vector, effectively) of values:
    # We will concatenate subsequent rows onto this.
    if (type == "Int"):
        concArray = zeros([1,int(colNo)],Int)
        newRow = zeros([1,int(colNo)],Int)
    elif (type == "Character"):
        concArray= zeros([1,int(colNo)],Character)
        newRow = zeros([1,int(colNo)],Character)
    elif (type == "Float"):
        concArray = zeros([1,int(colNo)],Float)
        newRow = zeros([1,int(colNo)],Float)
    else:
        # no recognised type
        f.close()
        return None,0,0

    f.close()  # Close the file and re-open it to read from the start
    #----------------------------------------------------------------
    
    f = open(filename,'r')

    rowCounter = 1
    
    columnsRead = 0
    startColumnIndex = 0
    finishColumnIndex = 0 # These 3 will have to be reset once a row has been completely read
    
    while (columnsRead < colNo):  # Allow for the fact that a line may not always be spread out
                                     # over the same number of lines
        line = f.readline()
        
        if (line == ""):  #If we're at the end of the file 
            rowCounter -=1  # The row counter hops ahead one: rein it back
##            print "End of file: rowCounter is %d" % rowCounter
            break
            
        else:    
            # split each new line
            contents = line.split()

            if (len(contents) == 0):
                rowCounter -=1  # The row counter hops ahead one: rein it back
##                print "End of file: rowCounter is %d" % rowCounter
                break

            finishColumnIndex = startColumnIndex + len(contents)
##            print "Start index = %s: end index = %s: about to read a line" % (startColumnIndex , finishColumnIndex)
            
            columnsRead += len(contents)
##            print "Added %d to columns read: now %d" % (len(contents), columnsRead)

            lineIndex = 0  # A counter to step us through the line
            
            # Copy this line of values into the array
            for colIndex in range(startColumnIndex, finishColumnIndex,1):

##                print "Line value %s, at line index %d, goes to columnIndex %d" % (contents[lineIndex], lineIndex, colIndex)

                # If we're on the first line, read it into the base array
                if (rowCounter == 1):
                    if (type == "Int"):
                        concArray[0,colIndex] = int(contents[lineIndex],10)
                    elif (type == "Character"):
                        concArray[0,colIndex] = (contents[lineIndex])[0]
                        # Take first character - TODO - check this works
                    elif (type == "Float"):
                        concArray[0,colIndex] = float(contents[lineIndex])
                else:
                    if (type == "Int"):
                        newRow[0,colIndex] = int(contents[lineIndex],10)
                    elif (type == "Character"):
                        newRow[0,olIndex] = (contents[lineIndex])[0]
                        # Take first character - TODO - check this works
                    elif (type == "Float"):
                        newRow[0,colIndex] = float(contents[lineIndex])

                lineIndex +=1
                
            # Now bump up[ the start for the next line
            startColumnIndex = columnsRead
            
            if (columnsRead == colNo):
                # We're at the end of a row: we need to force ourselves to continue with this read
                columnsRead = 0
                startColumnIndex = 0
                finishColumnIndex = 0

                if (rowCounter > 1):
##                    print "At the end of row %d: concatenating the new row to the base Array" % (rowCounter)
##                    print "Array "
##                    print concArray
##                    print "plus Row "
##                    print newRow

                    newArray = concatenate((concArray, newRow))
                    
##                    print " = new array"
##                    print newArray
                    concArray = newArray
##                    print "new Conc Array...."
##                    print concArray
                    

                # Note the fact that we've read another row
                rowCounter +=1
##                print "Moving to the next row %d" % rowCounter

                # Re-zero the row buffer array
                if (type == "Int"):
                    newRow = zeros([1,colNo],Int)
                elif (type == "Character"):
                    newRow = zeros([1,colNo],Character)
                elif (type == "Float"):
                    newRow = zeros([1,colNo],Float)
                
    f.close()

    return newArray, colNo, rowCounter


# Functions for filtering arrays:
# should ultimately use the stats module for mean, median etc, but having trouble
# calling its functions.

# medianFilter: arguments are
# an array of unspecified type - this should be 2-dimensional
# windowSize (e.g., 3 for 3x3)
# returns the filtered array, plus its width and height
# TODO - make this more generic, once I can call stats functions
# Function will then use, e.g., amean, amedian, to calucalte new pixel values.
#
# We use Numpy array properties (shape) to find out
# arraywidth (number of columns)
# arrayheight (number of rows)
#
def medianFilter(inArray, windowSize):

    if (len(inArray.shape) != 2):
        return None
    
    arrayWidth = inArray.shape[0]
    arrayHeight = inArray.shape[1]

##    print inArray

    newArrayWidth = int(math.floor(arrayWidth/windowSize))
    newArrayHeight = int(math.floor(arrayHeight/windowSize))

    # Truncate the new array if it is not divisible by the window size.

    print ("Old array width = %d, height = %d: New array width = %d, height = %d") % (arrayWidth, arrayHeight, newArrayWidth, newArrayHeight)

    newArray = ones((newArrayWidth, newArrayHeight), Int)
    # We don't actually need to specify Int here, it's the default:
    # this is just to remind me of the correct syntax.

    rowCounter = 0
    colCounter = 0

    for rowCounter in range (0,newArrayWidth,1):

        for colCounter in range (0, newArrayHeight, 1):

            startRowIndex = rowCounter * windowSize
            endRowIndex = startRowIndex + windowSize

            startColIndex = colCounter * windowSize
            endColIndex = startColIndex + windowSize

            newShape = windowSize * windowSize

##            print ("Row = %d, Col = %d") % (rowCounter, colCounter)
##            print inArray[startRowIndex:endRowIndex:1, startColIndex:endColIndex:1]
           
            # Clip out the window we're interested in
            # Turn it into a 1D array
            dataLine = reshape(inArray[startRowIndex:endRowIndex:1, startColIndex:endColIndex:1],(newShape,))

##            print dataLine

            medValue = dataLine[int(math.ceil(newShape/2.0))]
            
            newArray[rowCounter, colCounter] = medValue

        # end of column loop

    # end of row loop

    return newArray, newArrayWidth, newArrayHeight
            
# meanFilter: arguments are
# an array of unspecified type - this should be 2-dimensional
# windowSize (e.g., 3 for 3x3)
# returns the filtered array, plus its width and height
# TODO - make this more generic, once I can call stats functions
# Function will then use, e.g., amean, amedian, to calucalte new pixel values.
#
# We use Numpy array properties (shape) to find out
# arraywidth (number of columns)
# arrayheight (number of rows)
#
def meanFilter(inArray, windowSize):

    if (len(inArray.shape) != 2):
        return None
    
    arrayWidth = inArray.shape[0]
    arrayHeight = inArray.shape[1]

##    print inArray

    newArrayWidth = int(math.floor(arrayWidth/windowSize))
    newArrayHeight = int(math.floor(arrayHeight/windowSize))

    # Truncate the new array if it is not divisible by the window size.

    print ("Old array width = %d, height = %d: New array width = %d, height = %d") % (arrayWidth, arrayHeight, newArrayWidth, newArrayHeight)

    newArray = ones((newArrayWidth, newArrayHeight), Int)
    # We don't actually need to specify Int here, it's the default:
    # this is just to remind me of the correct syntax.

    rowCounter = 0
    colCounter = 0

    for rowCounter in range (0,newArrayWidth,1):

        for colCounter in range (0, newArrayHeight, 1):

            startRowIndex = rowCounter * windowSize
            endRowIndex = startRowIndex + windowSize

            startColIndex = colCounter * windowSize
            endColIndex = startColIndex + windowSize

            newShape = windowSize * windowSize

##            print ("Row = %d, Col = %d") % (rowCounter, colCounter)
##            print inArray[startRowIndex:endRowIndex:1, startColIndex:endColIndex:1]
           
            # Clip out the window we're interested in
            # Turn it into a 1D array
            dataLine = reshape(inArray[startRowIndex:endRowIndex:1, startColIndex:endColIndex:1],(newShape,))

##            print dataLine

            avValue = average(dataLine)
            
            newArray[rowCounter, colCounter] = int(math.floor(avValue))

        # end of column loop

    # end of row loop

    return newArray, newArrayWidth, newArrayHeight


# reinflate_array: arguments are
# an array of unspecified type - this should be 2-dimensional
# windowSize (e.g., 3 for 3x3)
# returns the reinflated array, plus its width and height
# 'Reinflation' means replication of a cell value to fill the specified window.
# In other words, the raster looks the same but has 3 x the resolution, and
# numerous repeated cells.
#
# We use Numpy array properties (shape) to find out
# arraywidth (number of columns)
# arrayheight (number of rows)
#
def reinflate_array(inArray, windowSize):

    if (len(inArray.shape) != 2):
        return None
    
    arrayWidth = inArray.shape[0]
    arrayHeight = inArray.shape[1]

##    print inArray

    newArrayWidth = arrayWidth*windowSize
    newArrayHeight = arrayHeight*windowSize

    print ("Old array width = %d, height = %d: New array width = %d, height = %d") % (arrayWidth, arrayHeight, newArrayWidth, newArrayHeight)

    newArray = zeros((newArrayWidth, newArrayHeight), Int)
    # We don't actually need to specify Int here, it's the default:
    # this is just to remind me of the correct syntax.

    rowCounter = 0
    colCounter = 0

    for rowCounter in range (0,arrayWidth,1):

        for colCounter in range (0, arrayHeight, 1):

            startRowIndex = rowCounter * windowSize
            endRowIndex = startRowIndex + windowSize

            startColIndex = colCounter * windowSize
            endColIndex = startColIndex + windowSize

            theValue = inArray[rowCounter,colCounter]
            
            for newRow in range(startRowIndex, endRowIndex, 1):
                for newCol in range(startColIndex, endColIndex, 1):

                    newArray[newRow,newCol] = theValue
                    
                # end of column loop
            # end of row loop

        # end of column loop

    # end of row loop

    print newArray
    
    return newArray, newArrayWidth, newArrayHeight
            
# ----------------------------------------------------------------------

# Function for stripping the leading space off RULE files
# (this can cause problems for import)
# arguments:
# string: RULE file name (with full path)
# string: output file name(with full path)
# int: column number
# string: datatype ("Int", "Float", or "Character"
#
# This reads the data into an array before writing it out, because
# it is also useful to put a whole row on one line
# (RULE breaks output into lines of 1000 characters)
#

def RULE_toPlainASCII(RULEfile, outfile, colNo, dataType):

    returnCode = 0  # default success

    if ((dataType != "Int")&(dataType != "Character")&(dataType != "Float")):
        print "Wrong argument for dataType - must be 'Int' or 'Float' or 'Character': argument was %s" % dataType
        return 1
    
    try:
        
        myArray, w, h = readASCIIarray(RULEfile, dataType, colNo)

        if (myArray != None):

            ascii_output = open(outfile, 'w')

            if (array_to_created_file(ascii_output, myArray, dataType, "P") == 0):
                print "Generated correctly formatted raster ASCII file for ArcMap import"
            else:
                returnCode = 1
                            
            ascii_output.close
            ascii_output = None
            gc.collect()

            print "Generated ASCII file without leading spaces"

            return returnCode      # No error

    except:
        import sys
        print sys.exc_type, sys.exc_value

        try:
          ascii_output.close
          ascii_output = None
          gc.collect()

        except:          
            print "Problem cleaning up files"          
      
        return 1      # Flags up an error

# -------------------------------------------------------------------------------

# Function for converting RULE output into files which can be
# imported into Arc as GRIDs
# arguments:
# string: RULE file name (with full path)
# string: output file name(with full path)  :MUST end in '.asc'
# int: column number
# string: datatype ("Int", "Float", or "Character"
#
# This reads the data into an array before writing it out, because
# it is also useful to put a whole row on one line
# (RULE breaks output into lines of 1000 characters)

# Generate an ascii file with the correct header for ARCMap to import
    # <ncols xxx>
    # <nrows xxx>
    # <xllcenter xxx | XLLCORNER xxx>
    # <YLLCENTER xxx | YLLCORNER xxx>
    # <CELLSIZE xxx>
    # {NODATA_VALUE xxx}
    # row 1
    # row 2
    # row n

    # where xxx is a number and the keyword NODATA_VALUE is optional and defaults to -9999. Row 1 of the data is at the top of the raster, row 2 is just under row 1, and so on.

    # For example:
    # ncols 480
    # nrows 450
    # xllcorner 378923
    # YLLCORNER 4072345
    # cellsize 30
    # nodata_value -32768
    # 43 2 45 7 3 56 2 5 23 65 34 6 32 54 57 34 2 2 54 6 
    #35 45 65 34 2 6 78 4 2 6 89 3 2 7 45 23 5 8 4 1 62  ...

    #The NODATA_VALUE is the value in the ASCII file to be assigned to those cells whose true value is unknown. In the raster, they will be assigned the keyword NODATA. 
    #Cell values should be delimited by spaces. No carriage returns are necessary at the end of each row in the raster. The number of columns in the header is used to determine when a new row begins. 
    # The number of cell values must be equal to the number of rows times the number of columns, or an error will be returned.             
#

def RULE_to_ESRI_ASCII(RULEfile, outfile, colNo, dataType):

    returnCode = 0   # default success

    if ((dataType != "Int")&(dataType != "Character")&(dataType != "Float")):
        print "Wrong argument for dataType - must be 'Int' or 'Float' or 'Character': argument was %s" % dataType
        return 1
    
    try:
        
        myArray, w, h = readASCIIarray(RULEfile, dataType, colNo)

        if (myArray != None):

            ascii_output = open(outfile, 'w')

            ascii_output.write("ncols %d\n" % w)
            ascii_output.write("nrows %d\n" % h)
            ascii_output.write("xllcorner 0\nyllcorner 0\n")
            ascii_output.write("cellsize 1\n") #default size - TODO, allow user to set this
            #stick with the default NODATA value

            if (array_to_created_file(ascii_output, myArray, dataType, "P") == 0):
                print "Generated correctly formatted raster ASCII file for ArcMap import"
            else:
                returnCode = 1
                            
            ascii_output.close
            ascii_output = None

            return returnCode      

    except:
        import sys
        print sys.exc_type, sys.exc_value

        try:
          ascii_output.close
          ascii_output = None
          gc.collect()

        except:          
            print "Problem cleaning up files"          
      
        return 1      # Flags up an error

# Function for writing a memory array out to a file opened elsewhere
# arguments:
# file: the opened file writer
# array: the array to be written
# string: datatype ("Int", "Float", or "Character"
# string: fileType ("P" for plain, "A" for Apack or "E" for ESRI)
#

def array_to_created_file(outFile, theArray, dataType, fileType, cellsize):

    if ((fileType != "E") & (fileType != "P") & (fileType != "A")):
        print "Wrong argument for fileType - must be 'P', 'A' or 'E': argument was %s" % fileType
        return 1

    if ((dataType != "Int")&(dataType != "Character")&(dataType != "Float")):
        print "Wrong argument for dataType - must be 'Int' or 'Float' or 'Character': argument was %s" % dataType
        return 1
    
    try:
        
        w = theArray.shape[1]
        h = theArray.shape[0]

        print "width of array = %d, height = %d" % (w,h)
        
        # write a header for ESRI format
        if (fileType == "E"):
            outFile.write("ncols %d\n" % w)
            outFile.write("nrows %d\n" % h)
            outFile.write("xllcorner 0\nyllcorner 0\n")
            outFile.write("cellsize 1\n") #default size - TODO, allow user to set this
            #stick with the default NODATA value

        if (fileType == "A"):
            outFile.write("[rows]\n%d\n" % h)  # Rows
            outFile.write("\n")
            outFile.write("[columns]\n%d\n" % w)  # Columns
            outFile.write("\n")
            outFile.write("[cell")
            outFile.write("s]\n")  # Cell values to follow
            # NB 'cells' is a Restricted keyword. Pain.
            
        for rowCounter in range(0,h,1):
            for colCounter in range(0,w,1):
                if (dataType == "Int"):
                    outFile.write("%d" % (theArray[rowCounter,colCounter]))
                elif (dataType == "Character"):
                    outFile.write("%s" % (theArray[rowCounter,colCounter]))
                elif (dataType == "Float"):
                    outFile.write("%f" % (theArray[rowCounter,colCounter]))
                # TODO - check this isn't swapping axes...
                if (colCounter < w):
                    outFile.write(" ")
            outFile.write("\n")

        if (fileType == "A"):
            outFile.write("[cell spacing]\n%d m\n" % cellsize)  # Cell size - use m., it doesn't matter!
            
        print "wrote array to file"

        return 0      # No error

    except:
        import sys
        print sys.exc_type, sys.exc_value

        return 1      # Flags up an error


def writeArrayToFile(outFileName, theArray, dataType, fileType, cellsize):

    if ((fileType != "E") & (fileType != "P") & (fileType != "A")):
        print "Wrong argument for fileType - must be 'P', 'A' or 'E': argument was %s" % fileType
        return 1

    if ((dataType != "Int")&(dataType != "Character")&(dataType != "Float")):
        print "Wrong argument for dataType - must be 'Int' or 'Float' or 'Character': argument was %s" % dataType
        return 1

    try:
        f_file = open(outFileName, 'w')
                    
        success = array_to_created_file(f_file, theArray, dataType, fileType, cellsize)

        if (success != 0):
          print "Failed to write out file" 

        f_file.close()
        return success

    except:
        # Print error message if an error occurs
        import sys
        # Looks odd, but we have to import again to get the new exception values 
        print "Error! ",sys.exc_type, sys.exc_value
        try:
            f_file.close()
        except:
            print ""
        return 1

# thresholdClassify: arguments are
# an array of unspecified type - this should be 2-dimensional
# class number 
# existing min
# existing max
# returns the classified array
#
def thresholdClassify(inArray, noClasses, minVal, maxVal):

    if (len(inArray.shape) != 2):
        return None
    
    arrayWidth = inArray.shape[0]
    arrayHeight = inArray.shape[1]

    newArray = ones((arrayWidth, arrayHeight), Int)
    # We don't actually need to specify Int here, it's the default:
    # this is just to remind me of the correct syntax.

    rowCounter = 0
    colCounter = 0

    binWidth = int((maxVal-minVal)/noClasses)

    for rowCounter in range (0,arrayWidth,1):

        for colCounter in range (0, arrayHeight, 1):
            
            thisVal = inArray[rowCounter, colCounter] 
            newVal = int(math.ceil(thisVal/binWidth))
            newArray[rowCounter, colCounter] = newVal 

        # end of column loop

    # end of row loop

    return newArray

    
