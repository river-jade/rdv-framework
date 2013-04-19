#===============================================================================

								#  read.R

#  source ('read.R')

	#  Taken originally from guppy version of w.R from around Austin ESA and
	#  last seen in my rdv snapshot of:
    #  /Users/Bill/D/rdv-framework-old.versions/rdv-framework-before-2012-07-25/R
    #  None of the updates in here were in the later rdv versions of w.R
    #  on my disk or on the repository.  Not sure why.
    #  Have now commented out all the read routines that were in w.R at the
    #  bottom of that file and moved them into here.
	#  2013 04 08 - BTL

#===============================================================================

    #--------------------------------------------------------------
    #  Added read.asc.file.to.matrix() [to test.maxent.v3.R ??]
    #  BTL - 2011.07.23
    #
    #  Added functions related to reading pnm files and converting
    #  them to asc files.
    #  Originally added to w.R because it was already in repository and
    #  was convenient just to modify that instead of adding new file to
    #  repository.
    #  BTL - 2011.08.07
    #
    #  Moved get.img.matrix.from.pnm.and.write.asc.equivalent()
    #  to guppy.maxent.functions.v7.R
    #  BTL - 2011.09.22
    #
    #--------------------------------------------------------------

#===============================================================================

    #  2011.08.07 - BTL - Moved from test.maxent.v3.R.
    #  2011.09.21 - BTL - Modified to only have one argument instead of two.
    #                     Used to require directory separate from filename.
    #                     Now just wants filename.

    #  NOTE: This might need the pixmap library, but I won't know until I try
    #  to call it.  test.maxent.v3.R has the following call that might be for
    #  this or for something else.  If this doesn't work here, try adding
    #  this library line:
    #      library (pixmap)
library (pixmap)
get.img.matrix.from.pnm <- function (full.img.filename)
  {
        #-----------------------------------------
        #  Load the input image from a pnm file.
        #-----------------------------------------

#  cat ("\n  Reading '", full.img.filename, "'", sep='')
    img <- read.pnm (full.img.filename)

    #plot (img)    #  This take a LONG beachball sort of time to plot the image,
    #                #  but eventually, it does return with a nice image.

        #-----------------------------------------------------------------
        #  Extract the image data from the pixmap as a matrix so that we
        #  can manipulate the data.
        #-----------------------------------------------------------------

    img.matrix <- img@grey

cat ("\n\nis.matrix(img.matrix) in get.img.matrix.from.pnm = '", is.matrix(img.matrix), "\n", sep='')
cat ("\n\nis.vector(img.matrix) in get.img.matrix.from.pnm = '", is.vector(img.matrix), "\n", sep='')
cat ("\n\ndim(img.matrix) in get.img.matrix.from.pnm = '", dim(img.matrix), "\n", sep='')

    return (img.matrix)
    }

#-------------------------------------------------------------------------------

    #  Moved from test.maxent.v3.R - August 7 - 2011, BTL.

###  2012.07.30 - BTL
testConvert <- function (targetMatrixSize)
  {
  base.asc.name = "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/Test2"
      pnm.to.asc.input.img.dir = paste (base.asc.name, "/", sep='')

  cat ("\npnm.to.asc.input.img.dir = ", pnm.to.asc.input.img.dir)
           # browser()
  convert.pnm.files.in.dir.to.asc.files (pnm.to.asc.input.img.dir,
                                         pnm.to.asc.input.img.dir, # env.layers.dir
                                         targetMatrixSize
                                         )
  cat ("\n\n")
  }

#-----------------------------------

convert.pnm.files.in.dir.to.asc.files <- function (input.dir, output.dir,
													targetMatrixSize=-1)
	{
  cat("\n\n---> starting convert.pnm.files.in.dir.to.asc.files\n")
	pnm.files <- dir (path=input.dir, pattern="*.pnm")
  #browser()
	for (cur.pnm.filename in pnm.files)
	    {
	    cat ("\nConverting pnm file '", cur.pnm.filename, "' to .asc file.", sep='')

        #-----------------------------------------
        #  Load the input image from a pnm file.
        #-----------------------------------------
	    #browser()

	    get.img.matrix.from.pnm.and.write.asc.equivalent (input.dir,
	    										output.dir,
	    										# env.layers.dir,
	    										cur.pnm.filename,
                                                targetMatrixSize)
	    }
	cat ("\n\nDone converting pnm files to asc files.\n\n")
	}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

    #  Added July 23, 2011 - BTL.

read.asc.file.to.matrix <-
#        function (base.asc.filename.to.read, input.dir = "./")
        function (base.asc.filename.to.read, input.dir = "")
  {
  name.of.file.to.read <- paste (base.asc.filename.to.read, '.asc', sep='')
  asc.file.as.matrix <-
  as.matrix (read.table (paste (input.dir, name.of.file.to.read, sep=''),
	                       skip=6))

  return (asc.file.as.matrix)
  }

#===============================================================================

