#===============================================================================

#                       saveCombinedPresencesForMaxent.R

# source( 'saveCombinedPresencesForMaxent.R' )

#===============================================================================

#  History:

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#===============================================================================

	#--------------------------------------------------------------
	#  Write the combined presences out to .csv files that can be
	#  fed to maxent.
	#--------------------------------------------------------------

saveCombinedPresencesForMaxent =
		function (combined.spp.true.presences.table,
				  combined.spp.sampled.presences.table)
	{
	combined.true.presences.filename =
						paste (cur.full.maxent.samples.dir.name, "/",
							   "spp.truePres.combined", ".csv", sep='')
	write.csv (combined.spp.true.presences.table,
			   file = combined.true.presences.filename,
			   row.names = FALSE,
			   quote=FALSE)

		#-----

	combined.sampled.presences.filename =
						paste (cur.full.maxent.samples.dir.name, "/",
							   "spp.sampledPres.combined", ".csv", sep='')
	write.csv (combined.spp.sampled.presences.table,
			   file = combined.sampled.presences.filename,
			   row.names = FALSE,
			   quote=FALSE)
	}

#===============================================================================


