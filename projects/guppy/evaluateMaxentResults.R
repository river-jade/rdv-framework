#=========================================================================================

#                               evaluateMaxentResults.R

# source( 'evaluateMaxentResults.R' )

#=========================================================================================

#  History:

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#=========================================================================================

evaluateMaxentResults = function ()
	{

cat ("\n\n>>>>>>>>>>>>>  STARTING evaluateMaxentResults.R\n\n")

for (spp.id in 1:variables$PAR.num.spp.to.create)
	{
	spp.name <- paste ('spp.', spp.id, sep='')

	#===========================================================================

		#---------------------------------------------------------------------
		#  When you use the replicates option in maxent (e.g., bootstrapping
		#  or cross-validation), it changes its naming convention.
		#  Instead of spp.1.asc, you get spp.1_0.asc, spp.1_1.asc, etc.
		#  I'm just going to arbitrarily copy the first replicate into a
		#  spp.?.asc file so that all of the naming conventions from before
		#  still hold up.
		#  I don't think that it matters which replicate you choose and I
		#  don't think that using a single more "representative" one like the
		#  median of the replicates will necessarily preserve the spatial
		#  errors.
		#---------------------------------------------------------------------

	if (variables$PAR.do.maxent.replicates)
		{
		#  maxentFirstReplicateFilename = paste ("MaxentOutputs/", spp.name, "_0.asc", sep='')
		#  maxentNoReplicateFilename = paste ("MaxentOutputs/", spp.name, ".asc", sep='')

		maxentFirstReplicateFilename =
				paste (maxent.output.dir, '/', spp.name, "_0.asc", sep='')
		maxentNoReplicateFilename =
				paste (maxent.output.dir, '/', spp.name, ".asc", sep='')

#  NOTE:  Could use the stopifnot() function for things like this...

		if (! file.copy (maxentFirstReplicateFilename,
					   	 maxentNoReplicateFilename,
					   	 overwrite = TRUE ))
			{
			cat ('\nCould not copy ', maxentFirstReplicateFilename, ' to ',
				 maxentNoReplicateFilename);
			stop ('\nAborted due to error.', call. = FALSE);
			}
	  	}

	#===========================================================================

		#-------------------------------------------------------------------
		#  Get maxent's resulting probability distribution.
		#  Then, subtract it from the true distribution to see the spatial
		#  pattern of error.
		#-------------------------------------------------------------------

		#  Load the maxent output distribution into a matrix.
	maxent.rel.prob.dist =
			read.asc.file.to.matrix (
									spp.name,
##									paste (spp.name, ".asc", sep=''),
									maxent.output.dir.with.slash)

		#  Normalize the matrix to allow comparison with true distribution.
	tot.maxent.rel.prob.dist = sum (maxent.rel.prob.dist)
	maxent.norm.prob.dist = maxent.rel.prob.dist/tot.maxent.rel.prob.dist

		#  Make sure it's a prob dist, i.e., sums to 1
	cat ("\n\n sum (maxent.norm.prob.dist) = '", sum (maxent.norm.prob.dist),
		"'.  Should == 1.\n\n")

################################################################################
#####  2013 04 25 - BTL
#####  THIS IS A TOTAL HACK THAT NEEDS TO BE CLEANED UP.
#####  NORM.PROB.MATRIX WAS SUPPOSED TO ALREADY HAVE BEEN NORMALIZED BEFORE
#####  IT WAS WRITTEN TO A FILE, BUT IT ISN'T, SO I'M NORMALIZING IT HERE.
#####  THIS WASN'T NECESSARY WHEN I WAS CREATING PROBABILITY DISTRIBUTIONS
#####  USING ARITHMETIC SINCE IT WAS DONE CORRECTLY THEN.
#####  NOW, I'M USING MAXENT OUTPUT FILES AS THE TRUE PROB DIST AND THEY
#####  DON'T SEEM TO BE NORMALIZED.

	norm.prob.matrix =
			read.asc.file.to.matrix (paste (prob.dist.layers.dir.with.slash,
									variables$PAR.trueProbDistFilePrefix,
									".", spp.name,
##									'.asc',
									sep=''))

#####  start of hack
			tot.norm.prob.matrix = sum (norm.prob.matrix)
			norm.prob.matrix = norm.prob.matrix / tot.norm.prob.matrix
#####  end of hack

	cat ("\n\n sum (norm.prob.matrix) = '", sum (norm.prob.matrix),
		"'.  Should also == 1.\n\n")
################################################################################

		#  Compute the difference between the correct and maxent probabilities
		#  and save it to a file for display.

	err.between.maxent.and.true.prob.dists =
			maxent.norm.prob.dist - norm.prob.matrix

	num.img.rows <- dim (err.between.maxent.and.true.prob.dists) [1]
	num.img.cols <- dim (err.between.maxent.and.true.prob.dists) [2]

#cat ("\n\n=============================\n")
#cat ("\nvariables$PAR.show.raw.error.in.dist = '",
#	variables$PAR.show.raw.error.in.dist, "'", sep='')
#cat ("\n\n=============================\n")

	if (variables$PAR.show.raw.error.in.dist)
		{
#cat ("\n\n=============  Inside the if statement  ================\n")

			  #  NECESSARY TO WRITE THESE ASC AND PGM FILES OUT?
			  #  DOESN'T SEEM LIKE THEY'RE USED FOR ANYTHING.
		write.asc.file (err.between.maxent.and.true.prob.dists,
						paste (analysis.dir.with.slash, "raw.error.in.dist.", spp.name, sep=''),
						num.img.rows, num.img.cols
						, xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
						, yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
											  #  is not actually on the map.  It's just off the lower
											  #  left corner.
						, no.data.value = -9999
						, cellsize = 1
						)
		write.pgm.file (err.between.maxent.and.true.prob.dists,
						paste (analysis.dir.with.slash, "raw.error.in.dist.", spp.name, sep=''),
						num.img.rows, num.img.cols)
		}
#stop()

	#===========================================================================

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

	err.magnitudes <- abs (err.between.maxent.and.true.prob.dists)
	if (variables$PAR.show.abs.error.in.dist)
		{
		write.asc.file (err.magnitudes,
						paste (analysis.dir.with.slash, "abs.error.in.dist.", spp.name, sep=''),
						num.img.rows, num.img.cols
						, xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
						, yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
											  #  is not actually on the map.  It's just off the lower
											  #  left corner.
						, no.data.value = -9999
						, cellsize = 1
						)

		write.pgm.file (err.magnitudes,
						paste (analysis.dir.with.slash, "abs.error.in.dist.", spp.name, sep=''),
						num.img.rows, num.img.cols)
		}

	tot.err.magnitude <- sum (err.magnitudes)
	max.err.magnitude <- max (err.magnitudes)

	####  PROBLEM: norm.prob.matrix not defined?  maxent.norm.prob.dist not defined?
	####  Actually, norm.prob.matrix IS defined.  Not sure why this comment is here.
	####  May be vestigial. Will leave it though until I clean everything up and
	####  make sure it's ok to delete it.
	####  BTL - 2011.09.22

	npm.vec <- as.vector (norm.prob.matrix)
	mnpd.vec <- as.vector (maxent.norm.prob.dist)

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

## 	cur.idx = 0
## 	zemCt = 0
## 	znpmCt = 0
## 	infCt = 0
## 	infLocs = NULL
## 	for (row in 1:num.img.rows)
## 		for (col in 1:num.img.cols)
## 			{
## 			cur.idx = cur.idx + 1
## 			if (err.magnitudes[row,col] == 0)
## 				zemCt = zemCt + 1
## 			if (norm.prob.matrix[row,col] == 0)
## 				znpmCt = znpmCt + 1
## #				cat ("\ne.m [", row, ",", col, "] = 0 at idx = ", cur.idx, sep='')
## 			if (is.infinite (err.magnitudes[row,col] / norm.prob.matrix[row,col]))
## 				{
## 				infCt = infCt + 1
## 				infLocs = c(infLocs,cur.idx)
## 			}
## 	cat ("\n\nvvvvvvvvvvvvvvvvvvvvv")
## 	cat ("\nerr.magnitudes = 0 for ", zemCt, " entries.", sep='')
## 	cat ("\nnorm.prob.matrix = 0 for ", znpmCt, " entries.", sep='')
## 	cat ("\ninfCt = ", infCt, sep='')
## 	cat ("\ninfLocs = ", infLocs, sep='')
## 	cat ("\n\n^^^^^^^^^^^^^^^^^^^^^")

epsilon = 1e-09

#norm.prob.matrix.epsilon = norm.prob.matrix
#norm.prob.matrix.epsilon [norm.prob.matrix == 0] = epsilon
#	percent.err.magnitudes <- (err.magnitudes / norm.prob.matrix.epsilon) * 100

	#  Create percent err magnitudes matrix.
	#  Could zero or NA it to start but all will be overwritten, so
	#  I'll just copy the err.magnitudes array as a quick initialization
	#  that matches whatever byrow conventions are used there.
percent.err.magnitudes = err.magnitudes

#cat ("\n\nComputing percent.err.magnitudes\n")
for (curIdx in 1:length(err.magnitudes))
	{
		#  %% indicates x mod y and
		#  %/% indicates integer division

#	if ((curIdx %% 50) == 0)  cat("\n")

	retVal = NA
	curErrMag = err.magnitudes [curIdx]
	corVal = norm.prob.matrix [curIdx]
	if (curErrMag == 0)
		{
		retVal = 0
#		cat ("0")
		} else if (corVal == 0)
		{
		retVal = 100 * curErrMag / epsilon
#		cat ("1")
		} else
		{
		retVal = 100 * curErrMag / corVal
#		cat ("3")
		}
	percent.err.magnitudes [curIdx] = retVal
	}
#cat ("\n\nDone computing percent.err.magnitudes\n")

## percent.err.magnitudes [(err.magnitudes == 0)] = 0
## minAndMax = range(x[(!is.infinite(x) & !is.nan(x))])
## minVal = minAndMax[1]
## maxVal = minAndMax[2]
## x[is.infinite(x) & (x < 0)] = minVal
## x[is.infinite(x) & (x > 0)] = maxVal
## x[is.nan(x)] = mean(x)

cat ("\n\nrange (norm.prob.matrix) = ", range (norm.prob.matrix))
cat ("\n\nrange (err.magnitudes) = ", range (err.magnitudes))
cat ("\n\nrange (percent.err.magnitudes) = ", range (percent.err.magnitudes))
cat ("\n\n")

		png (paste (analysis.dir.with.slash, "hist.percent.error.in.dist.", spp.name, ".png", sep='')
			)
#	hist (percent.err.magnitudes [percent.err.magnitudes <= 100])
	hist (percent.err.magnitudes)
		dev.off()

	if (variables$PAR.show.percent.error.in.dist)
		{

#####  PROBABLY NEED TO REWRITE THE WRITE.PGM.FILE() FUNCTION OR CREATE A
#####  DIFFERENT/OPTIONAL VERSION OF IT TO HANDLE FILES WHERE THERE ARE A
#####  A SMALL NUMBER OF VERY EXTREME VALUES THAT MESS UP THE LINEAR
#####  SCALING USED NOW.  FOR EXAMPLE, I THINK THAT IF YOU HAVE JUST ONE VALUE
#####  THAT'S MUCH LARGER THAN ALL THE OTHERS (E.G., NOISE), THEN IT WILL
#####  CURRENTLY SCALE EVERYTHING TO MAKE THAT PIXEL WHITE BUT ALL OTHER
#####  PIXELS WILL BE SMASHED DOWN INTO THE LOWEST PIXEL COLOR, I.E., BLACK,
#####  MAKING AN ALL BLACK IMAGE.
#####  MIGHT BE BETTER TO RUN HIST() AND USE THE BOUNDS OF SOME QUANTILES
#####  AS THE BOUNDS OF ALL BUT THE BLACKEST AND WHITEST PIXELS.
#####  Note that this might apply to other things besides pgms, but they're
#####  plotted by built-in R functions.  Not sure about this...
#####  BTL - 2013.04.18.

		write.pgm.file (percent.err.magnitudes,
						paste (analysis.dir.with.slash, "percent.error.in.dist.", spp.name, sep=''),
						num.img.rows, num.img.cols)
		}

	abs.percent.err.magnitudes <- abs (percent.err.magnitudes)
	if (variables$PAR.show.abs.percent.error.in.dist)
		{
		write.pgm.file (abs.percent.err.magnitudes,
					paste (analysis.dir.with.slash, "abs.percent.error.in.dist.", spp.name, sep=''),
						num.img.rows, num.img.cols)
		}

		##    #  Reset the largest errors to one fairly large value so that
		##    #  you can reduce the dynamic range of the image and make it
		##    #  easier to differentiate among smaller values.

		truncated.err.img <- abs.percent.err.magnitudes
		truncated.err.img [abs.percent.err.magnitudes >= 50] <- 50

	if (variables$PAR.truncated.percent.err.img)
		{
		write.pgm.file (truncated.err.img,
						paste (analysis.dir.with.slash, "truncated.percent.err.img.", spp.name, sep=''),
						num.img.rows, num.img.cols)
		}

	if (variables$PAR.show.heatmap)
		{
				#-----------------------------------------------------------------------
				#  standard color schemes that I know of that you can use:
				#  heat.colors(n), topo.colors(n), terrain.colors(n), and cm.colors(n)
				#
				#  I took this code from an example I found on the web and it uses
				#  some options that I don't know anything about but it works.
				#  May want to refine it later.
				#-----------------------------------------------------------------------

		cat ("\n\nDrawing heatmap of err between maxent and true prob dists as PNG.\n")
		heatmap.output.filename =
				paste (analysis.dir.with.slash,
						"heatmap.err.between.maxent.and.true.prob.dists.",
						spp.name,
						sep='')

		png (paste (heatmap.output.filename, ".png", sep='')
		     #, width=600, height=589
			)
		heatmap (err.between.maxent.and.true.prob.dists,
					Rowv = NA, Colv = NA,
					col = heat.colors (256),
					###		 scale="column",     #  This can rescale colors within columns.
					margins = c (5,10)

				#  more options found on the web
          	#cexRow=0.5,
          	#labRow=row_names, labCol=col_names,
          	#ColSideColors = patient_colours,
          	#col = r.topo_colors(50))

					)
		dev.off()
		cat ("\nDone with PNG heatmap.\n")


		## 		cat ("\n\nDrawing heatmap of err between maxent and true prob dists as PDF.\n")
		## 		pdf (paste (heatmap.output.filename, ".pdf", sep='')
		## 		     #, width=600, height=589
		## 			)
		## 		heatmap (err.between.maxent.and.true.prob.dists,
		## 					Rowv = NA, Colv = NA,
		## 					col = topo.colors (256),
		## 					###		 scale="column",     #  This can rescale colors within columns.
		## 					margins = c (5,10)
		##
		## 				#  more options found on the web
		##           	#cexRow=0.5,
		##           	#labRow=row_names, labCol=col_names,
		##           	#ColSideColors = patient_colours,
		##           	#col = r.topo_colors(50))
		##
		## 					)
		## 		dev.off()
		## 		cat ("\nDone with PDF heatmap.\n")

		}

#===============================================================================

	####  NOTES

	##  This part works but I'm not sure if it's what we want to do...

	#### quantile (norm.prob.matrix, c(0.1,0.9))
	#### top.10 <- which(norm.prob.matrix >= quantile (norm.prob.matrix, 0.9))
	#### truncated.err <- percent.err.magnitudes
	#### truncated.err [percent.err.magnitudes >= quantile (percent.err.magnitudes, 0.95)] <- 50
	#### write.pgm.file (truncated.err,
	#### 				paste (analysis.dir.with.slash, "truncated.err.img", sep=''),
	####             	num.img.rows, num.img.cols)


	##  This part is a copy of the fooling around I did in R to get the stuff
	##  above to work...

	#### > x <- pixmap (as.vector(percent.err.magnitudes), nrow=1025)
	#### > plot(x)
	#### Error in t(x@index[nrow(x@index):1, , drop = FALSE]) :
	####   subscript out of bounds
	#### > x
	#### Pixmap image
	####   Type          : pixmap
	####   Size          : 1025x1025
	####   Resolution    : 1x1
	####   Bounding box  : 0 0 1025 1025
	####
	#### > img <- read.pnm ('./ResultsAnalysis/percent.error.in.dist.pgm')
	#### Read 1050625 items
	#### > plot(img)
	#### > truncated.err <- norm.prob.matrix
	#### > truncated.err [norm.prob.matrix >= quantile (norm.prob.matrix, 0.95)] <- 50
	#### >
	#### > truncated.err <- percent.err.magnitudes
	#### > truncated.err [percent.err.magnitudes >= quantile (percent.err.magnitudes, 0.95)] <- 50
	#### >
	#### > write.pgm.file (truncated.err,
	#### + 				paste (analysis.dir.with.slash, "truncated.err.img", sep=''),
	#### +             	num.img.rows, num.img.cols)
	####
	#### wrote ./ResultsAnalysis/truncated.err.img.pgm
	#### >
	#### > img <- read.pnm ('./ResultsAnalysis/truncated.err.img.pgm')
	#### Read 1050625 items
	#### > plot(img)
	#### >

	#===============================================================================

	#num.cols <- 1025
	#num.rows <- 1025
	num.rows <- dim (truncated.err.img)[1]
	num.cols <- dim (truncated.err.img)[2]

	par (mfrow=c(1,1))

	#img.matrix <- truncated.err.img
	#jpeg (paste (analysis.dir.with.slash, "test.jpg", sep=''))
	#draw.img (img.matrix)
	#points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")

		#  NOTE: There is one issue with comparing the outputs of filled.contour().
		#        It rescales to fit the data, so the same color scheme may give
		#        different colors to the same values on different maps.
		#        I think that you Can control the max and min values in the
		#        scaling though.  Need to look at some of the arguments that
		#        I commented out when I cloned the example from R help or the web.

	if (! PAR.use.old.maxent.output.for.input)
		{
		if (write.to.file)
			tiff (paste (analysis.dir.with.slash, "env.layer.1.tiff", sep=''))
		#    draw.img (env.layers [[1]])
		#    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
		#    plot.main.title <- "Env Layer 1"
		#    plot.key.title <- "Env\nMeasure1"
		#    map.colors <- cm.colors
		#    point.color <- "red"

		draw.filled.contour.img (env.layers [[1]],
								 "Env Layer 1", "Env\nMeasure1",
								 cm.colors, "red")
		if (write.to.file)  dev.off()
		}

	# write.to.file = TRUE
	# analysis.dir.with.slash = "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/ResultsAnalysis/"
	# test.img = matrix (1:256, nrow=256,ncol=256)
	#     if (write.to.file)  tiff (paste (analysis.dir.with.slash, "test.tiff", sep=''))
	#     draw.filled.contour.img (test.img,
	#                              "Test Image", "Env\nMeasure1",
	#                              cm.colors, "red")
	#     if (write.to.file)  dev.off()



	if (! PAR.use.old.maxent.output.for.input)
		{
		if (write.to.file)
			tiff (paste (analysis.dir.with.slash, "env.layer.2.tiff", sep=''))
		#    draw.img (env.layers [[2]])
		#    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
		draw.filled.contour.img (env.layers [[2]],
								 "Env Layer 2", "Env\nMeasure2",
								 cm.colors, "red")
		if (write.to.file)  dev.off()
		}

	if (write.to.file)
		tiff (paste (analysis.dir.with.slash, "true.prob.dist.", spp.name,".tiff",sep=''))
	#    draw.img (norm.prob.matrix)
	#    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
	draw.filled.contour.img (norm.prob.matrix,
							 "True Prob Distribution", "Prob",
							 terrain.colors, "red")
	if (write.to.file)  dev.off()

	if (write.to.file)  tiff (paste (analysis.dir.with.slash, "maxent.prob.dist.", spp.name,".tiff",sep=''))
	#    draw.img (maxent.norm.prob.dist)
	#    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
	draw.filled.contour.img (maxent.norm.prob.dist,
							 "Maxent Prob Distribution", "Prob",
							 terrain.colors, "red")
	if (write.to.file)  dev.off()


	if (write.to.file)  tiff (paste (analysis.dir.with.slash, "raw.error.map.", spp.name,".tiff", sep=''))
	#    plot.main.title <- "Raw error in Maxent Probability"
	#    plot.key.title <- "Error"
	#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
	contour.levels.to.draw <- c (20)
	draw.contours = TRUE
	draw.filled.contour.img (err.between.maxent.and.true.prob.dists,
							 "Raw error in Maxent Probability",
							 "Error",
							 heat.colors, "turquoise",
							 draw.contours,
							 contour.levels.to.draw
							 )
	if (write.to.file)  dev.off()
	#write.table (err.between.maxent.and.true.prob.dists,
	#             file = paste (analysis.dir.with.slash, "raw.error.map.", spp.name,".table", sep=''))
	# x = "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/ResultsAnalysis/raw.error.map.spp.2.table"

	if (write.to.file)
		tiff (paste (analysis.dir.with.slash, "abs.raw.error.map.", spp.name,".tiff", sep=''))
	#    plot.main.title <- "Abs value of raw error in Maxent Probability"
	#    plot.key.title <- "Error\nAbs Value"
	#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
	contour.levels.to.draw <- c (20)
	draw.contours = TRUE
	draw.filled.contour.img (err.magnitudes,
							 "Abs value of raw error in Maxent Probability",
							 "Error\n(Abs Value)",
							 heat.colors, "turquoise",
							 draw.contours,
							 contour.levels.to.draw
							 )
	if (write.to.file)  dev.off()
	if (write.to.file)  tiff (paste (analysis.dir.with.slash, "error.map.", spp.name,".tiff", sep=''))
	#    plot.main.title <- "Percent error in Maxent Probability"
	#    plot.key.title <- "Error\n(percent)"
	#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
	contour.levels.to.draw <- c (20)
	draw.contours = TRUE
	draw.filled.contour.img (truncated.err.img,
							 "Percent error in Maxent Probability",
							 "Error\n(percent)",
							 heat.colors, "turquoise",
							 draw.contours,
							 contour.levels.to.draw
							 )
	if (write.to.file)  dev.off()


	###########

	if (variables$PAR.do.maxent.replicates)
		{
		maxent.bootstrap.sd =
			read.asc.file.to.matrix (
									paste ("/", spp.name, "_stddev", sep=''),
##									paste ("/", spp.name, "_stddev", ".asc", sep=''),
									maxent.output.dir)

	#  Just realized this is probably not necessary because maxent
	#  writes a .png of the sd values in the plots directory.
		if (write.to.file)
			tiff (paste (maxent.output.dir, "maxent.bootstrap.sd.", spp.name,".tiff", sep=''))

	#    plot.main.title <- "Percent error in Maxent Probability"
	#    plot.key.title <- "Error\n(percent)"
	#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)

		contour.levels.to.draw <- c (20)
		draw.contours = TRUE
		draw.filled.contour.img (maxent.bootstrap.sd,
								 paste ("Maxent ", spp.name, ".bootstrap std dev", sep=''),
								 "StdDev",
								 terrain.colors, "red",
								 draw.contours,
								 contour.levels.to.draw
								 )
		if (write.to.file)  dev.off()
		}


		#  Not using this at the moment since I've gotten the filled.contour()
		#  code to behave pretty well.  May need this more stripped down stuff
		#  later though.  It also will draw contour lines on the image instead
		#  of just doing a graded image.  (However, I've just figured out how
		#  to draw contour lines on the filled.contour maps too, so maybe it
		#  doesn't matter.)

	if (use.draw.image)
		{
		par (mfrow=c(1,2))

		if (! PAR.use.old.maxent.output.for.input)
			{
			draw.img (env.layers [[1]])
			draw.img (env.layers [[2]])
			}

		draw.img (norm.prob.matrix)
		points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
		draw.img (maxent.norm.prob.dist)
		points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")

		draw.img (truncated.err.img)
		points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
		}

#===============================================================================

		#  This "weird function" is taken from the R help file for levelplot.
		#  It makes an interesting radially banded pattern that could be a useful
		#  synthetic test as a landscape pattern.
	## library(lattice)
	## x <- seq(pi/4, 5 * pi, length.out = 100)
	## y <- seq(pi/4, 5 * pi, length.out = 100)
	## r <- as.vector(sqrt(outer(x^2, y^2, "+")))
	## grid <- expand.grid(x=x, y=y)
	## grid$z <- cos(r^2) * exp(-r/(pi^3))
	## levelplot(z~x*y, grid, cuts = 50, scales=list(log="e"), xlab="",
	##            ylab="", main="Weird Function", sub="with log scales",
	##            colorkey = FALSE, region = TRUE)

		#  That help file also gives an example of labelled contours that
		#  could be useful too.
	## require(stats)
	## attach(environmental)
	## ozo.m <- loess((ozone^(1/3)) ~ wind * temperature * radiation,
	##        parametric = c("radiation", "wind"), span = 1, degree = 2)
	## w.marginal <- seq(min(wind), max(wind), length.out = 50)
	## t.marginal <- seq(min(temperature), max(temperature), length.out = 50)
	## r.marginal <- seq(min(radiation), max(radiation), length.out = 4)
	## wtr.marginal <- list(wind = w.marginal, temperature = t.marginal,
	##         radiation = r.marginal)
	## grid <- expand.grid(wtr.marginal)
	## grid[, "fit"] <- c(predict(ozo.m, grid))
	## contourplot(fit ~ wind * temperature | radiation, data = grid,
	##             cuts = 10, region = TRUE,
	##             xlab = "Wind Speed (mph)",
	##             ylab = "Temperature (F)",
	##             main = "Cube Root Ozone (cube root ppb)")
	## detach()



	}  #  end - for each species

	}  #  end function - evaluateMaxentResults

#=========================================================================================


