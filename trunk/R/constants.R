#==============================================================================

#  source ('constants.R')

#  Constants used throughout the rdv framework code.

#==============================================================================

#  History:

#  2011.01.09 - BTL - Created.

#==============================================================================

    #------------------------------
    #  Constants from loss model.  
    #------------------------------

CONST.NO.PU.LEFT.TO.DEVELOP = -88
CONST.NO.ELIGIBLE.PU.TO.DEVELOP = -33
CONST.NO.OVERFLOW.PU.TO.DEV = 0

#CONST.UNINITIALIZED.NON.NEG.NUM = -77
CONST.UNINITIALIZED.NON.NEG.NUM = 0.0

#==============================================================================

CONST.UNINITIALIZED.NUM = -77

#==============================================================================

CONST.dev.IN.offset.IN = 1
CONST.dev.IN.offset.OUT = 2
CONST.dev.OUT.offset.OUT = 3
 
#==============================================================================

    #-----------------------------------
    #  Constants from offsetting pool.
    #-----------------------------------

        #---------------------------------------------------------------
        #  There were a couple of references to -99 in the code but no 
        #  indication of what it meant, so I am giving it a name.
        #  BTL - 2010.12.07
        #---------------------------------------------------------------

CONST.NO.OFFSETS.LEFT = -99

CONST.NO.PU.LEFT.TO.DEVELOP = -88

#==============================================================================

    #-----------------------------------
    #  Constants from partial offset.
    #-----------------------------------

CONST.UNINITIALIZED.PU.ID.VALUE <- -999;

        #---------------------------------------------------------------
        #  There were a couple of references to -99 in the code but no 
        #  indication of what it meant, so I am giving it a name.
        #  BTL - 2010.12.07
        #---------------------------------------------------------------

CONST.NO.OFFSETS.LEFT <- -99
CONST.NO.PU.LEFT.TO.DEVELOP <- -88

#==============================================================================

    #------------------------------------
    #  Constants related to ErrorModel.
    #------------------------------------

CONST.EM.BIAS.UNDERESTIMATE <- -1
CONST.EM.BIAS.NEUTRAL <- 0
CONST.EM.BIAS.OVERESTIMATE <- 1

#==============================================================================

    #  Making this test for initialized values a function so that I can 
    #  replace it with a test related to NA instead of a value if I want 
    #  to later.

is.initialized.number <- function (x)
    {
    return (x != CONST.UNINITIALIZED.NUM)
    }
    
#------------------------------------------------------------------------------

is.uninitialized.number <- function (x)
    {
    return (x == CONST.UNINITIALIZED.NUM)
    }
    
#==============================================================================

    
