#===============================================================================

#                               quartering.R

#  Usage:
#    source ("quartering.R")

#  This program recursively splits a parent directory full of .asc images into  
#  4 subdirectories containing files of the same name but one quarter the 
#  original size.  The point is to make it easy to generate a bunch of much 
#  smaller examples to speed up testing and training on the images.  
#  It also makes it easier to create cross-validation opportunities between 
#  sub-images derived from the same original image.

#  Each image in the parent directory is split into quarters and 
#  copied into the corresponding subdirectory while leaving the original 
#  image intact in the parent directory.  The image in the subdirectory 
#  has the same name as the parent image, but is one quarter the size and 
#  has its lower left corner information updated to match the quarter.  

#  The subdirectories are named to reflect both the quadrant name and the 
#  size of the resulting image.  For example, the upper left corner of a 
#  512x256 image called x.asc would go to UpperLeft_r256c128/x.asc.

#  When you source this file, it generates a file.chooser() dialog where 
#  you choose the directory that you want to split up.  Unfortunately, 
#  R's file chooser doesn't allow you to choose a directory. You have to 
#  choose a file.  So, to work around this, just pick any file in the 
#  directory that you want to split and this program will figure out the 
#  directory from that.  You can also pick a directory name in any way you 
#  want and call the routine that does the work using that name.  The 
#  function is:
#      quarterAllFilesInADirectory (dirName, minAllowedDimension, overwrite)
#  See the end of this file for an example of how it is used with the 
#  file.chooser().

#  Note that whatever dirName you hand in cannot have a slash at the end of it 
#  since the function is expecting whatever format is returned by the 
#  file.chooser() function.

#  The minAllowedDimension argument allows you to say what is the smallest 
#  image height or width that you want to go down to.  It defaults to 128 
#  pixels, i.e., it won't split beyond an image size where either height 
#  or width is less than 128 or the minAllowedDimension you choose.  

#  The overwrite option says whether to overwrite existing split files it 
#  finds along the way, but something seems to be wrong with this and I'm 
#  not sure why.  In any case, it's not really important for the usual use 
#  of this code and it defaults to FALSE to be safe.

#  Note that this code will recursively split the starting directory into 
#  quarters of quarters of ... until it reaches the minAllowedDimension.  
#  If you want to split just once instead of recursively, just set the 
#  minAllowedDimension to the size that one split would be.  For example, 
#  if the parent images were 512x512, then setting the minAllowedDimension 
#  to 256 will stop the process after just one quartering.

#  Caveats:

#  It assumes that all images in the directory are the same size (though it 
#  may work even if they aren't - not sure about that).

#  If the parent image does not have an even number of pixels in either the 
#  rows or the columns, that last pixel in each row and/or column will be 
#  dropped.  This means that the quartering will not be exact in those cases 
#  but for the things I want to use this for, that's not a problem.  If this 
#  was a problem, you could conceivably make the quarters be different sizes.  

#  I haven't done much of in R messing with files and subdirectories and had 
#  some problems with getting things to behave as I expected when creating 
#  and overwriting and detecting things.  So, it's conceivable that 
#  unexpected things may happen at some point.  The general use that I foresee 
#  and have tested is that:
#    - directory only contains .asc files
#    - directory does not have any subdirectories, particularly none with 
#      the same names that I am generating (e.g., UpperLeft_r128c128).  
#  Not sure what will happen if either of these are not true.
#  One thing that protects against problems is that the program does nothing 
#  to the files in the directory where you start.  After the program runs, 
#  even if it has crashed or screwed up its subdirectories in some way, 
#  the original file set in the parent directory will still be there.  
#  In debugging, I've often just gone into the parent directory and deleted 
#  the subdirectories that this program created in the process of misbehaving.
#  So, in that sense, the program seems pretty safe.  

#===============================================================================

#  NOTE: 
#       OVERWRITE FAILS IN HERE WHEN I TRY TO OVERWRITE AN EXISTING RASTER 
#       FILE.  
#       COULD BE THAT THE FILE TO OVERWRITE IS EITHER STILL OPEN OR 
#       LOCKED FOR SOME REASON.
#       TRY CLOSING THE FILE BEFORE DOING THE WRITE CALL AND SEE IF THAT 
#       HELPS...
#       OR, WAIT FOR THE OVEWRITE TO THROW AN EXCEPTION, THEN CATCH IT 
#       AND TRY CLOSING OR UNLOCKING (NOT SURE HOW) BEFORE RETRYING.


require (raster)
require (tools)

#-------------------------------------------------------------------------------

writeCroppedFile = function (aRaster, 
                             filename, 
                             startRow, 
                             endRow, 
                             startCol, 
                             endCol, 
                             overwrite=FALSE
                            )
    {
    cat ("\n\n=====>>>  In writeCroppedFile:  overwrite = ", overwrite, "\n", sep='')
    
    croppedRaster = 
        crop (aRaster, extent (aRaster, startRow, endRow, startCol, endCol))
    
    writeRaster (croppedRaster, filename, "ascii", overwrite)
    
    return (croppedRaster)
    }

#-------------------------------------------------------------------------------

createDirForQuarterIfNecessary = function (dirName, quarterName)
    {
    quarterDirName = file.path (dirName, quarterName)
    
    if (! file.exists (quarterDirName))
        {
        cat ("\n\nquarterDirName DOES NOT exist.  Creating it.\n\n", sep='')  
        dir.create (quarterDirName, 
                    showWarnings = TRUE, 
                    recursive = TRUE, #  Not sure about this, but it's convenient.
                    mode = "0777")    #  Not sure if this is what we want for mode.        
        }
    
    return (quarterDirName)
    }

#-------------------------------------------------------------------------------

doOneQuadrant = function (quadrantName, parentRaster, 
                          halfRowsColsFileString, dirName, baseFileName, 
                          halfRows, halfCols)
    {
    quarterName = paste0 (quadrantName, halfRowsColsFileString)
    quarterDirName = createDirForQuarterIfNecessary (dirName, quarterName)
    
    outfilename = file.path (quarterDirName, baseFileName)
    cat ("\n", quadrantName, " outfilename = ", outfilename, sep='')
    
    quadrantRaster = writeCroppedFile (parentRaster, outfilename, 1, halfRows, 1, halfCols, overwrite)
    
    curPlotTitle = paste (quadrantName, " - ", baseFileName, sep='')
    plot (quadrantRaster, main=curPlotTitle)
    
    return (quarterDirName)
    }

#-------------------------------------------------------------------------------

quarterAllFilesInADirectory = function (dirName, 
                                        minAllowedDimension = 128, 
                                        overwrite = FALSE)
    {
    cat ("\n******  dirName = ", dirName, "\n", sep='')

    listOfFiles = list.files (dirName, pattern=".asc", full.names=FALSE)
    
    for (curFilename in listOfFiles)
        {
        curBasename = file_path_sans_ext (curFilename)
        curFullFilename = file.path (dirName, curFilename)
        
        cat ("\ncurFilename = ", curFilename)
        cat ("\ncurBasename = ", curBasename)
        cat ("\ncurFullFilename = ", curFullFilename)
        
        cat ("\n\n")
        
            #----------------------
            #  Load raster image.
            #----------------------
        
        curRaster = raster (curFullFilename)
        curPlotTitle = paste ("Full - ", curBasename, sep='')
        plot (curRaster, main=curPlotTitle)
        
            #-------------------------------
            #  Find half rows and columns.
            #-------------------------------
        
        numRows = nrow (curRaster)
        numCols = ncol (curRaster)
                
        halfRows = floor (numRows / 2)
        halfCols = floor (numCols / 2)
        
        if ((halfRows <= 0) || (halfCols <= 0))
            stop (paste0 ("\n    ***  Half image size must be > 0, but halfRows = ", 
                          halfRows, " and halfCols = ", halfCols, ".  ***\n\n"))
        
        halfRowsColsFileString = paste0 ("_r", halfRows, "c", halfCols)
        
        cat ("\nnumRows = ", numRows, sep='')
        cat ("\nnumCols = ", numCols, sep='')
        cat ("\nhalfRows = ", halfRows, sep='')
        cat ("\nhalfCols = ", halfCols, sep='')
        cat ("\nhalfRowsColsFileStrings = ", halfRowsColsFileString, sep='')    
        cat ("\n")

            #----------------------------------------------------------------
            #  If still enough rows and columns left for quartering, do it.
            #----------------------------------------------------------------
        
        baseFileName = curBasename
        aRaster = curRaster
        overwrite = FALSE
        
        minHalfDimension = min (halfRows, halfCols)
        if (minHalfDimension < minAllowedDimension)
            {
            cat ("\n\nminHalfDimension = ", minHalfDimension, 
                 " < minAllowedDimension = ", minAllowedDimension, 
                 ", so not splitting\n\n")

            } else
            {
            upperLeftQuarterDirName = 
                doOneQuadrant ("UpperLeft", aRaster, halfRowsColsFileString, 
                               dirName, baseFileName, halfRows, halfCols)
            upperRightQuarterDirName = 
                doOneQuadrant ("UpperRight", aRaster, halfRowsColsFileString, 
                               dirName, baseFileName, halfRows, halfCols)
            lowerLeftQuarterDirName = 
                doOneQuadrant ("LowerLeft", aRaster, halfRowsColsFileString, 
                               dirName, baseFileName, halfRows, halfCols)
            lowerRightQuarterDirName = 
                doOneQuadrant ("LowerRight", aRaster, halfRowsColsFileString, 
                               dirName, baseFileName, halfRows, halfCols)
                            
            }  #  end if - minHalfDimension >= minAllowedDimension        
        }  #  end for - listoffiles
    
    if (minHalfDimension > minAllowedDimension)
        {
        quarterAllFilesInADirectory (upperLeftQuarterDirName, minAllowedDimension, overwrite)
        quarterAllFilesInADirectory (upperRightQuarterDirName, minAllowedDimension, overwrite)
        quarterAllFilesInADirectory (lowerLeftQuarterDirName, minAllowedDimension, overwrite)
        quarterAllFilesInADirectory (lowerRightQuarterDirName, minAllowedDimension, overwrite)        
        }
    
    }  #  end function - quarterAllFilesInADirectory()

#-------------------------------------------------------------------------------

#  Main code:
#  Just sets the 3 options and then calls function that does all the work.
#  If you want to do this some other way than using the file.chooser() to get 
#  the dirName to split, you can just call the quarterAllFilesInADirectory() 
#  function directly with a dirName of your choice (but no slash at the end 
#  of the path or it will choke).

    #dirName = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloSupervisedClusterLayers"
    #  file.choose() won't let you choose a directory.
    #  You have to choose a file.
    #  The following site suggested a workaround by using dirname() to 
    #  strip the directory name off of any file you select in the directory 
    #  you're after:
    #  http://r.789695.n4.nabble.com/choose-folder-interactively-td4651126.html

dirName = dirname (file.choose())    #  interactively choose the directory
minAllowedDimension = 128            #  smallest image height/width allowed
overwrite = FALSE                    #  whether to overwrite existing files 
                                     #  in split subdirectories 

quarterAllFilesInADirectory (dirName, minAllowedDimension, overwrite)

#===============================================================================



