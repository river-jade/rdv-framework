#===============================================================================

#  Copied from old rdv version in:
#  /Users/Bill/D/rdv-framework-old.versions/rdv-framework-before-2012-07-25/R
#  Not all of the updates in here were in the later rdv versions on my disk
#  or on the repository.  Not sure why.
#  Have now commented out all the read routines that were in here at the bottom
#  of the file.  Have copied them into a new file called read.R.
#  2013 04 08 - BTL

    #--------------------------------------------------------------
    # This contains some utility functions. To write tables and
    # vectors to files in a number of different formats.
    #
    #  Write a matrix to 3 forms of ascii output files:
    #    - pgm (for viewing as a grey scale image, 3 line header)
    #    - asc (Arc ascii format, 6(?) line header)
    #    - txt (raw ascii text file with no header)
    #  w.R - Cloned from Ascelin's output code in genSqPatches.R.
    #  BTL - 4/5/06
    #  added function writeOutputVector - 26 april 06 - AG
    #
    #  re-organised so can call functions to write each file type
    #  individually or in any combination - 29 april - AG
    #
    #  Changed write.pgm.file to check for divide by zero when
    #  rescaling non-integer values to be integers.
    #  In files that were all zero, it would get a divide by zero
    #  and fill the output with NaN values.
    #  BTL - 8/28/07.
    #
    #  Changed write.asc.file().
    #  Simple changes to make a bunch of the parameters able to be
    #  specified in the call rather than fixed inside the routine.
    #  All of the new call arguments default to the old values though,
    #  so no existing framework code should be broken by this.
    #  BTL - Feb, 2011 (I think).
    #
    #  Added read.asc.file.to.matrix()
    #  BTL - 2011.07.23
    #
    #  Added functions related to reading pnm files and converting
    #  them to asc files.
    #  BTL - 2011.08.07
    #
    #  Moved get.img.matrix.from.pnm.and.write.asc.equivalent()
    #  to guppy.maxent.functions.v7.R
    #  BTL - 2011.09.22
    #
    #--------------------------------------------------------------

#===============================================================================

#####  PROBABLY NEED TO REWRITE THE WRITE.PGM.FILE() FUNCTION OR CREATE A
#####  DIFFERENT/OPTIONAL VERSION OF IT TO HANDLE FILES WHERE THERE ARE A
#####  A SMALL NUMBER OF VERY EXTREME VALUES THAT MESS UP THE LINEAR
#####  SCALING USED NOW.  FOR EXAMPLE, I THINK THAT IF YOU HAVE JUST ONE VALUE
#####  THAT'S MUCH LARGER THAN ALL THE OTHERS (E.G., NOISE), THEN IT WILL
#####  CURRENTLY SCALE EVERYTHING TO MAKE THAT PIXEL WHITE BUT ALL OTHER
#####  PIXELS WILL BE SMASHED DOWN INTO THE LOWEST PIXEL COLOR, I.E., BLACK,
#####  MAKING AN ALL BLACK IMAGE.
#####
#####  MIGHT BE BETTER TO RUN HIST() AND USE THE BOUNDS OF SOME QUANTILES
#####  AS THE BOUNDS OF ALL BUT THE BLACKEST AND WHITEST PIXELS.
#####
#####  Another option would be to check for the range of the data and if it's
#####  large, log the data before scaling and writing it out.
#####  This isn't necessarily a great solution though, since it's likely to
#####  violate expectations.  Would be better to offer it as an explicit option
#####  passed to the function.  Maybe the same should apply to the quantile
#####  idea above.
#####
#####  Note that this might apply to other things besides pgms, but they're
#####  plotted by built-in R functions.  Not sure about this...
#####
#####  BTL - 2013.04.18 and 2014.05.05
#####  copied this comment from g2Utilities.R and edited it here.

write.pgm.file <- function (table.to.write, filename.root,
                            num.table.rows, num.table.cols)
  {
  ######################
  #write a pgm file

    if ( !is.integer(table.to.write) )
      {
      if ( is.numeric(table.to.write) )
	{
		#  Table is not integer but it is numeric.
		#  Need to convert it to integer values.

                #  Need to check for divide by 0 though.
                #  For example, this can happen when the file is
                #  ALL zeroes.  If it is 0, then just leave it alone.
                #  BTL - 8/28/07.
        if (max(table.to.write != 0))
          {
	  table.to.write <-
            floor (255 * (table.to.write / max(table.to.write)));
          }
	} else
	{
      	cat ('\nTable is NOT numeric.  CanNOT write pgm file ',
           filename.root, '\n');
      	return( FALSE ) ;
	}
    }

    #add the .pgm to the filename
    pgmFileName = paste(filename.root, ".pgm", sep = "" )

    #first write the header into the output file
    #for a pgm file need the following header:
    # (the last number is the maximim cell value)
    #P2
    #cols row ! (ie this is width, height )
    #4

    #  Compute the maximum value to be written to the pgm file.
    #  If the file is all zeros, then the max comes out to be 0 and
    #  putting that value in the pgm header makes some pgm viewers
    #  crash.  So, use a value of 1 in that case.
    max.table.value <- max( max( table.to.write ), 1)

    cat( "P2\n", file = pgmFileName );
    cat( num.table.cols, file = pgmFileName, append = TRUE );
    cat( " ", file = pgmFileName, append = TRUE );
    cat( num.table.rows, file = pgmFileName, append = TRUE );
    cat( "\n", max.table.value, "\n", file = pgmFileName, append = TRUE );

    write.table( table.to.write, file= pgmFileName,  append = TRUE,
                row.names = FALSE, col.names = FALSE );

    cat( '\nwrote', pgmFileName );
  }

#===============================================================================

original.write.pgm.file <- function (table.to.write, filename.root,
                            num.table.rows, num.table.cols)
  {
  ######################
  #write a pgm file

    if ( !is.integer(table.to.write) ) {
      cat ('\nTable is NOT integer.  CanNOT write pgm file ',
           filename.root, '\n')
      return( FALSE )
    }

    #add the .pgm to the filename
    pgmFileName = paste(filename.root, ".pgm", sep = "" )

    #first write the header into the output file
    #for a pgm file need the following header:
    # (the last number is the maximim cell value)
    #P2
    #cols row ! (ie this is width, height )
    #4

    #  Compute the maximum value to be written to the pgm file.
    #  If the file is all zeros, then the max comes out to be 0 and
    #  putting that value in the pgm header makes some pgm viewers
    #  crash.  So, use a value of 1 in that case.
    max.table.value <- max( max( table.to.write ), 1)

    cat( "P2\n", file = pgmFileName )
    cat( num.table.cols, file = pgmFileName, append = TRUE )
    cat( " ", file = pgmFileName, append = TRUE )
    cat( num.table.rows, file = pgmFileName, append = TRUE )
    cat( "\n", max.table.value, "\n", file = pgmFileName, append = TRUE )

    write.table( table.to.write, file= pgmFileName,  append = TRUE,
                row.names = FALSE, col.names = FALSE );

    cat( '\nwrote', pgmFileName, '\n' );
  }

#===============================================================================

write.txt.file <- function (table.to.write, filename.root,
                            num.table.rows, num.table.cols)
  {
    #########################
    #write the raw text ascii file

    rawFileName = paste(filename.root, ".txt", sep = "" )

if (DEBUG) {
cat ("\nIn write.txt.file, rawFileName = ", rawFileName);
#cat ("\ntable.to.write = \n");
#browser();
#print (table.to.write);
#cat ("\n");
#browser();
}

    write.table( table.to.write, file= rawFileName,
		row.names = FALSE, col.names = FALSE );

    cat( '\nwrote', rawFileName );

  }

#===============================================================================

    #  Changed to allow calling function to specify arguments.
    #  February(?) 2011, BTL
write.asc.file <- function (table.to.write, filename.root,
                            num.table.rows, num.table.cols,
                            xllcorner = 0.0,		#  BTL - 2011.02.15 - Added.
                            yllcorner = 0.0,
                            no.data.value = 0,      #  BTL - 2011.02.13 - Added.
							cellsize = 1			#  BTL - 2011.02.15 - Added.
                            )
  {

    ######################
    #write the arc asci file
    #example of an asc file header:
    #ncols	512
    #nrows	512
    #xllcorner	0.0000
    #yllcorner	0.0000
    #cellsize	40.00000000
    #NODATA_value	-1


    ascFileName = paste(filename.root, ".asc", sep = "" )

    #make the header lines
    line1 = paste( "ncols         ", num.table.cols, "\n", sep = "" )
    line2 = paste( "nrows         ", num.table.rows, "\n", sep = "" )

    otherLines = paste ("xllcorner     ", xllcorner, "\n",
                        "yllcorner     ", yllcorner, "\n",
      					"cellsize      ", cellsize, "\n",
      					"NODATA_value  ", no.data.value, "\n",
      					sep = "" )


    cat( line1 , file = ascFileName );
    cat( line2, file = ascFileName, append = TRUE );
    cat( otherLines, file = ascFileName, append = TRUE );

    write.table( table.to.write, file= ascFileName,  append = TRUE,
              row.names = FALSE, col.names = FALSE );

    cat( '\nwrote', ascFileName );

#cat ("\n---->  At end of write.asc.file()\n")
#browser()
}

#===============================================================================

#  Changed to allow calling function to specify arguments.
#  February(?) 2011, BTL
write.asc.file.usingStrHeaderVals <- function (table.to.write, filename.root,
                            ascFileHeaderAsStrVals
                            )
{

    ######################
    #write the arc asci file
    #example of an asc file header:
    #ncols	512
    #nrows	512
    #xllcorner	0.0000
    #yllcorner	0.0000
    #cellsize	40.00000000
    #NODATA_value	-1


    ascFileName = paste(filename.root, ".asc", sep = "" )

    #make the header lines
    line1 = paste( "ncols         ", ascFileHeaderAsStrVals$numCols, "\n", sep = "" )
    line2 = paste( "nrows         ", ascFileHeaderAsStrVals$numRows, "\n", sep = "" )

    otherLines = paste ("xllcorner     ", ascFileHeaderAsStrVals$xllCorner, "\n",
                        "yllcorner     ", ascFileHeaderAsStrVals$yllCorner, "\n",
                        "cellsize      ", ascFileHeaderAsStrVals$cellSize, "\n",
                        "NODATA_value  ", ascFileHeaderAsStrVals$noDataValue, "\n",
                        sep = "" )


    cat( line1 , file = ascFileName );
    cat( line2, file = ascFileName, append = TRUE );
    cat( otherLines, file = ascFileName, append = TRUE );

    write.table( table.to.write, file= ascFileName,  append = TRUE,
                 row.names = FALSE, col.names = FALSE );

    cat( '\nwrote', ascFileName );

    #cat ("\n---->  At end of write.asc.file()\n")
    #browser()

    if (TRUE)
    {
    jpgFileName = paste(filename.root, ".jpeg", sep = "" )
    jpeg(filename = jpgFileName,
         width = as.integer (ascFileHeaderAsStrVals$numCols),
         height = as.integer (ascFileHeaderAsStrVals$numRows),
         units = "px",
         pointsize = 12,
         quality = 100
         #,    #  75,

#         bg = "white",
#         res = NA,
#         type = c("cairo", "Xlib", "quartz"),
#         antialias
         )
    }


}

#===============================================================================

write.pgm.txt.files <- function (table.to.write, filename.root,
                            num.table.rows, num.table.cols)
  {
    if( DEBUG ) cat( "\nIn function: write.pgm.txt.files, file: w.R\n" )

    write.txt.file(table.to.write, filename.root,
                   num.table.rows, num.table.cols );
    write.pgm.file(table.to.write, filename.root,
                   num.table.rows, num.table.cols );
    return( TRUE );

  }


#===============================================================================

write.asc.txt.files <- function (table.to.write, filename.root,
                            num.table.rows, num.table.cols)
  {
    if( DEBUG ) cat( "\nIn function: write.asc.txt.files, file: w.R\n" )

    write.asc.file(table.to.write, filename.root,
                   num.table.rows, num.table.cols );
    write.txt.file(table.to.write, filename.root,
                   num.table.rows, num.table.cols );
    return( TRUE );

  }


#===============================================================================

write.to.3.forms.of.files <- function (table.to.write, filename.root,
					num.table.rows, num.table.cols)
  {
    if (DEBUG) {
      cat( "\nIn function: write.to.3.forms.of.files, file: w.R\n" )
      show( num.table.rows )
      show( num.table.cols )
      show(dim(table.to.write));
      show(table.to.write[1,1]);

      cat ("\nIn write.to.3.forms.of.files:");
      cat ("\n\tis.integer(table.to.write) = ", is.integer(table.to.write));
      cat ("\n\tis.real(table.to.write) = ", is.real(table.to.write));
      cat ("\n\tis.numeric(table.to.write) = ", is.numeric(table.to.write));
    }

    write.txt.file(table.to.write, filename.root,
                   num.table.rows, num.table.cols );
    write.pgm.file(table.to.write, filename.root,
                   num.table.rows, num.table.cols );
    write.asc.file(table.to.write, filename.root,
                   num.table.rows, num.table.cols );
    return( TRUE );
}

#===============================================================================

writeOutputVector <- function( outfilename, vecname ) {

  write.table( vecname, file= outfilename,
              row.names = FALSE, col.names = FALSE );

  cat( '\nwrote', outfilename );
}

#===============================================================================

##Removed 2013.04.08 BTL## #===============================================================================
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##     #  Should these read/get routines be in some other file since this
##Removed 2013.04.08 BTL##     #  is w.R, as in write.R?  Can't find any analogous file for reading
##Removed 2013.04.08 BTL##     #  though.  May want to create an r.R file or something like that
##Removed 2013.04.08 BTL##     #  but no time right now...
##Removed 2013.04.08 BTL##     #  Putting them here now because it's convenient...
##Removed 2013.04.08 BTL##     #  BTL - 2011.08.07
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL## #===============================================================================
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##     #  2011.08.07 - BTL - Moved from text.maxent.v3.R.
##Removed 2013.04.08 BTL##     #  2011.09.21 - BTL - Modified to only have one argument instead of two.
##Removed 2013.04.08 BTL##     #                     Used to require directory separate from filename.
##Removed 2013.04.08 BTL##     #                     Now just wants filename.
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##     #  NOTE: This might need the pixmap library, but I won't know until I try
##Removed 2013.04.08 BTL##     #  to call it.  test.maxent.v3.R has the following call that might be for
##Removed 2013.04.08 BTL##     #  this or for something else.  If this doesn't work here, try adding
##Removed 2013.04.08 BTL##     #  this library line:
##Removed 2013.04.08 BTL##     #      library (pixmap)
##Removed 2013.04.08 BTL## library (pixmap)
##Removed 2013.04.08 BTL## get.img.matrix.from.pnm <- function (full.img.filename)
##Removed 2013.04.08 BTL##   {
##Removed 2013.04.08 BTL##         #-----------------------------------------
##Removed 2013.04.08 BTL##         #  Load the input image from a pnm file.
##Removed 2013.04.08 BTL##         #-----------------------------------------
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL## #  cat ("\n  Reading '", full.img.filename, "'", sep='')
##Removed 2013.04.08 BTL##     img <- read.pnm (full.img.filename)
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##     #plot (img)    #  This take a LONG beachball sort of time to plot the image,
##Removed 2013.04.08 BTL##     #                #  but eventually, it does return with a nice image.
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##         #-----------------------------------------------------------------
##Removed 2013.04.08 BTL##         #  Extract the image data from the pixmap as a matrix so that we
##Removed 2013.04.08 BTL##         #  can manipulate the data.
##Removed 2013.04.08 BTL##         #-----------------------------------------------------------------
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##     img.matrix <- img@grey
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##     return (img.matrix)
##Removed 2013.04.08 BTL##     }
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL## #-------------------------------------------------------------------------------
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##     #  Moved from test.maxent.v3.R - August 7 - 2011, BTL.
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL## ###  2012.07.30 - BTL
##Removed 2013.04.08 BTL## testConvert <- function (targetMatrixSize)
##Removed 2013.04.08 BTL##   {
##Removed 2013.04.08 BTL##   base.asc.name = "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/Test2"
##Removed 2013.04.08 BTL##       pnm.to.asc.input.img.dir = paste (base.asc.name, "/", sep='')
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##   cat ("\npnm.to.asc.input.img.dir = ", pnm.to.asc.input.img.dir)
##Removed 2013.04.08 BTL##            # browser()
##Removed 2013.04.08 BTL##   convert.pnm.files.in.dir.to.asc.files (pnm.to.asc.input.img.dir,
##Removed 2013.04.08 BTL##                                          pnm.to.asc.input.img.dir, # env.layers.dir
##Removed 2013.04.08 BTL##                                          targetMatrixSize
##Removed 2013.04.08 BTL##                                          )
##Removed 2013.04.08 BTL##   cat ("\n\n")
##Removed 2013.04.08 BTL##   }
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL## convert.pnm.files.in.dir.to.asc.files <- function (input.dir, output.dir, targetMatrixSize=-1)
##Removed 2013.04.08 BTL## 	{
##Removed 2013.04.08 BTL##   cat("\n\n---> starting convert.pnm.files.in.dir.to.asc.files\n")
##Removed 2013.04.08 BTL## 	pnm.files <- dir (path=input.dir, pattern="*.pnm")
##Removed 2013.04.08 BTL##   #browser()
##Removed 2013.04.08 BTL## 	for (cur.pnm.filename in pnm.files)
##Removed 2013.04.08 BTL## 	    {
##Removed 2013.04.08 BTL## 	    cat ("\nConverting pnm file '", cur.pnm.filename, "' to .asc file.", sep='')
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##         #-----------------------------------------
##Removed 2013.04.08 BTL##         #  Load the input image from a pnm file.
##Removed 2013.04.08 BTL##         #-----------------------------------------
##Removed 2013.04.08 BTL## 	    #browser()
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL## 	    get.img.matrix.from.pnm.and.write.asc.equivalent (input.dir,
##Removed 2013.04.08 BTL## 	    												                          output.dir,    # env.layers.dir,
##Removed 2013.04.08 BTL## 	    												                          cur.pnm.filename,
##Removed 2013.04.08 BTL##                                                         targetMatrixSize)
##Removed 2013.04.08 BTL## 	    }
##Removed 2013.04.08 BTL## 	cat ("\n\nDone converting pnm files to asc files.\n\n")
##Removed 2013.04.08 BTL## 	}
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL## #-------------------------------------------------------------------------------
##Removed 2013.04.08 BTL## #-------------------------------------------------------------------------------
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##     #  Added July 23, 2011 - BTL.
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL## read.asc.file.to.matrix <-
##Removed 2013.04.08 BTL## #        function (base.asc.filename.to.read, input.dir = "./")
##Removed 2013.04.08 BTL##         function (base.asc.filename.to.read, input.dir = "")
##Removed 2013.04.08 BTL##   {
##Removed 2013.04.08 BTL##   name.of.file.to.read <- paste (base.asc.filename.to.read, '.asc', sep='')
##Removed 2013.04.08 BTL##   asc.file.as.matrix <-
##Removed 2013.04.08 BTL##   as.matrix (read.table (paste (input.dir, name.of.file.to.read, sep=''),
##Removed 2013.04.08 BTL## 	                       skip=6))
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL##   return (asc.file.as.matrix)
##Removed 2013.04.08 BTL##   }
##Removed 2013.04.08 BTL##
##Removed 2013.04.08 BTL## #===============================================================================
##Removed 2013.04.08 BTL##
