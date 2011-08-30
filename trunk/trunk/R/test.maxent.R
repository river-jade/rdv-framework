#===============================================================================

#  source ('test.maxent.R')

#  To run the current version of the code: 
        base.dir <- '/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated\ ecology/MaxentTests/'
        setwd (base.dir)
      
        write.to.file <- TRUE
        use.draw.image <- FALSE
        use.filled.contour <- TRUE
        use.pnm.env.layers <- TRUE        
        
        spp.id <- 1        
#        spp.id <- 2  
        
        if (spp.id == 1)      
            {
            num.samples.to.take <- 50
            } else
            {
            num.samples.to.take <- 10
            }

        random.num.seed <- spp.id
        spp.name <- paste ('spp.', spp.id, sep='')

#        random.num.seed <- 17
#        spp.name <- 'test.spp'
        
      
#      source ('test.maxent.R')

#  Note that it currently assumes the following directory structure 
#  of that MaxentTest directory:

#    drwxr-xr-x   5 bill  staff     170 20 Jan 11:20 AlexsSyntheticLandscapes
#    drwxr-xr-x   6 bill  staff     204 17 Feb 13:09 MaxentEnvLayers
#    drwxr-xr-x  14 bill  staff     476 17 Feb 13:48 MaxentOutputs
#    drwxr-xr-x   4 bill  staff     136 17 Feb 12:55 MaxentProbDistLayers
#    drwxr-xr-x   2 bill  staff      68 17 Feb 11:15 MaxentProjectionLayers
#    drwxr-xr-x   5 bill  staff     170 17 Feb 13:10 MaxentSamples
#    drwxr-xr-x   3 bill  staff     102 18 Feb 12:30 ResultsAnalysis
#    -rw-r--r--@  1 bill  staff   25339 18 Feb 12:55 test.maxent.R
#    -rw-r--r--@  1 bill  staff    8617 17 Feb 13:22 w.R

#  Also note that w.R is a modified version of w.R from the framework.  
#  Need to commit it to the framework so that the changes to write.asc.file()
#  are generally available.  Those changes are simple ones and only involve 
#  making a bunch of the parameters able to be specified in the call rather 
#  than fixed inside the routine.  All of the new call arguments default to 
#  the old values though, so no existing framework code should be broken by 
#  this.

#===============================================================================

#  History 
#
#  2011.02.18 - BTL
#  Have now completed a prototype that goes all the way through the process 
#  of:
#    - reading a pair of environment layers from .pnm files
#    - combining them in some way to produce a "correct" probability 
#      distribution
#    - drawing a "correct" population of presences from that distribution
#    - sampling from that correct population to get the "apparent" population 
#    - running maxent on that sample plus the environment layers
#    - reading maxent's resulting estimate of the probability distribution
#    - computing the error between maxent's normalized distribution and the 
#      correct normalized distribution
#    - computing some statistics and possibly showing a heatmap of the errors 
#      as a first cut at examining the spatial distribution of error.
#
#  There are lots of restrictions and assumptions about formats and locations 
#  and hard-coded rules for combining layers and you still have to run maxent 
#  by hand.  However, some version of every step is there and it works from 
#  end to end to get a result.  Now we just need to:
#    - expand the capabilities of each step 
#    - add the ability to inject error in all inputs and processes
#    - turn it into a class to make it easier to use and to swap methods 
#      in and out
#    - make a project for it in the framework and give it access to yaml 
#      files for setting control variables and run over many different 
#      scenarios and inputs

#===============================================================================

base.dir <- '/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated\ ecology/MaxentTests/'

#  setwd ('/Users/bill/Desktop/MaxentTests')
#setwd ('/Users/bill/Desktop/MaxentTests')

setwd (base.dir)
getwd ()

set.seed (random.num.seed)

#input.img.dir <- '/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01\ -\ simulated\ ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H05/'
#input.img.dir <- '/Users/bill/Desktop/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H05/'
#input.img.dir <- '/Users/bill/Desktop/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H05/'

input.img.dir <- './AlexsSyntheticLandscapes/IDLOutputAll2/H05/'

samples.dir <- "./MaxentSamples/"
env.layers.dir <- "./MaxentEnvLayers/"
prob.dist.layers.dir <- "./MaxentProbDistLayers/"
maxent.output.dir <- "./MaxentOutputs/"
analysis.dir <- "./ResultsAnalysis/"
zonation.output.dir <- "./ZonationResults/"

#===============================================================================

#source ('/Users/bill/D/rdv-svn/rdv-framework/trunk/framework/R/w.R')
#source ('/Users/bill/Desktop/framework2-R/w.R')
source ('w.R')

library (pixmap)

#===============================================================================

get.img.matrix.from.pnm <- function (input.dir, pnm.base.filename) 
    {
        #-----------------------------------------
        #  Load the input image from a pnm file.
        #-----------------------------------------

	full.img.filename <- paste (input.dir, pnm.base.filename, sep='')
	cat ("\n  Reading '", full.img.filename, "'", sep='')
    img <- read.pnm (full.img.filename)
    
    #plot (img)    #  This take a LONG beachball sort of time to plot the image, 
    #                #  but eventually, it does return with a nice image.

        #-----------------------------------------------------------------
        #  Extract the image data from the pixmap as a matrix so that we 
        #  can manipulate the data.    
        #-----------------------------------------------------------------

    img.matrix <- img@grey
    
    return (img.matrix)
    }
    
#===============================================================================

get.img.matrix.from.pnm.and.write.asc.equivalent <- function (input.dir, output.dir, 
												  			  pnm.base.filename) 
    {
        #-----------------------------------------
        #  Load the input image from a pnm file.
        #-----------------------------------------

	img.matrix <- get.img.matrix.from.pnm (input.dir, pnm.base.filename) 
	
        #---------------------------------------------
        #  Write the image data out in the form that  
        #  maxent expects, i.e., ESRI .asc format.
        #---------------------------------------------

	img.filename.root <- (strsplit (pnm.base.filename, ".pnm")) [[1]]
    cat ("\n    base name = '", img.filename.root, "'.", sep='')

    num.table.rows <- (dim (img.matrix))[1]
    num.table.cols <- (dim (img.matrix))[2]
    
    asc.filename.root <- paste (output.dir, img.filename.root, sep='')
    

    
    write.asc.file (img.matrix, asc.filename.root, 
                    num.table.rows, num.table.cols
                    , xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
                    , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
                                      #  is not actually on the map.  It's just off the lower 
                                      #  left corner.
                    , no.data.value = -9999    #  Maxent's missing value flag
                    , cellsize = 1
                    )

        #-----------------------------------------------------------
        #  Caller doesn't need anything other than the image data.                      
        #-----------------------------------------------------------

    return (img.matrix)                
    }

#===============================================================================

	#  This isn't called yet, but it's here to use when we're ready to do 
	#  a lot of these.
	
convert.pnm.files.in.dir.to.asc.files <- function (input.dir)
	{
	pnm.files <- dir (path=input.dir, pattern="*.pnm")
	for (cur.pnm.filename in pnm.files)
	    {
	    cat ("\nConverting pnm file '", cur.pnm.filename, "' to .asc file.", sep='')
	    
	    get.img.matrix.from.pnm.and.write.asc.equivalent (input.dir, 
	    												  env.layers.dir,
	    												  cur.pnm.filename) 
	    }
	cat ("\n\nDone converting pnm files to asc files.\n\n")
	}

#===============================================================================

build.presence.sample <- function (num.samples.to.take, true.presence.locs.x.y)
	{
		#-------------------------------------------------------------------
	    #  I'm doing this as a function so that the sampling method (and 
	    #  any other errors in building the presence sample) can be hidden 
	    #  from the calling program.
	    #  For the moment though, it's very simple.  It's just a straight 
	    #  subsample of the original population with no errors.
		#-------------------------------------------------------------------
	    
	num.rows <- (dim (true.presence.locs.x.y)) [1]    
	    
	sample.indices <- sample (1:num.rows, 
							  num.samples.to.take, 
							  replace=FALSE)  #  Should this be WITH rep instead?

	sample.locs.x.y <- true.presence.locs.x.y [sample.indices,]

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

	true.prob.dist.filename <- paste (prob.dist.layers.dir, "true.prob.dist.", spp.name, ".csv", sep='')
	cat ("\nWriting norm.tot.prod.matrix to ", true.prob.dist.filename, "\n", sep='')
	write.csv (norm.prob.matrix, file = true.prob.dist.filename, row.names = FALSE)
		   	
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
                                     contour.levels.to.draw = NULL
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
                    plot.axes = { points (sampled.locs.x.y, 
                                        pch = 19, 
                                        bg = point.color, 
                                        col = point.color)
                                  if (draw.contours) 
                                      contour (1:num.cols, 1:num.rows, 
                                                img.matrix, 
                                                levels = contour.levels.to.draw, 
                                                add=TRUE)

                                },
                    key.title = title (main=plot.key.title), 
                    asp = 1
##                     ,
##                     key.axes = axis(4, 
##                                     #seq(90, 190, by = 10)
##                                     c (2.0e-07, 4.0e-07, 6.0e-07, 
##                                        8.0e-07, 1.0e-06, 
##                                        1.2e-06, 1.4e-06, 1.6e-06)
##                                    )# maybe also asp=1
    #mtext(paste("filled.contour(.) from", R.version.string),
    #      side = 1, line = 4, adj = 1, cex = .66)
                    )
    }
    
#===============================================================================
#===============================================================================
#===============================================================================

par (mfrow=c(2,2))

convert.files.to.asc <- FALSE
if (convert.files.to.asc)
	convert.pnm.files.in.dir.to.asc.files (input.img.dir)

env.layers <- get.env.layers (input.img.dir, env.layers.dir)    #  returns a list where img.1 = env.layers[[1]], etc.
if (spp.id == 1)
    {
    combination.rule <- CONST.product.rule
    
    } else
    {
    combination.rule <- CONST.add.rule
    }
    
norm.prob.matrix <- 
	gen.normalized.prob.distribution.from.env.layers (env.layers, 
	                                                  combination.rule)

#===============================================================================

num.true.presences <- 100
num.rows <- (dim (norm.prob.matrix)) [1]
num.cols <- (dim (norm.prob.matrix)) [2]
num.cells <- num.rows * num.cols

	#-------------------------------------------------------------
	#  Sample presences from the mapped probability distribution 
	#  according to the probabilities.
	#-------------------------------------------------------------
	
true.presence.indices <- sample (1:(num.rows * num.cols), 
								num.true.presences, 
								replace = FALSE, 
								prob = norm.prob.matrix)

	#----------------------------------------------------------------
	#  Convert the sample from single index values to x,y locations 
	#  relative to the lower left corner of the map.
	#----------------------------------------------------------------

true.presence.locs.x.y <- 
	matrix (rep (0, (num.true.presences * 2)), 
			nrow = num.true.presences, ncol = 2, byrow = TRUE)

	#  Can probably replace this with an apply() call instead...
for (cur.loc in 1:num.true.presences)
	{
	true.presence.locs.x.y [cur.loc, ] <- 
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

species <- rep (spp.name, num.true.presences)    
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
    
outfile.root <- paste (spp.name, ".truePres.", spp.name, sep='')
sampled.presences.filename <- paste (samples.dir, outfile.root, ".csv", sep='')
write.csv (true.presences.table, 
		   file = sampled.presences.filename, 
		   row.names = FALSE, 
		   quote=FALSE)
	
#===============================================================================

    #---------------------------------------------------------------------
    #  Have now finished generating the true occurrences of the species.  
    #  Ready to simulate the sampling of the species to generate a 
    #  sampled occurrence layer to feed to maxent.
    #---------------------------------------------------------------------

sampled.locs.x.y <- 
	build.presence.sample (num.samples.to.take, true.presence.locs.x.y)


plot (true.presence.locs.x.y [,1], true.presence.locs.x.y [,2],
	  xlim = c (0, num.cols), ylim = c(0, num.rows), 
	  asp = 1,
	  main = paste ("True presences \nnum.true.presences = ", 
	  				num.true.presences, sep='')
	  )

plot (sampled.locs.x.y [,1], sampled.locs.x.y [,2],
	  xlim = c (0, num.cols), ylim = c(0, num.rows), 
	  asp = 1,
	  main = paste ("Sampled presences \nnum.samples = ", 
	  				num.samples.to.take, sep='')
	  )

sampled.presences.table <- 
	data.frame (cbind (species [1:num.samples.to.take], sampled.locs.x.y))
names (sampled.presences.table) <- c('species', 'longitude', 'latitude')

    #--------------------------------------------------------------------
	#  Write the true presences out to a .csv file to be fed to maxent.
	#  This will represent the case of "perfect" information 
	#  (for a given population size), i.e., it contains the true 
	#  location of every member of the population at the time of the 
	#  sampling.  For stationary species like plants, this will be 
	#  "more perfect" than for things that can move around.
    #--------------------------------------------------------------------
    
outfile.root <- paste (spp.name, ".sampledPres.", spp.name, sep='')
sampled.presences.filename <- paste (samples.dir, outfile.root, ".csv", sep='')
write.csv (sampled.presences.table, 
		   file = sampled.presences.filename, 
		   row.names = FALSE, 
		   quote=FALSE)
	

#===============================================================================

	#  This is where we need to exec maxent, but it has a fair number of 
	#  options to set, so I'll leave coding that call for later.  
	#  Right now, we can just pause, run the maxent gui, and then come 
	#  back and finish up below.

    ###    Example java calls from maxent help file
    ###java -mx512m -jar maxent.jar environmentallayers=layers samplesfile=samples\bradypus.csv outputdirectory=outputs togglelayertype=ecoreg redoifexists autorun
    ###java -mx512m -jar maxent.jar -e layers -s samples\bradypus.csv -o MaxentOutputs -t ecoreg -r -a

cat ("\n\n		-----  Run maxent now  -----\n\n")
cat ("\nHit c when Maxent has finished.\n")
browser()   #  this browser should be deleted when system() call works.

## cur.spp.name <- spp.name
## sample.path <- paste ("MaxentSamples/", cur.spp.name, ".sampledPres.csv", sep='')
## system (paste ("java -mx512m -jar maxent.jar -e MaxentEnvLayers -s ", 
##             sample.path, " -o outputs -a", sep=''))
## ###system ('do1.bat')    #  the call to run zonation - makes it wait to return?
## browser()

#===============================================================================

	#  Maxent is done now, so compare its results to the correct values.
	
#===============================================================================

    #  Get maxent's resulting probability distribution.
    #  Then, subtract it from the true distribution to see the spatial pattern.
     
		#  Load the maxent output distribution into a matrix.
maxent.rel.prob.dist.filename <- paste (maxent.output.dir, spp.name, '.asc', sep='')
maxent.rel.prob.dist <- 
	as.matrix (read.table (maxent.rel.prob.dist.filename, skip=6))

		#  Normalize the matrix to allow comparison with true distribution.
tot.maxent.rel.prob.dist <- sum (maxent.rel.prob.dist)
maxent.norm.prob.dist <- maxent.rel.prob.dist/tot.maxent.rel.prob.dist
sum (maxent.norm.prob.dist)

	#  Compute the difference between the correct and maxent probabilities 
	#  and save it to a file for display.	
err.between.maxent.and.true.prob.dists <- maxent.norm.prob.dist - norm.prob.matrix

num.img.rows <- dim (err.between.maxent.and.true.prob.dists) [1]
num.img.cols <- dim (err.between.maxent.and.true.prob.dists) [2]
write.asc.file (err.between.maxent.and.true.prob.dists, 
				paste (analysis.dir, "raw.error.in.dist.", spp.name, sep=''), 
            	num.img.rows, num.img.cols
            	, xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
                , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
                                      #  is not actually on the map.  It's just off the lower 
                                      #  left corner.
                , no.data.value = -9999
                , cellsize = 1
                )

##write.pgm.file (err.between.maxent.and.true.prob.dists, 
##				paste (analysis.dir, "raw.error.in.dist.", spp.name, sep=''), 
##            	num.img.rows, num.img.cols)                

    #-------------------------------------------------------------------------
    #  Plot that pattern.
    #  Compute non-spatial statistics that compare the two distributions.
    #    - rank correlation
    #    - correlation
    #    - KS test  (is KS the test that compares two distributions?)
    #  One question: are there any computer arithmetic issues with all these 
    #  small numbers in these distributions?
    #-------------------------------------------------------------------------
    
    #--------------------------------------------------------------------
    #  IMPORTANT
    #  NOTE:  May want to do these tests using several different views 
    #         that reflect something like a cost-sensitive view.  
    #         For example, what is most important in a Madagascar-style 
    #         use of maxent + zonation is how the true top 10% of the 
    #         distribution performs.
    #         So, you may want to use which() to pull out certain 
    #         subsets of locations to analyze.
    #         More importantly, probably want to do a which() that 
    #         selects the top 10% or so of locations in the true 
    #         distribution and the true Zonation ranking.  Then, 
    #         do various statistics on just those locations in the 
    #         Maxent data to get an idea of how well it does on those.
    #         One more thing - percent error may not be the right 
    #         error to look at in a probability distribution.  
    #         May want to look at the absolute error instead.  
    #         Not sure...
    #--------------------------------------------------------------------    

err.magnitudes <- abs (err.between.maxent.and.true.prob.dists)
write.asc.file (err.magnitudes, 
				paste (analysis.dir, "abs.error.in.dist.", spp.name, sep=''), 
            	num.img.rows, num.img.cols
            	, xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
                , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
                                      #  is not actually on the map.  It's just off the lower 
                                      #  left corner.
                , no.data.value = -9999
                , cellsize = 1
                )
##write.pgm.file (err.between.maxent.and.true.prob.dists, 
##				paste (analysis.dir, "abs.error.in.dist.", spp.name, sep=''), 
##            	num.img.rows, num.img.cols)


tot.err.magnitude <- sum (err.magnitudes)
max.err.magnitude <- max (err.magnitudes)

npm.vec <- as.vector (norm.prob.matrix)
mnpd.vec <- as.vector (maxent.norm.prob.dist)

pearson.cor <- cor (npm.vec, mnpd.vec, 
     			    method = "pearson"
     			   )
spearman.rank.cor <- cor (npm.vec, mnpd.vec, 
     			    method = "spearman"
     			   )
     			   
#  this one hung R every time I used it...     			   
##kendall.cor <- cor (npm.vec, mnpd.vec,        
##     			    method = "kendall"
##     			   )

##par (mfrow=c(4,2))    #  4 rows, 2 cols
par (mfrow=c(2,2))    #  2 rows, 2 cols

percent.err.magnitudes <- (err.magnitudes / norm.prob.matrix) * 100
hist (percent.err.magnitudes [percent.err.magnitudes <= 100])

write.pgm.file (err.between.maxent.and.true.prob.dists, 
				paste (analysis.dir, "percent.error.in.dist.", spp.name, sep=''), 
            	num.img.rows, num.img.cols)    
            	
            	
##    #  Reset the largest errors to one fairly large value so that 
##    #  you can reduce the dynamic range of the image and make it 
##    #  easier to differentiate among smaller values.

truncated.err.img <- percent.err.magnitudes 
truncated.err.img [percent.err.magnitudes >= 50] <- 50
write.pgm.file (truncated.err.img, 
				paste (analysis.dir, "truncated.err.img.", spp.name, sep=''), 
            	num.img.rows, num.img.cols)                



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
    		
	heatmap (err.between.maxent.and.true.prob.dists, 
		 		Rowv = NA, Colv = NA, 
		 		col = heat.colors (256), 
				###		 scale="column",     #  This can rescale colors within columns.
		 		margins = c (5,10)
		 		)
	}

#===============================================================================


####  NOTES

##  This part works but I'm not sure if it's what we want to do...

#### quantile (norm.prob.matrix, c(0.1,0.9))
#### top.10 <- which(norm.prob.matrix >= quantile (norm.prob.matrix, 0.9))
#### truncated.err <- percent.err.magnitudes
#### truncated.err [percent.err.magnitudes >= quantile (percent.err.magnitudes, 0.95)] <- 50
#### write.pgm.file (truncated.err, 
#### 				paste (analysis.dir, "truncated.err.img.", spp.name, sep=''), 
####             	num.img.rows, num.img.cols)                


##  This part is a copy of the fooling around I did in R to get the stuff 
##  above to work...

#### > x <- pixmap (as.vector(percent.err.magnitudes), nrow=1025)
#### > plot(x)
#### Error in t(x@index[nrow(x@index):1, , drop = FALSE]) : 
####   subscript out of bounds
#### > x
#### Pixmap image
####   Type          : pixmap 
####   Size          : 1025x1025 
####   Resolution    : 1x1 
####   Bounding box  : 0 0 1025 1025 
#### 
#### > img <- read.pnm ('./ResultsAnalysis/percent.error.in.dist.pgm')
#### Read 1050625 items
#### > plot(img)
#### > truncated.err <- norm.prob.matrix
#### > truncated.err [norm.prob.matrix >= quantile (norm.prob.matrix, 0.95)] <- 50
#### > 
#### > truncated.err <- percent.err.magnitudes
#### > truncated.err [percent.err.magnitudes >= quantile (percent.err.magnitudes, 0.95)] <- 50
#### > 
#### > write.pgm.file (truncated.err, 
#### + 				paste (analysis.dir, "truncated.err.img.", spp.name, sep=''), 
#### +             	num.img.rows, num.img.cols)                
#### 
#### wrote ./ResultsAnalysis/truncated.err.img.pgm
#### > 
#### > img <- read.pnm ('./ResultsAnalysis/truncated.err.img.pgm')
#### Read 1050625 items
#### > plot(img)
#### > 

#===============================================================================

force.imgs.to.same.scale.and.plot <- 
    function (true.img, maxent.img, 
              true.img.filename, maxent.img.filename, 
              true.plot.title, maxent.plot.title, 
              key.title, 
              map.colors, dot.color
              )
    {
        #  There is a problem when displaying pairs of maps 
        #  because I can't figure out how to set the range of 
        #  graded colors to be the same.  
        #  This means that the same color on two different probability 
        #  maps means different values.
        #  So, I'm going to do something to fake out the scaling routine.
        #  I'll find the extreme values in both images of a pair and then 
        #  make sure that both images contain at least one pixel with 
        #  the min value and with the max value.  
        #  This will force the scaling routine to use the same range of 
        #  colors for both images.  
        #  The only downside is that I may have to add a dummy pixel or 
        #  two to one or both images.  If so, I just add them in the 
        #  upper left and lower right corner.  They should be impossible 
        #  to see and since this is done inside of a function, the changes 
        #  are local and won't affect any statistical calculations done 
        #  on the original matrices.
        
    true.range <- range (true.img)
    maxent.range <- range (maxent.img)

    bounds <- c(min(true.range[1],maxent.range[1]), 
                max(true.range[2],maxent.range[2]))

    if (bounds[1] < true.range[1])
        true.img [1,1] <- bounds[1]
    if (bounds[2] > true.range[2])
        true.img [num.cols,num.rows] <- bounds[2]

    if (bounds[1] < maxent.range[1])
        maxent.img [1,1] <- bounds[1]
    if (bounds[2] > maxent.range[2])
        maxent.img [num.cols,num.rows] <- bounds[2]
        
        #  Now have any dummy values added in if necessary, so ready to 
        #  build the two plots.
        
        #  First, the true image...
        
    cat ("\n  Writing true.?.tiff...")    
    if (write.to.file)  tiff (true.img.filename)
    draw.filled.contour.img (true.img, 
                             true.plot.title, key.title, 
                             map.colors, dot.color)
    if (write.to.file)  dev.off()

        #  Now, the maxent image...

    cat ("\n  Writing maxent.?.tiff...")    
    if (write.to.file)  tiff (maxent.img.filename)
    draw.filled.contour.img (maxent.img, 
                             maxent.plot.title, key.title, 
                             map.colors, dot.color)
    if (write.to.file)  dev.off()
    }

#===============================================================================

#num.cols <- 1025
#num.rows <- 1025
num.rows <- dim (truncated.err.img)[1]
num.cols <- dim (truncated.err.img)[2]

par (mfrow=c(1,1))

#img.matrix <- truncated.err.img
#jpeg (paste (analysis.dir, "test.jpg", sep=''))
#draw.img (img.matrix)    
#points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")


    #  NOTE: There is one issue with comparing the outputs of filled.contour().
    #        It rescales to fit the data, so the same color scheme may give 
    #        different colors to the same values on different maps.  
    #        I think that you Can control the max and min values in the 
    #        scaling though.  Need to look at some of the arguments that 
    #        I commented out when I cloned the example from R help or the web.


    par (mfrow=c(1,1))
    
cat ("\nWrite env layer tiffs...")    
force.imgs.to.same.scale.and.plot (norm.prob.matrix, maxent.norm.prob.dist, 
              paste (analysis.dir, "env.layer.1.tiff", sep=''), 
              paste (analysis.dir, "env.layer.2.tiff", sep=''), 
              "Env Layer 1", 
              "Env Layer 2", 
              "Env\nMeasure", 
              cm.colors, "red"
              )

##     cat ("\nWrite env.layer.1.tiff...")
##     if (write.to.file)  tiff (paste (analysis.dir, "env.layer.1.tiff", sep=''))    
## #    draw.img (env.layers [[1]])
## #    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
## #    plot.main.title <- "Env Layer 1"
## #    plot.key.title <- "Env\nMeasure1"
## #    map.colors <- cm.colors
## #    point.color <- "red"
##     draw.filled.contour.img (env.layers [[1]], 
##                              "Env Layer 1", "Env\nMeasure1", 
##                              cm.colors, "red")
##     if (write.to.file)  dev.off()
## 
##     cat ("\nWrite env.layer.2.tiff...")
##     if (write.to.file)  tiff (paste (analysis.dir, "env.layer.2.tiff", sep=''))
## #    draw.img (env.layers [[2]])
## #    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
##     draw.filled.contour.img (env.layers [[2]], 
##                              "Env Layer 2", "Env\nMeasure2", 
##                              cm.colors, "red")
##     if (write.to.file)  dev.off()




    #  ALSO NEED TO RANK ALL OF THE PIXELS IN THE IMAGE AND THEN 
    #  COMPARE THOSE RANKS.
    #  USE THE ORDER() FUNCTION?  OR IS THERE A RANK FUNCTION?
    #  THEN, PLOT THE ORDERING, OR AT LEAST COLOR IN THE PIXELS 
    #  THAT ARE IN THE TOP 10% TO SEE HOW THEY COMPARE.  
    #  CAN THE QUANTILE() FUNCTION HELP HERE?




cat ("\nWrite prob dist tiffs...")    
force.imgs.to.same.scale.and.plot (norm.prob.matrix, maxent.norm.prob.dist, 
              paste (analysis.dir, "true.prob.dist.", spp.name, ".tiff", sep=''), 
              paste (analysis.dir, "maxent.prob.dist.", spp.name, ".tiff", sep=''), 
              "True Prob Distribution", 
              "Maxent Prob Distribution", 
              "Prob", 
              terrain.colors, "red"
              )

##     cat ("\nWrite true.prob.dist.?.tiff...")    
##     if (write.to.file)  tiff (paste (analysis.dir, "true.prob.dist.", spp.name, ".tiff", sep=''))
## #    draw.img (norm.prob.matrix) 
## #    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
##     draw.filled.contour.img (norm.prob.matrix, 
##                              "True Prob Distribution", "Prob", 
##                              terrain.colors, "red")
##     if (write.to.file)  dev.off()
## 
##     cat ("\nWrite maxent.prob.dist.?.tiff...")    
##     if (write.to.file)  tiff (paste (analysis.dir, "maxent.prob.dist.", spp.name, ".tiff", sep=''))
## #    draw.img (maxent.norm.prob.dist) 
## #    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
##     draw.filled.contour.img (maxent.norm.prob.dist, 
##                              "Maxent Prob Distribution", "Prob", 
##                              terrain.colors, "red")
##     if (write.to.file)  dev.off()

        #  To run Zonation over the distributions, we need them in .asc form. 
        #  Maxent already wrote its distribution in that form (e.g., spp.1.asc) 
        #  in the maxent outputs directory.  
        #  We just need to spit out the correct distribution now.
    true.dist.asc.filename.root <- paste (maxent.output.dir, "true.prob.dist.", spp.name, ".tiff", sep='') 
    write.asc.file (norm.prob.matrix, true.dist.asc.filename.root, 
                    num.rows, num.cols
                    , xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
                    , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
                                      #  is not actually on the map.  It's just off the lower 
                                      #  left corner.
                    , no.data.value = -9999    #  Maxent's missing value flag
                    , cellsize = 1
                    )
                    
    cat ("\nWrite abs.error.map.?.tiff...")    
    if (write.to.file)  tiff (paste (analysis.dir, "abs.error.map.", spp.name, ".tiff", sep=''))
    contour.levels.to.draw <- c (0.20)
    draw.contours = TRUE 
    draw.filled.contour.img (err.magnitudes, 
                             "Absolute error in Maxent Probability", 
                             "Error\n(prob)", 
                             heat.colors, "blue", 
                             draw.contours, 
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()

    cat ("\nWrite error.map.?.tiff...")    
    if (write.to.file)  tiff (paste (analysis.dir, "error.map.", spp.name, ".tiff", sep=''))
#    plot.main.title <- "Percent error in Maxent Probability"
#    plot.key.title <- "Error\n(percent)"
#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
    contour.levels.to.draw <- c (20)
    draw.contours = TRUE 
    draw.filled.contour.img (truncated.err.img, 
                             "Percent error in Maxent Probability", 
                             "Error\n(percent)", 
                             heat.colors, "turquoise", 
                             draw.contours, 
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()

    cat ("\n\nDone writing tiffs...\n\n")    

    #  Not using this at the moment since I've gotten the filled.contour() 
    #  code to behave pretty well.  May need this more stripped down stuff 
    #  later though.  It also will draw contour lines on the image instead 
    #  of just doing a graded image.  (However, I've just figured out how 
    #  to draw contour lines on the filled.contour maps too, so maybe it 
    #  doesn't matter.)
if (use.draw.image)
	{
    par (mfrow=c(1,2))
    
    draw.img (env.layers [[1]])
    draw.img (env.layers [[2]])
    
    draw.img (norm.prob.matrix) 
    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
    draw.img (maxent.norm.prob.dist) 
    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
    
    draw.img (truncated.err.img)
    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
    }

#===============================================================================

use.zonation.results <- TRUE
if (use.zonation.results)
    {
    CONST.zonation.no.data.flag <- -1
    CONST.replacement.value.for.zonation.no.data <- 0
    
    true.prob.dist.zonation.no.bqp.filename <- 
        paste (zonation.output.dir, "bill_cor_no_bqp.rank.asc", sep='')
    true.prob.dist.zonation.no.bqp <- 
	    as.matrix (read.table (true.prob.dist.zonation.no.bqp.filename, skip=6))
	true.prob.dist.zonation.no.bqp [true.prob.dist.zonation.no.bqp == 
	                                CONST.zonation.no.data.flag] <- 
	        CONST.replacement.value.for.zonation.no.data

    #----------
	            
write.to.file <-TRUE    

    cat ("\nWrite true.prob.dist.zonation.no.bqp.tiff...")    
    if (write.to.file)  tiff (paste (analysis.dir, "true.prob.dist.zonation.no.bqp.tiff", sep=''))
    contour.levels.to.draw <- c (0.9)
    draw.contours = TRUE 
    draw.filled.contour.img (true.prob.dist.zonation.no.bqp, 
                             "True Zonation rankings (no bqp)", 
                             "Proportional\nRank", 
                             terrain.colors, "black", 
                             draw.contours, 
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()

    #-----------------------
    
    maxent.dist.zonation.no.bqp.filename <- 
        paste (zonation.output.dir, "bill_app_no_bqp.rank.asc", sep='')
    maxent.dist.zonation.no.bqp <- 
	    as.matrix (read.table (maxent.dist.zonation.no.bqp.filename, skip=6))
	maxent.dist.zonation.no.bqp [maxent.dist.zonation.no.bqp == 
	                                CONST.zonation.no.data.flag] <- 
	        CONST.replacement.value.for.zonation.no.data

    #----------
	        
    cat ("\nWrite maxent.dist.zonation.no.bqp.tiff...")    
    if (write.to.file)  tiff (paste (analysis.dir, "maxent.dist.zonation.no.bqp.tiff", sep=''))
    contour.levels.to.draw <- c (0.9)
    draw.contours = TRUE 
    draw.filled.contour.img (maxent.dist.zonation.no.bqp, 
                             "Maxent Zonation rankings (no bqp)", 
                             "Proportional\nRank", 
                             terrain.colors, "black", 
                             draw.contours, 
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()

    #-----------------------

    	#  Compute the difference between the correct and maxent Zonation  
    	#  rankings.	
    err.between.maxent.and.true.zonation.rankings.no.bqp <- 
        maxent.dist.zonation.no.bqp - true.prob.dist.zonation.no.bqp
    err.magnitudes.zonation.rankings.no.bqp <- abs (err.between.maxent.and.true.zonation.rankings.no.bqp)

    percent.err.magnitudes.zonation.rankings.no.bqp <- (err.magnitudes.zonation.rankings.no.bqp / true.prob.dist.zonation.no.bqp) * 100
    hist (percent.err.magnitudes.zonation.rankings.no.bqp [percent.err.magnitudes.zonation.rankings.no.bqp <= 100])

    truncated.zonation.err.img.no.bqp <- percent.err.magnitudes.zonation.rankings.no.bqp 
    truncated.zonation.err.img.no.bqp [percent.err.magnitudes.zonation.rankings.no.bqp >= 100] <- 100

    #----------
	        
    cat ("\nWrite err.magnitudes.zonation.rankings.no.bqp.tiff...")    
    if (write.to.file)  tiff (paste (analysis.dir, "err.magnitudes.zonation.rankings.no.bqp.tiff", sep=''))
    contour.levels.to.draw <- c (0.2)
    draw.contours = TRUE 
    draw.filled.contour.img (err.magnitudes.zonation.rankings.no.bqp, 
                             "Absolute error magnitude in Zonation rankings (no bqp)", 
                             "Error", 
                             terrain.colors, "black", 
                             draw.contours, 
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()

    cat ("\nWrite percent.err.magnitudes.zonation.rankings.no.bqp.tiff...")    
    if (write.to.file)  tiff (paste (analysis.dir, "percent.err.magnitudes.zonation.rankings.no.bqp.tiff", sep=''))
    contour.levels.to.draw <- c (20)
    draw.contours = TRUE 
    draw.filled.contour.img (truncated.zonation.err.img.no.bqp, 
                             "Percent error in Zonation rankings (no bqp)", 
                             "Percent\nError", 
                             terrain.colors, "black", 
                             draw.contours, 
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()

    #-----------------------

    cat ("\n\n")
    
    true.top.zonation.locs.no.bqp <- which (true.prob.dist.zonation.no.bqp >= 0.9)
    num.true.top.locs <- length (true.top.zonation.locs.no.bqp)
    cat ("\nnum of locations in true top 10% = ", num.true.top.locs)

    maxent.top.zonation.locs.no.bqp <- which (maxent.dist.zonation.no.bqp >= 0.9)
    num.maxent.top.locs <- length (maxent.top.zonation.locs.no.bqp)
    cat ("\nnum of locations in maxent top 10% = ", num.maxent.top.locs)

    maxents.inside.trues <- maxent.top.zonation.locs.no.bqp %in% true.top.zonation.locs.no.bqp
    tp <- sum (maxents.inside.trues) / num.maxent.top.locs
    cat ("\ntp = fraction of maxent best 10% that is in true best 10% = ", tp)
    
    trues.inside.maxents <- true.top.zonation.locs.no.bqp %in% maxent.top.zonation.locs.no.bqp
    fn <- (num.true.top.locs - sum (trues.inside.maxents)) / num.true.top.locs
    cat ("\nfn = fraction of true best 10% that is not in maxent best 10% = ", fn)
    
    fp <- (num.maxent.top.locs - sum (trues.inside.maxents)) / num.maxent.top.locs
    cat ("\nfp = fraction of maxent best 10% that is not in true best 10% = ", fp)
    
    cat ("\n\n")
	}

#===============================================================================

    #  This "weird function" is taken from the R help file for levelplot.
    #  It makes an interesting radially banded pattern that could be a useful 
    #  synthetic test as a landscape pattern.
## library(lattice)
## x <- seq(pi/4, 5 * pi, length.out = 100)
## y <- seq(pi/4, 5 * pi, length.out = 100)
## r <- as.vector(sqrt(outer(x^2, y^2, "+")))
## grid <- expand.grid(x=x, y=y)
## grid$z <- cos(r^2) * exp(-r/(pi^3))
## levelplot(z~x*y, grid, cuts = 50, scales=list(log="e"), xlab="",
##            ylab="", main="Weird Function", sub="with log scales",
##            colorkey = FALSE, region = TRUE)

    #  That help file also gives an example of labelled contours that 
    #  could be useful too.
## require(stats)
## attach(environmental)
## ozo.m <- loess((ozone^(1/3)) ~ wind * temperature * radiation,
##        parametric = c("radiation", "wind"), span = 1, degree = 2)
## w.marginal <- seq(min(wind), max(wind), length.out = 50)
## t.marginal <- seq(min(temperature), max(temperature), length.out = 50)
## r.marginal <- seq(min(radiation), max(radiation), length.out = 4)
## wtr.marginal <- list(wind = w.marginal, temperature = t.marginal,
##         radiation = r.marginal)
## grid <- expand.grid(wtr.marginal)
## grid[, "fit"] <- c(predict(ozo.m, grid))
## contourplot(fit ~ wind * temperature | radiation, data = grid,
##             cuts = 10, region = TRUE,
##             xlab = "Wind Speed (mph)",
##             ylab = "Temperature (F)",
##             main = "Cube Root Ozone (cube root ppb)")
## detach()

#===============================================================================


