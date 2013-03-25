# source( 'scp-collab.download.inputdata.R' )

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------


rm( list = ls( all=TRUE ))

source( 'variables.R' )

cat( '\n----------------------------------' )
cat( '\n  scp-collab.download.inputdata.R ' )
cat( '\n----------------------------------\n' )


# Download the required inputdata

setwd( PAR.current.run.directory )

# Download the zip file, to a file with the same name as the original zip file
download.file( paste(PAR.input.data.zipfile.url, PAR.input.data.zipfile.url.filename, sep=''),
               destfile=PAR.input.data.zipfile.url.filename)

# Unzip the zipfile
unzip( PAR.input.data.zipfile.url.filename )
