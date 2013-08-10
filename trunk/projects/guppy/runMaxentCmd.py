#=========================================================================================

#                               runMaxentCmd.v2.py

# source( 'runMaxentCmd.R' )

#=========================================================================================

#  History:

#  2013.04 - BTL
#  Split out of guppy.test.maxent.v9.R and later versions of runMaxent.R.

#  2013.04.18 - BTL
#  Added parameters to argument list and restructured the construction of the
#  maxent command string to have one base string that gets a bit added if
#  bootstrapping.  The old logic had two separate commands and there's no
#  point in that now and it makes it more confusing and harder to maintain.

#=========================================================================================

###    Example java calls from maxent help file

###java -mx512m -jar maxent.jar environmentallayers=layers samplesfile=samples\bradypus.csv outputdirectory=outputs togglelayertype=ecoreg redoifexists autorun
###java -mx512m -jar maxent.jar -e layers -s samples\bradypus.csv -o MaxentOutputs -t ecoreg -r -a
##
## cur.spp.name <- spp.name
## sample.path <- paste ("MaxentSamples/", cur.spp.name, ".sampledPres.csv"
## system (paste ("java -mx512m -jar maxent.jar -e MaxentEnvLayers -s ",
##             sample.path, " -o outputs -a")
## ###system ('do1.bat')    #  the call to run zonation - makes it wait to return?
## browser()

#---------------------

#        Maxent can build species maps for just one species or you can give
#        it a combined list of species presences for different species
#        over the same environment and it will go through all of them.
#        That's what the spp.sampledPres.combined.csv file above is
#        talking about.  Have to decide whether to combine them all into
#        one file or run maxent one species at a time.
#        Probably makes more sense to combine them all into one file
#        since maxent is likely to run faster that way.

#  setting up for maxent requires the following:
#      - asc file for each species showing its true probability
#        distribution to use to build the samples file (it's not
#        used by maxent itself)
#      - an equation for each species (to build the true probability map
#        for each species)

#  maxent itself needs the following:
#      - csv file with the list of samples for each species
#      - asc file for each environment layer
#        these env layers are the same for every species in a particular
#        run and they are the ones that are drawn from alex's set

#===============================================================================

testing = False

if testing:
        #  Formerly variables used inside the function but not in arg list.
        #  Have now added these to the arg list.
    maxentFullPathName = 'TESTmaxent.full.path.name/'
    curFullMaxentEnvLayersDirName = 'TESTcur.full.maxent.env.layers.dir.name'
    PARnumProcessors = 2

        #  Arguments to the call.
    maxentSamplesFileName = 'TESTmaxentSamplesFileName'
    maxentOutDir = 'TESTmaxentOutDir/'
    doMaxentReplicates = False
    maxentReplicateType = 'TESTmaxentReplicatType'
    numMaxentReplicates = 10
    verboseMaxent = True

#===============================================================================

import os
import subprocess

#===============================================================================

def runMaxentCmd (maxentSamplesFileName, maxentOutDir, \
                        doMaxentReplicates, maxentReplicateType, \
                        numMaxentReplicates, \
                        maxentFullPathName, \
                        curFullMaxentEnvLayersDirName, \
                        PARnumProcessors = 1, \
                        verboseMaxent = True \
                        ):

    print "\n\nIn runMaxentCmd(), \n        maxentSamplesFileName = '" + maxentSamplesFileName + "'\n"

    #----------------------------------------------------------------------
    #  BTL - 2013 04 09
    #  For some reason, " outputdirectory=MaxentOutputs" no longer worked
    #  correctly after I had added code to create the
    #  maxent.output.dir variable at the start of this file.
    #  maxent would run and look like it was doing everything just fine
    #  until the very end but stop and say it couldn't find the output
    #  directory, even though it had already written to it.
    #  Afterwards, there was also a file called Rplots.pdf left in the
    #  output area but I couldn't open it.  A stackoverflow page mentioned
    #  Rplots.pdf being created when some plotting device was written to
    #  but not open (or something like that).
    #  Not sure what was going on but as soon I swapped to
    #      ' outputdirectory=', maxent.output.dir
    #  everything worked fine again.  May have had to do with some other
    #  thing that I was doing around the same time and not the creation
    #  of the maxent.output.dir variable since I was changing a bunch of
    #  things in the process of creating the true relative probability
    #  distribution.
    #----------------------------------------------------------------------

        #  Maxent's command line parsing chokes on Windows file names that
        #  contain spaces, so you need to put quotes around all the path
        #  or file names that you hand to it.
    filenameQuote = '"'

    maxentCmd = \
            '-mx512m -jar ' + \
        filenameQuote + \
                        maxentFullPathName + \
        filenameQuote + \
                       ' outputdirectory=' + \
        filenameQuote + \
                       maxentOutDir + \
        filenameQuote + \
                        ' samplesfile=' + \
        filenameQuote + \
                       maxentSamplesFileName + \
        filenameQuote + \
                       ' environmentallayers=' + \
        filenameQuote + \
                       curFullMaxentEnvLayersDirName + \
        filenameQuote + \
                        ' verbose=' + str (verboseMaxent) + \
                       ' threads=' + str (PARnumProcessors) + \
                       ' -z ' + \
                       ' autorun ' + \
                       ' redoifexists ' + \
                       ' novisible'



    """
            '-mx512m -jar ' + \
        filenameQuote + \
                        maxentFullPathName + \
        filenameQuote + \
    #                       ' outputdirectory=MaxentOutputs' +
                       ' outputdirectory=' + \
        filenameQuote + \
                       maxentOutDir + \
        filenameQuote + \
                       #' samplesfile=../MaxentSamples/spp.sampledPres.combined.csv' +
    #                       ' samplesfile=',PAR.input.directory, '/spp.sampledPres.combined.csv' +
    #                   ' samplesfile=',cur.full.maxent.samples.dir.name, '/spp.sampledPres.combined.csv' +
                       ' samplesfile=' + \
        filenameQuote + \
                       maxentSamplesFileName + \
        filenameQuote + \
                       ' environmentallayers=' + \
        filenameQuote + \
                       curFullMaxentEnvLayersDirName + \
        filenameQuote + \
                        ' verbose=' + verboseMaxent + \    #  Gived detailed diagnostics for debugging
                            #  If you have more than one processor in your
                            #  machine, then setting the thread count to the
                            #  number of processors can speed up things like
                            #  jacknife operations (and hopefully, replicate
                            #  operations) by using all of the processors.
                       ' threads=' + PARnumProcessors + \
                       ' -z ' + \   #  Run without showing the gui
                       ' autorun ' + \ #  Run without having to hit return.
                       ' redoifexists ' + \
    #                      ' nowarnings ' +
                            #  Looks like you have to set the "novisible" flag
                            #  in the argument list to maxent and then it will
                            #  return a 1 if it fails.  Without the "novisible"
                            #  flag, it seems to assume that you know there was
                            #  a problem (since its GUI was visible and hung
                            #  when it gave you a blocking message when it had
                            #  a problem) and returns an exit code that says it
                            #  succeeded instead of failed.
                            #  Commented out in guppy.test.maxent.v9.R
                            #  Not commented out in ascelin's guppy example code.
                            #  Not sure which is best inside of tzar.
                       ' novisible'
                                #  While I'm doing interactive testing, I'll leave
                                #  novisible commented out.  I think that the place
                                #  where it matters is in doing lots of batch runs
                                #  where you wouldn't see maxent doing its thing.
    #                   ' novisible'

    if doMaxentReplicates:

        maxentCmd = maxentCmd + \
                            ' replicates=' + numMaxentReplicates + \
                            ' replicatetype=' + maxentReplicateType + \
    #  There are some random seed issues here when doing bootstrap replicates.
    #  It looks like you cannot choose the seed yourself so you cannot get
    #  a reproducible result.  If you set randomseed to false and then try
    #  this, maxent will put up a prompt telling you that it is going to
    #  set randomseed to true.
    #  Need to talk to the maxent developers about this.
    #  2011.09.21 - BTL
                            ' randomseed=true'
    #                       ' randomseed=false'
    #------------------------
    #  NOT IMPLEMENTED YET, but I want to remember the option names...
    #                        ' linear=', allowLinearFeatures +
    #                        ' quadratic=' + allowQuadraticFeatures +
    #                        ' product=' + allowProductFeatures +
    #                        ' threshold=' + allowThresholdFeatures +
    #                        ' hinge=' + allowHingeFeatures +
    #                               Number of samples at which product and threshold features start being used.
    #                               default is 80.
    #                        ' lq2lqptthreshold=' + lq2lqptthreshold +
    #                               Number of samples at which quadratic features start being used
    #                               default is 10.
    #                        ' hingethreshold=' + hingethreshold +
    #                               Number of samples at which hinge features start being used
    #                               default is 15.
    #                        ' hingethreshold=' + hingethreshold +
    #------------------------



    """

    if doMaxentReplicates:

        maxentCmd = maxentCmd + \
                            ' replicates=' + str (numMaxentReplicates) + \
                            ' replicatetype=' + maxentReplicateType + \
                            ' randomseed=true'


    print '\n\nThe command to run maxent is:' + maxentCmd + '\n'

    #print "\n\n\n")
    #stop()

    #----------

    print '\n----------------------------------'
    print '\n Running Maxent'
    print '\n----------------------------------'

            #------------------------------------------------
            #  Need to deal with possible failure of maxent.
            #  Not sure how to handle this in python at the moment,
            #  but here are some comments from a stackoverflow question.
            #  For the moment, I'll just use the exit() since it's
            #  simplest.  Will come back to this later...

            ###  http://stackoverflow.com/questions/438894/how-do-i-stop-a-program-when-an-exception-is-raised-in-python

            ###  You can stop catching the exception, or - if you need to catch it (to do some custom handling), you can re-raise:

            ###    try:
            ###      doSomeEvilThing()
            ###    except Exception, e:
            ###      handleException(e)
            ###      raise

            ###  Note that typing raise without passing an exception object causes the original traceback to be preserved. Typically it is much better than raise e.

            ###  Of course - you can also explicitly call

            ###     import sys
            ###     sys.exit(exitCodeYouFindAppropriate)

            ###  This causes SystemExit exception to be raised, and (unless you catch it somewhere) terminates your application with specified exit code.
            #------------------------------------------------
            #  There are also some issues with what OS function to use to
            #  run the maxent program, particularly when dealing with Windows.

            ###  http://stackoverflow.com/questions/204017/how-do-i-execute-a-program-from-python-os-system-fails-due-to-spaces-in-path

            ###  http://stackoverflow.com/questions/89228/calling-an-external-command-in-python
            ###     ***  It gives "a summary of the ways to call external
            ###                    programs and the advantages and
            ###                    disadvantages of each"
            ###          There are also lots of other informative comments
            ###          all throughout the page.
            #------------------------------------------------
            ###  Ascelin message to me on May 6, 2013 discusses why we need
            ###  the system2() call with env="DISPLAY=:1" in R.
            ###  Basically, Nectar needs to have the DISPLAY variable set
            ###  in the environment (for running zonation?) and system2()
            ###  allows you to set it this way.

            ###  Here is some more he said in an email on May 7th:
            ###  "
            ###  system2( system.command, args=system.command.arguments, env="DISPLAY=:1" )
            ###  Here is the full script:
            ###  https://rdv-framework.googlecode.com/svn/trunk/R/scp-collab.run.zonation.R

            ###  If system 2 isn't available in your R installation just update to a newer version.

            ###  You also need to have make sure
            ###      export DISPLAY=:1
            ###      Xvfb $DISPLAY -auth /dev/null &> /tmp/Xvfb_rdv.log &
            ###  is set on the linux machine.
            ###  "

            ###  Not sure how to do the env thing in python...
            #------------------------------------------------

    if testing:
        maxentExitCode = 999
    else:
#        maxentExitCode = os.system ('java' + maxentCmd, env="DISPLAY=:1")

            #  The "call" function takes an array of arguments instead of a
            #  string I think.  If so, then the rest of this routine needs
            #  to be redone to handle that.  It would actually be better
            #  like that anyway, I suppose...
        javaCmd = 'java ' + maxentCmd
        maxentExitCode = os.system (javaCmd)
#        maxentExitCode = subprocess.call ('java', maxentCmd, shell=False)


#        if currentOS == CONST.windowsOSname:
#            maxentExitCode = system ('java ' + maxentCmd)
#        else:
#            maxentExitCode = system2 ('java', maxentCmd, env="DISPLAY=:1")
            #------------------------------------------------

    print "\n\nmaxentExitCode = " + str (maxentExitCode) + \
        ", class (maxentExitCode) = " + maxentExitCode.__class__.__name__


###        if maxentExitCode != 0:
###            stop ("\n\nmaxent failed: maxentExitCode = " + str (maxentExitCode)),
###                    call. = False)
###        else:
###          print "\n\nmaxent run succeeded (i.e., exit code == 0)."

#===============================================================================

def test_runMaxentCmd ():

    runMaxentCmd (maxentSamplesFileName, maxentOutDir, \
                        doMaxentReplicates, maxentReplicateType, \
                        numMaxentReplicates, \
                        maxentFullPathName, \
                        curFullMaxentEnvLayersDirName, \
                        PARnumProcessors, \
                        verboseMaxent \
                        )

if testing:
    test_runMaxentCmd()

#===============================================================================


