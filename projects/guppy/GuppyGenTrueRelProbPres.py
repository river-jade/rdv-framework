#===============================================================================

#                           GuppyGenTrueRelProbPres.py

#  History:

#  2013.08.05 - BTL
#  Created.

#===============================================================================

from guppySupportFunctions import xyRelToLowerLeft
import numpy
import random
import pandas as pd
import GuppyConstants as CONST
from runMaxentCmd import runMaxentCmd
from pprint import pprint
import os
import glob
import fnmatch
import shutil

#===============================================================================

class GuppyGenTrueRelProbPres (object):
    """Superclass for class for all guppy generators of true relative
    probability of presence.
    """

#-------------------------------------------------------------------------------

    def __init__ (self, variables=None):
        self.variables = variables or {}

#-------------------------------------------------------------------------------

    def getTrueRelProbDistsForAllSpp (self, guppy):
        raise NotImplementedError ()

#-------------------------------------------------------------------------------

    def genCombinedSppPresTable (self, numImgRows, numImgCols):
        """
        Generate and return a table specifying all true species locations
        (x,y values) for every species.
        The table has 3 columns and each row gives the species ID
        and then the x and y location of a true presence for that species
        (relative to the lower left corner of the map, since that is what
        maxent expects).
        """

        numCells = numImgRows * numImgCols

#        numSpp = 3    #  self.variables ["PAR.num.spp.to.create"]
#        minNumPres = 2    #  self.variables ["PAR.minNumPres"]
#        maxNumPres = 5    #self.variables ["PAR.maxNumPres"]

        numSpp = self.variables ["PAR.num.spp.to.create"]
        minNumPres = self.variables ["PAR.minNumPres"]
        maxNumPres = self.variables ["PAR.maxNumPres"]

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
#        sppNames = ['spp.' + str(sppId+1) for sppId in range(numSpp)]
        sppNames = ['spp.' + str(sppId) for sppId in range(numSpp)]
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

    #    curSppPresIndices = numpy.zeros (totNumPres, dtype=int)
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
            #       enough sense for me to remember it. - Noio Feb 20 at 16:19
            #
            #       Doesn't universally work!
            #           l=[1,2,[3,4]] [item for sublist in l for item in sublist]
            #       TypeError: 'int' object is not iterable - Sven Mar 27 at 14:00
            #
            #       @Noio It makes sense if you re-order it:
            #           [item for item in sublist for sublist in l ].
            #       Of course, if you re-order it, then it won't make sense to Python,
            #       because you're using sublist before you defined what it is.
            #       - mehaase May 23 at 22:29
        #curSppPresIndices = [item for sublist in curSppPresIndices for item in sublist]

            #  A tiny comment on the same stack overflow page suggested using numpy.concatenate() instead:
            #   	numpy.concatenate seems a bit faster than any of the methods here,
            #       if you are willing to accept an array.
            #       - Makoto Jul 19 '12 at 8:04
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
        xyPairs = numpy.zeros ((totNumPres,2), dtype=int)
        print
    #    print xyPairs

        for k in range (totNumPres):
            xyPairs [k,:] = xyRelToLowerLeft (curSppPresIndices [k], numImgRows, numImgCols)
        print "xyPairs = "
        print xyPairs

            #  This is writing column headers to the data frame, but I'm not sure
            #  if it should be doing that since maxent may not expect it.
###        combinedSppPresTable = pd.DataFrame(xyPairs,index=repeatedSppNames,columns=['longitude','latitude'])
        combinedSppPresTable = pd.DataFrame.from_items ([('spp', repeatedSppNames), ('longitude', xyPairs [:,0]), ('latitude', xyPairs [:,1])])
    #    print combinedSppPresTable

        return combinedSppPresTable

#===============================================================================
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

    def getTrueRelProbDistsForAllSpp (self, guppy):
        raise NotImplementedError ()

#===============================================================================
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

    def getTrueRelProbDistsForAllSpp (self, guppy):
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

        print "\n\nGenerate true rel prob map using MAXENT.\n\n"

        combinedSppPresTable = \
            self.genCombinedSppPresTable (guppy.imgNumRows, guppy.imgNumCols)

        print "\n\ncombinedSppPresTable = \n"
        print combinedSppPresTable

        combinedSppPresencesFilename = guppy.curFullMaxentSamplesDirName + \
                                        CONST.dirSlash + \
                                        "maxentGenSppPresCombined" + ".csv"

        combinedSppPresTable.to_csv (combinedSppPresencesFilename, index=False)
    #    writeCsv (combinedSppPresTable,
    #               file = combinedSppPresencesFilename,
    #               rowNames = False,
    #               quote=False)

            #  Now have to make whatever changes and initializations are necessary to
            #  call maxent and have it generate new layers in the proper subdirectory
            #  and not do any bootstrapping.

            #  OUTPUTS FROM THIS GENERATOR NEED TO GO INTO THE MaxentProbDistLayers
            #  directory, just like the outputs of the arithmetic generator.
            #  Need to see where it builds its directory name and writes to it.

            #  Also, when maxent is finished generating these layers, there will probably
            #  be tons of crap left in there by maxent that needs to be deleted.
            #  This suggests it might be better to just make a scratch area for maxent
            #  to dump into and then just copy the species distribution files I need
            #  out of there and into the MaxentProbDistLayers directory.
            #  Call it MaxentProbDistGenOutputs.

            #----------------------------------------------------------------
            #  Run maxent to generate a true relative probability map.
            #----------------------------------------------------------------

        runMaxentCmd (combinedSppPresencesFilename,
                        guppy.maxentGenOutputDir, \
                        guppy.doMaxentReplicates,
                        guppy.maxentReplicateType, \
                        guppy.numMaxentReplicates, \
                        guppy.maxentFullPathName, \
                        guppy.curFullMaxentEnvLayersDirName, \
                        guppy.numProcessors, \
                        guppy.verboseMaxent \
                        )

           #  NOW NEED TO CONVERT THE MAXENT OUTPUTS IN MaxentGenOutputs/plots/spp.?.asc
            #  into pgm and tiff?  Regardless, need to copy the .asc files into the
            #  MaxentProbDistLayers area as:
            #		true.prob.dist.spp.?.asc
            #  Then, possibly need to create these as well, just for diagnosis I think.
            #  I believe that maxent will run as soon as I get the asc files in there.
            #		true.prob.dist.spp.?.pgm
            #		true.prob.dist.spp.?.csv   ARE THESE CSV FILES REALLY NECESSARY?
            #									SEEMS LIKE I NEVER LOOK AT THEM...

            #  As soon as these files are moved and renamed, then I should be able to
            #  remove the stop() command below and the temporary call to get.true...()
            #  at the start of this else branch (surrounded by exclamation points)
            #  and the whole thing should run to completion.

            #  Once that works, then the only major thing left to do is to create
            #  smaller versions of all the files on the fly so that I can do more runs
            #  and use some parts Alex's big images as cross-validation and testing fodder.

        #maxentGenOutputDir = "../MaxentGenOutputs"
        #probDistLayersDir = "../MaxentProbDistLayers/"

            #  In R, list.files() produces a character vector of the names of
            #  files or directories in the named directory
        #fileRootNames = filePathSansExt (listFiles ('.','*.asc'))

###        filesToCopyFrom = listFiles (maxentGenOutputDir, "*.asc", fullNames=TRUE)
        filesToCopyFrom = []
        for root, dirs, files in os.walk (guppy.maxentGenOutputDir):
            filesToCopyFrom += glob.glob (os.path.join (root, '*.asc'))

###        filesToCopyFrom = filesToCopyFrom[[1]]
        print "\n\nfilesToCopyFrom = "
        pprint (filesToCopyFrom)
        print "\n\n"

        prefix = self.variables ["PAR.trueProbDistFilePrefix"] + "."
        print "\n\nprefix = " + prefix

###        fileRootNames = listFiles (maxentGenOutputDir, '*.asc')
###        print "\n\nfileRootNames =\n", fileRootNames

        fileRootNames = []
        for root, dirs, files in os.walk (guppy.maxentGenOutputDir):
            fileRootNames += fnmatch.filter (files, '*.asc')

        pprint (fileRootNames)


        #"/Users/Bill/tzar/outputdata/Guppy/default_runset/200_Scen_1.inprogress/MaxentGenOutputs/spp.1.asc"
        #"/Users/Bill/tzar/outputdata/Guppy/default_runset/200_Scen_1.inprogress/MaxentGenOutputs/spp.1.asc"

#        filesToCopyTo = probDistLayersDirWithSlash + prefix + fileRootNames
        filesToCopyToPrefix = guppy.probDistLayersDirWithSlash + prefix
        filesToCopyTo = [filesToCopyToPrefix + fileRootNames[i] for i in range (len(fileRootNames))]
        pprint (filesToCopyTo)

#        print "\n\nfilesToCopyTo = "
#        print filesToCopyTo
        print "\n\n"

        #retVals = file.copy(fileRootNames, filesToCopyTo)
###        retVals = fileCopy (filesToCopyFrom, filesToCopyTo)

        for k in range (len (filesToCopyFrom)):
            shutil.copyfile(filesToCopyFrom [k], filesToCopyTo [k])

###        print "\n\nretVals for file.copy =\n" + retVals
###        if length (which (not retVals)):
###            print "\n\nCopy failed.\n"
###            stop()

        print "\n\nDone copying files...\n\n"

    ## 		} else  #  No option chosen
    ## 		{
    ## 		print "\n\nNo option chosen for how to generate true rel prob map.\n\n")
    ## 		stop()
    ## 		}



    #	return (trueRelProbDistsForSpp)

#===============================================================================
#===============================================================================

class GuppyGenTrueRelProbPresCLUSTER (GuppyGenTrueRelProbPres):
    """
    Class for guppy generators of true relative probability of presence
    that are based on clustering environmental variables to generate a
    relative probability distribution that can then be reused as a true
    distribution.
    """

#-------------------------------------------------------------------------------

    def __init__ (self, variables=None):
        self.variables = variables or {}
#        super.__init__ (variables)    Should I be doing this instead?

#-------------------------------------------------------------------------------

    def getTrueRelProbDistsForAllSpp (self, guppy):
        """
        Build a relative probability map for each species by clustering
        the environmental variables and then computing the distance in
        feature space from the point to one or more clusters chosen to be
        representative of that species' habitat.
        """

        #--------------------------------------------------------------------
        #  1) Start by clustering the n-dimensional environmental variables
        #  that describe each pixel.
        #--------------------------------------------------------------------

        #--------------------------------------------------------------------
        #  2) Once they are clustered, generate a map for each cluster
        #  so that each pixel in that map represents the similarity of that
        #  pixel to the cluster.

        #  2a) For the case of k-means clustering, I will just use the
        #  distance from the point to the cluster centroid in feature space
        #  rather than geographic space.

        #  2b) However, that feature vector could also include the x,y (or
        #  lat,long) coordinates of the point too.  Not sure if that will
        #  be a good idea or not.  Will have to experiment to decide.
        #--------------------------------------------------------------------

        #--------------------------------------------------------------------
        #  3)  For each species, choose one or more clusters to use as the
        #  definition of the habitat for that species.
        #
        #  3a)  At the moment, I'm not sure how I want to handle the case
        #  of using more than one cluster.  For example, distance to that
        #  the "unified" cluster could be the minimum over the distances
        #  to all of the constituent clusters or it could be the median, etc.
        #  There might be other ways of doing it as well, but I haven't
        #  thought of any other yet.  It might actually be handled better
        #  via hierarchical clustering where you just grab one branch from
        #  a particular level down.  However, that wouldn't represent species
        #  who had very different kinds of habitats because they were
        #  generalists or because they had a particular thing that they
        #  were avoiding/excluding rather than including or because they
        #  needed different kinds of habitat for different life stages or
        #  living needs (e.g., breeding vs feeding vs nesting, etc.).
        #--------------------------------------------------------------------

        print "\n\nGenerate true rel prob map using CLUSTERING.\n\n"




    #	return (trueRelProbDistsForSpp)

#===============================================================================

