#==============================================================================

#                     functional.forms.to.test.R

###	Usage:
###        source ('functional.forms.to.test.R');

#  This file contains the different functional forms that are to be tested
#  for how they behave under uncertainty.

#==============================================================================

#  History:

#  BTL - 2009.08.05
#	 - Extracted from metrics.R

#  LS - 2012.07.11
#    - Added a function for a new index formulation (A-B)/B called (func.A.minus.B.over.B)

#  BTL - 2013.11.12
#    - Moved from /Users/Bill/D/Projects_RMIT/AAA_PapersInProgress/P04 a-b over a+b/R_files/functional.forms.to.test.v12.LS.R
#      to /Users/Bill/D/rdv-framework/projects/aMinusBoverAplusB/functional.forms.to.test.R
#      to try running it under tzar and keeping the project under version control.

#==============================================================================

init.ret.values <- function ()
  {
      #----------------------------------------------------------------
      #  The functions to be tested all return 4 values:
      #  the function value and 3 flags indicating whether the inputs
      #  and function value are legal.
      #
      #  Initialize the function value to NA and the flags to all say
      #  that everything is legal.
      #----------------------------------------------------------------

  return (list (is.legal.pos = TRUE,
                is.legal.neg = TRUE,
                is.legal = TRUE,
                M = NA
                )
          );
  }

#==============================================================================

func.A <- function (A, B)
  {
  ret.values <- init.ret.values ();

      #--------------------------------------------
      #  Make sure that A is in the interval [0,1].
      #--------------------------------------------

  if (A > 1)
    {
    ret.values$is.legal.pos <- FALSE;
    ret.values$is.legal <- FALSE;
    }

  if (A < 0)
    {
    ret.values$is.legal.neg <- FALSE;
    ret.values$is.legal <- FALSE;
    }

      #----------------------------------------------
      #  All ok, so compute function value to return.
      #----------------------------------------------

  if (ret.values$is.legal)
      ret.values$M <- A;

  return (ret.values)
  }

#==============================================================================

func.A.over.B <- function (A, B)
  {
  ret.values <- init.ret.values ();

      #----------------------------------------------------------------
      #  Make sure that A and B are in the interval [0,1] and
      #  that you can't divide by 0.
      #----------------------------------------------------------------

  if ((A > 1) | (B > 1))
    {
    ret.values$is.legal.pos <- FALSE;
    ret.values$is.legal <- FALSE;
    }

  if ((A < 0) | (B <= 0))
    {
    ret.values$is.legal.neg <- FALSE;
    ret.values$is.legal <- FALSE;
    }

      #----------------------------------------------
      #  All ok, so compute function value to return.
      #----------------------------------------------

  if (ret.values$is.legal)
      ret.values$M <- A / B;

  return (ret.values)
  }

#==============================================================================

func.A.over.A.plus.B <- function (A, B)
  {
  ret.values <- init.ret.values ();

      #----------------------------------------------------------------
      #  Make sure that A, B, and A+B are all in the interval [0,1] and
      #  that you can't divide by 0.
      #----------------------------------------------------------------

  if ((A > 1) | (B > 1) | ((A + B) > 1))
    {
    ret.values$is.legal.pos <- FALSE;
    ret.values$is.legal <- FALSE;
    }

  if ((A < 0) | (B < 0) | ((A + B) <= 0))
    {
    ret.values$is.legal.neg <- FALSE;
    ret.values$is.legal <- FALSE;
    }

      #----------------------------------------------
      #  All ok, so compute function value to return.
      #----------------------------------------------

  if (ret.values$is.legal)
      ret.values$M <- A / (A + B);

  return (ret.values)
  }

#==============================================================================

func.A.plus.B <- function (A, B)
  {
  ret.values <- init.ret.values ();

  M <- A + B;

      #-------------------------------------------------------------
      #  Make sure that A, B, and A+B are all in the interval [0,1].
      #-------------------------------------------------------------

  if ((A > 1) | (B > 1) | (M > 1))
    {
    ret.values$is.legal.pos <- FALSE;
    ret.values$is.legal <- FALSE;
    }

  if ((A < 0) | (B < 0) | (M <= 0))
    {
    ret.values$is.legal.neg <- FALSE;
    ret.values$is.legal <- FALSE;
    }

      #----------------------------------------------
      #  All ok, so compute function value to return.
      #----------------------------------------------

  if (ret.values$is.legal)  ret.values$M <- M;

  return (ret.values)
  }

#==============================================================================

func.A.minus.B <- function (A, B)
  {
  ret.values <- init.ret.values ();

  M <- A - B;

      #-------------------------------------------------------------
      #  Make sure that A, B, and A-B are all in the interval [0,1].
      #-------------------------------------------------------------

  if ((A > 1) | (B > 1) | (M > 1))
    {
    ret.values$is.legal.pos <- FALSE;
    ret.values$is.legal <- FALSE;
    }

  if ((A < 0) | (B < 0) | ((M <= 0)))
    {
    ret.values$is.legal.neg <- FALSE;
    ret.values$is.legal <- FALSE;
    }

      #----------------------------------------------
      #  All ok, so compute function value to return.
      #----------------------------------------------

  if (ret.values$is.legal)  ret.values$M <- M;

  return (ret.values)
  }

#==============================================================================

func.A.minus.B.over.A.plus.B <- function (A, B)
  {
  ret.values <- init.ret.values ();

      #----------------------------------------------------------------
      #  Make sure that A, B, and A+B are all in the interval [0,1] and
      #  that you can't divide by 0.
      #----------------------------------------------------------------

  if ((A > 1) | (B > 1) | ((A + B) > 1))
    {
    ret.values$is.legal.pos <- FALSE;
    ret.values$is.legal <- FALSE;
    }

  if ((A < 0) | (B < 0) | ((A + B) <= 0))
    {
    ret.values$is.legal.neg <- FALSE;
    ret.values$is.legal <- FALSE;
    }

      #----------------------------------------------
      #  All ok, so compute function value to return.
      #----------------------------------------------

  if (ret.values$is.legal)
    ret.values$M <- (A - B) / (A + B);

  if (DEBUG)
    {
    cat ("\n    A = ", A, "B = ", B, "(A + B) = ", (A + B),
         "\nis.legal = ", ret.values$is.legal);
    }

  return (ret.values)
  }

#==============================================================================
# LS (2012.07.11) added new formulation (A-B)/B


func.A.minus.B.over.B <- function (A, B)
{
  ret.values <- init.ret.values ();



  #-------------------------------------------------------------
  #  Make sure that A, B, and (A-B)/A are all in the interval [0,1].
  #-------------------------------------------------------------


  if ((A > 1) | (B > 1) )  #***LS: May want to change M constraints
  {
    ret.values$is.legal.pos <- FALSE;
    ret.values$is.legal <- FALSE;
  }

  if ((A < 0) | (B <= 0) )
  {
    ret.values$is.legal.neg <- FALSE;
    ret.values$is.legal <- FALSE;
  }

  M <- (A - B) / B;

  #cat("\n","A=",A,"B=",B,"M=",M,"\n");

  if (is.nan(M))
    {
    ret.values$is.legal.pos <- FALSE;
    ret.values$is.legal.neg <- FALSE;
    ret.values$is.legal <- FALSE;
    } else
    {
    if (M > 1 )  #***LS: May want to change M constraints
      {
      ret.values$is.legal.pos <- FALSE;
      ret.values$is.legal <- FALSE;
      }

#     if ( M <= 0)
#       {
#       ret.values$is.legal.neg <- FALSE;
#       ret.values$is.legal <- FALSE;
#       }
    }

  #----------------------------------------------
  #  All ok, so compute function value to return.
  #----------------------------------------------

  #browser()

  if (ret.values$is.legal)  ret.values$M <- M;

  return (ret.values)
}


#==============================================================================
