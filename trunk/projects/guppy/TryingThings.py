# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <markdowncell>

# # Using NetpbmFile.
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

# # Shape and summarizing over rows or columns using the "axis=" argument to commands like "median"
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

# # Finding operating system name (aka os or platform)

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

# <markdowncell>

# # Dividing an array (or matrix?) by a constant.

# <codecell>

from numpy import array
a = array([[1., 2., 3.], [4., 5., 6.]])
print "\na = "
print a
c = a / 3
print "\nc = "
print c

# <codecell>

print b.sum()

# <codecell>

print a / b.sum()

# <markdowncell>

# # Normalizing an array

# <codecell>

from numpy import array
a = array([[1., 2., 3.], [4., 5., 6.]])
print "\na = "
print a
c = a / a.sum()
print "\nc = "
print c
print "\nc.sum() = "
print c.sum()

# <codecell>

print a.normalize()

# <codecell>

def normalizeArray (anArray):
    return a / a.sum()
    
from numpy import array
a = array([[1., 2., 3.], [4., 5., 6.]])
print "\na = "
print a

x = normalizeArray (a)

print "\nx = normalizeArray (a) = "
print x

print "\nx.sum() = "
print x.sum()

# <markdowncell>

# # rpy2 experiments

# <codecell>

from rpy2 import r

r('''
print("Hello World!")
''')

# <markdowncell>

# # Trying to figure out how to assign to a slice 
# 
# For example, like you would assign x[,1]=1:10 in R.

# <codecell>

import numpy as np
#x = np.zeros (20, dtype=int)
x = np.zeros ((10,2), dtype=int)
print x
x[:,1] = range(10)
print x

# <markdowncell>

# # Building up genCombinedSppPresTable.py

# <codecell>

import numpy
import random
import pandas as pd

def verbose_xyRelToLowerLeft (n, numRows, numCols):
    """  Verbose form of: Compute the x,y coordinates of a given 
    index into the image array where the index starts with 0 in the 
    UPPER left and goes row by row.  The x,y coordinates that are 
    output (to give to maxent) have their origin in the LOWER left 
    and go row by row upward like a typical x,y plot.
    Also, numbering of the rows and columns in the output considers 
    the origin to be just outside the array, so that the lower left 
    corner of the array is called location [1,1] instead of [0,0].

    This routine is just to explain and test what the non-verbose 
    version does.  You don't want to use it unless there's a problem 
    with the x,y value to investigate.
    """
    print "In xyRelToLowerLeft (" + str (n) + ", " + str (numRows) + ", " + str (numCols) + ")"

    x = (n % numCols) + 1
    print "    x = " + str (x)
    
    rowFromTop = (n // numCols)
    print "    rowFromTop = " + str (rowFromTop)
    y = numRows - rowFromTop
    print "    y = " + str (y)
    
    retVal = [ x, y ]
    print "    retVal = "
    print retVal
    print

    return retVal

    #  NOTE: The R version of this routine seems to have been wrong.
    #        For one thing, it only asked for the number of columns 
    #        rather than both rows and columns, since it assumed that 
    #        the image would be square.
    #        Not sure if everything else about the routine was right.
    #        Needs to be tested if it's going to be used again.  
    #        This routine could be converted back to R, but if so, 
    #        need to modify to account for the fact that python arrays 
    #        start at 0 and R arrays start at 1.
    
def xyRelToLowerLeft (n, numRows, numCols):
    """  Compute the x,y coordinates of a given 
    index into the image array where the index starts with 0 in the 
    UPPER left and goes row by row.  The x,y coordinates that are 
    output (to give to maxent) have their origin in the LOWER left 
    and go row by row upward like a typical x,y plot.
    Also, numbering of the rows and columns in the output considers 
    the origin to be just outside the array, so that the lower left 
    corner of the array is called location [1,1] instead of [0,0].
    """
    return [ (n % numCols) + 1   ,   numRows - (n // numCols) ]
     



def test ():
    numRows = 4
    numCols = 5
    for i in range (20):
        retVal = xyRelToLowerLeft (i, numRows, numCols)
        print str (i) + " : " 
        print retVal
        print

def genCombinedSppPresTable (numImgRows, numImgCols):
    """
    Generate and return a table specifying all true species locations
    (x,y values) for every species.
    The table has 3 columns and each row gives the species ID
    and then the x and y location of a true presence for that species
    (relative to the lower left corner of the map, since that is what
    maxent expects).
    """

    numCells = numImgRows * numImgCols
    
    numSpp = 3    #  self.variables ["PAR.num.spp.to.create"]
    minNumPres = 2    #  self.variables ["PAR.minNumPres"]
    maxNumPres = 5    #self.variables ["PAR.maxNumPres"]

    combinedSppPresTable = None

        #  Randomly choose the number of presences to be generated for 
        #  for each species.
        #  NOTE: Using an array here rather than a list, so that I can 
        #  use the sum() function on the array later.  
        #  Maybe there is something similar for lists, but x.sum() on a 
        #  list gives an error.
    numPresForEachSpp = numpy.zeros (numSpp, dtype=int)
    for sppId in range (numSpp):
        numPresForEachSpp [sppId] = random.randint (minNumPres, maxNumPres)
        
    print "\n\nnumPresForEachSpp = "
    print numPresForEachSpp
    
        #  Compute the total number of presences to be generated.
    totNumPres = numPresForEachSpp.sum()
    print "totNumPres = " + str (totNumPres)
    
        #  Create a species name string for each species.
    sppNames = ['spp.' + str(sppId+1) for sppId in range(numSpp)]
    print "sppNames = "
    print sppNames
    
        #  The table of presences that maxent expects needs each line 
        #  to show the species name and then the x and y coordinates 
        #  of that presence.
        #  Build an array of repeated species names that will become 
        #  the first column of that table.  It will repeat each species 
        #  names so that there is one copy of the name for each presence 
        #  of that species.
    repeatedSppNames = []
    for curSppId in range (numSpp):
        for curPresIdx in range (numPresForEachSpp [curSppId]):
            repeatedSppNames.append (sppNames [curSppId])
            
    print "repeatedSppNames = "
    print repeatedSppNames
    
#    curSppPresIndices = np.zeros (totNumPres, dtype=int)
    curSppPresIndices = []
            #  Unfortunately, can't do it this simply (i.e., directly generating 
            #  the x,y pairs) because that doesn't guarantee that you will 
            #  generate a unique set of points within each species.  
            #  You have to be able to sample without replacement and do it that 
            #  within each species.  So, have to go back to drawing an index 
            #  into the array, without replacement for each species, and then 
            #  convert that into an x,y pair.
    curPresIdx = 0
    for sppIdx in range (numSpp):
        curSppPresIndices.append (random.sample (range (numCells), numPresForEachSpp [sppIdx]))
        
    print curSppPresIndices
    
        #  This command to collapse the list comes from a response at:
        #      http://stackoverflow.com/questions/952914/making-a-flat-list-out-of-list-of-lists-in-python
        #  I have no idea why it works, but it does work...
        #  Three other relevant comments follow that:
        #   	I keep coming back to this question because it just does not make 
        #       enough sense for me to remember it. – Noio Feb 20 at 16:19
        #
        #       Doesn't universally work! 
        #           l=[1,2,[3,4]] [item for sublist in l for item in sublist] 
        #       TypeError: 'int' object is not iterable – Sven Mar 27 at 14:00
        #
        #       @Noio It makes sense if you re-order it: 
        #           [item for item in sublist for sublist in l ]. 
        #       Of course, if you re-order it, then it won't make sense to Python, 
        #       because you're using sublist before you defined what it is. 
        #       – mehaase May 23 at 22:29
    #curSppPresIndices = [item for sublist in curSppPresIndices for item in sublist]

        #  A tiny comment on the same stack overflow page suggested using numpy.concatenate() instead:
        #   	numpy.concatenate seems a bit faster than any of the methods here, 
        #       if you are willing to accept an array. 
        #       – Makoto Jul 19 '12 at 8:04
        #  Since it's actually an array that I want, I've tried that now and it seems to work 
        #  (and be considerably clearer than the list comprehension above, which is also 
        #  referred to in another comment as a "list incomprehension" and amusingly,that remark got 
        #  99 votes so I suspect I'm not alone here..))
    curSppPresIndices = numpy.concatenate (curSppPresIndices)
    
    print "collapsed curSppPresIndices = "
    print curSppPresIndices
    
        #  Now build the array of x,y pairs corresponding to each 
        #  of those presences.  This 2 column array will then be 
        #  joined to the repeated species names above.
    xyPairs = np.zeros ((totNumPres,2), dtype=int)
    print
#    print xyPairs
    
    for k in range (totNumPres):
        xyPairs [k,:] = xyRelToLowerLeft (curSppPresIndices [k], numImgRows, numImgCols)
    print "xyPairs = "
    print xyPairs
    
        #  This is writing column headers to the data frame, but I'm not sure 
        #  if it should be doing that since maxent may not expect it.
    combinedSppPresTable = pd.DataFrame(xyPairs,index=repeatedSppNames,columns=['longitude','latitude'])
#    print combinedSppPresTable
    
    return combinedSppPresTable

random.seed (3) 
testing = False
if testing:
    test()
else:
    x = genCombinedSppPresTable (4, 5)
    print "combinedSppPresTable = "
    print x
    x.to_csv('combinedSppPresTable.csv')

# <codecell>

repeatedSppNames = ['spp.1', 'spp.1', 'spp.2', 'spp.2', 'spp.2', 'spp.3']
df = pd.DataFrame.from_items([('spp', repeatedSppNames), ('longitude', range(6)), ('latitude', range(6))])
print df
df.to_csv('df.csv', index=False)

# <codecell>


