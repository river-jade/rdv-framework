
library( maptools )

source( 'gis.utility.functions.R' )


# read in the first shape file to get the dimensions of the shape file
buff.df <- extract.shape.file.attribute.table.to.data.frame (p$buff1)

# get the number of cites
no.cities <- length(buff.df$AREA); cat( '\nThere are', no.cities, ' cities' )

# get the names of the cites
city.names <- as.character(buff.df$SUA_NAME);  #cat( '\nThe city names are', city.names )

# get the population sizes of each city 
pop.sizes <- buff.df$POP
    # to have random sizes use: round( runif( no.cities, min=1000, max=4e5), 0)

#cat( 'the pop sizes are:', pop.sizes )
#stop()

# remove the spaces in the cite names
city.names <- gsub( '\\s', '', city.names )

# define an empty dataframe to hold all the buffer lengths for each city
buffs <- data.frame( matrix (ncol=no.cities,  nrow=length(buff.lengths) ) )

colnames(buffs) <- city.names
rownames(buffs) <- buff.lengths


# If using a cached result then read that in
if( p$OPT.use.buff.cache ) {
    source( p$buff.cache )
   
} else {

    # Otherwise, loop through and fill in the dataframe with the results from
    # each of the buffer shape files

    for( i in 1:length(buff.lengths) ) {
    
        filename <- paste( 'input_data/buffers/b', buff.lengths[i], '.shp', sep='' )
        cat( '\n Reading in file: ', filename, ' (buffer length: ', buff.lengths[i], 'm)', sep='' )
        
        cur.buff <- extract.shape.file.attribute.table.to.data.frame( filename )    
        buffs[i,] <- cur.buff$AREA
        
    }

    #cat( '\nhead of buffs is')
    #show(head(buffs) )

}

dump('buffs', p$output.filename.buff.areas )

