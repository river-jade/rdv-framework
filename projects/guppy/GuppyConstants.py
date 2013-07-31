#===============================================================================

#                               GuppyConstants.py

#  History:

#  2013.07.31 - BTL
#  Created by extracting various constants from Guppy.py.

#===============================================================================

    #  THIS PROBABLY NEEDS TO BE CHANGED SOMEHOW TO MAKE IT SO THAT THERE
    #  IS ONLY ONE INSTANCE OF THIS CLASS AND THE VALUES ARE CLASS VALUES
    #  RATHER THAN INSTANCE VALUES AND THEY ARE IMMUTABLE.

class GuppyConstants (object):
    """Definitions for constants used throughout the Guppy system.
    """
    def __init__ (self):

        self.dirSlash = "/"

            #  Names provided by python for the different operating systems
            #  vary based on the call you use to get the name.
            #  in particular, os.name gives a coarser version that
            #  sys.platform or os.uname().  For example, all unix versions
            #  are called "posix" using os.name, but the others break unix
            #  up into finer categories.  I'll use the values from sys.platform
            #  here.
        self.windowsOSnameInR = "mingw32"
        self.windowsOSnameInPython = "win32"
        self.windowsOSname = self.windowsOSnameInPython

        self.macOSname = "darwin"

#===============================================================================

