# R file for testing the output during dry runs
library("rgdal")

cat( "\n*** The path to the DSE data for protected areas in GML format is:",  parameters$path.to.crown.land.kml, '\n' )
crown_lyr<-ogrListLayers(dsn=parameters$path.to.crown.land.kml)
crown_points <- readOGR(dsn=parameters$path.to.crown.land.kml, layer=crown_lyr)

cat( "\n*** The path to Anuran species range shp file dir is :",  parameters$path.to.spp.ranges.shp, '\n' )
shapefileName <- paste(parameters$path.to.spp.ranges.shp, "ANURA.shp", sep="\\")     
cat( "\n*** The path to the actual shapefile should be :",  shapefileName , '\n' )

sp_lyr<-ogrListLayers(dsn=shapefileName )
sp_polys <- readOGR(dsn=shapefileName , layer=sp_lyr)

cat('Value for test variable 1 is:', parameters$'test.variable.1', '\n')

cat('The working dir is', getwd(), '\n')
cat('test.output.filename=', parameters$'test.output.filename', '\n')


cat( "\n*** The path to the downloaded GBIF data for a single frog species is:",  parameters$path.to.GBIF.data, '\n' )
frog_lyr<-ogrListLayers(dsn=parameters$path.to.GBIF.data)
frog_points <- readOGR(dsn=parameters$path.to.GBIF.data, layer=frog_lyr)
