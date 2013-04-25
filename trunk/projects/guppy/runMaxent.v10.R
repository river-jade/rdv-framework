#=========================================================================================

#                                 runMaxent.v10.R

# source( 'runMaxent.R' )

#=========================================================================================

#  History:

#  2013 04 13 - BTL
#  This is effectively the same as what would be called guppy.test.maxent.v10.R
#  if I kept changing the guppy.text.maxent.v??.R sequence of files.
#  I've basically taken the version of runMaxent.R that Ascelin had developed
#  as a simple example of running maxent from tzar and moved many bits of code
#  from guppy.text.maxent.v9.R, plus a few small bits from
#  guppy.text.maxent.v5.R and some functions from guppy.maxent.functions.v9.R.
#  So far, there is nothing about Zonation in here, i.e., the entire second
#  half of guppy.text.maxent.v9.R.
#  I'm now going to break this file up and reorganize it so that pieces of it
#  are reusable for generating just environment layers or just running maxent,
#  etc.

#=========================================================================================

#  To run this code locally using tzar (by calling the R code from model.py):

#      cd /Users/bill/D/rdv-framework

#          All of this goes on one line; I've written two ways, all on one and then
#          again, broken broken into separate lines for clarity.
#          One thing that I don't understand though, why is --rscript=run.maxent.R
#          inside the commandlineflags argument instead of on its own like all the
#          other -- flags.
#  java -jar tzar.jar execlocalruns --runnerclass=au.edu.rmit.tzar.runners.RRunner --projectspec=projects/guppy/projectparams.yaml --localcodepath=. --commandlineflags="-p guppy --rscript=runMaxent.R"
#  java -jar tzar.jar execlocalruns
#      --runnerclass=au.edu.rmit.tzar.runners.RRunner
#      --projectspec=projects/guppy/projectparams.yaml
#      --localcodepath=.
#      --commandlineflags="-p guppy --rscript=runMaxent.R"

#    The only yaml file variables that seem to be referenced in the code here.
# PAR.current.run.directory = outputFiles$'PAR.current.run.directory'
# PAR.path.to.maxent = variables$'PAR.path.to.maxent'
# PAR.input.directory = inputFiles$'PAR.input.directory'
# PAR.maxent.env.layers.base.name = variables$'PAR.maxent.env.layers.base.name'
# PAR.path.to.maxent.input.data = variables$'PAR.path.to.maxent.input.data'

#=========================================================================================

source ('/Users/Bill/D/rdv-framework/projects/guppy/w.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/read.R')

#===============================================================================

draw.img <- function (img.matrix)
    {

        #  heat.colors give red as low to yellow (and white?) as high values
        #  topo.colors give blue to green to yellow to tan
        #  terrain.colors give green to yellow to tan to grey
        #  cm.colors give darker blue, lighter blue, white, light purple, dark purple
    image (1:num.cols, 1:num.rows, img.matrix,
           col = terrain.colors (100),
           asp = 1,
           mai = c(0,0,0,0),    #  trying to get rid of margin, but doesn't work?
           axes = FALSE,
           ann = FALSE
           )

    contour (1:num.cols, 1:num.rows, img.matrix, levels = c (20), add=TRUE)
    }

#===============================================================================

draw.filled.contour.img <- function (img.matrix,
                                     plot.main.title,
                                     plot.key.title,
                                     map.colors,
                                     point.color,
                                     draw.contours = FALSE,
                                     contour.levels.to.draw = NULL,
                                     show.sample.points = FALSE
                                    )
    {
    require(grDevices) # for colours

        #  When you leave out the x and y before the img.matrix in this
        #  call, you get something wrong (that I can't remember at the moment),
        #  so the next call down includes the x and y sequences.
    #filled.contour (img.matrix, color = heat.colors, asp = 1)

        #  More complex version with annotations.
        #  Note:  When I called points() after this, the scale was wrong
        #         somehow and some of the points ended up in the legend area.
        #         Not sure whether that's fixable or not.
        #  Have now found a note in the filled.contour help page that explains
        #  about adding points, etc.:
        #
        #      Note
        #
        #      This function currently uses the layout function and so is
        #      restricted to a full page display.
        #      As an alternative consider the levelplot and contourplot
        #      functions from the lattice package which work in multipanel
        #      displays.
        #
        #      The output produced by filled.contour is actually a combination
        #      of two plots; one is the filled contour and one is the legend.
        #      Two separate coordinate systems are set up for these two plots,
        #      but they are only used internally - once the function has
        #      returned these coordinate systems are lost.
        #      If you want to annotate the main contour plot, for example to
        #      add points, you can specify graphics commands in the plot.axes
        #      argument. An example is given below.
        #
        #          # Annotating a filled contour plot
        #      a <- expand.grid(1:20, 1:20)
        #      b <- matrix(a[,1] + a[,2], 20)
        #      filled.contour(x = 1:20, y = 1:20, z = b,
        #                     plot.axes={
        #                                axis(1); axis(2);
        #                                points(10,10)
        #                               })

    num.rows <- dim(img.matrix)[1]
    num.cols <- dim(img.matrix)[2]
    x <- 1:num.cols
    y <- 1:num.rows

    filled.contour (x, y, img.matrix,
                    color = map.colors,
                    plot.title = title (main = plot.main.title
#                    ,
#                    xlab = "Meters North", ylab = "Meters West"
                    ),
    #                plot.axes = { axis(1, seq(100, 800, by = 100)),
    #                              axis(2, seq(100, 600, by = 100)) },
                    plot.axes = {
                                 if (show.sample.points)
                                   {
                                   points (sampled.locs.x.y,
                                           pch = 19,
                                           bg = point.color,
                                           col = point.color);
                                   }
                                  if (draw.contours)
                                      contour (1:num.cols, 1:num.rows,
                                      img.matrix,
                                      levels = contour.levels.to.draw,
                                      add=TRUE)

                                },
                    key.title = title (main=plot.key.title),
                    asp = 1
    #                ,
    #                key.axes = axis(4, seq(90, 190, by = 10)))# maybe also asp=1
    #mtext(paste("filled.contour(.) from", R.version.string),
    #      side = 1, line = 4, adj = 1, cex = .66)
                    )
    }

#=========================================================================================

	#---------------------------------------------------------------------
    #  Temporary fixes to things that were set in guppy.test.maxent.v9.R
    #  but don't seem to appear anywhere here.
    #  BTL - 2013 04 04
	#---------------------------------------------------------------------

random.seed <- variables$PAR.random.seed
cat ("\n\nrandom.seed = '", random.seed, "'\n\n")
set.seed (random.seed)

	#---------------------------------------------------
	#  default value for number of processors in the
    #  current machine.
    #  maxent can use this value to speed up some
    #  of its operations by creating more threads.
    #  It's not a necessary thing to set for any other
    #  reason.
	#---------------------------------------------------

PAR.num.processors = variables$PAR.num.processors

#=========================================================================================

	#---------------------------------------------------------------------------
    #  Echo all of the input parameters to make sure they all loaded correctly.
	#---------------------------------------------------------------------------

cat ("\n\n=========  START str() of the 3 lists  =========\n\n")
str(inputFiles)
str(outputFiles)
str(variables)
cat ("\n\n=========  END str() of the 3 lists  =========\n\n")

#=========================================================================================

	#---------------------------------------------------------------
	#  Initialize variables and create necessary directories, etc.
	#---------------------------------------------------------------

startingDir = getwd()
cat ("\n\nstartingDir = '", startingDir, "'", sep='')

#----------------------

pathToRfiles = variables$PAR.pathToRfiles
cat ("\n\npathToRfiles = '", pathToRfiles, "'", sep='')

#----------------------

PAR.rdv.directory = variables$PAR.rdv.directory
cat ("\n\nPAR.rdv.directory = '", PAR.rdv.directory, "'", sep='')

#----------------------

PAR.input.directory.from.yaml = inputFiles$'PAR.input.directory'
PAR.input.directory = paste (PAR.rdv.directory, '/',
                             substr (PAR.input.directory.from.yaml,
                                     3, nchar (PAR.input.directory.from.yaml)),
                             sep='')
cat ("\n\nPAR.input.directory = '", PAR.input.directory, "'", sep='')

#----------------------

PAR.current.run.directory = outputFiles$'PAR.current.run.directory'
cat ("\n\nPAR.current.run.directory = '", PAR.current.run.directory, "'", sep='')

#----------------------

#prob.dist.layers.dir = "./MaxentProbDistLayers/"    #7/17#  what we want maxent to generate, i.e., the true layers?
#PAR.prob.dist.layers.dir.name = "MaxentProbDistLayers"
##prob.dist.layers.dir = paste (PAR.current.run.directory, "/",
##                              PAR.prob.dist.layers.dir.name, "/", sep='')

prob.dist.layers.dir = outputFiles$PAR.prob.dist.layers.dir.name

cat ("\nprob.dist.layers.dir = '", prob.dist.layers.dir, "'", sep='')
if ( !file.exists (prob.dist.layers.dir))
  {
  dir.create (prob.dist.layers.dir)
  }

    #--------------------

#PAR.maxent.output.dir.name = "MaxentOutputs"

maxent.output.dir = outputFiles$PAR.maxent.output.dir.name
maxent.output.dir.with.slash = paste (maxent.output.dir, "/", sep='')

cat ("\nmaxent.output.dir = '", maxent.output.dir, "'", sep='')
if ( !file.exists (maxent.output.dir))
  {
  dir.create (maxent.output.dir)
  }

    #--------------------

#analysis.dir = "./ResultsAnalysis/"
#PAR.analysis.dir.name = "ResultsAnalysis"
analysis.dir.with.slash = paste (PAR.current.run.directory, #  "/",
                      	  variables$PAR.analysis.dir.name, "/", sep='')
cat ("\nanalysis.dir.with.slash = '", analysis.dir.with.slash, "'", sep='')
if ( !file.exists (analysis.dir.with.slash))
  {
  dir.create (analysis.dir.with.slash)
  }

#------------------------------------------------------------------------------

    #  Move to the output directory.
setwd( PAR.current.run.directory )  # this is the output directory

#---------------------

##if (!file.exists ("MaxentOutputs"))
##	{
##	dir.create ("MaxentOutputs")
##	}

cur.full.maxent.env.layers.dir.name =
	paste (PAR.current.run.directory, variables$PAR.maxent.env.layers.base.name, sep='')

cat ("\n\ncur.full.maxent.env.layers.dir.name = '",
     cur.full.maxent.env.layers.dir.name, "'", sep='')

if (!file.exists (cur.full.maxent.env.layers.dir.name))
	{
	dir.create (cur.full.maxent.env.layers.dir.name)
	}

#---------------------

##if (!file.exists ("MaxentSamples"))
##	{
##	dir.create ("MaxentSamples")
##	}

cur.full.maxent.samples.dir.name =
	paste (PAR.current.run.directory, variables$PAR.maxent.samples.base.name, sep='')

cat ("\n\ncur.full.maxent.samples.dir.name = '",
     cur.full.maxent.samples.dir.name, "'", sep='')

if (!file.exists (cur.full.maxent.samples.dir.name))
	{
	dir.create (cur.full.maxent.samples.dir.name)
	}

    #--------------------

#       write.to.file : TRUE,
        write.to.file = variables$PAR.write.to.file

#   	  use.draw.image : FALSE,
        use.draw.image = variables$PAR.use.draw.image

#   	  use.filled.contour : TRUE,
        use.filled.contour = variables$PAR.use.filled.contour

            #  BEWARE: if this is FALSE, the get.env.layers() routine in
            #          guppy.maxent.functions.v6.R does something vestigial
            #          that you may not expect (or want) at all !
            #          Need to fix that.
            #          BTL - 2011.09.20
            #  BTL - 2011.10.03 - Is this note even relevant anymore?
            #                     Looks like this variable isn't even used now.
#   	  use.pnm.env.layers : TRUE ,
        use.pnm.env.layers = variables$PAR.use.pnm.env.layers

#---------------------

par (mfrow=c(2,2))

#===============================================================================

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

buildEnvLayersSrc = paste (pathToRfiles, 'buildEnvLayers.R', sep='')
cat ("\n\nbuildEnvLayersSrc = '", buildEnvLayersSrc, "'", sep='')

source (buildEnvLayersSrc)

#===============================================================================
#===============================================================================
      #  End of global env layers setup.
      #  Now it gets species-specific by operating over the same set of
      #  env layers as the base world for each species.
#===============================================================================
#===============================================================================

computeTrueRelProbDistSrc = paste (pathToRfiles, 'computeTrueRelProbDist.R', sep='')
cat ("\n\ncomputeTrueRelProbDistSrc = '", computeTrueRelProbDistSrc, "'", sep='')

source (computeTrueRelProbDistSrc)		#  probably should move to function file

#===============================================================================

xy.rel.to.lower.left <- function (n, nrow)    #**** the key function ****#
	{
	n.minus.1 <- n - 1
	return ( c (1 + (n.minus.1 %/% nrow),
			    nrow - (n.minus.1 %% nrow)
			   )
		   )
	}

#===============================================================================

build.presence.sample =
    function (sample.presence.indices.into.true.presence.indices,
              true.presence.locs.x.y)
	{
		#-------------------------------------------------------------------
	    #  I'm doing this as a function so that the sampling method (and
	    #  any other errors in building the presence sample) can be hidden
	    #  from the calling program.
	    #  For the moment though, it's very simple.  It's just a straight
	    #  subsample of the original population with no errors.
		#-------------------------------------------------------------------

	sample.locs.x.y =
	    true.presence.locs.x.y [sample.presence.indices.into.true.presence.indices,]

#	sample.presences.dataframe <-
#		data.frame (cbind (species[1:num.samples.to.take], sample.locs.x.y))
#	names (sample.presences.dataframe) <- c('species', 'longitude', 'latitude')

#	return (sample.presences.dataframe)
	return (sample.locs.x.y)
	}

#===============================================================================

PAR.num.spp.to.create = variables$PAR.num.spp.to.create
PAR.num.spp.in.reserve.selection = variables$PAR.num.spp.in.reserve.selection
PAR.use.old.maxent.output.for.input = variables$PAR.use.old.maxent.output.for.input

#===============================================================================

	#---------------------------------------------------------------
	#  Determine the number of true presences for each species.
	#  At the moment, you can specify the number of true presences
	#  drawn for each species either by specifying a count for each
	#  species to be created or by specifying the bounds of a
	#  random fraction for each species.  The number of true
	#  presences will then be that fraction multiplied times the
	#  total number of pixels in the map.
	#---------------------------------------------------------------

if (variables$PAR.use.random.num.true.presences)
	{
		#  Draw random true presence fractions and then convert them
		#  into counts.
	spp.true.presence.fractions.of.landscape =
		runif (variables$PAR.num.spp.to.create,
			   min = PAR.min.true.presence.fraction.of.landscape,
			   max = PAR.max.true.presence.fraction.of.landscape)

	#spp.true.presence.fractions.of.landscape = c (50/num.cells, 100/num.cells)
	cat ("\n\nspp.true.presence.fractions.of.landscape = \n")
	print (spp.true.presence.fractions.of.landscape)

	spp.true.presence.cts = num.cells * spp.true.presence.fractions.of.landscape
	cat ("\nspp.true.presence.cts = ")
	print (spp.true.presence.cts)

	num.true.presences = spp.true.presence.cts
	cat ("\nnum.true.presences = ", num.true.presences)

	} else  #  Use fixed counts specified in the yaml file.
	{
	num.true.presences = variables$PAR.num.true.presences

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

#PAR.use.all.samples = TRUE
PAR.use.all.samples = FALSE

    #  This is just a hack for now.
    #  Need to figure out a better way to pass in arrays of numbers of
    #  true sample sizes and subsample sizes.
PAR.num.samples.to.take = num.true.presences
if (! PAR.use.all.samples)
    {
    PAR.num.samples.to.take = num.true.presences / 2
    }

#####stop ("\n\nCheck that num.true.presences loaded correctly.\n\n")

#===============================================================================

combined.spp.true.presences.table = NULL
combined.spp.sampled.presences.table = NULL

for (spp.id in 1:variables$PAR.num.spp.to.create)
	{
	#spp.id = 1      #  This needs to become the head of a for loop...
	#spp.id = 2
	spp.name <- paste ('spp.', spp.id, sep='')

	#===========================================================================

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

	norm.prob.matrix =
		computeRelProbDist (spp.id, spp.name, env.layers, num.env.layers)

	#===========================================================================

		#----------------------------------------------------------------
		#  Get dimensions from relative probability matrix to use later
		#  and to make sure everything went ok.
		#----------------------------------------------------------------

	#####stop ("\n\nCheck that copy worked correctly.\n\n")

	num.rows <- (dim (norm.prob.matrix)) [1]
	num.cols <- (dim (norm.prob.matrix)) [2]
	num.cells <- num.rows * num.cols

	cat ("\n\nnum.rows = ", num.rows)
	cat ("\nnum.cols = ", num.cols)
	cat ("\nnum.cells = ", num.cells)

	#===========================================================================

		#-------------------------------------------------------------
		#  Sample presences from the mapped probability distribution
		#  according to the true relative presence probabilities to
		#  get the TRUE PRESENCES.
		#-------------------------------------------------------------

	true.presence.indices <- sample (1:(num.rows * num.cols),
									num.true.presences [spp.id],
									replace = FALSE,
									prob = norm.prob.matrix)
	cat ("\ntrue.presence.indices = \n")
	print (true.presence.indices)

		#----------------------------------------------------------------
		#  Convert the sample from single index values to x,y locations
		#  relative to the lower left corner of the map.
		#----------------------------------------------------------------

	true.presence.locs.x.y =
		matrix (rep (0, (num.true.presences [spp.id] * 2)),
				nrow = num.true.presences [spp.id], ncol = 2, byrow = TRUE)

		#  Can probably replace this with an apply() call instead...
	for (cur.loc in 1:num.true.presences [spp.id])
		{
		true.presence.locs.x.y [cur.loc, ] =
			xy.rel.to.lower.left (true.presence.indices [cur.loc], num.rows)
		}

		#-----------------------------------------------------------------------
		#  Bind the species names to the presence locations to make a data frame
		#  that can be written out in one call rather than writing it out one
		#  line at a time.
		#  Unfortunately, this cbind call turns the numbers into quoted strings
		#  too.  There may be a way to fix that, but at the moment, I don't
		#  know how to do that so I'll strip all quotes in the write.csv call.
		#  That, in turn, may cause a problem for the species name if it has a
		#  space in it.  Not sure what maxent thinks of that form.
		#-----------------------------------------------------------------------

	species <- rep (spp.name, num.true.presences [spp.id])
	true.presences.table <-
		data.frame (cbind (species, true.presence.locs.x.y))
	names (true.presences.table) <- c('species', 'longitude', 'latitude')

		#--------------------------------------------------------------------
		  #  Write the true presences out to a .csv file to be fed to maxent.
		  #  This will represent the case of "perfect" information
		#  (for a given population size), i.e., it contains the true
		#  location of every member of the population at the time of the
		#  sampling.  For stationary species like plants, this will be
		  #  "more perfect" than for things that can move around.
		#--------------------------------------------------------------------


			#  2011.09.21 - BTL - Have changed the name sampled.presences.filename
			#                     to true.presences.filename here because that
			#                     seems like it was an error before but didn't
			#                     show up because it gets written over further
			#                     down in the file.  I may be wrong so I'm flagging
			#                     it for the moment with '###'.
	outfile.root <- paste (spp.name, ".truePres", sep='')
	###sampled.presences.filename <- paste (samples.dir, outfile.root, ".csv", sep='')
##	true.presences.filename <- paste (samples.dir, outfile.root, ".csv", sep='')
	true.presences.filename <- paste (cur.full.maxent.samples.dir.name, "/",
										outfile.root, ".csv", sep='')
	cat ("\n\ntrue.presences.filename = '", true.presences.filename, "'", sep='')

	write.csv (true.presences.table,
	###  	   file = sampled.presences.filename,
		   file = true.presences.filename,
			   row.names = FALSE,
			   quote=FALSE)

		#-----------------------------------------------------------------
		#  Append the true presences to a combined table of presences
		#  for all species.
		#-----------------------------------------------------------------

	combined.spp.true.presences.table <-
		rbind (combined.spp.true.presences.table, true.presences.table)

	#===============================================================================

		#---------------------------------------------------------------------
		#  Have now finished generating the true occurrences of the species.
		#  Ready to simulate the sampling of the species to generate a
		#  sampled occurrence layer to feed to maxent.
		#---------------------------------------------------------------------

	sampled.locs.x.y = NULL
	sample.presence.indices.into.true.presence.indices =
		1:(num.true.presences [spp.id])

	if (PAR.use.all.samples)
	  {
	  sampled.locs.x.y = true.presence.locs.x.y

	  } else
	  {
	  num.samples.to.take = min (num.true.presences, PAR.num.samples.to.take)
	  sample.presence.indices.into.true.presence.indices =
			sample (1:(num.true.presences [spp.id]),
					num.samples.to.take,
					replace=FALSE)  #  Should this be WITH rep instead?
	  sampled.locs.x.y <-
		  build.presence.sample (sample.presence.indices.into.true.presence.indices,
								 true.presence.locs.x.y)
	  }

	#  temporary comment to try to get rid of sample points on image - aug 25 2011
	# plot (true.presence.locs.x.y [,1], true.presence.locs.x.y [,2],
	# 	  xlim = c (0, num.cols), ylim = c(0, num.rows),
	# 	  asp = 1,
	# 	  main = paste ("True presences \nnum.true.presences = ",
	# 	  				num.true.presences, sep='')
	# 	  )
	#
	# plot (sampled.locs.x.y [,1], sampled.locs.x.y [,2],
	# 	  xlim = c (0, num.cols), ylim = c(0, num.rows),
	# 	  asp = 1,
	# 	  main = paste ("Sampled presences \nnum.samples = ",
	# 	  				num.samples.to.take, sep='')
	# 	  )

	sampled.presences.table <-
		data.frame (cbind (species [1:num.samples.to.take], sampled.locs.x.y))
	names (sampled.presences.table) <- c('species', 'longitude', 'latitude')

		#--------------------------------------------------------------
		#  Write the sampled presences out to a .csv file that can be
		#  fed to maxent.
		#--------------------------------------------------------------

	outfile.root <- paste (spp.name, ".sampledPres", sep='')
	sampled.presences.filename <- paste (cur.full.maxent.samples.dir.name, "/",
										 outfile.root, ".csv", sep='')
	write.csv (sampled.presences.table,
			   file = sampled.presences.filename,
			   row.names = FALSE,
			   quote=FALSE)

		#-----------------------------------------------------------------
		#  Append the sampled presences to a combined table of presences
		#  for all species.
		#-----------------------------------------------------------------

	combined.spp.sampled.presences.table <-
		rbind (combined.spp.sampled.presences.table, sampled.presences.table)

	#===============================================================================

##  NEW STARTING HERE - 2013 04 10


##  NEW ENDING HERE - 2013 04 10

	#===============================================================================

	}  #  end for - each species

#===============================================================================

	#--------------------------------------------------------------
	#  Write the combined presences out to .csv files that can be
	#  fed to maxent.
	#--------------------------------------------------------------

combined.true.presences.filename =
					paste (cur.full.maxent.samples.dir.name, "/",
						   "spp.truePres.combined", ".csv", sep='')
write.csv (combined.spp.true.presences.table,
		   file = combined.true.presences.filename,
		   row.names = FALSE,
		   quote=FALSE)

	#-----

combined.sampled.presences.filename =
					paste (cur.full.maxent.samples.dir.name, "/",
						   "spp.sampledPres.combined", ".csv", sep='')
write.csv (combined.spp.sampled.presences.table,
		   file = combined.sampled.presences.filename,
		   row.names = FALSE,
		   quote=FALSE)

#===============================================================================
#===============================================================================
	#  Ready to run maxent for current species now.
#===============================================================================
#===============================================================================

###    Example java calls from maxent help file

###java -mx512m -jar maxent.jar environmentallayers=layers samplesfile=samples\bradypus.csv outputdirectory=outputs togglelayertype=ecoreg redoifexists autorun
###java -mx512m -jar maxent.jar -e layers -s samples\bradypus.csv -o MaxentOutputs -t ecoreg -r -a
##
## cur.spp.name <- spp.name
## sample.path <- paste ("MaxentSamples/", cur.spp.name, ".sampledPres.csv", sep='')
## system (paste ("java -mx512m -jar maxent.jar -e MaxentEnvLayers -s ",
##             sample.path, " -o outputs -a", sep=''))
## ###system ('do1.bat')    #  the call to run zonation - makes it wait to return?
## browser()

#---------------------

#		Maxent can build species maps for just one species or you can give
#		it a combined list of species presences for different species
#		over the same environment and it will go through all of them.
#		That's what the spp.sampledPres.combined.csv file above is
#		talking about.  Have to decide whether to combine them all into
#		one file or run maxent one species at a time.
#		Probably makes more sense to combine them all into one file
#		since maxent is likely to run faster that way.

#  setting up for maxent requires the following:
#      - asc file for each species showing its true probability
#        distribution to use to build the samples file (it's not
#        used by maxent itself)
#      - an equation for each species (to build the true probability map
#        for each species)

#  maxent itself needs the following:
#      - csv file with the list of samples for each species
#      - asc file for each environment layer
#        these env layers are the same for every species in a particular
#        run and they are the ones that are drawn from alex's set

#---------------------

PAR.path.to.maxent = variables$'PAR.path.to.maxent'
cat ("\n\nPAR.path.to.maxent = '", PAR.path.to.maxent, "'", sep='')

maxent.full.path.name <- paste (PAR.path.to.maxent,  '/', 'maxent.jar', sep = '')

cat ("\n\nmaxent.full.path.name = '", maxent.full.path.name, "'")

#---------------------

	#----------------------------------------------------------------------
	#  BTL - 2013 04 09
	#  For some reason, " outputdirectory=MaxentOutputs" no longer worked
	#  correctly after I had added code to create the
	#  maxent.output.dir variable at the start of this file.
	#  maxent would run and look like it was doing everything just fine
	#  until the very end but stop and say it couldn't find the output
	#  directory, even though it had already written to it.
	#  Afterwards, there was also a file called Rplots.pdf left in the
	#  output area but I couldn't open it.  A stackoverflow page mentioned
	#  Rplots.pdf being created when some plotting device was written to
	#  but not open (or something like that).
	#  Not sure what was going on but as soon I swapped to
	#      ' outputdirectory=', maxent.output.dir
	#  everything worked fine again.  May have had to do with some other
	#  thing that I was doing around the same time and not the creation
	#  of the maxent.output.dir variable since I was changing a bunch of
	#  things in the process of creating the true relative probability
	#  distribution.
	#----------------------------------------------------------------------

longMaxentCmd = paste ('java -mx512m -jar ',

					maxent.full.path.name,

#                       ' outputdirectory=MaxentOutputs',
				   ' outputdirectory=', maxent.output.dir,

				   #' samplesfile=../MaxentSamples/spp.sampledPres.combined.csv',
#                       ' samplesfile=',PAR.input.directory, '/spp.sampledPres.combined.csv',
				   ' samplesfile=',cur.full.maxent.samples.dir.name, '/spp.sampledPres.combined.csv',

				   ' environmentallayers=', cur.full.maxent.env.layers.dir.name,

						#  If you have more than one processor in your
						#  machine, then setting the thread count to the
						#  number of processors can speed up things like
						#  jacknife operations (and hopefully, replicate
						#  operations) by using all of the processors.
				   ' threads=', PAR.num.processors,

				   ' autorun ',

				   ' replicates=', variables$PAR.num.maxent.replicates,

				   ' replicatetype=bootstrap ',

#  There are some random seed issues here when doing bootstrap replicates.
#  It looks like you cannot choose the seed yourself so you cannot get
#  a reproducible result.  If you set randomseed to false and then try
#  this, maxent will put up a prompt telling you that it is going to
#  set randomseed to true.
#  Need to talk to the maxent developers about this.
#  2011.09.21 - BTL
				   ' randomseed=true',
#                       ' randomseed=false',

				   ' redoifexists ',

#                      ' nowarnings ',

						#  Looks like you have to set the "novisible" flag
						#  in the argument list to maxent and then it will
						#  return a 1 if it fails.  Without the "novisible"
						#  flag, it seems to assume that you know there was
						#  a problem (since its GUI was visible and hung
						#  when it gave you a blocking message when it had
						#  a problem) and returns an exit code that says it
						#  succeeded instead of failed.
						#  Commented out in guppy.test.maxent.v9.R
						#  Not commented out in ascelin's guppy example code.
						#  Not sure which is best inside of tzar.

                            #  While I'm doing interactive testing, I'll leave
                            #  novisible commented out.  I think that the place
                            #  where it matters is in doing lots of batch runs
                            #  where you wouldn't see maxent doing its thing.
#				   ' novisible',

				   sep = '')

shortMaxentCmd = paste( 'java -mx512m -jar ',

					maxent.full.path.name,

#                        ' outputdirectory=MaxentOutputs',
					' outputdirectory=', maxent.output.dir,

					#' samplesfile=../MaxentSamples/spp.sampledPres.combined.csv',
				   ' samplesfile=',cur.full.maxent.samples.dir.name, '/spp.sampledPres.combined.csv',
#                        ' samplesfile=',PAR.input.directory,'/MaxentSamples/spp.sampledPres.combined.csv',

					' environmentallayers=', cur.full.maxent.env.layers.dir.name,

                            #  If you have more than one processor in your
                            #  machine, then setting the thread count to the
                            #  number of processors can speed up things like
                            #  jacknife operations (and hopefully, replicate
                            #  operations) by using all of the processors.
                       ' threads=', PAR.num.processors,

						#  Looks like you have to set the "novisible" flag
						#  in the argument list to maxent and then it will
						#  return a 1 if it fails.  Without the "novisible"
						#  flag, it seems to assume that you know there was
						#  a problem (since its GUI was visible and hung
						#  when it gave you a blocking message when it had
						#  a problem) and returns an exit code that says it
						#  succeeded instead of failed.
						#  Commented out in guppy.test.maxent.v9.R
						#  Not commented out in ascelin's guppy example code.
						#  Not sure which is best inside of tzar.

                            #  While I'm doing interactive testing, I'll leave
                            #  novisible commented out.  I think that the place
                            #  where it matters is in doing lots of batch runs
                            #  where you wouldn't see maxent doing its thing.
#                    ' novisible',

				' autorun  redoifexists',

					sep = '' )

#maxentCmd = longMaxentCmd
maxentCmd = shortMaxentCmd

if (variables$PAR.do.maxent.replicates)
	{ maxentCmd = longMaxentCmd }

cat( '\n\nThe long command to run maxent is:', longMaxentCmd, '\n' )
cat( '\n\nThe short command to run maxent is:', shortMaxentCmd, '\n' )

cat( '\n\nThe command to run maxent is:', maxentCmd, '\n' )

##cat ("\n\n\n")
##stop()

#----------

cat( '\n----------------------------------' );
cat( '\n Running Maxent' );
cat( '\n----------------------------------' );

maxent.exit.code = system (maxentCmd)

cat ("\n\nmaxent.exit.code = ", maxent.exit.code,
	", class (maxent.exit.code) = ", class (maxent.exit.code))

if (maxent.exit.code != 0)
  {
  stop (paste ("\n\nmaxent failed: maxent.exit.code = ",
               maxent.exit.code, sep=''),
        call. = FALSE)
  } else
  {
  cat ("\n\nmaxent run succeeded (i.e., exit code == 0).")
  }

#===============================================================================

	#  Maxent is done now, so compare its results to the correct values.

#===============================================================================

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
			read.asc.file.to.matrix (spp.name, maxent.output.dir.with.slash)

		#  Normalize the matrix to allow comparison with true distribution.
	tot.maxent.rel.prob.dist = sum (maxent.rel.prob.dist)
	maxent.norm.prob.dist = maxent.rel.prob.dist/tot.maxent.rel.prob.dist
	sum (maxent.norm.prob.dist)  #  Make sure it's a prob dist, i.e., sums to 1

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
	####  Actually, norm.problmatrix IS defined.  Not sure why this comment is here.
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

	percent.err.magnitudes <- (err.magnitudes / norm.prob.matrix) * 100
	hist (percent.err.magnitudes [percent.err.magnitudes <= 100])

	if (variables$PAR.show.percent.error.in.dist)
		{
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
			read.asc.file.to.matrix (paste ("/", spp.name, "_stddev", sep=''),
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


#===============================================================================

setwd (startingDir)

#===============================================================================

