# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

#===============================================================================
#  This bar is just here to show the 80 character margin since I can't currently
#  see a way to do that in ipython itself.
#===============================================================================

# <codecell>

    #  BTL - 2013.07.15
    #  This is just while I'm figuring out how to do tests of things in ipython, 
    #  particularly when they involve creating and moving to directories that 
    #  may be very different for tzar.
    
    #  ONCE THINGS ARE FIGURED OUT, ALL USES OF tempDontMakeDirsYet 
    #  NEED TO BE REMOVED AND THIS LITTLE BLOCK NEEDS TO BE REMOVED.

tempDontMakeDirsYet = True
print "\n\n\n====>>>  tempDontMakeDirsYet = ", tempDontMakeDirsYet, "\n\n\n"

# <codecell>

#                               guppyInitializations.py

#  Initialize global guppy variables and create necessary directories, etc.

#  Usage:
#      python 'guppyInitializations.py'

# <codecell>

#  History:

#  2013.07.14 - BTL
#  Converted to python.

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

# <codecell>

#  NOTE:
#
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

# <headingcell level=3>

# Output from log file of a tzar run of the R version to show what values should be produced

# <markdowncell>

# Location of log file this output is taken from:
# 
# (paths copied from TextWrangler top bar's File Path pulldown)
# 
# path ========> ~/tzar/outputdata/Guppy/default_runset/114_Scen_1/logging.log
# 
# full path =====> /Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1/logging.log
# 
# url =========> file://localhost/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1/logging.log

# <rawcell>

# [FINE|4:06:15]: Rscript ./R/rrunner.R --paramfile=/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/parameters.json --rscript=./projects/guppy/runMaxent.R --outputpath=/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/ --inputpath=./projects/guppy/ 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: os = 'darwin9.8.0' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: dir.slash = '/' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: rdvRootDir = /Users/Bill/D/rdv-framework 
# [FINE|4:06:15]: rdvSharedRsrcDir = /Users/Bill/D/rdv-framework/R 
# [FINE|4:06:15]: guppyProjectRsrcDirWithSlash = /Users/Bill/D/rdv-framework/projects/guppy/ 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: Loading required package: methods 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: random.seed = '20', class (random.seed) = 'numeric') 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: =========  START str() of the 3 lists  ========= 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: List of 1 
# [FINE|4:06:15]:  $ PAR.input.directory: chr "./projects/guppy/input_data" 
# [FINE|4:06:15]: List of 6 
# [FINE|4:06:15]:  $ PAR.maxent.gen.output.dir.name: chr "/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/MaxentGenOutputs" 
# [FINE|4:06:15]:  $ PAR.zonation.files.dir.name   : chr "/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/Zonation" 
# [FINE|4:06:15]:  $ PAR.prob.dist.layers.dir.name : chr "/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/MaxentProbDistLayers" 
# [FINE|4:06:15]:  $ PAR.testing.output.filename   : chr "/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/test_output_file.txt" 
# [FINE|4:06:15]:  $ PAR.current.run.directory     : chr "/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/" 
# [FINE|4:06:15]:  $ PAR.maxent.output.dir.name    : chr "/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/MaxentOutputs" 
# [FINE|4:06:15]: List of 57 
# [FINE|4:06:15]:  $ PAR.min.true.presence.fraction.of.landscape: num 2e-04 
# [FINE|4:06:15]:  $ PAR.truncated.percent.err.img              : logi TRUE 
# [FINE|4:06:15]:  $ PAR.genTruePresWithArithmeticCombinations  : logi FALSE 
# [FINE|4:06:15]:  $ PAR.spp.hab.map.filename.root.win          : chr "MaxentOutputs\\\\spp" 
# [FINE|4:06:15]:  $ PAR.analysis.dir.name                      : chr "ResultsAnalysis" 
# [FINE|4:06:15]:  $ PAR.path.to.zonation                       : chr "lib/zonation" 
# [FINE|4:06:15]:  $ PAR.maxent.samples.base.name               : chr "MaxentSamples" 
# [FINE|4:06:15]:  $ PAR.num.processors                         : num 1 
# [FINE|4:06:15]:  $ PAR.run.zonation                           : logi TRUE 
# [FINE|4:06:15]:  $ PAR.write.to.file                          : logi FALSE 
# [FINE|4:06:15]:  $ PAR.show.abs.error.in.dist                 : logi TRUE 
# [FINE|4:06:15]:  $ PAR.random.seed                            : num 20 
# [FINE|4:06:15]:  $ PAR.num.spp.to.create                      : num 5 
# [FINE|4:06:15]:  $ PAR.use.random.num.true.presences          : logi TRUE 
# [FINE|4:06:15]:  $ PAR.zonation.app.spp.list.filename         : chr "zonation_app_spp_list.dat" 
# [FINE|4:06:15]:  $ PAR.use.old.maxent.output.for.input        : logi FALSE 
# [FINE|4:06:15]:  $ PAR.minNumPres                             : num 3 
# [FINE|4:06:15]:  $ PAR.use.pnm.env.layers                     : logi TRUE 
# [FINE|4:06:15]:  $ PAR.zonation.cor.output.filename           : chr "zonation_cor_output" 
# [FINE|4:06:15]:  $ CONST.add.rule                             : num 2 
# [FINE|4:06:15]:  $ PAR.num.true.presences                     : chr "50,100,75" 
# [FINE|4:06:15]:  $ PAR.remoteEnvDir                           : chr "http://glass.eres.rmit.edu.au/tzar_input/guppy/AlexFractalData/H" 
# [FINE|4:06:15]:  $ PAR.localEnvDirWin                         : chr "Z:/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H" 
# [FINE|4:06:15]:  $ PAR.variable.to.test.repetitions           : num -99 
# [FINE|4:06:15]:  $ PAR.zonation.spp.list.filename             : chr "zonation_spp_list.dat" 
# [FINE|4:06:15]:  $ PAR.genTruePresWithMaxent                  : logi TRUE 
# [FINE|4:06:15]:  $ PAR.fileSizeSuffix                         : chr ".256" 
# [FINE|4:06:15]:  $ PAR.trueProbDistFilePrefix                 : chr "true.prob.dist" 
# [FINE|4:06:15]:  $ PAR.do.maxent.replicates                   : logi FALSE 
# [FINE|4:06:15]:  $ PAR.zonation.app.output.filename           : chr "zonation_app_output" 
# [FINE|4:06:15]:  $ PAR.zonation.parameter.filename            : chr "lib/zonation/Z_parameter_settings.dat" 
# [FINE|4:06:15]:  $ PAR.show.raw.error.in.dist                 : logi TRUE 
# [FINE|4:06:15]:  $ PAR.zonation.exe.filename                  : chr "zig3.exe" 
# [FINE|4:06:15]:  $ PAR.maxent.env.layers.base.name            : chr "MaxentEnvLayers" 
# [FINE|4:06:15]:  $ PAR.use.filled.contour                     : logi TRUE 
# [FINE|4:06:15]:  $ PAR.show.abs.percent.error.in.dist         : logi TRUE 
# [FINE|4:06:15]:  $ PAR.closeZonationWindowOnCompletion        : logi TRUE 
# [FINE|4:06:15]:  $ PAR.path.to.maxent.input.data              : chr ".." 
# [FINE|4:06:15]:  $ PAR.pathToRfiles                           : chr "./projects/guppy/" 
# [FINE|4:06:15]:  $ PAR.useRemoteEnvDir                        : logi FALSE 
# [FINE|4:06:15]:  $ PAR.use.all.samples                        : logi FALSE 
# [FINE|4:06:15]:  $ PAR.rdv.directory                          : chr "" 
# [FINE|4:06:15]:  $ PAR.show.heatmap                           : logi TRUE 
# [FINE|4:06:15]:  $ PAR.maxNumPres                             : num 9 
# [FINE|4:06:15]:  $ CONST.product.rule                         : num 1 
# [FINE|4:06:15]:  $ PAR.max.true.presence.fraction.of.landscape: num 0.002 
# [FINE|4:06:15]:  $ PAR.spp.hab.map.filename.root              : chr "MaxentOutputs/spp" 
# [FINE|4:06:15]:  $ PAR.path.to.maxent                         : chr "lib/maxent" 
# [FINE|4:06:15]:  $ PAR.show.percent.error.in.dist             : logi TRUE 
# [FINE|4:06:15]:  $ PAR.use.draw.image                         : logi FALSE 
# [FINE|4:06:15]:  $ PAR.zonation.cor.spp.list.filename         : chr "zonation_cor_spp_list.dat" 
# [FINE|4:06:15]:  $ PAR.num.spp.in.reserve.selection           : num 3 
# [FINE|4:06:15]:  $ PAR.numEnvLayers                           : num 5 
# [FINE|4:06:15]:  $ PAR.num.maxent.replicates                  : num 5 
# [FINE|4:06:15]:  $ PAR.RwarningLevel                          : num 1 
# [FINE|4:06:15]:  $ PAR.localEnvDirMac                         : chr "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H" 
# [FINE|4:06:15]:  $ PAR.maxent.replicateType                   : chr "crossvalidate" 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: =========  END str() of the 3 lists  ========= 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: startingDir = '/Users/Bill/D/rdv-framework' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: pathToRfiles = './projects/guppy/' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: PAR.rdv.directory = '' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: PAR.input.directory = '/projects/guppy/input_data' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: PAR.current.run.directory = '/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/' 
# [FINE|4:06:15]: prob.dist.layers.dir = '/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/MaxentProbDistLayers' 
# [FINE|4:06:15]: maxent.output.dir = '/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/MaxentOutputs' 
# [FINE|4:06:15]: maxent.gen.output.dir = '/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/MaxentGenOutputs' 
# [FINE|4:06:15]: analysis.dir.with.slash = '/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/ResultsAnalysis/' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: cur.full.maxent.env.layers.dir.name = '/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/MaxentEnvLayers' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: cur.full.maxent.samples.dir.name = '/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/MaxentSamples' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: combinedPresSamplesFileName = '/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/MaxentSamples/spp.sampledPres.combined.csv' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: PAR.path.to.maxent = 'lib/maxent' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: maxent.full.path.name = ' /Users/Bill/D/rdv-framework/lib/maxent/maxent.jar ' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: variables$PAR.useRemoteEnvDir = 'FALSE' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: useRemoteEnvDir = 'FALSE' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: variables$PAR.remoteEnvDir = 'http://glass.eres.rmit.edu.au/tzar_input/guppy/AlexFractalData/H' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: variables$PAR.localEnvDirMac = '/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: variables$PAR.localEnvDirWin = 'Z:/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: envLayersDir = '/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: PAR.path.to.maxent.input.data = '..' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: num.env.layers = '5' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: eLayerFileNamePrefix = 'e01_' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: envSrcDir = '/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H08/' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: fullImgFileDestPath = '/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/MaxentEnvLayers/e01_H08_77.asc' 
# [FINE|4:06:15]: srcFile = ' /Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H08/H08_77.256.asc ' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: suffix = '.asc' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: fullImgFileDestPath = '/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/MaxentEnvLayers/e01_H08_77.pgm' 
# [FINE|4:06:15]: srcFile = ' /Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H08/H08_77.256.pgm ' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: suffix = '.pgm' 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: suffix is .pnm so adding env.layer 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: length (env.layers) before = '5Read 65536 items 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: is.matrix(img.matrix) in get.img.matrix.from.pnm = 'TRUE 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: is.vector(img.matrix) in get.img.matrix.from.pnm = 'FALSE 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: dim(img.matrix) in get.img.matrix.from.pnm = '256256 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: dim (new.env.layer) before = '256256 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: is.matrix(new.env.layer) in get.img.matrix.from.pnm = 'TRUE 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: is.vector(new.env.layer) in get.img.matrix.from.pnm = 'FALSE 
# [FINE|4:06:15]:  
# [FINE|4:06:15]:  
# [FINE|4:06:15]: class(new.env.layer) in get.img.matrix.from.pnm = 'matrix 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: length (env.layers) AFTER = '5 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: new.env.layer [1:3,1:3] =  
# [FINE|4:06:15]: 0.67843140.66666670.67843140.66666670.67843140.67843140.66666670.66666670.6784314 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: new.env.layer [1, 1] = 0.6784314, and class = numeric 
# [FINE|4:06:15]: new.env.layer [1, 2] = 0.6666667, and class = numeric 
# [FINE|4:06:15]: new.env.layer [1, 3] = 0.6666667, and class = numeric 
# [FINE|4:06:15]: new.env.layer [2, 1] = 0.6666667, and class = numeric 
# [FINE|4:06:15]: new.env.layer [2, 2] = 0.6784314, and class = numeric 
# [FINE|4:06:15]: new.env.layer [2, 3] = 0.6666667, and class = numeric 
# [FINE|4:06:15]: new.env.layer [3, 1] = 0.6784314, and class = numeric 
# [FINE|4:06:15]: new.env.layer [3, 2] = 0.6784314, and class = numeric 
# [FINE|4:06:15]: new.env.layer [3, 3] = 0.6784314, and class = numeric 
# [FINE|4:06:15]:  
# [FINE|4:06:15]: eLayerFileNamePrefix = 'e02_' 

# <codecell>

dirSlash = "/"    #  How does python sense this for each OS?
					#  Should this be in the yaml file?

# <codecell>

    #  Move to the guppy working directory.
    #  NOTE:  This may be an issue in the long run when running under tzar.
    #         I need to move there now so that netpbmfile will be found when imported.
    #         However, when running under tzar, we will have cd-ed to the tzar directory.
    #         Or will we?  Not sure if that move will show up inside this python code...
import os

guppyDir = '/Users/Bill/D/rdv-framework/projects/guppy/'
os.chdir (guppyDir)
os.getcwd()

# <markdowncell>

# Note that the cell below will need its reference to tempDontMakeDirsYet 
# removed once that issue is all straightened out.  That variable can just be set to False, but it will be better to wipe it out altogether when things are working right.

# <codecell>

def createDirIfDoesntExist (dirToMake):
	if tempDontMakeDirsYet:
		print "\n====>>>  Would make dir '" + dirToMake + "' now."
	else:
		if not os.path.isdir (dirToMake):
			os.makedirs (dirToMake)

# <codecell>

import yaml
from pprint import pprint

yamlFile = open("projectparams.yaml", "r")

projectParams = yaml.load(yamlFile)
baseParams = projectParams ['base_params']
variables = baseParams ['variables']
outputFiles = baseParams ['output_files']
inputFiles = baseParams ['input_files']

'''
print "\n===============================\n"
print "PROJECTPARAMS = \n"
pprint (projectParams)

print "\n===============================\n"
print "BASEPARAMS = \n"
pprint (baseParams)
'''

print "\n===============================\n"
print "INPUTFILES = \n"
pprint (inputFiles)

print "\n===============================\n"
print "OUTPUTFILES = \n"
pprint (outputFiles)

print "\n===============================\n"
print "VARIABLES = \n"
pprint (variables)

print "\n===============================\n"

# <codecell>

import random

# <codecell>

	#---------------------------------------------------------------------
    #  Temporary fixes to things that were set in guppy.test.maxent.v9.R
    #  but don't seem to appear anywhere here.
    #  BTL - 2013 04 04
	#---------------------------------------------------------------------

randomSeed = variables ['PAR.random.seed']
print "\nrandom.seed = '" + str(randomSeed) + "', class (randomSeed) = '" + randomSeed.__class__.__name__ + '\n'
random.seed (randomSeed)

# <codecell>

	#---------------------------------------------------
	#  default value for number of processors in the
    #  current machine.
    #  maxent can use this value to speed up some
    #  of its operations by creating more threads.
    #  It's not a necessary thing to set for any other
    #  reason.
	#---------------------------------------------------

PARnumProcessors = variables ['PAR.num.processors']
print "\nPARnumProcessors =", PARnumProcessors

# <codecell>

startingDir = os.getcwd()
print "\nstartingDir = '" + startingDir + "'"

# <codecell>

pathToRfiles = variables ['PAR.pathToRfiles']
print "\npathToRfiles = '" + pathToRfiles + "'"

# <codecell>

PARrdvDirectory = variables ['PAR.rdv.directory']
print "\nPARrdvDirectory = '" + PARrdvDirectory + "'"

# <codecell>

PARinputDirectoryFromYaml = inputFiles ['PAR.input.directory']
print "\nPARinputDirectoryFromYaml = '" + PARinputDirectoryFromYaml + "'"

# <markdowncell>

# =================================================================================================
# 
# NOTE: There is a ***BUG*** here in stripping the first two characters off the start of the PARinputDirectoryFromYaml string.  
# 
# Not sure why this was done in the R version, but in the test python version where the string is "inputData", it reduces that string to "putData", which is definitely wrong.  Might have been stripping something like "D/" off of the R version?
# 
# After having a look at an example tzar log, I can see what's going on now.
# 
# This code assumes that whatever string is handed to it will need the first two characters removed and then it will splice the rdv directory together with a slash and whatever came after the first two characters.  For example, in the example log file this means that you will splice:
# 
# rdv.dir = ""
# 
# dirSlash = "/"
# 
# "./projects/guppy/input_data" minus the two lead characters to give:  "projects/guppy/input_data"
# 
# The result is then:
# 
# "" + "/" + "projects/guppy/input_data"    =    "/projects/guppy/input_data"
# 
# So, it looks like this is all setting up to tack this onto the end of another directory path that lacks a trailing slash - though I think that you can actually splice "x/" + "./project" to get "x/./project" and it will still work as a legal path.  The main problem here is that the yaml file doesn't guarantee anything at all about what variables ['PAR.input.directory'] looks like.  That will have to be dealt with here.  
# 
# Still, it worked before so for the moment, I'm just going to flag the lead character condition as a WARNING.  Should probably throw some kind of exception...
# 
# This is all partly related to whatever tzar does in building the 3 dictionaries that I'm reading in directly here, but tzar modifies.  
# 
# =================================================================================================

# <codecell>

leadChars = PARinputDirectoryFromYaml [0:2]
print "\nleadChars = '" + leadChars + "'"
if leadChars == "./":
    PARinputDirectory = PARrdvDirectory + dirSlash + PARinputDirectoryFromYaml [2:]
else:
    PARinputDirectory = PARrdvDirectory + dirSlash + PARinputDirectoryFromYaml
    print "\n***********  WARNING  ***********\n" + "    leadChars of PARinputDirectoryFromYaml = '" + leadChars + "' rather than './' so not stripping."
    print "    PARinputDirectory may be messed up." + "\n***********           ***********"
print "\nPARinputDirectory = '" + PARinputDirectory + "'"

# <codecell>

PARcurrentRunDirectory = outputFiles ['PAR.current.run.directory']
print "\nPARcurrentRunDirectory = '" + PARcurrentRunDirectory + "'"

# <codecell>

#probDistLayersDir = "./MaxentProbDistLayers/"    #7/17#  what we want maxent to generate, i.e., the true layers?
#PARprobDistLayersDirName = "MaxentProbDistLayers"
##probDistLayersDir = paste (PARcurrentRunDirectory, "/",
##                              PARprobDistLayersDirName, "/"

probDistLayersDir = outputFiles ['PAR.prob.dist.layers.dir.name']
probDistLayersDirWithSlash = probDistLayersDir + "/"

print "\nprobDistLayersDir = '" + probDistLayersDir + "'"
createDirIfDoesntExist (probDistLayersDir)

# <codecell>

#PARmaxentOutputDirName = "MaxentOutputs"

maxentOutputDir = outputFiles ['PAR.maxent.output.dir.name']
maxentOutputDirWithSlash = maxentOutputDir + dirSlash

print "\nmaxentOutputDir = '" + maxentOutputDir + "'"
createDirIfDoesntExist (maxentOutputDir)

# <codecell>

#PARmaxentGenOutputDirName = "MaxentGenOutputs"

maxentGenOutputDir = outputFiles ['PAR.maxent.gen.output.dir.name']
maxentGenOutputDirWithSlash = maxentGenOutputDir + "/"

print "\nmaxentGenOutputDir = '" + maxentGenOutputDir + "'"
createDirIfDoesntExist (maxentGenOutputDir)

# <codecell>

#analysisDir = "./ResultsAnalysis/"
#PARanalysisDirName = "ResultsAnalysis"

analysisDirWithSlash = PARcurrentRunDirectory +  dirSlash + variables ['PAR.analysis.dir.name'] + dirSlash
print "\nanalysisDirWithSlash = '" + analysisDirWithSlash + "'"
createDirIfDoesntExist (analysisDirWithSlash)

# <markdowncell>

#     #  NOTE:  DOES THIS output directory move below NEED TO BE DONE NOW?
#     #         IE, ARE ALL THE DIRECTORY CREATIONS BELOW ABSOLUTE OR ARE THEY
#     #         RELATIVE TO BEING IN THE CURRENTRUNDIRECTORY?
#     #
#     #         It makes testing all this in python easier if I can separate
#     #         the moving to a directory from the creation of directories.
#     
#     #  IN GENERAL, IT SEEMS LIKE I NEED TO MAKE SURE THAT PATHS ARE ALWAYS BUILT WITH AS LITTLE 
#     #  DEPENDENCE AS POSSIBLE ON WHAT DIRECTORY YOU HAPPEN TO BE SITTING IN AT A GIVEN TIME.  
#     #  THAT WILL MAKE IT MUCH EASIER TO TEST.  OR WILL IT?  MAYBE A RELATIVE PATH IS A BETTER 
#     #  THING SO THAT YOU CAN CREATE A DUMMY LITTLE TEST AREA AND WORK THERE WITHOUT HURTING 
#     #  ANYTHING ELSE...

# <codecell>

    #  Move to the output directory.

if tempDontMakeDirsYet:
    print "\n====>>>  Would move to dir '", PARcurrentRunDirectory, "' now."
else:
        #  Move to the output directory, e.g.,
        #  "/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/"
    os.chdir (PARcurrentRunDirectory)

# <codecell>

##if (!file.exists ("MaxentOutputs"))
##	{
##	dir.create ("MaxentOutputs")
##	}

curFullMaxentEnvLayersDirName = \
    PARcurrentRunDirectory + variables ['PAR.maxent.env.layers.base.name']

print "\n\ncurFullMaxentEnvLayersDirName = '" + curFullMaxentEnvLayersDirName + "'"

createDirIfDoesntExist (curFullMaxentEnvLayersDirName)

# <codecell>

##if (not file.exists ("MaxentSamples"))
##	{
##	dir.create ("MaxentSamples")
##	}

curFullMaxentSamplesDirName = \
	PARcurrentRunDirectory + variables ['PAR.maxent.samples.base.name']

print "\n\ncurFullMaxentSamplesDirName = '" + curFullMaxentSamplesDirName + "'"

createDirIfDoesntExist (curFullMaxentSamplesDirName)

# <codecell>

#       write.to.file : TRUE,
writeToFile = variables ['PAR.write.to.file']

#   	  use.draw.image : FALSE,
useDrawImage = variables ['PAR.use.draw.image']

#   	  use.filled.contour : TRUE,
useFilledContour = variables ['PAR.use.filled.contour']

            #  BEWARE: if this is FALSE, the get.env.layers() routine in
            #          guppy.maxent.functions.v6.R does something vestigial
            #          that you may not expect (or want) at all !
            #          Need to fix that.
            #          BTL - 2011.09.20
            #  BTL - 2011.10.03 - Is this note even relevant anymore?
            #                     Looks like this variable isn't even used now.
#   	  use.pnm.env.layers : TRUE ,
usePnmEnvLayers = variables ['PAR.use.pnm.env.layers']

# <codecell>

combinedSppTruePresencesTable = None		#  correct Null for PYTHON ???
combinedSppSampledPresencesTable = None

# <codecell>

PARnumSppToCreate = variables ['PAR.num.spp.to.create']
ARnumSppInReserveSelection = variables ['PAR.num.spp.in.reserve.selection']
PARuseOldMaxentOutputForInput = variables ['PAR.use.old.maxent.output.for.input']

# <codecell>

PARuseAllSamples = variables ['PAR.use.all.samples']

# <codecell>

CONSTproductRule = variables ['CONST.product.rule']
CONSTaddRule = variables ['CONST.add.rule']

# <codecell>

combinedPresSamplesFileName = curFullMaxentSamplesDirName + dirSlash + \
						'spp.sampledPres.combined.csv'
print "\n\ncombinedPresSamplesFileName = '" + combinedPresSamplesFileName + "'\n\n"

# <codecell>

PARpathToMaxent = variables ['PAR.path.to.maxent']
print "\n\nPARpathToMaxent = '" + PARpathToMaxent + "'"

maxentFullPathName = startingDir + dirSlash + PARpathToMaxent + dirSlash + 'maxent.jar'

print "\n\nmaxentFullPathName = '" + maxentFullPathName, "'"

# <codecell>

#  Look at this ipython notebook under the Subplots heading to see the
#  matplotlib way to do this.
#      http://nbviewer.ipython.org/urls/raw.github.com/swcarpentry/notebooks/master/matplotlib.ipynb

#####    par (mfrow=c(2,2))

# <headingcell level=1>

# End of guppyinitializations code  (EOF)

# <markdowncell>

# ---
# 
# ---
# 
# ---

# <headingcell level=2>

# Trying out some ipython extensions.

# <headingcell level=3>

# Most of the cells below that involved a call to the web failed at work or even at home, so I've turned those cells into raw text just to remember the code but not make the running of all cells in this notebook fail.

# <markdowncell>

# **Extension:  version_information**
# 
# http://nbviewer.ipython.org/urls/raw.github.com/jrjohansson/version_information/master/example.ipynb
# 
# This one fails all over the place, but need to try it from home to see if it's an issue with RMIT firewall, proxies, etc.

# <rawcell>

# %install_ext http://raw.github.com/jrjohansson/version_information/master/version_information.py
# %load_ext version_information
# %version_information
# %version_information scipy, numpy, Cython, matplotlib, qutip

# <markdowncell>

# Extension:  ***Magics for temporary workspace***
# 
#     %cdtemp -- Creates a temporary directory that is magically cleaned up when you exit IPython session.
# 
#     %%with_temp_dir -- Run Python code in a temporary directory and clean up it after the execution.
# 
# https://github.com/tkf/ipython-tempmagic

# <codecell>

%install_ext https://raw.github.com/tkf/ipython-tempmagic/master/tempmagic.py

# <markdowncell>

# ***Extension: ipy_table***
#     
# 
# ipy_table is a supporting module for IP[y]:Notebook which makes it easy to create richly formatted data tables.
# 
# 
# http://nbviewer.ipython.org/urls/raw.github.com/epmoyer/ipy_table/master/ipy_table-Introduction.ipynb
#     

# <markdowncell>

# Extension:  ***flot - interactive plotting***
# 
# Inline javascript plotting for IPython notebooks
# 
# This package adds the ability to plot in an ipython notebook using the flot plotting backend. This makes it possible to have interactive (zoomable) plots within an ipython notebook webpage. The flot javascript library that is sourced is currently hosted at crbates.github.com/flot/. This add-in requires ipython >= 0.13
# 
# https://github.com/crbates/ipython-flot/
# 
# http://www.flotcharts.org/

# <markdowncell>

# from IPython.display import Image
# Image(url='http://python.org/images/python-logo.gif')

# <rawcell>

# from IPython.display import SVG
# SVG(filename='python-logo.svg')

# <rawcell>

# from IPython.display import Image
# 
# # by default Image data are embedded
# Embed      = Image(    'http://scienceview.berkeley.edu/view/images/newview.jpg')
# 
# # if kwarg `url` is given, the embedding is assumed to be false
# ##SoftLinked = Image(url='http://scienceview.berkeley.edu/view/images/newview.jpg')
# 
# # In each case, embed can be specified explicitly with the `embed` kwarg
# # ForceEmbed = Image(url='http://scienceview.berkeley.edu/view/images/newview.jpg', embed=True)

# <codecell>

from IPython.display import HTML

# <codecell>

s = """<table>
<tr>
<th>Header 1</th>
<th>Header 2</th>
</tr>
<tr>
<td>row 1, cell 1</td>
<td>row 1, cell 2</td>
</tr>
<tr>
<td>row 2, cell 1</td>
<td>row 2, cell 2</td>
</tr>
</table>"""

# <codecell>

h = HTML(s); h

# <markdowncell>

# The following pandas section (and the display ones above) are taken from: 
# 
# https://wakari.io/nb/url///wakari.io/static/notebooks/Part_5___Rich_Display_System.ipynb

# <codecell>

import pandas

# <markdowncell>

# By default, DataFrames will be represented as text; to enable HTML representations we need to set a print option:

# <codecell>

pandas.core.format.set_printoptions(notebook_repr_html=True)

# <markdowncell>

# Here is a small amount of stock data for APPL:

# <codecell>

%%file data.csv
Date,Open,High,Low,Close,Volume,Adj Close
2012-06-01,569.16,590.00,548.50,584.00,14077000,581.50
2012-05-01,584.90,596.76,522.18,577.73,18827900,575.26
2012-04-02,601.83,644.00,555.00,583.98,28759100,581.48
2012-03-01,548.17,621.45,516.22,599.55,26486000,596.99
2012-02-01,458.41,547.61,453.98,542.44,22001000,540.12
2012-01-03,409.40,458.24,409.00,456.48,12949100,454.53

# <markdowncell>

# Read this as into a DataFrame:

# <codecell>

df = pandas.read_csv('data.csv')

# <markdowncell>

# And view the HTML representation:

# <codecell>

df

# <markdowncell>

# You can even embed an entire page from another site in an iframe; for example this is today's Wikipedia page for mobile users:

# <codecell>

from IPython.display import HTML
HTML('<iframe src=http://en.mobile.wikipedia.org/?useformat=mobile width=700 height=350></iframe>')

# <markdowncell>

# And we also support the display of mathematical expressions typeset in LaTeX, which is rendered in the browser thanks to the MathJax library.

# <codecell>

from IPython.display import Math
Math(r'F(k) = \int_{-\infty}^{\infty} f(x) e^{2\pi i k} dx')

# <markdowncell>

# Much more about Latex follows on the example page I've been copying from.  There's also a bunch of other stuff about things like embedding movies, etc.

# <codecell>


