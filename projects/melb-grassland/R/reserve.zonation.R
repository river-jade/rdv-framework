#   source( 'reserve.zonation.R' )




    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'variables.R' )
source( 'w.R' );
source( 'gen.reserved.patches.R' );


    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

#  set in python...

    #------------------------------------------------------------
    #  Outputs/returned
    #------------------------------------------------------------




    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------

# set the variable prop.of.patch.overlap, which is used in the function
# sel.res.full() below
prop.of.patch.overlap <- PAR.zonation.prop.of.patch.overlap

# note this line was changed so that this would work
# when adding the melb grassland project into the new tzar/babushka framework
# AG - 2011.11.15

#reserve.map <- 'zonation_output.rank.txt';
reserve.map <- PAR.Zonation.reserve.map

if( PAR.zonation.select.partial.patches ){
  sel.res.partial( zonation.threshold );
}else{
  sel.res.full( zonation.threshold  );
}

