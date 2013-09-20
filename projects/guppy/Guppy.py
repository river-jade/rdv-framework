#===============================================================================

#                                   Guppy.py

#  Usage:
#       cd /Users/Bill/D/rdv-framework
#       java -jar tzar.jar execlocalruns --runnerclass=PythonRunner  --projectspec=projects/guppy/projectparams.yaml --localcodepath=. --commandlineflags="-p guppy"

#  History:

#  2013.09.18 - BTL
#  Changed from using rpy2 to using pyper as the mechanism for linking to R
#  since rpy2 stopped working when I upgraded R to version 3.
#  Various web sites suggest rpy2 might still work if you recompile it and
#  set something in it to point to the version 3 of R since it is version
#  dependent.  However, I don't want to have to do that every time I upgrade
#  R, so I'm going to see if pyper is more independent of the R version.

#  2013.07.25 - BTL
#  Created Guppy.py file by copying code from what was getting to be a very
#  large cell in guppyInitializations.ipynb.
#  From now on, I will just be stripping code out of that file and this will
#  be the file to be used.

#  2013.07.24 - BTL
#  Had converted to python by doing it all inside an ipython notebook and
#  incrementally testing each little bit of code.  Now want to create a
#  class for Guppy and turn this initialization code into a method for that
#  class.  Unfortunately, ipython cannot execute multiple cells at once
#  and if you make a method that spans multiple cells, there will be
#  indentation and ipython will get upset about that indentation when it tries
#  to run just one cell where the reason for the indentation is not visible
#  in that cell.  So, I'm now going to strip this file down to one method or
#  a small number of methods, with each method in its own (possibly very long)
#  cell.  Once I have these methods built, I'll go create the Guppy class and
#  hang all this off of there.

#  2013.07.14 - BTL
#  Converted to python.

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#===============================================================================

#  NOTE:
#
#  Many things in here have an absolute path that looks like this:
#
#            /Users/Bill/D/rdv-framework/lib/maxent
#
#  This will fail when moved to windows or linux because rdv is not in:
#
#            /Users/Bill/D
#
#  Is that lead-in for rdv's location available somewhere as a variable
#  in the variables list?

#===============================================================================

#  Output from log file of a tzar run of the R version to show what values
#  should be produced:
#
#  Location of log file this output is taken from:
#
#  (paths copied from TextWrangler top bar's File Path pulldown)
#
#  path ========> ~/tzar/outputdata/Guppy/default_runset/114_Scen_1/logging.log
#
#  full path =====> /Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1/logging.log
#
#  url =========> file://localhost/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1/logging.log
#
#  At svn guppy revision 259, have removed the full output echo that was in
#  the next cell for now because it's quite large and I'm not doing anything
#  with it.
#  If you need to see it, look at svn version 259 of guppyInitializations.ipynb.
#  (BTL - 2013.07.24).

#===============================================================================

#  BTL - 2013.07.15
#  This is just while I'm figuring out how to do tests of things in ipython,
#  particularly when they involve creating and moving to directories that
#  may be very different for tzar.

#  ONCE THINGS ARE FIGURED OUT, ALL USES OF tempDontMakeDirsYet
#  NEED TO BE REMOVED AND THIS LITTLE BLOCK NEEDS TO BE REMOVED.

tempDontMakeDirsYet = False
print "\n\n\n====>>>  tempDontMakeDirsYet = ", tempDontMakeDirsYet, "\n\n\n"

verbose = True

#===============================================================================

import os
from pprint import pprint
import random

#  For testing only?
import yaml
import pickle

from sys import platform

#from rpy2.robjects import r
#from rpy2 import rinterface

import pandas as pd
import pyper as pr
r = pr.R (use_pandas = True)

#----------------------------------------

import GuppyConstants as CONST
import guppySupportFunctions as gsf
import GuppyEnvLayers

import GuppyGenTrueRelProbPres as TrueRelProbGen

from runMaxentCmd import runMaxentCmd

#===============================================================================

#  Note that the function below will need its reference to
#  tempDontMakeDirsYet removed once that issue is all straightened out.
#  That variable can just be set to False, but it will be better to wipe
#  it out altogether when things are working right.

def createDirIfDoesntExist(dirToMake):
    if tempDontMakeDirsYet:
        print "\n====>>>  Would make dir '" + dirToMake + "' now."
    else:
        if not os.path.isdir(dirToMake):
            os.makedirs(dirToMake)

#===============================================================================

class Guppy (object):
    """Overarching class for everything about managing a Guppy run.
    """

    def __init__(self, variables=None, qualifiedParams=None):

        """
        :type self: object
        :param variables:
        :param qualifiedParams:
        """

        self.variables = variables or {}
        self.qualifiedParams = qualifiedParams or {}

        self.curDir = os.getcwd()
        self.curOS = platform

        self.envLayersDir = None
        self.numEnvLayers = None
        self.numEnvLayers = self.variables['PAR.numEnvLayers']
        self.imgNumRows = variables['PAR.imgNumRows']
        self.imgNumCols = variables['PAR.imgNumCols']
        self.imgNumCells = self.imgNumRows * self.imgNumCols

        self.fileSizeSuffix = variables['PAR.fileSizeSuffix']

        if (verbose):
            print ("\n-----------------------------\n\nPARAMS AS PASSED IN:")
            self.pprintParamValues()

        #        self.variables ["test"] = "varTest"
        #        self.qualifiedParams ["test"] = "qpTest"

        self.randomSeed = 1
        self.setRandomSeed()

        self.initNumProcessors()

        self.useRemoteEnvDir = self.variables['PAR.useRemoteEnvDir']
        self.writeToFile = None
        self.useDrawImage = None
        self.useFilledContour = None
        self.usePnmEnvLayers = None

        self.numSppToCreate = None
        self.PARnumSppInReserveSelection = None
        self.PARuseOldMaxentOutputForInput = None
        self.PARuseAllSamples = None

        self.curFullMaxentEnvLayersDirName = None
        self.curFullMaxentSamplesDirName = None

        self.probDistLayersDir = None
        self.probDistLayersDirWithSlash = None
        self.maxentOutputDir = None
        self.maxentOutputDirWithSlash = None
        self.maxentGenOutputDir = None
        self.maxentGenOutputDirWithSlash = None
        self.maxentFullPathName = None
        self.combinedPresSamplesFileName = None
        self.analysisDirWithSlash = None

        self.initDirectories()

        self.guppyEnvLayers = None
        self.envLayers = None

        self.doMaxentReplicates = self.variables['PAR.do.maxent.replicates']
        self.numMaxentReplicates = self.variables['PAR.num.maxent.replicates']
        self.maxentReplicateType = self.variables['PAR.maxent.replicateType']
        self.verboseMaxent = False

        self.trueProbDistFilePrefix = self.variables["PAR.trueProbDistFilePrefix"]

        self.showRawErrorInDist = self.variables['PAR.show.raw.error.in.dist']
        self.showAbsErrorInDist = self.variables['PAR.show.abs.error.in.dist']
        self.showPercentErrorInDist = self.variables['PAR.show.percent.error.in.dist']
        self.showAbsPercentErrorInDist = self.variables['PAR.show.abs.percent.error.in.dist']
        self.showTruncatedPercentErrImg = self.variables['PAR.truncated.percent.err.img']
        self.showHeatmap = self.variables['PAR.show.heatmap']

    #-------------------------------------------------------------------------------

    def setRandomSeed(self):

        self.randomSeed = self.variables['PAR.random.seed']
        print "\nrandomSeed = '" + str(
            self.randomSeed) + "', class (randomSeed) = '" + self.randomSeed.__class__.__name__

        random.seed (self.randomSeed)

    #-------------------------------------------------------------------------------

    def initNumProcessors(self):

    #---------------------------------------------------
    #  default value for number of processors in the
    #  current machine.
    #  maxent can use this value to speed up some
    #  of its operations by creating more threads.
    #  It's not a necessary thing to set for any other
    #  reason.
    #---------------------------------------------------

        self.numProcessors = self.variables['PAR.num.processors']
        print "\nself.numProcessors =", self.numProcessors

    #-------------------------------------------------------------------------------

    def initDirectories(self):

        self.startingDir = os.getcwd()
        print "\nstartingDir = '" + self.startingDir + "'"

        self.pathToRfiles = self.variables['PAR.pathToRfiles']
        print "\npathToRfiles = '" + self.pathToRfiles + "'"

        self.PARrdvDirectory = self.variables['PAR.rdv.directory']
        print "\nPARrdvDirectory = '" + self.PARrdvDirectory + "'"

        #        self.PARinputDirectoryFromYaml = self.inputFiles ['PAR.input.directory']
        self.PARinputDirectoryFromYaml = self.qualifiedParams['PAR.input.directory']
        print "\nPARinputDirectoryFromYaml = '" + self.PARinputDirectoryFromYaml + "'"

        #===================================================================
        #
        #  NOTE: There is a BUG here in stripping the first two characters
        #        off the start of the PARinputDirectoryFromYaml string.
        #
        #  Not sure why this was done in the R version, but in the test
        #  python version where the string is "inputData", it reduces that
        #  string to "putData", which is definitely wrong.
        #  Might have been stripping something like "D/" off of the
        #  R version?
        #
        #  After having a look at an example tzar log, I can see what's
        #  going on now.
        #  This code assumes that whatever string is handed to it will need
        #  the first two characters removed and then it will splice the rdv
        #  directory together with a slash and whatever came after the first
        #  two characters.
        #  For example, in the example log file this means that you will
        #  splice:
        #
        #      rdv.dir = ""
        #      dirSlash = "/"
        #
        #  "./projects/guppy/input_data" minus the two lead characters
        #  to give:
        #      "projects/guppy/input_data"
        #
        #  The result is then:
        #
        #      "" + "/" + "projects/guppy/input_data" =
        #      "/projects/guppy/input_data"
        #
        #  So, it looks like this is all setting up to tack this onto
        #  the end of another directory path that lacks a trailing slash -
        #  though I think that you can actually splice "x/" + "./project"
        #  to get "x/./project" and it will still work as a legal path.
        #
        #  The main problem here is that the yaml file doesn't guarantee
        #  anything at all about what variables ['PAR.input.directory']
        #  looks like. That will have to be dealt with here.
        #
        #  Still, it worked before so for the moment, I'm just going to
        #  flag the lead character condition as a WARNING. Should probably
        #  throw some kind of exception...
        #
        #  This is all partly related to whatever tzar does in building
        #  the 3 dictionaries that I'm reading in directly here, but tzar
        #  modifies.
        #
        #===================================================================

        leadChars = self.PARinputDirectoryFromYaml[0:2]
        print "\nleadChars = '" + leadChars + "'"
        if leadChars == "./":
            self.PARinputDirectory = self.PARrdvDirectory + CONST.dirSlash + self.PARinputDirectoryFromYaml[2:]
        else:
            self.PARinputDirectory = self.PARrdvDirectory + CONST.dirSlash + self.PARinputDirectoryFromYaml
            print "\n***********  WARNING  ***********\n" + "    leadChars of PARinputDirectoryFromYaml = '" + leadChars + "' rather than './' so not stripping."
            print "    PARinputDirectory may be messed up." + "\n***********           ***********"
        print "\nPARinputDirectory = '" + self.PARinputDirectory + "'"


        PARcurrentRunDirectory = self.qualifiedParams['PAR.current.run.directory']
        print "\nPARcurrentRunDirectory = '" + PARcurrentRunDirectory + "'"


        self.probDistLayersDir = self.qualifiedParams['PAR.prob.dist.layers.dir.name']
        self.probDistLayersDirWithSlash = self.probDistLayersDir + "/"

        print "\nself.probDistLayersDir = '" + self.probDistLayersDir + "'"
        createDirIfDoesntExist(self.probDistLayersDir)


        self.maxentOutputDir = self.qualifiedParams['PAR.maxent.output.dir.name']
        self.maxentOutputDirWithSlash = self.maxentOutputDir + CONST.dirSlash

        print "\nself.maxentOutputDir = '" + self.maxentOutputDir + "'"
        createDirIfDoesntExist(self.maxentOutputDir)


        self.maxentGenOutputDir = self.qualifiedParams['PAR.maxent.gen.output.dir.name']
        self.maxentGenOutputDirWithSlash = self.maxentGenOutputDir + "/"

        print "\nself.maxentGenOutputDir = '" + self.maxentGenOutputDir + "'"
        createDirIfDoesntExist(self.maxentGenOutputDir)


        self.analysisDirWithSlash = PARcurrentRunDirectory + self.variables['PAR.analysis.dir.name'] + CONST.dirSlash
        print "\nself.analysisDirWithSlash = '" + self.analysisDirWithSlash + "'"
        createDirIfDoesntExist(self.analysisDirWithSlash)


        #  NOTE:  DOES THIS output directory move below NEED TO BE DONE NOW?
        #         IE, ARE ALL THE DIRECTORY CREATIONS BELOW ABSOLUTE OR ARE THEY
        #         RELATIVE TO BEING IN THE CURRENTRUNDIRECTORY?
        #
        #         It makes testing all this in python easier if I can separate
        #         the moving to a directory from the creation of directories.

        #  IN GENERAL, IT SEEMS LIKE I NEED TO MAKE SURE THAT PATHS ARE ALWAYS BUILT WITH AS LITTLE
        #  DEPENDENCE AS POSSIBLE ON WHAT DIRECTORY YOU HAPPEN TO BE SITTING IN AT A GIVEN TIME.
        #  THAT WILL MAKE IT MUCH EASIER TO TEST.  OR WILL IT?  MAYBE A RELATIVE PATH IS A BETTER
        #  THING SO THAT YOU CAN CREATE A DUMMY LITTLE TEST AREA AND WORK THERE WITHOUT HURTING
        #  ANYTHING ELSE...


        #  Move to the output directory.

        if tempDontMakeDirsYet:
            print "\n====>>>  Would move to dir '" + PARcurrentRunDirectory + "' now."
        else:
                #  Move to the output directory, e.g.,
                #  "/Users/Bill/tzar/outputdata/Guppy/default_runset/114_Scen_1.inprogress/"
            os.chdir(PARcurrentRunDirectory)


        self.curFullMaxentEnvLayersDirName = \
            PARcurrentRunDirectory + self.variables['PAR.maxent.env.layers.base.name']
        print "\n\nself.curFullMaxentEnvLayersDirName = '" + self.curFullMaxentEnvLayersDirName + "'"
        createDirIfDoesntExist(self.curFullMaxentEnvLayersDirName)


        self.curFullMaxentSamplesDirName = \
            PARcurrentRunDirectory + self.variables['PAR.maxent.samples.base.name']
        print "\n\nself.curFullMaxentSamplesDirName = '" + self.curFullMaxentSamplesDirName + "'"
        createDirIfDoesntExist(self.curFullMaxentSamplesDirName)


        self.writeToFile = self.variables['PAR.write.to.file']
        self.useDrawImage = self.variables['PAR.use.draw.image']
        self.useFilledContour = self.variables['PAR.use.filled.contour']

        #  BEWARE: if this is FALSE, the get.env.layers() routine in
        #          guppy.maxent.functions.v6.R does something vestigial
        #          that you may not expect (or want) at all !
        #          Need to fix that.
        #          BTL - 2011.09.20
        #  BTL - 2011.10.03 - Is this note even relevant anymore?
        #                     Looks like this variable isn't even used now.
        #         use.pnm.env.layers : TRUE ,
        self.usePnmEnvLayers = self.variables['PAR.use.pnm.env.layers']

        combinedSppTruePresencesTable = None  #  Is this the correct Null for PYTHON ???
        combinedSppSampledPresencesTable = None

        self.numSppToCreate = self.variables['PAR.num.spp.to.create']
        self.PARnumSppInReserveSelection = self.variables['PAR.num.spp.in.reserve.selection']
        self.PARuseOldMaxentOutputForInput = self.variables['PAR.use.old.maxent.output.for.input']

        self.PARuseAllSamples = self.variables['PAR.use.all.samples']

        CONST.productRule = self.variables['CONST.product.rule']
        CONST.addRule = self.variables['CONST.add.rule']

        #-----------------------------------

        self.combinedPresSamplesFileName = self.curFullMaxentSamplesDirName + CONST.dirSlash + \
                                           'spp.sampledPres.combined.csv'
        print "\n\nself.combinedPresSamplesFileName = '" + self.combinedPresSamplesFileName + "'\n\n"

        #-----------------------------------

        PARpathToMaxent = self.variables['PAR.path.to.maxent']
        print "\n\nPARpathToMaxent = '" + PARpathToMaxent + "'"

        #        self.maxentFullPathName = self.PARrdvDirectory + CONST.dirSlash + PARpathToMaxent + CONST.dirSlash + 'maxent.jar'
        self.maxentFullPathName = self.startingDir + "/../.." + CONST.dirSlash + PARpathToMaxent + CONST.dirSlash + 'maxent.jar'
        print "\n\nself.maxentFullPathName = '" + self.maxentFullPathName, "'"

        #-----------------------------------

        #  Look at this ipython notebook under the Subplots heading to see the
        #  matplotlib way to do this.
        #      http://nbviewer.ipython.org/urls/raw.github.com/swcarpentry/notebooks/master/matplotlib.ipynb

        #####    par (mfrow=c(2,2))

        #-----------------------------------

        ###        curFullMaxentEnvLayersDirName = PARcurrentRunDirectory + self.variables ['PAR.maxent.env.layers.base.name']
        ###        print "\ncurFullMaxentEnvLayersDirName = '" + curFullMaxentEnvLayersDirName + "'"
        ###        createDirIfDoesntExist (curFullMaxentEnvLayersDirName)

        #-----------------------------------

        #  NOTE the difference between the mac path in R and in python.
        #       In R, you need the backslash in front of the spaces, but in python,
        print "\nvariables ['PAR.useRemoteEnvDir'] = " + str(self.variables['PAR.useRemoteEnvDir'])
        print "variables ['PAR.remoteEnvDir'] = " + self.variables['PAR.remoteEnvDir']
        print "variables ['PAR.localEnvDirMac'] = " + self.variables['PAR.localEnvDirMac']
        print "variables ['PAR.localEnvDirWin'] = " + self.variables['PAR.localEnvDirWin']

        #-----------------------------------

        ###        if (self.variables ['PAR.useRemoteEnvDir']):
        print "***  self.useRemoteEnvDir = " + str(self.useRemoteEnvDir)
        print "***  self.curOS = " + self.curOS
        if (self.useRemoteEnvDir):
            self.envLayersDir = self.variables['PAR.remoteEnvDir']
            print "in branch 1"
        elif (self.curOS == CONST.windowsOSname):
            self.envLayersDir = self.variables['PAR.localEnvDirWin']
            print "in branch 2"
        else:
            self.envLayersDir = self.variables['PAR.localEnvDirMac']
            print "in branch 3"
        print "\nenvLayersDir = '" + self.envLayersDir + "'"

        #-----------------------------------

            #  Get generator to use for true relative probability
            #  distributions.

        self.trueRelProbDistGen = None

        if self.variables["PAR.genTruePresWithArithmeticCombinations"]:
            self.trueRelProbDistGen = TrueRelProbGen.GuppyGenTrueRelProbPresARITH(self.variables)

        elif self.variables["PAR.genTruePresWithMaxent"]:
            self.trueRelProbDistGen = TrueRelProbGen.GuppyGenTrueRelProbPresMAXENT(self.variables)

        #-------------------------------------------------------------------------------

    def pprintParamValues(self):

        print "\n\nvariables ="
        pprint(self.variables)
        print "\n\nqualifiedParams ="
        pprint(self.qualifiedParams)
        print "\n\nself.curDir = " + self.curDir
        print "\n\nself.curOS = " + self.curOS

    #        print "\n\nself.envLayersDir = " + self.envLayersDir + "'"
    #        print "\n\nnumEnvLayers = '" + str (self.numEnvLayers) + "'"
    #        print "\n\nfileSizeSuffix = '" + self.fileSizeSuffix + "'"

    #-------------------------------------------------------------------------------

    def loadEnvLayers(self, useMattEnvData):

        print "\n====>  IN loadEnvLayers:  self.curFullMaxentEnvLayersDirName = '" + self.curFullMaxentEnvLayersDirName + "'"

        if useMattEnvData:
            self.guppyEnvLayers = GuppyEnvLayers.GuppyMattEnvLayers(self.curFullMaxentEnvLayersDirName, \
                                                                       self.useRemoteEnvDir, \
                                                                       self.envLayersDir, \
                                                                       self.numEnvLayers, \
                                                                       self.imgNumRows, self.imgNumCols)

        else:   #  Use Alex's fractal data
            self.guppyEnvLayers = GuppyEnvLayers.GuppyFractalEnvLayers(self.curFullMaxentEnvLayersDirName, \
                                                                       self.useRemoteEnvDir, \
                                                                       self.envLayersDir, \
                                                                       self.numEnvLayers, \
                                                                       self.imgNumRows, self.imgNumCols, \
                                                                       self.fileSizeSuffix)

        self.guppyEnvLayers.genEnvLayers()
#        self.envLayers = self.guppyEnvLayers.genEnvLayers()
#        print "\nIn Guppy:loadEnvLayers:  self.envLayers.__class__.__name__ = '" + self.envLayers.__class__.__name__ + "'"

        if (False):
            envLayersShape = self.envLayers.shape
            print "\nenvLayersShape = " + str(envLayersShape)

            self.numEnvLayers = envLayersShape[0]
            self.imgNumRows = envLayersShape[1]
            self.imgNumCols = envLayersShape[2]

        else:
            self.numEnvLayers = self.guppyEnvLayers.numEnvLayers
            self.imgNumRows = self.guppyEnvLayers.imgNumRows
            self.imgNumCols = self.guppyEnvLayers.imgNumCols

#        self.imgNumCells = self.imgNumRows * self.imgNumCols
        self.imgNumCells = self.guppyEnvLayers.imgNumCells

        print "\n\n>>>  After genEnvLayers(), self.numEnvLayers = " + str(self.numEnvLayers)
        print "\n>>>                        img is " + str(self.imgNumRows) + " rows by " + str(
            self.imgNumCols) + " cols for total cell ct = " + str(self.imgNumCells)



    #-------------------------------------------------------------------------------

    #---------------------------------------------------------------
    #  Determine the number of true presences for each species.
    #  At the moment, you can specify the number of true presences
    #  drawn for each species either by specifying a count for each
    #  species to be created or by specifying the bounds of a
    #  random fraction for each species.  The number of true
    #  presences will then be that fraction multiplied times the
    #  total number of pixels in the map.
    #---------------------------------------------------------------

    def getNumTruePresencesForEachSpp(self):

        """
        :return:
        """
        if self.variables["PAR.use.random.num.true.presences"]:

        #-------------------------------------------------------------
        #  Draw random true presence fractions and then convert them
        #  into counts.
        #-------------------------------------------------------------

            print "\n\nIn getNumTruePresencesForEachSpp, case: random true pres"

            presmin = self.variables["PAR.min.true.presence.fraction.of.landscape"]
            print "presmin = " + str(presmin)
            print "class (presmin) = " + presmin.__class__.__name__
            presmax = self.variables["PAR.max.true.presence.fraction.of.landscape"]
            print "presmax = " + str(presmax)
            print "class (presmax) = " + presmax.__class__.__name__

            sppTruePresenceFractionsOfLandscape = []
            for k in range(self.numSppToCreate):
                sppTruePresenceFractionsOfLandscape.append( \
                    random.uniform( \
                        self.variables["PAR.min.true.presence.fraction.of.landscape"], \
                        self.variables["PAR.max.true.presence.fraction.of.landscape"]))

            #            for k in range (self.numSppToCreate):
            #                sppTruePresenceFractionsOfLandscape [k] = k
            ##                    random.uniform ( \
            ##                           presmin, \
            ##                           presmax)
            #                sppTruePresenceFractionsOfLandscape [k] = \
            #                    random.uniform ( \
            #                           presmin, \
            #                           presmax)

            print "\n\nsppTruePresenceFractionsOfLandscape = "
            print sppTruePresenceFractionsOfLandscape

            sppTruePresenceCts = \
                [round(self.imgNumCells * fraction) \
                 for fraction in sppTruePresenceFractionsOfLandscape]
            print "\nsppTruePresenceCts = "
            print sppTruePresenceCts

            numTruePresences = sppTruePresenceCts
            print "\nnumTruePresences = "
            pprint(numTruePresences)

        else:

        #--------------------------------------------------
        #  Use non-random, fixed counts of true presences
        #  specified in the yaml file.
        #--------------------------------------------------

        #		numTruePresences = self.variables ["PAR.num.true.presences"]
            numTruePresences = \
                strOfCommaSepNumbersToVec(self.variables["PAR.num.true.presences"])

            print "\n\nIn getNumTruePresencesForEachSpp, case: NON-random true pres"
            print "\n\nnumTruePresences = "
            pprint (numTruePresences)
            ###        print "\nclass (numTruePresences) = '" + class (numTruePresences) + "'"
            ###        print "\nis.vector (numTruePresences) = '" + is.vector (numTruePresences) + "'"
            ###        print "\nis.list (numTruePresences) = '" + is.list (numTruePresences) + "'"
            print "\nlength (numTruePresences) = '" + str(len(numTruePresences)) + "'"
            ###        for (i in 1:length (numTruePresences))
            ###            print "\n\tnumTruePresences [" + str (i) + "] = " + str (numTruePresences[i])

            if len(numTruePresences) != self.numSppToCreate:
                print "\n\nlen(numTruePresences) = '" + \
                      str(len(self.variables["PAR.num.true.presences"])) + \
                      "' but \nnumSppToCreate = '" + numSppToCreate + \
                      "'.\nMust specify same number of presence cts as " + \
                      "species to be created.\n\n"
                os.exit()

        return (numTruePresences)

    #-------------------------------------------------------------------------------

    def genTruePresences(self, numTruePresences):

        allSppTruePresenceLocsXY = []
        #            vector (mode="list", length=self.variables ["PAR.num.spp.to.create"])

        for sppId in range(self.numSppToCreate):
            sppName = 'spp.' + str(sppId)

            #----------------------------------------------------------------
            #  Get dimensions from relative probability matrix to use later
            #  and to make sure everything went ok.
            #----------------------------------------------------------------

            #	normProbMatrix = true.rel.prob.dists.for.spp [[sppId]]
            filename = self.probDistLayersDirWithSlash + \
                       self.trueProbDistFilePrefix + \
                       "." + sppName
            #                            self.variables ["PAR.trueProbDistFilePrefix"] + \
            #                            + '.asc'
            #                                    sep='')
            print "filename = " + filename

            normProbMatrix = gsf.readAscFileToMatrix(filename,
                                                     self.imgNumRows, self.imgNumCols)

            numRows = normProbMatrix.shape[0]      #(dim (normProbMatrix)) [1]
            numCols = normProbMatrix.shape[1]      #(dim (normProbMatrix)) [2]
            numCells = numRows * numCols

            print "\n\nnumRows = " + str(numRows)
            print "numCols = " + str(numCols)
            print "\nnumCells = " + str(numCells)

            #-----------------------------------------------------------------------

            #numTruePresences = [3,5,6]
            r.assign('rNumTruePresences', numTruePresences)

            #probDistLayersDirWithSlash = '/Users/Bill/tzar/outputdata/Guppy/default_runset/156_Scen_1/MaxentProbDistLayers/'
            r.assign('rProbDistLayersDirWithSlash', self.probDistLayersDirWithSlash)

            #trueProbDistFilePrefix = 'true.prob.dist'
            r.assign('rTrueProbDistFilePrefix', self.trueProbDistFilePrefix)
            #            r.assign ('rTrueProbDistFilePrefix', self.variables ["PAR.trueProbDistFilePrefix"])

            #curFullMaxentSamplesDirName = '/Users/Bill/tzar/outputdata/Guppy/default_runset/156_Scen_1/MaxentSamples'
            r.assign('rCurFullMaxentSamplesDirName', self.curFullMaxentSamplesDirName)

            #PARuseAllSamples = False
            r.assign('rPARuseAllSamples', self.PARuseAllSamples)

            #combinedPresSamplesFileName = curFullMaxentSamplesDirName + "/" + "spp.sampledPres.combined" + ".csv"
            r.assign('rCombinedPresSamplesFileName', self.combinedPresSamplesFileName)

            #randomSeed = 1
            r.assign('rRandomSeed', self.randomSeed)

            r("source ('/Users/Bill/D/rdv-framework/projects/guppy/genTruePresencesPyper.R')")
            r(
                'genPresences (rNumTruePresences, rProbDistLayersDirWithSlash, rTrueProbDistFilePrefix, rCurFullMaxentSamplesDirName, rPARuseAllSamples, rCombinedPresSamplesFileName, rRandomSeed)')

            #-----------------------------------------------------------------------

        return allSppTruePresenceLocsXY

    #-------------------------------------------------------------------------------

    def run(self):

            #--------------------------------
            #  Generate environment layers.
            #--------------------------------

        useMattEnvData = True      #  Will add this to the yaml file and Guppy __init__() when finished with testing...
        self.loadEnvLayers(useMattEnvData)
#        print "\nIn Guppy:run:  self.envLayers.__class__.__name__ = '" + self.envLayers.__class__.__name__ + "'"

#               Moved these into the loadEnvLayers() routine.
#         envLayersShape = self.envLayers.shape
#         print "\nenvLayersShape = " + str(envLayersShape)
#
#         self.numEnvLayers = envLayersShape[0]
#         self.imgNumRows = envLayersShape[1]
#         self.imgNumCols = envLayersShape[2]
#         self.imgNumCells = self.imgNumRows * self.imgNumCols
#
#         print "\n\n>>>  After genEnvLayers(), self.numEnvLayers = " + str(self.numEnvLayers)
#         print "\n>>>                        img is " + str(self.imgNumRows) + " rows by " + str(
#             self.imgNumCols) + " cols for total cell ct = " + str(self.imgNumCells)

            #--------------------------------------------
            #  Generate true relative probability maps.
            #--------------------------------------------

        self.trueRelProbDistGen.getTrueRelProbDistsForAllSpp(self)

            #----------------------------
            #  Generate true presences.
            #----------------------------

        print "\n\n+++++\tBefore get.num.true.presences.for.each.spp()\n"

        #  moved from up above.
        numTruePresences = self.getNumTruePresencesForEachSpp()

        print "\n\n+++++\tBefore genTruePresences\n"

        listOfTruePresencesAndXYlocs = self.genTruePresences(numTruePresences)
        #        combinedSppTruePresencesTable = \
        #            listOfTruePresencesAndXYlocs ["combined.spp.true.presences.table"]
        #        allSppTruePresenceLocsXY = \
        #            listOfTruePresencesAndXYlocs ["all.spp.true.presence.locs.x.y"]

            #----------------------------------------------------------------
            #  Run maxent to generate a predicted relative probability map.
            #----------------------------------------------------------------

        maxentSamplesFileName = self.combinedPresSamplesFileName

        print "\n\n+++++\tBefore", "runMaxentCmd", "\n"

        runMaxentCmd(maxentSamplesFileName, \
                     self.maxentOutputDir, \
                     self.doMaxentReplicates, \
                     self.maxentReplicateType, \
                     self.numMaxentReplicates, \
                     self.maxentFullPathName, \
                     self.curFullMaxentEnvLayersDirName, \
                     self.numProcessors, \
                     self.verboseMaxent)

            #----------------------------------------------------------------
            #  Evaluate the results of maxent by comparing its output maps
            #  to the true relative probability maps.
            #----------------------------------------------------------------

        print"\n\n+++++\tBefore" + "evaluateMaxentResults" + "\n"

        ###        evaluateMaxentResults ()
        ###rinterface.set_flushconsole()
        r.assign('rNumSppToCreate', self.numSppToCreate)
        r.assign('rDoMaxentReplicates', self.doMaxentReplicates)
        r.assign('rTrueProbDistFilePrefix', self.trueProbDistFilePrefix)
        r.assign('rShowRawErrorInDist', self.showRawErrorInDist)
        r.assign('rShowAbsErrorInDist', self.showAbsErrorInDist)
        r.assign('rShowPercentErrorInDist', self.showPercentErrorInDist)
        r.assign('rShowAbsPercentErrorInDist', self.showAbsPercentErrorInDist)
        r.assign('rShowTruncatedPercentErrImg', self.showTruncatedPercentErrImg)
        r.assign('rShowHeatmap', self.showHeatmap)
        r.assign('rMaxentOutputDirWithSlash', self.maxentOutputDirWithSlash)
        r.assign('rProbDistLayersDirWithSlash', self.probDistLayersDirWithSlash)
        r.assign('rAnalysisDirWithSlash', self.analysisDirWithSlash)
        r.assign('rUseOldMaxentOutputForInput', self.PARuseOldMaxentOutputForInput)
        r.assign('rWriteToFile', self.writeToFile)
        r.assign('rUseDrawImage', self.useDrawImage)

        r("source ('/Users/Bill/D/rdv-framework/projects/guppy/evaluateMaxentResultsPyper.R')")
        r('evaluateMaxentResults (rNumSppToCreate, rDoMaxentReplicates, \
                rTrueProbDistFilePrefix, rShowRawErrorInDist, rShowAbsErrorInDist, \
                rShowPercentErrorInDist, rShowAbsPercentErrorInDist, \
                rShowTruncatedPercentErrImg, rShowHeatmap, rMaxentOutputDirWithSlash, \
                rProbDistLayersDirWithSlash, rAnalysisDirWithSlash, \
                rUseOldMaxentOutputForInput, rWriteToFile, rUseDrawImage)')
        ###rinterface.get_flushconsole()

#===============================================================================

if __name__ == '__main__':

#  Move to the guppy working directory.
#  NOTE:  This may be an issue in the long run when running under tzar.
#         I need to move there now so that netpbmfile will be found when imported.
#         However, when running under tzar, we will have cd-ed to the tzar directory.
#         Or will we?  Not sure if that move will show up inside this python code...
    guppyDir = '/Users/Bill/D/rdv-framework/projects/guppy/'
    os.chdir(guppyDir)
    print "\nMoved to directory: " + os.getcwd()

    oldStyleTest = False
    if oldStyleTest:
        yamlFile = open("projectparams.yaml", "r")

        projectParams = yaml.load(yamlFile)
        baseParams = projectParams['base_params']
        variables = baseParams['variables']
        outputFiles = baseParams['output_files']
        inputFiles = baseParams['input_files']

        '''
        print "\n===============================\n"
        print "PROJECTPARAMS = \n"
        pprint (projectParams)

        print "\n===============================\n"
        print "BASEPARAMS = \n"
        pprint (baseParams)
        '''

        if verbose:
            print "\n===============================\n"
            print "INPUTFILES = \n"
            pprint(inputFiles)

            print "\n===============================\n"
            print "OUTPUTFILES = \n"
            pprint(outputFiles)


    else:
        pickleFileName = '/Users/Bill/D/rdv-framework/projects/guppy/pickeledGuppyInitializationTestParams.pkl'
        pkl_file = open(pickleFileName, 'rb')
        qualifiedparams = pickle.load(pkl_file)
        variables = pickle.load(pkl_file)
        pkl_file.close()

        if verbose:
            print "\n===============================\n"
            print "qualifiedparams = \n"
            pprint(qualifiedparams)

            print "\n===============================\n"
            print "variables = \n"
            pprint(variables)

            print "\n===============================\n"

    g = Guppy(variables, qualifiedparams)
    print ("\nCreated a Guppy.\n")

    if (verbose):
        print ("-----------------------------\n\nINITIALIZED PARAMS:")
        g.pprintParamValues()

#===============================================================================
