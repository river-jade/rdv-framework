#==============================================================================

                                #  boneyard.R

#  Random leftover code that I don't want to throw away but am not currently
#  using.

#==============================================================================

#  History:

#    BTL - 2013.11.12
#    Moved from /Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/P04 a-b over a+b/R_files/boneyard.R
#    to /Users/Bill/D/rdv-framework/projects/aMinusBoverAplusB/boneyard.R
#    to try running it under tzar and keeping the project under version control.

#==============================================================================

get.next.grid.disturbed.A.B.tuple <-
    function (cur.tuple.idx, num.tuples.to.generate, app.A, app.B)
  {
  keep.going <- FALSE;
  if (cur.tuple.idx < num.tuples.to.generate)
    {
    cur.err.A.idx <- grid.disturbed.tuple.state [2];
    cur.err.B.idx <- grid.disturbed.tuple.state [3];

    cur.err.B.idx <- cur.err.B.idx + 1;
    if (cur.err.B.idx > length (err.B.set))
      {
      cur.err.B.idx <- 1;
      cur.err.A.idx <- cur.err.A.idx + 1;
      }

    err.A <- err.A.set [cur.err.A.idx];
    cor.A <- app.A * (1 + err.A);

    err.B <- err.B.set [cur.err.B.idx];
    cor.B <- app.B * (1 + err.B);

    cat ("\nAt cur.tuple.idx = ", cur.tuple.idx, ":\n",
         "    cor.A = ", cor.A,
         ", err.A = ", err.A, "\n",
         "    cor.B = ", cor.B,
         ", err.B = ", err.B);

    cur.tuple.idx <- grid.disturbed.tuple.state [1];
    cur.tuple.idx <- cur.tuple.idx + 1;

    keep.going <- TRUE;
    }

  return (c (keep.going, cur.tuple.idx, cor.A, err.A, cor.B, err.B));
  }

#==============================================================================

junk <- function ()
  {
###cat ("\n  -----  at top of for (err.A = ", err.A);
###cat ("\n      -----  at top of for (err.B = ", err.B);

  grid.disturbed.tuple.state <- c (1, 1, 1, err.A.set, err.B.set);

  while (keep.going)
    {
#    grid.generator.state <-
#      get.next.grid.disturbed.A.B.tuple (cur.tuple.idx,
#                                         num.tuples.to.generate,
#                                         app.A, app.B,
#                                         grid.disturbed.tuple.state);

    keep.going <- grid.generator.state [1];
    cur.err.A.idx <- grid.disturbed.tuple.state [2];
    cur.err.B.idx <- grid.disturbed.tuple.state [3];

#    grid.disturbed.tuple.state [???
    }
  }

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

  num.tuples.to.generate <- length (err.A.set) * length (err.B.set);
  cur.tuple.idx <- 1;
  app.A <- 0.2;
  app.B <- 0.6;
  keep.going <- TRUE;

  grid.disturbed.tuple.state <- c (1, 1, 1, err.A.set, err.B.set);

  while (keep.going)
    {
    grid.generator.state <-
      get.next.grid.disturbed.A.B.tuple (cur.tuple.idx,
                                         num.tuples.to.generate,
                                         app.A, app.B,
                                         grid.disturbed.tuple.state);

    keep.going <- grid.generator.state [1];
    cur.err.A.idx <- grid.disturbed.tuple.state [2];
    cur.err.B.idx <- grid.disturbed.tuple.state [3];

#    grid.disturbed.tuple.state [???
    }

  }

#==============================================================================

