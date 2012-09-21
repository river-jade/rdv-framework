# Does all the file copying then
# Runs zonation and copies output files back to the working dir.

# source( 'run.zonation.scp-collab.R' )

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

rm( list = ls( all=TRUE ));

source( 'variables.R'     )

    cat( '\n----------------------------------' )
    cat( '\nrun.zonation.scp-collab.R         ' )
    cat( '\n----------------------------------' )

number.asc.header.rows <- 6;  #number of header rows in the ascii files for
                              #zonation.

# First get the OS
#   for linux this returns linux-gnu
#   for mac this returns darwin9.8.0
#   for windos this returns mingw32

current.os <- sessionInfo()$R.version$os

spp.used.in.reserve.selection.vector <- 1:PAR.num.spp.in.reserve.selection


source.dir <- getwd()
cat( "\n The path to the run dir is", PAR.current.run.directory )
cat( "\n The path back to the source tree is ", source.dir)

    #--------------------------------------------
    # Copy the Zonation data file to the output dir
    #--------------------------------------------

from.filename <- paste( PAR.path.to.zonation, '/', PAR.zonation.parameter.filename, sep = '' )
Z.settings.file.full.path <- paste(  PAR.current.run.directory, '/',  PAR.zonation.parameter.filename, sep = '' )
if( !file.copy( from.filename, Z.settings.file.full.path, overwrite = TRUE ) ) {
  cat( '\nCould not copy',PAR.zonation.parameter.filename, 'to', Z.settings.file.full.path, '\n' )
  stop( '\nAborted due to error.', call. = FALSE )
}


    #--------------------------------------------
    # Generate the species list file for zonation 
    #--------------------------------------------

zonation.spp.list.full.filename <- paste( PAR.current.run.directory, '/',
                                         PAR.zonation.spp.list.filename, sep ='' )
# delete old one if already there
if(file.exists(zonation.spp.list.full.filename)) file.remove( zonation.spp.list.full.filename ) 


file.list <- dir( PAR.path.to.spp.hab.map.files, pattern="^m" )
# pattern="^m" is regex for files starting with m
# need this becuase all spp maps start with m so want these but don't want the admin map which starts with "a"

for( cur.spp.id in spp.used.in.reserve.selection.vector ) {

  path.to.file <- paste( source.dir, '/', PAR.path.to.spp.hab.map.files, sep='')
  if( current.os == mingw32 ) path.to.file <- gsub("/", "\\\\", path.to.file )
  line.of.text <- paste( "1.0 1.0 1 1 1 ", paste(path.to.file, file.list[cur.spp.id],sep=''), "\n", sep='' )
  cat( line.of.text, file = zonation.spp.list.full.filename, append = TRUE )
  
}

browser()

    #--------------------------------------------
    # If using admin units, generate the admin input files
    #--------------------------------------------

if( PAR.use.administrative.units ){
  
  # Administrative units description file
  cat ( '#ID    G_A    beta_A    name\n' , file = PAR.zonation.admu.desc.file, append = TRUE );
  for( i in 1:PAR.num.admin.units ) {
    line.of.text <- paste ( i, '    1    1    ',  'R', i, '\n', sep='' )
    cat( line.of.text, file = PAR.zonation.admu.desc.file, append = TRUE );
  }

  # Administrative units weights matrix file
  for( i in 1:PAR.num.spp.in.reserve.selection) {
    cat( rep( 1, PAR.num.admin.units), '\n', file = PAR.zonation.admu.weights.matrix.file, append = TRUE )
  }
  
  # Add the extra admin units settings to the Zonation parameter file

  string <- paste( 
                  '[Administrative units]', '\n',
                  'use ADMUs = 1', '\n',
                  'ADMU descriptions file = ADMU_desc.txt', '\n',
                  'ADMU layer file = ', PAR.admin.regions.map, '\n',
                  'ADMU weight matrix = ADMU_weights_matrix.txt', '\n', 
                  'calculate local weights from condition = 1', '\n',
                  'ADMU mode = 2', '\n',
                  'Mode 2 global weight = ', PAR.admin.units.global.weight, '\n', sep=''
                  )
  
  cat( string, file = Z.settings.file.full.path, append = TRUE )

}


    #--------------------------------------------
    # Now try and run zonation
    #--------------------------------------------

full.path.to.zonation.exe <- paste( source.dir, '/', PAR.path.to.zonation,  '/',
                                   PAR.zonation.exe.filename, sep = '')

cat( '\n\n full.path.to.zonation.exe=', full.path.to.zonation.exe )


setwd( PAR.current.run.directory )

if( current.os == 'mingw32' ) {
  
  system.specific.cmd <- ''
  
  # in this case we're one a windows machine
  ## system.command.run.zonation <- paste( full.path.to.zonation.exe, '-r',
  ##                                              PAR.zonation.parameter.filename,
  ##                                              PAR.zonation.spp.list.filename, PAR.zonation.output.filename,
  ##                                              "0.0 0 1.0 1" )
  

} else {
  
  system.specific.cmd <- 'wine'
  
  # otherwise assume we're on mac or linux
  ## system.command.run.zonation2 <- paste( 'wine', full.path.to.zonation.exe, '-r',
  ##                                                   PAR.zonation.parameter.filename,
  ##                                                   PAR.zonation.spp.list.filename, PAR.zonation.output.filename,
  ##                                                   "0.0 0 1.0 1" ) 

}

system.command.run.zonation <- paste( system.specific.cmd, full.path.to.zonation.exe, '-r',
                                       PAR.zonation.parameter.filename,
                                       PAR.zonation.spp.list.filename, PAR.zonation.output.filename,
                                       "0.0 0 1.0 1" ) 

cat( '\n The system command to run zonation will be:', system.command.run.zonation )

#system( system.command.run.zonation )      

    #--------------------------------------------
    # If running with Administrative units run zonation again to
    # loading previously calculated solution based on
    # ADMU.redistributed.rank.asc solution. The *.curves.txt file when
    # running with admin units is not based on this file (see p 136 of Z
    # manual v3.1)
    #--------------------------------------------

if( PAR.use.administrative.units ){

  reload.output.name <- paste( PAR.zonation.output.filename, '_redistributed.rank', sep = '')
  
  system.command.run.zonation <- paste( system.specific.cmd,
                                       full.path.to.zonation.exe,
                                       '-lzonation_output.ADMU.redistributed.rank.asc',
                                       PAR.zonation.parameter.filename,
                                       PAR.zonation.spp.list.filename,
                                       reload.output.name,
                                       "0.0 0 1.0 1" )

  browser()
  system( system.command.run.zonation )
  
}

#/Users/ascelin/tzar/outputdata/SCP_collab_S2_local_100_8315.inprogress

# wine /Users/ascelin/analysis/src/rdv-framework/R/../lib/zonation/zig3.exe -lzonation_output.ADMU.redistributed.rank.asc Z_parameter_settings.dat zonation_spp_list.dat zonation_output_redistributed.rank.txt 0.0 0 1.0 1
