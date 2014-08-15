


extract.shape.file.attribute.table.to.data.frame <- function( full.shapefile.filename) {


  # this returns a SpatialPolygonsDataFrame object
  # see http://sekhon.berkeley.edu/library/sp/html/SpatialPolygonsDataFrame-class.html
  shapefile.object <- readShapePoly( full.shapefile.filename )

  # now extract the dataframe from the  SpatialPolygonsDataFrame object
  attribute.table.dataframe <- shapefile.object@data

  return( attribute.table.dataframe ) 

}
