#===============================================================================
#===============================================================================

computeTrueRelProbDistSrc = paste (pathToRfiles, 'computeTrueRelProbDist.R', sep='')
cat ("\n\ncomputeTrueRelProbDistSrc = '", computeTrueRelProbDistSrc, "'", sep='')

source (computeTrueRelProbDistSrc)		#  probably should move to function file

#===============================================================================

	#---------------------------------------------------------------
	#  Determine the number of true presences for each species.
	#  At the moment, you can specify the number of true presences
	#  drawn for each species either by specifying a count for each
	#  species to be created or by specifying the bounds of a
	#  random fraction for each species.  The number of true
	#  presences will then be that fraction multiplied times the
	#  total number of pixels in the map.
	#---------------------------------------------------------------

if (variables$PAR.use.random.num.true.presences)
	{
		#  Draw random true presence fractions and then convert them
		#  into counts.
	spp.true.presence.fractions.of.landscape =
		runif (variables$PAR.num.spp.to.create,
			   min = PAR.min.true.presence.fraction.of.landscape,
			   max = PAR.max.true.presence.fraction.of.landscape)

	#spp.true.presence.fractions.of.landscape = c (50/num.cells, 100/num.cells)
	cat ("\n\nspp.true.presence.fractions.of.landscape = \n")
	print (spp.true.presence.fractions.of.landscape)

	spp.true.presence.cts = num.cells * spp.true.presence.fractions.of.landscape
	cat ("\nspp.true.presence.cts = ")
	print (spp.true.presence.cts)

	num.true.presences = spp.true.presence.cts
	cat ("\nnum.true.presences = ", num.true.presences)

	} else  #  Use fixed counts specified in the yaml file.
	{
	num.true.presences = variables$PAR.num.true.presences

	cat ("\n\nnum.true.presences = '",
			num.true.presences, "'", sep='')
	cat ("\nclass (num.true.presences) = '",
			class (num.true.presences), "'")
	cat ("\nis.vector (num.true.presences) = '",
			is.vector (num.true.presences), "'", sep='')
	cat ("\nis.list (num.true.presences) = '",
			is.list (num.true.presences), "'", sep='')
	cat ("\nlength (num.true.presences) = '",
			length (num.true.presences), "'", sep='')
	for (i in 1:length (num.true.presences))
		cat ("\n\tnum.true.presences [", i, "] = ",
				num.true.presences[i], sep='')

	if (length (num.true.presences) < PAR.num.spp.to.create)
		{
		cat ("\n\nlength(PAR.num.true.presences) = '",
				length(variables$PAR.num.true.presences),
				"' but \nPAR.num.spp.to.create = '", PAR.num.spp.to.create,
				"'.\nMust specify at least as many presence cts as ",
				"species to be created.\n\n", sep='')
		stop ()
		}
	}

PAR.use.all.samples = variables$PAR.use.all.samples

    #  This is just a hack for now.
    #  Need to figure out a better way to pass in arrays of numbers of
    #  true sample sizes and subsample sizes.
PAR.num.samples.to.take = num.true.presences
if (! PAR.use.all.samples)
    {
    PAR.num.samples.to.take = num.true.presences / 2
    }

#===============================================================================

true.rel.prob.dists.for.spp =
	vector (mode="list", length=variables$PAR.num.spp.to.create)
#true.rel.prob.dists.for.spp = list ()

for (spp.id in 1:variables$PAR.num.spp.to.create)
	{
	spp.name <- paste ('spp.', spp.id, sep='')

		#-----------------------------------------------------------------------
		#  Compute the true relative probability distribution for each species.
		#  This is where the generated equation is built and invoked, e.g.,
		#  adding or multiplying the env layers together to create a
		#  probability of presence of the current species at each pixel.
		#  The distribution that is generated is a relative distribution
		#  in that it does not give the probability of finding the species at
		#  that pixel in general.  It just gives a distribution of the
		#  relative probability of finding the species at that pixel compared
		#  to any other pixel in the bounds of this map.  It is intended to
		#  be used for drawing any given number of occurrences from the map
		#  rather than the actual probability that there will be something
		#  at each pixel.  To get that value, you would need to do something
		#  like taking the relative probabilities and choosing a threshold
		#  value below which you say the habitat is not suitable.  You could
		#  then consider all locations above the threshold to have a presence
		#  (and thereby derive the number of occurrences (i.e., abundance))
		#  instead of specifying it ahead of time as is done when generating
		#  occurrences directly from the relative distribution.  I think that
		#  some of the maxent papers may also specify some way of turning the
		#  relative probabilities (essentially "suitabilities") into true
		#  probabilities, but I can't remember where at the moment.
		#-----------------------------------------------------------------------

	norm.prob.matrix =
		computeRelProbDist (spp.id, spp.name, env.layers, num.env.layers)

	true.rel.prob.dists.for.spp [[spp.id]] = norm.prob.matrix
			##	last = length (true.rel.prob.dists.for.spp) + 1
			##	true.rel.prob.dists.for.spp [[last]] = norm.prob.matrix

	}  #  end for - all species

