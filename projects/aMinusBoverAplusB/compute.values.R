#==============================================================================

#                             compute.values.R

###	Usage:
###        source ('compute.values.R');

#==============================================================================

#  History:

#  BTL - 2009.08.12
#	 - extracted from gamma.v6.R

#  BTL - 2013.11.12
#    - Moved from /Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/P04 a-b over a+b/R_files/compute.values.v11.R
#      to /Users/Bill/D/rdv-framework/projects/aMinusBoverAplusB/compute.values.R
#      to try running it under tzar and keeping the project under version control.

#==============================================================================

library(lattice)

#==============================================================================

compute.values <- function (experiment.name, short.experiment.name,
                            experiment.eqn.string, func.M)
  {
      #------------------------------------------------------------------
      #  Ready now to create the matrix where the results for all gamma,B
      #  pairs will be stored.
      #
      #  In the results, there will be one row for each combination of the
      #  four different variables.
      #-------------------------------------------------------------------

  cat ("\n\n*****  number of rows to do = ", num.result.rows,
       "  *****", sep='');

  results <- matrix (CONST.illegal.number,
                     nrow = num.result.rows,
                     ncol = num.result.cols);

  colnames (results) <- result.col.names;

      #----------------------------------------
      #  Results for just the current A,B pair.
      #----------------------------------------

#  num.err.A.B.pairs <- num.err.A.values * num.err.B.values;
  cur.gamma.B.results <- matrix (CONST.illegal.number,
#                                 nrow = num.err.A.B.pairs,
                                 nrow = num.err.tuples,
                                 ncol = num.result.cols);

  colnames (cur.gamma.B.results) <- result.col.names;

#-----------------------------------------------------------------------------

      #--------------------------------------------------------
      #  Finally ready to compute the candidate metric function
      #  for each A,B pair error level.
      #--------------------------------------------------------
  cur.idx <- 1;
      for (cur.triple in 1:num.gamma.A.B.triples)
        {
        gamma <- gamma.A.B.triples [cur.triple, "gamma"];
        app.A <- gamma.A.B.triples [cur.triple, "app.A"];
        app.B <- gamma.A.B.triples [cur.triple, "app.B"];

        if (DEBUG)
          {
          cat ("\ncur.triple = ", cur.triple,
               ", gamma = ", gamma,
               ", app.A = ", app.A,
               ", app.B = ", app.B
               );
          }

        if (build.err.tuples.from.normal.distributions)
          {
              #-----------------------------------------------------
              #  Build cor and err values by drawing errors from
              #  normal distributions whose standard deviations are
              #  given by the user.  Their mean error is set to
              #  be zero.
              #-----------------------------------------------------

          if (debug.normal.dist)
            {
            cat ("\n--------------\n\nAt cur.idx = ", cur.idx,
                 "/", num.result.rows,
                 ", app.A = ", app.A, ", app.B = ", app.B);
            }

          cor.and.err.tuples <-
              build.cor.and.err.tuples.from.normal.dist.draws (app.A, app.B,
                                                               sd.A, sd.B,
                                                               num.err.tuples);
          } else
          {
              #-----------------------------------------------------
              #  Build cor and err values from a set of error levels
              #  given by the user.
              #-----------------------------------------------------

          cor.and.err.tuples <-
              build.cor.and.err.tuples.from.given.err.sequences (app.A, app.B,
                                        min.err.A, max.err.A, err.A.step.size,
                                        min.err.B, max.err.B, err.B.step.size);
          }

        num.tuples <- dim (cor.and.err.tuples) [1];

        for (cur.tuple.idx in 1:num.tuples)
          {
          cor.A <- cor.and.err.tuples [cur.tuple.idx, "cor.A"];
          err.A <- cor.and.err.tuples [cur.tuple.idx, "err.A"];

          cor.B <- cor.and.err.tuples [cur.tuple.idx, "cor.B"];
          err.B <- cor.and.err.tuples [cur.tuple.idx, "err.B"];

          if (DEBUG)
            {
            cat ("\n[", cur.tuple.idx, ", ] = \n",
                 "    cor.A = ", cor.A,
                 "    err.A = ", err.A,
                 "    cor.B = ", cor.B,
                 "    err.B = ", err.B
                 );
            }

              #------------------------------------------------------
              #  Echo the state of the main variables every 100 steps
              #  to give some hint at the progress of the operation.
              #------------------------------------------------------

          if ((cur.idx %% 1000) == 0)
            {
            cat ("\ncur.idx = ", cur.idx, "/", num.result.rows,
                 ", gamma:", gamma,
                 ", app.A:", app.A,
                 ", app.B:", app.B,
                 ", err.A:", err.A,
                 ", err.B:", err.B,
                 ", cor.A:", cor.A,
                 ", cor.B:", cor.B,
                 sep = ''
                 );
            }

              #-------------------------------
              #  Save current state variables.
              #-------------------------------

          results [cur.idx, "gamma"] <- gamma;
          results [cur.idx, "app.A"] <- app.A;
          results [cur.idx, "app.B"] <- app.B;
          results [cur.idx, "cor.A"] <- cor.A;
          results [cur.idx, "cor.B"] <- cor.B;
          results [cur.idx, "err.A"] <- err.A;
          results [cur.idx, "err.B"] <- err.B;
          results [cur.idx, "err.idx"] <- cur.tuple.idx;

              #-----------------------------------------------------------
              #  Compute metric value for apparent and then correct values
              #  of A and B.
              #-----------------------------------------------------------

          app.M.ret.values <- func.M (app.A, app.B);
          app.M <- app.M.ret.values$M;
          results [cur.idx, "app.M"] <- app.M;

          cor.M.ret.values <- func.M (cor.A, cor.B);
          cor.M <- cor.M.ret.values$M;
          results [cur.idx, "cor.M"] <- cor.M;

              #---------------------------------------------------------
              #  The metric calculation routines also track various
              #  things about whether the inputs and the outputs had
              #  legal values.
              #  Save those flags in case you need to know later.
              #  (Not sure if they're really ever used though, with
              #   the one exception of "both.app.M.and.cor.M.are.legal")
              #---------------------------------------------------------

                  #-------------------
                  #  First, apparent
                  #-------------------

          results [cur.idx, "app.M.is.legal"] <-
              app.M.ret.values$is.legal;
          results [cur.idx, "app.M.is.legal.pos"] <-
              app.M.ret.values$is.legal.pos;
          results [cur.idx, "app.M.is.legal.neg"] <-
              app.M.ret.values$is.legal.neg;

                  #-----------------
                  #  Then, correct
                  #-----------------

          results [cur.idx, "cor.M.is.legal"] <-
              cor.M.ret.values$is.legal;
          results [cur.idx, "cor.M.is.legal.pos"] <-
              cor.M.ret.values$is.legal.pos;
          results [cur.idx, "cor.M.is.legal.neg"] <-
              cor.M.ret.values$is.legal.neg;

                  #---------------------------------------------
                  #  And finally, make sure that both are legal.
                  #---------------------------------------------

          both.app.M.and.cor.M.are.legal <-
              (app.M.ret.values$is.legal & cor.M.ret.values$is.legal);
          results [cur.idx, "both.app.M.and.cor.M.are.legal"] <-
              both.app.M.and.cor.M.are.legal;

              #-------------------------------------------------------
              #  If both metric values are legal, compute the errors
              #  between them.
              #-------------------------------------------------------

          if (both.app.M.and.cor.M.are.legal)
            {
                #---------------------------------------
                #  First compute and save the raw error.
                #---------------------------------------

            raw.err.M <- app.M - cor.M;
            if (use.app.M.as.rel.err.base)
              {
              raw.err.M <- cor.M - app.M;
              }

            if (only.show.above.cutoff)
              {
              results [cur.idx, "raw.err.M"] <-
                get.above.cutoff.value (raw.err.M,
                                        raw.err.display.plane.cutoff);

              } else
              {
              if (only.show.cutoff.and.below)
                {
                results [cur.idx, "raw.err.M"] <-
                  get.at.or.below.cutoff.value (raw.err.M,
                                                raw.err.display.plane.cutoff);

                } else  #  Show all values that are not NA.
                {
                results [cur.idx, "raw.err.M"] <- raw.err.M;
                }
              }

                #----------------------------------------------------
                #  Now compute the relative error with respect to the
                #  whichever value you have chosen as the error base,
                #  either cor.M or app.M.
                #  If that value was 0 though, you
                #  can't compute a value for the relative error.
                #----------------------------------------------------

            rel.err.base <- cor.M;
            if (use.app.M.as.rel.err.base)  rel.err.base <- app.M;

            if (rel.err.base == 0)
              {
                  #-----------------------------------------------------
                  #  Zero denominator so can't compute a relative error.
                  #-----------------------------------------------------

              rel.err.M <- CONST.illegal.number;
              err.diff.magnify.M <- CONST.illegal.number;
              err.ratio.magnify.M <- CONST.illegal.number;

              } else
              {
                  #-----------------------------------------------------
                  #  Denominator is not zero, so compute relative error.
                  #-----------------------------------------------------

              rel.err.M <- raw.err.M / rel.err.base;

                  #-----------------------------------------------------------
                  #  Want to test magnification with respect to the magnitudes
                  #  of the errors rather than their signs, so find the
                  #  absolute values of the various errors.
                  #-----------------------------------------------------------

              abs.val.rel.err.M <- abs (rel.err.M);
              abs.val.err.A <- abs (err.A);
              abs.val.err.B <- abs (err.B);

                  #----------------------------------------------
                  #  Figure out what was the biggest input error.
                  #----------------------------------------------

              max.abs.val.err.A.or.B <- max (abs.val.err.A, abs.val.err.B);

                  #---------------------------------------------------------
                  #  Now ready to see whether the largest input error is
                  #  magnified by computing M using erroneous values.
                  #  This is computed in two ways: simple difference and
                  #  ratio.
                  #---------------------------------------------------------
                      #-----------------------------------------------------
                      #  The first way just checks to see if output error is
                      #  larger than the input error and it returns the
                      #  difference between the two.
                      #  A positive value means there was magnification.
                      #  Zero means no difference in the input and output
                      #  errors.
                      #  A negative number means that the error was reduced.
                      #-----------------------------------------------------

              err.diff.magnify.M <-
                  abs.val.rel.err.M - max.abs.val.err.A.or.B;

                      #------------------------------------------------------
                      #  The second way is just the ratio of the output error
                      #  to the input error.
                      #  A value of 1 means no magnification.
                      #  Greater than 1 means magnfication.
                      #  Less than 1 means the error was reduced.
                      #  Because it's a ratio, we also have to insure there
                      #  is not divide by 0.
                      #------------------------------------------------------

              if (max.abs.val.err.A.or.B == 0.0)
                {
                err.ratio.magnify.M <- CONST.illegal.number;
                } else
                {
                err.ratio.magnify.M <-
                    abs.val.rel.err.M / max.abs.val.err.A.or.B;

                if (err.ratio.magnify.M < 0)
                  {
                    cat ("\n\n>>>>>  negative mag ratio = ",
                         err.ratio.magnify.M, "\n");
                    browser();
                  }

                if (DEBUG)
                  {
                  cat ("\nabs.val.rel.err.M != 1",
                       "\n    abs.val.rel.err.M = ", abs.val.rel.err.M,
                       "\n    app.A = ", app.A,
                       "\n    app.B = ", app.B,
                       "\n    err.A = ", err.A,
                       "\n    err.B = ", err.B,
                       "\n    gamma = ", gamma,
                       "\n    raw.err.M = ", raw.err.M,
                       "\n    rel.err.base = ", rel.err.base,
                       "\n    abs.val.err.A = ", abs.val.err.A,
                       "\n    abs.val.err.B = ", abs.val.err.B,
                       "\n    max.abs.val.err.A.or.B = ",
                       max.abs.val.err.A.or.B,
                       "\n    abs.val.rel.err.M = ", abs.val.rel.err.M,
                       "\n    err.diff.magnify.M = ", err.diff.magnify.M,
                       "\n    err.ratio.magnify.M = ", err.ratio.magnify.M,
                       "\n\n", sep = '');

                  browser();
                  }

                }  #  end else - max err != 0
              }  #  end else app.M != 0



                #-----------------------------------------------------
                #  Last thing, save the error and magnification values
                #  for plotting later.
                #-----------------------------------------------------

            if (only.show.above.cutoff)
              {
              results [cur.idx, "rel.err.M"] <-
                get.above.cutoff.value (rel.err.M,
                                        rel.err.display.plane.cutoff);

              results [cur.idx, "err.diff.magnify.M"] <-
                get.above.cutoff.value (err.diff.magnify.M,
                                        err.diff.magnify.display.plane.cutoff);

              results [cur.idx, "err.ratio.magnify.M"] <-
                get.above.cutoff.value (err.ratio.magnify.M,
                      err.ratio.magnify.display.plane.cutoff);

              } else
              {
              if (only.show.cutoff.and.below)
                {
                results [cur.idx, "rel.err.M"] <-
                  get.at.or.below.cutoff.value (rel.err.M,
                                                rel.err.display.plane.cutoff);

                results [cur.idx, "err.diff.magnify.M"] <-
                  get.at.or.below.cutoff.value (err.diff.magnify.M,
                              err.diff.magnify.display.plane.cutoff);

                results [cur.idx, "err.ratio.magnify.M"] <-
                  get.at.or.below.cutoff.value (err.ratio.magnify.M,
                              err.ratio.magnify.display.plane.cutoff);

                } else  #  Show all values that are not NA.
                {
                results [cur.idx, "rel.err.M"] <- rel.err.M;

                results [cur.idx, "err.diff.magnify.M"] <- err.diff.magnify.M;

                results [cur.idx, "err.ratio.magnify.M"] <-
                    err.ratio.magnify.M;
                }
              }

            }  #  end if - both app.M and cor.M are legal

          cur.idx <- cur.idx + 1;

          }  #  end for - cur.tuple.idx
      }  #  end for - cur.triple

  if (do.A & (name.of.var.to.plot == "err.ratio.magnify.M"))
    {
    make.sure.that.func.A.returns.all.1s.for.err.B.equal.0 (results);
    }

  cat ("\n\nAt end of building full results array...\n\n");

#------------------------------------------------------------------------------

      #---------------------------------------------------
      #  Done computing the full set of individual values.
      #  Now ready to plot results.
      #---------------------------------------------------

#------------------------------------------------------------------------------

      #
  threshold.string <- "all values";
  if (only.show.above.cutoff)
    {
    threshold.string <- "only values ABOVE cutoff";
    } else
    {
    if (only.show.cutoff.and.below)
      {
      threshold.string <- "only values AT or BELOW cutoff";
      }
    }

  plot.title.start.string <- paste ("Function ", experiment.eqn.string,
                                    "  -  ", threshold.string,
                                    "\n",
                                    name.of.var.to.plot,
                                    " = ", plot.eqn.string,
                                    "\n[ A/B = ");

#------------------------------------------------------------------------------

      #----------------------------------------------------------------------
      #  Put up an empty plot to separate different runs from each other
      #  when you're paging back through them in the interactive plot window.
      #----------------------------------------------------------------------

if (RS.paper)
{
cat ("\n\nRS.paper, so NOT plotting 0.\n")
#  par (mfrow = c (1,1));
#  plot (0);

} else
{
cat ("\n\nNOT RS.paper, so plotting 0.\n")
  par (mfrow = c (1,1));
  plot (0);
}
#browser()

      #-----------------------------------------------------------------
      #  Specify how many subplots to put up in each plot frame.
      #  Sometimes you would like to show a number of them together
      #  for comparison, but generally, the 3D plots are too complicated
      #  to look at with more than one in a frame.
      #-----------------------------------------------------------------

#  par (mfrow = c (num.app.A.values, num.app.B.values));
#  par (mfrow = c (1,1));

      #---------------------------------------------------------------
      #  Most of the time, you will not want to plot every single plot
      #  since many of them are empty (i.e., all illegal values).
      #  Keep a count of the number of plots you actually make (as
      #  opposed to the number of gamma,A,B triples that you consider.
      #  If you're even plotting empty graphs, then these two counts
      #  will be the same.
      #---------------------------------------------------------------

  cur.plot.idx <- 0;

      #--------------------------------------------------------------------
      #  Here's the main loop for everything.
      #  For each gamma,B pair (which implies a gamma,A,B triple),
      #  compute the metric M with and without error at all the different
      #  error levels of A and B.
      #  Add the results to the master results table and plot a 3D graph
      #  of the distortion measure over the range of error values.
      #  Also make a 2D plot of the same thing for when B has no error.
      #  Write out the different results and plots to files along the way.
      #  (Note that all of these different actions are controlled by flags
      #   saying whether the user wants them done or not.  I've just listed
      #   all of the things that this loop Can do.)
      #--------------------------------------------------------------------

  for (cur.triple in 1:num.gamma.A.B.triples)
    {
    gamma <- gamma.A.B.triples [cur.triple, "gamma"];
    app.A <- gamma.A.B.triples [cur.triple, "app.A"];
    app.B <- gamma.A.B.triples [cur.triple, "app.B"];

    results.for.cur.gamma.B <- extract.gamma.B (results, gamma, app.B);

    if (DEBUG.PLOT)
      {
      cat ("\n----> Just before if (plot.results):");
      cat ("\n    gamma = ", gamma);
      cat ("\n    app.A = ", app.A);
      cat ("\n    app.B = ", app.B);
      cat ("\n    cur.plot.idx = ", cur.plot.idx);
      }

      num.values.to.plot <-
          length (which (!is.na (
                    results.for.cur.gamma.B [ ,name.of.var.to.plot])));

    if (DEBUG.PLOT)
      {
      cat ("\n    num.values.to.plot = ", num.values.to.plot);
      }

    if (plot.results)
      {
      if (even.plot.empty.graphs | (num.values.to.plot > 0))
        {

        plot.title <- paste (plot.title.start.string,
                             format (gamma, digits = 4),
                             ", A = ", format (app.A, digits = 4),
                             ", B = ", format (app.B, digits = 4), " ]"
                             );

        cur.plot.idx <- cur.plot.idx + 1;
        cur.plot.idx.string <- as.character (cur.plot.idx);

        if (cur.plot.idx < 10)
          {
          cur.plot.idx.string <- paste ("00", cur.plot.idx.string, sep = '');
          } else
          {
          if (cur.plot.idx < 100)
            {
            cur.plot.idx.string <- paste ("0", cur.plot.idx.string, sep = '');
            }
          }
        plotfile.name.stem <-
            paste (cur.plot.idx.string, "_", short.experiment.name,
                   "_", "g", gamma, "_B", app.B,
                   "_", name.of.var.to.plot,
                   sep = '');

        if (DEBUG.PLOT)
          {
          cat ("\n----> Just before plot 3D:");
          cat ("\n    gamma = ", gamma);
          cat ("\n    app.A = ", app.A);
          cat ("\n    app.B = ", app.B);
          cat ("\n    cur.plot.idx = ", cur.plot.idx);
          }

        plot.surface.in.3D (results.for.cur.gamma.B,
                            name.of.var.to.plot,
                            err.A.values, err.B.values,
#                            "Overest   <-    err.Res    ->   Underest",
                            "Overest   <-    err.A    ->   Underest",

#                            "Overest   <-    err.Dev    ->   Underest",
                            "Overest   <-    err.B    ->   Underest",
                            plot.title,
                            z.min, z.max,
                            plotfile.name.stem,
                            compute.max.and.min.z.values
                            );

        }  #  end if - even plot empty graphs
      }  #  end if - plot.results

    if (save.individual.gamma.B.result.tables)
      {
      file.name <- paste (short.experiment.name,
                          "_", gamma, "_", app.B,
                          "_", name.of.var.to.plot,
                          ".csv", sep = '');
      write.table (results.for.cur.gamma.B,
                   file = file.name,
                   sep = ",",
                   col.names = TRUE,
                   row.names = FALSE
                   );
      }
    }  #  end for - cur.triple

#------------------------------------------------------------------------------

      #-------------------------------------------------------------
      #  Done with all computations.
      #  Now, save the results matrix to a file.
      #
      #  To read the file back into R:
      #      results <- read.csv ("exp.A.minus.B.over.A.plus.B.csv",
      #                           header = TRUE, sep = ",");
      #-------------------------------------------------------------

  write.table (results,
               file = paste (experiment.name, ".csv", sep = ''),
               sep = ",",
               col.names = TRUE,
               row.names = FALSE
               );


  if (! plot.correlations)
    return (results);


#------------------------------------------------------------------------------

  cat ("\n\nnum.err.tuples = ", num.err.tuples, "\n\n");

  for (cur.err.tuple.idx in 1:num.err.tuples)
    {
    cur.result.indices <-
        which (
               (results [,"err.idx"] == cur.err.tuple.idx)  &
               (! is.na (results [,"app.M"]))  &
               (! is.na (results [,"cor.M"]))
               );

    if (length (cur.result.indices) > 0)
      {
      if (debug.err.tuple.plots)
        {
        cat ("\n\nCur err tuple results:\n");
        print (results [cur.result.indices,
                        cols.to.print.for.debugging.err.tuple.plots]);
        }

      gamma.red.zone.bottom <- 0.3;
      gamma.red.zone.top <- 2.0;

      gamma.red.zone.result.indices <-
        which (
               (results [,"err.idx"] == cur.err.tuple.idx)  &
               (results [,"gamma"] >= gamma.red.zone.bottom)  &
               (results [,"gamma"] <= gamma.red.zone.top)  &
               (! is.na (results [,"app.M"]))  &
               (! is.na (results [,"cor.M"]))
               );

      par (mfrow = c (1,2));
#      par (mfrow = c (1,1));
      plot (results [cur.result.indices, "cor.M"],
            results [cur.result.indices, "app.M"],
            pch=19,
            #cex=2,
            col = "green");

      abline (a = 0, b = 1, lty = 3);  #  Plot a dotted 1:1 line.

      if (length (gamma.red.zone.result.indices) > 0)
        {
        if (debug.err.tuple.plots)
          {
          cat ("\n\nRed zone results:\n");
          print (results [gamma.red.zone.result.indices,
                          cols.to.print.for.debugging.err.tuple.plots]);
          }

        points (results [gamma.red.zone.result.indices, "cor.M"],
                results [gamma.red.zone.result.indices, "app.M"],
                pch=19,
                #cex=2,
                col="red"
                );
        }

#      if (save.corr.plots)
#        {
#        plotfile.name <- paste (plotfile.name.stem,
#                                "valueCorr",
#                                "jpg", sep = ".");
#        savePlot (plotfile.name, "jpg");
#        }



      cur.M.values <- cbind (results [cur.result.indices, "app.M"],
                             results [cur.result.indices, "cor.M"]);

      colnames (cur.M.values) <- c ("app.M", "cor.M");

          #-------------------------------------------------------------
          #  Compute various correlation values for the apparent vs. the
          #  correct values.
          #-------------------------------------------------------------

      app.cor.M.correl.pearson <- NA;
      app.cor.M.correl.kendall <- NA;
      app.cor.M.correl.spearman <- NA;

          #--------------------------------------------------------
          #  The correlation functions choke when the std dev is 0,
          #  so check for that before computing the correlations.
          #--------------------------------------------------------

      if (sd (cur.M.values [,"cor.M"] != 0))
        {
        app.cor.M.correl.pearson <-
          cor (cur.M.values [,"app.M"], cur.M.values [,"cor.M"],
               method = "pearson"
               );
        app.cor.M.correl.kendall <-
          cor (cur.M.values [,"app.M"], cur.M.values [,"cor.M"],
               method = "kendall"
               );
        app.cor.M.correl.spearman <-
          cor (cur.M.values [,"app.M"], cur.M.values [,"cor.M"],
               method = "spearman"
               );
        }

          #--------------------------------------------
          #  Echo the correlation values to the screen.
          #--------------------------------------------

      cat ("\n\n----------\n\nAt err.tuple ", cur.err.tuple.idx, ":",
           "\n\n    pearson = ", app.cor.M.correl.pearson,
           "\n    kendall = ", app.cor.M.correl.kendall,
           "\n    spearman = ", app.cor.M.correl.spearman,
           sep = '');

          #----------------------------------------------------------
          #  Put a title on the plot of M values.
          #  Include the regular correlation and the rank correlation
          #  in the title.
          #----------------------------------------------------------

      title (paste ("M values for error set ", cur.err.tuple.idx,
                    "\nstdev A = ", sd.A, "    -    stdev B = ", sd.B,
                    "\nPearson corr = ",
                    round (app.cor.M.correl.pearson, 2)));

          #----------------------------------------------------------
          #  Make a scatter plot of the correct vs. apparent ranks of
          #  each of the A,B pairs.
          #----------------------------------------------------------

      app.order.M <- rank (cur.M.values [, "app.M"], ties = "first");
      cor.order.M <- rank (cur.M.values [, "cor.M"], ties = "first");

#      par (mfrow = c (1,1));
      plot (cor.order.M, app.order.M,
            pch=19,
            #cex=2,
            col="blue"
            );
      abline (a = 0, b = 1, lty = 3);  #  Plot a dotted 1:1 line.

      title (paste ("Ranks for error set ", cur.err.tuple.idx,
                    "\nstdev A = ", sd.A, "    -    stdev B = ", sd.B,
                    "\nSpearman corr = ",
                    round (app.cor.M.correl.spearman, 2)));

      if (save.corr.plots)
        {
        plotfile.name <- paste (plotfile.name.stem,
#                                "rankCorr",
                                "corr",
                                cur.tuple.idx,
                                "jpg", sep = ".");

cat ("\nAbout to save plot '", plotfile.name, "'", sep = '');

        savePlot (plotfile.name, "jpg");
        }



      }
    }

  cat ("\n\n");

#------------------------------------------------------------------------------

  return (results);
  }

#==============================================================================

