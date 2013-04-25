#===============================================================================

#  source ('guppy.maxent.functions.v9.R')

#===============================================================================

#  History 
#
#  2011.08.07 - BTL
#  Extracted from test.maxent.v4.R to make that code easier to read.

#  2011.09.19 - BTL 
#  Moved to framework2 R directory to incorporate in guppy project from 
#  /Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/.
#  Renamed from test.maxent.functions.v5.R to guppy.maxent.functions.v6.R 
#  in case any changes need to be made for its new incarnation.

#  2011.09.22 - BTL
#  Moved get.img.matrix.from.pnm.and.write.asc.equivalent() into here from w.R.
#  It has some very specific stuff about array dimension = 256 that doesn't 
#  belong in w.R.  In fact, I think that the 256 stuff shouldn't exist in that 
#  function at all, but even so, I think that the function may be vestigial 
#  at this point and can probably be deleted.  However, not sure enough yet to 
#  go ahead and ditch it.

#  2012.07.30 - BTL
#  The comment above from 2011.09.22 about the function being vestigial turns 
#  out to be at least partly wrong.  It is vestigial in the sense of not having 
#  been used in a long time and having been built for a fairly one-off sort of 
#  use.  However, I need it again to provide some small files for Ascelin to 
#  use in testing, so I'm going to fix it up a bit in here now because it has 
#  at least one bug having to do with setting the target matrix size.  
#  The fix may mean it should go back into w.R.  Not sure yet.

#===============================================================================

    #  Not currently sourcing any of the necessary auxiliary files like w.R 
    #  since they're assumed to be sourced already in the code that sources 
    #  this file.  Might need to change that assumption later.
    
#===============================================================================

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
	    
	sample.locs.x.y = 
	    true.presence.locs.x.y [sample.presence.indices.into.true.presence.indices,]

#	sample.presences.dataframe <- 
#		data.frame (cbind (species[1:num.samples.to.take], sample.locs.x.y))
#	names (sample.presences.dataframe) <- c('species', 'longitude', 'latitude')
							  
#	return (sample.presences.dataframe)						  
	return (sample.locs.x.y)		
	}

#===============================================================================

    #-----------------------------------------------------------------------
    #  Get environment variables, 
    #  then combine them using some made-up rule to get a True probability 
    #  surface that maxent will try to recreate.
    #  (For example, we can use generated images from a pnm file as the  
    #   environment layers.)
    #
    #  Then, sample from that surface to get the true occurrences of the 
    #  species.  Once you have that set, then you can build a biased 
    #  sampling method to look for these true occurrences and then feed 
    #  the results of that sampling to maxent.
    #
    #  This biased sampling might also have errors in it, i.e., false 
    #  positives.
    #-----------------------------------------------------------------------
    #  2011.09.22 - BTL
    #  I don't think this is used anymore but need to check more thoroughly.
    #  I think that its functionality has been replaced with some looking 
    #  for random layers instead.
    #-----------------------------------------------------------------------

get.env.layers <- function (input.dir, env.layers.dir)
	{
	cat ('\nStarting get.env.layers()\n')
	
	img.1.matrix <- NULL
	img.2.matrix <- NULL
	
	if (use.pnm.env.layers)
	    {
	    img.1.matrix <- get.img.matrix.from.pnm.and.write.asc.equivalent (input.dir, env.layers.dir, 'H05_1.pnm') 
	    ##img.1.matrix <- get.img.matrix.from.pnm (input.dir, 'H05_1.pnm') 
	    img.1.matrix [1:3,1:3]    #  Echo a bit of the result...

	    img.2.matrix <- get.img.matrix.from.pnm.and.write.asc.equivalent (input.dir, env.layers.dir, 'H05_2.pnm') 
	    ##img.2.matrix <- get.img.matrix.from.pnm (input.dir, 'H05_2.pnm') 
	    img.2.matrix [1:3,1:3]    #  Echo a bit of the result...
	    
	    } else
	    {
	    img.1.matrix <- matrix (0, nrow = 1025, ncol = 1025)
	    img.1.matrix [1:500, 1:500] <- 1
	    img.1.matrix [501:900, 501:1025] <- 0.5
	    
	    img.2.matrix <- matrix (1, nrow = 1025, ncol = 1025)
	    }
	
	return (list (img.1.matrix, img.2.matrix))
	}

#===============================================================================

	#--------------------------------------------------------------------------
    #  Make up a fake rule for how the matrices combine to form a 
    #  probability distribution over the image.
    #  In this case, just make it be the pixelwise product of the two images.
	#--------------------------------------------------------------------------

CONST.product.rule <- 1
CONST.add.rule <- 2
combine.env.layers.to.get.relative.probabilities <- function (env.layers, 
                                                              combination.rule)
	{
	rel.prob.matrix <- matrix()
	
	if (combination.rule == CONST.product.rule)
		{
		rel.prob.matrix <- env.layers [[1]] * env.layers [[2]]
		
		} else
		{
		if (combination.rule == CONST.add.rule)
		    {
		    rel.prob.matrix <- env.layers [[1]] + env.layers [[2]]
		    
		    } else
		    {
		    stop ("\n\nUndefined combination rule for environmental layers.\n\n")
		    }
		}
	
	print (rel.prob.matrix [1:3,1:3])    #  Echo a bit of the result...

#cat ("\nAbout to return rel.prob.matrix from combine.env.layers...()\n")
	
	return (rel.prob.matrix)
	}
	
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

  filename.root = paste (prob.dist.layers.dir, "true.prob.dist.", spp.name, sep='')
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
gen.normalized.prob.distribution.from.env.layers <- function (env.layers, 
                                                              combination.rule)
	{
	rel.prob.matrix <- 
	    combine.env.layers.to.get.relative.probabilities (env.layers, 
														  combination.rule)
																		 																		 
	normalized.prob.matrix <- 
		normalize.prob.distribution.from.env.layers (rel.prob.matrix)
	
	return (normalized.prob.matrix)
	}

#===============================================================================

xy.rel.to.lower.left <- function (n, nrow)    #**** the key function ****#
	{ 
	n.minus.1 <- n - 1
	return ( c (1 + (n.minus.1 %/% nrow), 
			    nrow - (n.minus.1 %% nrow)
			   )
		   ) 
	}

#===============================================================================

draw.img <- function (img.matrix)
    {
    
        #  heat.colors give red as low to yellow (and white?) as high values
        #  topo.colors give blue to green to yellow to tan
        #  terrain.colors give green to yellow to tan to grey
        #  cm.colors give darker blue, lighter blue, white, light purple, dark purple
    image (1:num.cols, 1:num.rows, img.matrix, 
           col = terrain.colors (100), 
           asp = 1, 
           mai = c(0,0,0,0),    #  trying to get rid of margin, but doesn't work?
           axes = FALSE, 
           ann = FALSE
           )

    contour (1:num.cols, 1:num.rows, img.matrix, levels = c (20), add=TRUE)
    }

#===============================================================================

draw.filled.contour.img <- function (img.matrix, 
                                     plot.main.title, 
                                     plot.key.title, 
                                     map.colors,
                                     point.color, 
                                     draw.contours = FALSE, 
                                     contour.levels.to.draw = NULL,
                                     show.sample.points = FALSE
                                    )
    {
    require(grDevices) # for colours

        #  When you leave out the x and y before the img.matrix in this 
        #  call, you get something wrong (that I can't remember at the moment), 
        #  so the next call down includes the x and y sequences.
    #filled.contour (img.matrix, color = heat.colors, asp = 1)

        #  More complex version with annotations.
        #  Note:  When I called points() after this, the scale was wrong 
        #         somehow and some of the points ended up in the legend area.
        #         Not sure whether that's fixable or not.
        #  Have now found a note in the filled.contour help page that explains 
        #  about adding points, etc.:
        #
        #      Note
        #
        #      This function currently uses the layout function and so is 
        #      restricted to a full page display. 
        #      As an alternative consider the levelplot and contourplot 
        #      functions from the lattice package which work in multipanel 
        #      displays.
        #
        #      The output produced by filled.contour is actually a combination 
        #      of two plots; one is the filled contour and one is the legend. 
        #      Two separate coordinate systems are set up for these two plots, 
        #      but they are only used internally - once the function has 
        #      returned these coordinate systems are lost. 
        #      If you want to annotate the main contour plot, for example to 
        #      add points, you can specify graphics commands in the plot.axes 
        #      argument. An example is given below.
        #
        #          # Annotating a filled contour plot
        #      a <- expand.grid(1:20, 1:20)
        #      b <- matrix(a[,1] + a[,2], 20)
        #      filled.contour(x = 1:20, y = 1:20, z = b,
        #                     plot.axes={ 
        #                                axis(1); axis(2); 
        #                                points(10,10) 
        #                               })

    num.rows <- dim(img.matrix)[1]   
    num.cols <- dim(img.matrix)[2]
    x <- 1:num.cols
    y <- 1:num.rows

    filled.contour (x, y, img.matrix, 
                    color = map.colors,
                    plot.title = title (main = plot.main.title
#                    ,
#                    xlab = "Meters North", ylab = "Meters West"
                    ),
    #                plot.axes = { axis(1, seq(100, 800, by = 100)), 
    #                              axis(2, seq(100, 600, by = 100)) },
                    plot.axes = {
                                 if (show.sample.points)
                                   {
                                   points (sampled.locs.x.y, 
                                           pch = 19, 
                                           bg = point.color, 
                                           col = point.color); 
                                   }
                                  if (draw.contours) 
                                      contour (1:num.cols, 1:num.rows, 
                                      img.matrix, 
                                      levels = contour.levels.to.draw, 
                                      add=TRUE)

                                },
                    key.title = title (main=plot.key.title), 
                    asp = 1
    #                ,
    #                key.axes = axis(4, seq(90, 190, by = 10)))# maybe also asp=1
    #mtext(paste("filled.contour(.) from", R.version.string),
    #      side = 1, line = 4, adj = 1, cex = .66)
                    )
    }
    
#===============================================================================

create.clustering.input.file <- function (input.dir, output.dir, 
										  pnm.base.filename)
    {
        #  Environmental input probabilites.
        
    input.dir <- "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H05/"    

        #  2012.07.30 - BTL - Changed to reflect change in arguments to 
        #  get.img...().
    full.img.filename = paste (input.dir, "/", 'H05_1.pnm', sep='')    
	  img.1.matrix <- get.img.matrix.from.pnm (full.img.filename) 
    full.img.filename = paste (input.dir, "/", 'H05_2.pnm', sep='')    
    img.2.matrix <- get.img.matrix.from.pnm (full.img.filename) 

    num.rows <- dim (img.1.matrix) [1]
    num.cols <- dim (img.1.matrix) [2]
        
    env.points.to.cluster <- array (0, c(num.rows*num.cols, 5))

    #-----
    
        #  Species rule probabilites.
        
	probabilities.dir <- "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/MaxentProbDistLayers/"

    mult.filename <- paste (probabilities.dir, 'true.prob.dist.spp.1.csv', sep='')
	img.mult.data.table <- read.csv (mult.filename) 
    mult.points.to.cluster <- array (0, c(num.rows*num.cols, 4))

    add.filename <- paste (probabilities.dir, 'true.prob.dist.spp.2.csv', sep='')
	img.add.data.table <- read.csv  (add.filename) 
    add.points.to.cluster <- array (0, c(num.rows*num.cols, 4))
    
    #-----
    
    i <- 0
    
    for (cur.row in 1:num.rows)
        {
        for (cur.col in 1:num.cols)
            {
            i <- i + 1
            
            if ((cur.col == 1) & ((cur.row %% 50) == 0)) cat ("\n    ", cur.row)
            
            env.points.to.cluster [i, 1] <- i
            env.points.to.cluster [i, 2] <- img.1.matrix [cur.row, cur.col]
            env.points.to.cluster [i, 3] <- img.2.matrix [cur.row, cur.col]
            env.points.to.cluster [i, 4] <- cur.col
            env.points.to.cluster [i, 5] <- cur.row
            
            mult.points.to.cluster [i, 1] <- i
            mult.points.to.cluster [i, 2] <- img.mult.data.table [cur.row, cur.col]
            mult.points.to.cluster [i, 3] <- cur.col
            mult.points.to.cluster [i, 4] <- cur.row
            
            add.points.to.cluster [i, 1] <- i
            add.points.to.cluster [i, 2] <- img.add.data.table [cur.row, cur.col]
            add.points.to.cluster [i, 3] <- cur.col
            add.points.to.cluster [i, 4] <- cur.row
            }
        }
        
        
    env.points.to.cluster.filename <- "maxent.env.points.to.cluster.csv"
    write.csv (env.points.to.cluster, file = env.points.to.cluster.filename, 
               row.names = FALSE, col.names = FALSE)
    
    mult.points.to.cluster.filename <- "maxent.mult.points.to.cluster.csv"
    write.csv (mult.points.to.cluster, file = mult.points.to.cluster.filename, 
               row.names = FALSE, col.names = FALSE)
    
    add.points.to.cluster.filename <- "maxent.add.points.to.cluster.csv"
    write.csv (add.points.to.cluster, file = add.points.to.cluster.filename, 
               row.names = FALSE, col.names = FALSE)
    
    }

#-------------------------------------------------------------------------------

    #-----------------------------------------------------------------------
    #  History:
    #
    #  2011.08.07 - BTL - Moved to w.R from text.maxent.v3.R.
    #
    #  2011.09.22 - BTL - Moved from w.R to guppy.maxent.functions.v6(v7?).R.
    #
    #  2012.07.30 - BTL
    #  Fixed bug about targetMatrixSize and added check to make sure 
    #  the specified target size is not bigger than the original image.
    #  Also flagging an odd comment about xllcorner and yllcorner.  
    #  Will just add two new optional arguments to allow them to be set  
    #  in the call to this routine.
    #-----------------------------------------------------------------------

get.img.matrix.from.pnm.and.write.asc.equivalent <- 
    function (input.dir, output.dir, pnm.base.filename, targetMatrixSize=-1, 
              xLowerLeft = 1, yLowerLeft = 1)
    {
        #-----------------------------------------
        #  Load the input image from a pnm file.
        #-----------------------------------------

        #  2012.07.30 - BTL - Changed to reflect change to get.img...() arg list.
    full.img.filename = paste (input.dir, "/", pnm.base.filename, sep='')
    img.matrix <- get.img.matrix.from.pnm (full.img.filename) 

        #  2012.07.30 - BTL
        #  Fixing Bug:  This was hard-coded to always be 256 here.
        #  It should have been passed in as targetMatrixSize argument.
#    targetMatrixSize = 256    

        #------------------------------------------------------------------
        #  Default to keeping the same size matrix as the original, i.e.,
        #  if the matrix size passed is positive, then use that as the 
        #  new matrix dimension.  If <= 0, then just leave dimension as is.
        #
        #  Default to keeping the same size matrix as the original, i.e.,
        #  if the matrix size passed is positive, then use that as the 
        #  new matrix dimension.  If <= 0, then just leave dimension as is.
        #------------------------------------------------------------------
        
    if (targetMatrixSize > 0)
      {
      if ((targetMatrixSize <= dim(img.matrix)[1])  &  
          (targetMatrixSize <= dim(img.matrix)[2]))
        {
            #  Target size is legal.
            #  Reduce the image dimensions to the given target size.
        img.matrix = img.matrix [1:targetMatrixSize, 1:targetMatrixSize]
        
        } else
        {
            #  Target size is bigger than the original image.
        cat ("\n\nIn get.img.matrix.from.pnm.and.write.asc.equivalent():  \n",
             "    targetMatrixSize = ", targetMatrixSize, 
             " is larger than at least one dimension of original matrix.\n\n",
             sep='')
        browser();
        }
      }  

        #---------------------------------------------
        #  Write the image data out in the form that  
        #  maxent expects, i.e., ESRI .asc format.
        #---------------------------------------------

	  img.filename.root <- (strsplit (pnm.base.filename, ".pnm")) [[1]]  # remove pnm
    if (targetMatrixSize > 0)
      img.filename.root = paste (img.filename.root, '.', targetMatrixSize, sep='')
    cat ("\n    base name = '", img.filename.root, "'", sep='')

    num.table.rows <- (dim (img.matrix))[1]
    num.table.cols <- (dim (img.matrix))[2]
    
    asc.filename.root <- paste (output.dir, img.filename.root, sep='')
    
            #???????????????????????????????????????????????????????????????????
            #  BTL - 2012.07.30
            #  The comment below about xllcorner and yllcorner as 0 instead of 1
            #  looks like these values should have been changed but aren't.
            #  Not sure what's going on here...
            #  The values in the asc files in the directory containing all of 
            #  Alex's synthetic images give xllcorner = yllcorner = 1, not the 
            #  0 that the comment below would seem to suggest.
            #  Have just changed the code here to allow the value to be set by  
            #  the caller of this routine so that it's easy to change if the 
            #  value that I had here now is wrong.
            #???????????????????????????????????????????????????????????????????
#browser()    
    write.asc.file (img.matrix, asc.filename.root, 
                    num.table.rows, num.table.cols
###                                       #-------------------------------------                    
###                                       #  The old comment before 2012.07.30:              
###                    , xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
###                    , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
###                                       #  is not actually on the map.  It's just off the lower 
###                                       #  left corner.
###                                       #-------------------------------------                    
                                                #  BTL - 2012.07.30
                    , xllcorner = xLowerLeft    #  Have changed to allow caller 
                    , yllcorner = yLowerLeft    #  to specify but default (0,0).
###                                       #-------------------------------------                    

                    , no.data.value = -9999    #  Maxent's missing value flag
                    , cellsize = 1
                    )

     if (targetMatrixSize > 0)
       write.pgm.file (img.matrix, asc.filename.root, targetMatrixSize, targetMatrixSize)
   
        #-----------------------------------------------------------
        #  Caller doesn't need anything other than the image data.                      
        #-----------------------------------------------------------

    return (img.matrix)                
    }

#===============================================================================
#===============================================================================
#===============================================================================


