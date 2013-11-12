#==============================================================================

#                        gamma.utilities.R

###	Usage:
###        source ('gamma.utilities.R');

#  Miscellaneous support routines plus routines for some error checking
#  and diagnostics under special cases of the gamma code.

#==============================================================================

#  History:

#  BTL - 2009.08.10.
#	 - Extracted from gamma.R

#  BTL - 2013.11.12
#    - Moved from /Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/P04 a-b over a+b/R_files/gamma.utilities.v11.R
#      to /Users/Bill/D/rdv-framework/projects/aMinusBoverAplusB/gamma.utilities.R
#      to try running it under tzar and keeping the project under version control.

#==============================================================================

    #----------------------------------------------------
    #  Requires package msm to get the function rtnorm().
    #  The rtnorm() routine in msm seems to use the
    #  resampling method that keeps trying again if it
    #  draws something outside the interval.
    #  This makes my whole program choke from time to
    #  time because rtnorm is off endlessly resampling
    #  for one legal value.
    #  So, I'm ditching it and writing my own variant.
    #  I don't know if it's strictly correct, but it
    #  seems to do what I intuitively want.
    #  My routine here is called my.rtnorm().
    #  BTL - 2009.08.16.
    #----------------------------------------------------

####require (msm);

#==============================================================================

build.experiment.gamma.A.B.triples <- function (gamma.values, app.B.values)
  {
  gamma.A.B.triples <-
      matrix (CONST.uninit.value,
              nrow = length (gamma.values) * length (app.B.values),
              ncol = 3);
  colnames (gamma.A.B.triples) <- c ("gamma", "app.A", "app.B");

  cur.idx <- 1;
  for (cur.gamma in gamma.values)
    {
    for (cur.app.B in app.B.values)
      {
      cur.app.A <- cur.gamma * cur.app.B;
      gamma.A.B.triples [cur.idx, "gamma"] <- cur.gamma;
      gamma.A.B.triples [cur.idx, "app.A"] <- cur.app.A;
      gamma.A.B.triples [cur.idx, "app.B"] <- cur.app.B;

###      cat ("\n", gamma.A.B.triples [cur.idx, ]);
###      cat ("\n    cur.idx = ", cur.idx);
###      cat ("\n    cur.gamma = ", cur.gamma);
###      cat ("\n    cur.app.B = ", cur.app.B);
###      cat ("\n    cur.app.A = ", cur.app.A);

      cur.idx <- cur.idx + 1;
      }
    }

###        browser();

  gamma.B.A.sort.order <-
      order (gamma.A.B.triples [ , "gamma"],
             gamma.A.B.triples [ , "app.B"],
             gamma.A.B.triples [ , "app.A"]
             );

  return (gamma.A.B.triples [gamma.B.A.sort.order, ]);
  }

#==============================================================================

build.cor.and.err.tuples.from.given.err.sequences <-
  function (app.A, app.B,
            min.err.A, max.err.A, err.A.step.size,
            min.err.B, max.err.B, err.B.step.size)
  {
  err.A.values <- seq (min.err.A, max.err.A, err.A.step.size);
  num.err.A.values <- length (err.A.values);

  err.B.values <- seq (min.err.B, max.err.B, err.B.step.size);
  num.err.B.values <- length (err.B.values);

  num.tuples <- num.err.A.values * num.err.B.values;

  tuple.col.names <- c ("cor.A", "err.A", "cor.B", "err.B");

  cor.and.err.tuples <-
      matrix (data = NA, nrow = num.tuples, ncol = length (tuple.col.names),
              byrow = TRUE
              );

  colnames (cor.and.err.tuples) <- tuple.col.names;

  cur.tuple.idx <- 1;
  for (err.A in err.A.values)
    {
    cor.A <- app.A * (1 + err.A);

    for (err.B in err.B.values)
      {
      cor.B <- app.B * (1 + err.B);

      cor.and.err.tuples [cur.tuple.idx, "cor.A"] <- cor.A;
      cor.and.err.tuples [cur.tuple.idx, "err.A"] <- err.A;

      cor.and.err.tuples [cur.tuple.idx, "cor.B"] <- cor.B;
      cor.and.err.tuples [cur.tuple.idx, "err.B"] <- err.B;

      cur.tuple.idx <- cur.tuple.idx + 1;
      }
    }

      #----------------------
      #  Quick error check...
      #----------------------

###  ApB <- cor.A+ cor.B;
###  if ((ApB > 1) | (ApB < 0))
###    {
###    cat ("\n\nERROR in compute.A.B.err.and.cor.values(), ApB = ", ApB,
###         ".  Supposed to be in [0,1].\n\n");
###    browser();
###    }

  return (cor.and.err.tuples);
  }

#==============================================================================

compute.A.B.err.and.cor.values <- function (app.A, app.B, sd.A, sd.B)
  {
  X.is.A <- TRUE;

  app.X <- app.A;
  sd.X <- sd.A;

  app.Y <- app.B;
  sd.Y <- sd.B;

  if (runif (1) > 0.5)
    {
    X.is.A <- FALSE;

    app.X <- app.B;
    sd.X <- sd.B;

    app.Y <- app.A;
    sd.Y <- sd.A;
    }

  err.and.cor.X <-
    compute.err.and.cor.value.pair (app.X, 0, 1, sd.X);
  cor.X <- err.and.cor.X [1];

  err.and.cor.Y <-
    compute.err.and.cor.value.pair (app.Y, 0, 1 - cor.X, sd.Y);
#  cor.Y <- err.and.cor.Y [1];
##cat ("\nJust before return from compute.A.B.err.and.cor.values().\n");
##browser();
  if (X.is.A)
    {
    return (c (err.and.cor.X, err.and.cor.Y));

    } else
    {
    return (c (err.and.cor.Y, err.and.cor.X));
    }
  }

#==============================================================================

compute.err.and.cor.value.pair <-
    function (app.X, cor.X.lower.bound, cor.X.upper.bound, sd.X)
  {
  if (app.X == 0)
    {
    err.X.lower.bound <- cor.X.lower.bound;
    err.X.upper.bound <- cor.X.upper.bound;

    err.X <- my.rtnorm (0, sd.X, err.X.lower.bound, err.X.upper.bound,
                        num.x.sample.pts.in.rtnorm);

    cor.X <- err.X;
##cat ("\nIn compute.err.and.cor.value.pair with app.X = 0:",
##     "\n    err.X = ", err.X, ", cor.X = ", cor.X,
##     "\n    sd.X = ", sd.X,
##    "\n    cor.X.lower.bound = ", cor.X.lower.bound,
##     "\n    cor.X.upper.bound = ", cor.X.upper.bound
##     );

    } else
    {
    err.X.lower.bound <- (cor.X.lower.bound - app.X) / app.X;
    err.X.upper.bound <- (cor.X.upper.bound - app.X) / app.X;

    err.X <- my.rtnorm (0, sd.X, err.X.lower.bound, err.X.upper.bound,
                        num.x.sample.pts.in.rtnorm);

    cor.X <- app.X * (1 + err.X);

##cat ("\nIn compute.err.and.cor.value.pair with app.X NOT EQUAL to 0:",
##     "\n    err.X = ", err.X, ", cor.X = ", cor.X,
##     "\n    sd.X = ", sd.X,
##     "\n    cor.X.lower.bound = ", cor.X.lower.bound,
##     "\n    cor.X.upper.bound = ", cor.X.upper.bound
##     );

    }

  return (c (cor.X, err.X));
  }

#==============================================================================

init.qld.data <- function ()
  {
        #------------------------------------------------
      #  Load A and B values from Queensland data file.
      #------------------------------------------------

  qld.data <- read.csv ("qld_AB_cols.csv", header = TRUE);

      #  1997
#  app.A.values <- qld.data [,"A_res1997"];
#  app.B.values <- qld.data [,"B_dev1997"];

      #  2003
  app.A.values <- qld.data [,"A_res2003"];
  app.B.values <- qld.data [,"B_dev2003"];

      #--------------------------------------------------------------------
      #  Compute the gamma values instead of specifying them ahead of time.
      #--------------------------------------------------------------------

  gamma.values <- app.A.values / app.B.values;

      #--------------------
      #  Build the triples.
      #--------------------

  gamma.A.B.values <- cbind (gamma.values, app.A.values, app.B.values);

      #  Compute the different metrics for the A,B pairs.

#  num.gamma.A.B.values <- dim (gamma.A.B.values) [1];
  num.gamma.A.B.values <- length (gamma.values);
#browser();
  AmBoApB.values <- rep (CONST.uninit.value, num.gamma.A.B.values);
  AoB.values <- rep (CONST.uninit.value, num.gamma.A.B.values);

#  cbind (gamma.A.B.values, AmBoApB.values, AoB.values);
  gamma.A.B.values <- cbind (gamma.values, app.A.values, app.B.values,
                             AmBoApB.values, AoB.values);

  colnames (gamma.A.B.values) <- c("gamma", "app.A", "app.B",
                                   "app.AmBoApB", "app.AoB");

  for (cur.idx in 1:num.gamma.A.B.values)
    {
    cur.A <- gamma.A.B.values [cur.idx, "app.A"];
    cur.B <- gamma.A.B.values [cur.idx, "app.B"];

    cur.AmBoApB.ret.values <- func.A.minus.B.over.A.plus.B (cur.A, cur.B);
    cur.AoB.ret.values <- func.A.over.B (cur.A, cur.B);

    cat ("\ncur.idx = ", cur.idx, ", [", cur.A, ",", cur.B, "], ",
         "AmBoApB = ", cur.AmBoApB.ret.values, ", AoB = ",
         cur.AoB.ret.values);

    }  # end for - cur.idx

cat ("\n\n");

      #  Order the A,B pairs by each metric.

      #  Compute the correlation and the rank correlation of the two metrics.




browser();
  gamma.B.A.sort.order <-
      order (gamma.A.B.values [, "gamma.values"],
             gamma.A.B.values [, "app.B.values"],
             gamma.A.B.values [, "app.A.values"]
             );

  gamma.A.B.triples <- gamma.A.B.values [gamma.B.A.sort.order, ];
  colnames (gamma.A.B.triples) <- c ("gamma", "app.A", "app.B");


  }

#==============================================================================

extract.gamma.B <- function (results, gamma, B)
  {
  x <- which ((results[,"gamma"] == gamma) & (results[,"app.B"] == B));
###cat ("\nin extract...");
###browser();
  return (as.matrix (results [x, ]));
  }

#==============================================================================

test.B <- function ()
  {
  gamma.values <- c (0.001, 0.01, 0.1, 0.3, 0.5, 0.7, 0.9, 1, 1.1, 1.3, 1.5, 1.7, 2, 5, 10, 50, 100, 150, 200, 250);

  log.gamma.values <- log10 (gamma.values);

  f.of.gamma <- (gamma.values - 1) / (gamma.values + 1);

  plot (log.gamma.values, f.of.gamma);
  }

#==============================================================================

get.above.cutoff.value <- function (value, cutoff)
  {
  if (!is.na (value) & (value > cutoff))
    {
    return (value);

    } else
    {
    return (NA)
    };
  }

#==============================================================================

get.at.or.below.cutoff.value <- function (value, cutoff)
  {
  if (!is.na (value) & (value <= cutoff))
    {
    return (value);

    } else
    {
    return (NA)
    };
  }

#==============================================================================

    #----------------------------------------------------------------
    #  Utility function to see which values of A are actually visited
    #  as you walk through the gammas.
    #  Just a diagnostic routine to use when debugging, etc.
    #  Not currently called in the code.
    #----------------------------------------------------------------

plot.values.of.A.that.were.used <- function (results)
  {
      #-------------------------------------------------------
      #  Find the cases where legal values of M were possible.
      #-------------------------------------------------------

  legals <- which(results[,'both.app.M.and.cor.M.are.legal'] == TRUE)

      #----------------------------------------------
      #  Find the unique values of app.A in that set.
      #----------------------------------------------

  u <- unique (results [legals,'app.A']);

      #------------------------------------
      #  Plot the values of app.A in order.
      #------------------------------------

  plot(sort(u));
  }

#==============================================================================

    #------------------------------------------------------------------------
    #  Even though func.A runs just like all the other functions,
    #  it gives weird looking results.  All results for error ratio
    #  magnification should be 1 since it's not transforming the original
    #  values in any way.  The reason the 3D surface looks weird (i.e.,
    #  it's not perfectly flat with a uniform value of 1) is that it's
    #  plotting based on values of err.B being something other than 0.
    #  That makes the max of the err.A and err.B absolute values pick
    #  the value of err.B when it's bigger than err.A, even though err.B
    #  isn't even used.  So, the only value of err.B that should be
    #  considered is 0.  When I try to plug just 0 in as the sequence
    #  of err.B values to use, R throws weird errors that have nothing
    #  to do with anything but the fact that we're just using this one
    #  err.B value, etc.  So, I've built this little routine to let the
    #  normal code run for all values of err.B and then you use this function
    #  to ignore all results except those at err.B == 0 and make sure that
    #  those values are all 1.
    #------------------------------------------------------------------------

make.sure.that.func.A.returns.all.1s.for.err.B.equal.0 <- function (results)
  {
      #-----------------------------------------------------------------
      #  Extract just the err.B and err.ratio.magnify.M columns from the
      #  results so that it's easier to look at in printing.
      #-----------------------------------------------------------------

  k <- results[,c("err.B", "err.ratio.magnify.M")]

      #---------------------------------------------------------------------
      #  Find which rows have 0 for the error in B and don't have an NA
      #  for the magnification and don't have a value of 1.
      #---------------------------------------------------------------------
      #  Really wanted to directly ask for all the magnification values that
      #  are not 1, but have to add an epsilon on either side because the
      #  floating point arithmetic seems to have returned something that is
      #  just slightly off from 1.
      #---------------------------------------------------------------------

  mm <- which ((k[,"err.B"] == 0) & (!is.na (k[,"err.ratio.magnify.M"])) &

               ((k[,"err.ratio.magnify.M"] < 0.999) |
                (k[,"err.ratio.magnify.M"] > 1.001))
               )

  if (length (k[mm,]) > 0)
    {
    cat ("\nERROR:  Not all values for err.B == 0 are 1.  Quitting.\n\n");
    browser();
    } else
    {
    cat ("\nALL values for err.B == 0 are 1.",
         "\nEverything OK, so will continue running.\n\n");
    }
  }

#==============================================================================

build.cor.and.err.tuples.from.normal.dist.draws <-
  function (app.A, app.B, sd.A, sd.B, num.tuples)
  {
  tuple.col.names <- c ("cor.A", "err.A", "cor.B", "err.B");

  cor.and.err.tuples <-
      matrix (data = NA, nrow = num.tuples, ncol = length (tuple.col.names),
              byrow = TRUE
              );

  colnames (cor.and.err.tuples) <- tuple.col.names;

  if (debug.normal.dist)
    {
    cat ("\n\nIn build.cor.and.err.tuples.from.normal.dist.draws:",
         "\n    num.tuples = ", num.tuples,
         "\n    app.A = ", app.A, ", app.B = ", app.B,
         ", sd.A = ", sd.A, ", sd.B = ", sd.B
         );
    }

  for (cur.tuple.idx in 1:num.tuples)
    {
    if (debug.normal.dist)
      {
      cat ("\n  cur.tuple.idx = ", cur.tuple.idx);
      }

    next.tuple <- compute.A.B.err.and.cor.values (app.A, app.B, sd.A, sd.B);

    if (debug.normal.dist)
      {
      cat ("\n  next.tuple = ", next.tuple);
      }

    cor.A <- next.tuple [1];
    err.A <- next.tuple [2];
    cor.B <- next.tuple [3];
    err.B <- next.tuple [4];

    if (debug.normal.dist)
      {
      cat ("\nAt cur.tuple.idx = ", cur.tuple.idx, ":\n",
           "    cor.A = ", cor.A,
           "err.A = ", err.A, "\n",
           "    cor.B = ", cor.B,
           "err.B = ", err.B
           );
      }

    cor.and.err.tuples [cur.tuple.idx, "cor.A"] <- cor.A;
    cor.and.err.tuples [cur.tuple.idx, "err.A"] <- err.A;

    cor.and.err.tuples [cur.tuple.idx, "cor.B"] <- cor.B;
    cor.and.err.tuples [cur.tuple.idx, "err.B"] <- err.B;

    }  #  end for - cur.tuple.idx

  return (cor.and.err.tuples);
  }

#==============================================================================

my.rtnorm <- function (mean, sd, lower.bound, upper.bound, num.x.sample.pts)
  {
  x <- seq (lower.bound, upper.bound, length.out = num.x.sample.pts);
  y <- dnorm (x, mean, sd);

  x.idx <- sample (1:num.x.sample.pts, 1, prob = y);
  ret.value <- x [x.idx];

  if (debug.my.rtnorm)
    {
    plot (x,y);
#    points (ret.value, y [x.idx], pch = 19, col = 'red');
    points (ret.value, y [x.idx], pch=19, cex=2, col="green");
    }

  return (ret.value);
  }

#==============================================================================

test.my.rtnorm <- function ()
  {
  sd.X <- 0.1;
  err.X.lower.bound <- -0.4;
  err.X.upper.bound <- 0.1;

  num.x.sample.pts <- 100;

  cat ("\n\nTesting my.rtnorm():\n");
  for (kkk in 1:250)
    {
    value <- my.rtnorm (0, sd.X, err.X.lower.bound, err.X.upper.bound,
                        num.x.sample.pts);

    cat ("\nAt kkk = ", kkk, ", my.rtnorm() = ", value);
    }
  cat ("\n\n");
  }

#test.my.rtnorm ();

#==============================================================================

grid.loop.test <- function ()
  {
  min.err.A <- 0.0;
  max.err.A <- 0.2;
  err.A.step.size <- 0.1;

  min.err.B <- 0.5;
  max.err.B <- 0.65;
  err.B.step.size <- 0.05;

  err.A.set <- seq (min.err.A, max.err.A, err.A.step.size);
  err.B.set <- seq (min.err.B, max.err.B, err.B.step.size);

  app.A <- 0.2;
  app.B <- 0.6;

  cor.and.err.tuples <-
    build.cor.and.err.tuples.from.given.err.sequences (app.A, app.B,
                              min.err.A, max.err.A, err.A.step.size,
                              min.err.B, max.err.B, err.B.step.size);

  num.tuples <- dim (cor.and.err.tuples) [1];

  for (cur.tuple.idx in 1:num.tuples)
    {
    cor.A <- cor.and.err.tuples [cur.tuple.idx, "cor.A"];
    err.A <- cor.and.err.tuples [cur.tuple.idx, "err.A"];

    cor.B <- cor.and.err.tuples [cur.tuple.idx, "cor.B"];
    err.B <- cor.and.err.tuples [cur.tuple.idx, "err.B"];

###    cat ("\n[", cur.tuple.idx, ", ] = \n",
###         "    cor.A = ", cor.A,
###         "    err.A = ", err.A,
###         "    cor.B = ", cor.B,
###         "    err.B = ", err.B
###         );
    }
###  cat ("\n\n");
  }

#==============================================================================

loop.test <- function ()
  {
  app.A <- 0;
  app.B <- 0;
  sd.A <- 0.1;
  sd.B <- 1;

  cur.idx <- 0;
  while (cur.idx <= 5)
    {
    next.tuple <- get.next.normally.disturbed.A.B.tuple (cur.idx,
                                                         app.A, app.B,
                                                         sd.A, sd.B);

    cur.idx <- next.tuple [1];
    cor.A <- next.tuple [2];
    err.A <- next.tuple [3];
    cor.B <- next.tuple [4];
    err.B <- next.tuple [5];

##    cat ("\nAt cur.idx = ", cur.idx, ":\n",
##         "    cor.A = ", cor.A,
##        "err.A = ", err.A, "\n",
##         "    cor.B = ", cor.B,
##         "err.B = ", err.B
##         );
    }

  cat ("\n\n");
  }

#==============================================================================

get.next.normally.disturbed.A.B.tuple <-
    function (cur.tuple.idx, num.tuples.to.generate, app.A, app.B, sd.A, sd.B)
  {
  keep.going <- FALSE;
  if (cur.tuple.idx < num.tuples.to.generate)
    {
    next.tuple <- compute.A.B.err.and.cor.values (app.A, app.B, sd.A, sd.B);
    cat ("\nAt cur.tuple.idx = ", cur.tuple.idx, ":\n    ", next.tuple);

    cur.tuple.idx <- cur.tuple.idx + 1;
    keep.going <- TRUE;
    }

  return (c (keep.going, cur.tuple.idx, next.tuple));
  }

#==============================================================================

