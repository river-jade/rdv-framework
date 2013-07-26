# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

import Guppy

# <codecell>

reload(Guppy)

# <codecell>

import sys
if 'Guppy' in sys.modules:  
    del(sys.modules["Guppy"]) 

import Guppy

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
PARnumSppInReserveSelection = variables ['PAR.num.spp.in.reserve.selection']
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

#  Code example bits from netpbm.py
__version__ = '2013.01.18'
#__docformat__ = 'restructuredtext en'
#__all__ = ['imread', 'imsave', 'NetpbmFile']


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


