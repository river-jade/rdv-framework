#=========================================================================================

#                       buildEnvLayers.v2.R

# source( 'buildEnvLayers.R' )

#=========================================================================================

#  History:

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#=========================================================================================

	#--------------------------------------------------------------------------
	#  In the Austin code, the env layers are returned as matrices that
	#  are elements of a list, i.e., env.layers is a list with 2 elements,
	#  env layer 1 and env layer 2.  Each of these matrices was loaded
	#  directly from a pnm file (I think).
	#
	#  Here, instead of having them preloaded in a list, they have been
	#  copied from glass into a local directory as files (asc files?).
	#  Because I was not building the probability distribution, that was
	#  ok.  Maxent wanted them as files, not as matrices.
	#
	#  What I need to do now (thursday 3/28) is load the matrices from
	#  the files I've moved from glass.  At that point, I will be able
	#  to build the probability distribution and create the true presences
	#  and the sampled presences, like I did in Austin but have not done here
	#  yet.
	#--------------------------------------------------------------------------

    #-----------------------------------------------------------------------
    #  Get environment variables,
    #  then combine them using some made-up rule to get a True probability
    #  surface that maxent will try to recreate.
    #  (For example, we can use generated images from a pnm file as the
    #   environment layers.)
    #
    #  Then, sample from that surface to get the true occurrences of the
    #  species.  Once you have that set, then you can build a biased
    #  sampling method to look for these true occurrences and then feed
    #  the results of that sampling to maxent.
    #
    #  This biased sampling might also have errors in it, i.e., false
    #  positives.
    #-----------------------------------------------------------------------
	#
	#  The synthetic env data directory currently has 5 different files for
	#  each combination of H level and image ID, e.g., for H00_1:
	#		H00_1.256.asc
	#		H00_1.256.pgm
	#		H00_1.asc
	#		H00_1.pnm
	#		H00_1.tif
	#
    #-----------------------------------------------------------------------

#===============================================================================

    #------------------------------------------------------------
    #  Now choose the set of input environmental layers to use
    #
    #      - This is done by looking at all the input dirs
    #        in PAR.path.to.maxent.input.data that match the pattern
    #        PAR.maxent.env.layers.base.name
    #      - Then randomly selecting one of these
    #
    #------------------------------------------------------------

genEnvLayers <- function ()
	{
	useRemoteEnvDir = variables$PAR.useRemoteEnvDir
			cat ("\n\nvariables$PAR.useRemoteEnvDir = '", variables$PAR.useRemoteEnvDir, "'", sep='')
			cat ("\n\nuseRemoteEnvDir = '", useRemoteEnvDir, "'", sep='')

			cat ("\n\nvariables$PAR.remoteEnvDir = '", variables$PAR.remoteEnvDir, "'", sep='')
			cat ("\n\nvariables$PAR.localEnvDir = '", variables$PAR.localEnvDir, "'", sep='')

	#envLayersDir = "http://glass.eres.rmit.edu.au/tzar_input/guppy/AlexFractalData/H"
	envLayersDir = variables$PAR.remoteEnvDir

	if (!useRemoteEnvDir)
		{
		envLayersDir = variables$PAR.localEnvDir
		#envLayersDir = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H"
		}
			cat ("\n\nenvLayersDir = '", envLayersDir, "'", sep='')

	minH = 1
	maxH = 10
	minImgNum = 1
	maxImgNum = 100

	PAR.path.to.maxent.input.data = variables$'PAR.path.to.maxent.input.data'
			cat ("\n\nPAR.path.to.maxent.input.data = '", PAR.path.to.maxent.input.data, "'", sep='')

	num.env.layers = variables$PAR.numEnvLayers
			cat ("\n\nnum.env.layers = '", num.env.layers, "'", sep='')

	#env.layers = list()
	env.layers = vector (mode="list", length=num.env.layers)

	for (curEnvLayerIdx in 1:num.env.layers)
		{
			#  It's highly unlikely that you'll draw the same environmental layer twice, but
			#  you need to make sure that you don't end up with a name conflict or too few
			#  layers.
			#  Since it's ok biologically to have two env layers be highly correlated,
			#  (in the case of duplicate layers, they'd be perfectly correlated),
			#  I'll just create image names that have a unique ID prefixed to them and if
			#  the same layer is drawn twice it will just have a different prefix on it.
			#  I'll make the prefixes just be e01_, e02_, etc.
			#  This isn't a perfect solution, but since we're just drawing random images
			#  at this point, it really isn't important.  It just needs to not crash the
			#  program.

		idxString = (if (curEnvLayerIdx < 10)
						{ paste ('0', curEnvLayerIdx, sep='') } else
						{ as.character (curEnvLayerIdx) })

		eLayerFileNamePrefix = paste ("e", idxString, "_", sep='')

				cat ("\n\neLayerFileNamePrefix = '", eLayerFileNamePrefix, "'", sep='')

		#----------

			#  Choose an H level at random.
			#  H is the factor that controls the amount of spatial autocorrelation in
			#  Alex's fractal landscape images.
			#  Also need to convert the H value to a string to be used in file names.
			#  If the value is a single digit, then it needs a 0 in front of it to
			#  make file names line up in listings for easier reading.

		H = sample (minH:maxH, 1)
		Hstring = (if (H < 10) { paste ('0', H, sep='') } else { as.character (H) })

		#----------

		envSrcDir = paste (envLayersDir, Hstring, "/", sep='')
				cat ("\n\nenvSrcDir = '", envSrcDir, "'\n", sep='')

		#----------

		imgNum = sample (minImgNum:maxImgNum, 1)
		imgFileRoot = paste ("H", Hstring, "_", imgNum, sep='')

			#  May want to use the 256x256 images instead of the 1024x1024 images...
			#  http://glass.eres.rmit.edu.au/tzar_input/guppy/AlexFractalData/H01/H01_1.256.asc

		for (suffix in c(".tif", ".asc", ".pnm"))   #
			{
			imgFileName = paste (imgFileRoot, suffix, sep='')
			fullImgFileDestPath = paste (cur.full.maxent.env.layers.dir.name, "/",
										 eLayerFileNamePrefix, imgFileName, sep='')
					cat ("\n\nfullImgFileDestPath = '", fullImgFileDestPath,  "'", sep='')

			srcFile = paste (envSrcDir, imgFileName, sep='')
					cat ("\nsrcFile = '", srcFile, "'")

			if (useRemoteEnvDir)
				{
				err = try (download.file (srcFile, destfile = fullImgFileDestPath,
										  quiet = TRUE),
						   silent = TRUE)
				if (class (err) == "try-error")
					{
						#  you may be hitting the server too hard , so backoff and try again later.
					Sys.sleep (5)  #  in seconds , adjust as necessary
					try (download.file (srcFile,
										destfile = fullImgFileDestPath,
										quiet = TRUE),
						 silent = TRUE )
					}
				}  else
				{
					#  Copy file from local directory to fullImgFileDestPath

				file.copy (srcFile, fullImgFileDestPath)

				}  #  end else - using local env dir files

					cat ("\n\nsuffix = '", suffix, "'\n", sep='')
			if (suffix == ".pnm")
				{
						cat ("\n\nsuffix is .pnm so adding env.layer\n", sep='')
						cat ("\nlength (env.layers) before = '", length(env.layers), sep='')
				new.env.layer = get.img.matrix.from.pnm (fullImgFileDestPath)
						cat ("\ndim (new.env.layer) before = '", dim (new.env.layer), sep='')
						cat ("\n\nis.matrix(new.env.layer) in get.img.matrix.from.pnm = '", is.matrix(new.env.layer), "\n", sep='')
						cat ("\n\nis.vector(new.env.layer) in get.img.matrix.from.pnm = '", is.vector(new.env.layer), "\n", sep='')
						cat ("\n\nclass(new.env.layer) in get.img.matrix.from.pnm = '", class(new.env.layer), "\n", sep='')

				env.layers [[curEnvLayerIdx]]= new.env.layer

						cat ("\nlength (env.layers) AFTER = '", length(env.layers), sep='')
						cat ("\n\nnew.env.layer [1:3,1:3] = \n", new.env.layer [1:3,1:3], "\n", sep='')    #  Echo a bit of the result...
						for (row in 1:3)
							for (col in 1:3)
								{
								cat ("\nnew.env.layer [", row, ", ", col, "] = ", new.env.layer[row,col], ", and class = ", class(new.env.layer[row,col]), sep='')
								}
						#	print (new.env.layer [1:3,1:3])    #  Echo a bit of the result...

				}  #  end if - pnm file
			}  #  end for - suffixes
		}  #  end for - num.env.layers

			cat( '\n cur.full.maxent.env.layers.dir.name =', cur.full.maxent.env.layers.dir.name )

	return (env.layers)
	}

#===============================================================================
