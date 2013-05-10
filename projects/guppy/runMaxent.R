#===============================================================================

#                                 runMaxent.v13.R

# source( 'runMaxent.R' )

#===============================================================================

#  History:

#  2013 04 14 - BTL - v11
#  Have split the last version of the code up into a bunch of separate files
#  that are all sourced in a line instead of having one giant file.
#  That led to finding one bug about not having defined a vector called
#  species properly in generating sampled presences.  That has now been fixed
#  in createSampledPresences.R.  Otherwise, splitting into separate files
#  seemed to work ok.  Will now move on to trying to turn the separate files
#  into functions that can be called instead of sourcing files.

#  2013 04 13 - BTL - v10
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

#===============================================================================

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

#===============================================================================

#  options (warn = 2)  =>  warnings are treated as errors, i.e., they're fatal.
#  Here's what the options() help page in R says:
#
#    warn:
#    sets the handling of warning messages. If warn is negative all warnings
#    are ignored. If warn is zero (the default) warnings are stored until
#    the top–level function returns. If fewer than 10 warnings were signalled
#    they will be printed otherwise a message saying how many were signalled.
#    An object called last.warning is created and can be printed through the
#    function warnings. If warn is one, warnings are printed as they occur.
#    If warn is two or larger all warnings are turned into errors.

options (warn = variables$PAR.RwarningLevel)

#===============================================================================

# First get the OS
#   for linux this returns linux-gnu
#   for mac this returns darwin9.8.0
#   for windos this returns mingw32

current.os <- sessionInfo()$R.version$os
cat ("\n\nos = '", current.os, "'\n", sep='')

dir.slash = "/"
#if (current.os == 'mingw32')  dir.slash = "\\"
if (current.os == "mingw32")  dir.slash = "\\"
cat ("\n\ndir.slash = '", dir.slash, "'\n", sep='')

#===============================================================================

rdvRootDir = getwd()
rdvSharedRsrcDir = paste (rdvRootDir, "/R", sep='')
guppyProjectRsrcDir = paste (rdvRootDir, "/projects/guppy", sep='')
guppyProjectRsrcDirWithSlash = paste (guppyProjectRsrcDir, "/", sep='')

cat ("\n\nrdvRootDir = ", rdvRootDir, sep='')
cat ("\nrdvSharedRsrcDir = ", rdvSharedRsrcDir, sep='')
cat ("\nguppyProjectRsrcDirWithSlash = ", guppyProjectRsrcDirWithSlash, sep='')
cat ("\n\n")

#stop()

#===============================================================================

source (paste (guppyProjectRsrcDirWithSlash, 'w.R', sep=''))
source (paste (guppyProjectRsrcDirWithSlash, 'read.R', sep=''))
source (paste (guppyProjectRsrcDirWithSlash, 'guppySupportFunctions.R', sep=''))

source (paste (guppyProjectRsrcDirWithSlash, 'guppyInitializations.R', sep=''))

source (paste (guppyProjectRsrcDirWithSlash, 'buildEnvLayers.R', sep=''))

source (paste (guppyProjectRsrcDirWithSlash, 'genCombinedSppPresTable.R', sep=''))

source (paste (guppyProjectRsrcDirWithSlash, 'computeTrueRelProbDist.R', sep=''))
source (paste (guppyProjectRsrcDirWithSlash, 'computeSppDistributions.R', sep=''))

source (paste (guppyProjectRsrcDirWithSlash, 'createTruePresences.R', sep=''))

source (paste (guppyProjectRsrcDirWithSlash, 'createSampledPresences.R', sep=''))

source (paste (guppyProjectRsrcDirWithSlash, 'saveCombinedPresencesForMaxent.R', sep=''))

source (paste (guppyProjectRsrcDirWithSlash, 'runMaxentCmd.R', sep=''))

source (paste (guppyProjectRsrcDirWithSlash, 'evaluateMaxentResults.R', sep=''))

#===============================================================================

	#--------------------------------
	#  Generate environment layers.
	#--------------------------------

env.layers = genEnvLayers ()
num.env.layers = length (env.layers)

imgDimensions = dim (env.layers[[1]])
num.rows <- imgDimensions [1]
num.cols <- imgDimensions [2]
num.cells <- num.rows * num.cols

cat ("\n\n>>>  After genEnvLayers(), num.env.layers = ", num.env.layers, sep='')
cat ("\n>>>                        imgDimensions = ", imgDimensions)
cat ("\n>>>                        img is ", num.rows, " rows by ", num.cols, " cols for total cell ct = ", num.cells, sep='')

	#--------------------------------------------
	#  Generate true relative probability maps.
	#--------------------------------------------

if (variables$PAR.genTruePresWithArithmeticCombinations)
	{
	#num.true.presences = get.num.true.presences.for.each.spp ()
#	true.rel.prob.dists.for.spp =
		get.true.rel.prob.dists.for.all.spp.ARITH (env.layers, num.env.layers
		#,
		#									 num.true.presences
											 )
	} else if (variables$PAR.genTruePresWithMaxent)
	{

		#--------------------------------------------------------------------
		#  Here, we now want to have the option to create the true relative
		#  probability maps in a different way.
		#  	1) Generate a very small number of presence locations.
		#	2) Hand these to maxent with the environment layers and
		#	   have it fit a distribution from them (no bootstrapping).
		#	3) Return that as the true relative probability map.
		#--------------------------------------------------------------------

#	true.rel.prob.dists.for.spp =
		get.true.rel.prob.dists.for.all.spp.MAXENT (env.layers, num.env.layers)
	}

	#----------------------------
	#  Generate true presences.
	#----------------------------

cat ("\n\n+++++\tBefore ", "get.num.true.presences.for.each.spp", "\n")

#  moved from up above.
num.true.presences = get.num.true.presences.for.each.spp ()

cat ("\n\n+++++\tBefore", "genTruePresences", "\n")

list.of.true.presences.and.x.y.locs = genTruePresences (num.true.presences)
combined.spp.true.presences.table =
	list.of.true.presences.and.x.y.locs [["combined.spp.true.presences.table"]]
all.spp.true.presence.locs.x.y =
	list.of.true.presences.and.x.y.locs [["all.spp.true.presence.locs.x.y"]]

	#-------------------------------
	#  Generate sampled presences.
	#-------------------------------

cat ("\n\n+++++\tBefore", "createSampledPresences", "\n")

combined.spp.sampled.presences.table =
	createSampledPresences (num.true.presences, all.spp.true.presence.locs.x.y)

	#----------------------------------
	#  Generate all of the presences.
	#----------------------------------

cat ("\n\n+++++\tBefore", "saveCombinedPresencesForMaxent", "\n")

saveCombinedPresencesForMaxent (combined.spp.true.presences.table,
								combined.spp.sampled.presences.table)

	#----------------------------------------------------------------
	#  Run maxent to generate a predicted relative probability map.
	#----------------------------------------------------------------

maxentSamplesFileName = combinedPresSamplesFileName
maxentOutputDir = maxent.output.dir
bootstrapMaxent = variables$PAR.do.maxent.replicates

#if (FALSE)
#{
cat ("\n\n+++++\tBefore", "runMaxentCmd", "\n")

runMaxentCmd (maxentSamplesFileName, maxentOutputDir,
				bootstrapMaxent)

	#----------------------------------------------------------------
	#  Evaluate the results of maxent by comparing its output maps
	#  to the true relative probability maps.
	#----------------------------------------------------------------

cat ("\n\n+++++\tBefore", "evaluateMaxentResults", "\n")

evaluateMaxentResults ()
#}
	#----------------------------------------------------------------
	#  Set up input files and paths to run zonation, then run it.
	#----------------------------------------------------------------

cat ("\n\n+++++\tBefore", "runZonation.R", "\n")

		#  At the moment, I can't get wine to run properly anywhere,
		#  so I can only run zonation if we're on a Windows system.
##if (current.os == "mingw32")
##	{
	source (paste (guppyProjectRsrcDirWithSlash, 'runZonation.R', sep=''))

##	} else
##	{
##	cat ("\n\n=====>  Can't run zonation on non-Windows system yet ",
##		   "\n=====>  since wine doesn't work properly yet.  Quitting now.\n\n",
##		   sep='')
##	}

cat ("\n\nAt end of runMaxent.R.  \n\n             -----  ALL DONE WITH GUPPY RUN NOW  -----\n\n")

#===============================================================================

