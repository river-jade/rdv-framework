#===============================================================================

#                          setUpAndRunZonation.R

#===============================================================================

#  History
#
#  2014 02 19 - BTL - Created.
#
#  Have split the old guppy and even older Austin ESA code that was in 
#  runZonation.R into several pieces.
#    - The header comments from runZonation.R are in this file now.
#    - The initialization of path names, etc. has all been moved into 
#      initializeG2options.R.  
#    - The function called setUpAndRunZonation.R is now in this file.
#    - The running of zonation on apparent and then on correct was done 
#      by calling this setUp...() function in runZonation.R but those 
#      two calls are now made in the g2 mainline code.
#    - The plotting and evaluation of zonation results that was the last 
#      part of runZonation.R has now been moved into a separate file and 
#      function called evaluationZonationResults.R.  That function is 
#      called in the g2 mainline just after the two calls to setUp...().
#
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
#===============================================================================
#===============================================================================

#  OLD COMMENTS FROM PAST VERSIONS FROM HERE DOWN TO START OF CODE.
#  LEAVING THEM IN FOR NOW BECAUSE IT HELPS IN TRACKING DOWN ODD BEHAVIOR 
#  THAT IS A RESULT OF THE WAY THIS STUFF HAS DEVELOPED IN DIFFERENT CONTEXTS 
#  AND CONVERSIONS OVER TIME.

#===============================================================================
#===============================================================================
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

#  OLD...
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

setUpAndRunZonation = function (spp.list.filename,
                                zonation.files.dir,
                                zonation.input.maps.dir,
                                spp.used.in.reserve.selection.vector,
                                zonation.output.filename,
                                full.path.to.zonation.parameter.file,
                                full.path.to.zonation.exe,
                                runZonation,
                                sppFilePrefix,
                                closeZonationWindowOnCompletion, 
                                dir.slash
                                )
    {
    cat ("\n\n*******************  At start of setUpAndRunZonation  *******************")    
    cat ("\n    spp.list.filename = '", spp.list.filename, "'", sep='')
    cat ("\n    zonation.files.dir = '", zonation.files.dir, "'", sep='')
    cat ("\n    zonation.input.maps.dir = '", zonation.input.maps.dir, "'", sep='')
    cat ("\n    spp.used.in.reserve.selection.vector = '", spp.used.in.reserve.selection.vector, "'", sep='')
    cat ("\n    zonation.output.filename = '", zonation.output.filename, "'", sep='')
    cat ("\n    full.path.to.zonation.parameter.file = '", full.path.to.zonation.parameter.file, "'", sep='')
    cat ("\n    full.path.to.zonation.exe = '", full.path.to.zonation.exe, "'", sep='')
    cat ("\n    runZonation = '", runZonation, "'", sep='')
    cat ("\n    sppFilePrefix = '", sppFilePrefix, "'", sep='')
    cat ("\n    closeZonationWindowOnCompletion = '", closeZonationWindowOnCompletion, "'", sep='') 
    cat ("\n    dir.slash = '", dir.slash, "'", sep='')
    
    
    zonation.spp.list.full.filename = 
        paste0 (zonation.files.dir, dir.slash, spp.list.filename)

    cat ("\n\nzonation.spp.list.full.filename = '", zonation.spp.list.full.filename, "'", sep='')
    
    if (file.exists (zonation.spp.list.full.filename))
        file.remove (zonation.spp.list.full.filename)
    
        #  Need to build the spp_list.dat file.
        #  In /Users/bill/D/rdv-svn/rdv-framework/trunk/framework2/rdv/lib/zonation/spp_list.dat
        #      1.0 1.0 2 10 1.0 /Users/ascelin/analysis/zonation/wine_test2_data/spp1.asc
        #      1.0 1.0 2 10 1.0 /Users/ascelin/analysis/zonation/wine_test2_data/spp2.asc
        #      1.0 1.0 2 10 1.0 /Users/ascelin/analysis/zonation/wine_test2_data/spp3.asc
    
    zonation.input.maps.dir = gsub ("Documents and Settings", "DOCUME~1", zonation.input.maps.dir)
    cat ("\n\nzonation.input.maps.dir = '", zonation.input.maps.dir, "'", sep='')

    for (cur.spp.id in spp.used.in.reserve.selection.vector)
        {
            #		filename <- paste (zonation.input.maps.dir, '/', 'spp.', cur.spp.id, '.asc', sep = '' );
            ##		filename <- paste ('"', zonation.input.maps.dir, dir.slash, 'spp.',
            ##							cur.spp.id, '.asc', '"', sep = '' );
            #  sppFilePrefix is different for correct and apparent species.
            #  For apparent, it will just be "spp", but for correct,
            #  it will probably be something like "true.prob.dist.spp".
#        filename <- paste (zonation.input.maps.dir, dir.slash, sppFilePrefix, '.',
#        filename <- paste (zonation.input.maps.dir, sppFilePrefix, '.',
        filename <- paste0 (zonation.input.maps.dir, dir.slash, sppFilePrefix, '.',                           
                           cur.spp.id, '.asc');
        line.of.text <- paste ("1.0 1.0 1 1 1 ", filename, "\n", sep = "");
        cat (line.of.text, file = zonation.spp.list.full.filename, append = TRUE);
        }
    
        #  From /Users/bill/D/rdv-svn/rdv-framework/trunk/framework2/rdv/lib/zonation/README.txt
        #  Example to call zonation with wine on mac or linux:
        #  > wine zig2 -r Z_parameter_settings.dat spp_list.dat output.txt 0.0 0 1.0 1
        #  The last number in the list autoclose (if set to 0 then zonation will stay open after it finishes running)
    
    zonation.full.output.filename =
        paste0 (zonation.files.dir, dir.slash, zonation.output.filename)
    cat ("\n\nzonation.full.output.filename = '", zonation.full.output.filename, "'", sep='')

    #  Maxent's command line parsing chokes on Windows file names that
    #  contain spaces, so you need to put quotes around all the path
    #  or file names that you hand to it.
    filenameQuote = '"'
    
    full.path.to.zonation.exe = gsub ("Documents and Settings", "DOCUME~1", full.path.to.zonation.exe)
    full.path.to.zonation.parameter.file = gsub ("Documents and Settings", "DOCUME~1", full.path.to.zonation.parameter.file)
    zonation.spp.list.full.filename = gsub ("Documents and Settings", "DOCUME~1", zonation.spp.list.full.filename)
    zonation.full.output.filename = gsub ("Documents and Settings", "DOCUME~1", zonation.full.output.filename)

    cat ("\n\nfull.path.to.zonation.exe = '", full.path.to.zonation.exe, "'", sep='')
    cat ("\n    full.path.to.zonation.parameter.file = '", full.path.to.zonation.parameter.file, "'", sep='')
    cat ("\n    zonation.spp.list.full.filename = '", zonation.spp.list.full.filename, "'", sep='')
    cat ("\n    zonation.full.output.filename = '", zonation.full.output.filename, "'", sep='')

#full.path.to.zonation.exe = "/usr/local/bin/zig3"
#cat ("\n\nfull.path.to.zonation.exe = ", full.path.to.zonation.exe)

    system.command.run.zonation <- 
        paste0 (######    '/sw/bin/wine',
                filenameQuote, full.path.to.zonation.exe, filenameQuote, " ", 
               '-r', " ", 
               filenameQuote, full.path.to.zonation.parameter.file, filenameQuote, " ", 
               filenameQuote, zonation.spp.list.full.filename, filenameQuote, " ", 
               filenameQuote, zonation.full.output.filename, filenameQuote, " ", 
               "0.0 0 1.0",  " ", 
               as.integer (closeZonationWindowOnCompletion)
               )

#     system.command.run.zonation <- 
#         paste (######    '/sw/bin/wine',
#             full.path.to.zonation.exe,
#             '-r',
#             full.path.to.zonation.parameter.file,
#             zonation.spp.list.full.filename,
#             zonation.full.output.filename,
#             "0.0 0 1.0",
#             as.integer (closeZonationWindowOnCompletion)
#         )


    cat( "\n\n>>>>>  The system command to run zonation will be:\n'", system.command.run.zonation, "'\n>>>>>\n\n", sep='')
    
    #---------------------
    
        #  Can't run zonation under wine yet, so only allow it to be tried
        #  under Windows for now...
    
    cat("\n =====> The current wd is", getwd() )
    
    if (runZonation)
        {
        if (regexpr ("ming*", current.os) != -1)            
            {
            retval = system (system.command.run.zonation)
            
            } else if (regexpr ("darwin*", current.os) != -1)            
            {
            cat (paste0 ("\n\n=====>  Can't run zonation on Mac yet since ", 
                         "wine doesn't work properly yet.  Skipping zonation call.\n\n"))
            retval = "on mac - SKIPPED ZONATION CALL"
                
            } else
            {
#                system.specific.cmd <- 'wine'
                system.specific.cmd <- ''
                
                
                full.path.to.zonation.exe = "/usr/local/bin/zig3"
                cat ("\n\nfull.path.to.zonation.exe = ", full.path.to.zonation.exe)
                
                system.command.run.zonation <- 
                    paste0 (######    '/sw/bin/wine',
#                        filenameQuote, full.path.to.zonation.exe, filenameQuote, " ", 
                        '-r', " ", 
                        filenameQuote, full.path.to.zonation.parameter.file, filenameQuote, " ", 
                        filenameQuote, zonation.spp.list.full.filename, filenameQuote, " ", 
                        filenameQuote, zonation.full.output.filename, filenameQuote, " ", 
                        "0.0 0 1.0",  " ", 
                        as.integer (closeZonationWindowOnCompletion)
                    )
                
                
                
                
                
                
                cat ("\n\nAbout to run zonation using system.specific.cmd = '", system.specific.cmd, "'\n\n", sep='')
            
                retval = system2 (full.path.to.zonation.exe, args=system.command.run.zonation, env="DISPLAY=:1")
#            retval = system2 (system.specific.cmd, args=system.command.run.zonation, env="DISPLAY=:1")
#            retval = system2 (system.specific.cmd, args=system.command.run.zonation, env="DISPLAY=:0")
            }
        
        cat ("\n\nzonation retval = '", retval, "'.\n\n", sep='')        
        }

    cat ("\n\n*******************  At END of setUpAndRunZonation  *******************")
    }

#===============================================================================

