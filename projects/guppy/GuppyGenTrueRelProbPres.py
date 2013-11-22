#===============================================================================

#                           GuppyGenTrueRelProbPres.py

#  History:

#  2013.08.05 - BTL
#  Created.

#===============================================================================

import guppySupportFunctions as gsf
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

    def copyTrueRelProbDistMapsForAllSpp (self, guppy):

        clusterTest = False
        if (clusterTest):
            filespec = "spp.*.asc"
        else:
            filespec = "*.asc"
            #  2013 10 23 - BTL
            #  Guppy was crashing when there were 8 species and 3 env layers.
            #  It would crash when trying to read in the 8 generated species
            #  because there were only 3 species in the directory the
            #  generated species were copied into.
            #  For some reason, it was copying the env files as the
            #  generated species files.  Seems to work now that I've changed
            #  the srcFile directory.
###2013.10.23###        srcFiles = gsf.buildNamesOfSrcFiles (guppy.curFullMaxentEnvLayersDirName, filespec)


#2013.11.08 - fooling around with hacking clustering species
#NEED TO MAKE NUMBER AND SOURCE OF ENV LAYERS MATCH THE ONES USED FOR
#THE CLUSTER TESTS IN THE GUPPY DIRECTORY, I.E., ALL OF MATT'S ENV LAYERS

#Then, need to copy the cluster output images instead of the maxent
#generated species for this quick and dirty tests.

        print "\n\nvvvvvvvvvvvvvvvvvvvvvvvvvv\n\n*****  In copyTrueRelProbDistMapsForAllSpp():\n"

        if (clusterTest):
#            srcDir = "/Users/Bill/D/rdv-framework/projects/guppy"
            srcDir = "/Users/Bill/D/rdv-framework/projects/guppy/Clustered_kmeans_MattEnvLayers_All/ClusteredWith500pointsAnd15clusters"
        else:
            srcDir = guppy.sppGenOutputDir

        print "\nAbout to get srcFiles with first call to gsf.buildNamesOfSrcFiles()."
        srcFiles = gsf.buildNamesOfSrcFiles (srcDir, filespec)




        print "srcDir = '" + srcDir + "'\n"
        #pprint (srcFiles)
        print "\nAbout to get fileRootNames with second call to gsf.buildNamesOfSrcFiles()."
        fileRootNames = gsf.buildDestFileRootNames (guppy.sppGenOutputDir, filespec)
        print "fileRootNames = "
        pprint (fileRootNames)
        print "*****  srcFiles_1 = \n"
        pprint (srcFiles)

        prefix = self.variables ["PAR.trueProbDistFilePrefix"] + "."
        print "\n\nprefix = " + prefix
        destFilesPrefix = guppy.probDistLayersDirWithSlash + prefix

        print "destFilesPrefix = " + destFilesPrefix

        destFiles = [destFilesPrefix + fileRootNames[i] for i in range (len(fileRootNames))]
        pprint (destFiles)
        print "\n\n"
        print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n\n"

        gsf.copyFiles (srcFiles, destFiles)

#-------------------------------------------------------------------------------

    def getTrueRelProbDistMapsForAllSpp (self, guppy):

        self.generateTrueRelProbDistMapsForAllSpp (guppy)
        self.copyTrueRelProbDistMapsForAllSpp (guppy)

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

    def getTrueRelProbDistMapsForAllSpp (self, guppy):
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

    def genCombinedSppPresTable (self, guppy):      ###numImgRows, numImgCols, guppy):
        """
        Generate and return a table specifying all true species locations
        (x,y values) for every species.
        The table has 3 columns and each row gives the species ID
        and then the x and y location of a true presence for that species
        (relative to the lower left corner of the map, since that is what
        maxent expects).
        """

###        numCells = numImgRows * numImgCols
        numCells = guppy.imgNumRows * guppy.imgNumCols

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
#        xyPairs = numpy.zeros ((totNumPres,2), dtype=int)
        xyPairs = numpy.zeros ((totNumPres,2), dtype=float)
        print
    #    print xyPairs

        for k in range (totNumPres):
###            xyPairs [k,:] = gsf.xyRelToLowerLeft (curSppPresIndices [k], guppy.imgNumRows, guppy.imgNumCols)
##            xyPairs [k,:] = gsf.spatialXYrelToLowerLeft (curSppPresIndices [k], guppy.imgNumRows, guppy.imgNumCols)
#            xyPairs [k,:] = gsf.spatialXYCellCenter (curSppPresIndices [k], guppy.imgNumRows, guppy.imgNumCols)
            xyPairs [k,:] = gsf.spatialXYCellCenter (curSppPresIndices [k],
                            guppy.imgNumRows, guppy.imgNumCols,
                            guppy.xllcorner, guppy.yllcorner,
                            guppy.cellsize)
#            print "xyPairs = "
#            pprint (xyPairs)

            #  This is writing column headers to the data frame, but I'm not sure
            #  if it should be doing that since maxent may not expect it.
###        combinedSppPresTable = pd.DataFrame(xyPairs,index=repeatedSppNames,columns=['longitude','latitude'])
        combinedSppPresTable = pd.DataFrame.from_items ([('spp', repeatedSppNames), ('longitude', xyPairs [:,0]), ('latitude', xyPairs [:,1])])
    #    print combinedSppPresTable

        return combinedSppPresTable

#-------------------------------------------------------------------------------

    def generateTrueRelProbDistMapsForAllSpp (self, guppy):
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
            self.genCombinedSppPresTable (guppy)  ###  guppy.imgNumRows, guppy.imgNumCols)

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
#                        guppy.maxentGenOutputDir, \
                        guppy.sppGenOutputDir, \
                        guppy.doMaxentReplicates,
                        guppy.maxentReplicateType, \
                        guppy.numMaxentReplicates, \
                        guppy.maxentFullPathName, \
                        guppy.curFullMaxentEnvLayersDirName, \
                        guppy.numProcessors, \
                        guppy.verboseMaxent \
                        )


#===============================================================================
#===============================================================================

    #  2013.11.22 - BTL
    #  This is the class that I started working on when I was clustering
    #  the data myself with kmeans.
    #  After meeting with Matt last week, he thought that those clusters
    #  didn't look very realistic and he had some that he had developed
    #  using a supervised clustering method and they were much more realistic.
    #  So, I'm going to work on a class using those instead and just leave
    #  this one here as a stub for now.

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

    def getTrueRelProbDistMapsForAllSpp (self, guppy):
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

        Rcaller.assign ('rSppGenOutputDir', guppy.sppGenOutputDir)
        Rcaller.assign ('rCurFullMaxentEnvLayersDirName', guppy.curFullMaxentEnvLayersDirName)
        Rcaller.assign ('rNumSpp', self.variables ["PAR.num.spp.to.create"])
        Rcaller.assign ('rRandomSeed', guppy.randomSeed)

        print "\n\n>>>>> About to pyper source guppyClusterTest.R"
        Rcaller ("source ('/Users/Bill/D/rdv-framework/projects/guppy/guppyClusterTest.R')")


    #	return (trueRelProbDistsForSpp)

#===============================================================================

    #  2013.11.22 - BTL
    #  Adding this class to generate species using the supervised clustering
    #  results that Matt had created for the Mt Buffalo data.

class GuppyGenTrueRelProbPres_ExistingClusters (GuppyGenTrueRelProbPres):
    """
    Class for guppy generators of true relative probability of presence
    that are based on using an existing clustering of environmental variables
    (rather than creating one here) to generate a relative probability
    distribution that can then be reused as a true distribution.
    """

#-------------------------------------------------------------------------------

    def __init__ (self, variables=None):
        self.variables = variables or {}
#        super.__init__ (variables)    Should I be doing this instead?

#-------------------------------------------------------------------------------

    def getTrueRelProbDistMapsForAllSpp (self, guppy):
        """
        Build a relative probability map for each species by reading an
        image of a clustering of the environmental variables and then
        computing the distance in feature space from the point to one or
        more clusters chosen to be representative of that species' habitat.
        """

        #--------------------------------------------------------------------
        #  1) Start by reading in the n-dimensional environmental variables
        #  that describe each pixel.
        #--------------------------------------------------------------------

        #--------------------------------------------------------------------
        #  2)  Read an image showing the pre-generated cluster ID of each
        #  pixel, then generate a map for each cluster so that each pixel
        #  in that map represents the similarity of that pixel to the cluster.

        #  2a) For the moment, I will just use the distance from the point
        #  in environmental coordinates to the cluster centroid (mediod?) in
        #  environmental space rather than geographic space.

        #  2b) However, that feature vector could also include the x,y (or
        #  lat,long) coordinates of the point too.  Not sure if that will
        #  be a good idea or not.  Will have to experiment to decide.
        #--------------------------------------------------------------------

        #--------------------------------------------------------------------
        #  3)  For each species, choose one or more clusters to use as the
        #  definition of the habitat for that species.
        #
        #  3a)  At the moment, I'm not sure how I want to handle the case
        #  of using more than one cluster.  For example, distance to the
        #  "unified" cluster could be the minimum over the distances
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

        print "\n\nGenerate true rel prob map using Existing Clustering.\n\n"

        Rcaller.assign ('rSppGenOutputDir', guppy.sppGenOutputDir)
        Rcaller.assign ('rCurFullMaxentEnvLayersDirName', guppy.curFullMaxentEnvLayersDirName)
        Rcaller.assign ('rNumSpp', self.variables ["PAR.num.spp.to.create"])
        Rcaller.assign ('rRandomSeed', guppy.randomSeed)

        print "\n\n>>>>> About to pyper source guppyClusterTest.R"
        Rcaller ("source ('/Users/Bill/D/rdv-framework/projects/guppy/guppyClusterTest.R')")


    #	return (trueRelProbDistsForSpp)

#===============================================================================

