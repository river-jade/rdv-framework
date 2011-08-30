

# a set of utility functions for dealing with GIS data in R

# libraries needed are
#  - maptools (to deal with shapefiles)
#  - RSQLite (for dealing with the SQLite database)

# Ascelin Gordon - 20/11/2010
#
# TO run:
#         source( "GIS.utility.functions.R" )



library( maptools )
library( RSQLite)
source( 'dbms.functions.R' )
source( 'utility.functions.R' )

extract.shape.file.attribute.table.to.data.frame <- function( full.shapefile.filename) {


  # this returns a SpatialPolygonsDataFrame object
  # see http://sekhon.berkeley.edu/library/sp/html/SpatialPolygonsDataFrame-class.html
  shapefile.object <- readShapePoly( full.shapefile.filename )

  # now extract the dataframe from the  SpatialPolygonsDataFrame object
  attribute.table.dataframe <- shapefile.object@data

  return( attribute.table.dataframe ) 

}

##########################################################################################

extract.attribute.table.headers <- function( full.shapefile.filename) {


  # this returns a SpatialPolygonsDataFrame object
  # see http://sekhon.berkeley.edu/library/sp/html/SpatialPolygonsDataFrame-class.html
  shapefile.object <- readShapePoly( full.shapefile.filename )

  # now extract the dataframe from the  SpatialPolygonsDataFrame object
  attribute.table.dataframe <- shapefile.object@data

  cat( "\nThe column names in file", full.shapefile.filename, "are:\n",
      colnames( attribute.table.dataframe ) )
  
  return( colnames( attribute.table.dataframe ) )

}



##########################################################################################

extract.shape.file.attribute.table.to.data.base <- function( full.shapefile.filename,
                                                           DB.name, table.name  ) {


  t.data.frame <- extract.shape.file.attribute.table.to.data.frame( full.shapefile.filename )

  
  
  write.data.frame.to.new.DB(t.data.frame, DB.name, table.name )

  cat( "\nWrote the attribute table from shape file", full.shapefile.filename,
      "to the database", DB.name, "\n" )

  
}


##########################################################################################


update.shapefile.att.table.field <- function( full.in.shpfilename, full.out.shpfilename,
                                              update.data.df, shape.file.column.names ) {

  
  # Read in the shape file
  shapefile.object <- readShapePoly( full.in.shpfilename )

  # Check the length of the column in the attribute table to update

  colnames.new.data <- colnames(update.data.df)
  
  
  no.entries.in.shpfile <- length( shapefile.object@data[ ,colnames.new.data[1] ] )
  no.entries.in.new.data <- length( update.data.df[,1])
  
  if( no.entries.in.new.data == no.entries.in.shpfile ){

    # In this case there are as many values as in the attribute table
    # as there are in the new values so we can write it directly to
    # the shapefile

    values.to.pad.new.df.with <- integer(0)

  } else {

    # In this case there are not as many entires in the new data so
    # assuming that we were running on a subset of the PUs for
    # testing. In this case pad the new data with 0s to show that
    # these PUs were not operated 

    if( no.entries.in.new.data > no.entries.in.shpfile ){
      cat( '\nERROR: no.entries.in.new.data > no.entries.in.shpfile',
          '[from update.shapefile.att.table.field()]' )
      stop()
    }

    values.to.pad.new.df.with <- rep(-999, (no.entries.in.shpfile-no.entries.in.new.data) )
    
  }

  #browser()

  ctr <- 0
  for( cur.col in colnames.new.data ) {

    ctr <- ctr+1
    shapefile.object@data[ , shape.file.column.names[ctr] ] <-
      c( update.data.df[,cur.col ], values.to.pad.new.df.with )

  }

  
  # Finally write the updated shapefile, first testing to make sure one does not already exist.

  if( !file.exists(full.out.shpfilename) ) {

    writePolyShape(shapefile.object, full.out.shpfilename )
    cat( "\nWrote polygon file:", full.out.shpfilename, "\n" )
    
  } else {
    
    cat( '\nERROR: trying to overwite existing polygon file:\n', full.out.shpfilename, '\n\n' )
    stop()
    
  }
  
}



##########################################################################################


testing.GIS.utility.functions <- function() {

  # code for testing the functions

  cadastral.shape.file <-
    "/Users/ascelin/analysis/gis_data/CPW/2nd_data_same_proj/cpw_cadstre_del_parcels_removed/cpw_cadastre_FINAL.shp"

  new.database <- "/Users/ascelin/analysis/CPW_sydney/code/test_R_shapefile/CPW_parcel_info.dbms"
  table.name <- "att_table"
  
  df.dump.filename <-
    "/Users/ascelin/analysis/CPW_sydney/code/test_R_shapefile/CPW_parcel_info_dataframe.Rdump"


  # EXAMPLE 1 shp file to DB - using the lower level functions
  #att.df <- extract.shape.file.attribute.table.to.data.frame (cadastral.shape.file )               #col.names <- extract.attribute.table.headers (cadastral.shape.file )
  #write.data.frame.to.new.DB( att.df, new.database, table.name )

  # Example 2 shp file to DB - do it all in one step
  extract.shape.file.attribute.table.to.data.base(cadastral.shape.file, new.database,
                                                  table.name)

  # Exmple 3 shp file to data.frame
  #att.df <- extract.shape.file.attribute.table.to.data.frame( cadastral.shape.file )

  #dump.data.frame.to.file( att.df, df.dump.filename )
  
}

