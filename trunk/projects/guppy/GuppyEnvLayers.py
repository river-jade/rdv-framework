#===============================================================================

#                               GuppyEnvLayers.py

#  History:

#  2013.07.30 - BTL
#  Renamed EnvLayers.py to GuppyEnvLayers.py.

#  2013.07.26 - BTL
#  Created by copying code from guppyBuildEnvLayers.ipynb as saved in the .py
#  version of that notebook.

#===============================================================================

# Dummy setup code to emulate what would have been done by the calling code.

    #  Move to the guppy working directory.
    #  NOTE:  This may be an issue in the long run when running under tzar.
    #         I need to move there now so that netpbmfile will be found when imported.
    #         However, when running under tzar, we will have cd-ed to the tzar directory.
    #         Or will we?  Not sure if that move will show up inside this python code...
import os

guppyDir = '/Users/Bill/D/rdv-framework/projects/guppy/'
os.chdir (guppyDir)
os.getcwd()

import random
import urllib
import shutil
import netpbmfile
import numpy

import GuppyConstants as CONST

from matplotlib import pyplot


os.chdir ("/Users/Bill/D/rdv-framework/projects/guppy/")

#===============================================================================


# BTL - 2013.09.19 - AM IN THE MIDDLE OF GETTING THIS TO WORK AND BE CALLED
# DOWN BELOW WHEN I WANT TO COPY MATTS IMAGES OVER INTO THE MAXENT ENV AREA.
# SEEMS TO WORK OK RIGHT NOW IN THE IPYTHON TEST AREA, BUT NEED TO FIGURE OUT
# WHAT THE WHOLE THING IS ABOUT PREFIXS.  IT WAS IN THERE FOR THE CODE THAT
# THIS WAS CLONED FROM, BUT NOT SURE WHAT THOSE PREFIXS WERE THERE.
# HERE, THEY MAY JUST BE SET TO AN EMPTY STRING BUT STILL NEED TO BE PASSED
# IN THROUGH THE ARGUMENT LIST IF THIS IS GOING TO BE A GENERIC UTILITY FOR
# GUPPY.

# THIS ALSO NEEDS TO BE MODIFIED TO HANDLE THE REMOTE URL LOOKUP CASE.
# IT MAY BE BETTER TO DO THAT AS A SEPARATE FUNCTION, BUT I'LL CHECK THAT
# OUT LATER.  JUST WANT TO GET THIS TO DO SOMETHING FOR THE MOMENT...

        #  This is a utility that will end up elsewhere as well as being used
        #  to replace the code that it was cloned from.
        #  Cloned from GuppyGenTrueRelProbPres.py function getTrueRelProbDistMapsForAllSpp().
        #  Currently (2013.09.19), this code is in the area of lines 269-341.

        #  NOTE:  The file handling logic below is derived from code at:
        #      http://stackoverflow.com/questions/1274506/how-can-i-create-a-list-of-files-in-the-current-directory-and-its-subdirectories

from pprint import pprint
import glob
import fnmatch


def copyFiles_Matt (imgSrcDir = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloEnvVarsSubset", \
                    filespec = "*.asc", \
                    targetDirWithSlash = "./tempTarget/"):

        #  Get a list of the source files to copy from.
        #  The copy command will need the names to have their full path
        #  so include that for each file name retrieved.
    filesToCopyFrom = []
    for root, dirs, files in os.walk (imgSrcDir):
        filesToCopyFrom += glob.glob (os.path.join (root, filespec))
    print "\n\nfilesToCopyFrom = "
    pprint (filesToCopyFrom)
    print "\n\n"


        #  Now, need a list of the destination names for the file copies.
        #  Want the results of the copy to have the same root file names,
        #  so get the source file names without the path prepended.
    fileRootNames = []
    for root, dirs, files in os.walk (imgSrcDir):
        fileRootNames += fnmatch.filter (files, filespec)
    print "\n\nfilesRootnames = "
    pprint (fileRootNames)
    print "\n\n"


        #  Finally, need to prepend those destination names with ?????
######        prefix = self.variables ["PAR.trueProbDistFilePrefix"] + "."
######        print "\n\nprefix = " + prefix


##        targetDirWithSlash = guppy.probDistLayersDirWithSlash
#####    targetDirWithSlash = "./tempTarget/"


#        filesToCopyToPrefix = targetDirWithSlash + prefix
    filesToCopyToPrefix = targetDirWithSlash

#        filesToCopyTo = probDistLayersDirWithSlash + prefix + fileRootNames
    filesToCopyTo = [filesToCopyToPrefix + fileRootNames[i] for i in range (len(fileRootNames))]
    pprint (filesToCopyTo)
    print "\n\n"


        #  Have src and dest file names now, so copy the files.
    for k in range (len (filesToCopyFrom)):
        shutil.copyfile(filesToCopyFrom [k], filesToCopyTo [k])
    print "\n\nDone copying files...\n\n"

#===============================================================================

class GuppyEnvLayers (object):
    """Support for managing, getting, and/or building environment
    layers for a Guppy run.
    """

    #---------------------------------------------------------------------------

    def __init__ (self, curFullMaxentEnvLayersDirName, useRemoteEnvDir, envLayersDir, \
                        numEnvLayers, imgNumRows, imgNumCols):

        print ("\n__init__ routine for GuppyEnvLayers class.\n")

        self.curFullMaxentEnvLayersDirName = curFullMaxentEnvLayersDirName
        print "\n====>  IN GuppyEnvLayers INIT:  self.curFullMaxentEnvLayersDirName = '" + self.curFullMaxentEnvLayersDirName + "'"

        self.useRemoteEnvDir = useRemoteEnvDir
        self.envLayersDir = envLayersDir

        self.numEnvLayers = numEnvLayers
        self.imgNumRows = imgNumRows
        self.imgNumCols = imgNumCols
        self.imgNumCells = self.imgNumRows * self.imgNumCols

        self.keepEnvLayersInMem = False
        if (self.keepEnvLayersInMem):
            self.envLayers = numpy.zeros ((self.numEnvLayers, self.imgNumRows, self.imgNumCols))


#===============================================================================

class GuppyMattEnvLayers (GuppyEnvLayers):
    """Support for managing, getting, and/or building environment
    layers based on Matt's Mt Buffalo images for a Guppy run.
    """

    #---------------------------------------------------------------------------

    def __init__ (self, curFullMaxentEnvLayersDirName, \
                        useRemoteEnvDir, envLayersDir, \
                        numEnvLayers, imgNumRows, imgNumCols):

        print ("\n__init__ routine for GuppyMattEnvLayers class.\n")

        super (GuppyMattEnvLayers, self).__init__ (curFullMaxentEnvLayersDirName, \
                        useRemoteEnvDir, envLayersDir, \
                        numEnvLayers, imgNumRows, imgNumCols)

    #---------------------------------------------------------------------------

       # Define the higher level function that gets the environment layers.

    def genEnvLayers (self):

#        imgSrcDir = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloEnvVarsSubset/"
        imgSrcDir = self.envLayersDir
        targetDirWithSlash = self.curFullMaxentEnvLayersDirName + CONST.dirSlash

            #  NOTE:  THIS DOESN'T WORK FOR REMOTE (URL) FILES YET...

        copyFiles_Matt (imgSrcDir, "*.asc", targetDirWithSlash)

#===============================================================================

class GuppyFractalEnvLayers (GuppyEnvLayers):
    """Support for managing, getting, and/or building environment
    layers based on Alex's fractal images for a Guppy run.
    """

    #---------------------------------------------------------------------------

    def __init__ (self, curFullMaxentEnvLayersDirName, \
                        useRemoteEnvDir, envLayersDir, \
                        numEnvLayers, imgNumRows, imgNumCols, \
                        fileSizeSuffix):

        print ("\n__init__ routine for GuppyFractalEnvLayers class.\n")

        super (GuppyFractalEnvLayers, self).__init__ (curFullMaxentEnvLayersDirName, \
                        useRemoteEnvDir, envLayersDir, \
                        numEnvLayers, imgNumRows, imgNumCols)

        self.keepEnvLayersInMem = False
        if (self.keepEnvLayersInMem):
            self.envLayers = numpy.zeros ((self.numEnvLayers, self.imgNumRows, self.imgNumCols))

        self.fileSizeSuffix = fileSizeSuffix

        self.minH = 1
        #	self.maxH = 10       #  For some reason I didn't create .256 images for H=10.
        self.maxH = 9

        self.minImgNum = 1
        self.maxImgNum = 100

        self.envSrcDir = None

    #---------------------------------------------------------------------------

    def buildEnvLayerOutputPrefix (self, curEnvLayerIdx):

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

        idxString = ('0' + str (curEnvLayerIdx)) if (curEnvLayerIdx < 10) else str (curEnvLayerIdx)
        eLayerFileNamePrefix = "e" + idxString + "_"
        print "\n\neLayerFileNamePrefix = '" + eLayerFileNamePrefix + "'"
        return eLayerFileNamePrefix

    #---------------------------------------------------------------------------

    def buildImgFilenameRoot (self):

            #  Choose an H level at random.
            #  H is the factor that controls the amount of spatial autocorrelation in
            #  Alex's fractal landscape images.
            #  Also need to convert the H value to a string to be used in file names.
            #  If the value is a single digit, then it needs a 0 in front of it to
            #  make file names line up in listings for easier reading.

        H = random.randint (self.minH, self.maxH)
        Hstring = ('0'+ str (H)) if (H < 10) else str (H)

        self.envSrcDir = self.envLayersDir + Hstring + CONST.dirSlash
        print "\n\nself.envSrcDir = '" + self.envSrcDir + "'\n"

        imgNum = random.randint (self.minImgNum, self.maxImgNum)
        imgFileRoot = "H" + Hstring + "_" + str (imgNum)

        return imgFileRoot

    #---------------------------------------------------------------------------

    def loadCurPgmEnvLayerToMem (self, fullImgFileDestPath, \
                                    displayImagesOnScreen = False):
            #--------------------------------------------------------------
            #  Now have the file copied to local work area.
            #  Need to load the image into an array.
            #  Only do this if it's a pgm since the pgm and asc file
            #  will contain the same image and we know how to read a pgm.
            #
            #  Note that only a couple of lines below are actually doing
            #  anything relevant.  The rest are there to print things
            #  for debugging purposes and can be removed later.
            #--------------------------------------------------------------

        print "\n\nimgTypeSuffix is .pgm so adding env.layer\n"

        print "\nIn directory: '" + os.getcwd() + "'"
        filename = fullImgFileDestPath
##                "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H02/H02_96.256.pgm"
        print "\npgm file to read = '" + filename + "'"

        if False:
            img = netpbmfile.imread (filename)
            cmap = 'gray'
        else:
            try:
                netpbm = netpbmfile.NetpbmFile(filename)
                img = netpbm.asarray()
                netpbm.close()
                cmap = 'gray' if netpbm.maxval > 1 else 'binary'
            except ValueError as e:
                print(filename, e)
            #    continue    #  only do this if reading through a loop of filenames and you want to jump over the display logic below

        print "    img.ndim = '" + str(img.ndim) + "'"
        print "    img.shape = '" + str(img.shape) + "'"

        if displayImagesOnScreen:
            _shape = img.shape
            if img.ndim > 3 or (img.ndim > 2 and img.shape[-1] not in (3, 4)):    #  I have no idea what second clause is doing here...
                img = img[0]
            pyplot.imshow(img, cmap, interpolation='nearest')
            pyplot.title("%s\n%s %s %s" % (filename, unicode(netpbm.magicnum),
                                          _shape, img.dtype))
            pyplot.show()

        return img

    #---------------------------------------------------------------------------

       # Define the higher level function that gets the environment layers.

    def genEnvLayers_Matt (self):

        imgSrcDir = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloEnvVarsSubset/"
        targetDirWithSlash = self.curFullMaxentEnvLayersDirName + CONST.dirSlash

        copyFiles_Matt (imgSrcDir, "*.asc", targetDirWithSlash)

    #---------------------------------------------------------------------------

       # Define the higher level function that gets the environment layers.

    def genEnvLayers (self):

        for curEnvLayerIdx in range (self.numEnvLayers):

            eLayerFileNamePrefix = self.buildEnvLayerOutputPrefix (curEnvLayerIdx)
            print "\n====>  eLayerFileNamePrefix = '" + eLayerFileNamePrefix + "'"

            imgFileRoot = self.buildImgFilenameRoot ()
            print "\n====>  imgFileRoot = '" + imgFileRoot + "'\n"

                #-------------------------------------------------------------------
                #  May want to use the 256x256 images instead of the 1024x1024 images...
                #  http://glass.eres.rmit.edu.au/tzar_input/guppy/AlexFractalData/H01/H01_1.256.asc
                #-------------------------------------------------------------------

            for imgTypeSuffix in [".asc", ".pgm"]:

                    #-----------------------------------------------
                    #  Build the file name and retrieve the file.
                    #  File may be on local disk or on web server.
                    #-----------------------------------------------

                print "\n====>  imgTypeSuffix = '" + imgTypeSuffix + "'\n"
                imgFileName = imgFileRoot + imgTypeSuffix
                print "\n====>  imgFileName = '" + imgFileName + "'"

                print "\n====>  self.curFullMaxentEnvLayersDirName = '" + self.curFullMaxentEnvLayersDirName + "'"
                print "\n====>  CONST.dirSlash = '" + CONST.dirSlash + "'"
                print '\n====>  self.curFullMaxentEnvLayersDirName = ', self.curFullMaxentEnvLayersDirName
                fullImgFileDestPath = self.curFullMaxentEnvLayersDirName + \
                                        CONST.dirSlash + \
                                        eLayerFileNamePrefix + imgFileName
                print "\n\nfullImgFileDestPath = '" + fullImgFileDestPath +  "'"

                srcImgFileName = imgFileRoot + self.fileSizeSuffix + imgTypeSuffix
                srcFile = self.envSrcDir + srcImgFileName
                print "\nsrcFile = '" + srcFile + "'"

                    #--------------------------------------------------
                    #  Copy file from url to fullImgFileDestPath
                    #  or from local directory to fullImgFileDestPath
                    #  as specified by user option.
                    #--------------------------------------------------

                if self.useRemoteEnvDir:
                    urllib.urlretrieve (srcFile, fullImgFileDestPath)
                else:
                    shutil.copy (srcFile, fullImgFileDestPath)

                    #--------------------------------------------------
                    #  Add the current environment layer to the stack of them
                    #  in memory if you're saving them and it's a pgm file.
                    #
                    #  This is really just a vestigial thing at the moment.
                    #  I'm only keeping it now in case there was something
                    #  that I DID need it for and just can't remember it.
                    #  However, I think that everything is currently done
                    #  by having maxent work on the envLayer files rather
                    #  than on the layers themselves, so there is no need
                    #  to read them in.
                    #--------------------------------------------------

                if (self.keepEnvLayersInMem and (imgTypeSuffix == ".pgm")):
                    newEnvLayer = self.loadCurPgmEnvLayerToMem (fullImgFileDestPath)
                    self.envLayers [curEnvLayerIdx, :, :] = newEnvLayer


    #---------------------------------------------------------------------------
    #---------------------------------------------------------------------------

    # Test the function that gets the prefix for the name of the input environment layers directory.

    # Not sure this test code is worth it since it's much longer than the original function, which does almost nothing, but it gives me a bit of practice in preparation for trying to use python's unit testing classes.

    #    Tests for the getEnvLayersDirPrefix() function.
    #
    #    Normally you would set args to this call:
    #        getEnvLayersDirPrefix (variables, useRemoteEnvDir, o.n)
    #
    #    something like this:
    #        useRemoteEnvDir = variables ["PAR.useRemoteEnvDir"]
    #        curOS = os.name
    #
    #    But I set them by hand here to test all variants of the call.

        #  Helper function for these tests since they all do nearly the same thing.
    def testHelper_getEnvLayersDirPrefix (osNameString, useRemoteEnvDir, curOS):
        envLayersDirPrefix = getEnvLayersDirPrefix (variables, useRemoteEnvDir, curOS)
        print "\n" + osNameString + "envLayersDirPrefix = " + envLayersDirPrefix
        return envLayersDirPrefix

        #  Test for MAC local copy.
    def test_getEnvLayersDirPrefix_mac ():
        envLayersDirPrefix = testHelper_getEnvLayersDirPrefix ("MAC", False, CONST.macOSname)
        assert envLayersDirPrefix == variables ['PAR.localEnvDirMac']
###    test_getEnvLayersDirPrefix_mac ()

        #  Test for Windows local copy.
    def test_getEnvLayersDirPrefix_windows ():
        envLayersDirPrefix = testHelper_getEnvLayersDirPrefix ("WIN", False, CONST.windowsOSname)
        assert envLayersDirPrefix == variables ['PAR.localEnvDirWin']
###    test_getEnvLayersDirPrefix_windows ()

        #  Test for download from web server.
    def test_getEnvLayersDirPrefix_remote ():
        envLayersDirPrefix = testHelper_getEnvLayersDirPrefix ("REMOTE", True, CONST.macOSname)
        assert envLayersDirPrefix == variables ['PAR.remoteEnvDir']
###    test_getEnvLayersDirPrefix_remote ()

#===============================================================================

