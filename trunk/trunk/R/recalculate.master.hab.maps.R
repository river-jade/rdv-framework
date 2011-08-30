

    #-----------------------------------------------------------#
    #            recalculate.master.hab.maps.R                  #
    #                                                           #
    #  This file does two things:                               #
    #    1. Takes the original master zero or 1 master habitat  #
    #       file and renames it to have 'orig' in the filename  #
    #                                                           #
    #    2 Takes the patch id map created by Lucy's java code   #
    #      and recreates the zero or 1 master habitat maps      #
    #                                                           #
    #  This is necessary because of the patch size thresholding #
    #  that the java code does. Ie depending on the settings in #
    #  rdv.config, it might remove patches greater or less than #
    #  a given size. We then want the zero or 1 habitat map to  #
    #  reflect this                                             #
    #                                                           #
    #  Input: the patch id map from Lucy's code                 #
    #                                                           #
    #  Output:                                                  #
    #         - renames the original zo1 master hab maps        #
    #         - recreated the z01 master  hab maps based in     #
    #           the patch id map                                #
    #                                                           #
    # source( 'recalculate.master.hab.maps.R' );         #
    #                                                           #
    #-----------------------------------------------------------#
    #                                                           #
    #  - Created 08/09/07 - AG                                  #
    #  - 03/03/07 - BTL                                         #
    #    Replaced all z01's with zo1's.                         #
    #    Converted to run under python.                         #
    #                                                           #
    #-----------------------------------------------------------#

source( 'variables.R' );
source ('w.R');


# move the the original master hab map [.txt, .pgm, .asc] files to have
# 'orig' in the filename
                                        
old.filename <- master.habitat.map.zo1.base.filename
new.filename <- paste( master.habitat.map.zo1.base.filename, '.orig',sep = '');

file.extension.vec <- c( '.txt', '.asc', '.pgm');

for( extn in file.extension.vec ) {

  file.rename( paste( old.filename, extn, sep = ''),
               paste( new.filename, extn, sep = '') );
  
}


# now make the new hab.map.master.zo1 from the patch id map created by Lucy's
# code

# read in pid map
map <- as.matrix( read.table( master.habitat.map.pid.filename ) );

# recreate the hab.map.master.zo1 files by setting all pixels that
# do not equal non.habitat.indicator to 1.
map[ map != non.habitat.indicator ] <- 1;

write.to.3.forms.of.files( map, master.habitat.map.zo1.base.filename, rows,
                          cols);
