

stochastically.expire.reserve.or.management <- function (action) 
  {
  db.field.name <- 'DUMMY_NAME';
  
  if( action == 'RESERVED' ) 
    db.field.name <- 'PROB_RES_EXPIRING_PER_TIMESTEP';
  
  if( action == 'MANAGED' ) 
    db.field.name <- 'PROB_MAN_EXPIRING_PER_TIMESTEP';


  # get the reserves that expire this time step
  query <- paste( 'select ID,', db.field.name, 'from ', dynamicPUinfoTableName,
                 'where ', action, '= 1 and', db.field.name, ' > 0' );

  ids.and.prob.expiring <- sql.get.data(PUinformationDBname, query);


  # Windows and mac seem to handle the the case were you get an empy
  # result from a DB query. On windows integer(0) is returned, on the
  # mac a an empty data frame is returned. Thus there is now a check
  # for the result being a dataframe before the test of whether the
  # dataframe is empy. Note that an empty windows result will fail at
  # the first test. The mac retrun will fail the 2nd
  if( is.data.frame( ids.and.prob.expiring) ) {

    if( length( ids.and.prob.expiring[,1] ) > 0 ) {

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
        } else 
        {
        update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                             ids.that.expire,
                                             0, action);
        }

      if(DEBUG.OFFSETTING) cat( '\nThe following IDs had their', action, 'status expire',
                               ids.that.expire, '\n' );
      }
    }
  
  }  #  end function - stochastically.expire.reserve.or.management

#==============================================================================

# --------------------------------------------------------------------------------------


set.pu.cpw.fields.zero.in.db <- function( PU.to.dev ){
    
  cpw.db.fields <- c( 'AREA_OF_CPW', 'AREA_OF_C1_CPW', 'AREA_OF_C2_CPW', 'AREA_OF_C3_CPW',
                     'SCORE_OF_C1_CPW', 'SCORE_OF_C2_CPW', 'SCORE_OF_C3_CPW')

  for( cur.field in cpw.db.fields ) {
    update.single.db.pu.with.single.value ( dynamicPUinfoTableName,
                                           PU.to.dev,
                                           0,
                                           cur.field );
    
  }
}

# --------------------------------------------------------------------------------------
