# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

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

# <headingcell level=3>

# Example of running a system call from inside ipython

# <codecell>

!ls

# <codecell>

x = !ls

# <codecell>

print x

# <codecell>

pprint (x)

# <codecell>

profile()

# <codecell>

pprint()

# <codecell>

pprint (x)

# <codecell>

pprint()

# <codecell>

from pprint import pprint as ppp

# <codecell>

pprint(x)

# <codecell>

pprint()

# <markdowncell>

# ### Experimenting with netpbm library for reading and writing ppm (pgm) files.

# <codecell>

import netpbmfile
from matplotlib import pyplot

displayImagesOnScreen = True
filename = "distToCluster.1.pgm"

try:
    netpbm = netpbmfile.NetpbmFile (filename)
    img = netpbm.asarray ()
    netpbm.close ()
    cmap = 'gray' if netpbm.maxval > 1 else 'binary'
except ValueError as e:
    print(filename, e)

print "    img.ndim = '" + str(img.ndim) + "'"
print "    img.shape = '" + str(img.shape) + "'"

if displayImagesOnScreen:
    _shape = img.shape
        #  I have no idea what second clause is doing here...
    if img.ndim > 3 or (img.ndim > 2 and img.shape[-1] not in (3, 4)):
        img = img[0]
    pyplot.imshow(img, cmap, interpolation='nearest')
    pyplot.title("%s\n%s %s %s" % (filename, unicode(netpbm.magicnum),
                                   _shape, img.dtype))
    pyplot.show()


# <codecell>


