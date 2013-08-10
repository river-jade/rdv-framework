#===============================================================================

						#  computeSppDistributions.v2.R

#===============================================================================

#  History:

#  2013.08.10 - BTL
#  IMPORTANT: See notes in comment near the call to runMaxentCmd() below.
#  There may be a bug in here that needs to be fixed if this code is used again.
#  Since I'm in the process of converting everything to python, that may
#  never happen though...

#  2013.04.14 - BTL -  v2
#  Inserting bits that write the matrix to a file that used to be in
#  computeTrueRelProbDist.R.  There, you're only normalizing
#  any matrix that you're handed, so it shouldn't be writing the matrix to
#  a file as the true probability distribution.

#  2013 04 13? - BTL - v1
#  Extracted from guppy.test.maxent.v9.R.

#===============================================================================

strOfCommaSepNumbersToVec = function (numberString)
	{
	numStrAsCatCmdStr = paste ("c(", numberString, ")", sep='')

	return (eval (parse (text = numStrAsCatCmdStr)))
	}

	#---------------------------------------------------------------
	#  Determine the number of true presences for each species.
	#  At the moment, you can specify the number of true presences
	#  drawn for each species either by specifying a count for each
	#  species to be created or by specifying the bounds of a
	#  random fraction for each species.  The number of true
	#  presences will then be that fraction multiplied times the
	#  total number of pixels in the map.
	#---------------------------------------------------------------

get.num.true.presences.for.each.spp = function ()
	{
	if (variables$PAR.use.random.num.true.presences)
		{
			#-------------------------------------------------------------
			#  Draw random true presence fractions and then convert them
			#  into counts.
			#-------------------------------------------------------------

		cat ("\n\nIn get.num.true.presences.for.each.spp, case: random true pres")
		spp.true.presence.fractions.of.landscape =
			runif (variables$PAR.num.spp.to.create,
				   min = variables$PAR.min.true.presence.fraction.of.landscape,
				   max = variables$PAR.max.true.presence.fraction.of.landscape)

				cat ("\n\nspp.true.presence.fractions.of.landscape = \n")
				print (spp.true.presence.fractions.of.landscape)

		spp.true.presence.cts = round (num.cells * spp.true.presence.fractions.of.landscape)
				cat ("\nspp.true.presence.cts = ")
				print (spp.true.presence.cts)

		num.true.presences = spp.true.presence.cts
				cat ("\nnum.true.presences = ", num.true.presences)

		} else  #  end if - random true presences
		{
			#--------------------------------------------------
			#  Use non-random, fixed counts of true presences
			#  specified in the yaml file.
			#--------------------------------------------------

#		num.true.presences = variables$PAR.num.true.presences
		num.true.presences =
			strOfCommaSepNumbersToVec (variables$PAR.num.true.presences)

				cat ("\n\nIn get.num.true.presences.for.each.spp, case: NON-random true pres")
				cat ("\n\nnum.true.presences = '",
				num.true.presences, "'", sep='')
				cat ("\nclass (num.true.presences) = '",
				class (num.true.presences), "'")
				cat ("\nis.vector (num.true.presences) = '",
				is.vector (num.true.presences), "'", sep='')
				cat ("\nis.list (num.true.presences) = '",
				is.list (num.true.presences), "'", sep='')
				cat ("\nlength (num.true.presences) = '",
				length (num.true.presences), "'", sep='')
				for (i in 1:length (num.true.presences))
					cat ("\n\tnum.true.presences [", i, "] = ",
							num.true.presences[i], sep='')

		if (length (num.true.presences) < PAR.num.spp.to.create)
			{
			cat ("\n\nlength(PAR.num.true.presences) = '",
					length(variables$PAR.num.true.presences),
					"' but \nPAR.num.spp.to.create = '", PAR.num.spp.to.create,
					"'.\nMust specify at least as many presence cts as ",
					"species to be created.\n\n", sep='')
			stop ()
			}
		}

	return (num.true.presences)
	}

#===============================================================================

	#-----------------------------------------------------------------------
	#  Compute the true relative probability distribution for each species.
	#  This is where the generated equation is built and invoked, e.g.,
	#  adding or multiplying the env layers together to create a
	#  probability of presence of the current species at each pixel.
	#  The distribution that is generated is a relative distribution
	#  in that it does not give the probability of finding the species at
	#  that pixel in general.  It just gives a distribution of the
	#  relative probability of finding the species at that pixel compared
	#  to any other pixel in the bounds of this map.  It is intended to
	#  be used for drawing any given number of occurrences from the map
	#  rather than the actual probability that there will be something
	#  at each pixel.  To get that value, you would need to do something
	#  like taking the relative probabilities and choosing a threshold
	#  value below which you say the habitat is not suitable.  You could
	#  then consider all locations above the threshold to have a presence
	#  (and thereby derive the number of occurrences (i.e., abundance))
	#  instead of specifying it ahead of time as is done when generating
	#  occurrences directly from the relative distribution.  I think that
	#  some of the maxent papers may also specify some way of turning the
	#  relative probabilities (essentially "suitabilities") into true
	#  probabilities, but I can't remember where at the moment.
	#-----------------------------------------------------------------------

get.true.rel.prob.dists.for.all.spp.ARITH = function (env.layers, num.env.layers)
	{
	cat ("\n\nStarting get.true.rel.prob.dists.for.all.spp().")

	true.rel.prob.dists.for.spp =
		vector (mode="list", length=variables$PAR.num.spp.to.create)

	for (spp.id in 1:variables$PAR.num.spp.to.create)
		{
		spp.name <- paste ('spp.', spp.id, sep='')

		norm.prob.matrix =
			computeRelProbDist.ARITH (spp.id, spp.name, env.layers, num.env.layers)

		true.rel.prob.dists.for.spp [[spp.id]] = norm.prob.matrix
				##	last = length (true.rel.prob.dists.for.spp) + 1
				##	true.rel.prob.dists.for.spp [[last]] = norm.prob.matrix

		#===========================================================================

			#--------------------------------------------------------------------------------
			#  Write the normalized distribution to a csv image so that it can
			#  be inspected later if you want.
			#  May want to write to something other than csv, but it's easy for
			#  the moment.
			#
			#  One small problem:
			#  Can't seem to get write.csv() to leave off the column headings,
			#  no matter what options I choose.  R even complains if I use the
			#  col.names=NA option as advertised in the help file.
			#
			#  On the web, I did find a write.matrix() function in MASS that
			#  doesn't add the column headings, but it's much slower than
			#  write.csv() so I won't use it at this point.
			#      library (MASS)
			#      write.matrix (norm.prob.matrix, file = true.prob.dist.filename, sep=',')
			#--------------------------------------------------------------------------------

		filename.root = paste (prob.dist.layers.dir, "/",
								variables$PAR.trueProbDistFilePrefix,
								".", spp.name, sep='')
		num.img.rows = dim (norm.prob.matrix)[1]
		num.img.cols = dim (norm.prob.matrix)[2]

		true.prob.dist.csv.filename <- paste (filename.root, ".csv", sep='')
				cat ("\nWriting norm.tot.prod.matrix to ", true.prob.dist.csv.filename, "\n", sep='')
		write.csv (norm.prob.matrix, file = true.prob.dist.csv.filename, row.names = FALSE)

				cat ("\nWriting norm.tot.prod.matrix to ", filename.root, ".asc", "\n", sep='')

			#  NOTE:
			# Both the maxent env input layers (e.g., H05_1.asc) and the maxent
			# output layers have the following header when the image is 256x256:

			# ncols         256
			# nrows         256
			# xllcorner     1
			# yllcorner     1
			# cellsize      1
			# NODATA_value  -9999

			# Running write.asc() with the defaults gives the following header,
			# which Zonation chokes on (I think that it thinks all values are 0):

			# ncols         256
			# nrows         256
			# xllcorner     0
			# yllcorner     0
			# cellsize      1
			# NODATA_value  0

			# So, need to run write.asc() specifying all options to match the
			# maxent input headers.

		#  write.asc.file (norm.prob.matrix, filename.root, num.img.rows, num.img.cols);
		write.asc.file (norm.prob.matrix, filename.root,
						  num.img.rows, num.img.cols
						  , xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
						  , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
											 #  is not actually on the map.  It's just off the lower
											 #  left corner.
						  , no.data.value = -9999
						  , cellsize = 1
						 )

				cat ("\nWriting norm.tot.prod.matrix to ", filename.root, ".pgm", "\n", sep='')
		write.pgm.file (norm.prob.matrix, filename.root, num.img.rows, num.img.cols);

		#--------------------------------------------------------------------------------

			#-----------------------------------------------------------------
			#  Show a heatmap representation of the probability distribution
			#  if desired.
			#-----------------------------------------------------------------

		#show.heatmap <- FALSE
		#if (show.heatmap)

		if (FALSE)
			{
				#-----------------------------------------------------------------------
				#  standard color schemes that I know of that you can use:
				#  heat.colors(n), topo.colors(n), terrain.colors(n), and cm.colors(n)
				#
				#  I took this code from an example I found on the web and it uses
				#  some options that I don't know anything about but it works.
				#  May want to refine it later.
				#-----------------------------------------------------------------------

			png (paste (heatmap.output.filename, ".png", sep='')
				 #, width=600, height=589
				)

			heatmap (norm.prob.matrix,
					Rowv = NA, Colv = NA,
					col = heat.colors (256),
					###		 scale="column",     #  This can rescale colors within columns.
					margins = c (5,10)
					)
			dev.off()

			}  #  end if - show heatmap

		}  #  end for - all species

#	return (true.rel.prob.dists.for.spp)
	}

#===============================================================================

get.true.rel.prob.dists.for.all.spp.MAXENT = function (env.layers, num.env.layers)
	{

	cat ("\n\nGenerate true rel prob map using maxent.\n\n")

	if (FALSE)
		{
		#!!!!!!!!!!!!!!!!!!!!!!!
		#  TEMPORARILY STILL HAVE TO DO THIS UNTIL I GET THE MAXENT GENERATOR WORKING.
		#  AT THAT POINT, DELETE THIS LINE.
			true.rel.prob.dists.for.spp =
				get.true.rel.prob.dists.for.all.spp (env.layers, num.env.layers)
		#!!!!!!!!!!!!!!!!!!!!!!!
		}

		combinedSppPresTable = genCombinedSppPresTable (num.rows, num.cells)

		cat ("\n\ncombinedSppPresTable = \n\n")
		print (combinedSppPresTable)

		combinedSppPresencesFilename =
							paste (cur.full.maxent.samples.dir.name, "/",
								   "maxentGenSppPresCombined", ".csv", sep='')
		write.csv (combinedSppPresTable,
				   file = combinedSppPresencesFilename,
				   row.names = FALSE,
				   quote=FALSE)


		#  Now have to make whatever changes and initializations are necessary to
		#  call maxent and have it generate new layers in the proper subdirectory
		#  and not do any bootstrapping.

		#  OUTPUTS FROM THIS GENERATOR NEED TO GO INTO THE MaxentProbDistLayers
		#  directory, just like the outputs of the arithmetic generator.
		#  Need to see where it builds its directory name and writes to it.

		#  Also, when maxent is finished generating these layers, there will probably
		#  be tons of crap left in there by maxent that needs to be deleted.
		#  This suggests it might be better to just make a scratch area for maxent
		#  to dump into and then just copy the species distribution files I need
		#  out of there and into the MaxentProbDistLayers directory.
		#  Call it MaxentProbDistGenOutputs.

		#----------------------------------------------------------------
		#  Run maxent to generate a true relative probability map.
		#----------------------------------------------------------------

	maxentSamplesFileName = combinedSppPresencesFilename
	maxentOutputDir = maxent.gen.output.dir
	bootstrapMaxent = FALSE

#----------------------------------------------------------------
#----------------------------------------------------------------
#  2013 08 10 - BTL
#  runMaxentCmd() had some arguments beyond the 3 that it has here added to it
#  in mid-May 2013 in runMaxentCmd.R according to svn.
#  Those arguments were also added to the call of runMaxentCmd() in
#  runMaxent.R around the same time, but nothing seems to have happened here.
#  What's puzzling is that this seems to have continued to run after that
#  even though it shouldn't have...
#  In any case, if I come back to using this R code, I need to change the call
#  here to match the other two files mentione above.
#  I can't find any run logs in May or June after about the 11th of May, so
#  maybe I started making all these changes and never got around to testing
#  them in R before moving on to python...
#----------------------------------------------------------------
system.exit ("\n\n*****  Quitting due to probable bug in calling maxent in computeSppDistributions.R.  Fix it!  *****\n\n")
#----------------------------------------------------------------

	runMaxentCmd (maxentSamplesFileName, maxentOutputDir, bootstrapMaxent)

	#  NOW NEED TO CONVERT THE MAXENT OUTPUTS IN MaxentGenOutputs/plots/spp.?.asc
	#  into pgm and tiff?  Regardless, need to copy the .asc files into the
	#  MaxentProbDistLayers area as:
	#		true.prob.dist.spp.?.asc
	#  Then, possibly need to create these as well, just for diagnosis I think.
	#  I believe that maxent will run as soon as I get the asc files in there.
	#		true.prob.dist.spp.?.pgm
	#		true.prob.dist.spp.?.csv   ARE THESE CSV FILES REALLY NECESSARY?
	#									SEEMS LIKE I NEVER LOOK AT THEM...

	#  As soon as these files are moved and renamed, then I should be able to
	#  remove the stop() command below and the temporary call to get.true...()
	#  at the start of this else branch (surrounded by exclamation points)
	#  and the whole thing should run to completion.

	#  Once that works, then the only major thing left to do is to create
	#  smaller versions of all the files on the fly so that I can do more runs
	#  and use some parts Alex's big images as cross-validation and testing fodder.

	#maxent.gen.output.dir = "../MaxentGenOutputs"
	#prob.dist.layers.dir = "../MaxentProbDistLayers/"

	#fileRootNames = file_path_sans_ext (list.files ('.','*.asc'))

	filesToCopyFrom = list.files (maxent.gen.output.dir,"*.asc",full.names=TRUE)
	#filesToCopyFrom = filesToCopyFrom[[1]]
	cat ("\n\nfilesToCopyFrom =\n")
	print (filesToCopyFrom)
	cat ("\n\n")

	prefix = paste (variables$PAR.trueProbDistFilePrefix, ".", sep='')
	cat ("\n\nprefix = ", prefix, sep='')

	fileRootNames = list.files (maxent.gen.output.dir, '*.asc')
	cat ("\n\nfileRootNames =\n", fileRootNames)


	#"/Users/Bill/tzar/outputdata/Guppy/default_runset/200_Scen_1.inprogress/MaxentGenOutputs/spp.1.asc"
	#"/Users/Bill/tzar/outputdata/Guppy/default_runset/200_Scen_1.inprogress/MaxentGenOutputs/spp.1.asc"

	filesToCopyTo = paste (prob.dist.layers.dir.with.slash, prefix, fileRootNames, sep='')
	#filesToCopyTo = prob.dist.layers.dir.with.slash
	cat ("\n\nfilesToCopyTo =\n")
	print (filesToCopyTo)
	cat ("\n\n")

	#retVals = file.copy(fileRootNames, filesToCopyTo)
	retVals = file.copy(filesToCopyFrom, filesToCopyTo)

	cat ("\n\nretVals for file.copy =\n", retVals)
	if (length (which (!retVals))) { cat ("\n\nCopy failed.\n\n");	stop() }

	cat ("\n\nDone copying files...\n\n")

## 		} else  #  No option chosen
## 		{
## 		cat ("\n\nNo option chosen for how to generate true rel prob map.\n\n")
## 		stop()
## 		}



#	return (true.rel.prob.dists.for.spp)
	}

#===============================================================================

