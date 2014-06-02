# R file for testing the output during dry runs


p <- parameters


# build the commandline to run zonation

z.cmdline <- paste( p$z.executable, p$z.settings.file, p$z.spp.file, p$z.output.file,
                   p$z.other.cmd.line.args )

cat( '\n\nThe commandline to run zonation is:\n', z.cmdline )


cat( '\n\nTrying to run zonation....')


#system2( system.command, args=system.command.arguments, env="DISPLAY=:1" )      
system( z.cmdline )

