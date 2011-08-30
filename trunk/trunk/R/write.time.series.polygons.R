

# A script to write the a polygon file to show the current information about each parcel 

# Ascelin Gordon - 10/12/2010
#
# TO run:
#         source( 'write.time.series.polygons.R' )


rm( list = ls( all=TRUE ))

source( 'GIS.utility.functions.R' )
source( 'variables.R' )

if( current.time.step%%PAR.interval.between.generating.polygon.maps == 0 ) {

  
  # get the unique  PU ids from the database
  query <- paste( 'select MANAGED from', dynamicPUinfoTableName )
  managed.vec <- sql.get.data(PUinformationDBname , query)

  query <- paste( 'select RESERVED from', dynamicPUinfoTableName )
  reserved.vec <- sql.get.data(PUinformationDBname , query)

  query <- paste( 'select TIME_RESERVED from', dynamicPUinfoTableName )
  time.reserved.vec <- sql.get.data(PUinformationDBname , query)

  query <- paste( 'select DEVELOPED from', dynamicPUinfoTableName )
  developed.vec <- sql.get.data(PUinformationDBname , query)

  query <- paste( 'select TIME_DEVELOPED from', dynamicPUinfoTableName )
  time.developed.vec <- sql.get.data(PUinformationDBname , query)


  # These need to be the same names match in order with
  # shape.file.column.names Note that these aren't identical because
  # in ARCGIS there is a limit to the number of characters in the att
  # table heading and 'TIME_RESERVED' is too long!!!
  column.names <- c('MANAGED', 'RESERVED', 'TIME_RESERVED', 'DEVELOPED', 'TIME_DEVELOPED' )
  shape.file.column.names <- c('MANAGED', 'RESERVED', 'TIME_RES', 'DEVELOPED', 'TIME_DEV' )

  update.data.df <- as.data.frame(cbind( managed.vec, reserved.vec, time.reserved.vec,
                                        developed.vec, time.developed.vec))
  
  colnames( update.data.df ) <- column.names


  # Always use the original shapfile as the initial shapefile, this is
  # because now you can specify any interval between when shapefiles
  # will be written so you don't know when the last time step was
  
  in.shape.filename <- PAR.PU.information.shapefile
 
  #if ( current.time.step == 0 ) {
    # It it's the first time step then use the initial shape file as input
  #  in.shape.filename <- PAR.PU.information.shapefile
  #} else {
    # Otherwise use the polygon file from the previous time step
    #in.shape.filename <- paste( PAR.PU.information.output.shapefile.filename.base, '_t',
    #                           (current.time.step - step.interval), '.shp', sep='' )
  #}
  
  # Determine the name to wite the now ploygon to 
  out.shape.filename <- paste( PAR.PU.information.output.shapefile.filename.base, '_t',
                              current.time.step, '.shp', sep='' ) 

  update.shapefile.att.table.field( in.shape.filename, out.shape.filename,
                                   update.data.df, shape.file.column.names )

}
