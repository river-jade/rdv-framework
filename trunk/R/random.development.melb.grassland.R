# source( '../R/random.development.R' );

#rm( list = ls( all=TRUE ));

    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------


source( '../R/dbms.functions.R' );
#source( '../R/random.development.variables.R' );

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

DEBUG <- FALSE;
PUinformationDBname <- 'PUinformation.dbms';
dynamicPUinfoTableName <- 'dynamicPUinfo';

    #------------------------------------------------------------
    #  Outputs/returned
    #------------------------------------------------------------


    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------






randomly.develop.pus <- function( num.pus.to.develop, current.time.step ) {



    #------------------------------------------------------------
    # get the PUs available for loss:
    #   the PUs with OVERLAY == AVAILABLE_FOR_DEVELOPMENT the previously
    #   undeveloped and unreserved PUs)
    #------------------------------------------------------------

  query <- paste( 'select ID from ', dynamicPUinfoTableName,
                 'where RESERVED = 0 and DEVELOPED = 0 and IN_DEV_POOL = 1' );
  
  units.eligible.for.loss <- sql.get.data(PUinformationDBname, query);

  if( DEBUG ){
    cat ('\nTime step ', current.time.step, ': units.eligible.for.loss = \n');
    show (units.eligible.for.loss);
  }


  # work out how many PUs to remove  
  num.to.sample <- min (length(units.eligible.for.loss),
                        num.pus.to.develop );
  

  # if there are some PUs left to remove then do so
  if (num.to.sample > 0) {

    pus.to.remove <- sample.rdv( units.eligible.for.loss, num.to.sample);

    if(DEBUG){
      cat ('\nTime step ', current.time.step,' PUs to remove = \n');
      show ( pus.to.remove);
    }
  } else {

    # otherwiese there are no more PUs to remove
    pus.to.remove <- integer(0);
  
  }  # end/else if (num.to.sample > 0) 



    #------------------------------------------------------------
    #  Update the database 
    #------------------------------------------------------------


  if( length( pus.to.remove ) > 0 ) {

    # there are some pus to remove...
    
    # mark the PUs as developed in the database
    update.db.pu.ids.with.single.value(dynamicPUinfoTableName,
                                       pus.to.remove, 1,
                                       'DEVELOPED');

    # record the timestep that the PU was developed 
    update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                       pus.to.remove, current.time.step,
                                       'TIME_DEVELOPED');


    # record the habitat score of the PU before it was developed
    for( cur.id in pus.to.remove){

      # get the current habitat score
      query <- paste ('select TOTAL_COND_SCORE_SUM from',
                      dynamicPUinfoTableName,
                      'where ID = ', cur.id );
      cur.cond.score.sum <- sql.get.data( PUinformationDBname, query)

      # record it

      update.single.db.pu.with.single.value( dynamicPUinfoTableName, cur.id,
                                            cur.cond.score.sum,
                                            'HH_SCORE_AT_DEV_TIME' );
      
    }
    
  }  # end - if( length( pus.to.remove ) > 0 )
  
  return(pus.to.remove)
  
}



