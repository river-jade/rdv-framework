#===============================================================================

#  source ("initializeBeyondSettingOptions.R")

#===============================================================================

#  History

#  2014 02 05 - BTL - Cloned from guppy/guppyInitializations.R.
#    - That file is not even an active file in guppy since the conversion to 
#      python starting around June, 2013.  The copy of guppyInitializations.R 
#      is (I think) a restored version taken from the code repository from a 
#      guppy version from around May, 2013, just before the SEWPAC report for 
#      2013.  That version of the code was in turn, "Split out of 
#      guppy.test.maxent.v9.R and later versions of runMaxent.R." around 
#      April, 2013 (according to the History comment in the file).
#    - The code here is a subset of that code plus some modifications, since 
#      I'm changing many initializations (e.g., directory creations) to be 
#      more of a just-in-time kind of initialization.  This is intended to 
#      make all of the functions be more decoupled and easier to test and 
#      to use in a pipelined fashion with better dependency injection.  
#        - Also, one or more directories have different names in guppy now 
#          than they did when the May, 2013 version was active, so those  
#          changes need to be reflected here too.

#===============================================================================

#---------------------------------------------------------------
#  Determine the number of true presences for each species.
#  At the moment, you can specify the number of true presences
#  drawn for each species either by specifying a count for each
#  species to be created or by specifying the bounds of a
#  random fraction for each species.  The number of true
#  presences will then be that fraction multiplied times the
#  total number of pixels in the map.
#---------------------------------------------------------------

if (useRandomNumTruePresForEachSpp)
    {
    numTruePresForEachSpp = 
        getNumTruePresForEachSpp_usingRandom (numSppToCreate,
                                              minTruePresFracOfLandscape,
                                              maxTruePresFracOfLandscape,
                                              numImgCells)
    
    } else
    {
    numTruePresForEachSpp = 
        getNumTruePresForEachSpp_usingSpecifiedCts (numTruePresForEachSpp_string, 
                                                    numSppToCreate)
    }

#-------------------------------------------------------------------------------

    #  Values for setting values in .asc headers.
    #  These were passed in from Pyper before.
    #  Hard coding for now.  
    #  Need to read them from one of the env files or something.
    #  yaml file shows:
        # PAR.ascFileNcols: 512
        # PAR.ascFileNrows: 512
        # PAR.ascFileXllcorner: 2618380.652817
        # PAR.ascFileYllcorner: 2529528.47684
        # PAR.ascFileCellsize: 75.0
        # PAR.ascFileNodataValue: -9999

llcorner = c (2618380.65282, 2529528.47684)
cellsize = 75.0
nodataValue = -9999

#===============================================================================

