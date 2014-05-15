
    #--------------------------------------------------------------
    # This contains some unitility functions. To write tables and
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
    #  re-ogranised so can call functions to write each file type
    #  individually or in any combination - 29 april - AG
    #
    #  Changed write.pgm.file to check for divide by zero when
    #  rescaling non-integer values to be integers.
    #  In files that were all zero, it would get a divide by zero
    #  and fill the output with NaN values.
    #  BTL - 8/28/07.
    #
    #--------------------------------------------------------------

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


write.txt.file <- function (table.to.write, filename.root, 
                            num.table.rows, num.table.cols)
  {
    #########################
    #write the raw text ascii file
  
    rawFileName = paste(filename.root, ".txt", sep = "" )

    if (DEBUG) {
      cat ("\nIn write.txt.file, rawFileName = ", rawFileName);
    }

    write.table( table.to.write, file= rawFileName, 
		row.names = FALSE, col.names = FALSE );

    cat( '\nwrote', rawFileName );

  }

write.asc.file <- function (table.to.write, filename.root, 
                            num.table.rows, num.table.cols,
                            xllcorner = 0.0,	    #  BTL - 2011.02.15 - Added. 
                            yllcorner = 0.0,
                            no.data.value = 0,      #  BTL - 2011.02.13 - Added.
			    cellsize = 1	    #  BTL - 2011.02.15 - Added.
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

#----------------------------------------------------------------------------

writeOutputVector <- function( outfilename, vecname ) {

  write.table( vecname, file= outfilename,
              row.names = FALSE, col.names = FALSE );
  
  cat( '\nwrote', outfilename );
}

#----------------------------------------------------------------------------


