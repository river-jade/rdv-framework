#===============================================================================

#  source ("getSampledPresForEachSpp.R")

#===============================================================================

#  History

#  2014 02 87 - BTL - Created.
#  Extracted from old createSampledPresences.R from guppy project and
#  from guppy/genTruePresencesPyper.R.  

#===============================================================================

#  Copied from genTruePresencesPyper.R which originally copied it from 
#  guppySupportFunctions.R

buildPresSample =
    function (samplePresIndicesIntoTruePresIndices,
              truePresLocsXY)
    {
        #-------------------------------------------------------------------
        #  I'm doing this as a function so that the sampling method (and
        #  any other errors in building the presence sample) can be hidden
        #  from the calling program.
        #  For the moment though, it's very simple.  It's just a straight
        #  subsample of the original population with no errors.
        #-------------------------------------------------------------------
        
    sampleLocsXY =
        truePresLocsXY [samplePresIndicesIntoTruePresIndices,]
        
        #	sample.presences.dataframe <-
        #		data.frame (cbind (species[1:num.samples.to.take], sample.locs.x.y))
        #	names (sample.presences.dataframe) <- c('species', 'longitude', 'latitude')
        
        #	return (sample.presences.dataframe)
        
        #  Downstream uses expect the output to be a matrix, not a vector,
        #  so make sure that any single row outputs are converted to matrices.
    if (is.vector (sampleLocsXY))
        sampleLocsXY = matrix (sampleLocsXY, nrow=1)
    
    return (sampleLocsXY)
    }

#===============================================================================

    #---------------------------------------------------------------------
    #  Have now finished generating the true occurrences of the species.
    #  Ready to simulate the sampling of the species to generate a
    #  sampled occurrence layer to feed to maxent.
    #
    #  This routine really belongs as a method in Guppy that applies a
    #  a SamplingBias class to generate a biased sample.
    #---------------------------------------------------------------------

getSampledPresForEachSpp = function (numTruePresForEachSpp,
                                     allSppTruePresLocsXY,
                                     PARuseAllSamples,
                                     fullSppSamplesDirWithSlash,    #  cur.full.maxent.samples.dir.name,
                                     combinedSampledPresFilename
                                     )
    {
    numSppToCreate = length (numTruePresForEachSpp)
    combinedSppSampledPresTable = NULL
    
    #  This is just a hack for now.
    #  Need to figure out a better way to pass in arrays of numbers of
    #  true sample sizes and subsample sizes.
    PARnumSamplesToTake = numTruePresForEachSpp
    if (! PARuseAllSamples)
        {
        PARnumSamplesToTake = as.integer (numTruePresForEachSpp / 2)
        }
    
    for (sppID in 1:numSppToCreate)
        {
#        spp.name = paste ('spp.', (spp.id - 1), sep='')    #  to match python...
        sppName = paste0 ('spp.', sppID)
        
        sampledLocsXY = NULL
        samplePresIndicesIntoTruePresIndices = 
            1:(numTruePresForEachSpp [sppID])
        
        if (PARuseAllSamples)
            {
            sampledLocsXY = allSppTruePresLocsXY [[sppID]]
            
            } else
            {
            numSamplesToTake = min (numTruePresForEachSpp [sppID], PARnumSamplesToTake [sppID])
            
            samplePresIndicesIntoTruePresIndices =
                sample (1:(numTruePresForEachSpp [sppID]),
                        numSamplesToTake,
                        replace=FALSE)  #  Should this be WITH rep instead?
            
            sampledLocsXY =
                buildPresSample (samplePresIndicesIntoTruePresIndices,
                                       allSppTruePresLocsXY [[sppID]])
            }
        
        #  temporary comment to try to get rid of sample points on image - aug 25 2011
        # plot (all.spp.true.presence.locs.x.y [[spp.id]] [,1], all.spp.true.presence.locs.x.y [[spp.id]] [,2],
        # 	  xlim = c (0, num.cols), ylim = c(0, num.rows),
        # 	  asp = 1,
        # 	  main = paste ("True presences \nnum.true.presences = ",
        # 	  				num.true.presences, sep='')
        # 	  )
        #
        # plot (sampled.locs.x.y [,1], sampled.locs.x.y [,2],
        # 	  xlim = c (0, num.cols), ylim = c(0, num.rows),
        # 	  asp = 1,
        # 	  main = paste ("Sampled presences \nnum.samples = ",
        # 	  				num.samples.to.take, sep='')
        # 	  )
        
        #-------------------
        #  Need to change this line to make it act the same way that
        #  true presences behave, i.e., can have a different number of
        #  of samples for each species.  Right now, I think that all
        #  sampled species have the same number of samples.
        #  BTL - 2013.04.14
        #  Note that this line about defining the species vector was
        #  not here before now.  It appeared in the true presences area
        #  but not here.  When I split the giant initial file into
        #  separate files with separate loops over each generative step,
        #  this part crashed because the species vector was not defined.
        #  It only worked before because this section happened
        #  immediately after the true presences code inside the same
        #  loop, so the species vector just happened to have been defined
        #  already.  Now that I've added a definition of the species
        #  vector here, it works again.
        #  BTL - 2013.08.13
        #  Have I fixed this now by adding the [spp.id] index everywhere
        #  in this routine where num.samples.to.take appears?
        
        species = rep (sppName, numSamplesToTake)
        
        #  The cbind that follows this will misbehave if sampledLocsXY
        #  is a vector instead of a matrix.  This was happening when there
        #  was only one xy pair in sampledLocsXY and the routine that
        #  was building it didn't explicitly turn that into a 1 row matrix
        #  and this routine thought it was a 2 row x 1 column column vector.
        #  I think I've fixed that, but this little safety check will
        #  catch it if not.
        if (is.vector (sampledLocsXY))
            sampledLocsXY = matrix (sampledLocsXY, nrow=1)
        
        sampledPresTable =
            data.frame (cbind (species, sampledLocsXY))
        #  old version of this line that I think is an error
        #		data.frame (cbind (species [1:num.samples.to.take], sampled.locs.x.y))
        
        #-------------------
        
        names (sampledPresTable) = c('species', 'longitude', 'latitude')
        
        #--------------------------------------------------------------
        #  Write the sampled presences out to a .csv file that can be
        #  fed to maxent.
        #--------------------------------------------------------------
        
        outfileRoot = paste (sppName, ".sampledPres", sep='')
        sampledPresFilename = paste0 (fullSppSamplesDirWithSlash, #  "/",
                                             outfileRoot, ".csv")
        write.csv (sampledPresTable,
                   file = sampledPresFilename,
                   row.names = FALSE,
                   quote=FALSE)
        
        #-----------------------------------------------------------------
        #  Append the sampled presences to a combined table of presences
        #  for all species.
        #-----------------------------------------------------------------
        
        combinedSppSampledPresTable =
            rbind (combinedSppSampledPresTable, sampledPresTable)
        
        #===============================================================================
        
        }  #  end for - each species
    
    #-------------------------------------------
    
    #  This last bit is copied from saveCombinedPresencesForMaxent.R.
    #  That looks like the only place where the
    #  combined.sampled.presences.filename was every used in the old R
    #  version of guppy and all that function did was write the combined
    #  true presences and the combined sampled presences out.
    #  I have just moved the writing of the combined true presences
    #  into here so that nothing has to be returned from this routine.
    #  Looks like this file name is set here and in the guppy
    #  intialization code, so I'm going to remove the setting
    #  of it here so that it can't get set two different ways
    #  by accident.
    #  BTL - 2013.08.13
#     combinedSampledPresFilename = paste0 (fullSppSamplesDirWithSlash,    #  cur.full.maxent.samples.dir.name, "/",
#                                           "spp.sampledPres.combined", ".csv")
    
    write.csv (combinedSppSampledPresTable,
               file = combinedSampledPresFilename,
               row.names = FALSE,
               quote=FALSE)

    #-------------------------------------------
    #-------------------------------------------
    
    #    return (combinedSppSampledPresTable)
    }

#===============================================================================

