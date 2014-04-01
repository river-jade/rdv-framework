#==============================================================================

#                             gamma.R

###	Usage:
###        setwd ('/Users/Bill/D/rdv-framework/projects/aMinusBoverAplusB')
###        source ('gamma.R');

#==============================================================================

#  History:

#  BTL - 2009.08.07.
#	 - Cloned from metric.v4.R - 2009.06.20 - BTL.

#  LS - 2012.07.11
#    - Created a new version for vegetation indices analysis (gamma.12.LS.R)
#    - Added flags for a new index formulation (A-B)/B called (do.A.minus.B.over.B)
#      Function was added as well in functional.forms.to.test.v12.LS.R file
#      (func.A.minus.B.over.B)
#    - Added flag to allow turning off 2D plots that came between 3D plots
#     (plot.2D.err.0.cross.sections)

#  BTL - 2013.10.16.
#	 - Starting to make changes as basis for a remote sensing paper with Lola and
#      Simon.
#    - Added RS.paper boolean variable to invoke changes made for the remote
#      sensing paper.

#  BTL - 2013.11.12
#    - Moved from /Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/P04 a-b over a+b/R_files/gamma.v13.R
#      to /Users/Bill/D/rdv-framework/projects/aMinusBoverAplusB/gamma.R
#      to try running it under tzar and keeping the project under version control.

#==============================================================================

#  Current questions/problems

#  - For some reason, when I try to do the correlations for the grid
#    experiments, most of the correlation values come out to be NA
#    even though the plots look like they should have good values.

#==============================================================================

#  Conventions:

#    - #  *****
#      Options that you will commonly need to change when doing
#      different runs are marked below with:
#                  #  *****
#      If you just search for the string of asterisks, you should
#      be able to jump to the most common things to change and
#      ignore the rest.

#    - A and B
#      Used to refer to the two variables used in the metric
#      being examined.  In the conservation context, A is the amount of
#      protected land and B is the amount of developed land.

#    - gamma
#      Stands for the ratio A/B.  Since many of the results depend on
#      this ratio rather than on the values of A and B themselves,
#      this value is used in many places.

#    - M
#      Used to refer to the metric being examined, e.g., A/B or (A-B)/(A+B).

#    - NA initializations
#      Many variables in here have one value under the grid version of
#      things and a different value under the truncated normal sampling
#      version.  In cases of things that might only get created inside
#      the scope of an if or else statement, I create it first with an
#      initial value of NA and then do the if/else.  This is just to
#      make sure that every variable has a value and it's in scope,
#      even if I screw up.  The NA will cause things to choke and let
#      me know what happened.

#    - error grid vs. sampling
#      The same overall code is used here to drive two different methods
#      of examining error in M.

#      grid
#      The grid method method is looking at the general question of how
#      the error in M behaves as a function of error in A and B.
#      It builds a sequence of gamma,B pairs and a sequence of error levels
#      for both A and B.  The choice of levels for each of these variables
#      is meant to reflect a large possible range of values rather than
#      values found in any specific application.  The intent is to look
#      at distortion of M values for individual A,B,gamma points rather
#      than how those distortions interact with each other in a decision
#      process such as ranking.

#      sampling
#      The sampling method is intended for use with the queensland data.
#      The idea here is that you're given a set of real A,B,gamma values
#      and you want to add random amounts of error to each one, compute
#      the M values, and then see how the resulting error in M values
#      changes your ranking of the points (compared to how you would rank
#      them if there was no error in any of the values).

#      I've used the same code here to do both of these approaches because
#      they need a lot of the same things like the computation of M, etc.
#      It's a bit of a pain sometimes though when there are things that
#      one needs but the other doesn't and lots of if/else statements
#      are spawned as a result.  This really needs to be rewritten in an
#      object-oriented form to solve this problem if we go on with this...

#==============================================================================

    #---------------------------------------------------------------
    #  Clear any old values of variables from R's memory so that you
    #  don't get inexplicable effects through the accidental use of
    #  old values of variables from previous runs.
    #---------------------------------------------------------------

rm (list = ls (all = TRUE));

#==============================================================================

    #----------------------------------------------------------------------
    #  Debugging control flags.
    #  These are generally left as FALSE unless something is going wrong
    #  and you want to turn something on to activate some write statements
    #  to see what's happening.
    #  You can completely ignore this section and everything will run fine.
    #----------------------------------------------------------------------

DEBUG <- FALSE;
DEBUG.PLOT <- FALSE;
debug.normal.dist <- FALSE;
debug.my.rtnorm <- FALSE;
debug.err.tuple.plots <- FALSE;

#==============================================================================

    #-------------
    #  Constants
    #-------------

CONST.illegal.number <- NA;
CONST.uninit.value <- NA;

    #----------------------------------------
    #  Constant value used only in debugging.
    #----------------------------------------

cols.to.print.for.debugging.err.tuple.plots <-
    c ("gamma","app.A","app.B","err.idx","app.M","cor.M");

#==============================================================================

    #-------------------------------------------------------------------
    #  Set up the seed so that random number sequences are reproducable.
    #  Doesn't matter what number you choose for the initial seed.
    #  You just have to choose something and then call set.seed with it.
    #-------------------------------------------------------------------

initial.random.seed <- 5;
set.seed (initial.random.seed);

#==============================================================================

    #-----------------------------------------------------------------
    #  Source code files containing functions that need to be included
    #  before the main code can run.
    #-----------------------------------------------------------------

RS.paper = TRUE
if (RS.paper)
{
## required packages (plot, melt data frame, and rolling function)
library(ggplot2)
library(reshape)
library(zoo)
}


        #-----------------------------------------------------------------
        #  At one time, I was trying out a just-in-time compiler for R
        #  (called Ra) because things were really slow.
        #  It didn't help that much so I have removed it.
        #  Doesn't matter too much anyway, since I've changed other things
        #  that have speeded it all up now.
        #  I'm leaving a reference to the library in here just to remember
        #  that it exists if speed becomes an issue later.
        #-----------------------------------------------------------------

#library (jit);

        #------------------------------------------------------------
        #  Also want to remember that I wrote some code that computed
        #  how much time was left to run at each point in a loop.
        #  This was when things were taking hours to run and now this
        #  isn't necessary, but I want to remember where the code is
        #  if things change later.
        #------------------------------------------------------------

#source ('estimate.time.remaining.R');

        #---------------------------------------------------------------
        #  These are the real thing.  They're the definitions of all the
        #  functions used in the code.
        #---------------------------------------------------------------

source ('functional.forms.to.test.R');
source ('plotting.functions.R');
source ('gamma.utilities.R');
source ('compute.values.R');

#==============================================================================

                #-------------------------------------------
                #  User options to control particular runs
                #-------------------------------------------

    #----------------------------------------------------------------------
    #  When running this program, you can either load the queensland
    #  data used in the Science paper or you can let the program generate
    #  a sequence of gamma,A,B pairs itself.  The latter is useful for
    #  exploring the range of possible behaviors of the M functions.
    #  The queensland data lets you know exactly which ranges of A,B pairs
    #  occur in one real situation.  It has two sets of values, one for
    #  1997 and one for 2003.
    #  You can set one or the other of the corresponding flags to TRUE here
    #  but not both.  However, you Can set both to FALSE.  Do that if you
    #  want the program to generate its own gamma,A,B values.
    #----------------------------------------------------------------------

load.1997.queensland.data.from.file <- FALSE;    #  *****
load.2003.queensland.data.from.file <- FALSE;    #  *****

load.queensland.data.from.file <-
  (load.1997.queensland.data.from.file | load.2003.queensland.data.from.file);

if (load.1997.queensland.data.from.file & load.2003.queensland.data.from.file)
  {
  cat ("\n\nERROR: can't read both queensland data files at same time.\n\n");
  browser();
  }

    #--------------------------------------------------------------------
    #  Flag whether you want results for each gamma,A,B combination to
    #  be written out to separate files.  This is useful if you want to
    #  be able to load each data for one plot at a time without having to
    #  extract them from the master results file.  That file is always
    #  written out but contains every single result in one giant table.
    #  The main use for turning this flag on is to allow you to read
    #  the grid of values into Matlab and make a 3D plot that you can
    #  rotate in the viewer there.  If you're not going to do that,
    #  then you will generally want this flag to be FALSE so that you
    #  don't have a million little files lying around.
    #--------------------------------------------------------------------

save.individual.gamma.B.result.tables <- FALSE;

    #--------------------------------------------------------------
    #  If you want to see the 3D plots of the error grid applied to
    #  the different M values, then set this to TRUE.
    #  If you're sampling errors instead (e.g., with the queensland
    #  data), then this will automatically be turned off since the
    #  plotting code can't handle that yet.  See below.
    #--------------------------------------------------------------

plot.results <- TRUE;

    #---------------------------------------------------------------------
    #  Various other plots and file saves can be turned on or off as well.
    #  None of these matter if plot.results is turned off.
    #
    # LS (2012.07.11) added a flag that allows turning off the representation of
    # 2D plots in between 3D plots
    #---------------------------------------------------------------------

plot.multi.pane.3D <- FALSE;
plot.2D.err.0.cross.sections <- FALSE;

save.3D.plots <- FALSE;
save.2D.plots <- FALSE;

plot.correlations <- FALSE;
save.corr.plots <- FALSE;

    #---------------------------------------------------------------------
    #  Flag whether you're going to sample error values for A and B from a
    #  truncated normal distribution.  The default is to use a regular
    #  grid of error levels instead, but setting this flag to TRUE will
    #  override that.
    #  The grid is intended mostly to be used for generalization testing
    #  across a wide range of gamma,A,B values.  The sampling method is
    #  more intended for use with the queensland data and  exploring
    #  having different error levels for every point in the list of A,B
    #  pairs.  This allows us to look at interactions among all the
    #  different amounts of error when sorting a list of metric values.
    #---------------------------------------------------------------------

build.err.tuples.from.normal.distributions <- FALSE;    #  *****
#if (load.queensland.data.from.file)
#  {
#  build.err.tuples.from.normal.distributions <- TRUE;
#  }

    #---------------------------------------------------------------------
    #  If you're going to draw errors from a truncated normal distribution
    #  instead of just having a grid of error levels, then you need to
    #  specify the standard deviations of the A and B errors as well as
    #  the number of replicates to draw at each err.A and err.B level.
    #  The number of replicates is referred to here as num.err.tuples.
    #
    #  Note that plot.results is automatically turned off here if you
    #  do draw error values.  That's because at the moment, the 3D
    #  plotting code in here doesn't know how to handle anything other
    #  than a grid of values.  I think that Can be fixed, but I haven't
    #  messed with that yet.  Not sure whether it's even useful...
    #---------------------------------------------------------------------

        #-------------------------------------------------------
        #  Initialize the error sampling controls to do nothing.
        #  Reset them below if sampling is going to be used.
        #-------------------------------------------------------

sd.A <- NA;  #  Standard deviation of variable A.
sd.B <- NA;  #  Same for B.
num.err.tuples <- NA;    #  Number of times to draw new error value for
                         #  each gamma,A,B point, i.e., number of replicates

if (build.err.tuples.from.normal.distributions)
  {
  plot.results <- FALSE;  #  NOTE:  Don't change this.
                          #  Plotting code currently can only handle grid.

      #--------------------------------------------------------------------
      #  If you're sampling error values, you will want to pay attention to
      #  these three options as they are the main controls for that.
      #--------------------------------------------------------------------

  num.err.tuples <- 20;     #  *****
  sd.A <- 1;              #  *****
  sd.B <- 1;              #  *****
  }

    #--------------------------------------------------------
    #  Choose which metric to test.
    #  You can choose more than one to run at a time, but
    #  it can get to be a lot of output to look at if you do.
    #  I usually just choose one to turn on at a time.
    #
    # LS (2012.07.11) added do.A.minus.B.over.B to the list of
    # formulations
    #--------------------------------------------------------

do.A.minus.B.over.A.plus.B <- FALSE  ##TRUE;    #  *****
do.A.over.A.plus.B <- FALSE;           #  *****
do.A.over.B <- FALSE  ##TRUE;                  #  *****
do.A.minus.B <- TRUE  ##FALSE;                 #  *****
do.A.minus.B.over.B <- FALSE  ##TRUE;           #  *****
do.A <- FALSE;                         #  *****

    #---------------------------------------------------------
    #  Choose 1 and only 1 of the statistics of the metrics to
    #  plot for a given run.
    #---------------------------------------------------------

#name.of.var.to.plot <- "raw.err.M";             #  *****
###name.of.var.to.plot <- "rel.err.M";             #  *****
name.of.var.to.plot <- "err.ratio.magnify.M";    #  *****
#name.of.var.to.plot <- "err.diff.magnify.M";    #  *****

    #---------------------------------------------------------------
    #  Sometimes you want to use just a simple sequence of B values,
    #  but other times, you want them to span a much wider range.
    #  In that case, you want to have the sequence be in terms of
    #  powers rather than in terms of the raw values.
    #  For example, instead of [0, 0.1, 0.2, ...] you might want
    #  [10^-2, 10^-1, ...].  Setting this flag to TRUE will do that.
    #
    #  This value is ignored if you're sampling errors instead of
    #  using the grid.  Usually, you won't need to change it even
    #  if you are using the grid option.
    #---------------------------------------------------------------

if (RS.paper)
    {
    use.powers.for.range.of.B <- FALSE;
   ### plot (0)   #  temporary hack to try to get plots to pair correctly - 2013 11 06
    } else
    {
    use.powers.for.range.of.B <- TRUE;
    }

    #----------------------------------------------------------
    #  If you're imitating the queensland data from the science
    #  paper, flag that here you want to choose points in an
    #  irregular way since that data spans a much larger
    #  range of gammas with a specific focus in certain areas
    #  rather than an even spread throughout.
    #
    #  NOTE: The variable for imitating queensland data is
    #        probably not useful anymore since we are actually
    #        reading in the queensland data now.  However,
    #        it's referenced in a lot of places (especially
    #        for setting plot axis bounds) and it will take
    #        too much time for me to go through and carefully
    #        pull it out right now.  Maybe later...  Doesn't
    #        really hurt anything at the moment.
    #----------------------------------------------------------

use.large.range.of.gamma.values <- TRUE;
imitate.queensland.A.B.values <- FALSE;
#imitate.queensland.A.B.values <- use.large.range.of.gamma.values;

#==============================================================================

    #  From here on, there are lots of variables that need to be set
    #  but you will hardly ever want to change them once the code
    #  is working right.  Most options that you will want to change
    #  frequently to control runs will have been set before this
    #  point.

#==============================================================================

    #-------------------------------------------------------------------
    #  Turn this on only when you want to compute what the values of the
    #  z axis bounds should be.  Normally, you will know what you want
    #  to set them at so that things are standardized and you will set
    #  this to be FALSE.
    #  When you're first experimenting with plotting a different metric,
    #  you may not know what the bounds of its range are and this will
    #  help you find them.  Then you can set the z.min and z.max values
    #  to be fixed there in other runs.
    #  You want them to be fixed if you're doing lots of runs where
    #  you want to have all of the plots have identical scales to make
    #  them easier to compare in a sequence.
    #-------------------------------------------------------------------

compute.max.and.min.z.values <- FALSE;

    #--------------------------------------------------------------
    #  Choose which variable to compute the relative error against,
    #  app.M or cor.M.
    #  In the rdv framework, everything used cor as the base, but
    #  here, we are generally more interested in app as the base.
    #--------------------------------------------------------------

use.app.M.as.rel.err.base <- TRUE;

    #-------------------------------------------------------------
    #  My version of rtnorm beaks up the truncation interval into
    #  a certain number of sample points and then draws from among
    #  those locations.  The number of divisions to use is given
    #  by num.x.sample.pts.in.rtnorm.
    #-------------------------------------------------------------

num.x.sample.pts.in.rtnorm <- 100;

    #-----------------------------------------------------------------
    #  Generally don't want to draw plots for cases where all measures
    #  had values that were out of bounds.
    #-----------------------------------------------------------------

even.plot.empty.graphs <- FALSE;

    #------------------------------------------------------------
    #  Need to specify defaults for 3D plot axis bounds and for
    #  the string describing the equation for M that will be used
    #  in the plot title.
    #------------------------------------------------------------

default.z.min <- -20;
z.min <- default.z.min;

default.z.max <- 20;
z.max <- default.z.max;

plot.eqn.string <- "plot.eqn.string was not initialized";

    #--------------------------------------------------------------------
    #  I haven't figured out how to show a plane through the middle of
    #  a 3D plot, so here are some "cutoff" options to allow you to only
    #  show values above (or below) where you would want to draw a plane.
    #  This is useful for seeing where the magnification ratio is > 1
    #  or the difference is < 0, etc.
    #--------------------------------------------------------------------

only.show.above.cutoff <- FALSE;
only.show.cutoff.and.below <- FALSE;
if (only.show.above.cutoff & only.show.cutoff.and.below)
  {
  cat ("\n\nERROR: ",
       "Can't have both show above and show below TRUE at same time.\n\n");
  browser();
  }

    #  In extreme error magnifications, the 3d plotting is giving a warning
    #  that "surface extends beyond the box" and this messes up the plot
    #  display sequence in markdown, so I'm going to allow silencing of
    #  warnings for the moment.
    #  BTL - 2013 11 06.

silenceWarnings = FALSE
if (RS.paper)
    silenceWarnings = TRUE
if (silenceWarnings)
    options(warn = -1)

    #----------------------------------------------------------------
    #  Initialize the value that indicates the level to draw a cutoff
    #  plane in the plots.  In some cases this means the point where
    #  there is no error in others, it means the point where there is
    #  magnification of error.  The correct value is set below based
    #  on which variable you are plotting.
    #----------------------------------------------------------------

raw.err.display.plane.cutoff <- 0;
rel.err.display.plane.cutoff <- 0;
err.diff.magnify.display.plane.cutoff <- 0;
err.ratio.magnify.display.plane.cutoff <- 1;

#------------------------------------------------------------------------------

    #-------------------------------------------------------------
    #  Set up the plot controls for each of the variables that are
    #  possible to plot.
    #-------------------------------------------------------------

#------------------------------------------------------------------------------

if (name.of.var.to.plot == "raw.err.M")
  {
  plot.eqn.string <- "app.M - cor.M";
  display.plane.cutoff <- raw.err.display.plane.cutoff;

  if (use.app.M.as.rel.err.base)
    {
    plot.eqn.string <- "cor.M - app.M";
    }
  z.min <- -2;
  z.max <- 2;
  if (imitate.queensland.A.B.values)
    {
    z.min <- -2;
    z.max <- 2;
    }
  }

    #----------

if (name.of.var.to.plot == "rel.err.M")
  {
  plot.eqn.string <- "raw.err.M / cor.M";
  display.plane.cutoff <- rel.err.display.plane.cutoff;

  if (use.app.M.as.rel.err.base)
    {
    plot.eqn.string <- "raw.err.M / app.M";
    }
  z.min <- -20.0;
  z.max <- 20.0;
  if (imitate.queensland.A.B.values)
    {
    z.min <- -4;
    z.max <- 4;
    }
  }

    #----------

if (name.of.var.to.plot == "err.ratio.magnify.M")
  {
  plot.eqn.string <- "|rel.err.M| / max(|err.A|,|err.B|)";
  display.plane.cutoff <- err.ratio.magnify.display.plane.cutoff;

  z.min <- 0;
  z.max <- 20;
  if (imitate.queensland.A.B.values)
    {
    z.min - 0;
    z.max <- 5;
    }
  }

    #----------

if (name.of.var.to.plot == "err.diff.magnify.M")
  {
  plot.eqn.string <- "|rel.err.M| - max(|err.A|,|err.B|)";
  display.plane.cutoff <- err.diff.magnify.display.plane.cutoff;

  z.min <- -1;
  z.max <- 20;
  if (imitate.queensland.A.B.values)
    {
    z.min <- -1;
    z.max <- 3;
    }
  }

#==============================================================================

gamma.A.B.triples <- NA;
gamma.values <- NA;
app.A.values <- NA;
app.B.values <- NA;

if (load.queensland.data.from.file)
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

  gamma.B.A.sort.order <-
      order (gamma.A.B.values [, "gamma.values"],
             gamma.A.B.values [, "app.B.values"],
             gamma.A.B.values [, "app.A.values"]
             );

  gamma.A.B.triples <- gamma.A.B.values [gamma.B.A.sort.order, ];
  colnames (gamma.A.B.triples) <- c ("gamma", "app.A", "app.B");

  } else

  #------------------------------------------------------------------------
  #------------------------------------------------------------------------

  {
      #---------------------------------------------------------
      #  Not loading Queensland data.
      #
      #  Instead, specifying a list of gamma values and B values
      #  and A will be derived from gamma and B.
      #
      #  Then, creating a grid of errors over A and B.
      #---------------------------------------------------------

  #-----------------------------------------

      #-------------------
      #  Set gamma values.
      #-------------------

  if (use.large.range.of.gamma.values)
    {
        #---------------------------------------------------------------
        #  Want a large range of gamma values to get at any effects
        #  that might be different for A,B pairs that are tiny enough
        #  to allow much larger gammas than bigger A values would allow.
        #---------------------------------------------------------------

    gamma.values <- c (0.001, 0.01, 0.1, 0.3, 0.5, 0.7, 0.9,
                       1, 1.1, 1.3, 1.5, 1.7, 2, 5,
                       10, 50, 100, 150, 200, 250);
    } else
    {
        #---------------------------------------------------------
        #  Not using the large range of gamma values.
        #  Want a simple sequence instead.
        #---------------------------------------------------------

    gamma.step.size <- 0.1;
    min.gamma <- 0.0;
    max.gamma <- 2.0;

    gamma.values <- seq (min.gamma, max.gamma, gamma.step.size);

    }  #  end else - not using large range of gamma values

  #-----------------------------------------

      #------------------------
      #  Set apparent B values.
      #------------------------

  if (use.powers.for.range.of.B)
    {
    powers <- c (-4, -3, -2, -1, -0.5, -0.25, -0.02);
#    powers <- c (-0.25, -0.02);
    app.B.values <- 10 ^ powers;

    } else
    {
        #--------------------------------------
        #  Don't use powers of 10 for B values.
        #  Use a simple sequence.
        #--------------------------------------

    if (RS.paper)
        {
        B.step.size <- 0.05;
        min.B <- 0.0;
        max.B <- 0.4;

        } else
        {
        B.step.size <- 0.1;
        min.B <- 0.0;
        max.B <- 1.0;
        }

    if (imitate.queensland.A.B.values)
      {
      B.step.size <- 0.0005;
      max.B <- 0.001;
      }

    app.B.values <- seq (min.B, max.B, B.step.size);

    }  #  end else - not using powers for range of B

  #-----------------------------------------

  gamma.A.B.triples <- build.experiment.gamma.A.B.triples (gamma.values,
                                                           app.B.values);

  }  #  end else - not loading queensland data

num.app.A.values <- length (app.A.values);
num.app.B.values <- length (app.B.values);
num.gamma.values <- length (gamma.values);
num.gamma.A.B.triples <- dim (gamma.A.B.triples) [1];

#-----------------------------------------------------------------------------

    #-----------------------------------------------------------------
    #  Initialize variables related to err.A and err.B to dummy value.
    #  Need to do this so that all of these variables are in scope
    #  everywhere and have values that will flag an error if there
    #  is some accidental usage of them later in the code when using
    #  the option to draw errors from a normal distribution instead of
    #  the simple grid method built below.
    #-----------------------------------------------------------------

err.AB.bound <- NA;
err.A.step.size <- NA;
min.err.A <- NA;
max.err.A <- NA;
err.A.values <- NA;
num.err.A.values <- NA;
idx.where.err.A.is.0 <- NA;

err.B.step.size <- NA;
min.err.B <- NA;
max.err.B <- NA;
err.B.values <- NA;
num.err.B.values <- NA;
idx.where.err.B.is.0 <- NA;

if (! build.err.tuples.from.normal.distributions)
  {
      #--------------------------------------------------------------
      #  Build error values from a grid rather than drawing them from
      #  a normal distribution.
      #--------------------------------------------------------------

      #-------------------------
      #  Set error values for A.
      #-------------------------

#  err.AB.bound <- 1.0;
  err.AB.bound <- 0.1;

#  err.A.step.size <- 0.1;
  err.A.step.size <- 0.01;
  min.err.A <- - err.AB.bound;
  max.err.A <- err.AB.bound;

  err.A.values <- seq (min.err.A, max.err.A, err.A.step.size);
  num.err.A.values <- length (err.A.values);

      #-------------------------------------------------------------------
      #  Need to flag the index where err.A is 0 so that we can make
      #  separate plots related to the case where there is error in B but
      #  not in A.
      #-------------------------------------------------------------------

  idx.where.err.A.is.0 <- which (err.A.values == 0);
  cat ("\n\nindex where err.A = 0 is ", idx.where.err.A.is.0, "\n\n");

      #-------------------------
      #  Set error values for B.
      #-------------------------

#  err.B.step.size <- 0.1;
  err.B.step.size <- 0.01;
  min.err.B <- - err.AB.bound;
  max.err.B <- err.AB.bound;

  err.B.values <- seq (min.err.B, max.err.B, err.B.step.size);
  num.err.B.values <- length (err.B.values);

      #-------------------------------------------------------------------
      #  Need to flag the index where err.B is 0 so that we can make
      #  separate plots related to the case where there is error in A but
      #  not in B.
      #-------------------------------------------------------------------

  idx.where.err.B.is.0 <- which (err.B.values == 0);
  cat ("\n\nindex where err.B = 0 is ", idx.where.err.B.is.0, "\n\n");

      #-----------------------------------------------------------------
      #  The total number of results computed depends partly on how many
      #  A,B error pairs there are for each A,B.  Remember that value.
      #-----------------------------------------------------------------

  num.err.tuples <- num.err.A.values * num.err.B.values;

  }  #  end if - not drawing error values from normal distribution

#-----------------------------------------------------------------------------

      #---------------------------------------------------------------
      #  Each combination of the four variables will have a number of
      #  things computed for it.  Each of these computations will have
      #  a corresponding column for it in the results table.
      #  Name those columns here.
      #---------------------------------------------------------------

result.col.names <- c(
                      "gamma",
                      "app.A",
                      "app.B",
                      "cor.A",
                      "cor.B",
                      "err.A",
                      "err.B",
                      "err.idx",

                      "app.M",
                      "cor.M",
                      "raw.err.M",
                      "rel.err.M",
                      "err.diff.magnify.M",
                      "err.ratio.magnify.M",

                      "both.app.M.and.cor.M.are.legal",
                      "app.M.is.legal",
                      "app.M.is.legal.pos",
                      "app.M.is.legal.neg",
                      "cor.M.is.legal",
                      "cor.M.is.legal.pos",
                      "cor.M.is.legal.neg"
                      );

    #---------------------------------------------------------------------
    #  Now we have all the information we need to determine the dimensions
    #  of the results table that we're going to build later.
    #---------------------------------------------------------------------

num.result.cols <- length (result.col.names);
num.result.rows <- num.gamma.A.B.triples * num.err.tuples;

    #-------------------------------------------------------------------
    #  Initialize the results variable so that it will still be in scope
    #  after the if statements below are finished.
    #  This just makes it available for queries after the run is done
    #  inside R.
    #-------------------------------------------------------------------

results <- NA;

#==============================================================================

    #-----------------------------------------------------------------
    #  Finally ready to compute the values for the chosen function(s).
    #-----------------------------------------------------------------

if (do.A.over.B)
  {
  cat ("\n\nComputing func.A.over.B.results:\n");
  func.A.results <- compute.values ("exp.A.over.B",
                                    "AoB",
                                    "A/B",
                                    func.A.over.B);

  }

if (do.A.minus.B.over.A.plus.B)
  {
  cat ("\n\n================================================================");
  cat ("\n\nComputing func.A.minus.B.over.A.plus.B.results:\n");
  results <-
    compute.values ("exp.A.minus.B.over.A.plus.B",
                    "AmBoApB",
                    "(A-B)/(A+B)",
                    func.A.minus.B.over.A.plus.B);

  cat ("\n\n****************************************************");
  cat ("\n*****  All done with A.minus.B.over.A.plus.B.  *****");
  cat ("\n****************************************************\n\n");

  }

if (do.A.over.A.plus.B)
  {
  cat ("\n\nComputing func.A.over.A.plus.B.results:\n");
  results <-
      compute.values ("exp.A.over.A.plus.B",
                      "AoApB",
                      "A/(A+B)",
                      func.A.over.A.plus.B);

  cat ("\n\n****************************************************");
  cat ("\n*****  All done with A.over.A.plus.B.  *****");
  cat ("\n****************************************************\n\n");

  }

if (do.A.minus.B)
  {
  cat ("\n\nComputing func.A.minus.B.results:\n");
  func.A.minus.B.results <- compute.values ("exp.A.minus.B",
                                            "AmB",
                                            "A-B",
                                            func.A.minus.B);

  }

if (do.A)
  {
  cat ("\n\nComputing func.A.results:\n");
  func.A.results <- compute.values ("exp.A",
                                    "A",
                                    "A",
                                    func.A);
  }

if (do.A.minus.B.over.B)
{
  cat ("\n\nComputing func.A.minus.B.over.B.results:\n");
  func.A.results <- compute.values ("exp.A.minus.B.over.B",
                                    "AmBoB",
                                    "(A-B)/B",
                                    func.A.minus.B.over.B);
}


#==============================================================================

