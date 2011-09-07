
    #------------------------------------------------------------
    #            assign.patch.ids.to.single.pixels.R
    #
    #  Assigns a separate patch id to every habitat pixel.
    #
    #  The new pixel IDs are consecutive within original patch 
    #  IDs.  For example, original patch 6 might have new pixel 
    #  IDs for the pixels within it with values 21 22 23 24.
    #  This is not strictly necessary, but might be useful 
    #  diagnostic information downstream.
    #
    #  Created 4/12/06 - BTL.
    #  Modified 4/24/06 - AG
    #  to run: source( 'assign.patch.ids.to.single.pixels.R' )
    #                                    
    #------------------------------------------------------------





#non.habitat.indicator <- 0

#  Create a test matrix.
#a <- matrix( sample( c(0,1,2,3,4),15,replace=TRUE), 3)
#cat ('\na = ');
#show (a)

	#  Simple version
### c <- a
### b<-which(a!=0)
### cat ('\nb = ');
### show(b)
### c[b] <- 1:length(b)
### cat ('\nc = ');
### show (c)
	#  End of simple version

file.copy( 'binaryHabitatMap.patches.txt',
          'binaryHabitatMap.patches.orig.txt', overwrite = TRUE )
file.copy( 'binaryHabitatMap.patches.pgm',
          'binaryHabitatMap.patches.orig.pgm', overwrite = TRUE )

orig.patch.map <- as.matrix ( read.table( 'binaryHabitatMap.patches.txt' ) )
new.patch.map <- orig.patch.map


#cat ('\nd = '); show (d)

u <- sort (unique(as.vector(orig.patch.map)))

#get rid of the values for non habitat
unique.patch.ids <- u[u != non.habitat.indicator ]

#cat ('\n unique patch ids: u = ');
#show( unique.patch.ids )

tot.id.ct <- 0;
cur.start.id <- 1;


for( i in unique.patch.ids ) {
  
  cat( '\n\nfor patch id = ')
  show( i )
  
  cur.patch.size <- length( orig.patch.map[ orig.patch.map==i ] )
  #cat ('\ncur.patch.size = '); show(cur.patch.size)

  tot.id.ct <- tot.id.ct + cur.patch.size;
  #cat ('tot.id.ct = '); show(tot.id.ct)

  #cat ('cur.start.id = '); show(cur.start.id)

  cur.end.id <- tot.id.ct;
  #cat ('cur.end.id = '); show(cur.end.id)

  new.patch.i.pixel.patch.IDs <- seq( cur.start.id, cur.end.id )
  #cat(paste ('New pixel patch IDs for patch', i, '=' )); show (new.patch.i.pixel.patch.IDs)

  patch.i.locs <- which( orig.patch.map==i );
  #cat ('Locations of pixels for patch', i, '='); show( patch.i.locs )

  if( length( patch.i.locs ) == length(patch.i.locs) ) {
    new.patch.map[patch.i.locs] <- new.patch.i.pixel.patch.IDs
    #cat ('\nd after replacing patch', i, ' = \n'); show( new.patch.map )
  } else {
    
    print( "ERROR renumbering pixels in each patch:" )
    print( "length( patch.i.locs ) != length(patch.i.locs)" )
  }
   
  cur.start.id <- cur.end.id + 1;
  
}

#cat ('\n\nOriginal array = \n'); show( a )
#cat ('\n\nfinal array = \n'); show( new.patch.map )

write.to.3.forms.of.files( new.patch.map, "binaryHabitatMap.patches", rows, cols )
