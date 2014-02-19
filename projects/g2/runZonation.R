#===============================================================================

#  To run the current version of the code:

#      source ('test.maxent.v5.R')

#  Note that it currently assumes the following directory structure
#  of that MaxentTest directory:

#    drwxr-xr-x   5 bill  staff     170 20 Jan 11:20 AlexsSyntheticLandscapes
#    drwxr-xr-x   6 bill  staff     204 17 Feb 13:09 MaxentEnvLayers
#    drwxr-xr-x  14 bill  staff     476 17 Feb 13:48 MaxentOutputs
#    drwxr-xr-x   4 bill  staff     136 17 Feb 12:55 MaxentProbDistLayers
#    drwxr-xr-x   2 bill  staff      68 17 Feb 11:15 MaxentProjectionLayers
#    drwxr-xr-x   5 bill  staff     170 17 Feb 13:10 MaxentSamples
#    drwxr-xr-x   3 bill  staff     102 18 Feb 12:30 ResultsAnalysis
#    -rw-r--r--@  1 bill  staff   25339 18 Feb 12:55 test.maxent.R
#    -rw-r--r--@  1 bill  staff    8617 17 Feb 13:22 w.R

#  Also note that w.R is a modified version of w.R from the framework.
#  Need to commit it to the framework so that the changes to write.asc.file()
#  are generally available.  Those changes are simple ones and only involve
#  making a bunch of the parameters able to be specified in the call rather
#  than fixed inside the routine.  All of the new call arguments default to
#  the old values though, so no existing framework code should be broken by
#  this.

#-------------------------

#  NOTE: things to add to the ML book
#        (have added this to evernote on 2011.07.17)
#
#      - Having spaces in a file path can cause R to choke on the mac.
#        If I do something like:
#            dir (probabilities.dir)
#        when probabilities directory ccontains embedded spaces like this:
#            probabilities.dir <- "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated ecology/MaxentTests/MaxentProbDistLayers/"
#        then R returns
#            char(0)
#        which is similar to what the shell terminal window gives:
#            > ls -l /Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated ecology/MaxentTests/MaxentProbDistLayers/
#            > ls: -: No such file or directory


#===============================================================================

#  History
#
#  2014 02 19 - BTL
#  Starting to convert to run under g2.
#    - First problem is that the old code tests for a specific darwin version 
#      when seeing if you're running on a mac.  Since there are lots of 
#      versions, I'm changing to test for "darwin*" rather than "darwin9.8.0".
#      Doing a similar thing for testing for windows.  It currently says 
#      "mingw32", but I don't know if that ever changes so now I'm testing for 
#      "ming*".
#
#  2013 04 29 - BTL
#  Stripped out everything before zonation section of test.maxent.v5.R to
#  make a starting point for the code to run zonation.  Will source this
#  file from inside the new runMaxent.R code.

#===============================================================================

#  2013 04 29 - BTL
#  History from here down is old history from test.maxent.v5.R.
#  Some of it may no longer apply, but some of it may help explain
#  some things that are in here.  Can remove it all later when the
#  more final version of this code is working.

#  2011.02.18 - BTL
#  Have now completed a prototype that goes all the way through the process
#  of:
#    - reading a pair of environment layers from .pnm files
#    - combining them in some way to produce a "correct" probability
#      distribution
#    - drawing a "correct" population of presences from that distribution
#    - sampling from that correct population to get the "apparent" population
#    - running maxent on that sample plus the environment layers
#    - reading maxent's resulting estimate of the probability distribution
#    - computing the error between maxent's normalized distribution and the
#      correct normalized distribution
#    - computing some statistics and possibly showing a heatmap of the errors
#      as a first cut at examining the spatial distribution of error.
#
#  There are lots of restrictions and assumptions about formats and locations
#  and hard-coded rules for combining layers and you still have to run maxent
#  by hand.  However, some version of every step is there and it works from
#  end to end to get a result.  Now we just need to:
#    - expand the capabilities of each step
#    - add the ability to inject error in all inputs and processes
#    - turn it into a class to make it easier to use and to swap methods
#      in and out
#    - make a project for it in the framework and give it access to yaml
#      files for setting control variables and run over many different
#      scenarios and inputs

#  2011.08.07 - BTL
#  Working on ESA version now.
#  Most of that work will happen in the guppy project of framework2, but
#  some things may happen here as well.
#    - Just moved defn of get.img.matrix.from.pnm() to w.R in framework2/R.
#    - Extracted all of the function definitions into test.maxent.functions.v4.R
#      since this file was too complicated to read easily.

#===============================================================================

library (pixmap)

setwd (rdvRootDir)

runZonationAppAndCore = function (current.os)
    {
    if (regexpr ("darwin*", current.os) != -1)
        {
    	stop (paste0 ("\n\n=====>  Can't run zonation on Mac yet since wine doesn't work properly yet.",
    		   "\n=====>  Quitting now.\n\n",
    		   sep=''))    
    	} 
    
        #--------------------
    
        #  APPARENT
    setUpAndRunZonation (zonation.APP.spp.list.filename,
    					zonation.files.dir,
    					zonation.APP.input.maps.dir,
    					spp.used.in.reserve.selection.vector,
    					zonation.APP.output.filename,
    					full.path.to.zonation.parameter.file,
    					full.path.to.zonation.exe,
    					runZonation,
    					"spp",
    					parameters$PAR.closeZonationWindowOnCompletion
    					)
    
    #--------------------
    
        #  CORRECT
    setUpAndRunZonation (zonation.COR.spp.list.filename,
    					zonation.files.dir,
    					zonation.COR.input.maps.dir,
    					spp.used.in.reserve.selection.vector,
    					zonation.COR.output.filename,
    					full.path.to.zonation.parameter.file,
    					full.path.to.zonation.exe,
    					runZonation,
    					"true.prob.dist.spp",
    					parameters$PAR.closeZonationWindowOnCompletion
    					)
    
    cat ("\n\nDone setting up and running zonation.\n\n")
    #stop()
    
#===============================================================================
    
    cat ("\n\nAt end of runZonationAppAndCore().\n\n")
    
    }

#===============================================================================


