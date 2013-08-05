# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <markdowncell>

# Using NetpbmFile.
# 
# Examples originally derived from __main__ and imread() in netpbmfile.py.

# <codecell>

import numpy
import netpbmfile
import os
from matplotlib import pyplot

print "\nIn directory: '" + os.getcwd() + "'"
filename = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H02/H02_96.256.pgm"
###"H00_1.256.pgm"


if True:
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

_shape = img.shape
if img.ndim > 3 or (img.ndim > 2 and img.shape[-1] not in (3, 4)):    #  I have no idea what second clause is doing here...
    img = img[0]
pyplot.imshow(img, cmap, interpolation='nearest')
pyplot.title("%s\n%s %s %s" % (filename, unicode(netpbm.magicnum),
                              _shape, img.dtype))
pyplot.show()

# <markdowncell>

# Timing and various ?range-style commands
# 
# Originally derived from examples in:  http://stackoverflow.com/questions/10698858/built-in-range-or-numpy-arange-which-is-more-efficient

# <codecell>

import numpy as np

%timeit for i in range(1000000): pass
%timeit for i in np.arange(1000000): pass
%timeit for i in xrange(1000000): pass

# <markdowncell>

# Shape and summarizing over rows or columns using the "axis=" argument to commands like "median"
# 
# Based on:
# http://stackoverflow.com/questions/13753251/median-combining-fits-images-in-python

# <codecell>



import numpy
from pprint import pprint
a = numpy.array([[1,2,3,4],[5,6,7,8]])
b = numpy.array([[11,12,13,14],[15,16,17,18]])
c = numpy.array([[21,22,23,24],[25,26,27,28]])
x = numpy.array([[31,32,33,34],[35,36,37,38]])

#d = numpy.array([a,b,c])
d = numpy.zeros((4,2,4))

pprint (a)
print a.shape
pprint (b)
print b.shape
pprint (c)
print c.shape

pprint (d)
print d.shape

d[0,:,:] = a
d[1,:,:] = b
d[2,:,:] = c
d[3,:,:] = x

print d[1,1,1]
print d[2,0,2]
print d[0,0,3]

pprint (d)
print d.shape

numpy.median (d, axis=0)

# <markdowncell>

# Finding operating system name (aka os or platform)

# <codecell>

import os
print os.name

from sys import platform as _platform

"""
if _platform == "linux" or _platform == "linux2":
    # linux
elif _platform == "darwin":
    # OS X
elif _platform == "win32":
    # Windows...
"""

print _platform

print "_platform startswith linux"
print _platform.startswith ("linux")

print "_platform startswith dar"
print _platform.startswith ("dar")

print "os.name startswith linux"
print os.name.startswith ("linux")

print "os.name startswith posi"
print os.name.startswith ("posi")

print os.uname()

# <codecell>


