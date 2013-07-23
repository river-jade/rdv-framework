# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

!pwd

# <codecell>

!svn status

# <codecell>

!svn update

# <markdowncell>

# svn update seemed to just hang.  Not sure why, so I killed it.  Will try running it outside of ipython now.

# <rawcell>

# tests-MacBook-Pro:guppy Bill$ svn update
# svn: OPTIONS of 'https://rdv-framework.googlecode.com/svn/trunk/projects/guppy': could not connect to server (https://rdv-framework.googlecode.com)

# <markdowncell>

# It seemed like it was hanging outside ipython notebook too, but I went away for a while and then it came back with a connection failure message, so it might have done the same thing inside of hte notebook too if I'd waited long enough.  
# 
# The connection failure may be just because I'm trying to run this from home instead of through the proxy at work.  

