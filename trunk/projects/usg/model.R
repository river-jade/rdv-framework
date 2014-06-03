# R file for testing the output during dry runs


p <- parameters


    #--------------------------------------------
    # Generate the species list file for zonation 
    #--------------------------------------------


#p$z.spp.list.filename
cat( '\np$z.input.data.dir = ',  p$z.input.data.dir )
cat( '\np$z.spp.list.filename = ',  p$z.spp.list.filename )

# get a list of all the .asc in the input dir. These will all go into the input species file
spp.file.list <- dir( p$z.input.data.dir, pattern='asc', full.names=TRUE )


for( spp in spp.file.list) {


    cat( '1.0 1.0  1 1 1', spp, '\n', append=TRUE, file=p$z.spp.list.filename )

}


# Build the commandline to run zonation

z.cmdline <- paste( p$z.executable, '-r', p$z.settings.file, p$z.spp.file, p$z.output.file,
                   p$z.other.cmd.line.args )

cat( '\n\nThe commandline to run zonation is:\n', z.cmdline )


cat( '\n\nTrying to run zonation....')

#setwd( '/home/ubuntu/usg_zigtest/')

#system2( system.command, args=system.command.arguments, env="DISPLAY=:1" )      
#system( z.cmdline )

