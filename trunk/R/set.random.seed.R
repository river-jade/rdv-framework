#==============================================================================

###	Usage:
###		source ('set.random.seed.R');

#  Set the seed for random number generation

#  History:
#      - Extracted from reserve.validation.R.
#        BTL - 02/03/09.

#      - Added specification of a starting seed to use if not using the
#        seed from the previous run and not using the run number as the seed.
#        No value was specified before, so I think that the it would default
#        to the seed from the initialcall to sample().  This means that if
#        something weird happened, you wouldn't necessarily be able to
#        figure out what the seed was to be able to repeat the problem.

#        Also moved setting seed to previous end seed up next to where it
#        is read, because where it was would only see it executed half the
#        time.
#        BTL - 02/03/09.

#==============================================================================

    #--------------------------------------------
    #  Load definitions of functions called here.
    #--------------------------------------------

source( 'stop.execution.R' )

#==============================================================================

    #---------------------------------------------------------------
    #  Load global variables from a file written by the python code.
    #---------------------------------------------------------------

source( 'variables.R' )

#==============================================================================

    #------------------------------------------------------------------------
    #  I'm commenting this line out because I don't think it's needed anymore
    #  since I've added the startingSeed and guarantee that a seed is always
    #  created.  I won't remove the line yet though, in case I'm wrong.
    #  BTL - 02/03/09.
    #------------------------------------------------------------------------

  # put in a dummy line with sample in it, otherwise depending on what
  # other parts of the framework are operating, there may be no other
  # calls to any random functions and the "save.seed <- .Random.seed"
  # line will cause the program to stop
#####dummy.sample <- sample(1);

#--------------------------

if (use.same.seed.as.last.run)
  {
      #load the seed from the previous run
  if (file.exists ('./rng.seed'))
    {
    previous.end.seed <- scan ("rng.seed");
    set.seed (previous.end.seed);
    
    } else
    {
    cat( '\nWARNING: Could not load random seed from file.' );
    cat( '\nFile rng.seed not found.' );
    cat( '\nRun once use.same.seed.as.last.run set to false.\n' );
    stop.execution();
    }
  
  } else if (use.run.number.as.seed)
  {
  set.seed (random.seed);
  
  } else  #  Not using previous or run number, so use default seed value.
  {
  set.seed (startingSeed);
  }

#==============================================================================

