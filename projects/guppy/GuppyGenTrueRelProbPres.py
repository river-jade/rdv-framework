#===============================================================================

#                           GuppyGenTrueRelProbPres.py

#  History:

#  2013.08.05 - BTL
#  Created.

#===============================================================================

class GuppyGenTrueRelProbPres (object):
    """Superclass for class for all guppy generators of true relative
    probability of presence.
    """

#-------------------------------------------------------------------------------

    def __init__ (self, variables=None):
        self.variables = variables or {}

#-------------------------------------------------------------------------------

    def getTrueRelProbDistsForAllSpp (envLayers, numEnvLayers):
        raise NotImplementedError ()

#===============================================================================

class GuppyGenTrueRelProbPresARITH (GuppyGenTrueRelProbPres):
    """
    Class for guppy generators of true relative probability of presence
    that are based on doing simple arithmetic between environmental layers.
    """

#-------------------------------------------------------------------------------

    def __init__ (self, variables=None):
        self.variables = variables or {}
#        super.__init__ (variables)    Should I be doing this instead?

#-------------------------------------------------------------------------------

    def getTrueRelProbDistsForAllSpp (self, envLayers, numEnvLayers):
        print "\n\nNot implemented yet.\n"

#===============================================================================

class GuppyGenTrueRelProbPresMAXENT (GuppyGenTrueRelProbPres):
    """
    Class for guppy generators of true relative probability of presence
    that are based on running Maxent to generate a relative probability
    distribution that can then be reused as a true distribution.
    """

#-------------------------------------------------------------------------------

    def __init__ (self, variables=None):
        self.variables = variables or {}
#        super.__init__ (variables)    Should I be doing this instead?

#-------------------------------------------------------------------------------

    def getTrueRelProbDistsForAllSpp (self, envLayers, numEnvLayers):
        """
        #--------------------------------------------------------------------
        #  Here, we now want to have the option to create the true relative
        #  probability maps in a different way.
        #  	1) Generate a very small number of presence locations.
        #	2) Hand these to maxent with the environment layers and
        #	   have it fit a distribution from them (no bootstrapping).
        #	3) Return that as the true relative probability map.
        #--------------------------------------------------------------------

        #  NOTE:  This function is defined in computeSppDistributions.R
        """

        print "\n\nNot implemented yet.\n"

#===============================================================================

