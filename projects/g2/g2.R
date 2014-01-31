#===============================================================================

#                                 g2.R

# source( 'g2.R' )

#===============================================================================

#  History:

#  2014 01 31 - BTL
#  Created as the beginning of stripping the guppy project down and getting
#  rid of all the python code in it.
#  Largely basing it on runMaxent.R from:
#  GuppyRev256_from2013.05.20_justBeforePython_exportedFromCornerstone_2014.01.20/guppy.
#  Will also mix in things from the latest version of guppy as well, but
#  runMaxent.R from guppy revision 256 (on google code repository) is pretty
#  much the last version of the code after submitting the sewpac first year
#  report and before I started adding python to the project (other than the
#  overarching dummy model.py code that was required for using tzar at the
#  time, but all that did was immediately call runMaxent.R).

#===============================================================================

#  To run this code locally using tzar (by calling the R code from model.py):

#      cd /Users/bill/D/rdv-framework

#          All of this goes on one line; I've written it two ways, all on one
#          and then again, broken broken into separate lines for clarity.
#          One thing that I don't understand though, why is --rscript=run.maxent.R
#          inside the commandlineflags argument instead of on its own like all the
#          other -- flags.
#  java -jar tzar.jar execlocalruns --runnerclass=au.edu.rmit.tzar.runners.RRunner --projectspec=projects/g2/projectparams.yaml --localcodepath=. --commandlineflags="-p g2 --rscript=runMaxent.R"
#  java -jar tzar.jar execlocalruns
#      --runnerclass=au.edu.rmit.tzar.runners.RRunner
#      --projectspec=projects/g2/projectparams.yaml
#      --localcodepath=.
#      --commandlineflags="-p g2 --rscript=g2.R"

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

options (warn = 2)
#options (warn = variables$PAR.RwarningLevel)

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

setwd ("/Users/Bill/D/rdv-framework")

rdvRootDir = getwd()
rdvSharedRsrcDir = paste (rdvRootDir, "/R", sep='')
g2ProjectRsrcDir = paste (rdvRootDir, "/projects/g2", sep='')
g2ProjectRsrcDirWithSlash = paste (g2ProjectRsrcDir, "/", sep='')

cat ("\n\nrdvRootDir = ", rdvRootDir, sep='')
cat ("\nrdvSharedRsrcDir = ", rdvSharedRsrcDir, sep='')
cat ("\ng2ProjectRsrcDirWithSlash = ", g2ProjectRsrcDirWithSlash, sep='')
cat ("\n\n")

#stop()

#===============================================================================

#source (paste (g2ProjectRsrcDirWithSlash, 'w.R', sep=''))

#===============================================================================

	#--------------------------------
	#  Get environment layers.
	#--------------------------------


	#--------------------------------------------
	#  Get true species distributions.
	#
	#  For now, this means getting the true
	#  probability maps.
	#  It could eventually mean something like
	#  running an individual-based model, etc.
	#--------------------------------------------


	#----------------------------
	#  Generate true presences.
	#----------------------------


	#-------------------------------
	#  Get sampled presences.
	#-------------------------------


	#----------------------------------
	#  Get all of the presences.
	#----------------------------------


	#----------------------------------------------------------------
	#  Run maxent to generate a predicted relative probability map.
	#----------------------------------------------------------------


	#----------------------------------------------------------------
	#  Evaluate the results of maxent by comparing its output maps
	#  to the true relative probability maps.
	#----------------------------------------------------------------


	#----------------------------------------------------------------
	#  Set up input files and paths to run zonation.
	#----------------------------------------------------------------


	#----------------------------------------------------------------
	#  Run zonation.
	#----------------------------------------------------------------


	#----------------------------------------------------------------
	#  Evaluate the results of zonation by comparing output for
	#  running zonation on correct maps and on apparent maps.
	#----------------------------------------------------------------


	#----------------------------------------------------------------
	#  Set up input files and paths to run zonation.
	#----------------------------------------------------------------


#===============================================================================

