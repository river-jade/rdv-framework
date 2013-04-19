#=========================================================================================

#                               createTruePresences.R

# source( 'createTruePresences.R' )

#=========================================================================================

#  History:

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#=========================================================================================

genTruePresences = function (num.true.presences)
{
for (spp.id in 1:variables$PAR.num.spp.to.create)
	{
	spp.name <- paste ('spp.', spp.id, sep='')

		#----------------------------------------------------------------
		#  Get dimensions from relative probability matrix to use later
		#  and to make sure everything went ok.
		#----------------------------------------------------------------

	norm.prob.matrix = true.rel.prob.dists.for.spp [[spp.id]]

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
			xy.rel.to.lower.left (true.presence.indices [cur.loc], num.rows)
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

		#-----------------------------------------------------------------
		#  Append the true presences to a combined table of presences
		#  for all species.
		#-----------------------------------------------------------------

	combined.spp.true.presences.table <-
		rbind (combined.spp.true.presences.table, true.presences.table)

	#===============================================================================

	}  #  end for - all species

return (list (combined.spp.true.presences.table=combined.spp.true.presences.table,
				true.presence.locs.x.y=true.presence.locs.x.y))
}

#=========================================================================================

