
# source( 'scp-collab.permute.coalitions.R' )

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------


rm( list = ls( all=TRUE ))

source( 'variables.R' )
source( 'w.R' )

cat( '\n----------------------------------' )
cat( '\n  scp-collab.permute.coalitions.R ' )
cat( '\n----------------------------------\n' )

    #--------------------------------------------
    # Read in the current admin file 
    #--------------------------------------------

PAR.admin.regions.map <- '/Users/ascelin/analysis/src/rdv-framework/projects/scp-collab/input_data/admin_regions.asc'

PAR.remapped.admin.regions.map.filename.base <- '~/tmp/admin_regions_remapped'
PAR.admin.regions.map.filename.base <- '~/tmp/admin_regions'

PAR.ncols <- 281
PAR.nrows <- 250
PAR.xllcorner <- -109.45483714671
PAR.yllcorner <- -55.979644819015
PAR.cellsize <- 0.286609223258
PAR.NODATA_value <- -9999



admin.units.map <- as.matrix(read.table( PAR.admin.regions.map, skip=6 ))
all.unique.ids <- unique(as.vector( admin.units.map ) )
unique.ids <- sort(all.unique.ids[which( all.unique.ids != PAR.NODATA_value )])

orig.ids <- unique.ids


    #--------------------------------------------
    # Now permunte the ids
    #--------------------------------------------


# For now this is just a hack that assigns each current coutnry into one of 4 coalitions

permuted.coalitions <- sample( 1:4, length(orig.ids), replace = TRUE)
remapped.ids <- permuted.coalitions

    #--------------------------------------------
    # Now remap all the value in admin.units.map to the values in remapped.ids
    #--------------------------------------------



# 1st define a function that will remap the values in admin.units.map
# this will be applied to each element of admin.units.map via the apply function

perm <- function( x ){

  if( x == PAR.NODATA_value ) return(PAR.NODATA_value)
  else {
    # get the position in the original ID vector that the current value occurs at 
    indx <- which( orig.ids == x )
  
    # reutrn the remapped ID value
    return(remapped.ids[indx])
  }
}

# test code
#M <- matrix( sample( orig.ids, 25, replace = TRUE) ,5,5)
#M2 <- apply(M,c(1,2), perm )


# not the 2nd argument (c(1,2)) tell apply to apply the function
# 'perm' to each element of the matrix (as opposed to only rows or
# cols
admin.units.map.remapped <- apply( admin.units.map, c(1,2), perm )
M2 <- admin.units.map.remapped 
M <- admin.units.map


write.asc.file ( admin.units.map.remapped, PAR.remapped.admin.regions.map.filename.base, 
                 PAR.nrows, PAR.ncols, 
                 PAR.xllcorner, PAR.yllcorner,
                 PAR.NODATA_value, PAR.cellsize
                )

# note: set nodate value to zero before writing pgm
admin.units.map.remapped[ which( admin.units.map.remapped == PAR.NODATA_value )] <- 0
write.pgm.file( admin.units.map.remapped, PAR.remapped.admin.regions.map.filename.base, 
                PAR.nrows, PAR.ncols )

# write the original map to a pgm also
admin.units.map[ which( admin.units.map == PAR.NODATA_value )] <- 0
write.pgm.file( admin.units.map, PAR.admin.regions.map.filename.base, 
                PAR.nrows, PAR.ncols )
