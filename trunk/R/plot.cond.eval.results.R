#==============================================================================
#
#                            plot.cond.eval.results.R
#
#  Plot the results of evaluating the condition of the landscape.
#
#  To run:
#      source( 'plot.cond.eval.results.R' )
#
#
#  Create 24/02/09 - BTL.
#
#==============================================================================

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'w.R' );
source( 'variables.R' );

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

#  moved to python...

#==============================================================================

    #-------------------------------------------
    #  Get the current map of habitat condition.
    #-------------------------------------------

eval.cond.results <- as.matrix (read.table (eval.cond.outfile.name));

    #---------------

	#  Plot the results on a single figure using a 3x3 layout.
par (mfrow = c(3,1));

k = 2
  plot (eval.cond.results [,1], eval.cond.results [,k], 
	xlim=c(0, max(eval.cond.results [,1])), 
	ylim=c(0, max(eval.cond.results [,k])), 
	xlab="Time step",
	ylab='Condition Sum',
	type='l'
	);

mtext( "Condition scores: (black=tot, red=reserved, blue=unreserved)",
      padj = -1);

  lines (eval.cond.results [,1], eval.cond.results [,k+3], col="red", lty=1);
  lines (eval.cond.results [,1], eval.cond.results [,k+6], col="blue", lty=1);

  k = 3
  plot (eval.cond.results [,1], eval.cond.results [,k], 
	xlim=c(0, max(eval.cond.results [,1])), 
	ylim=c(0, max(eval.cond.results [,6])), 
	xlab="Time step",
	ylab='Condition Mean',
	type='l'
	);

  lines (eval.cond.results [,1], eval.cond.results [,k+3], col="red", lty=1);
  lines (eval.cond.results [,1], eval.cond.results [,k+6], col="blue", lty=1);


  k = 4
  plot (eval.cond.results [,1], eval.cond.results [,k], 
	xlim=c(0, max(eval.cond.results [,1])), 
	ylim=c(0, max(eval.cond.results [,7])), 
	xlab="Time step",
	ylab='Condition Median',
	type='l'
	);

  lines (eval.cond.results [,1], eval.cond.results [,k+3], col="red", lty=1);
  lines (eval.cond.results [,1], eval.cond.results [,k+6], col="blue", lty=1);




     
#==============================================================================
