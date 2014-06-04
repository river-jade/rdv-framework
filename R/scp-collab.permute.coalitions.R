
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
    # Read in the current admin file and get the IDs
    #--------------------------------------------

setwd( PAR.current.run.directory )

admin.units.map <- as.matrix(read.table( PAR.admin.regions.map.downloaded, skip=6 ))
all.unique.ids <- unique(as.vector( admin.units.map ) )
orig.ids <- sort(all.unique.ids[which( all.unique.ids != PAR.NODATA_value )])


    #--------------------------------------------
    # Permunte the IDs
    #--------------------------------------------

# For now this is just a hack that assigns each current country into one of PAR.num.coalitions4 coalitions
permuted.coalitions <- sample( 1:PAR.num.coalitions, length(orig.ids), replace = TRUE)
remapped.ids.old <- permuted.coalitions

# make a vector of randome coalitions

no.coutnries <- length(orig.ids)
sample.reps <- ceiling( no.coutnries/PAR.num.coalitions)

sampled.coals <- sample( 1:PAR.num.coalitions, length(1:PAR.num.coalitions), replace = FALSE)

# this make a vector of coalition ids to be assigned to each country
for( i in 1:(sample.reps -1) ) {
  sampled.coals <- c(sampled.coals, sample( 1:PAR.num.coalitions, length(1:PAR.num.coalitions), replace = FALSE) )
}

remapped.ids <- rep( -1, length(1:no.coutnries))

for( i in 1:no.coutnries ) {

  remapped.ids[i] <- sampled.coals[i]
  
}

    #--------------------------------------------
    # Remap all the values in admin.units.map to the values in
    # remapped.ids
    #--------------------------------------------

# 1st define a function that will remap the values in admin.units.map
# this will be applied to each element of admin.units.map via the apply function

perm <- function( x ){

  if( x == PAR.NODATA_value ) return( PAR.NODATA_value )
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

   # Note the 2nd argument (c(1,2)) tells the apply function to apply
   # the function 'perm' to each element of the matrix (as opposed to
   # only rows or columns).

admin.units.map.remapped <- apply( admin.units.map, c(1,2), perm )

    #--------------------------------------------
    # write outputs
    #--------------------------------------------


# write out the mapping of orig IDs to remapped IDs.
write.table( cbind(orig.ids, remapped.ids), file=PAR.admin.regions.id.mapping.filename,
            row.names = FALSE, quote=FALSE)


write.asc.file( admin.units.map.remapped, PAR.remapped.admin.regions.map.filename.base, 
                PAR.nrows, PAR.ncols, 
                PAR.xllcorner, PAR.yllcorner,
                PAR.NODATA_value, PAR.cellsize
                )

# Note: set nodata value to zero before writing pgm
admin.units.map.remapped[ which( admin.units.map.remapped == PAR.NODATA_value )] <- 0
write.pgm.file( admin.units.map.remapped, PAR.remapped.admin.regions.map.filename.base, 
                PAR.nrows, PAR.ncols )

# write the original map to a pgm also
admin.units.map[ which( admin.units.map == PAR.NODATA_value )] <- 0
write.pgm.file( admin.units.map, PAR.admin.regions.map.filename.base, 
                PAR.nrows, PAR.ncols )


cat( '\n' )
