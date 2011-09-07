#==============================================================================

###	Usage:
###		source ('load.all.hab.patches.map.R');

#  History:
#      - Changed to stand alone by loading global variables through a file
#        written by the python code.
#        BTL - 27/2/09.

#==============================================================================

    #---------------------------------------------------------------
    #  Load global variables from a file written by the python code.
    #---------------------------------------------------------------

source( 'variables.R' )

#==============================================================================

	#  Load the habitat patch map.
	#  Every pixel in the map has the ID of the patch containing it.
all.hab.patches.map <- 
    as.matrix (read.table (master.habitat.map.pid.filename));


num.rows <- (dim (all.hab.patches.map))[1];
num.cols <- (dim (all.hab.patches.map))[2];

	#  Get the list of patch IDs from the map and determine how many 
	#  patches there are.
	#  Ignore patch 0.  It's the background (i.e., non-habitat) indicator.
patch.IDs <- sort (unique (as.vector (all.hab.patches.map)));
patch.IDs <- patch.IDs [patch.IDs != GC.non.habitat.indicator];

tot.num.patches <- length (patch.IDs);

#==============================================================================
