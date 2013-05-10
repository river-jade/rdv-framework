#=========================================================================================

#                               guppyInitializations.R

# source( 'guppyInitializations.R' )

#=========================================================================================

#  History:

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#=========================================================================================



#  Many things in here have an absolute path that looks like this:
#
#			/Users/Bill/D/rdv-framework/lib/maxent
#
#  This will fail when moved to windows or linux because rdv is not in:
#
#			/Users/Bill/D
#
#  Is that lead-in for rdv's location available somewhere as a variable
#  in the variables list?





#===============================================================================

	#---------------------------------------------------------------------
    #  Temporary fixes to things that were set in guppy.test.maxent.v9.R
    #  but don't seem to appear anywhere here.
    #  BTL - 2013 04 04
	#---------------------------------------------------------------------

random.seed <- variables$PAR.random.seed
cat ("\n\nrandom.seed = '", random.seed, "', class (random.seed) = '", class(random.seed), "')\n\n", sep='')
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
prob.dist.layers.dir.with.slash = paste (prob.dist.layers.dir, "/", sep='')

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

#PAR.maxent.gen.output.dir.name = "MaxentGenOutputs"

maxent.gen.output.dir = outputFiles$PAR.maxent.gen.output.dir.name
maxent.gen.output.dir.with.slash = paste (maxent.gen.output.dir, "/", sep='')

cat ("\nmaxent.gen.output.dir = '", maxent.gen.output.dir, "'", sep='')
if ( !file.exists (maxent.gen.output.dir))
  {
  dir.create (maxent.gen.output.dir)
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

combined.spp.true.presences.table = NULL
combined.spp.sampled.presences.table = NULL

#---------------------

PAR.num.spp.to.create = variables$PAR.num.spp.to.create
PAR.num.spp.in.reserve.selection = variables$PAR.num.spp.in.reserve.selection
PAR.use.old.maxent.output.for.input = variables$PAR.use.old.maxent.output.for.input

#---------------------

PAR.use.all.samples = variables$PAR.use.all.samples

#---------------------

CONST.product.rule = variables$CONST.product.rule
CONST.add.rule = variables$CONST.add.rule

#---------------------

combinedPresSamplesFileName = paste (cur.full.maxent.samples.dir.name,
						'/spp.sampledPres.combined.csv',
						sep='')
cat ("\n\ncombinedPresSamplesFileName = '", combinedPresSamplesFileName, "'\n\n", sep='')

#---------------------

PAR.path.to.maxent = variables$'PAR.path.to.maxent'
cat ("\n\nPAR.path.to.maxent = '", PAR.path.to.maxent, "'", sep='')

maxent.full.path.name <- paste (startingDir, "/", PAR.path.to.maxent,  '/', 'maxent.jar', sep = '')

cat ("\n\nmaxent.full.path.name = '", maxent.full.path.name, "'")

#---------------------

par (mfrow=c(2,2))

#===============================================================================


