#===============================================================================

#  source ("getTruePresForEachSpp.R")

#===============================================================================

#  History

#  2014 02 07 - BTL - Created.
#  Extracted from old createTruePresences.R from guppy project and
#  from guppy/genTruePresencesPyper.R.  
#  Also, code for computing the number of true presences is derived 
#  from code in guppy/computeSppDistributions.R.

#===============================================================================

getTruePresIndicesForOneSpp = function (numTruePresForCurSpp, 
                                        numRows, 
                                        numCols, 
                                        sppGenOutputDirWithSlash,
                                        trueProbDistFilePrefix,    #  Or, variables$PAR.trueProbDistFilePrefix
                                        sppName
                                        )
    {
        #    norm.prob.matrix = true.rel.prob.dists.for.spp [[sppID]]
        #        filename = paste (prob.dist.layers.dir.with.slash,
    normProbFilename = paste0 (sppGenOutputDirWithSlash,
                               trueProbDistFilePrefix,    #  Or, variables$PAR.trueProbDistFilePrefix
                               ".", sppName
                               #					        '.asc',
                               )
    
        #  BTL - 2013.11.22
        #  IS THIS USING THE OLD ASCII READER OR THE NEW ONE?
        #  LOOKS LIKE IT'S PROBABLY THE OLD ONE SINCE IT LOOKS LIKE IT'S RETURNING
        #  A MATRIX RATHER THAN AN OBJECT.
        #  THIS SEEMS TO BE HAPPENING IN BOTH Guppy.py AND IN genTruePresencesPyper.R.
        #  DO I NEED BOTH A PYTHON AND AN R VERSION OF THIS?
    
    normProbMatrix = read.asc.file.to.matrix (normProbFilename)
    
        #-------------------------------------------------------------
        #  Sample presences from the mapped probability distribution
        #  according to the true relative presence probabilities to
        #  get the TRUE PRESENCES.
        #-------------------------------------------------------------

    
    truePresIndices = sample (1:(numRows * numCols),
                              numTruePresForCurSpp,    #  numTruePresForEachSpp [sppID],
                              replace = FALSE,
                              prob = normProbMatrix)

    return (truePresIndices)
    }

#===============================================================================

    #  Copied from createTruePresences.R, then modified to run more
    #  stand-alone rather than embedded in the R version of guppy.

getTruePresForEachSpp = 
    function (numTruePresForEachSpp,    #  a vector, not a scalar
              trueProbDistFilePrefix,
              fullSppSamplesDirWithSlash,    #  cur.full.maxent.samples.dir.name
              combinedTruePresFilename, 
              
              numRows, 
              numCols, 
              
                  #  Values for writing .asc file headers
              llcorner, 
              cellsize, 
              nodataValue     #  not needed here?
              )
    {
    numSppToCreate = length (numTruePresForEachSpp)  #  Or, variables$PAR.num.spp.to.create?
    allSppTruePresLocsXY = vector (mode="list", length=numSppToCreate)
    combinedSppTruePresTable = NULL
    
    for (sppID in 1:numSppToCreate)
        {
        sppName = paste ('spp.', sppID, sep='')
        #sppName = paste ('spp.', (sppID - 1), sep='')    #  to match python...

        numTruePresForCurSpp = numTruePresForEachSpp [sppID]
        
        truePresIndices = getTruePresIndicesForOneSpp (numTruePresForCurSpp, 
                                                       numRows, 
                                                       numCols, 
                                                       sppGenOutputDirWithSlash,
                                                       trueProbDistFilePrefix,    #  Or, variables$PAR.trueProbDistFilePrefix
                                                       sppName)
        
            #----------------------------------------------------------------
            #  Convert the sample from single index values to x,y locations
            #  relative to the lower left corner of the map.
            #----------------------------------------------------------------
    
        truePresenceLocsXY =
            matrix (rep (0, (numTruePresForCurSpp * 2)),
                    nrow = numTruePresForCurSpp, ncol = 2, byrow = TRUE)

        for (curLoc in 1:numTruePresForCurSpp)    #  Use apply instead?
            {
            truePresenceLocsXY [curLoc, ] =
                spatial.xy.rel.to.lower.left.by.row (truePresIndices [curLoc],
                                                     numRows, numCols,
                                                     llcorner, cellsize)
            }

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

        species = rep (sppName, numTruePresForCurSpp)
        truePresTable = data.frame (cbind (species, truePresenceLocsXY))
        names (truePresTable) = c('species', 'longitude', 'latitude')

            #--------------------------------------------------------------------
            #  Write the true presences out to a .csv file to be fed to maxent.
            #  This will represent the case of "perfect" information
            #  (for a given population size), i.e., it contains the true
            #  location of every member of the population at the time of the
            #  sampling.  For stationary species like plants, this will be
            #  "more perfect" than for things that can move around.
            #--------------------------------------------------------------------


            #  2011.09.21 - BTL - Have changed the name sampled.presences.filename
            #                     to true.presences.filename here because that
            #                     seems like it was an error before but didn't
            #                     show up because it gets written over further
            #                     down in the file.  I may be wrong so I'm flagging
            #                     it for the moment with '###'.
        outfileRoot = paste (sppName, ".truePres", sep='')
            ###sampled.presences.filename = paste (samples.dir, outfileRoot, ".csv", sep='')
            ##	true.presences.filename = paste (samples.dir, outfileRoot, ".csv", sep='')
        truePresFilename = paste0 (fullSppSamplesDirWithSlash,    #  cur.full.maxent.samples.dir.name, "/",
                                   outfileRoot, ".csv")

        write.csv (truePresTable,
                   file = truePresFilename,    #  file = sampled.presences.filename,
                   row.names = FALSE,
                   quote=FALSE)

        allSppTruePresLocsXY [[sppID]] = truePresenceLocsXY

            #-----------------------------------------------------------------
            #  Append the true presences to a combined table of presences
            #  for all species.
            #-----------------------------------------------------------------

        combinedSppTruePresTable =
            rbind (combinedSppTruePresTable, truePresTable)

        #===========================================================================

        }  #  end for - all species

    #-------------------------------------------

        #  This last bit is copied from saveCombinedPresencesForMaxent.R.
        #  That looks like the only place where the
        #  combined.spp.true.presences.table was ever used in the old R
        #  version of guppy and all that function did was write the combined
        #  true presences and the combined sampled presences out.
        #  I have just moved the writing of the combined true presences
        #  into here so that they don't have to be returned from this routine.
#     combinedTruePresFilename =
#         paste0 (fullSppSamplesDirWithSlash,    #  cur.full.maxent.samples.dir.name, "/",
#                 "spp.truePres.combined", ".csv")
    write.csv (combinedSppTruePresTable,
               file = combinedTruePresFilename,
               row.names = FALSE,
               quote=FALSE)

    return (allSppTruePresLocsXY)
    }

#===============================================================================

