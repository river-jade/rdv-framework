

# source( 'model.functions.R' )

find.closest.buffer.size <- function(target, b) {

    # note: assume people in each buffer are sorted in numerical order
    indices <- which( b <= target )

    # if none of the buffers are large enough take the smallest one
    if( length( indices) < 1 ) {
        final.index <- 1

    # otherwise work out which one to take    
    } else {
        
        index <- max( indices)


        # if this is the largest index the choose this
        if( index == length(b) ) {
            
            final.index <- index
        # otherwise check wither the one above is closer to the taget and if so take that one
        } else { 
        
        # see if the one above the selected index has a smaller difference
            if( abs(b[index+1] - target) < abs(b[index] - target) ) {
                final.index <- index + 1
            } else {
                final.index <- index
            }
        }
    }
    
    return( final.index ) 
}
