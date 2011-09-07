#    source ('run.java.patch.info.R');

    source ('variables.R');

    #-----------------------------------------------------------#
    # Run Java code which replaces previous Fragstats call.                  
    # This will identify patches, and label them with unique
    # integer IDs.  These IDs are then spatially 'scrambled'
    # across the map, and if the user specifies a minimum patch
    # area, patches below that size are removed.
    # The outputs are:                             
    #  - labelled ASCII map, (.txt, .asc and .pgm formats)
    #  - a file with 4 columns
    #        <Patch ID> <Area> <Manhattan-distance perimeter>
    #        <Closer estimate of perimeter (S. Prashker algorithm)>
    #
    # Need 2 arguments at least
    # <ASCII file in>
    # <root name for output files> 
    # <minimum patch area>
    # <pixel as patch (1(true) or 0(false))>
    #   I'd recommend always using false! Not properly tested yet,
    #   and pretty energy consuming.
    # <include diagonals (0 or 1)>
    # <foreground value (default value 1)> I'd recommend always using 1
    #                                           
    # .. and, if reading a headerless .txt file...   
    #                                         
    # <number of rows>                                
    # <number of columns>                             
    # <min. x>                                  
    # <min. y>                       
    # <pixel resolution>
    #  
    # e.g.
    # java PatchDistance/DistanceMapper ./inputs/test_patches01.txt ./outputs/test_patches01 0.0 0 1 1 263 267 0.0 0.0 1.0
    # **reads a headerless text file - very simple, just has 7 patches
    #------------------------------------------------------------

    # TODO - these should go to rdv.configuration.R
    # File in and out names will change within a batch run, but should be
    # based on common root
  
master.habitat.map.zo1.filename <- paste( master.habitat.map.zo1.base.filename, '.txt', sep = '');
    #  Changed z01 to zo1 to match other uses in the python code.
    #  BTL - 02/03/09.
#####file.in <- paste( '../runall/', master.habitat.map.z01.filename, sep = '' );
file.in <- paste( '../runall/', master.habitat.map.zo1.filename, sep = '' );
file.out.root <-  paste( '../runall/', master.habitat.map.pid.base.filename,
                        sep = '' );

# need a 0 or 1 rather than 'TRUE' or 'FALSE'
use.diags <- 0;
if( OPT.use.diags ) use.diags <- 1;
upp <- 0;
if (use.pixels.as.patches) upp <- 1;


#Jcommand <- paste("java PatchDistance/DistanceMapper", file.in,
#                  file.out.root, patch.size.thresh, upp, use.diags,
#                  habitat.value, rows, cols, min.x, min.y, pixel.size,
#                  sep=' ');

Jcommand <- paste("java -cp PatchDistance/bin DistanceMapper", file.in,
                  file.out.root, lower.patch.size.thresh,
                  upper.patch.size.thresh, upp, use.diags,
                  habitat.value, rows, cols, min.x, min.y, pixel.size,
                  sep=' ');
  
  
#pause( paste( 'java command is', Jcommand) );

  # Write this command to a batch file for execution.
  # This has some painful directory changes in it!

write("cd ..",   file="../java/runpatchdist.bat", append=FALSE)
write("cd java", file="../java/runpatchdist.bat", append=TRUE)

write(Jcommand, file="../java/runpatchdist.bat", append=TRUE)

write("cd ..", file="../java/runpatchdist.bat", append=TRUE)
write("cd runall", file="../java/runpatchdist.bat", append=TRUE)
  
#pause("Wrote batch file file")

system("../java/runpatchdist", wait=TRUE)

  # the code creates two files in the runall directory
  # binaryHabitatMap.patches.att - This contains three nums for each patch
  #          area bound.length smoothed.boundry.length see above
  # binaryHabitatMap.patches.dist - the patch dist matrix

