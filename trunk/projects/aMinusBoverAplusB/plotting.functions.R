#==============================================================================

#                        plotting.functions.R

###	Usage:
###        source ('plotting.functions.R');

#  Routines for plotting the results of the uncertainty tests on the
#  functional forms being considered as a metric.

#==============================================================================

#  History:

#  BTL - 2009.08.05
#	 - Extracted from metrics.R

#  LS - 2012.07.11
#    - added option that allows turning off the representation of 2D plots in
#      between 3D plots

#  BTL - 2013.11.12
#    - Moved from /Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/P04 a-b over a+b/R_files/plotting.functions.v12.LS.R
#      to /Users/Bill/D/rdv-framework/projects/aMinusBoverAplusB/plotting.functions.R
#      to try running it under tzar and keeping the project under version control.

#==============================================================================

build.surface.for <- function (col.name.string,
                               z.values.in.one.col,
                               num.rows, num.cols
                               )
  {
  zz <- matrix (NA, nrow = num.rows, ncol = num.cols);

  i <- 0;

  for (slow.idx in 1:num.rows)
    for (fast.idx in 1:num.cols)
      {
      i <- i + 1;

      zz [slow.idx, fast.idx] <- z.values.in.one.col [i, col.name.string];
      }

  return (zz);
  }

#==============================================================================

##        plot.surface.in.3D (results.for.cur.gamma.B,
##                            name.of.var.to.plot,
##                            err.A.values, err.B.values,
###                            "Overest   <-    err.Res    ->   Underest",
##                            "Overest   <-    err.A    ->   Underest",
##
###                            "Overest   <-    err.Dev    ->   Underest",
##                            "Overest   <-    err.B    ->   Underest",
##                            plot.title,
##                            z.min, z.max,
##                            plotfile.name.stem,
##                            compute.max.and.min.z.values
##                            );

plot.surface.in.3D <- function (values.for.pairs,
                                col.name.string,
                                r, c,
                                r.label.string,
                                c.label.string,
                                plot.title,
                                z.min, z.max,
                                plotfile.name.stem,
                                compute.max.and.min.z.values
                                )
  {
#  plot(0);  # temporary...
#  par (mfrow = c (1,1));
#  par (mfrow = c (2,2));

  if (DEBUG.PLOT)
    {
    cat ("\nAt start of plot.surface.in.3D:",
         "\n    r = ", r, ", c = ", c,
         "z.min = ", z.min, ", z.max = ", z.max,
         sep='');
    }

  zz <- build.surface.for (col.name.string, values.for.pairs,
                           length(r), length(c));

#cat ("\n\nJust finished building zz.\n")
#browser()

if (compute.max.and.min.z.values)
  {
  min.zz <- min (zz, na.rm = TRUE);
  if (min.zz < 0) z.min <- floor (min.zz) else z.min <- ceiling (min.zz);

  max.zz <- max (zz, na.rm = TRUE);
  if (max.zz < 0) z.max <- floor (max.zz) else z.max <- ceiling (max.zz);

  if (z.min == z.max)
      {
      cat ("\n\nWarning: in plot.summary.stats.for.A.B, z.min == z.max == ",
           z.min, "\nAdding 1 to max to avoid crashing plotting code.\n\n");
      z.max <- z.min + 1;
      }
  if (z.min == -Inf)
    z.min <- -10;
  if (z.max == Inf)
    z.max <- 10;
  }

  z.limits <- c (z.min, z.max);

  if (DEBUG.PLOT)
    {
    cat ("\nJust before 2D plot:",
         "\n    z.min = ", z.min, ", z.max = ", z.max,
         "\n    z.limits = (", z.limits [1], ", ", z.limits [2], ")\n",
         sep='');
    }

#  if (stop.plotting)
#    browser();

      #----------------------------------------------------------------
      #  Do a 2D plot only for the cases where all of the error is in B
      #  and there is no error in A.
      #----------------------------------------------------------------
if (plot.2D.err.0.cross.sections)     # LS (2012.07.11) added option
{
  par (mfrow = c (1,2));
#  par (mfrow = c (1,1));
  plot (r, zz[idx.where.err.A.is.0,],
#        xlab = c.label.string,
        xlab = paste (c.label.string, " (no err in A)", sep = ''),
        ylab = col.name.string,
        ylim = z.limits,
        type = 'l',
        main = plot.title,
        font.main = 1
        );

#  abline (h = err.ratio.magnify.display.plane.cutoff,
  abline (h = display.plane.cutoff,
          col = 'red',
          lty = 'dashed'
          );

  if (col.name.string == "rel.err.M")
    {
    abline (a = 0, b = 1, col= 'blue');
    abline (a = 0, b = -1, col= 'blue');
    }

#  if (save.2D.plots)
#    {
#    plotfile.name <- paste (plotfile.name.stem,
#                            "2D.noErrInA",
#                            "jpg", sep = ".");
#    savePlot (plotfile.name, "jpg");
#    }

      #----------------------------------------------------------------
      #  Do a 2D plot only for the cases where all of the error is in A
      #  and there is no error in B.
      #----------------------------------------------------------------

#  par (mfrow = c (1,1));
  plot (r, zz[,idx.where.err.B.is.0],
#        xlab = r.label.string,
        xlab = paste (r.label.string, " (no err in B)", sep = ''),
        ylab = col.name.string,
        ylim = z.limits,
        type = 'l',
        main = plot.title,
        font.main = 1
        );

#  abline (h = err.ratio.magnify.display.plane.cutoff,
  abline (h = display.plane.cutoff,
          col = 'red',
          lty = 'dashed'
          );

  if (col.name.string == "rel.err.M")
    {
    abline (a = 0, b = 1, col= 'blue');
    abline (a = 0, b = -1, col= 'blue');
    }

  if (save.2D.plots)
    {
    plotfile.name <- paste (plotfile.name.stem,
#                            "2D.noErrInB",
                            "2D",
                            "jpg", sep = ".");
    savePlot (plotfile.name, "jpg");
    }
}
      #-------------------------------------------------------------------
      #  Draw 3D plots for current surface at various viewing angles.
      #
      #  For the moment, I've switched off the multiple viewing angles
      #  by making the bounds of the for loop have the same start and end.
      #  At the moment, only want to show one view so that it can be
      #  shown in sequence with the same view from other gamma,B settings.
      #-------------------------------------------------------------------

#p.theta <- 60;    #  These were angle settings that were useful at one time.
#p.phi <- 30;      #  Just want to remember them...
#p.ltheta <- 180;
#  angle.step <- 150;
#  for (p.theta in seq (angle.step,360,angle.step))

  p.phi <- 20;
  p.ltheta <- 180;
#  angle.step <- 150;
#  angle.step <- 3300;

  angle.step <- 240;
  angle.start <- angle.step;
  angle.end <- angle.step;
  par (mfrow = c (1,1));

  if (plot.multi.pane.3D)
    {
#    par (mfrow = c (2,3));
    par (mfrow = c (2,2));

    angle.step <- 90;
    angle.start <- 60;
    angle.end <- 330;
    }

#  for (p.theta in seq (angle.step,360,angle.step))
#  for (p.theta in seq (angle.step, angle.step, angle.step))
  for (p.theta in seq (angle.start, angle.end, angle.step))
    {
## temporary ##  if (! RS.paper)
{
    res <- persp(r, c, zz,
                 theta = p.theta,
                 phi = p.phi,
                 ltheta = p.ltheta,
                 expand = 0.5,
                 col = "lightblue",
                 zlim = z.limits,
          #      shade = 0.75,
                 ticktype = "detailed",
                 xlab = r.label.string,
                 ylab = c.label.string,
                 zlab = col.name.string,
                 main = plot.title,
                 font.main = 1
                 );

      #-------------------------------------------------------------
      #  This code draws a red line that follows the contours of the
      #  err.B=0 column of the matrix describing the surface to be
      #  plotted in perspective.
      #  The code is cloned from the code in the ?persp help output
      #  and the rdv framework file called plot.diff.3d.small.R.
      #
      #  It has one problem that I don't know how to fix at the
      #  moment.  That is, it doesn't hide the red line when it
      #  goes behind something that should obscure it from view.
      #  For the moment, that's ok, since I just want to get a
      #  clue about how the 0 contour is behaving.
      #-------------------------------------------------------------

    y1 <- rep (c[idx.where.err.B.is.0], length (r));
    lines (trans3d (r, y1, zz[,idx.where.err.B.is.0], res), col="red",  lwd=2);

}  #  end if NOT RS.paper

    if (RS.paper)
        {
#V2
##        heatmap(zz, Rowv=NA, Colv=NA, col = heat.colors(256),
##                scale="column", margins=c(5,10))

#V1
#        http://martinsbioblogg.wordpress.com/2013/03/21/using-r-correlation-heatmap-with-ggplot2/
#        library(ggplot2)
#        library(reshape2)
#        qplot(x=Var1, y=Var2, data=melt(cor(attitude)), fill=value, geom="tile")

#        http://mintgene.wordpress.com/


#V3
#  heatmapLearning.R

#  From  http://mintgene.wordpress.com/

## required packages (plot, melt data frame, and rolling function)
#library(ggplot2)
#library(reshape)
#library(zoo)

## repeat random selection
#set.seed(1)

## create 50x10 matrix of random values from [-1, +1]
#random_matrix <- matrix(runif(500, min = -1, max = 1), nrow = 50)
#random_matrix <- matrix(runif(21*21, min = -1, max = 1), nrow = 21)
        #####random_matrix = zz

#####cat ("\n\nJust assigned zz to random_matrix...\n")

#+++++++++++++++++++

errSteps = seq (-0.1, 0.1, 0.01)
numErrSteps = length (errSteps)
magValues = zz
#    10 * abs (matrix (rnorm(numErrSteps*numErrSteps),
#                      ncol = numErrSteps))
x <- errSteps  # 10*1:nrow(magValues)
y <- errSteps  # 10*1:ncol(magValues)



YlOrBr <- c("#FFFFD4", "#FED98E", "#FE9929", "#D95F0E", "#993404")
#               color.palette = colorRampPalette(YlOrBr, space = "Lab"),
#               color.palette = colorRampPalette(YlOrBr, space = "Lab",
#                                               bias = 0.5),
#               asp = 1)

showFilledContour = TRUE
if (showFilledContour)
{
#  NOTE: colorRampPalette() help page says that bias is a positive
#        number and higher values give more widely spaced colors at
#        the high end.
filled.contour(x, y, magValues,
               #color = terrain.colors,

               color.palette =
                   #                   colorRampPalette(c("green", "white", "red")),
                   #                   colorRampPalette(c("light yellow", "orange", "red")),
                   colorRampPalette(c("light blue", "red")),

               #                    colorRampPalette(YlOrBr, space = "Lab"
               #                                     , bias = 0.75
               #                                     ),

               plot.title = title(main = plot.title, #"Error Magnification\nin current metric",
                                  xlab = "err in A", ylab = "err in B"),
               #    plot.axes = { axis(1, seq(100, 800, by = 100))
               #                  axis(2, seq(100, 600, by = 100)) },
               key.title = title(main = "Err Mag")  # ,
               #    key.axes = axis(4, seq(90, 190, by = 10))
)  # maybe also asp = 1
mtext(paste("Drawn using filled.contour(.) from", R.version.string),
      side = 1, line = 4, adj = 1, cex = .66)
}

showHeatMap = FALSE
if (showHeatMap)
{
require (gplots)
heatmap.2(zz, dendrogram="none", Colv = FALSE, Rowv = FALSE)

##heatmap.2(zz, dendrogram = "none", Rowv = FALSE, Colv = FALSE,
##          col = bluered(256), scale = "none", key = TRUE, density.info = "none", trace = "none",
##          cexRow = 0.125, cexCol = 0.125, symm = F, symkey = T, symbreaks = T)
}

#+++++++++++++++++++


#browser()

skipOld = TRUE
if (!skipOld)
{
## set color representation for specific values of the data distribution
#  BTL - generated error because of na values, so had to add an option
#        setting to deal with it, i.e., na.rm = TRUE
quantile_range <- quantile(random_matrix, probs = seq(0, 1, 0.2),
                            na.rm = TRUE)

## use http://colorbrewer2.org/ to find optimal divergent color palette (or set own)
color_palette <- colorRampPalette(c("#3794bf", "#FFFFFF", "#df8640"))(length(quantile_range) - 1)

## prepare label text (use two adjacent values for range text)
label_text <- rollapply(round(quantile_range, 2), width = 2, by = 1, FUN = function(i) paste(i, collapse = " : "))

## discretize matrix; this is the most important step, where for each value we find category of predefined ranges (modify probs argument of quantile to detail the colors)
mod_mat <- matrix(findInterval(random_matrix, quantile_range, all.inside = TRUE), nrow = nrow(random_matrix))

## remove background and axis from plot
theme_change <- theme(
    plot.background = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    panel.background = element_blank(),
    panel.border = element_blank(),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank()
)

## output the graphics
ggplot(melt(mod_mat), aes(x = X1, y = X2, fill = factor(value))) +
    geom_tile(color = "black") +
    scale_fill_manual(values = color_palette, name = "", labels = label_text) +
    theme_change  +
    coord_fixed()        #  Make plot square (http://stackoverflow.com/questions/7056836/r-how-to-fix-the-aspect-ratio-in-ggplot)

#browser()

#  You can change interval to color relationship by modifying quantile_range
#  and color_palette objects. Each sliding pair within quantile_range
#  corresponds to a single color (upper and lower boundary).

#  To change the colors within ranges, you’d write something like:
#      color_palette[4] <- "#a95af6"

# …, which would generate a heatmap like this:
#    http://s12.postimg.org/58ph022lp/comment.png

}

        }  #  end if RS.paper
    }

        #----------------------------------------------------------
        #  Write the plot to a file.
        #  Need to explicitly put the "." and the file extension on
        #  file name stem because R won't do it if there is already
        #  a "." somewhere in the filename, e.g., "g0.5".
        #  Don't usually need to do this, but in this case,
        #  all or nearly all file names will contain "0." somewhere
        #  in the name.
        #----------------------------------------------------------

  if (save.3D.plots)
    {
    plotfile.name <- paste (plotfile.name.stem,
                            "jpg", sep = ".");
    savePlot (plotfile.name, "jpg");
    }
  }

#==============================================================================

