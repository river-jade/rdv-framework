# Does all the file copying then
# Runs zonation and copies output files back to the working dir.

# source( 'run.zonation.R'     );

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

rm( list = ls( all=TRUE ));

source( 'variables.R'     );

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

#  set in python...

    #------------------------------------------------------------
    #  Start Code
    #------------------------------------------------------------


    cat( '\n----------------------------------' );
    cat( '\nReserve Selection Method: ZONATION' );
    cat( '\n----------------------------------' );


# First get the OS
#   for linux this returns linux-gnu
#   for mac this returns darwin9.8.0
#   for windos this returns mingw32

current.os <- sessionInfo()$R.version$os


spp.used.in.reserve.selection.vector <- 1:PAR.num.spp.in.reserve.selection


number.asc.header.rows <- 6;  #number of header rows in the ascii files for
                              #zonation.

source.dir <- getwd()
cat( "\n The path to the run dir is", PAR.current.run.directory )
cat( "\n The path back to the source tree is ", source.dir)

# Fist copy the Zonation data file to the output dir

from.filename <- paste( PAR.path.to.zonation, '/', PAR.zonation.parameter.filename, sep = '' )
to.filename <- paste(  PAR.current.run.directory, '/',  PAR.zonation.parameter.filename, sep = '' )

if( !file.copy( from.filename, to.filename, overwrite = TRUE ) ) {
    
  cat( '\nCould not copy species habitat files to zonation directory\n' );
  stop( '\nAborted due to error.', call. = FALSE );
    
}



# Generate the specied list file for zonation 

zonation.spp.list.full.filename <- paste( PAR.current.run.directory, '/',
                                         PAR.zonation.spp.list.filename, sep ='' )

if(file.exists(zonation.spp.list.full.filename)) file.remove( zonation.spp.list.full.filename ) 


file.list <- dir( PAR.path.to.spp.hab.map.files )  # NEW


for( cur.spp.id in spp.used.in.reserve.selection.vector ) {

  if( current.os == 'mingw32' ) {
    filename <- paste( PAR.spp.hab.map.filename.root.win, '.', cur.spp.id, '.asc', sep = '' );
  } else {
    filename <- paste( PAR.spp.hab.map.filename.root, '.', cur.spp.id, '.asc', sep = '' );
  }
  
  # line.of.text <- paste( "1.0 1.0 1 1 1 ", filename, "\n", sep = "" )

  path.to.file <- paste( source.dir, '/', PAR.path.to.spp.hab.map.files, sep='')  # NEW
  line.of.text <- paste( "1.0 1.0 1 1 1 ", paste(path.to.file, file.list[cur.spp.id],sep=''), "\n", sep = '' ) # NEW

  cat( line.of.text, file = zonation.spp.list.full.filename, append = TRUE );
  
}

browser()


# Now try and run zonation!

full.path.to.zonation.exe <- paste( source.dir, '/', PAR.path.to.zonation,  '/',
                                   PAR.zonation.exe.filename, sep = '')

cat( '\n\n full.path.to.zonation.exe=', full.path.to.zonation.exe )


setwd( PAR.current.run.directory )

if( current.os == 'mingw32' ) {
  
  # in this case we're one a windows machine
  system.command.run.zonation <- paste( full.path.to.zonation.exe, '-r',
                                               PAR.zonation.parameter.filename,
                                               PAR.zonation.spp.list.filename, PAR.zonation.output.filename,
                                               "0.0 0 1.0 1" ) 

} else {
  
  # otherwise assume we're on mac or linux
  system.command.run.zonation <- paste( 'wine', full.path.to.zonation.exe, '-r',
                                                    PAR.zonation.parameter.filename,
                                                    PAR.zonation.spp.list.filename, PAR.zonation.output.filename,
                                                    "0.0 0 1.0 0" ) # NEW - changed autoclose
}



cat( '\n The system command to run zonation will be:', system.command.run.zonation )

system( system.command.run.zonation )
        


## if( ! file.copy( "../zonation/zonation_output.rank.asc", ".",
##                 overwrite = TRUE )) {
  
##   cat( '\nCould not copy zonation result to runall directory\n' );
##   stop( '\nAborted due to error.', call. = FALSE );

## }

## # read in the zonation output file. Remove the header that the ".asc"
## # file contains 

## temp.zonation <- readLines( "zonation_output.rank.asc", n = (rows + number.asc.header.rows) );

## temp.zonation2 <- temp.zonation[ (number.asc.header.rows +1) : (rows + number.asc.header.rows)];


## write.table( temp.zonation2, file = "zonation_output.rank.txt",
##             quote = FALSE, row.names = FALSE, col.names = FALSE )




