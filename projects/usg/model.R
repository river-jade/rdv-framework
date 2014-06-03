# R file for testing the output during dry runs


p <- parameters


    #--------------------------------------------
    # Generate the species list file for zonation 
    #--------------------------------------------

cat( '\np$z.input.data.dir = ',  p$z.input.data.dir )
cat( '\np$z.spp.list.filename = ',  p$z.spp.list.filename )

# Get a list of all the .asc in the input dir. These will all go into
# the input species file
spp.file.list <- dir( p$z.input.data.dir, pattern='asc', full.names=TRUE )

# Now write the the zonation species list file (assuming all spp have
# the same weight for now
for( s in spp.file.list){
    cat( '1.0 1.0 1 1 1', s, '\n', append=TRUE, file=p$z.spp.list.filename )
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

#setwd( '/home/ubuntu/usg_zigtest/')

system( z.cmdline )


#system2( system.command, args=system.command.arguments, env="DISPLAY=:1" )      

