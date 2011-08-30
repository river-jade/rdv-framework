#==============================================================================

###	Usage:
###		source ('generate.habitat.R');

#  If user is not supplying habitat map(s), generate habiat map(s).

#  History:
#      - Extracted from reserve.validation.R.
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

    #------------------------------------------------------------
    #  Generate habitat map if requested.
    #  Otherwise, assume that the user has provided it.
    #
    #  Used to be able to either generate square patches or run RULE.
    #  Currently, have removed the ability to run RULE because its output
    #  needs some postprocessing to generate maps that don't tend to have
    #  just one giant patch and a bunch of little ones.
    #  Ascelin has some scripts to run externally that can help fix up
    #  the generated maps to be more useful and then you can stick them
    #  in the runall directory as you would any other map that you have
    #  supplied.  
    #-----------------------------------------------------------

if( generate.habitat.map ) {
  if( use.test.maps ) {
    cat ("\nAbout to make square patches...\n");
    source( 'make.sq.patches.R' );

        #  "pause()" uses an interactive call in R (menu()) and it chokes when
        #  I run this code from python in Eclipse.
        #  So, for the moment, I'll just comment it out...
        #  BTL - 02/03/09.
#####    pause( "Finished Generating Master Habitat Map" );
    cat( "\nFinished Generating Master Habitat Map\n" );
  }

  # run Lucy's java code that does the patch labeling
  # and inter-patch distences etc...

  cat ("\nAbout to run lucy's java patch info code...\n");
  source( 'run.java.patch.info.R' );
  
  # the code below will ultimately also be replaced by the Java
  if( use.pixels.as.patches ) {
    cat ("\nAbout to assign patch IDs to single pixels...\n");
        #---------------------------------------------------------------------
        #  Leaving this in for now, but not converting it to run under python.
        #  We don't use it at the moment and if we ever do get around to
        #  using it, then it will crash immediately and flag the fact that
        #  it needs to be converted.
        #
        #  Mostly not converting it because of these lines that reference
        #  "binaryHabitatMap.patches.*".  I'm not sure where that file is
        #  supposed to have been built.
        #      file.copy( 'binaryHabitatMap.patches.txt',
        #                 'binaryHabitatMap.patches.orig.txt',
        #                 overwrite = TRUE )
        #      file.copy( 'binaryHabitatMap.patches.pgm',
        #                 'binaryHabitatMap.patches.orig.pgm',
        #                 overwrite = TRUE )
        #
        #  Based on the file names, I think that it might be very old code
        #  that has never been updated to match the file naming conventions
        #  that we're using now.  (For example, in the Documentation file
        #  about file names, one of the "OLD NAME:" sections says that
        #  binaryHabitatMap.patches.* has changed to hab.map.master.pid.*.
        #
        #  BTL - 03/03/09.
        #---------------------------------------------------------------------
    source( 'assign.patch.ids.to.single.pixels.R' );
  
  }

  cat ("\nAbout to recalculate master hab maps...\n");
  # this function
   source( 'recalculate.master.hab.maps.R' );

#####  pause( "Finished running new java code" )

}    #end - if( generate.habitat.map )

#==============================================================================

