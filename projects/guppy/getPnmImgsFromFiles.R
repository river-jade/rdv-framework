#===============================================================================

#  source ('getPnmImgsFromFiles.R')

#===============================================================================

get.img.matrix.from.pnm <- function (input.dir, pnm.base.filename)
    {
        #-----------------------------------------
        #  Load the input image from a pnm file.
        #-----------------------------------------

	full.img.filename <- paste (input.dir, pnm.base.filename, sep='')
	cat ("\n  Reading '", full.img.filename, "'", sep='')
    img <- read.pnm (full.img.filename)

    #plot (img)    #  This take a LONG beachball sort of time to plot the image,
    #                #  but eventually, it does return with a nice image.

        #-----------------------------------------------------------------
        #  Extract the image data from the pixmap as a matrix so that we
        #  can manipulate the data.
        #-----------------------------------------------------------------

    img.matrix <- img@grey

    return (img.matrix)
    }

#===============================================================================

get.img.matrix.from.pnm.and.write.asc.equivalent <- function (input.dir, output.dir,
												  			  pnm.base.filename)
    {
        #-----------------------------------------
        #  Load the input image from a pnm file.
        #-----------------------------------------

	img.matrix <- get.img.matrix.from.pnm (input.dir, pnm.base.filename)

        #---------------------------------------------
        #  Write the image data out in the form that
        #  maxent expects, i.e., ESRI .asc format.
        #---------------------------------------------

	img.filename.root <- (strsplit (pnm.base.filename, ".pnm")) [[1]]
    cat ("\n    base name = '", img.filename.root, "'.", sep='')

    num.table.rows <- (dim (img.matrix))[1]
    num.table.cols <- (dim (img.matrix))[2]

    asc.filename.root <- paste (output.dir, img.filename.root, sep='')



    write.asc.file (img.matrix, asc.filename.root,
                    num.table.rows, num.table.cols
                    , xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
                    , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
                                      #  is not actually on the map.  It's just off the lower
                                      #  left corner.
                    , no.data.value = -9999    #  Maxent's missing value flag
                    , cellsize = 1
                    )

        #-----------------------------------------------------------
        #  Caller doesn't need anything other than the image data.
        #-----------------------------------------------------------

    return (img.matrix)
    }

#===============================================================================

	#  This isn't called yet, but it's here to use when we're ready to do
	#  a lot of these.

convert.pnm.files.in.dir.to.asc.files <- function (input.dir)
	{
	pnm.files <- dir (path=input.dir, pattern="*.pnm")
	for (cur.pnm.filename in pnm.files)
	    {
	    cat ("\nConverting pnm file '", cur.pnm.filename, "' to .asc file.", sep='')

	    get.img.matrix.from.pnm.and.write.asc.equivalent (input.dir,
	    												  env.layers.dir,
	    												  cur.pnm.filename)
	    }
	cat ("\n\nDone converting pnm files to asc files.\n\n")
	}

#===============================================================================
