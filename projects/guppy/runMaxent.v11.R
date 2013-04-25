#=========================================================================================

#                                 runMaxent.v11.R

# source( 'runMaxent.R' )

#=========================================================================================

#  History:

#  2013 04 14 - BTL - v11
#  Have split the last version of the code up into a bunch of separate files
#  that are all sourced in a line instead of having one giant file.
#  That led to finding one bug about not having defined a vector called
#  species properly in generating sampled presences.  That has now been fixed
#  in createSampledPresences.R.  Otherwise, splitting into separate files
#  seemed to work ok.  Will now move on to trying to turn the separate files
#  into functions that can be called instead of sourcing files.

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

#===============================================================================

source ('/Users/Bill/D/rdv-framework/projects/guppy/w.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/read.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/guppySupportFunctions.R')

source ('/Users/Bill/D/rdv-framework/projects/guppy/guppyInitializations.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/buildEnvLayers.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/computeSppDistributions.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/createTruePresences.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/createSampledPresences.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/saveCombinedPresencesForMaxent.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/runMaxentCmd.R')
source ('/Users/Bill/D/rdv-framework/projects/guppy/evaluateMaxentResults.R')

setwd (startingDir)

#===============================================================================

