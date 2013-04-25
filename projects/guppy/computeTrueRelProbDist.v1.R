#===============================================================================

						#  computeTrueRelProbDist.R

#  Compute the true relative probability distribution for each species.

#  Make up a fake rule for how the matrices combine to form a
#  probability distribution over the image.
#  In this case, just make it be the pixelwise product of the two images.

#===============================================================================

#  source ('computeTrueRelProbDist.R')

#  History:
#		2013 04 04 - BTL
#			Extracted from guppy.test.maxent.v9.R.

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

CONST.product.rule = variables$CONST.product.rule
CONST.add.rule = variables$CONST.add.rule

#===============================================================================

normalize.prob.distribution.from.env.layers <- function (rel.prob.matrix)
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

	#---------------------------------------------------------------------------
	#  May want to move all this file writing a couple of levels higher in
	#  the calling chain.  At the upper levels, I couldn't figure out where
	#  the true probability map was being written out and this isn't a
	#  function for creating the true prob dist.  It's a function for
	#  normalizing that could be called by any other routine, not just by
	#  the one computing true prob of presence.
	#  BTL - 2013.04.14
	#---------------------------------------------------------------------------
		#--------------------------------------------------------------------------------
		#  Write the normalized distribution to a csv image so that it can
		#  be inspected later if you want.
		#  May want to write to something other than csv, but it's easy for
		#  the moment.
		#
		#  One small problem:
    	#  Can't seem to get write.csv() to leave off the column headings,
    	#  no matter what options I choose.  R even complains if I use the
    	#  col.names=NA option as advertised in the help file.
    	#
    	#  On the web, I did find a write.matrix() function in MASS that
    	#  doesn't add the column headings, but it's much slower than
		#  write.csv() so I won't use it at this point.
		#      library (MASS)
		#      write.matrix (norm.prob.matrix, file = true.prob.dist.filename, sep=',')
		#--------------------------------------------------------------------------------

  filename.root = paste (prob.dist.layers.dir, "/true.prob.dist.", spp.name, sep='')
  num.img.rows = dim (norm.prob.matrix)[1]
  num.img.cols = dim (norm.prob.matrix)[2]

	true.prob.dist.csv.filename <- paste (filename.root, ".csv", sep='')
	cat ("\nWriting norm.tot.prod.matrix to ", true.prob.dist.csv.filename, "\n", sep='')
	write.csv (norm.prob.matrix, file = true.prob.dist.csv.filename, row.names = FALSE)

  cat ("\nWriting norm.tot.prod.matrix to ", filename.root, ".asc", "\n", sep='')
      #  NOTE:
      # Both the maxent env input layers (e.g., H05_1.asc) and the maxent
      # output layers have the following header when the image is 256x256:

      # ncols         256
      # nrows         256
      # xllcorner     1
      # yllcorner     1
      # cellsize      1
      # NODATA_value  -9999

      # Running write.asc() with the defaults gives the following header,
      # which Zonation chokes on (I think that it thinks all values are 0):

      # ncols         256
      # nrows         256
      # xllcorner     0
      # yllcorner     0
      # cellsize      1
      # NODATA_value  0

      # So, need to run write.asc() specifying all options to match the
      # maxent input headers.

#  write.asc.file (norm.prob.matrix, filename.root, num.img.rows, num.img.cols);
	write.asc.file (norm.prob.matrix, filename.root,
					  num.img.rows, num.img.cols
					  , xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
					  , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
										 #  is not actually on the map.  It's just off the lower
										 #  left corner.
					  , no.data.value = -9999
					  , cellsize = 1
					 )

	cat ("\nWriting norm.tot.prod.matrix to ", filename.root, ".pgm", "\n", sep='')
	write.pgm.file (norm.prob.matrix, filename.root, num.img.rows, num.img.cols);

		#-----------------------------------------------------------------
		#  Show a heatmap representation of the probability distribution
		#  if desired.
		#-----------------------------------------------------------------

		#  WHERE WOULD A HEATMAP SHOW UP ON TZAR SINCE IT'S NOT SHOWING THE TERMINAL
		#  ANYWHERE THAT I KNOW OF?
		#  DO I HAVE TO WRITE IT TO A FILE?
		#  BTL - 2013 04 08

	show.heatmap <- FALSE
	if (show.heatmap)
		{
    		#-----------------------------------------------------------------------
   			#  standard color schemes that I know of that you can use:
    		#  heat.colors(n), topo.colors(n), terrain.colors(n), and cm.colors(n)
    		#
    		#  I took this code from an example I found on the web and it uses
    		#  some options that I don't know anything about but it works.
    		#  May want to refine it later.
    		#-----------------------------------------------------------------------

		heatmap (norm.prob.matrix,
		 		Rowv = NA, Colv = NA,
		 		col = heat.colors (256),
				###		 scale="column",     #  This can rescale colors within columns.
		 		margins = c (5,10)
		 		)
		}

	return (norm.prob.matrix)
	}

#===============================================================================

computeRelProbDist = function (spp.id, spp.name, env.layers, num.env.layers)
	{
	cat ("\n\nin computeRelProbDist, num.env.layers = '", num.env.layers, "'\n\n", sep='')
	cat ("\n\nlength (env.layers) = '", length (env.layers), "'\n\n", sep='')

	norm.prob.matrix = NULL

	if (PAR.use.old.maxent.output.for.input)
		{
		norm.prob.matrix = read.asc.file.to.matrix (spp.name, PAR.old.maxent.output.dir)

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

