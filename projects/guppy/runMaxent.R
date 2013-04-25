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

source ('/Users/Bill/D/rdv-framework/projects/guppy/w.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/read.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/guppySupportFunctions.R')

source ('/Users/Bill/D/rdv-framework/projects/guppy/guppyInitializations.R')

source ('/Users/Bill/D/rdv-framework/projects/guppy/buildEnvLayers.R')

source ('/Users/Bill/D/rdv-framework/projects/guppy/genCombinedSppPresTable.R')

source ('/Users/Bill/D/rdv-framework/projects/guppy/computeTrueRelProbDist.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/computeSppDistributions.R')

source ('/Users/Bill/D/rdv-framework/projects/guppy/createTruePresences.R')

source ('/Users/Bill/D/rdv-framework/projects/guppy/createSampledPresences.R')

source ('/Users/Bill/D/rdv-framework/projects/guppy/saveCombinedPresencesForMaxent.R')

source ('/Users/Bill/D/rdv-framework/projects/guppy/runMaxentCmd.R')

source ('/Users/Bill/D/rdv-framework/projects/guppy/evaluateMaxentResults.R')

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

#  moved from up above.
num.true.presences = get.num.true.presences.for.each.spp ()

list.of.true.presences.and.x.y.locs = genTruePresences (num.true.presences)
combined.spp.true.presences.table =
	list.of.true.presences.and.x.y.locs [["combined.spp.true.presences.table"]]
all.spp.true.presence.locs.x.y =
	list.of.true.presences.and.x.y.locs [["all.spp.true.presence.locs.x.y"]]

	#-------------------------------
	#  Generate sampled presences.
	#-------------------------------

combined.spp.sampled.presences.table =
	createSampledPresences (num.true.presences, all.spp.true.presence.locs.x.y)

	#----------------------------------
	#  Generate all of the presences.
	#----------------------------------

saveCombinedPresencesForMaxent (combined.spp.true.presences.table,
								combined.spp.sampled.presences.table)

	#----------------------------------------------------------------
	#  Run maxent to generate a predicted relative probability map.
	#----------------------------------------------------------------

maxentSamplesFileName = combinedPresSamplesFileName
maxentOutputDir = maxent.output.dir
bootstrapMaxent = variables$PAR.do.maxent.replicates

runMaxentCmd (maxentSamplesFileName, maxentOutputDir,
				bootstrapMaxent)

	#----------------------------------------------------------------
	#  Evaluate the results of maxent by comparing its output maps
	#  to the true relative probability maps.
	#----------------------------------------------------------------

evaluateMaxentResults ()

#===============================================================================

