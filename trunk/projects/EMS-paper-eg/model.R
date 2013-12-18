# R file for testing the output during dry runs

# an example of sourcing another R doc
#source( "w.R" )



cat( "\n*** The path to the downloaded GBIF data is:",  parameters$path.to.GBIF.data, '\n' )
cat( "\n*** The path to spp range shp file dir is :",  parameters$path.to.spp.ranges.shp, '\n' )

cat('Value for test variable 1 is:', parameters$'test.variable.1', '\n')

cat('The working dir is', getwd(), '\n')
cat('test.output.filename=', parameters$'test.output.filename', '\n')
