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

from rpy2.robjects import r

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
###    combinedSppPresTable = pd.DataFrame(xyPairs,index=repeatedSppNames,columns=['longitude','latitude'])
    combinedSppPresTable = pd.DataFrame.from_items ([('spp', repeatedSppNames), ('longitude', xyPairs [:,0]), ('latitude', xyPairs [:,1])])
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

# <markdowncell>

# #  Figuring out how to merge species names with xy pairs into a pandas dataframe

# <codecell>

import pandas as pd
import numpy

repeatedSppNames = ['spp.1', 'spp.1', 'spp.2', 'spp.2', 'spp.2', 'spp.3']
df = pd.DataFrame.from_items([('spp', repeatedSppNames), ('longitude', range(6)), ('latitude', range(6))])
print df
df.to_csv('df.csv', index=False)

df2 = pd.DataFrame.from_items ([('spp', repeatedSppNames)])
df2 ['longitude'] = range(6)
print df2

xyPairs = numpy.zeros ((6,2), dtype=int)
print

xyPairs [:,0] = range(6)
print xyPairs

xyPairs [:,1] = range(6)
print xyPairs

xyPairs [:,1] = xyPairs [:,1] + 5
print xyPairs

df3 = pd.DataFrame.from_items ([('spp', repeatedSppNames)])
df3 ['longitude'] = xyPairs [:,0]
df3 ['latitude'] = xyPairs [:,1]
print df3

###  df4 = pd.DataFrame.from_items ([('spp', repeatedSppNames), (['longitude', 'latitude'], xyPairs))
###  print df4
###  
###      Gives
    
###   File "<ipython-input-29-1adeab7d5450>", line 30
###      df4 = pd.DataFrame.from_items ([('spp', repeatedSppNames), (['longitude', 'latitude'], xyPairs))
###                                                                                                     ^
###  SyntaxError: invalid syntax

df5 = pd.DataFrame.from_items ([('spp', repeatedSppNames), ('longitude', xyPairs [:,0]), ('latitude', xyPairs [:,1])])
print "\ndf5 = "
print df5

# <markdowncell>

# #  Test whether rpy2 has installed correctly and is working
# 
# Examples taken from Matloff web page:
# http://heather.cs.ucdavis.edu/~matloff/rpy2.html
# 
# NOTES:
# 
# * Everything seems to work fine except for one line that I have flagged in the code.
# 
# * When a plot is generated, it appears in R's plot window, not in this ipython page.  
#     * Is it possible to make them appear inline here?
#     * Also, that external plot has a beachball when I move the cursor over it and CMD-OPT-ESC tells me that python is hung.  Not sure if this will always happen or if something odd is going on just this one time.

# <codecell>

from rpy2.robjects import r

    #  Generate vectors x and y in R, do a scatter plot, fit a least-squares line, etc.: 
r('x <- rnorm(100)')  # generate x at R
r('y <- x + rnorm(100,sd=0.5)')  # generate y at R
r('plot(x,y)')  # have R plot them
r('lmout <- lm(y~x)')  # run the regression
r('print(lmout)')  # print from R
loclmout = r('lmout') # download lmout from R to Python
print loclmout  # print locally

#-----------------------------------------------------------------------------
    #  This statement generates the error shown below it...
#  print loclmout.r['coefficients']  # print one component
#  ---------------------------------------------------------------------------
#  AttributeError                            Traceback (most recent call last)
#  <ipython-input-5-6dbb6373c865> in <module>()
#        7 loclmout = r('lmout') # download lmout from R to Python
#        8 print loclmout  # print locally
#  ----> 9 print loclmout.r['coefficients']  # print one component
#  
#  AttributeError: 'ListVector' object has no attribute 'r'
#-----------------------------------------------------------------------------

    #  Apply some R operations to some Python variables:

u = range(10)  # set up another scatter plot, this one local
e = 5*[0.25,-0.25]
v = u[:]
for i in range(10): v[i] += e[i]
r.plot(u,v)
r.assign('remoteu',u)  # ship local u to R
r.assign('remotev',v)  # ship local v to R
r('plot(remoteu,remotev)')  # plot there

# <markdowncell>

# #Another example of trying to use rpy2, this time with clustering in R (hclust)
# 
# Taken from:
# http://baoilleach.blogspot.com.au/2007/11/using-r-from-python-best-of-both-worlds.html
# 
# NOTE: This fails for two reasons:  
# 
# - It's using rpy instead of rpy2 (since it's an old article, from 2007), but that's easily fixed by changing the import statement the way that I have done below.  
# 
# - It tries to read in a table called cpOfSimMatrix.txt that's never built or defined anywhere.
# 
# Still, it may be useful to come back and look at this when I do clustering and have a proper input file of my own.

# <codecell>

#from rpy import *
from rpy2.robjects import r

# START OF METHOD 1
hclust = r("""
    a <- read.table("cpOfSimMatrix.txt")
    mydist <- dist(1-a)
    hclust(mydist)
""")
r("rm(a)") # Ends with an error if you leave anything in memory
# END OF METHOD 1

# START OF METHOD 2
set_default_mode(NO_CONVERSION)
a = r.read_table("cpOfSimMatrix.txt")
mydist = r.dist(r["-"](1,a)) # Note the trick for '1-a' here
set_default_mode(BASIC_CONVERSION)
hclust = r.hclust(mydist) # Converts R object to Python dict
# END OF METHOD 2

# START OF METHOD 3 (here's one I created earlier)
r.load(".RData")
hclust = r('myHclust')
# END OF METHOD 3

# <markdowncell>

# #  Testing PypeR installation and execution
# 
# Code below is taken from:
# http://statcompute.wordpress.com/2012/11/29/another-way-to-access-r-from-python-pyper/
# 
# Unfortunately, this is yet another web example where they read the data in but don't provide the data for someone trying to reproduce their run, so it fails as soon as it hits the read_table() line.

# <codecell>

    # LOAD PYTHON PACKAGES 
import pandas as pd
import pyper as pr
 
    # READ DATA
data = pd.read_table("/home/liuwensui/Documents/data/csdata.txt", header = 0)
 
    # CREATE A R INSTANCE WITH PYPER
r = pr.R(use_pandas = True)
 
    # PASS DATA FROM PYTHON TO R
r.assign("rdata", data)
 
    # SHOW DATA SUMMARY
print r("summary(rdata)")

    # LOAD R PACKAGE
r("library(betareg)")

    # ESTIMATE A BETA REGRESSION 
r("m <- betareg(LEV_LT3 ~ SIZE1 + PROF2 + GROWTH2 + AGE + IND3A, data = rdata, subset = LEV_LT3 > 0)")
 
    # OUTPUT MODEL SUMMARY 
print r("summary(m)")
 
    # CALCULATE MODEL PREDICTION 
r("beta_fit <- predict(m, link = 'response')")

    # SHOW PREDICTION SUMMARY IN R
print r("summary(beta_fit)")

    # PASS DATA FROM R TO PYTHON
pydata = pd.DataFrame(r.get("beta_fit"), columns = ["y_hat"])
 
    # SHOW PREDICTION SUMMARY IN PYTHON 
pydata.y_hat.describe()

# <markdowncell>

# #  Testing PypeR using code from the original PypeR paper:
# 
# Xia et al. 2010."PypeR, A Python Package for Using R in Python", Journal of Statistical Software, July 2010, vol 35, code snippet 2, http://www.jstatsoft.org/

# <codecell>

from pyper import *

    #  For a single run of R, the function runR may be used:
outputs = runR("a <- 3; print(a + 5)")
print outputs

    #  or if there is an R script (e.g., “RScript.R”) to run: 
#  runR("source('RScript.R')")

    #  In cases where more interactive operations are involved, 
    #  the better way is to create a Python object - an instance of the class R:
r = R(use_numpy=True)

    #  The function Str4R can be applied to translate Python objects 
    #  to R objects in the form of string. In the following examples, 
    #  a Python list, an iterator, and a string are passed to the 
    #  R child process as vectors, while a NumPy record array is 
    #  converted as an R data frame:

r("a <- %s" %  Str4R([0, 1, 2, 3, 4]) )
r.assign("a", xrange(5) )
r.An_IMPORTANT_Notice = """You CANNOT use dot (.) for a variable
    name in this format, and leading underscore (_) is INVALID
    in any R variable name."""
r["salary"] = numpy.array([(1, "Joe", 35820.0), \
    (2, "Jane", 41235.0), (3, "Kate", 37932.0)], \
    dtype=[("id", "<i4"), ("employee", "|S4"), ("salary", "<f4")] )
print r["salary"]
del r["An_IMPORTANT_Notice"], r.salary

    #  It is also possible to make plots, however the plotting is 
    #  done in the background and the output are saved in a file:
r("png('test.png')")
r("plot(1:5)")
r("dev.off()")

    #  Usage details and more examples can be found in the module 
    #  documents and in the test script (“test.py”) in the 
    #  distribution package.
    

# <markdowncell>

# #  Testing PypeR again
# 
# Using code from test.py file distributed with pyper module.
# 
# On my machine,test.py is in:
# /Users/Bill/anaconda/pkgs/PypeR-1.1.0/test.py
# 
# This whole set of examples actually seems to work for a change...

# <codecell>

import numpy
from pyper import *

myR = R()
a = range(5)

# test simple command
myR.run('a <- 3')
myR('print(a)')

# test parameter conversion
myR('b <- %s' % Str4R(a))

# set variable in R
myR.assign('b', a)
#    or 
myR['b'] = a
#	or
myR.b = a

# get value from R 
# from R variables
b = myR['b']
bb = myR.get('bb', 'No this variable!')
print(b, bb, myR['pi'], myR.pi)
# or from an R expression
print(myR['(2*pi + 3:9)/5'])
del myR.a, myR['b']

# test R list
myR['alst'] = [1, (2, 3, 'any strings'), 4+5j]
print(myR['alst'])

# test plotting
myR('png("abc.png"); plot(1:5); dev.off()')

if has_numpy:
    arange, array, reshape = numpy.arange, numpy.array, numpy.reshape
    # numpy arrays
    # one-dimenstion numpy array will be converted to R vector
    myR['avec'] = arange(5)
    print(myR['avec'])
    # one-dimenstion numpy record array will be converted to R data.framme
    myR['adfm'] = array([(1, 'Joe', 35820.0), (2, 'Jane', 41235.0), (3, 'Kate', 37932.0)], \
            dtype=[('id', '<i4'), ('employee', '|S4'), ('salary', '<f4')])
    print(myR['adfm'])
    # two-dimenstion numpy array will be converted to R matrix
    myR['amat'] = reshape(arange(12), (3, 4)) # a 3-row, 4-column matrix
    print(myR['amat'])
    # numpy array of three or higher dimensions will be converted to R array
    myR['aary'] = reshape(arange(24), (2, 3, 4)) # a 3-row, 4-column, 2-layer array 
    print(myR['aary'])

# test huge data sets and the function runR
a = range(10000) #00)
sa = 'a <- ' + Str4R(a)
rlt = runR(sa)
print(rlt)
print('\nTest passed!\n\n')

# to use an R on remote server, you need to provide correct parameter to initialize the R instance:
# rsrv = R(RCMD='/usr/local/bin/R', host='My_server_name_or_IP', user='username')

# <markdowncell>

# #  Testing PypeR yet again
# 
# Using code from latest version of test.py file distributed with pyper module.
# This one includes pandas support?
# 
# On my machine,test.py is in:
# /Users/Bill/anaconda/pkgs/PypeR-1.1.1/test.py
# Actually, this is where it SHOULD be, but I'm not sure where it actually is...
# At the moment, I have a downloaded version of the tarball in my Downloads directory but it seems to have installed somewhere else.
# 
# This *seems* to run too, though I'm not completely sure about the very last line, i.e., where it prints the values of rlt as a phrase about "try...".  

# <codecell>

from pyper import *

# generate a R instance
r = R()

# disable numpy & pandas in R
r.has_numpy = False
r.has_pandas = False

# run R codes
r.run('a <- 3')
r('a <- 3')
r(['a <- 3', 'b <- a*2', 'print(b)'])
r('png("abc.png"); plot(1:5); dev.off()') # plotting in R

# test parameter conversion
a = range(5)
r('b <- %s' % Str4R(a))

# set variables in R
r.assign('b', a)
r['b'] = a
r.b = a

# get value from R 
b = r['b']
b = r.b
pi = r['pi']
pi = r.pi
# or from a more complex R expression
val = r['(2*pi + 3:9)/5']
# get value from R variables that may not exist
bb = r.get('bb', 'No this variable!')

# delete R variables
del(r.a, r['b'])

# test for more data structure
print('\n\n-------Test without numpy & pandas----------\n')
r.avec = 0, 1, 2, 3, 4
r.alist = [1, (2, 3, 'any strings'), 4+5j]
r('amat <- matrix(0:11, nrow=3, byrow=TRUE)')
r('aary <- array(0:23, dim=c(3,4,2))')
r('adfm <- data.frame(aa=1:3, bb=paste("s", 2:4, sep="-"))')
print('R vector (avec): ' + repr(r.avec))
print('R list (alist): ' + repr(r.alist))
print('R matrix (amat): ' + repr(r.amat))
print('R array (aary): ' + repr(r.aary))
print('R data frame (adfm): ' + repr(r.adfm))

print ('has_numpy = ' + str (has_numpy))
if has_numpy:
    print('\n\n-------Test with numpy----------\n')
    r.has_numpy = True
    arange, array, reshape = numpy.arange, numpy.array, numpy.reshape
    # numpy arrays
    # one-dimenstion numpy array will be converted to R vector
    r.bvec = arange(5)
    # two-dimenstion numpy array will be converted to R matrix
    r.bmat = reshape(arange(12), (3, 4)) # a 3-row, 4-column matrix
    # numpy array of three or higher dimensions will be converted to R array
    r.bary = reshape(arange(24), (2, 3, 4)) # a 3-row, 4-column, 2-layer array 
    # one-dimenstion numpy record array will be converted to R data.framme
    r.bdfm = array([(1, 'Joe', 35820.0), (2, 'Jane', 41235.0), (3, 'Kate', 37932.0)], \
            dtype=[('id', '<i4'), ('employee', '|S4'), ('salary', '<f4')])
    print('R vector (avec): ' + repr(r['avec']))
    print('R vector (bvec): ' + repr(r['bvec']))
    print('R matrix (amat): ' + repr(r['amat']))
    print('R matrix (bamat): ' + repr(r['bmat']))
    print('R array (aary): ' + repr(r['aary']))
    print('R array (bary): ' + repr(r['bary']))
    print('R data frame (adfm): ' + repr(r['adfm']))
    print('R data frame (bdfm): ' + repr(r['bdfm']))

if has_pandas:
    print('\n\n-------Test with pandas----------\n')
    r.has_pandas = True
    print('R data frame (adfm): ' + repr(r.adfm))
    if has_numpy:
        print('R data frame (bdfm): ' + repr(r['bdfm']))

# test huge data sets and the function runR
print('\n\n-------Test for huge data sets----------\n')
a = range(10000) #00)
sa = 'a <- ' + Str4R(a)
rlt = runR(sa, Robj=r) # If you want to launch a new R process. use "runR(sa)" or "runR(sa, Robj='path_to_R')" instead.
print(rlt)

print('\nTest passed!\n\n')

del(r) # to eliminate the possible DOS windows

# to use an R on remote server, you need to provide correct parameter to initialize the R instance:
# rsrv = R(RCMD='/usr/local/bin/R', host='My_server_name_or_IP', user='username')


# <codecell>

%run runMaxentCmd

# <codecell>

import autoreload
autoreload?

# <codecell>

import os
import subprocess

maxentExitCode = subprocess.call ("echo Hello World", shell=True)

# <codecell>

#  Derived from:
#      http://stackoverflow.com/questions/1274506/how-can-i-create-a-list-of-files-in-the-current-directory-and-its-subdirectories

import os
import glob

maxentGenOutputDir = '/Users/Bill/tzar/outputdata/Guppy/default_runset/277_Scen_1'
filesToCopyFrom = []
for root, dirs, files in os.walk(maxentGenOutputDir):
    filesToCopyFrom += glob.glob(os.path.join(root, '*.asc'))
    
print "ascs = "
print ascs[0]

    #  Remove the ".asc" suffix.
short = short[0:-4]
print short

short = ascs[0]
print short

#fileRootNames = listFiles (maxentGenOutputDir, '*.asc')
fileRootNames = filesToCopyFrom [:,:-4]
print fileRootNames


#filesToCopyTo = probDistLayersDirWithSlash + prefix + fileRootNames
#filesToCopyTo = probDistLayersDirWithSlash + prefix + fileRootNames


# <codecell>

len(ascs)

# <codecell>

print os.sep

# <codecell>

    #  Derived from:
    #      http://stackoverflow.com/questions/1274506/how-can-i-create-a-list-of-files-in-the-current-directory-and-its-subdirectories
import os
import glob
from pprint import pprint

def listFiles (path = ".", pattern = '*'):
    '''python first approximation to replacement for R function
       list.files().
    '''
    print "In listFiles,\n"
    print "    path = " + path
    print "    pattern = " + str (pattern)
    print
    
    listOfFiles = []
    for root, dirs, files in os.walk (path):
        listOfFiles += glob.glob (os.path.join (root, '*.pyc'))
    return listOfFiles

def test_listFiles ():
    testPath = '/Users/Bill/D/rdv-framework/projects/guppy'
    testPattern = "\*.pyc"
    
    print "current directory = " + os.getcwd() + "\n"
    
    listOfFiles = listFiles ()
    print "listFiles() = \n"
    pprint (listOfFiles)
    print
    
    listOfFiles = listFiles (testPath)
    print "listFiles ('" + testPath + "') = \n"
    pprint (listOfFiles)
    print
    
    listOfFiles = listFiles (testPath, testPattern)
    print "listFiles ('" + testPath + "', '" + testPattern + "') = \n"
    pprint (listOfFiles)
    print
    
test_listFiles()

# <codecell>

import fnmatch
from pprint import pprint

asps = []
for root, dirs, files in os.walk('/Users/Bill/D/rdv-framework/projects/guppy'):
    asps += fnmatch.filter(files, '*.R')
    
pprint (asps)

print len(asps)

prefixAsps = ["pre." + asps[i] for i in range(len(asps))]
pprint (prefixAsps)

# <codecell>

import fnmatch
from pprint import pprint

asps = []
for root, dirs, files in os.walk('/Users/Bill/D/rdv-framework/projects/guppy'):
    asps += fnmatch.filter(files, '*.R')
    
pprint (asps)

print len(asps)

prefixAsps = ["pre." + asps[i] for i in range(len(asps))]
pprint (prefixAsps)

# <codecell>

from pprint import pprint
import os
import glob
import fnmatch
import shutil

#imgSrcDir = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloEnvVars"
imgSrcDir = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloEnvVars"
#imgSrcDir = "/Users/Bill/D/rdv-framework/projects/guppy"

filespec = "*.asc"

filesToCopyFrom = []
for root, dirs, files in os.walk (imgSrcDir):
    filesToCopyFrom += glob.glob (os.path.join (root, filespec))

###        filesToCopyFrom = filesToCopyFrom[[1]]
print "\n\nfilesToCopyFrom = "
pprint (filesToCopyFrom)
print "\n\n"

fileRootNames = []
for root, dirs, files in os.walk (imgSrcDir):
    fileRootNames += fnmatch.filter (files, filespec)

pprint (fileRootNames)

print "\nIn directory: '" + os.getcwd() + "'"

targetDirWithSlash = "./tempTarget/"
#        filesToCopyToPrefix = targetDirWithSlash + prefix
filesToCopyToPrefix = targetDirWithSlash
filesToCopyTo = [filesToCopyToPrefix + fileRootNames[i] for i in range (len(fileRootNames))]
pprint (filesToCopyTo)

#        print "\n\nfilesToCopyTo = "
#        print filesToCopyTo
print "\n\n"

for k in range (len (filesToCopyFrom)):
    shutil.copyfile(filesToCopyFrom [k], filesToCopyTo [k])

print "\n\nDone copying files...\n\n"

# <codecell>

from pprint import pprint
import os
import glob
import fnmatch
import shutil

def copyFiles_Matt (imgSrcDir, filespec, targetDirWithSlash):

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
#        filesToCopyTo = probDistLayersDirWithSlash + prefix + fileRootNames
##        targetDirWithSlash = guppy.probDistLayersDirWithSlash
#####    targetDirWithSlash = "./tempTarget/"
#        filesToCopyToPrefix = targetDirWithSlash + prefix
    filesToCopyToPrefix = targetDirWithSlash
    filesToCopyTo = [filesToCopyToPrefix + fileRootNames[i] for i in range (len(fileRootNames))]
    pprint (filesToCopyTo)
    print "\n\n"


        #  Have src and dest file names now, so copy the files.
    for k in range (len (filesToCopyFrom)):
        shutil.copyfile(filesToCopyFrom [k], filesToCopyTo [k])
    print "\n\nDone copying files...\n\n"

imgSrcDir = "/Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated_ecology/MaxentTests/MattsVicTestLandscape/MtBuffaloEnvVars"
filespec = "*.asc"
targetDirWithSlash = "./tempTarget/"

copyFiles_Matt (imgSrcDir, filespec, targetDirWithSlash)

# <codecell>

#  http://www.adamlaiacano.com/post/14987215771/python-function-for-sampling-from-an-arbitrary-discrete

from numpy.random import uniform
import numpy
import random

def slice_sampler(px, N = 1, x = None):
    """
    Provides samples from a user-defined distribution.
    slice_sampler(px, N = 1, x = None)
    Inputs:
    px = A discrete probability distribution.
    N = Number of samples to return, default is 1
    x = Optional list/array of observation values to return, where prob(x) = px.
     
    Outputs:
    If x=None (default) or if len(x) != len(px), it will return an array of integers
    between 0 and len(px)-1. If x is supplied, it will return the
    samples from x according to the distribution px.
    """
    values = numpy.zeros(N, dtype=numpy.int)
    samples = numpy.arange(len(px))
    px = numpy.array(px) / (1.*sum(px))
    u = uniform(0, max(px))
    for n in xrange(N):
        included = px>=u
        choice = random.sample(range(numpy.sum(included)), 1)[0]
        values[n] = samples[included][choice]
        u = uniform(0, px[included][choice])
    if x:
        if len(x) == len(px):
            x=numpy.array(x)
            values = x[values]
        else:
            print "px and x are different lengths. Returning index locations for px."
    if N == 1:
        return values[0]
    return values

px = [.2, .4, .1, .3]

slice_sampler (px, N=5)
#array([2, 3, 3, 3, 3]) 

slice_sampler(px, N=5, x=[100, 200, 300, 400])
#array([200, 200, 400, 200, 200])

from pylab import *
samples = slice_sampler(px, N=10000, x=[100, 200, 300, 400]) 
hist(samples)
grid()


# <codecell>

from scipy.stats import rv_discrete
from numpy.random import uniform
import numpy
import random
from pylab import *

px = [.2, .4, .1, .3]
x=[100, 200, 300, 400]
N = 10000

samples = rv_discrete (values=(x, px)).rvs(size=N)
hist (samples)
grid()

# <codecell>

import numpy

numTruePresences = numpy.zeros(10)
print numTruePresences
print "len(numTruePresences) = " + str(len(numTruePresences))

numSppToCreate = 5
print "numSppToCreate = " + str(numSppToCreate)

if len (numTruePresences) != numSppToCreate:
    print "they are NOT equal"
else:
    print "they are equal"

# <codecell>

import re

def strOfCommaSepNumbersToVec (numberString):
    '''Take a string of numbers separated by commas or spaces and
    turn it into an array of numbers.'''

        #  Break up the string into a string for each number, then
        #  convert each of these substrings into an integer individually.

    strValues = re.split (r"[, ]", numberString)

    return [int (aNumString) for aNumString in strValues]

numTruePresences = \
    strOfCommaSepNumbersToVec ("10,20,30,40,50,60,70,80,90,100")
print "\n\nIn getNumTruePresencesForEachSpp, case: NON-random true pres"
print "numTruePresences = "
print numTruePresences

###        print "\nclass (numTruePresences) = '" + class (numTruePresences) + "'"
###        print "\nis.vector (numTruePresences) = '" + is.vector (numTruePresences) + "'"
###        print "\nis.list (numTruePresences) = '" + is.list (numTruePresences) + "'"
print "\nlength (numTruePresences) = '" + str (len (numTruePresences)) + "'"
###        for (i in 1:length (numTruePresences))
###            print "\n\tnumTruePresences [" + str (i) + "] = " + str (numTruePresences[i])

if len (numTruePresences) != numSppToCreate:
    print "they are NOT equal"
else:
    print "they are equal"


# <codecell>

import random

random.uniform (0.0002, 0.002)

# <codecell>

import numpy
sppTruePresenceFractionsOfLandscape = []
numSppToCreate = 5
for k in range (numSppToCreate):
    sppTruePresenceFractionsOfLandscape.append ( \
        random.uniform ( \
               0.0002, \
               0.002))
print sppTruePresenceFractionsOfLandscape
                

# <codecell>

            sppTruePresenceFractionsOfLandscape = []
            sppTruePresenceFractionsOfLandscape = \
                [sppTruePresenceFractionsOfLandscape.append ( \
                    random.uniform ( \
                           self.variables ["PAR.min.true.presence.fraction.of.landscape"], \
                           self.variables ["PAR.max.true.presence.fraction.of.landscape"])) \
                 for k in range (self.numSppToCreate)]

# <codecell>

#  Based on:
#      http://pymotw.com/2/csv/#module-csv

import csv
import sys

ascFileName = '/Users/Bill/tzar/outputdata/Guppy/default_runset/152_Scen_1/MaxentProbDistLayers/true.prob.dist.spp.1.asc'
numHeaderLines = 6

f = open(ascFileName, 'rt')
try:
    reader = csv.reader(f, delimiter=' ')
    for k in range (numHeaderLines):
        next (reader)
    ct = 0
    maxCt = 5
    for row in reader:
        if ct < maxCt:
            print "row " + str (ct)
            print row.__class__.__name__
            print len (row)
            print row [0:3]
        ct += 1
finally:
    f.close()

def readAscFileToMatrix (base.asc.filename.to.read, input.dir = "")
  {
##  name.of.file.to.read <- paste (base.asc.filename.to.read, '.asc', sep='')
##  asc.file.as.matrix <-
#####  as.matrix (read.table (paste (input.dir, name.of.file.to.read, sep=''),
##  as.matrix (read.table (paste (input.dir, base.asc.filename.to.read, sep=''),
##	                       skip=6))

  name.of.file.to.read <- paste (base.asc.filename.to.read, '.asc', sep='')

#filename.handed.in = paste (input.dir, base.asc.filename.to.read, sep='')
filename.handed.in = paste (input.dir, name.of.file.to.read, sep='')
cat ("\n\n====>>  In read.asc.file.to.matrix(), \n",
		"\tname.of.file.to.read = '", name.of.file.to.read, "\n",
		"\tbase.asc.filename.to.read = '", base.asc.filename.to.read, "\n",
		"\tinput.dir = '", input.dir, "\n",
		"\tfilename.handed.in = '", filename.handed.in, "\n",
		"\n", sep='')

  asc.file.as.matrix <-
#  as.matrix (read.table (paste (input.dir, base.asc.filename.to.read, sep=''),
  as.matrix (read.table (paste (input.dir, name.of.file.to.read, sep=''),
	                       skip=6))



  return (asc.file.as.matrix)
  }

    

# <codecell>

print csv.list_dialects()

# <codecell>

import numpy
import csv

imgNumRows = imgNumCols = 256

def readAscFileToMatrix (baseAscFilenameToRead, inputDir = ""):

    nameOfFileToRead = baseAscFilenameToRead + ".asc"    #  extension should be made optional...
    filenameHandedIn = inputDir + nameOfFileToRead

    print "\n\n====>>  In read.asc.file.to.matrix(), \n" + \
		"\tnameOfFileToRead = '" + nameOfFileToRead + "\n" + \
		"\tbaseAscFilenameToRead = '" + baseAscFilenameToRead + "\n" + \
		"\tinput.dir = '" + inputDir + "\n" + \
		"\tfilenameHandedIn = '" + filenameHandedIn + "\n"

#  ascFileAsMatrix = \
#      as.matrix (read.table (paste (input.dir, nameOfFileToRead, sep=''),
#	                       skip=6))

    numHeaderLines = 6

    ascFileAsMatrix = numpy.zeros ((imgNumRows, imgNumCols))

        #  Based on:
        #      http://pymotw.com/2/csv/#module-csv
    f = open (filenameHandedIn, 'rt')
    try:
        reader = csv.reader(f, delimiter=' ')
        for k in range (numHeaderLines):
            next (reader)
        ct = 0
        maxCt = 5
        for row in reader:
            ascFileAsMatrix [ct,:] = row
            if ct < maxCt:
                print "row " + str (ct)
                print row.__class__.__name__
                print len (row)
                print row [0:3]
                print ascFileAsMatrix [ct,0:3]
            ct += 1

    finally:
        f.close()

    return ascFileAsMatrix

    
normProbMatrix = readAscFileToMatrix ('true.prob.dist.spp.2', '/Users/Bill/tzar/outputdata/Guppy/default_runset/152_Scen_1/MaxentProbDistLayers/')

print "\nnormProbMatrix.shape = " + str (normProbMatrix.shape)

from rpy2.robjects import r

numCells = imgNumRows * imgNumCols
numTruePresences = [3,5,10]
sppId = 1
r.assign ('rNumCells',numCells)
r.assign ('rNormProbMatrix',normProbMatrix)
r.assign ('rNumTruePresencesSppId', numTruePresences [sppId])
r('cat ("\n\nrNumCells = ", rNumCells, "\nrNumTruePresencesSppId = ", rNumTruePresencesSppId, "\ndim(rNormProbMatrix) = ', dim(rNormProbMatrix), "\n\n")

# <codecell>

x[1,2]

# <codecell>

from rpy2.robjects import r

numTruePresences = [3,5,6]
r.assign ('rNumTruePresences', numTruePresences)

probDistLayersDirWithSlash = '/Users/Bill/tzar/outputdata/Guppy/default_runset/156_Scen_1/MaxentProbDistLayers/'
r.assign ('rProbDistLayersDirWithSlash', probDistLayersDirWithSlash)

trueProbDistFilePrefix = 'true.prob.dist'
r.assign ('rTrueProbDistFilePrefix', trueProbDistFilePrefix)
          
curFullMaxentSamplesDirName = '/Users/Bill/tzar/outputdata/Guppy/default_runset/156_Scen_1/MaxentSamples'
r.assign ('rCurFullMaxentSamplesDirName', curFullMaxentSamplesDirName)

PARuseAllSamples = False
r.assign ('rPARuseAllSamples', PARuseAllSamples)

combinedPresSamplesFileName = curFullMaxentSamplesDirName + "/" + "spp.sampledPres.combined" + ".csv"
r.assign ('rCombinedPresSamplesFileName', combinedPresSamplesFileName)

randomSeed = 1
r.assign ('rRandomSeed', randomSeed)

r("source ('genTruePresencesPyper.R')")
r('genPresences (rNumTruePresences, rProbDistLayersDirWithSlash, rTrueProbDistFilePrefix, rCurFullMaxentSamplesDirName, rPARuseAllSamples, rCombinedPresSamplesFileName, rRandomSeed)')


# <codecell>


