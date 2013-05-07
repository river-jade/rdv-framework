#===============================================================================

#  To run the current version of the code:

#      source ('test.maxent.v5.R')

#  Note that it currently assumes the following directory structure
#  of that MaxentTest directory:

#    drwxr-xr-x   5 bill  staff     170 20 Jan 11:20 AlexsSyntheticLandscapes
#    drwxr-xr-x   6 bill  staff     204 17 Feb 13:09 MaxentEnvLayers
#    drwxr-xr-x  14 bill  staff     476 17 Feb 13:48 MaxentOutputs
#    drwxr-xr-x   4 bill  staff     136 17 Feb 12:55 MaxentProbDistLayers
#    drwxr-xr-x   2 bill  staff      68 17 Feb 11:15 MaxentProjectionLayers
#    drwxr-xr-x   5 bill  staff     170 17 Feb 13:10 MaxentSamples
#    drwxr-xr-x   3 bill  staff     102 18 Feb 12:30 ResultsAnalysis
#    -rw-r--r--@  1 bill  staff   25339 18 Feb 12:55 test.maxent.R
#    -rw-r--r--@  1 bill  staff    8617 17 Feb 13:22 w.R

#  Also note that w.R is a modified version of w.R from the framework.
#  Need to commit it to the framework so that the changes to write.asc.file()
#  are generally available.  Those changes are simple ones and only involve
#  making a bunch of the parameters able to be specified in the call rather
#  than fixed inside the routine.  All of the new call arguments default to
#  the old values though, so no existing framework code should be broken by
#  this.

#-------------------------

#  NOTE: things to add to the ML book
#        (have added this to evernote on 2011.07.17)
#
#      - Having spaces in a file path can cause R to choke on the mac.
#        If I do something like:
#            dir (probabilities.dir)
#        when probabilities directory ccontains embedded spaces like this:
#            probabilities.dir <- "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated ecology/MaxentTests/MaxentProbDistLayers/"
#        then R returns
#            char(0)
#        which is similar to what the shell terminal window gives:
#            > ls -l /Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated ecology/MaxentTests/MaxentProbDistLayers/
#            > ls: -: No such file or directory


#===============================================================================

#  History
#
#  2013 04 29 - BTL
#  Stripped out everything before zonation section of test.maxent.v5.R to
#  make a starting point for the code to run zonation.  Will source this
#  file from inside the new runMaxent.R code.

#===============================================================================

#  2013 04 29 - BTL
#  History from here down is old history from test.maxent.v5.R.
#  Some of it may no longer apply, but some of it may help explain
#  some things that are in here.  Can remove it all later when the
#  more final version of this code is working.

#  2011.02.18 - BTL
#  Have now completed a prototype that goes all the way through the process
#  of:
#    - reading a pair of environment layers from .pnm files
#    - combining them in some way to produce a "correct" probability
#      distribution
#    - drawing a "correct" population of presences from that distribution
#    - sampling from that correct population to get the "apparent" population
#    - running maxent on that sample plus the environment layers
#    - reading maxent's resulting estimate of the probability distribution
#    - computing the error between maxent's normalized distribution and the
#      correct normalized distribution
#    - computing some statistics and possibly showing a heatmap of the errors
#      as a first cut at examining the spatial distribution of error.
#
#  There are lots of restrictions and assumptions about formats and locations
#  and hard-coded rules for combining layers and you still have to run maxent
#  by hand.  However, some version of every step is there and it works from
#  end to end to get a result.  Now we just need to:
#    - expand the capabilities of each step
#    - add the ability to inject error in all inputs and processes
#    - turn it into a class to make it easier to use and to swap methods
#      in and out
#    - make a project for it in the framework and give it access to yaml
#      files for setting control variables and run over many different
#      scenarios and inputs

#  2011.08.07 - BTL
#  Working on ESA version now.
#  Most of that work will happen in the guppy project of framework2, but
#  some things may happen here as well.
#    - Just moved defn of get.img.matrix.from.pnm() to w.R in framework2/R.
#    - Extracted all of the function definitions into test.maxent.functions.v4.R
#      since this file was too complicated to read easily.

#===============================================================================

#source ('w.R')
#source ('/Users/bill/D/rdv-svn/rdv-framework/trunk/framework2/rdv/R/w.R')

library (pixmap)

#===============================================================================

setUpAndRunZonation = function (spp.list.filename,
								zonation.files.dir,
								zonation.input.maps.dir,
								spp.used.in.reserve.selection.vector,
								zonation.output.filename,
								full.path.to.zonation.parameter.file,
								full.path.to.zonation.exe,
								runZonation,
								sppFilePrefix,
								closeZonationWindowOnCompletion
								)
	{
	zonation.spp.list.full.filename <-
		paste (zonation.files.dir, '/', spp.list.filename, sep ='' )

	if (file.exists (zonation.spp.list.full.filename))
		file.remove (zonation.spp.list.full.filename)

		#  Need to build the spp_list.dat file.
		#  In /Users/bill/D/rdv-svn/rdv-framework/trunk/framework2/rdv/lib/zonation/spp_list.dat
		#      1.0 1.0 2 10 1.0 /Users/ascelin/analysis/zonation/wine_test2_data/spp1.asc
		#      1.0 1.0 2 10 1.0 /Users/ascelin/analysis/zonation/wine_test2_data/spp2.asc
		#      1.0 1.0 2 10 1.0 /Users/ascelin/analysis/zonation/wine_test2_data/spp3.asc

zonation.input.maps.dir = gsub ("Documents and Settings", "DOCUME~1", zonation.input.maps.dir)
	for (cur.spp.id in spp.used.in.reserve.selection.vector)
		{
#		filename <- paste (zonation.input.maps.dir, '/', 'spp.', cur.spp.id, '.asc', sep = '' );
##		filename <- paste ('"', zonation.input.maps.dir, dir.slash, 'spp.',
##							cur.spp.id, '.asc', '"', sep = '' );
			#  sppFilePrefix is different for correct and apparent species.
			#  For apparent, it will just be "spp", but for correct,
			#  it will probably be something like "true.prob.dist.spp".
		filename <- paste (zonation.input.maps.dir, dir.slash, sppFilePrefix, '.',
							cur.spp.id, '.asc', sep = '' );
		line.of.text <- paste ("1.0 1.0 1 1 1 ", filename, "\n", sep = "");
		cat (line.of.text, file = zonation.spp.list.full.filename, append = TRUE);
		}

		#  From /Users/bill/D/rdv-svn/rdv-framework/trunk/framework2/rdv/lib/zonation/README.txt
		#  Example to call zonation with wine on mac or linux:
		#  > wine zig2 -r Z_parameter_settings.dat spp_list.dat output.txt 0.0 0 1.0 1
		#  The last number in the list autoclose (if set to 0 then zonation will stay open after it finishes running)

	zonation.full.output.filename =
		paste (zonation.files.dir, '/', zonation.output.filename, sep='')

		#  Maxent's command line parsing chokes on Windows file names that
		#  contain spaces, so you need to put quotes around all the path
		#  or file names that you hand to it.
filenameQuote = '"'

full.path.to.zonation.exe = gsub ("Documents and Settings", "DOCUME~1", full.path.to.zonation.exe)
full.path.to.zonation.parameter.file = gsub ("Documents and Settings", "DOCUME~1", full.path.to.zonation.parameter.file)
zonation.spp.list.full.filename = gsub ("Documents and Settings", "DOCUME~1", zonation.spp.list.full.filename)
zonation.full.output.filename = gsub ("Documents and Settings", "DOCUME~1", zonation.full.output.filename)




##	system.command.run.zonation <- paste (
##	######									'/sw/bin/wine',
##		filenameQuote,
##										full.path.to.zonation.exe,
##		filenameQuote, " ",
##
##										'-r', " ",
##		filenameQuote,
##										full.path.to.zonation.parameter.file,
##		filenameQuote, " ",
##
##		filenameQuote,
##										zonation.spp.list.full.filename,
##		filenameQuote, " ",
##
##		filenameQuote,
##										zonation.full.output.filename,
##		filenameQuote, " ",
##
##
##	#                                      "0.0 0 1.0 1" ,    #  close Zonation after finished
##										  "0.0 0 1.0 0" ,    #  stay open after finished
##										  sep='')


##if (closeZonationWindowOnCompletion)


	system.command.run.zonation <- paste (
	######									'/sw/bin/wine',
										full.path.to.zonation.exe,
										'-r',
										full.path.to.zonation.parameter.file,
										zonation.spp.list.full.filename,
										zonation.full.output.filename,
                                      	"0.0 0 1.0",
										as.integer (closeZonationWindowOnCompletion)
										)

	cat( '\n The system command to run zonation will be:', system.command.run.zonation )

	#---------------------

#  Can't run zonation under wine yet, so only allow it to be tried
#  under Windows for now...

##if (current.os == "mingw32")
##{
		#  Run Zonation.
	if (runZonation)
		{
##		system (system.command.run.zonation)

		if( current.os == 'mingw32' )
			{
##			system.specific.cmd <- ''
			retval = system (system.command.run.zonation)

			} else
			{
		  	system.specific.cmd <- 'wine'
cat ("\n\nAbout to run zonation using system.specific.cmd = '", system.specific.cmd, "'\n\n", sep='')

##		retval = system2( system.specific.cmd, args=system.command.run.zonation, env="DISPLAY=:1" )
			retval = system2( system.specific.cmd, args=system.command.run.zonation, env="DISPLAY=:1" )
			}

cat ("\n\nzonation retval = '", retval, "'.\n\n", sep='')

		}
##}
	}

#===============================================================================

#browser()

    #--------------------

PAR.zonation.exe.filename = variables$PAR.zonation.exe.filename
PAR.path.to.zonation = variables$PAR.path.to.zonation
full.path.to.zonation.exe <- paste (startingDir, '/',
									PAR.path.to.zonation,  '/',
                                   PAR.zonation.exe.filename, sep = '')


zonation.files.dir = outputFiles$PAR.zonation.files.dir.name
zonation.files.dir.with.slash = paste (zonation.files.dir, "/", sep='')

	#  Kluge to deal with lots of Windows problems running zonation
	#  using file names with embedded spaces.
	#  So far, they're all due to the "Documents and Settings" directory,
	#  so I'll deal with that.  In the Windows terminal window you can
	#  ask Windows for a no-spaces version of the name of a directory
	#  by using the -x option on dir, e.g., sitting above the
	#  "Documents and Settings" in C: and giving the command "dir /x", will
	#  list the shortened names of all the files and directories there,
	#  including "DOCUME~1 for "Documents and Settings".
	#  I think that these problems may primarily be coming from the use of
	#  the Windows environment variable called HOMEPATH to determine
	#  where to hang the temporary output directories.  I suspect that
	#  is what tzar is doing.  If we could get tzar to fix it up right
	#  when it's created, then none of this would be necessary here.
	#  Note, I found HOMEPATH by running the SET command with no arguments
	#  to see all declared variables in the environment, because a web site
	#  had mentioned that the similarly troublesome directory called
	#  "Program Files" has a name stored in the environment that you can
	#  use to avoid these space-based problems.

zonation.files.dir.with.slash = gsub ("Documents and Settings", "DOCUME~1", zonation.files.dir.with.slash)

cat ("\nzonation.files.dir = '", zonation.files.dir, "'", sep='')
if ( !file.exists (zonation.files.dir))
  {
  dir.create (zonation.files.dir)
  }

zonation.parameter.filename = variables$PAR.zonation.parameter.filename
#full.path.to.zonation.parameter.file <- paste (startingDir, '/',
#									PAR.path.to.zonation,  '/',
#                                   zonation.parameter.filename, sep = '')
full.path.to.zonation.parameter.file <- variables$PAR.zonation.parameter.filename
cat ("\n\nfull.path.to.zonation.parameter.file = '",
	full.path.to.zonation.parameter.file, "'\n\n", sep='')
#stop()

PAR.num.spp.in.reserve.selection = variables$PAR.num.spp.in.reserve.selection
spp.used.in.reserve.selection.vector <- 1:PAR.num.spp.in.reserve.selection

runZonation = variables$PAR.run.zonation

    #--------------------

	#  APPARENT
zonation.APP.spp.list.filename = variables$PAR.zonation.app.spp.list.filename
zonation.APP.output.filename = variables$PAR.zonation.app.output.filename
zonation.APP.input.maps.dir = maxent.output.dir
		#  root not used anymore?
##zonation.APP.spp.hab.map.filename.root = paste (zonation.APP.input.maps.dir, '/', "spp", sep='')
#zonation.APP.spp.hab.map.filename.root = paste (zonation.APP.input.maps.dir, dir.slash, "spp", sep='')

setUpAndRunZonation (zonation.APP.spp.list.filename,
					zonation.files.dir,
					zonation.APP.input.maps.dir,
					spp.used.in.reserve.selection.vector,
					zonation.APP.output.filename,
					full.path.to.zonation.parameter.file,
					full.path.to.zonation.exe,
					runZonation,
					"spp",
					variables$PAR.closeZonationWindowOnCompletion
					)

	#  CORRECT
zonation.COR.input.maps.dir = prob.dist.layers.dir
zonation.COR.spp.list.filename = variables$PAR.zonation.cor.spp.list.filename
zonation.COR.output.filename = variables$PAR.zonation.cor.output.filename
		#  root not used anymore?
##zonation.COR.spp.hab.map.filename.root = paste (zonation.COR.input.maps.dir, '/', "spp", sep='')

setUpAndRunZonation (zonation.COR.spp.list.filename,
					zonation.files.dir,
					zonation.COR.input.maps.dir,
					spp.used.in.reserve.selection.vector,
					zonation.COR.output.filename,
					full.path.to.zonation.parameter.file,
					full.path.to.zonation.exe,
					runZonation,
					"true.prob.dist.spp",
					variables$PAR.closeZonationWindowOnCompletion
					)

cat ("\n\nDone setting up and running zonation.\n\n")
#stop()

#===============================================================================

## if( ! file.copy( "../zonation/zonation_output.rank.asc", ".",
##                 overwrite = TRUE )) {

##   cat( '\nCould not copy zonation result to runall directory\n' );
##   stop( '\nAborted due to error.', call. = FALSE );

## }

## # read in the zonation output file. Remove the header that the ".asc"
## # file contains

#rows = num.rows
#number.asc.header.rows <- 6;  #number of header rows in the ascii files for
#                              #zonation.

zonation.app.rank =
    read.asc.file.to.matrix ("zonation_app_output.rank",
    						zonation.files.dir.with.slash)
#"/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/Zonation/")

zonation.cor.rank =
    read.asc.file.to.matrix ("zonation_cor_output.rank",
    						zonation.files.dir.with.slash)
#"/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/Zonation/")

    #--------------------

  #  Compute the difference between the correct and zonation probabilities
	#  and save it to a file for display.
err.between.app.and.zonation.ranks <- zonation.app.rank - zonation.cor.rank

num.img.rows <- dim (err.between.app.and.zonation.ranks) [1]
num.img.cols <- dim (err.between.app.and.zonation.ranks) [2]

write.pgm.file (err.between.app.and.zonation.ranks,
				paste (zonation.files.dir.with.slash,
						"raw.error.in.zonation.ranks", sep=''),
            	num.img.rows, num.img.cols)

    #-------------------------------------------------------------------------
    #  Plot that pattern.
    #  Compute non-spatial statistics that compare the two distributions.
    #    - rank correlation
    #    - correlation
    #    - KS test  (is KS the test that compares two distributions?)
    #  One question: are there any computer arithmetic issues with all these
    #  small numbers in these distributions?
    #-------------------------------------------------------------------------

    #--------------------------------------------------------------------
    #  IMPORTANT
    #  NOTE:  May want to do these tests using several different views
    #         that reflect something like a cost-sensitive view.
    #         For example, what is most important in a Madagascar-style
    #         use of maxent + zonation is how the true top 10% of the
    #         distribution performs.
    #         So, you may want to use which() to pull out certain
    #         subsets of locations to analyze.
    #         More importantly, probably want to do a which() that
    #         selects the top 10% or so of locations in the true
    #         distribution and the true Zonation ranking.  Then,
    #         do various statistics on just those locations in the
    #         Maxent data to get an idea of how well it does on those.
    #         One more thing - percent error may not be the right
    #         error to look at in a probability distribution.
    #         May want to look at the absolute error instead.
    #         Not sure...
    #--------------------------------------------------------------------

err.magnitudes <- abs (err.between.app.and.zonation.ranks)
# write.asc.file (err.magnitudes,
# 				paste (analysis.dir, "abs.error.in.dist.", spp.name, sep=''),
#             	num.img.rows, num.img.cols
#             	, xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
#                 , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
#                                       #  is not actually on the map.  It's just off the lower
#                                       #  left corner.
#                 , no.data.value = -9999
#                 , cellsize = 1
#                 )
write.pgm.file (err.magnitudes,
				paste (analysis.dir.with.slash,
						"abs.error.in.zonation.ranks", sep=''),
            	num.img.rows, num.img.cols)


tot.err.magnitude <- sum (err.magnitudes)
max.err.magnitude <- max (err.magnitudes)

  ####  PROBLEM: norm.prob.matrix not defined?  zonation.norm.prob.dist not defined?

	########  Should these be cor and app instead?
	########  I.e., npm.vec ----> norm.prob.cor.vec and
	########       mnpd.vec ----> norm.prob.app.vec ???
	########  BTL - 2013.05.06

	########  Also, is it really necessary to convert these to vectors?
	########  Doesn't R already treat them as vectors except when you apply
	########  matrix operations to them?


#npm.vec <- as.vector (norm.prob.matrix)
npm.vec <- as.vector (zonation.app.rank)
#mnpd.vec <- as.vector (zonation.norm.prob.dist)
mnpd.vec <- as.vector (zonation.cor.rank)

pearson.cor <- cor (npm.vec, mnpd.vec,
     			    method = "pearson"
     			   )
spearman.rank.cor <- cor (npm.vec, mnpd.vec,
     			    method = "spearman"
     			   )

#  this one hung R every time I used it...
##kendall.cor <- cor (npm.vec, mnpd.vec,
##     			    method = "kendall"
##     			   )

##par (mfrow=c(4,2))    #  4 rows, 2 cols
par (mfrow=c(2,2))    #  2 rows, 2 cols

percent.err.magnitudes <- (err.magnitudes / zonation.cor.rank) * 100
hist (percent.err.magnitudes [percent.err.magnitudes <= 100])

write.pgm.file (percent.err.magnitudes,
				paste (analysis.dir.with.slash,
						"percent.error.in.zonation.ranks", sep=''),
            	num.img.rows, num.img.cols)

abs.percent.err.magnitudes <- abs (percent.err.magnitudes)
write.pgm.file (abs.percent.err.magnitudes,
				paste (analysis.dir.with.slash,
						"abs.percent.error.in.zonation.ranks", sep=''),
            	num.img.rows, num.img.cols)


##    #  Reset the largest errors to one fairly large value so that
##    #  you can reduce the dynamic range of the image and make it
##    #  easier to differentiate among smaller values.

truncated.err.img <- abs.percent.err.magnitudes
truncated.err.img [percent.err.magnitudes >= 50] <- 50
write.pgm.file (truncated.err.img,
				paste (analysis.dir.with.slash,
						"truncated.zonation.rank.percent.err.img", sep=''),
            	num.img.rows, num.img.cols)


    if (write.to.file)  tiff (paste (analysis.dir, "percent.error.zonation.rank.map.tiff", sep=''))
#    plot.main.title <- "Percent error in Zonation rank"
#    plot.key.title <- "Error\n(percent)"
#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
    contour.levels.to.draw <- c (20)
    draw.contours = TRUE
    draw.filled.contour.img (truncated.err.img,
                             "Truncated percent error in Zonation rank",
                             "Error\n(percent)",
                             terrain.colors, "red",
                             draw.contours,
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()

    if (write.to.file)  tiff (paste (analysis.dir.with.slash,
    								"raw.error.zonation.rank.map.tiff", sep=''))
#    plot.main.title <- "Percent error in Zonation rank"
#    plot.key.title <- "Error\n(percent)"
#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
    contour.levels.to.draw <- c (-0.50, 0.0)
    draw.contours = TRUE
    draw.filled.contour.img (err.between.app.and.zonation.ranks,
                             "Raw error in Zonation rank",
                             "Error\n(raw)",
                             terrain.colors, "red",
                             draw.contours,
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()

#  Not sure what's going on here.  Trying to put a contour around the top
#  10% or so of zonation ranks, but it doesn't seem to agree with the .jpg
#  files that zonation writes out (bright red, etc.).
#     if (write.to.file)  tiff (paste (analysis.dir, "zonation.app.rank.map.tiff", sep=''))
#     contour.levels.to.draw <- c (0.10)
#     draw.contours = TRUE
#     draw.filled.contour.img (zonation.app.rank,
#                              "Zonation Apparent rank",
#                              "Rank",
#                              terrain.colors, "red",
#                              draw.contours,
#                              contour.levels.to.draw
#                              )
#     if (write.to.file)  dev.off()
#
#     if (write.to.file)  tiff (paste (analysis.dir, "zonation.cor.rank.map.tiff", sep=''))
#     contour.levels.to.draw <- c (0.10)
#     draw.contours = TRUE
#     draw.filled.contour.img (zonation.cor.rank,
#                              "Zonation Correct rank",
#                              "Rank",
#                              terrain.colors, "red",
#                              draw.contours,
#                              contour.levels.to.draw
#                              )
#     if (write.to.file)  dev.off()

#===============================================================================

# From: nearest-neighbor.pdf slides
#
# Distance-Weighting
# Rather than treating each neighbor equally, give more weight to closer neighbors. Predict with:
# - Classification: the class with the highest sum of weights.
# - Regression: the weighted average, e.g.,
#     y = [sum from i=1 to k (yi / d(x,xi))] /
#         [sum from i=1 to k (1 / d(x,xi))]
# To avoid division by 0, add a small value to d.
# BTL: (e.g., maybe use min value of d (divided by 10 or 100 or ?)?)
#
# Issues of kNN
#
# Scaling
# Attributes can have widely different ranges, e.g., Aluminum and Refractive Index. Consider:
# • Normalization. Rescale attribute so that its minimum is 0 (or −1) and its maximum is 1.
# • Standardization. Rescale attribute so that its mean is 0 and its standard deviation is 1.
#
# Attributes can be redundant, e.g., Petal Length and Petal Width.
# Consider Mahalanobis dis- tance (Duda/Hart/Stork).
#
# Other Distance Issues
# Attributes can be irrelevant. The textbook hints at sophisticated ways to address this issue, but consider multiplying an attribute times its cor- relation with the outcome (after scaling).
# Nominal attributes are either equal or different. Consider being different as a difference of 1, or convert to binary attributes.
# Attribute values can be missing. Consider using some fixed value for the difference.
#
# For basic kNN, no training is needed, but might
# be desired for scaling or selecting training exs.
# An open problem is more efficient algorithms to find NN.
# Roughly, case-based and analogical learning are based on closeness of symbolic descriptions.
# What is the inductive bias of kNN? Does kNN have an overfitting problem? Will increasing k always improve performance?

#===============================================================================

	#  Don't want to do anything with this at the moment, so cutting it out.
	#  BTL - 2013.05.06.
if (FALSE)
{
library (knnflex)
num.rows = 256
num.cols = 256
num.entries = num.rows * num.cols

idx.to.xy.table = matrix (0, nrow=num.entries, ncol=2)

curIdx = 0
for (curRow in 1:num.rows)
  {
  for (curCol in 1:num.cols)
    {
    curIdx = curIdx + 1
    idx.to.xy.table [curIdx,1:2] = c(curRow,curCol)
    }
  }

dist.between.all.xy.locs = knn.dist (idx.to.xy.table)
}

#===============================================================================


