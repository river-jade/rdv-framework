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

    #  Copied from guppySupportFunctions.R

xy.rel.to.lower.left <- function (n, nrow, ncol)    #**** the key function ****#
	{
	n.minus.1 <- n - 1
	return ( c (1 + (n.minus.1 %/% ncol),
			    nrow - (n.minus.1 %% nrow)
			   )
		   )
	}

#===============================================================================

    #  Copied from read.R.

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
cat ("\n\n+++  true.presence.locs.x.y = \n")
print (true.presence.locs.x.y)
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
                        prob.dist.layers.dir.with.slash,
                        trueProbDistFilePrefix,
                        cur.full.maxent.samples.dir.name
                        )
    {
cat ("\n\n+++PYPER+++  STARTING genTruePresences()")

    numSppToCreate = length (num.true.presences)
    combined.spp.true.presences.table = NULL

    all.spp.true.presence.locs.x.y =
            vector (mode="list", length=numSppToCreate)

    for (spp.id in 1:numSppToCreate)
        {
    #	spp.name <- paste ('spp.', spp.id, sep='')
        spp.name <- paste ('spp.', (spp.id - 1), sep='')    #  to match python...

            #----------------------------------------------------------------
            #  Get dimensions from relative probability matrix to use later
            #  and to make sure everything went ok.
            #----------------------------------------------------------------

    #	norm.prob.matrix = true.rel.prob.dists.for.spp [[spp.id]]
        filename = paste (prob.dist.layers.dir.with.slash,
                                    trueProbDistFilePrefix,
                                    ".", spp.name,
    #								'.asc',
                                    sep='')
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

cat ("\n\nspp.id = ", spp.id, "\nnum.true.presences = \n")
print (num.true.presences)


        true.presence.indices <- sample (1:(num.rows * num.cols),
                                        num.true.presences [spp.id],
                                        replace = FALSE,
                                        prob = norm.prob.matrix)
        cat ("\ntrue.presence.indices = \n")
        print (true.presence.indices)

            #----------------------------------------------------------------
            #  Convert the sample from single index values to x,y locations
            #  relative to the lower left corner of the map.
            #----------------------------------------------------------------

        true.presence.locs.x.y =
            matrix (rep (0, (num.true.presences [spp.id] * 2)),
                    nrow = num.true.presences [spp.id], ncol = 2, byrow = TRUE)

            #  Can probably replace this with an apply() call instead...
        for (cur.loc in 1:num.true.presences [spp.id])
            {
            true.presence.locs.x.y [cur.loc, ] =
                xy.rel.to.lower.left (true.presence.indices [cur.loc], num.rows,
                                        num.cols)
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
        cat ("\n\ntrue.presences.filename = '", true.presences.filename, "'", sep='')

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

cat ("\n\n+++PYPER+++  ENDING genTruePresences()")

    return (all.spp.true.presence.locs.x.y)
    }

#===============================================================================

		#---------------------------------------------------------------------
		#  Have now finished generating the true occurrences of the species.
		#  Ready to simulate the sampling of the species to generate a
		#  sampled occurrence layer to feed to maxent.
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

    cat ("\n\ncombined.spp.sampled.presences.table = \n")
    print (combined.spp.sampled.presences.table)

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
                        prob.dist.layers.dir.with.slash,
                        trueProbDistFilePrefix,
                        cur.full.maxent.samples.dir.name,
                        PAR.use.all.samples,
                        combinedPresSamplesFileName,
                        randomSeed
                        )
    {
cat ("\n\n+++PYPER+++  STARTING genPresences()")

    set.seed (randomSeed)

        #  When I create a vector in python as x = [1,2,5], it gets passed
        #  in here as a list of lists, so I need to flatten the list into
        #  a vector since that's what the functions in here are expecting.
    num.true.presences = unlist (num.true.presences)

    all.spp.true.presence.locs.x.y =
        genTruePresences (num.true.presences,
                            prob.dist.layers.dir.with.slash,
                            trueProbDistFilePrefix,
                            cur.full.maxent.samples.dir.name
                            )

    createSampledPresences (num.true.presences,
                            all.spp.true.presence.locs.x.y,
                            PAR.use.all.samples,
                            cur.full.maxent.samples.dir.name,
                            combinedPresSamplesFileName
                            )
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

