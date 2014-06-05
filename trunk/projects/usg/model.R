# R file for testing the output during dry runs


p <- parameters


    #--------------------------------------------
    # Generate the species list file for zonation 
    #--------------------------------------------

cat( '\nThe input dir for species data is:',  p$z.input.data.dir )
cat( '\nFilename for the Zonation spp file:',  p$z.spp.list.filename )
cat( '\nThe Zonation settings .dat file is:',  p$z.settings.file )

# Get a list of all the .asc in the input dir. These will all go into
# the input species file
spp.file.list <- dir( p$z.input.data.dir, pattern='asc', full.names=TRUE )

if( length(spp.file.list) == 0 ) {
    cat('\nERROR: No species maps were found, stopping.\n\n')
	stop()
}


# Now write the the zonation species list file (assuming all spp have
# the same weight for now
for( s in spp.file.list){
    cat( '1.0 1.0 1 1 1 ', s, '\n', append=TRUE, file=p$z.spp.list.filename, sep='' )
}




    #--------------------------------------------
    # Run Zonation
    #--------------------------------------------


# Build the commandline to run zonation

#z.cmdline <- paste( p$z.executable, '-r', p$z.settings.file, p$z.spp.file, p$z.output.file,
#                   p$z.other.cmd.line.args )
z.cmdline <- paste( p$z.executable, '-r', p$z.settings.file, p$z.spp.list.filename, p$z.output.file,
                   p$z.other.cmd.line.args )

cat( '\n\nThe commandline to run zonation is:\n', z.cmdline )
cat( '\n\nTrying to run zonation....')

if( !p$do.dry.run ) system( z.cmdline )


