
reserve.using.specified.rate.of.CPW <- function() {

      #--------------------------------------------------------------------
      #  First define the sequence of quiries to be made to search for
      #  available parcels. This may need to be moved in the CPW
      #  project yaml file at some stage.
      #--------------------------------------------------------------------
  
  # These PAR... variables are now set in the yaml file
  criteria.vec <- c(PAR.random.reserve.criteria.1, PAR.random.reserve.criteria.2 )


      #----------------------------------------------------------
      #  First check whether the file
      #  PAR.reserve.random.tmp.info.filename exists. If it does
      #  reinstate the dataframe from there. Otherwise this must be
      #  the first time this code is called so create the dataframe.
      #----------------------------------------------------------

  if ( file.exists ( PAR.reserve.random.tmp.info.filename ) ) {

    # Source this file to reinstate the dataframe containing info from last time    
    source( PAR.reserve.random.tmp.info.filename )
    
  } else {

    # Create the dataframe as this must be the first time the code is called
    persistent.info.df <- data.frame( carry.over.PU.id = -999, area.of.CPW.for.carry.over.PU = 0,
                                     cum.area.reserved.so.far = 0 )
    
  }


      #----------------------------------------------------------
      # First check whether the target amount of CPW has already been
      # reserved
      # ----------------------------------------------------------

  if( persistent.info.df$cum.area.reserved.so.far > PAR.limit.for.random.reserves ) {

    # In this case the target for reserve area has been already been meet
    cat( '\nThe target of', PAR.limit.for.random.reserves,
        'has already been met, so no more parcels will be reserved.' )

    # In this case don't need to write any info to file as want the
    # same info as was aviable this time step to be used next time
    # step
    return( FALSE )
  
    
  }

  
      #----------------------------------------------------------
      # Calculate the amount of CPW that we would expect to have been
      # reserved using the ramdon method by the end of this time step
      # ----------------------------------------------------------

  CPW.cumulative.area.reserved.target <- current.time.step * PAR.rate.of.CPW.reserved.per.timestep

  if(DEBUG) cat( '\nCPW.cumulative.area.reserved.target for timestep', current.time.step, '=',
                CPW.cumulative.area.reserved.target)

  
      #------------------------------------------------
      #  Query the database to get info about the
      #  parcels available to be reserved
      #------------------------------------------------

  available.PUs <- integer(0)
  ctr <- 1
  nothing.to.reserve <- FALSE

  # Loop through the criteria until to see if there are any parcels that meet them
  while( selection.not.empty(available.PUs) == FALSE & ctr <= length(criteria.vec) ) {
    
    query <- paste( 'select ID, AREA_OF_CPW, AREA_OF_C1_CPW, AREA_OF_C2_CPW from',
                   dynamicPUinfoTableName, 'where', criteria.vec[ctr] )
    
    if(DEBUG) cat( '\n\nAbout to execute query:', query )

    available.PUs <- sql.get.data( PUinformationDBname, query)

    if(DEBUG) { cat( '\nThe result is:\n' ); show( available.PUs ) }

    ctr <- ctr + 1

    # Flag the fact if there was nothing to develope
    if( ctr > length(criteria.vec) & selection.not.empty(available.PUs) == FALSE ) nothing.to.reserve <- TRUE
    
  }

  
      #------------------------------------------------
      #  Check to make sure there were parcels avaiable to be 
      #  reserved
      #------------------------------------------------

  if( nothing.to.reserve ) {
    
    # In this case there was nothing avialble to be reserved so return
    cat( '\nNo parclels matching any reserve criteria. Nothing will be reserved this time step.' )

    # In this case don't need to write any info to file as wont the
    # same info as was aviable this time step to be used next time
    # step
    return( FALSE )
    
  }
  
  # Otherwise there were parcels avaiable to be reserved so contiune...

  #--------------------------------------------------------------------------------------------------
  
      #------------------------------------------------------------
      #  Loop through the available parcels adding them until you
      #  reach the parcels that takes you over the limit There will
      #  then be a 50-50 chance as to whether this parcel is selected
      #  now or added at the start of the next timestep
      #-------------------------------------------------------------


  area.of.cpw.vec <- available.PUs$AREA_OF_CPW
  PU.id.vec <- available.PUs$ID
  
  # make a vector containing the randomly selected indices of the parcles to attempt to reserve
  indices.to.reserve <- sample( 1:length(PU.id.vec), length(PU.id.vec) )

  if(DEBUG) cat( '\n The indicies of parcels to potentially reserve:', indices.to.reserve, 'and IDs =',
                PU.id.vec[indices.to.reserve], '\n\n' )
  if(DEBUG) cat( '\n There was already', persistent.info.df$cum.area.reserved.so.far, 'ha of CPW reserved' )
  
  cum.CPW.reserved <- persistent.info.df$cum.area.reserved.so.far

  
  #--------------------------------------------------------------------------------------------------



      #------------------------------------------------------------
      #  Deal with the case that there was a parcel left over from
      #  last time that needs to the first canditdate to be reserved.
      #-------------------------------------------------------------

  carryover <- FALSE
  if( persistent.info.df$carry.over.PU.id > 0 ) {

    # In this case there was a parcel from last time that needs to be reserved
    if(DEBUG) cat( '\n\n*****There was a parcels flagged from last time that needs to be reserved 1st.\n' )
    if(DEBUG) cat( '\n**** ID=', persistent.info.df$carry.over.PU.id, 'area of CPW=',
                  persistent.info.df$area.of.CPW.for.carry.over.PU )

    # Check whether the parcel us still available

    # First check that it hasn't been developed in the meantime
    query <- paste( 'select developed from', dynamicPUinfoTableName, 'where ID =',
                   persistent.info.df$carry.over.PU.id )
    developed <- sql.get.data( PUinformationDBname, query)

    # Second check that it hasn't been reserved in the meantime
    query <- paste( 'select reserved from', dynamicPUinfoTableName, 'where ID =',
                   persistent.info.df$carry.over.PU.id )
    reserved <- sql.get.data( PUinformationDBname, query)

    if( (!developed) & (!reserved) ) {                 # if the parcel wasn't or reserved developed...
      
      carryover <- TRUE

      # Add this parcel as the first element of the parcels to reserve vectors so that it
      # will attempt to be reserved first. 

      # Add a "1" to the start of the indices.to.reserve, and increment all the remianing indices by 1
      indices.to.reserve <- c(1, indices.to.reserve + 1)
      PU.id.vec <- c( persistent.info.df$carry.over.PU.id, PU.id.vec )
      area.of.cpw.vec <- c(persistent.info.df$area.of.CPW.for.carry.over.PU, area.of.cpw.vec)
    
    }
  }
  #--------------------------------------------------------------------------------------------------
    
  if(DEBUG & carryover) cat( '  -- (Note: need to subtract 1 of index to compare with list above due',
                            'to the carryover parcel being added to the start of the vector)' )

  for( cur.index in indices.to.reserve ) {

    cum.CPW.reserved <- cum.CPW.reserved + area.of.cpw.vec[cur.index]
    
    if(DEBUG) cat( '\n Current index=', cur.index, 'running tot of CPW=', cum.CPW.reserved )

    not.passed.limit.from.random.reserves <- TRUE
    if( (PAR.limit.for.random.reserves > 0)  & (cum.CPW.reserved > PAR.limit.for.random.reserves) ) {
      not.passed.limit.from.random.reserves <- FALSE
    }
    
    if( (cum.CPW.reserved < CPW.cumulative.area.reserved.target) & (not.passed.limit.from.random.reserves)) {

      # In this case we're under the target so mark this PU as reserved
      if(DEBUG) cat( '\n   Parcel ID', PU.id.vec[cur.index], 'will be reserved' )

      # Mark the current parcel as reserved in the db
      reserve.curr.PU( PU.id.vec[cur.index] )
      
    } else {

      # This PU takes us over the limit so we need to roll the dice to
      # see if it's reserved this timestep or next
      if(DEBUG) cat( '\n\n   Went over limit with parcel ID=', PU.id.vec[cur.index] )
      
      if( runif(1)  < 0.5 ) {

        # In this case we'll reserve the parcel and record the running total of CPW reserved
        if(DEBUG) cat( '\n  Parcel will be reserved' )
        
        # Mark the parcel as reserved in the db
         reserve.curr.PU( PU.id.vec[cur.index] )
        
        persistent.info.df$cum.area.reserved.so.far <- cum.CPW.reserved 
        persistent.info.df$carry.over.PU.id <- -999
        persistent.info.df$area.of.CPW.for.carry.over.PU <- 0
        
      } else {
        
        if(DEBUG) cat( '\n  Parcel will be marked as reserved first next time step' )
        
        # Otherwise we'll leave this parcel to reserved next time step
        persistent.info.df$carry.over.PU.id <- PU.id.vec[cur.index]

        # Don't include the current parcels CPW in the running total
        persistent.info.df$cum.area.reserved.so.far <-
          cum.CPW.reserved - area.of.cpw.vec[cur.index]

        # Persist the area of CPW for the parcel to be reserved next time step
        persistent.info.df$area.of.CPW.for.carry.over.PU <- area.of.cpw.vec[cur.index]
        
      }
      
      # Dump info to file that will be used next timestep
      dump( "persistent.info.df", file =  PAR.reserve.random.tmp.info.filename)
      
      # now that the limit has been exceeded we need to break out of the loop
      break()
      
    } # end - if/else (cum.CPW.reserved < CPW.cur.area.reserved.target)

  } # end - for( cur.index in indices.to.reserve )
  

}

#------------------------------------------------------------------------------------------

reserve.using.given.budget <- function() {
  
  planning.units.filename <- paste(planning.units.filename.base, '.txt',sep='');



                                        # read in the PU id map
  cur.pid.map <- as.matrix( read.table( planning.units.filename ) );

  # get the unique  PU ids from the database
  query <- paste( "select ID from", dynamicPUinfoTableName );
  unique.sorted.pu.ids <- sql.get.data(PUinformationDBname , query);

  tot.num.of.pus <- length( unique.sorted.pu.ids );

  # define a reserve map with all values set to zero
  reserve.pu.map <- cur.pid.map;
  reserve.pu.map[,] <- as.integer(0);

  if(DEBUG){
    cat('\nInitial PUs are:');
    show(unique.sorted.pu.ids);
  }

 # get the PU costs and IDs from the database
 # this will return a matrix with two columns
 # <PU_id> <cost> <management cost>

  query <- paste( "select ID, COST, MANAGEMENT_COST from ",
                 dynamicPUinfoTableName );

  pu.costs <- sql.get.data(PUinformationDBname , query);


                                        # consistency check
  if( length( pu.costs[,1]) != tot.num.of.pus ){
    cat( '\nERROR: length( pu.costs)!= tot.num.of.pus!')
    stop( 'Aborted due to error in input.', call. = FALSE );
  }

                                  # get the previously reserved PUs
  query <- paste( "select ID from ",dynamicPUinfoTableName,"where RESERVED = 1");
  priev.reserved.pus <- sql.get.data(PUinformationDBname , query);

  # get the available PUs from the database. These are the PUs that have
  # RESERVED = 0 and LANDUSE = "UNDEVELOPED" in the PU info database
  # also include the condition that TOTAL_COND_SCORE_SUM > 0, which
  # ensures that parcels with no grassland and not picked as reserves
  query <- paste( 'select ID from ', dynamicPUinfoTableName,
                 'where RESERVED = 0 and DEVELOPED = 0 and TOTAL_COND_SCORE_SUM > 0');

  available.pus <- sql.get.data(PUinformationDBname, query);


                                        # make a random list of to select from
  if( length( available.pus) > 0 ) {
    random.list.of.available.pus <- sample.rdv( available.pus,length(available.pus));
  } else {
    random.list.of.available.pus <- integer(0);
  }


  cat( '\nWill spend a budget of ',PAR.budget.for.timestep,'in reserving PUs\n');


                                        #------------------------------------------------------------
                                        #  Work out the costs of each PU
                                        #  If it's private management then it's only the management
                                        #  cost for the time period
                                        #  otherwise it's the cost of buying it + the management cost
                                        #------------------------------------------------------------


                                        #pu.purchase.cost.vec <- pu.costs[,2];
                                        #pu.management.cost.vec <- pu.costs[,3];



                                        # Make the management and purchase cost vectors so that they are the
                                        # costs associated with the random selection of PUs. I.e. entry 2,
                                        # shows the cost of the PU specified in entry 2 of
                                        # random.list.of.available.pus

  if( length( random.list.of.available.pus ) > 0 ) {

                                        # make a vector of the right length to be filled
    pu.purchase.cost.vec <- rep( -1, length( random.list.of.available.pus ));
    pu.management.cost.vec <- rep( -1, length( random.list.of.available.pus));

    ctr <- 0;

    for( cur.pu in random.list.of.available.pus ) {
      
      ctr <- ctr + 1;
      pu.index <- which ( pu.costs[,1]  == cur.pu );

      current.purchase.cost <-  pu.costs[ pu.index, 2];
      current.management.cost <- pu.costs[ pu.index, 3];
      
      pu.purchase.cost.vec[ctr] <- current.purchase.cost;
      pu.management.cost.vec[ctr] <- current.management.cost;

    }

  } else {

    pu.purchase.cost.vec <- integer(0)
    pu.management.cost.vec <- integer(0)

  }


  if( OPT.action.type == OPT.VAL.public.reserve ) {

                                        # Adding a hack here to be able to specify different management
                                        # costs for public and private conservation. Will leave the default
                                        # setting to be the private management setting and will set the
                                        # public managment cost to be a smaller value by multiplying all
                                        # managment costs by a reduction value. Thus the cost of managing
                                        # existing and new parcels will be reduced by this factor.
    
                                        # The plan is to set private management at $0.03/m^2 ($300/ha) and
                                        # public management to be $0.01/m^2 ($100/ha). Thus the conversion
                                        # factor will be 0.333333 to that 300 * 0.3333 = 100

                                        #priv.to.pub.conv.factor <- 0.3333333
    priv.to.pub.conv.factor <- 1

    
                                        # in this case add the cost of purchasing the property and managing
                                        # it for the next timestep

    pu.cost.vec <- pu.purchase.cost.vec +
      step.interval * pu.management.cost.vec * priv.to.pub.conv.factor;


                                        # now get the cost of managing all existing reserves
    
    query <- paste( 'select MANAGEMENT_COST from', dynamicPUinfoTableName,
                   'where RESERVED = 1 and RESERVE_TYPE =',
                   OPT.VAL.public.reserve );
    
    
    mgmt.costs.of.exisiting.reserves <- sql.get.data(PUinformationDBname,query);
    
    tot.cost.of.managing.existing.reserves <-
      sum(mgmt.costs.of.exisiting.reserves)*step.interval*priv.to.pub.conv.factor;
    
  } else {

    if( OPT.action.type == OPT.VAL.private.management ) {
      
                                        # in this case just include the cost managing it for the management period 
                                        # specified by PAR.reserve.duration
      pu.cost.vec <- pu.management.cost.vec * PAR.reserve.duration;
      
      tot.cost.of.managing.existing.reserves <- 0;
      
    } else {
      cat( '\nError unknown OPT.action.type. [OPT.action.type =',
          OPT.action.type, ']' );
      stop();
    }
  }

                                        #------------------------------------------------------------
                                        #  Do a greedy selection of PUs that meet budget 
                                        #------------------------------------------------------------


  budget <- PAR.budget.for.timestep - tot.cost.of.managing.existing.reserves;

  if( length( random.list.of.available.pus)> 0 &  budget > 0 ) {
    
    cur.pus.to.reserve <-
      greedy.selection.of.PUs( random.list.of.available.pus, pu.cost.vec,
                              budget );
    
  } else {
    
    cur.pus.to.reserve <-integer(0);
    
  }


  num.of.pus.to.reserve <- length( cur.pus.to.reserve);


                                        # work out the total reserved PUs by adding the prieviously reserved
                                        # PUs to the currently reserved ones
  all.reserved.pus <- sort( c(cur.pus.to.reserve, priev.reserved.pus) );


                                        # create the map of reserved patches and work out total reserved area
  total.reserved.area <- as.integer( 0 );

  for ( pu.id in all.reserved.pus ) {
    
    pu.area <- length( cur.pid.map [ cur.pid.map  == pu.id ] );
    total.reserved.area <- total.reserved.area + pu.area;
    
    reserve.pu.map[cur.pid.map == pu.id] <- as.integer( 1 );
    
  }


                                        # ---------
                                        # WRITE OUTPUT FILES
                                        # ---------


                                        # determine the name to write the current reserve map to 
  cur.reserve.map.name.base <-
    paste (reserved.planning.units.filename.base, '.', current.time.step,sep="");

  
  write.pgm.txt.files( reserve.pu.map,
                      reserved.planning.units.filename.base,
                      rows, cols );
  write.pgm.txt.files( reserve.pu.map,
                      cur.reserve.map.name.base,
                      rows, cols );

                                        # Create managed PU map and planning units - at this time step
                                        # it's identical to the reserved map

  managed.pu.map <- reserve.pu.map;

  write.pgm.txt.files( managed.pu.map,
                      managed.planning.units.filename.base,
                      rows, cols );


                                        #------------------------------------------------------------
                                        #  Update the database 
                                        #------------------------------------------------------------

                                        # PU reserve status

  if( length( cur.pus.to.reserve ) > 0 ) {
    
                                        # there were some pus to reserve in this time step...
    
                                        # update the database
    update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                       cur.pus.to.reserve, 1, 'RESERVED');
    
    update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                       cur.pus.to.reserve, 1, 'MANAGED');
    
                                        # PU timestep reserved
    update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                       cur.pus.to.reserve, current.time.step,
                                       'TIME_RESERVED');


                                        # set the exiry time for the reserves
    reserve.expiry.time <- current.time.step + PAR.reserve.duration;

    update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                       cur.pus.to.reserve,
                                       reserve.expiry.time,
                                       'RES_EXPIRY_TIME');

                                        # set the RESERVE_TYPE
    update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                       cur.pus.to.reserve,
                                       OPT.action.type,
                                       'RESERVE_TYPE');
    

  }


  cat( '\nFinished reserve selection.' );
  cat( '\n - PUs reserved this timestpe  = ', num.of.pus.to.reserve  );
  cat( '\n - Total area reserved = ', total.reserved.area , 'Pixels');
  cat( '\n - PU ids reserved in this timestep = ', cur.pus.to.reserve );
  cat( '\n - All reserved PUs  = ', all.reserved.pus, '\n' );

  cat( '\n' );

                                        #cat( num.of.pus.to.reserve, total.reserved.area, '\n',
                                        #    file = reserve.info.file  );



}



reserve.curr.PU <- function( PU.to.reserve ) {

  cat( '\n Marking PU=', PU.to.reserve, 'as reserved in the database' )

  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.reserve,
                                         current.time.step,
                                         'TIME_RESERVED');
    
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.reserve,
                                         1,
                                         "RESERVED");
  
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.reserve,
                                         1,
                                         "MANAGED");
      
                                        
  update.single.db.pu.with.single.value (dynamicPUinfoTableName,
                                         PU.to.reserve,
                                         current.time.step,
                                         'TIME_MANAGEMENT_COMMENCED');

}
