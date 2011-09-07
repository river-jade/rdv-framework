    #-----------------------------------------------------------#
    #                                                           #
    #             make.patches.planning.units.R                 #
    #                                                           #
    #  Make a planing unit map. In this case the PUs are are    #
    #  same as the patches. This means that there will be no    #
    #  shared bourndries between patches.                       #
    #                                                           #
    #  Created Oct 2, 2006 - Ascelin Gordon                     #
    #  source( 'make.patches.planning.units.R')          #
    #                                                           #
    #-----------------------------------------------------------#

#source( 'variables.R')

source( 'w.R')


# just make a copy of the patch binaryHabitatMap.patches.txt file as the
# planning units file



#read in the file
patch.id.matrix <- as.matrix ( read.table( master.habitat.map.pid.filename ) );


# assume that all patches are sequentially numbered (ie of there are 5 patches
# the pids will be 1,2,3,4,5
# Lucy's java code creats binaryHabitatMap.patches.txt and and they are
# sequentially numbered (though spatially jumbled)
# TODO - make code to deal with it if this is not the case
# u <- unique ( as.vector ( patch.id.matrix ) )

#write the planning unit file
write.to.3.forms.of.files( patch.id.matrix, planning.units.filename.base, rows, cols );
