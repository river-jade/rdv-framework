####################################################

# Lucy Bastin, 27/02/07

#####################################################


# Import system modules
import sys, string, os, gc

# Function for converting ESRII ASCII text exports into PGM and plain text files
# arguments:
# string: ASCII file name (with full path) :MUST end in '.asc'
# string: output text file name(with full path)
# string: output pgm file name(with full path)
# int: row number
# int: column number
# int: maximum value in the raster file (for PGM)

# No longer uses array structures - having problems with consistency between
# Python 2.1 (used by Arc 9.1, uses 'Numeric' and
# Python 2.4. (used by Arc 9.2, uses 'numpy'.

# Read an ascii file exported by ARCMap 
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

# Write a plain text file (no header) and a PGM file with header as follows:
# P2
# 256 256
# 5

# 256s are cols/rows 
# 5 is the maximum value of any individual pixel (or number of classes in the image I think)

#
def AscToPGMandTXT(ASCIIfile, TXTfile, PGMfile, rowNo, colNo, maxInt):

    returnCode = 0   # default success
    try:

        ascii_input = open(ASCIIfile, 'r')
        # skip down through the header
        junk = ascii_input.readline() # columns
        junk = ascii_input.readline() # rows
        junk = ascii_input.readline() # lower left x corner
        junk = ascii_input.readline() # lower left y corner
        junk = ascii_input.readline() # cellsize
        junk = ascii_input.readline() # NODATA

    except:
       print "Problem opening or reading the ASCII file %s" % ASCIIfile
       exit

    try:       
        txt_output = open(TXTfile, 'w')
        
        pgm_output = open(PGMfile, 'w')
        pgm_output.write("P2\n")
        pgm_output.write("%d %d\n" % (colNo, rowNo))
        pgm_output.write("%d\n" % maxInt)
        
    except:
       print "Problem opening or reading the text or pgm file"
       exit    

    try:
       # Now ready to write the rows straight out as read from ASCII file.
       for theline in ascii_input.readlines():
                 
           txt_output.write(theline)
           pgm_output.write(theline)
                           
       ascii_input.close
       ascii_input = None
       txt_output.close
       txt_output = None
       pgm_output.close
       pgm_output = None  

    except:
      import sys
      print sys.exc_type, sys.exc_value

    gc.collect()

# -------------------------------------------------------------------------------

# Function for converting text output into files which can be
# imported into Arc as GRIDs
# arguments:
# string: text file name (with full path)
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

def txt_to_ESRI_ASCII(txtfile, outfile, colNo, dataType):

    returnCode = 0   # default success

    if ((dataType != "Int")&(dataType != "Character")&(dataType != "Float")):
        print "Wrong argument for dataType - must be 'Int' or 'Float' or 'Character': argument was %s" % dataType
        return 1
    
    try:
        
        myArray, w, h = readASCIIarray(txtfile, dataType, colNo)

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

