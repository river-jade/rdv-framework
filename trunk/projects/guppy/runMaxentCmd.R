#=========================================================================================

#                               runMaxentCmd.v2.R

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
## sample.path <- paste ("MaxentSamples/", cur.spp.name, ".sampledPres.csv", sep='')
## system (paste ("java -mx512m -jar maxent.jar -e MaxentEnvLayers -s ",
##             sample.path, " -o outputs -a", sep=''))
## ###system ('do1.bat')    #  the call to run zonation - makes it wait to return?
## browser()

#---------------------

#		Maxent can build species maps for just one species or you can give
#		it a combined list of species presences for different species
#		over the same environment and it will go through all of them.
#		That's what the spp.sampledPres.combined.csv file above is
#		talking about.  Have to decide whether to combine them all into
#		one file or run maxent one species at a time.
#		Probably makes more sense to combine them all into one file
#		since maxent is likely to run faster that way.

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

runMaxentCmd = function (maxentSamplesFileName, maxentOutDir, bootstrapMaxent)
	{
	cat ("\n\nIn runMaxentCmd(), \n        maxentSamplesFileName = '", maxentSamplesFileName, "'\n\n", sep='')

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

maxentCmd = paste ('java -mx512m -jar ',

	filenameQuote,
					maxent.full.path.name,
	filenameQuote,

#                       ' outputdirectory=MaxentOutputs',
				   ' outputdirectory=',
	filenameQuote,
				   maxentOutDir,
	filenameQuote,

				   #' samplesfile=../MaxentSamples/spp.sampledPres.combined.csv',
#                       ' samplesfile=',PAR.input.directory, '/spp.sampledPres.combined.csv',
#				   ' samplesfile=',cur.full.maxent.samples.dir.name, '/spp.sampledPres.combined.csv',
				   ' samplesfile=',
	filenameQuote,
				   maxentSamplesFileName,
	filenameQuote,

				   ' environmentallayers=',
	filenameQuote,
				   cur.full.maxent.env.layers.dir.name,
	filenameQuote,

						#  If you have more than one processor in your
						#  machine, then setting the thread count to the
						#  number of processors can speed up things like
						#  jacknife operations (and hopefully, replicate
						#  operations) by using all of the processors.
				   ' threads=', PAR.num.processors,

				   ' autorun ',

				   ' redoifexists ',

#                      ' nowarnings ',

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

                            #  While I'm doing interactive testing, I'll leave
                            #  novisible commented out.  I think that the place
                            #  where it matters is in doing lots of batch runs
                            #  where you wouldn't see maxent doing its thing.
#				   ' novisible',

				   sep = '')

#if (variables$PAR.do.maxent.replicates)
if (bootstrapMaxent)
	{
	maxentCmd = paste (maxentCmd,
						' replicates=', variables$PAR.num.maxent.replicates,

						' replicatetype=bootstrap ',

#  There are some random seed issues here when doing bootstrap replicates.
#  It looks like you cannot choose the seed yourself so you cannot get
#  a reproducible result.  If you set randomseed to false and then try
#  this, maxent will put up a prompt telling you that it is going to
#  set randomseed to true.
#  Need to talk to the maxent developers about this.
#  2011.09.21 - BTL
						' randomseed=true',
#                       ' randomseed=false',

						sep='')
	}


cat( '\n\nThe command to run maxent is:', maxentCmd, '\n' )

#cat ("\n\n\n")
#stop()

#----------

cat( '\n----------------------------------' );
cat( '\n Running Maxent' );
cat( '\n----------------------------------' );

maxent.exit.code = system (maxentCmd)

cat ("\n\nmaxent.exit.code = ", maxent.exit.code,
	", class (maxent.exit.code) = ", class (maxent.exit.code))

if (maxent.exit.code != 0)
  {
  stop (paste ("\n\nmaxent failed: maxent.exit.code = ",
               maxent.exit.code, sep=''),
        call. = FALSE)
  } else
  {
  cat ("\n\nmaxent run succeeded (i.e., exit code == 0).")
  }

	}  #  end function - runMaxentCmd

#===============================================================================


