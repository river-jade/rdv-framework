#==============================================================================

#                       plot.condition.curves

#  Reads a .csv file containing 4 columns (time, and 3 condition curves)
#  and plots the 3 curves all on one plot with time as the x axis.

#  It also plots three different horizontal asymptote lines and a legend.

#------------------------------------------------------------------------------

#  Usage:
#          source ('plot.condition.curves.R');

#  History:
#    Created 2009.07.15 - BTL.

#==============================================================================

    #---------------------------------------------------------
    #  Set parameters controlling axes and labels on the plot.
    #---------------------------------------------------------

max.y.value <- 1.0;      #  True max is at 0.75, but leaving room for legend.

x.axis.label <- 'Time (years)';
y.axis.label <- 'Condition score (0-1)';

plot.title <- "(A) Reference curves for grassland condition change";

    #------------------------------------------------------------------
    #  Set y locations for each of the asymptote lines.
    #  Each one will be offset by a small amount from its true value so
    #  that the condition curves don't cover them up.
    #------------------------------------------------------------------

asymptote.offset <- 0.004;

upper.bound.value <- 0.75 + asymptote.offset;
lower.bound.value <- 0.01 - asymptote.offset;
threshold.value <- 0.35 + asymptote.offset;

    #-------------------------------
    #  Set characteristics of lines.
    #-------------------------------

line.thickness <- 3;    #  2 steps wider than default width
dashed.line.type <- 6;  #  double dashed line

    #-----------------------------------------------------------
    #  Shrink the legend text a little bit down from the default
    #  so that the legend doesn't take up so much of the plot.
    #-----------------------------------------------------------

legend.text.shrinkage.factor <- 0.7;

    #-----------------------------------------
    #  Specify the file to read the data from.
    #-----------------------------------------

condition.curves.filename <- 'condition.curves.csv';

#==============================================================================

    #--------------------------------------
    #  Load the curve points from the file.
    #--------------------------------------

condition.curves <- read.csv (condition.curves.filename);

    #---------------------------------------------------
    #  The first column is assumed to contain the times.
    #---------------------------------------------------

time.points <- condition.curves [,1];
num.points <- length (time.points);

    #-------------------------------------------------
    #  Draw the initial plot frame and the first curve
    #  (managed - below threshold).
    #-------------------------------------------------

cur.curve.idx <- 2;
plot (time.points, condition.curves [,cur.curve.idx],
      xlim = c(1,time.points [num.points]), 
      ylim = c(0, max.y.value), 
      xlab = x.axis.label,
      ylab = y.axis.label,
      col = 1,
      lwd = line.thickness, 
      type='l'
      );

    #-------------------------------------------------------------------
    #  Put a title on the plot.
    #  (Can't remember what the padj = -1 is for; cloned it from another
    #   bit of code.  It works though...)
    #-------------------------------------------------------------------

mtext (plot.title, padj = -1);

    #--------------------------------------------------------
    #  Plot the second curve now (managed - above threshold).
    #--------------------------------------------------------

cur.curve.idx <- cur.curve.idx + 1;
lines (time.points, condition.curves [,cur.curve.idx], col=2, lty=1,
       lwd=line.thickness);

    #----------------------------------------------------------
    #  Plot the final curve (unmanaged).
    #  Differentiate it from the others by using a dashed line.
    #----------------------------------------------------------

cur.curve.idx <- cur.curve.idx + 1;
lines (time.points, condition.curves [,cur.curve.idx], col=4,
       lty=dashed.line.type,
       lwd=line.thickness);

    #--------------------------------------
    #  Draw the asymptotes as dotted lines.
    #--------------------------------------

abline (h = upper.bound.value, lty = "dotted", col = "black");
abline (h = lower.bound.value, lty = "dotted", col = "black");
abline (h = threshold.value, lty = "dotted", col = "black");

    #-----------------------------------------------------------------
    #  Finally, draw the legend in the upper right corner of the plot.
    #  Inset it from the corners by 5% of the size of the plot so that
    #  it's easier to read.
    #-----------------------------------------------------------------

legend("topright",
       c("managed - below thresh", "managed - above thresh", "unmanaged"),
       col = c(1,2,4),
       lty = c(1, 1, dashed.line.type),
       lwd = c(line.thickness, line.thickness, line.thickness),
       cex = legend.text.shrinkage.factor,
       inset = 0.05
       );

    #--------------------------------------------------------------
    #  Save the results to a file (encapsulated postcript for now).
    #--------------------------------------------------------------

plotfile.name <- "condition.curves.plot.eps";  #  Change extension if not eps.
savePlot (filename = plotfile.name,
          type = "eps"
          #c("wmf", "emf", "png", "jpg", "jpeg", "bmp",
          #        "tif", "tiff", "ps", "eps", "pdf")
          );

#==============================================================================


