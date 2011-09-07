#==============================================================================
#
#                            initialise.CPW.information.R
#
#  Runs once at the start of the simulation to input all the info
#  regarding the CPW into the database
#
#  To run:
#      source( 'initialise.CPW.information.R' )
#
#
#  Create 1/12/2010 - AG.
#
#==============================================================================


rm( list = ls( all=TRUE ));


    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'utility.functions.R' )
source( 'dbms.functions.R' )      
source( 'initialise.CPW.information.functions.R' )
    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

source( 'variables.R' )

#test.initialise.using.grassland.map.and.PUs()

initialise.using.CPW.info.from.shapefile()
