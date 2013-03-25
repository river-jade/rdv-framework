# source( 'scp-collab.delete.downloaded.input.data.R' )

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------


rm( list = ls( all=TRUE ))

source( 'variables.R' )
source( 'utility.functions.R' )

cat( '\n-----------------------------------------------' )
cat( '\n  scp-collab.delete.downloaded.input.data.R ' )
cat( '\n---------------------------------------------\n' )


setwd( PAR.current.run.directory )


if (PAR.delete.downloaded.data.at.end.of.run ) {

  # Delete the download the input data to save space

  # First delete the downloaded zip file
  cat( '\nDeleting the file', PAR.input.data.zipfile.url.filename )
  unlink( PAR.input.data.zipfile.url.filename )

  # Second, delete the unzipped data. The function
  # strip.filename.extension(PAR.input.data.zipfile.url.filename) is
  # used to get the dir name from the input file, eg if the input file
  # is input_data.zip, this would create the dir input_data with
  # multiple files in it when unzupped). When we delete this dir we
  # want to recursively delete just the input_data directory

  dir.to.delete <- no.extension ( PAR.input.data.zipfile.url.filename )
  cat ('\nRecursively deleting the directory', dir.to.delete )
  unlink( dir.to.delete,  recursive = TRUE )

  cat( '\n' )
}
