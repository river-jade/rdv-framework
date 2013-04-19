#=========================================================================================

#                               guppySupportFunctions.R

# source( 'guppySupportFunctions.R' )

#=========================================================================================

#  History:

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#=========================================================================================

xy.rel.to.lower.left <- function (n, nrow)    #**** the key function ****#
	{
	n.minus.1 <- n - 1
	return ( c (1 + (n.minus.1 %/% nrow),
			    nrow - (n.minus.1 %% nrow)
			   )
		   )
	}

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

