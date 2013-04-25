#=========================================================================================

#                               createSampledPresences.R

# source( 'createSampledPresences.R' )

#=========================================================================================

#  History:

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#=========================================================================================

		#---------------------------------------------------------------------
		#  Have now finished generating the true occurrences of the species.
		#  Ready to simulate the sampling of the species to generate a
		#  sampled occurrence layer to feed to maxent.
		#---------------------------------------------------------------------

createSampledPresences = function (num.true.presences, all.spp.true.presence.locs.x.y)
{
    #  This is just a hack for now.
    #  Need to figure out a better way to pass in arrays of numbers of
    #  true sample sizes and subsample sizes.
PAR.num.samples.to.take = num.true.presences
if (! PAR.use.all.samples)
    {
    PAR.num.samples.to.take = as.integer (num.true.presences / 2)
    }

for (spp.id in 1:variables$PAR.num.spp.to.create)
	{
	spp.name <- paste ('spp.', spp.id, sep='')

	sampled.locs.x.y = NULL
	sample.presence.indices.into.true.presence.indices =
		1:(num.true.presences [spp.id])

	if (PAR.use.all.samples)
	  {
	  sampled.locs.x.y = all.spp.true.presence.locs.x.y [[spp.id]]

	  } else
	  {
	  num.samples.to.take = min (num.true.presences [spp.id], PAR.num.samples.to.take)
	  sample.presence.indices.into.true.presence.indices =
			sample (1:(num.true.presences [spp.id]),
					num.samples.to.take,
					replace=FALSE)  #  Should this be WITH rep instead?
cat ("\n\n>>>  num.samples.to.take = '", num.samples.to.take, "'", sep='')
cat ("\n\n>>>  num.true.presences [", spp.id, "] = '", num.true.presences [spp.id], "'", sep='')
cat ("\n\n>>>  sample.presence.indices.into.true.presence.indices = '", sample.presence.indices.into.true.presence.indices, "'")
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
#	species <- rep (spp.name, num.samples.to.take [spp.id])
	species <- rep (spp.name, num.samples.to.take)

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

return (combined.spp.sampled.presences.table)
}

#===============================================================================

