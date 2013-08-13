#===============================================================================

#                               createTruePresences.py

# source( 'createTruePresences.R' )

#===============================================================================

#  History:

#  2013.08.12 - BTL
#  Converted to python.

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#===============================================================================

def genTruePresences (numTruePresences):

    allSppTruePresenceLocsXY = []
#            vector (mode="list", length=self.variables ["PAR.num.spp.to.create"])

    for (sppId in 1:self.variables ["PAR.num.spp.to.create"])
        sppName = 'spp.' + str (sppId)

            #----------------------------------------------------------------
            #  Get dimensions from relative probability matrix to use later
            #  and to make sure everything went ok.
            #----------------------------------------------------------------

    #	normProbMatrix = true.rel.prob.dists.for.spp [[sppId]]
        filename = self.probDistLayersDirWithSlash + \
                        self.variables ["PAR.trueProbDistFilePrefix"] + \
                        "." + sppName)
    #								'.asc',
#                                    sep='')
        normProbMatrix = readAscFileToMatrix (filename)

        numRows = normProbMatrix.shape [0]      #(dim (normProbMatrix)) [1]
        numCols = normProbMatrix.shape [1]      #(dim (normProbMatrix)) [2]
        numCells = numRows * numCols

        cat ("\n\nnumRows = ", numRows)
        cat ("\nnumCols = ", numCols)
        cat ("\nnumCells = ", numCells)

        #===========================================================================

            #-------------------------------------------------------------
            #  Sample presences from the mapped probability distribution
            #  according to the true relative presence probabilities to
            #  get the TRUE PRESENCES.
            #-------------------------------------------------------------

        truePresenceIndices = sample (1:numCells,
                                        numTruePresences [sppId],
                                        replace = False,
                                        prob = normProbMatrix)
        cat ("\ntruePresenceIndices = \n")
        print (truePresenceIndices)

            #----------------------------------------------------------------
            #  Convert the sample from single index values to x,y locations
            #  relative to the lower left corner of the map.
            #----------------------------------------------------------------

        truePresenceLocsXY =
            matrix (rep (0, (numTruePresences [sppId] * 2)),
                    nrow = numTruePresences [sppId], ncol = 2, byrow = TRUE)

            #  Can probably replace this with an apply() call instead...
        for curLoc in 1:numTruePresences [sppId]:
            truePresenceLocsXY [curLoc, ] =
                xyRelToLowerLeft (truePresenceIndices [cur.loc], numRows)

            #-----------------------------------------------------------------------
            #  Bind the species names to the presence locations to make a data frame
            #  that can be written out in one call rather than writing it out one
            #  line at a time.
            #  Unfortunately, this cbind call turns the numbers into quoted strings
            #  too.  There may be a way to fix that, but at the moment, I don't
            #  know how to do that so I'll strip all quotes in the write.csv call.
            #  That, in turn, may cause a problem for the species name if it has a
            #  space in it.  Not sure what maxent thinks of that form.
            #-----------------------------------------------------------------------

        species = rep (sppName, numTruePresences [sppId])
        truePresencesTable =
            data.frame (cbind (species, truePresenceLocsXY))
        names (truePresencesTable) = ['species', 'longitude', 'latitude']

            #--------------------------------------------------------------------
            #  Write the true presences out to a .csv file to be fed to maxent.
            #  This will represent the case of "perfect" information
            #  (for a given population size), i.e., it contains the true
            #  location of every member of the population at the time of the
            #  sampling.  For stationary species like plants, this will be
            #  "more perfect" than for things that can move around.
            #--------------------------------------------------------------------


                #  2011.09.21 - BTL - Have changed the name sampledPresencesFilename
                #                     to truePresencesFilename here because that
                #                     seems like it was an error before but didn't
                #                     show up because it gets written over further
                #                     down in the file.  I may be wrong so I'm flagging
                #                     it for the moment with '###'.
        outfile.root = sppName + ".truePres"
        ###sampledPresencesFilename = paste (samples.dir, outfile.root, ".csv", sep='')
    ##	truePresencesFilename = paste (samples.dir, outfile.root, ".csv", sep='')
        truePresencesFilename = paste (cur.full.maxent.samples.dir.name, "/",
                                            outfile.root, ".csv", sep='')
        cat ("\n\ntruePresencesFilename = '", truePresencesFilename, "'", sep='')

        write.csv (truePresencesTable,
        ###  	   file = sampledPresencesFilename,
               file = truePresencesFilename,
                   row.names = False,
                   quote=False)


        allSppTruePresenceLocsXY [[sppId]] = truePresenceLocsXY

            #-----------------------------------------------------------------
            #  Append the true presences to a combined table of presences
            #  for all species.
            #-----------------------------------------------------------------

        combinedSppTruePresencesTable =
            rbind (combinedSppTruePresencesTable, truePresencesTable)

        #===========================================================================

    return {("combinedSppTruePresencesTable", combinedSppTruePresencesTable), \
            ("allSppTruePresenceLocsXY", allSppTruePresenceLocsXY)}

#===============================================================================

