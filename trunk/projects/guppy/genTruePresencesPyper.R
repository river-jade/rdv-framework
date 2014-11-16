#===============================================================================

#                               genTruePresencesPyper.R

# source( 'genTruePresencesPyper.R' )

#===============================================================================

#  History:

#  2013.08.13 - BTL
#  Modified from createTruePresences.R so that it could be called from Pyper
#  in python version of guppy.

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#===============================================================================

debuggingOutputFileName = "/Users/Bill/D/rdv-framework/projects/guppy/debugOutput.txt"

#===============================================================================

xy.rel.to.lower.left.by.row <- function (n, nrow, ncol)
    {
    x = 1 + ((n-1) %% ncol)        #  modulo
    y = nrow - ((n-1) %/% ncol)    #  integer divide

    return ( c (x,y) )
    }

#===============================================================================

#  Copied from guppySupportFunctions.R
#  BUT modified 2013.11.21 by BTL because of error in the original version
#  where it did an integer divide by ncol instead of nrow in calculating the
#  x coordinate.

xy.rel.to.lower.left.by.col <- function (n, nrow, ncol)
    {
###    x = 1 + ((n-1) %/% ncol)      #  integer divide  ERROR IN guppySupportFunctions.R VERSION ***
    x = 1 + ((n-1) %/% nrow)      #  integer divide

    y = nrow - ((n-1) %% nrow)    #  modulo

    return (c (x,y) )
    }

#===============================================================================

spatial.xy.rel.to.lower.left.by.row <- function (n, nrow, ncol, llcorner,  cellsize)    #**** the key function ****#
    {
<<<<<<< .mine
cat (file = debuggingOutputFile, "\n\nat START of spatial.xy.rel.to.lower.left.by.row()", append = TRUE)
=======
#####cat ("\n\nat START of spatial.xy.rel.to.lower.left.by.row()")
>>>>>>> .r362
    xy = xy.rel.to.lower.left.by.row (n, nrow, ncol)

###    return ( c (xllcorner + (cellsize * x), yllcorner + (cellsize * y) ) )
##    return (llcorner + (cellsize * xy))
#    return (llcorner + ((cellsize * xy) -(cellsize * 0.5)))

<<<<<<< .mine
#    cat (">>>> (xy - 0.5) = ", (xy - 0.5), ", cellsize = ", cellsize, ", llcorner = ", llcorner)
cat (file = debuggingOutputFile, "\n\nat END of spatial.xy.rel.to.lower.left.by.row()", append = TRUE)
=======
#    cat (">>>> (xy - 0.5) = ", (xy - 0.5), ", cellsize = ", cellsize, ", llcorner = ", llcorner)
#####cat ("\n\nat END of spatial.xy.rel.to.lower.left.by.row()")
#####cat ("\nretVal = ")
    retVal = (llcorner + (cellsize * (xy - 0.5)))
#####print (retVal)
>>>>>>> .r362

    return (llcorner + (cellsize * (xy - 0.5)))
    }

#===============================================================================

    #  Copied from read.R.


    #  THIS FUNCTION IS A REAL PAIN BECAUSE IT ASSUMES A VERY SPECIFIC
    #  WAY OF PASSING THE FILE IN AND I CAN NEVER REMEMBER IT, I.E.,
    #  FILE STEM WITHOUT THE ".ASC" AS THE FIRST ARGUMENT, THEN
    #  PATH TO DIRECTORY WHERE FILE IS STORED BUT MUST HAVE "/" ON THE
    #  END OF IT.
    #  WOULD LIKE TO BE ABLE TO PASS IT IN ANY WAY THAT I WANT AND THEN
    #  HAVE THE FUNCTION FIGURE OUT WHETHER SLASHES AND EXTENSIONS AND
    #  PATHS ARE NEEDED...
    #
    #  ALSO NEED TO HAVE IT INTERFACE WITH SOMETHING THAT RECOVERS ALL
    #  THE HEADER INFORMATION AND RETURNS THAT TOO.  I THINK THAT I'VE
    #  BUILT SOMETHING LIKE THAT IN PYTHON, BUT NEED TO TRACK IT DOWN.
    #  BTL - 2013.12.03


read.asc.file.to.matrix <-
#        function (base.asc.filename.to.read, input.dir = "./")
        function (base.asc.filename.to.read, input.dir = "")
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

#===============================================================================

    #  Copied from guppySupportFunctions.R

build.presence.sample =
    function (sample.presence.indices.into.true.presence.indices,
              true.presence.locs.x.y)
	{
		#-------------------------------------------------------------------
	    #  I'm doing this as a function so that the sampling method (and
	    #  any other errors in building the presence sample) can be hidden
	    #  from the calling program.
	    #  For the moment though, it's very simple.  It's just a straight
	    #  subsample of the original population with no errors.
		#-------------------------------------------------------------------

cat ("\n\n+++PYPER+++  STARTING build.presence.sample()")

cat ("\n\n+++  sample.presence.indices.into.true.presence.indices = '", sample.presence.indices.into.true.presence.indices, "'")
#cat ("\n\n+++  true.presence.locs.x.y = \n")
cat ("\n\n+++  head (true.presence.locs.x.y) = \n")
#print (true.presence.locs.x.y)
head (true.presence.locs.x.y)
cat ("\n")

	sample.locs.x.y =
	    true.presence.locs.x.y [sample.presence.indices.into.true.presence.indices,]

#	sample.presences.dataframe <-
#		data.frame (cbind (species[1:num.samples.to.take], sample.locs.x.y))
#	names (sample.presences.dataframe) <- c('species', 'longitude', 'latitude')

#	return (sample.presences.dataframe)

        #  Downstream uses expect the output to be a matrix, not a vector,
        #  so make sure that any single row outputs are converted to matrices.
    if (is.vector (sample.locs.x.y))
        sample.locs.x.y = matrix (sample.locs.x.y, nrow=1)

cat ("\n\n+++PYPER+++  ENDING build.presence.sample()")

	return (sample.locs.x.y)
	}

#===============================================================================

    #  Copied from createTruePresences.R, then modified to run more
    #  stand-alone rather than embedded in the R version of guppy.

genTruePresences = function (num.true.presences,    #  a vector, not a scalar

#                        prob.dist.layers.dir.with.slash,
                        sppGenOutputDirWithSlash,

                        trueProbDistFilePrefix,
                        cur.full.maxent.samples.dir.name
                        )
    {
cat ("\n\n+++PYPER+++  STARTING genTruePresences()")

    numSppToCreate = length (num.true.presences)
    combined.spp.true.presences.table = NULL

    all.spp.true.presence.locs.x.y =
            vector (mode="list", length=numSppToCreate)

cat ("\n\n+++PYPER+++  just before For Loop over numSppToCreate = ", numSppToCreate, " in genTruePresences()")

    for (spp.id in 1:numSppToCreate)
        {
cat ("\n\n+++PYPER+++  top of For Loop over numSppToCreate with spp.id = ", spp.id, " in genTruePresences()")
    #	spp.name <- paste ('spp.', spp.id, sep='')
        spp.name <- paste ('spp.', (spp.id - 1), sep='')    #  to match python...

            #----------------------------------------------------------------
            #  Get dimensions from relative probability matrix to use later
            #  and to make sure everything went ok.
            #----------------------------------------------------------------

    #	norm.prob.matrix = true.rel.prob.dists.for.spp [[spp.id]]
#        filename = paste (prob.dist.layers.dir.with.slash,
        filename = paste (sppGenOutputDirWithSlash,
                                    trueProbDistFilePrefix,
                                    ".", spp.name,
    #								'.asc',
                                    sep='')

#  BTL - 2013.11.22
#  IS THIS USING THE OLD ASCII READER OR THE NEW ONE?
#  LOOKS LIKE IT'S PROBABLY THE OLD ONE SINCE IT LOOKS LIKE IT'S RETURNING
#  A MATRIX RATHER THAN AN OBJECT.
#  THIS SEEMS TO BE HAPPENING IN BOTH Guppy.py AND IN genTruePresencesPyper.R.
#  DO I NEED BOTH A PYTHON AND AN R VERSION OF THIS?

        norm.prob.matrix = read.asc.file.to.matrix (filename)



        num.rows <- (dim (norm.prob.matrix)) [1]
        num.cols <- (dim (norm.prob.matrix)) [2]
        num.cells <- num.rows * num.cols

        cat ("\n\nnum.rows = ", num.rows)
        cat ("\nnum.cols = ", num.cols)
        cat ("\nnum.cells = ", num.cells)

        #===========================================================================

            #-------------------------------------------------------------
            #  Sample presences from the mapped probability distribution
            #  according to the true relative presence probabilities to
            #  get the TRUE PRESENCES.
            #-------------------------------------------------------------

<<<<<<< .mine
cat (file = debuggingOutputFile, "\n\nspp.id = ", spp.id, append = TRUE)
cat ("\nnum.true.presences = \n")
print (num.true.presences)
=======
cat ("\n\nspp.id = ", spp.id)
cat ("\nnum.true.presences = \n")
print (num.true.presences)
>>>>>>> .r362


        true.presence.indices <- sample (1:(num.rows * num.cols),
                                        num.true.presences [spp.id],
                                        replace = FALSE,
                                        prob = norm.prob.matrix)
<<<<<<< .mine
        cat ("\ntrue.presence.indices = \n")
        print (true.presence.indices)
=======
#        cat ("\ntrue.presence.indices = \n")
        cat ("\nhead (true.presence.indices) = \n")
#        print (true.presence.indices)
        head (true.presence.indices)
>>>>>>> .r362

            #----------------------------------------------------------------
            #  Convert the sample from single index values to x,y locations
            #  relative to the lower left corner of the map.
            #----------------------------------------------------------------

        true.presence.locs.x.y =
            matrix (rep (0, (num.true.presences [spp.id] * 2)),
                    nrow = num.true.presences [spp.id], ncol = 2, byrow = TRUE)


# cat ("\n\n******  HARD CODING llcorner AND cellsize in genTruePresencesPyper.R.  *****\n\n")
# ##2618380.652817
# ##2529528.47684
# llcorner = c (2618380.65282, 2529528.47684)
# cellsize = 75.0

            #  Variables related to .asc file header defining spatial
            #  origin, image dimensions, and resolution.
            #  These are currently passed in by Rassign call via pyper.
        num.cols = rNcols
        num.rows = rNrows
        llcorner = c (rXllcorner, rYllcorner)
        cellsize = rCellsize
        nodataValue = rNodataValue      #  probably not needed here...



<<<<<<< .mine
#####cat (file = debuggingOutputFile, "\n\nBEFORE for (cur.loc...)", append = TRUE)
=======
cat ("\n\nBEFORE for (cur.loc...)")
flush.console()

debugCtr = 0
curNumPresToGen = num.true.presences [spp.id]

>>>>>>> .r362
            #  Can probably replace this with an apply() call instead...
#        for (cur.loc in 1:num.true.presences [spp.id])
        for (cur.loc in 1:curNumPresToGen)
            {
cat ("\n\nIN for (cur.loc...) BEFORE spatial.xy.rel.to.lower.left.by.row(), cur.loc = ", cur.loc)
debugCtr = debugCtr + 1
cat ("\ndebugCtr = ", debugCtr, " / ", curNumPresToGen)
#            true.presence.locs.x.y [cur.loc, ] =
#                xy.rel.to.lower.left (true.presence.indices [cur.loc], num.rows,
#                                        num.cols)

            true.presence.locs.x.y [cur.loc, ] =
#                spatial.xy.rel.to.lower.left (true.presence.indices [cur.loc],
                spatial.xy.rel.to.lower.left.by.row (true.presence.indices [cur.loc],
                                                num.rows, num.cols,
                                                llcorner, cellsize
                                                )
cat ("\n\nIN for (cur.loc...) AFTER spatial.xy.rel.to.lower.left.by.row()")

            }
<<<<<<< .mine
#####cat (file = debuggingOutputFile, "\n\nAFTER for (cur.loc...)", append = TRUE)
=======
cat ("\n\nAFTER for (cur.loc...)")
cat ("\n\ntrue.presence.locs.x.y = ")
print (true.presence.locs.x.y)
>>>>>>> .r362

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

        species <- rep (spp.name, num.true.presences [spp.id])
        true.presences.table <-
            data.frame (cbind (species, true.presence.locs.x.y))
        names (true.presences.table) <- c('species', 'longitude', 'latitude')

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
        outfile.root <- paste (spp.name, ".truePres", sep='')
        ###sampled.presences.filename <- paste (samples.dir, outfile.root, ".csv", sep='')
    ##	true.presences.filename <- paste (samples.dir, outfile.root, ".csv", sep='')
        true.presences.filename <- paste (cur.full.maxent.samples.dir.name, "/",
                                            outfile.root, ".csv", sep='')
<<<<<<< .mine
        cat ("\n\ntrue.presences.filename = '", true.presences.filename, "'", sep='')
#####cat (file = debuggingOutputFile, "\n\nbefore write.csv (true.presences.table...)", append = TRUE)
=======
        cat ("\n\ntrue.presences.filename = '", true.presences.filename, "'", sep='')
cat ("\n\nbefore write.csv (true.presences.table...)")
>>>>>>> .r362

        write.csv (true.presences.table,
        ###  	   file = sampled.presences.filename,
               file = true.presences.filename,
                   row.names = FALSE,
                   quote=FALSE)


        all.spp.true.presence.locs.x.y [[spp.id]] = true.presence.locs.x.y

            #-----------------------------------------------------------------
            #  Append the true presences to a combined table of presences
            #  for all species.
            #-----------------------------------------------------------------

        combined.spp.true.presences.table <-
            rbind (combined.spp.true.presences.table, true.presences.table)

        #===========================================================================

<<<<<<< .mine
#####cat (file = debuggingOutputFile, "\n\n+++PYPER+++  bottom of For Loop over numSppToCreate in genTruePresences()", append = TRUE)
=======
cat ("\n\n+++PYPER+++  bottom of For Loop over numSppToCreate in genTruePresences()")
>>>>>>> .r362

        }  #  end for - all species

    #-------------------------------------------

    cat ("\n\ncombined.spp.true.presences.table = \n")
    print (combined.spp.true.presences.table)

    cat ("\n\nall.spp.true.presence.locs.x.y = \n")
    print (all.spp.true.presence.locs.x.y)

    cat ("\n\n")

        #  This last bit is copied from saveCombinedPresencesForMaxent.R.
        #  That looks like the only place where the
        #  combined.spp.true.presences.table was every used in the old R
        #  version of guppy and all that function did was write the combined
        #  true presences and the combined sampled presences out.
        #  I have just moved the writing of the combined true presences
        #  into here so that nothing has to be returned from this routine.
	combined.true.presences.filename =
						paste (cur.full.maxent.samples.dir.name, "/",
							   "spp.truePres.combined", ".csv", sep='')
	write.csv (combined.spp.true.presences.table,
			   file = combined.true.presences.filename,
			   row.names = FALSE,
			   quote=FALSE)

#####cat ("\n\n+++PYPER+++  ENDING genTruePresences()")

    return (all.spp.true.presence.locs.x.y)
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

createSampledPresences = function (num.true.presences,
                                    all.spp.true.presence.locs.x.y,
                                    PAR.use.all.samples,
                                    cur.full.maxent.samples.dir.name,
                                    combinedPresSamplesFileName
                                    )
    {
cat ("\n\n+++PYPER+++  STARTING createSampledPresences()")

    numSppToCreate = length (num.true.presences)
    combined.spp.sampled.presences.table = NULL

        #  This is just a hack for now.
        #  Need to figure out a better way to pass in arrays of numbers of
        #  true sample sizes and subsample sizes.
    PAR.num.samples.to.take = num.true.presences
    if (! PAR.use.all.samples)
        {
        PAR.num.samples.to.take = as.integer (num.true.presences / 2)
        }

    for (spp.id in 1:numSppToCreate)
        {
        spp.name <- paste ('spp.', (spp.id - 1), sep='')    #  to match python...

        sampled.locs.x.y = NULL
        sample.presence.indices.into.true.presence.indices =
            1:(num.true.presences [spp.id])

        if (PAR.use.all.samples)
          {
          sampled.locs.x.y = all.spp.true.presence.locs.x.y [[spp.id]]

          } else
          {
          num.samples.to.take = min (num.true.presences [spp.id], PAR.num.samples.to.take [spp.id])

          sample.presence.indices.into.true.presence.indices =
                sample (1:(num.true.presences [spp.id]),
                        num.samples.to.take,
                        replace=FALSE)  #  Should this be WITH rep instead?

          sampled.locs.x.y <-
              build.presence.sample (sample.presence.indices.into.true.presence.indices,
                                     all.spp.true.presence.locs.x.y [[spp.id]])
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

        species <- rep (spp.name, num.samples.to.take)

            #  The cbind that follows this will misbehave if sampled.locs.x.y
            #  is a vector instead of a matrix.  This was happening when there
            #  was only one xy pair in sampled.locs.x.y and the routine that
            #  was building it didn't explicitly turn that into a 1 row matrix
            #  and this routine thought it was a 2 row x 1 column column vector.
            #  I think I've fixed that, but this little safety check will
            #  catch it if not.
        if (is.vector (sampled.locs.x.y))
            sampled.locs.x.y = matrix (sampled.locs.x.y, nrow=1)

        sampled.presences.table <-
            data.frame (cbind (species, sampled.locs.x.y))
                #  old version of this line that I think is an error
    #		data.frame (cbind (species [1:num.samples.to.take], sampled.locs.x.y))

    #-------------------

        names (sampled.presences.table) <- c('species', 'longitude', 'latitude')

            #--------------------------------------------------------------
            #  Write the sampled presences out to a .csv file that can be
            #  fed to maxent.
            #--------------------------------------------------------------

        outfile.root <- paste (spp.name, ".sampledPres", sep='')
        sampled.presences.filename <- paste (cur.full.maxent.samples.dir.name, "/",
                                             outfile.root, ".csv", sep='')
        write.csv (sampled.presences.table,
                   file = sampled.presences.filename,
                   row.names = FALSE,
                   quote=FALSE)

            #-----------------------------------------------------------------
            #  Append the sampled presences to a combined table of presences
            #  for all species.
            #-----------------------------------------------------------------

        combined.spp.sampled.presences.table <-
            rbind (combined.spp.sampled.presences.table, sampled.presences.table)

        #===============================================================================

        }  #  end for - each species

    #-------------------------------------------

<<<<<<< .mine
    cat ("\n\ncombined.spp.sampled.presences.table = \n")
    print (combined.spp.sampled.presences.table)
=======
    cat ("\n\ncombined.spp.sampled.presences.table = \n")
    print (combined.spp.sampled.presences.table)
    cat ("\n\n")
>>>>>>> .r362

    cat ("\n\n")

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
	combined.sampled.presences.filename =
#						paste (cur.full.maxent.samples.dir.name, "/",
#							   "spp.sampledPres.combined", ".csv", sep='')
                        combinedPresSamplesFileName
	write.csv (combined.spp.sampled.presences.table,
			   file = combined.sampled.presences.filename,
			   row.names = FALSE,
			   quote=FALSE)

    #-------------------------------------------
    #-------------------------------------------

cat ("\n\n+++PYPER+++  ENDING createSampledPresences()")

#    return (combined.spp.sampled.presences.table)
    }

#===============================================================================

genPresences = function (num.true.presences,    #  a vector, not a scalar

#                        prob.dist.layers.dir.with.slash,
                        sppGenOutputDirWithSlash,

                        trueProbDistFilePrefix,
                        cur.full.maxent.samples.dir.name,
                        PAR.use.all.samples,
                        combinedPresSamplesFileName,
                        randomSeed
                        )
    {
debuggingOutputFile = file (debuggingOutputFileName, open="wt")

#sink (debuggingOutputFileName, type=c("output","message"), append=TRUE)
#sink (debuggingOutputFile, type=c("output","message"), append=TRUE)
sink (debuggingOutputFile, type=c("output","message"))

cat ("\n\n+++PYPER+++  STARTING genPresences()")

            #sppId = [1..numSppToCreate]
cat ('\n             rSppId = ', rSppId)

            #numTruePresences = [3,5,6]
cat ('\n             rNumTruePresences = ', rNumTruePresences)

            #probDistLayersDirWithSlash = '/Users/Bill/tzar/outputdata/Guppy/default_runset/156_Scen_1/MaxentProbDistLayers/'
#cat ('\n             rProbDistLayersDirWithSlash = ', rProbDistLayersDirWithSlash)

            #trueProbDistFilePrefix = 'true.prob.dist'
cat ('\n             rTrueProbDistFilePrefix = ', rTrueProbDistFilePrefix)
            #            Rcaller.assign ('rTrueProbDistFilePrefix', self.variables ["PAR.trueProbDistFilePrefix"])

            #curFullMaxentSamplesDirName = '/Users/Bill/tzar/outputdata/Guppy/default_runset/156_Scen_1/MaxentSamples'
cat ('\n             rCurFullMaxentSamplesDirName = ', rCurFullMaxentSamplesDirName)

            #PARuseAllSamples = False
cat ('\n             rPARuseAllSamples = ', rPARuseAllSamples)

            #combinedPresSamplesFileName = curFullMaxentSamplesDirName + "/" + "spp.sampledPres.combined" + ".csv"
cat ('\n             rCombinedPresSamplesFileName = ', rCombinedPresSamplesFileName)

            #randomSeed = 1
cat ('\n             rRandomSeed = ', rRandomSeed)

cat ('\n\nAbout to set.seed()')

#####    set.seed (randomSeed)
    set.seed (rRandomSeed)

cat ('\nAbout to unlist()')

        #  When I create a vector in python as x = [1,2,5], it gets passed
        #  in here as a list of lists, so I need to flatten the list into
        #  a vector since that's what the functions in here are expecting.
    num.true.presences = unlist (num.true.presences)

cat ('\nAbout to genTruePresences()')

    all.spp.true.presence.locs.x.y =
        genTruePresences (num.true.presences,

#                            prob.dist.layers.dir.with.slash,
                            sppGenOutputDirWithSlash,

                            trueProbDistFilePrefix,
                            cur.full.maxent.samples.dir.name
                            )

cat ('\nAbout to createSampledPresences()')

    createSampledPresences (num.true.presences,
                            all.spp.true.presence.locs.x.y,
                            PAR.use.all.samples,
                            cur.full.maxent.samples.dir.name,
                            combinedPresSamplesFileName
                            )


sink ()
close (debuggingOutputFile)

cat ("\n\n+++PYPER+++  ENDING genPresences()")
    }

#===============================================================================

testing = FALSE
if (testing)
    {
    num.true.presences = c(3,5,6)
    probDistLayersDirWithSlash = '/Users/Bill/tzar/outputdata/Guppy/default_runset/156_Scen_1/MaxentProbDistLayers/'
    trueProbDistFilePrefix = 'true.prob.dist'
    cur.full.maxent.samples.dir.name = '/Users/Bill/tzar/outputdata/Guppy/default_runset/156_Scen_1/MaxentSamples'
    PAR.use.all.samples = FALSE
    combinedPresSamplesFileName = paste (cur.full.maxent.samples.dir.name, "/",
        							   "spp.sampledPres.combined", ".csv", sep='')

cat ("\nIn main, combinedPresSamplesFileName = '", combinedPresSamplesFileName, "'\n")

    randomSeed = 1

    genPresences (num.true.presences,
                    probDistLayersDirWithSlash,
                    trueProbDistFilePrefix,
                    cur.full.maxent.samples.dir.name,
                    PAR.use.all.samples,
                    combinedPresSamplesFileName,
                    randomSeed
                    )
    }

#===============================================================================

