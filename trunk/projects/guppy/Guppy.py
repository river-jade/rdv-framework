#===============================================================================

#                                   Guppy.py

#  History:

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

verbose = False

#===============================================================================

import os
from pprint import pprint
import random

    #  For testing only?
import yaml
import pickle

from sys import platform

import GuppyConstants as CONST
import GuppyEnvLayers

#===============================================================================

    #  Note that the function below will need its reference to
    #  tempDontMakeDirsYet removed once that issue is all straightened out.
    #  That variable can just be set to False, but it will be better to wipe
    #  it out altogether when things are working right.

def createDirIfDoesntExist (dirToMake):
    if tempDontMakeDirsYet:
        print "\n====>>>  Would make dir '" + dirToMake + "' now."
    else:
        if not os.path.isdir (dirToMake):
            os.makedirs (dirToMake)

#===============================================================================

class Guppy (object):
    """Overarching class for everything about managing a Guppy run.
    """
    def __init__ (self, variables=None, qualifiedParams=None):

        self.variables = variables or {}
        self.qualifiedParams = qualifiedParams or {}

        self.curDir = os.getcwd()
        self.curOS = platform

        self.envLayersDir = None
        self.numEnvLayers = self.variables ['PAR.numEnvLayers']

        self.imgNumRows = variables ['PAR.imgNumRows']
        self.imgNumCols = variables ['PAR.imgNumCols']
        self.fileSizeSuffix = variables ['PAR.fileSizeSuffix']

        if (verbose):
            print ("\n-----------------------------\n\nPARAMS AS PASSED IN:")
            self.pprintParamValues()

#        self.variables ["test"] = "varTest"
#        self.qualifiedParams ["test"] = "qpTest"

        self.setRandomSeed ()
        self.initNumProcessors ()

        self.useRemoteEnvDir = self.variables ['PAR.useRemoteEnvDir']

        self.curFullMaxentEnvLayersDirName = None
        self.initDirectories ()

        self.envLayers = None

    def setRandomSeed (self):
        randomSeed = self.variables ['PAR.random.seed']
        print "\nrandom.seed = '" + str (randomSeed) + "', class (randomSeed) = '" + randomSeed.__class__.__name__
        random.seed (randomSeed)

    def initNumProcessors (self):
            #---------------------------------------------------
            #  default value for number of processors in the
            #  current machine.
            #  maxent can use this value to speed up some
            #  of its operations by creating more threads.
            #  It's not a necessary thing to set for any other
            #  reason.
            #---------------------------------------------------

        self.PARnumProcessors = self.variables ['PAR.num.processors']
        print "\nPARnumProcessors =", self.PARnumProcessors

    def initDirectories (self):
        self.startingDir = os.getcwd()
        print "\nstartingDir = '" + self.startingDir + "'"

        self.pathToRfiles = self.variables ['PAR.pathToRfiles']
        print "\npathToRfiles = '" + self.pathToRfiles + "'"

        self.PARrdvDirectory = self.variables ['PAR.rdv.directory']
        print "\nPARrdvDirectory = '" + self.PARrdvDirectory + "'"

#        self.PARinputDirectoryFromYaml = self.inputFiles ['PAR.input.directory']
        self.PARinputDirectoryFromYaml = self.qualifiedParams ['PAR.input.directory']
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

        leadChars = self.PARinputDirectoryFromYaml [0:2]
        print "\nleadChars = '" + leadChars + "'"
        if leadChars == "./":
            self.PARinputDirectory = self.PARrdvDirectory + CONST.dirSlash + self.PARinputDirectoryFromYaml [2:]
        else:
            self.PARinputDirectory = self.PARrdvDirectory + CONST.dirSlash + self.PARinputDirectoryFromYaml
            print "\n***********  WARNING  ***********\n" + "    leadChars of PARinputDirectoryFromYaml = '" + leadChars + "' rather than './' so not stripping."
            print "    PARinputDirectory may be messed up." + "\n***********           ***********"
        print "\nPARinputDirectory = '" + self.PARinputDirectory + "'"

        #---------------------
        #  start new
        #---------------------

        PARcurrentRunDirectory = self.qualifiedParams ['PAR.current.run.directory']
        print "\nPARcurrentRunDirectory = '" + PARcurrentRunDirectory + "'"

#  PARcurrentRunDirectory = ''

        #probDistLayersDir = "./MaxentProbDistLayers/"    #7/17#  what we want maxent to generate, i.e., the true layers?
        #PARprobDistLayersDirName = "MaxentProbDistLayers"
        ##probDistLayersDir = paste (PARcurrentRunDirectory, "/",
        ##                              PARprobDistLayersDirName, "/"

        probDistLayersDir = self.qualifiedParams ['PAR.prob.dist.layers.dir.name']
        probDistLayersDirWithSlash = probDistLayersDir + "/"

        print "\nprobDistLayersDir = '" + probDistLayersDir + "'"
        createDirIfDoesntExist (probDistLayersDir)

#  probDistLayersDir = 'MaxentProbDistLayers'
#
#  ====>>>  Would make dir 'MaxentProbDistLayers' now.


        #PARmaxentOutputDirName = "MaxentOutputs"

        maxentOutputDir = self.qualifiedParams ['PAR.maxent.output.dir.name']
        maxentOutputDirWithSlash = maxentOutputDir + CONST.dirSlash

        print "\nmaxentOutputDir = '" + maxentOutputDir + "'"
        createDirIfDoesntExist (maxentOutputDir)

#  maxentOutputDir = 'MaxentOutputs'
#
#  ====>>>  Would make dir 'MaxentOutputs' now.


        #PARmaxentGenOutputDirName = "MaxentGenOutputs"

        maxentGenOutputDir = self.qualifiedParams ['PAR.maxent.gen.output.dir.name']
        maxentGenOutputDirWithSlash = maxentGenOutputDir + "/"

        print "\nmaxentGenOutputDir = '" + maxentGenOutputDir + "'"
        createDirIfDoesntExist (maxentGenOutputDir)

#  maxentGenOutputDir = 'MaxentGenOutputs'
#
#  ====>>>  Would make dir 'MaxentGenOutputs' now.


        #analysisDir = "./ResultsAnalysis/"
        #PARanalysisDirName = "ResultsAnalysis"

##        analysisDirWithSlash = PARcurrentRunDirectory +  CONST.dirSlash + self.variables ['PAR.analysis.dir.name'] + CONST.dirSlash
        analysisDirWithSlash = PARcurrentRunDirectory + self.variables ['PAR.analysis.dir.name'] + CONST.dirSlash
        print "\nanalysisDirWithSlash = '" + analysisDirWithSlash + "'"
        createDirIfDoesntExist (analysisDirWithSlash)

#  analysisDirWithSlash = '/ResultsAnalysis/'
#
#  ====>>>  Would make dir '/ResultsAnalysis/' now.


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
            os.chdir (PARcurrentRunDirectory)

#  ====>>>  Would move to dir '  ' now.

        ##if (!file.exists ("MaxentOutputs"))
        ##    {
        ##    dir.create ("MaxentOutputs")
        ##    }

        self.curFullMaxentEnvLayersDirName = \
            PARcurrentRunDirectory + self.variables ['PAR.maxent.env.layers.base.name']

        print "\n\nself.curFullMaxentEnvLayersDirName = '" + self.curFullMaxentEnvLayersDirName + "'"

        createDirIfDoesntExist (self.curFullMaxentEnvLayersDirName)

#  curFullMaxentEnvLayersDirName = 'MaxentEnvLayers'
#
#  ====>>>  Would make dir 'MaxentEnvLayers' now.


        ##if (not file.exists ("MaxentSamples"))
        ##    {
        ##    dir.create ("MaxentSamples")
        ##    }

        curFullMaxentSamplesDirName = \
            PARcurrentRunDirectory + self.variables ['PAR.maxent.samples.base.name']

        print "\n\ncurFullMaxentSamplesDirName = '" + curFullMaxentSamplesDirName + "'"

        createDirIfDoesntExist (curFullMaxentSamplesDirName)

#  curFullMaxentSamplesDirName = 'MaxentSamples'
#
#  ====>>>  Would make dir 'MaxentSamples' now.

        #       write.to.file : TRUE,
        writeToFile = self.variables ['PAR.write.to.file']

        #         use.draw.image : FALSE,
        useDrawImage = self.variables ['PAR.use.draw.image']

        #         use.filled.contour : TRUE,
        useFilledContour = self.variables ['PAR.use.filled.contour']

                    #  BEWARE: if this is FALSE, the get.env.layers() routine in
                    #          guppy.maxent.functions.v6.R does something vestigial
                    #          that you may not expect (or want) at all !
                    #          Need to fix that.
                    #          BTL - 2011.09.20
                    #  BTL - 2011.10.03 - Is this note even relevant anymore?
                    #                     Looks like this variable isn't even used now.
        #         use.pnm.env.layers : TRUE ,
        usePnmEnvLayers = self.variables ['PAR.use.pnm.env.layers']



        combinedSppTruePresencesTable = None        #  correct Null for PYTHON ???
        combinedSppSampledPresencesTable = None


        PARnumSppToCreate = self.variables ['PAR.num.spp.to.create']
        PARnumSppInReserveSelection = self.variables ['PAR.num.spp.in.reserve.selection']
        PARuseOldMaxentOutputForInput = self.variables ['PAR.use.old.maxent.output.for.input']


        PARuseAllSamples = self.variables ['PAR.use.all.samples']


        CONST.productRule = self.variables ['CONST.product.rule']
        CONST.addRule = self.variables ['CONST.add.rule']


        combinedPresSamplesFileName = curFullMaxentSamplesDirName + CONST.dirSlash + \
                                'spp.sampledPres.combined.csv'
        print "\n\ncombinedPresSamplesFileName = '" + combinedPresSamplesFileName + "'\n\n"

#  combinedPresSamplesFileName = 'MaxentSamples/spp.sampledPres.combined.csv'



        PARpathToMaxent = self.variables ['PAR.path.to.maxent']
        print "\n\nPARpathToMaxent = '" + PARpathToMaxent + "'"

        maxentFullPathName = self.startingDir + CONST.dirSlash + PARpathToMaxent + CONST.dirSlash + 'maxent.jar'

        print "\n\nmaxentFullPathName = '" + maxentFullPathName, "'"

#  PARpathToMaxent = 'lib/maxent'
#
#
#  maxentFullPathName = '/Users/Bill/D/rdv-framework/projects/guppy/lib/maxent/maxent.jar '



        #  Look at this ipython notebook under the Subplots heading to see the
        #  matplotlib way to do this.
        #      http://nbviewer.ipython.org/urls/raw.github.com/swcarpentry/notebooks/master/matplotlib.ipynb

        #####    par (mfrow=c(2,2))


        #---------------------
        #  end new
        #---------------------

        #---------------------
        #  start newer
        #---------------------

###        curFullMaxentEnvLayersDirName = PARcurrentRunDirectory + self.variables ['PAR.maxent.env.layers.base.name']
###        print "\ncurFullMaxentEnvLayersDirName = '" + curFullMaxentEnvLayersDirName + "'"
###        createDirIfDoesntExist (curFullMaxentEnvLayersDirName)

            #  NOTE the difference between the mac path in R and in python.
            #       In R, you need the backslash in front of the spaces, but in python,
        print "\nvariables ['PAR.useRemoteEnvDir'] = " + str (self.variables ['PAR.useRemoteEnvDir'])
        print "variables ['PAR.remoteEnvDir'] = " + self.variables ['PAR.remoteEnvDir']
        print "variables ['PAR.localEnvDirMac'] = " + self.variables ['PAR.localEnvDirMac']
        print "variables ['PAR.localEnvDirWin'] = " + self.variables ['PAR.localEnvDirWin']

###        if (self.variables ['PAR.useRemoteEnvDir']):
        if (self.useRemoteEnvDir):
           self.envLayersDir = self.variables ['PAR.remoteEnvDir']
        elif (self.curOS == CONST.windowsOSname):
           self.envLayersDir = self.variables ['PAR.localEnvDirWin']
        else:
           self.envLayersDir = self.variables ['PAR.localEnvDirMac']
        print "\nenvLayersDir = '" + self.envLayersDir + "'"



        #---------------------
        #  end newer
        #---------------------

    def pprintParamValues (self):
        print "\n\nvariables ="
        pprint (self.variables)
        print "\n\nqualifiedParams ="
        pprint (self.qualifiedParams)
        print "\n\nself.curDir = " + self.curDir
        print "\n\nself.curOS = " + self.curOS
        print "\n\nself.envLayersDir = " + self.envLayersDir + "'"
        print "\n\nnumEnvLayers = '" + str (self.numEnvLayers) + "'"
        print "\n\nfileSizeSuffix = '" + self.fileSizeSuffix + "'"

    def loadEnvLayers (self):
        print "\n====>  IN loadEnvLayers:  self.curFullMaxentEnvLayersDirName = '" + self.curFullMaxentEnvLayersDirName + "'"

        self.guppyEnvLayers = GuppyEnvLayers.GuppyFractalEnvLayers (self.curFullMaxentEnvLayersDirName, \
                        self.useRemoteEnvDir, \
                        self.envLayersDir, \
                        self.numEnvLayers, self.fileSizeSuffix, \
                        self.imgNumRows, self.imgNumCols)

        self.envLayers = self.guppyEnvLayers.genEnvLayers()

        print "\nIn Guppy:loadEnvLayers:  self.envLayers.__class__.__name__ = '" + self.envLayers.__class__.__name__ + "'"


    def run (self):

            #--------------------------------
            #  Generate environment layers.
            #--------------------------------

        self.loadEnvLayers ()
        print "\nIn Guppy:run:  self.envLayers.__class__.__name__ = '" + self.envLayers.__class__.__name__ + "'"


        envLayersShape = self.envLayers.shape
        print "\nenvLayersShape = " + str (envLayersShape)

        numEnvLayers = envLayersShape [0]


        numRows = envLayersShape [1]
        numCols = envLayersShape [2]
        numCells = numRows * numCols
#        imgDimensions = dim (envLayers[[1]])
        imgDimensions = numRows

        print "\n\n>>>  After genEnvLayers(), numEnvLayers = " + str (numEnvLayers)
        print "\n>>>                        imgDimensions = " + str (imgDimensions)
        print "\n>>>                        img is " + str (numRows) + " rows by " + str (numCols) + " cols for total cell ct = " + str (numCells)



#===============================================================================

if __name__ == '__main__':

        #  Move to the guppy working directory.
        #  NOTE:  This may be an issue in the long run when running under tzar.
        #         I need to move there now so that netpbmfile will be found when imported.
        #         However, when running under tzar, we will have cd-ed to the tzar directory.
        #         Or will we?  Not sure if that move will show up inside this python code...
    guppyDir = '/Users/Bill/D/rdv-framework/projects/guppy/'
    os.chdir (guppyDir)
    print "\nMoved to directory: " + os.getcwd()

    oldStyleTest = False
    if oldStyleTest:
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

        if verbose:
            print "\n===============================\n"
            print "INPUTFILES = \n"
            pprint (inputFiles)

            print "\n===============================\n"
            print "OUTPUTFILES = \n"
            pprint (outputFiles)


    else:
        pickleFileName = '/Users/Bill/D/rdv-framework/projects/guppy/pickeledGuppyInitializationTestParams.pkl'
        pkl_file = open (pickleFileName, 'rb')
        qualifiedparams = pickle.load (pkl_file)
        variables = pickle.load (pkl_file)
        pkl_file.close ()

        if verbose:
            print "\n===============================\n"
            print "qualifiedparams = \n"
            pprint (qualifiedparams)

            print "\n===============================\n"
            print "variables = \n"
            pprint (variables)

            print "\n===============================\n"

    g = Guppy (variables, qualifiedparams)
    print ("\nCreated a Guppy.\n")

    if (verbose):
        print ("-----------------------------\n\nINITIALIZED PARAMS:")
        g.pprintParamValues()

#===============================================================================
