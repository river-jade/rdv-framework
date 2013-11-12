#==============================================================================

                                #  heatmapLearning.R

#  Random bits of code I was testing to learn how to use heatmaps in R.
#  Eventually moved to doing this in R Markdown in RStudio in the file
#  called heatmapLearning.Rmd.

#==============================================================================

#  History:

#    BTL - 2013.11.12
#    Moved from /Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/P04 a-b over a+b/R_files/heatmapLearning.R
#    to /Users/Bill/D/rdv-framework/projects/aMinusBoverAplusB/heatmapLearning.R
#    to try running it under tzar and keeping the project under version control.

#==============================================================================

#  heatmapLearning.R

#  From  http://mintgene.wordpress.com/

## required packages (plot, melt data frame, and rolling function)
library(ggplot2)
library(reshape)
library(zoo)

## repeat random selection
set.seed(1)

## create 50x10 matrix of random values from [-1, +1]
#random_matrix <- matrix(runif(500, min = -1, max = 1), nrow = 50)
random_matrix <- matrix(runif(21*21, min = -1, max = 1), nrow = 21)

## set color representation for specific values of the data distribution
quantile_range <- quantile(random_matrix, probs = seq(0, 1, 0.2))

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
    coord_fixed()        #  Makes to plot square (http://stackoverflow.com/questions/7056836/r-how-to-fix-the-aspect-ratio-in-ggplot)




#  You can change interval to color relationship by modifying quantile_range
#  and color_palette objects. Each sliding pair within quantile_range
#  corresponds to a single color (upper and lower boundary).

#  To change the colors within ranges, you’d write something like:
#      color_palette[4] <- "#a95af6"

# …, which would generate a heatmap like this:
#    http://s12.postimg.org/58ph022lp/comment.png
