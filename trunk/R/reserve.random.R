
    #------------------------------------------------------------
    #            reserve.random.R                               #
    #  Create a random reserve selection.                       #
    #                                                           #
    #  Created 12/5/06 - AG                                     #
    #  modified 24/07/06 - AG changed to specify the fraction   #
    #                      of patches to reserve, not the       #
    #                      absolute number                      #
    #                                                           #
    #  Inputs: cur.pid.map (patch id map for hab for at least 1 #
    #                       species)                            #
    #                                                           #
    #  Output:                                                  #
    #                                                           #
    #         - reserve.pu.map (binary map of reserved patches) #
    #                       (just for viewing)                  #
    #         - cur.pus.to.reserve  (file of PU ids)            #
    #         - pus.for.removal (file of PU ids)                #
    #                                                           #
    #    source('reserve.random.R')                        #
    #------------------------------------------------------------

rm( list = ls( all=TRUE ))

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'w.R' )
source( 'variables.R' )
source( 'utility.functions.R' )
source( 'dbms.functions.R' )
source( 'reserve.random.functions.R' )

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

# set in python....

    #------------------------------------------------------------
    #  Outputs/returned
    #------------------------------------------------------------


    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------

if (use.run.number.as.seed) {
  set.seed(random.seed)
}


cat( '\n----------------------------------' )
cat( '\nReserve Selection Method: RANDOM'   )
cat( '\n----------------------------------' )



if(  OPT.reserve.parcels.based.on.budget ) {

  cat( '\n *** Running reserve random based on a budget of', PAR.budget.for.timestep, '***' )
  
  # In this case call the old reserve.random.R code (it's in
  # reserve.random.functions.R)
  reserve.using.given.budget()

} else {

  cat( '\n *** Running reserve random based on a reserve rate of', PAR.rate.of.CPW.reserved.per.timestep,
      'ha ***' )
  
  # Otherwise assume that we're using the CPW project and will be
  # reseving CPW based an an average 'rate' per timestep

  reserve.using.specified.rate.of.CPW()

  
  
}
