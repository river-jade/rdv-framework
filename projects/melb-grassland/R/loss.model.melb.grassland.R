
# source( 'loss.model.melb.grassland.R' )

rm( list = ls( all=TRUE ))

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'w.R' )
source( 'dbms.functions.R' )
source( 'variables.R' )
source( 'random.development.melb.grassland.R' )

source( 'offset.model.melb.grassland.R' )
source( 'utility.functions.R' )

master.habitat.map.zo1.filename <-  paste( master.habitat.map.zo1.base.filename, '.txt', sep='')

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

# set in python

    #------------------------------------------------------------
    #  Outputs/returned
    #------------------------------------------------------------


    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------

initialize.partial.offset.db.values <- function ()
  {

    connect.to.database (PUinformationDBname);

      #----------
  
    query <- paste( 'insert into ', offsettingWorkingVarsTableName,
                   ' ( PARTIAL_OFFSET_IS_ACTIVE ) values (', 0, ')', 
                   sep = '');
    
    sql.send.operation (query);

    cat ("\n\nIn initialize.partial.offset.db.values(), init actions are:\n");
    cat ("\n    ", query);
  
      #----------
    CONST.UNINITIALIZED.PU.ID.VALUE <- -999;
  
    query <- paste( 'update ', offsettingWorkingVarsTableName,
                   ' set ', 'PARTIAL_OFFSET_PU_ID', ' = ', 
                   CONST.UNINITIALIZED.PU.ID.VALUE, 
                   sep = '');
    sql.send.operation (query);

    cat ("\n    ", query);
  
      #----------
  
    query <- paste( 'update ', offsettingWorkingVarsTableName,
                   ' set ', 'PARTIAL_OFFSET_SUM_SCORE_REMAINING', ' = ', 
                   0.0, 
                   sep = '');
    sql.send.operation (query);

    cat ("\n    ", query);
  
      #----------
  
    close.database.connection ();

#cat ("\n\nPausing so you can check the ",
#     offsettingWorkingVarsTableName,
#     " table for those values.\n\n",
#     sep='');
}

#------------------------------------------------------------------------------

# for now this assumes that loss units are Planning Units.
# can make PUs and patches the same if you want to have
# patches being lost.

# Note this needs to be called with current.time.step = 0.
# This initialises the time zero hab map with no loss 

#------------------------------------------------------------------------------

initialise.loss.model <- function() {

  cat( '\nIn initialise offset model' );
  
  # write out time zero hab map without any loss
  init.hab.map <- as.matrix ( read.table( master.habitat.map.zo1.filename ));

  cur.loss.model.file.name <-  paste (loss.model.root.filename,
                                 '0', sep = "");
  write.to.3.forms.of.files(init.hab.map, cur.loss.model.file.name,rows,cols);


  # also initialise the offset model if being used
  

  # this code reads in the maps dev_pool_mask.txt and
  # offset_pool_mask.txt and the calculates which PUs are in each
  # pool and sets IN_DEV_POOL IN_OFFSET_POOL values for those PUs in
  # dynamicPUinfoTableName table in the PUinformationDBname database.
  
  if( OPT.specify.development.pool.with.map |
     OPT.specify.offset.pool.with.map ) {

    # only call this code if either offset pool or development pool is
    # specified with a map
      
    source( "determine.PUs.in.offset.and.dev.pools.R" )

  }


  initialize.partial.offset.db.values ();
      

  
}  #  end - initialise.loss.model function



#------------------------------------------------------------------------------

stochastically.expire.reserve.or.management <- function( action ) {


  db.field.name <- 'DUMMY_NAME';
  
  if( action == 'RESERVED' ) 
    db.field.name <- 'PROB_RES_EXPIRING_PER_TIMESTEP';
  
  if( action == 'MANAGED' ) 
    db.field.name <- 'PROB_MAN_EXPIRING_PER_TIMESTEP';


  # get the reserves that expire this time step
  query <- paste( 'select ID,', db.field.name, 'from ', dynamicPUinfoTableName,
                 'where ', action, '= 1 and', db.field.name, ' > 0' );

  ids.and.prob.expiring <- sql.get.data(PUinformationDBname, query);


  if( length( ids.and.prob.expiring ) > 0 ) {

    ids <- ids.and.prob.expiring[,1];
    probs.of.expiring <- ids.and.prob.expiring[,2];

    test.probs <- runif( ( probs.of.expiring ), 0, 1);

    indices.that.expire <- which( probs.of.expiring < test.probs );

    ids.that.expire <- ids[indices.that.expire];
    
    # set them to unreserved. 
    # Update - if protection is expiring (action  = reserved) then
    # management should expire also. But not vice versa -  DWM 25 Nov 2009
    if( action == 'RESERVED')
    {
      update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                       ids.that.expire,
                                       0, action);
      update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                       ids.that.expire,
                                       0, 'MANAGED');
    } else {
      update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                       ids.that.expire,
                                       0, action);
    }

    cat( '\nThe following IDs had their', action, 'status expire',
        ids.that.expire, '\n' );

    
  }

  #browser();

}

#------------------------------------------------------------------------------


if( current.time.step == 0 ) {

  initialise.loss.model()


  
} else {


    #------------------------------------------------------------
    #  set any expired reserves to unreserved
    #------------------------------------------------------------


  # get the reserves that expire this time step
  query <- paste( 'select ID from ',dynamicPUinfoTableName,
                 'where RES_EXPIRY_TIME =', current.time.step);
  reserves.expiring.this.timestep <- sql.get.data(PUinformationDBname, query);

  if( length( reserves.expiring.this.timestep ) > 0 ) {
    # if there are any that expire...
    
    # set them to unreserved
    update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                       reserves.expiring.this.timestep,
                                       0, 'RESERVED');
  }

    #------------------------------------------------------------
    #  check if the reserved or managed status of any PUs 
    #  expires this time step. This is now done through the function
    #  stochastically.expire.reserve.or.management() defined above
    #------------------------------------------------------------

  
  stochastically.expire.reserve.or.management( 'RESERVED' )
  stochastically.expire.reserve.or.management( 'MANAGED' )
  
  
  # get the reserves that expire this time step
  #query <- paste( 'select ID, PROB_RES_EXPIRING_PER_TIMESTEP from ',
  #               dynamicPUinfoTableName,
  #              'where RESERVED = 1 and PROB_RES_EXPIRING_PER_TIMESTEP > 0' );
  
  #ids.and.prob.expiring <- sql.get.data(PUinformationDBname, query);


  #if( length( ids.and.prob.expiring ) > 0 ) {

    #ids <- ids.and.prob.expiring[,1];
    #probs.of.expiring <- ids.and.prob.expiring[,2];

    #test.probs <- runif( ( probs.of.expiring ), 0, 1);

    #indices.that.expire <- which( probs.of.expiring < test.probs );

    #ids.that.expire <- ids[indices.that.expire];
    
   # update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
    #                                   ids.that.expire,
     #                                  0, 'RESERVED');   
  #}

  
    #------------------------------------------------------------
    #  set any expired management of reserves to unmanaged
    #------------------------------------------------------------


  timestep.with.mgmt.expiring <- current.time.step - PAR.management.duration;
  

   #   cat( '\n timestep.with.mgmt.expiring:', timestep.with.mgmt.expiring);
   #   cat('\n');
 
   
  if( timestep.with.mgmt.expiring > 0 ) {
    
    query <- paste( 'select ID from ', dynamicPUinfoTableName,
                    'where MANAGED = 1 AND TIME_MANAGEMENT_COMMENCED <= ',
                    timestep.with.mgmt.expiring);
      
    management.expiring.this.timestep <-
      sql.get.data(PUinformationDBname, query);
  
      #  ------------------------------
      #  We may want to insert a Pr curve for management expiring here
      #  rather than the effective step function - DWM 21/09/2009
      #  ------------------------------
  
      if( length( management.expiring.this.timestep ) > 0 ) 
      {
        # if there are any that expire...
        # set them to unmanaged
        update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                           management.expiring.this.timestep,
                                           0, 'MANAGED');
      }
  }


    #------------------------------------------------------------
    #  If doing offsetting, do it now 
    #------------------------------------------------------------

  
  print('\n -----Starting offset model called from loss model \n');

  
  if( OPT.use.offsetting.in.loss.model ) {

    test.offsetting.standalone (PAR.pus.lost.per.timestep);
    
  } else {
    
    pus.developed <-
      randomly.develop.pus( PAR.pus.lost.per.timestep, current.time.step );
  }
  
  print('\n -----End offset called from loss model \n');



    #------------------------------------------------------------
    #  Calculate the new maps based on what has been lost (and
    #  possibly reserved if doing offsetting)
    #------------------------------------------------------------

  
  # read in the planning unit id map
  pu.id.map <- as.matrix ( read.table( planning.units.filename ));
  
  # Read in the master habiat map. Will alter this based on the
  # PUs lost per time step
  cur.loss.model.map <-
    as.matrix ( read.table( master.habitat.map.zo1.filename ));


  # read in the current reserved PU map

  cur.reserved.PU.map.filename.base <-
    paste (reserved.planning.units.filename.base, '.', current.time.step,
           sep="");

  cur.reserved.PU.map.filename <-
    paste(cur.reserved.PU.map.filename.base, '.txt', sep = '') 

  if( file.exists( cur.reserved.PU.map.filename ) ) {
    # if the map exists read it in
    cur.reserved.PU.map <- as.matrix(read.table(cur.reserved.PU.map.filename));
  } else {
    # there is no reserve map yet so create on

     cur.reserved.PU.map <- matrix ( 0, nrow = rows, ncol = cols ); 
  }

    # read in the current managed PU map

  cur.managed.PU.map.filename.base <-
    paste (managed.planning.units.filename.base, '.', current.time.step,
           sep="");

  cur.managed.PU.map.filename <-
    paste(cur.managed.PU.map.filename.base, '.txt', sep = '') 

  if( file.exists( cur.managed.PU.map.filename ) ) {
    # if the map exists read it in
    cur.managed.PU.map <- as.matrix(read.table(cur.managed.PU.map.filename));
  } else {
    # there is no managed map yet so create on

     cur.managed.PU.map <- matrix ( 0, nrow = rows, ncol = cols ); 
  }

  
  # determine the name to write the current maps to 
  cur.loss.model.file.name <-
    paste (loss.model.root.filename, current.time.step,sep="");

  cur.cond.model.base.file.name <- paste( cond.model.root.filename,
                                    current.time.step, sep = '' );
  
  cur.cond.model.file.name <- paste( cond.model.root.filename,
                                    current.time.step, '.txt', sep = '' );
  
  cur.cond.model.map <-
    as.matrix ( read.table( cur.cond.model.file.name ));

  #print( "\n ------Getting all unit indices from DB\n");

  
  # get the all  developed units
  query <- paste( 'select ID from ',dynamicPUinfoTableName,
                 'where DEVELOPED = 1');
  all.previously.developed.units <- sql.get.data(PUinformationDBname, query);

  # get the previously reserved units
  query <- paste( 'select ID from ',dynamicPUinfoTableName,
                 'where RESERVED = 1');
  all.previously.reserved.units <- sql.get.data(PUinformationDBname, query);
  
  # get the previously managed units
  query <- paste( 'select ID from ',dynamicPUinfoTableName,
                 'where MANAGED = 1');
  all.previously.managed.units <- sql.get.data(PUinformationDBname, query);
  
  # get the reserved + unmanaged units
  query <- paste( 'select ID from ',dynamicPUinfoTableName,
                 'where MANAGED = 0');
  all.unmanaged.units <- sql.get.data(PUinformationDBname, query);

  
  # update the PUs lost 
  for (id.of.PU.to.remove in all.previously.developed.units ) {
      
     cur.loss.model.map[ pu.id.map == id.of.PU.to.remove] <- 
        as.integer(non.habitat.indicator);

     cur.cond.model.map[ pu.id.map == id.of.PU.to.remove] <-
         as.integer(non.habitat.indicator);
  }

  # update extra PUs reserved

  for (id.of.PU.to.reserve in all.previously.reserved.units ) {
    
    cur.reserved.PU.map[ pu.id.map == id.of.PU.to.reserve] <- 1;

   }
   
   # update extra PUs managed/unmanaged

  for (id.of.PU.to.manage in all.previously.managed.units ) 
  {
    
    cur.managed.PU.map[ pu.id.map == id.of.PU.to.manage] <- 1;
    #cur.managed.PU.map[ pu.id.map != id.of.PU.to.manage] <- 0;
  }
  
  for (id.of.PU.to.unmanage in all.unmanaged.units ) 
  {
    cur.managed.PU.map[ pu.id.map == id.of.PU.to.unmanage] <- 0;
  }


  #------------------------------------------------------------
  #  write output
  #------------------------------------------------------------


  # write the loss  map.
  write.to.3.forms.of.files (cur.loss.model.map, 
                             cur.loss.model.file.name, 
	  	             rows, cols);

  # also write to
  write.to.3.forms.of.files (cur.cond.model.map,
                             cur.cond.model.base.file.name,
                             rows, cols);
  # also write to
  write.to.3.forms.of.files (cur.reserved.PU.map,
                             cur.reserved.PU.map.filename.base,
                             rows, cols);

  # also write to
  write.to.3.forms.of.files (cur.managed.PU.map,
                             cur.managed.PU.map.filename.base,
                             rows, cols);


}   # end if / else (current.time.step == 0  )


