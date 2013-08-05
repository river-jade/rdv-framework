# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

#===============================================================================
#  This bar is just here to show the 80 character margin since I can't currently
#  see a way to do that in ipython itself.
#===============================================================================

# <headingcell level=2>

# Dummy setup code to emulate what would have been done by the calling code.

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

# <codecell>

import random
import urllib
import os
import shutil
import netpbmfile

dirSlash = "/"    #  How does python sense this for each OS?
					#  Should this be in the yaml file?

CONSTwindowsOSnameInR = "mingw32"
CONSTwindowsOSnameInPython = "os2"		#  NOT SURE ABOUT THIS...
										  #  SEE os.name variable in python documentation
CONSTwindowsOSname = CONSTwindowsOSnameInPython

CONSTmacOSname = "posix"

os.chdir ("/Users/Bill/D/rdv-framework/projects/guppy/")

#  NOTE the difference between the mac path in R and in python.
#       In R, you need the backslash in front of the spaces, but in python,
#       the backslash can't be there.

#			 "PAR.localEnvDirMac" : "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H",
variables = { "PAR.useRemoteEnvDir" : False,
				"PAR.localEnvDir" : "/Users/Bill/D/Projects_RMIT/",
				"PAR.localEnvDirMac" : "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H",
				"PAR.localEnvDirWin" : "Z:/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H",
				"PAR.remoteEnvDir" : "http://glass.eres.rmit.edu.au/tzar_input/guppy/AlexFractalData/H",
                "PAR.numEnvLayers" : 2 }

#----------------------

outputFiles = { 'PAR.current.run.directory' : "xxx" }

PAR.current.run.directory = outputFiles ['PAR.current.run.directory']
print "\nPAR.current.run.directory = '" + PAR.current.run.directory + "'"

#---------------------

cur.full.maxent.env.layers.dir.name = PAR.current.run.directory + variables ['PAR.maxent.env.layers.base.name']

print "\ncur.full.maxent.env.layers.dir.name = '" + cur.full.maxent.env.layers.dir.name + "'"

if (not file.exists (cur.full.maxent.env.layers.dir.name)):    #  PYTHON file and dir commands here???
	dir.create (cur.full.maxent.env.layers.dir.name)           #  shutils???  os???

#---------------------

print "\nvariables ['PAR.useRemoteEnvDir'] = " + variables ['PAR.useRemoteEnvDir']
print "variables ['PAR.remoteEnvDir'] = " + variables ['PAR.remoteEnvDir']
print "variables ['PAR.localEnvDirMac'] = " + variables ['PAR.localEnvDirMac']
print "variables ['PAR.localEnvDirWin'] = " + variables ['PAR.localEnvDirWin']

# <headingcell level=3>

# Constants that will probably become instance variables when I turn this into a class.

# <codecell>

minH = 1
#	maxH = 10       #  For some reason I didn't create .256 images for H=10.
maxH = 9
minImgNum = 1
maxImgNum = 100

# <headingcell level=2>

# Define a function to get the prefix of the input directory holding the environment layers.

# <codecell>

def getEnvLayersDirPrefix (variables, useRemoteEnvDir, curOS):
    if (useRemoteEnvDir):
       envLayersDir = variables ['PAR.remoteEnvDir']
    elif (curOS == CONSTwindowsOSname):
       envLayersDir = variables ['PAR.localEnvDirWin']
    else:
       envLayersDir = variables ['PAR.localEnvDirMac']
    
    return envLayersDir

# <headingcell level=2>

# Test the function that gets the prefix for the name of the input environment layers directory.

# <headingcell level=4>

# Not sure this test code is worth it since it's much longer than the original function, which does almost nothing, but it gives me a bit of practice in preparation for trying to use python's unit testing classes.

# <codecell>

#    Tests for the getEnvLayersDirPrefix() function.
#
#    Normally you would set args to this call:
#        getEnvLayersDirPrefix (variables, useRemoteEnvDir, curOS)
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
    envLayersDirPrefix = testHelper_getEnvLayersDirPrefix ("MAC", False, CONSTmacOSname)
    assert envLayersDirPrefix == variables ['PAR.localEnvDirMac']
test_getEnvLayersDirPrefix_mac ()

    #  Test for Windows local copy.
def test_getEnvLayersDirPrefix_windows ():
    envLayersDirPrefix = testHelper_getEnvLayersDirPrefix ("WIN", False, CONSTwindowsOSname)
    assert envLayersDirPrefix == variables ['PAR.localEnvDirWin']
test_getEnvLayersDirPrefix_windows ()

    #  Test for download from web server.
def test_getEnvLayersDirPrefix_remote ():
    envLayersDirPrefix = testHelper_getEnvLayersDirPrefix ("REMOTE", True, CONSTmacOSname)
    assert envLayersDirPrefix == variables ['PAR.remoteEnvDir']
test_getEnvLayersDirPrefix_remote ()

# <headingcell level=3>

# Define a function to build the prefix of the output environment layers.

# <codecell>

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

def buildEnvLayerOutputPrefix (curEnvLayerIdx):
    idxString = ('0' + str (curEnvLayerIdx)) if (curEnvLayerIdx < 10) else str (curEnvLayerIdx)

    eLayerFileNamePrefix = "e" + idxString + "_"

    print "\n\neLayerFileNamePrefix = '" + eLayerFileNamePrefix + "'"
    
    return eLayerFileNamePrefix


# <headingcell level=2>

# Define function to build the image filename root.

# <codecell>

			#  Choose an H level at random.
			#  H is the factor that controls the amount of spatial autocorrelation in
			#  Alex's fractal landscape images.
			#  Also need to convert the H value to a string to be used in file names.
			#  If the value is a single digit, then it needs a 0 in front of it to
			#  make file names line up in listings for easier reading.

def buildImgFilenameRoot (envLayersDir):            
    H = random.randint (minH, maxH)
    Hstring = ('0'+ str (H)) if (H < 10) else str (H)

    #----------

    envSrcDir = envLayersDir + Hstring + dirSlash
    print "\n\nenvSrcDir = '" + envSrcDir + "'\n"

    #----------

    imgNum = random.randint (minImgNum, maxImgNum)
    imgFileRoot = "H" + Hstring + "_" + str (imgNum)

    #----------

    return imgFileRoot

# <codecell>

envLayersDir = "xxx/"
imgFileRoot = buildImgFilenameRoot (envLayersDir)
print "\nimgFileRoot = " + imgFileRoot

# <headingcell level=2>

# Define the higher level function that gets the environment layers.

# <codecell>

def genEnvLayers (variables):

    envLayersDir = getEnvLayersDirPrefix (variables)

    numEnvLayers = variables ['PAR.numEnvLayers']
    print "\n\nnumEnvLayers = '" + str (numEnvLayers) + "'"

    envLayers = [None] * numEnvLayers

    for curEnvLayerIdx in range (numEnvLayers): 
        
        eLayerFileNamePrefix = buildEnvLayerOutputPrefix (curEnvLayerIdx)

                #----------

        imgFileRoot = buildImgFilenameRoot (envLayersDir)

		

# <codecell>


			#-------------------------------------------------------------------
			#  May want to use the 256x256 images instead of the 1024x1024 images...
			#  http://glass.eres.rmit.edu.au/tzar_input/guppy/AlexFractalData/H01/H01_1.256.asc
			#-------------------------------------------------------------------

		for suffix in [".asc", ".pgm"]:

				#-----------------------------------------------
				#  Build the file name and retrieve the file.
				#  File may be on local disk or on web server.
				#-----------------------------------------------

			imgFileName = imgFileRoot + suffix
			fullImgFileDestPath = curFullMaxentEnvLayersDirName + dirSlash + \
										 eLayerFileNamePrefix + imgFileName
			print "\n\nfullImgFileDestPath = '" + fullImgFileDestPath +  "'"

			srcImgFileName = imgFileRoot + variables ['PAR.fileSizeSuffix'] + suffix
			srcFile = envSrcDir + srcImgFileName
			print "\nsrcFile = '" + srcFile + "'"

				#--------------------------------------------------
				#  Copy file from url to fullImgFileDestPath
				#  or from local directory to fullImgFileDestPath
				#  as specified by user option.
				#--------------------------------------------------

			if useRemoteEnvDir:
				urllib.urlretrieve (srcFile, fullImgFileDestPath)
			else:
				shutil.copy (srcFile, fullImgFileDestPath)

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

			print "\n\nsuffix = '" + suffix + "'\n"
#			if (suffix == ".pnm"):
			if (suffix == ".pgm"):
				print "\n\nsuffix is .pnm so adding env.layer\n"
				print "\nlen (env.layers) before = '", len (env.layers)

#  NEEDS REPLACEMENT WITH NETPBM CODE IN PYTHON.
				new.env.layer = get.img.matrix.from.pnm (fullImgFileDestPath)	###  PYTHON???

				print "\ndim (new.env.layer) before = '", dim (new.env.layer)	###  PYTHON???
				print "\n\nis.matrix(new.env.layer) in get.img.matrix.from.pnm = '", is.matrix(new.env.layer), "\n"	###  PYTHON???
				print "\n\nis.vector(new.env.layer) in get.img.matrix.from.pnm = '", is.vector(new.env.layer), "\n"	###  PYTHON???
				print "\n\nclass(new.env.layer) in get.img.matrix.from.pnm = '", class(new.env.layer), "\n"	###  PYTHON???

				env.layers [curEnvLayerIdx]= new.env.layer    #  Add to stack.

				print "\nlen (env.layers) AFTER = '", len (env.layers)
#  IS THIS THE CORRECT WAY TO INDEX THE ARRAY RETURNED BY READING THE PGM FILE?
				print "\n\nnew.env.layer [1:3,1:3] = \n", new.env.layer [1:3,1:3], "\n"     #  Echo a bit of the result...	###  PYTHON???
				for (row in 1:3):
					for (col in 1:3):
						print "\nnew.env.layer [", row, ", ", col, "] = ", new.env.layer[row,col], ", and class = ", class(new.env.layer[row,col])	###  PYTHON???
				#print (new.env.layer [1:3,1:3])    #  Echo a bit of the result...	###  PYTHON???

			print '\n curFullMaxentEnvLayersDirName = ', curFullMaxentEnvLayersDirName

	return (env.layers)
"""

# <codecell>

import GuppyConstants
print GuppyConstants.dirSlash

# <codecell>


