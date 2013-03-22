# source( 'scp-collab.download.inputdata.R' )

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------


rm( list = ls( all=TRUE ))

source( 'variables.R' )
source( 'w.R' )

cat( '\n----------------------------------' )
cat( '\n  scp-collab.download.inputdata.R ' )
cat( '\n----------------------------------\n' )


# Download the required inputdata

setwd( PAR.current.run.directory )
download.file(PAR.input.data.zipfile.URL, destfile ="input_data.zip")
unzip("input_data.zip" )
