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
# 
# 
# At svn guppy revision 259, have removed the full output echo that was in the next cell for now because it's quite large and I'm not doing anything with it.  If you need to see it, look at svn version 259 of this file (BTL - 2013.07.24).

# <codecell>

import os
from pprint import pprint

verbose = False

class Guppy (object):
    """Overarching class for everything about managing a Guppy run.
    """
    def __init__ (self, constants=None, variables=None, \
                        qualifiedParams=None, runParams=None):
        
        self.constants = constants or {}
        self.variables = variables or {}
        self.qualifiedParams = qualifiedParams or {}
        self.runParams = runParams or {}
        self.curDir = os.getcwd()
        
        if (verbose):
                
            print ("\n-----------------------------\n\nPARAMS AS PASSED IN:")
            self.pprintParamValues()
        
        self.constants ["dirSlash"] = "/"
        self.variables ["test"] = "varTest"
        self.qualifiedParams ["test"] = "qpTest"
        self.runParams ["test"] = "rpTest"

    def pprintParamValues (self):
        print "\n\nconstants ="
        pprint (self.constants)
        print "\n\nvariables ="
        pprint (self.variables)
        print "\n\nqualifiedParams ="
        pprint (self.qualifiedParams)
        print "\n\nrunParams ="
        pprint (self.runParams)
        print "\n\ncurDir =" + self.curDir + "\n\n"
      
#===============================================================================

#  Uncomment "name=main" line and indent following lines when all of this  
#  becomes a full, standalone python file.
#  For now, just want the code below to run automatically on every test 
#  in ipython.
        
#if __name__ == '__main__':    

g = Guppy()
print ("\nCreated a Guppy.\n")

if (verbose):
    print ("-----------------------------\n\nINITIALIZED PARAMS:")
    g.pprintParamValues()
    
#===============================================================================

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

# <markdowncell>

# ---
# 
# ---
# 
# ---

# <headingcell level=3>

# Following code is pulled from netpbm.py file to get some examples of declaring a class etc.  Will delete this stuff after I've figured all that out.

# <codecell>

__version__ = '2013.01.18'
__docformat__ = 'restructuredtext en'
__all__ = ['imread', 'imsave', 'NetpbmFile']


def imread(filename, *args, **kwargs):
    """Return image data from Netpbm file as numpy array.

    `args` and `kwargs` are arguments to NetpbmFile.asarray().

    Examples
    --------
    >>> image = imread('_tmp.pgm')

    """
    try:
        netpbm = NetpbmFile(filename)
        image = netpbm.asarray()
    finally:
        netpbm.close()
    return image


def imsave(filename, data, maxval=None, pam=False):
    """Write image data to Netpbm file.

    Examples
    --------
    >>> image = numpy.array([[0, 1],[65534, 65535]], dtype=numpy.uint16)
    >>> imsave('_tmp.pgm', image)

    """
    try:
        netpbm = NetpbmFile(data, maxval=maxval)
        netpbm.write(filename, pam=pam)
    finally:
        netpbm.close()


class NetpbmFile(object):
    """Read and write Netpbm PAM, PBM, PGM, PPM, files."""

    _types = {b'P1': b'BLACKANDWHITE', b'P2': b'GRAYSCALE', b'P3': b'RGB',
              b'P4': b'BLACKANDWHITE', b'P5': b'GRAYSCALE', b'P6': b'RGB',
              b'P7 332': b'RGB', b'P7': b'RGB_ALPHA'}

    def __init__(self, arg=None, **kwargs):
        """Initialize instance from filename, open file, or numpy array."""
        for attr in ('header', 'magicnum', 'width', 'height', 'maxval',
                     'depth', 'tupltypes', '_filename', '_fh', '_data'):
            setattr(self, attr, None)
        if arg is None:
            self._fromdata([], **kwargs)
        elif isinstance(arg, basestring):
            self._fh = open(arg, 'rb')
            self._filename = arg
            self._fromfile(self._fh, **kwargs)
        elif hasattr(arg, 'seek'):
            self._fromfile(arg, **kwargs)
            self._fh = arg
        else:
            self._fromdata(arg, **kwargs)

    def asarray(self, copy=True, cache=False, **kwargs):
        """Return image data from file as numpy array."""
        data = self._data
        if data is None:
            data = self._read_data(self._fh, **kwargs)
            if cache:
                self._data = data
            else:
                return data
        return deepcopy(data) if copy else data

    def write(self, arg, **kwargs):
        """Write instance to file."""
        if hasattr(arg, 'seek'):
            self._tofile(arg, **kwargs)
        else:
            with open(arg, 'wb') as fid:
                self._tofile(fid, **kwargs)

    def close(self):
        """Close open file. Future asarray calls might fail."""
        if self._filename and self._fh:
            self._fh.close()
            self._fh = None

    def __del__(self):
        self.close()

    def _fromfile(self, fh):
        """Initialize instance from open file."""
        fh.seek(0)
        data = fh.read(4096)
        if (len(data) < 7) or not (b'0' < data[1:2] < b'8'):
            raise ValueError("Not a Netpbm file:\n%s" % data[:32])
        try:
            self._read_pam_header(data)
        except Exception:
            try:
                self._read_pnm_header(data)
            except Exception:
                raise ValueError("Not a Netpbm file:\n%s" % data[:32])

    def _read_pam_header(self, data):
        """Read PAM header and initialize instance."""
        regroups = re.search(
            b"(^P7[\n\r]+(?:(?:[\n\r]+)|(?:#.*)|"
            b"(HEIGHT\s+\d+)|(WIDTH\s+\d+)|(DEPTH\s+\d+)|(MAXVAL\s+\d+)|"
            b"(?:TUPLTYPE\s+\w+))*ENDHDR\n)", data).groups()
        self.header = regroups[0]
        self.magicnum = b'P7'
        for group in regroups[1:]:
            key, value = group.split()
            setattr(self, unicode(key).lower(), int(value))
        matches = re.findall(b"(TUPLTYPE\s+\w+)", self.header)
        self.tupltypes = [s.split(None, 1)[1] for s in matches]

    def _read_pnm_header(self, data):
        """Read PNM header and initialize instance."""
        bpm = data[1:2] in b"14"
        regroups = re.search(b"".join((
            b"(^(P[123456]|P7 332)\s+(?:#.*[\r\n])*",
            b"\s*(\d+)\s+(?:#.*[\r\n])*",
            b"\s*(\d+)\s+(?:#.*[\r\n])*" * (not bpm),
            b"\s*(\d+)\s(?:\s*#.*[\r\n]\s)*)")), data).groups() + (1, ) * bpm
        self.header = regroups[0]
        self.magicnum = regroups[1]
        self.width = int(regroups[2])
        self.height = int(regroups[3])
        self.maxval = int(regroups[4])
        self.depth = 3 if self.magicnum in b"P3P6P7 332" else 1
        self.tupltypes = [self._types[self.magicnum]]

    def _read_data(self, fh, byteorder='>'):
        """Return image data from open file as numpy array."""
        fh.seek(len(self.header))
        data = fh.read()
        dtype = 'u1' if self.maxval < 256 else byteorder + 'u2'
        depth = 1 if self.magicnum == b"P7 332" else self.depth
        shape = [-1, self.height, self.width, depth]
        size = numpy.prod(shape[1:])
        if self.magicnum in b"P1P2P3":
            data = numpy.array(data.split(None, size)[:size], dtype)
            data = data.reshape(shape)
        elif self.maxval == 1:
            shape[2] = int(math.ceil(self.width / 8))
            data = numpy.frombuffer(data, dtype).reshape(shape)
            data = numpy.unpackbits(data, axis=-2)[:, :, :self.width, :]
        else:
            data = numpy.frombuffer(data, dtype)
            data = data[:size * (data.size // size)].reshape(shape)
        if data.shape[0] < 2:
            data = data.reshape(data.shape[1:])
        if data.shape[-1] < 2:
            data = data.reshape(data.shape[:-1])
        if self.magicnum == b"P7 332":
            rgb332 = numpy.array(list(numpy.ndindex(8, 8, 4)), numpy.uint8)
            rgb332 *= [36, 36, 85]
            data = numpy.take(rgb332, data, axis=0)
        return data

    def _fromdata(self, data, maxval=None):
        """Initialize instance from numpy array."""
        data = numpy.array(data, ndmin=2, copy=True)
        if data.dtype.kind not in "uib":
            raise ValueError("not an integer type: %s" % data.dtype)
        if data.dtype.kind == 'i' and numpy.min(data) < 0:
            raise ValueError("data out of range: %i" % numpy.min(data))
        if maxval is None:
            maxval = numpy.max(data)
            maxval = 255 if maxval < 256 else 65535
        if maxval < 0 or maxval > 65535:
            raise ValueError("data out of range: %i" % maxval)
        data = data.astype('u1' if maxval < 256 else '>u2')
        self._data = data
        if data.ndim > 2 and data.shape[-1] in (3, 4):
            self.depth = data.shape[-1]
            self.width = data.shape[-2]
            self.height = data.shape[-3]
            self.magicnum = b'P7' if self.depth == 4 else b'P6'
        else:
            self.depth = 1
            self.width = data.shape[-1]
            self.height = data.shape[-2]
            self.magicnum = b'P5' if maxval > 1 else b'P4'
        self.maxval = maxval
        self.tupltypes = [self._types[self.magicnum]]
        self.header = self._header()

    def _tofile(self, fh, pam=False):
        """Write Netbm file."""
        fh.seek(0)
        fh.write(self._header(pam))
        data = self.asarray(copy=False)
        if self.maxval == 1:
            data = numpy.packbits(data, axis=-1)
        data.tofile(fh)

    def _header(self, pam=False):
        """Return file header as byte string."""
        if pam or self.magicnum == b'P7':
            header = "\n".join((
                "P7",
                "HEIGHT %i" % self.height,
                "WIDTH %i" % self.width,
                "DEPTH %i" % self.depth,
                "MAXVAL %i" % self.maxval,
                "\n".join("TUPLTYPE %s" % unicode(i) for i in self.tupltypes),
                "ENDHDR\n"))
        elif self.maxval == 1:
            header = "P4 %i %i\n" % (self.width, self.height)
        elif self.depth == 1:
            header = "P5 %i %i %i\n" % (self.width, self.height, self.maxval)
        else:
            header = "P6 %i %i %i\n" % (self.width, self.height, self.maxval)
        if sys.version_info[0] > 2:
            header = bytes(header, 'ascii')
        return header

    def __str__(self):
        """Return information about instance."""
        return unicode(self.header)


if sys.version_info[0] > 2:
    basestring = str
    unicode = lambda x: str(x, 'ascii')


# <rawcell>

# if __name__ == "__main__":
#     print "\n\n=====>>>  In __main__  <<<=====\n\n"
#     print "Quitting...\n\n"
# '''    
#         try:
#             pam = NetpbmFile(fname)
#             pam.close()
#         except ValueError as e:
#             print(fname, e)
#             continue
# '''

# <codecell>


