#=========================================================================================

#                               genCombinedSppPresTable.R

# source( 'genCombinedSppPresTable.R' )

#=========================================================================================

#  History:

#  2013.04.18 - BTL
#  Cloned from genTruePresences() in createTruePresences.R.

#=========================================================================================

genCombinedSppPresTable = function (num.img.rows, num.cells)
	{
	num.spp = variables$PAR.num.spp.to.create
	minNumPres = variables$PAR.minNumPres
	maxNumPres = variables$PAR.maxNumPres

	combinedSppPresTable = NULL

	numPresForEachSpp = sample (minNumPres:maxNumPres,
								num.spp, replace=TRUE)

	cat ("\n\nnumPresForEachSpp = ", numPresForEachSpp)

	for (spp.id in 1:num.spp)
		{
		spp.name <- paste ('spp.', spp.id, sep='')

		presIndices <- sample (1:num.cells,
									numPresForEachSpp [spp.id],
									replace = FALSE)
		cat ("\n\npresIndices for spp.id ", spp.id, " = ", presIndices)

		presLocsXY =
			matrix (rep (0, (numPresForEachSpp [spp.id] * 2)),
					nrow = numPresForEachSpp [spp.id], ncol = 2, byrow = TRUE)

			#  Can probably replace this with an apply() call instead...
		for (curPresIdx in 1:numPresForEachSpp [spp.id])
			{
			presLocsXY [curPresIdx, ] =
				xy.rel.to.lower.left (presIndices [curPresIdx],
									  num.img.rows)
			}

		species <- rep (spp.name, numPresForEachSpp [spp.id])
		PresTable <-
			data.frame (cbind (species, presLocsXY))
		names (PresTable) <- c('species', 'longitude', 'latitude')

		combinedSppPresTable <-
			rbind (combinedSppPresTable, PresTable)
		}

	return (combinedSppPresTable)
	}

#=========================================================================================

