#===============================================================================

						#  computeTrueRelProbDist.v4.R

#  Compute the true relative probability distribution for each species.

#  Make up a fake rule for how the matrices combine to form a
#  probability distribution over the image.
#  In this case, just make it be the pixelwise product of the two images.

#===============================================================================

#  source ('computeTrueRelProbDist.R')

#  History:

#  2013.04.16 - BTL -  v4
#  Abandoning the S4 nonsense.  Reverting to v2 version of this file.

#  2013.04.16 - BTL -  v3
#  Trying to convert this to S4 objects, but once again, it's proving difficult
#  to figure out how to phrase things since the R documentation tends to only
#  give examples for methods like "plot", rather than more complicated things
#  that I want to do.  Plus, I can't see the command to do the setGeneric()
#  for plot() and that means I'm uncertain how to mimic it.  This is probably
#  a complete waste of time and I should just get something working now and
#  do the oop stuff in python instead of endlessly screwing around with
#  guessing the appropriate syntax and trickery for S4 in R.

#  2013.04.14 - BTL -  v2
#  Pulling out the bit that writes the matrix to a file and moving it up a
#  couple of levels to the file computeSppDistributions.R since that's
#  where the true prob distribution is built.  Here you're only normalizing
#  any matrix that you're handed, so it shouldn't be writing the matrix to
#  a file as the true probability distribution.

#  2013 04 04 - BTL - v1
#  Extracted from guppy.test.maxent.v9.R.

#===============================================================================

#  NOTE: This section that computes a probability distribution by combining
#        environment layers is Extremely simplistic right now.
#        The beginnings of a more complex version of it can be found in
#        Desktop/MaxentTests/test.maxent.v4.R where things like hinge functions
#        are mentioned.  I think that is where I was working on it at Austin ESA
#        but ran out of time and reverted back to this very simple version.
#        I think that there may be some better examples in a Dorfmann paper
#        that simulated various species, but I think the paper is at home.
#        I think that he had 3 main classes of combining functions.
#        BTL - 2011.09.22

#===============================================================================

normalize.prob.distribution.from.env.layers = function (rel.prob.matrix)
        #normalize.prob.distribution.from.env.layers <- function (env.layers)
	{
		#--------------------------------------------------------------------------
    	#  Normalize the values to get a probability distribution over the image,
    	#  i.e., make them all sum to one.
		#--------------------------------------------------------------------------

	#cat ("\nAt start of normalize.prob...()\n")


	tot.rel.prob.matrix <- sum (rel.prob.matrix)
	cat ("\ntot.rel.prob.matrix = ", tot.rel.prob.matrix, "\n")

	norm.prob.matrix <- rel.prob.matrix / tot.rel.prob.matrix
	cat ("\nsum of norm.prob.matrix = ", sum (norm.prob.matrix), " (should = 1).\n")

	return (norm.prob.matrix)
	}

#===============================================================================

computeRelProbDist.ARITH = function (spp.id, spp.name, env.layers, num.env.layers)
	{
	cat ("\n\nin computeRelProbDist, num.env.layers = '", num.env.layers, "'\n\n", sep='')
	cat ("\n\nlength (env.layers) = '", length (env.layers), "'\n\n", sep='')

	norm.prob.matrix = NULL

	if (PAR.use.old.maxent.output.for.input)
		{
		norm.prob.matrix =
			read.asc.file.to.matrix (
									spp.name,
#									paste (spp.name, ".asc", sep=''),
									PAR.old.maxent.output.dir)

		norm.prob.matrix <-
				normalize.prob.distribution.from.env.layers (norm.prob.matrix)

		} else
		{

		rel.prob.matrix <- matrix ()

		if (spp.id == 1)
			{
			combination.rule <- CONST.product.rule

			} else
			{
			combination.rule <- CONST.add.rule
			}

		if (combination.rule == CONST.product.rule)
			{
			cat ("\n\nusing product rule\n")
			rel.prob.matrix = env.layers [[1]]
			cat ("\n\nlength (env.layers) BEFORE product = '", length (env.layers), "'\n\n", sep='')
			for (cur.env.layer.idx in 2:num.env.layers)
				{
				cat ("\n\ndim (rel.prob.matrix) BEFORE product = '", dim (rel.prob.matrix), "'\n\n")
				cat ("\n\nclass (rel.prob.matrix) BEFORE product = '", class (rel.prob.matrix), "'\n\n", sep='')
				cat ("\n\nrel.prob.matrix [1:3,1:3] = \n", rel.prob.matrix [1:3,1:3], "\n", sep='')    #  Echo a bit of the result...
				for (row in 1:3)
					{
					for (col in 1:3)
						{
						cat ("\nrel.prob.matrix [", row, ", ", col, "] = ", rel.prob.matrix [row, col], ", and class = ", class(rel.prob.matrix[row,col]), sep='')
						}
					}
				#*****#
				#cat ("\n\n    All done     \n\n")
				#stop ("\nSTOP\n")
				#*****#

				cat ("\n\ndim (rel.prob.matrix) BEFORE product = '", dim (rel.prob.matrix), "'\n\n", sep='')
				cat ("\n\nenv.layers [[cur.env.layer.idx]] [1:3,1:3] = \n", env.layers [[cur.env.layer.idx]] [1:3,1:3], "\n", sep='')    #  Echo a bit of the result...
				for (row in 1:3)
					{
					for (col in 1:3)
						{
						cat ("\nenv.layers [[cur.env.layer.idx]] [", row, ", ", col, "] = ", env.layers [[cur.env.layer.idx]][row,col], ", and class = ", class(env.layers [[cur.env.layer.idx]][row,col]), sep='')
						}
					}

				rel.prob.matrix <- rel.prob.matrix * env.layers [[cur.env.layer.idx]]
				cat ("\n\ndim (rel.prob.matrix) AFTER product = '", dim (rel.prob.matrix), "'\n\n", sep='')
				}

			} else  #  comb rule is not product
			{
			if (combination.rule == CONST.add.rule)
				{
				cat ("\n\nusing add rule\n")
				rel.prob.matrix = env.layers [[1]]
				for (cur.env.layer.idx in 2:num.env.layers)
					{
					rel.prob.matrix <- rel.prob.matrix + env.layers [[cur.env.layer.idx]]
					}

				} else  #  unknown comb rule
				{
				stop ("\n\nUndefined combination rule for environmental layers.\n\n")
				}

			}  #  end else comb rule is not product

		cat ("\n\ndim (rel.prob.matrix) = '", dim (rel.prob.matrix), "'\n\n", sep='')

		print (rel.prob.matrix [1:3,1:3])    #  Echo a bit of the result...

		norm.prob.matrix <-
				normalize.prob.distribution.from.env.layers (rel.prob.matrix)

		}  #  end else - do not use old maxent output as input

	return (norm.prob.matrix)
	}

#===============================================================================

