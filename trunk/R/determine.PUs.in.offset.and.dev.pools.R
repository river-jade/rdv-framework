
    #------------------------------------------------------------
    #      determine.PUs.in.offset.and.dev.pools.R              #
    #                                                           #
    #  Find the PUs that overlap the areas in the development   #
    # pool and in the offset pool. Note it's expected that the  # 
    # maps for the offset pool and development pool are 0/1     #
    # maps where a pixel value of 1 indicates that the pixel is #
    # in a given 'pool'.                                        #
    #                                                           #
    # Note: this code is called from loss.model.R and has all   #
    # the variables needed are defined in loss.model.R.         #
    #                                                           #
    #                                                           #
    #  Created 16 June 2009 - AG                                #
    #                                                           #
    #------------------------------------------------------------


    # to run:
    # source( "determine.PUs.in.offset.and.dev.pools.R" )

    #------------------------------------------------------------
    #  Note all variables need and R code are set in loss.model.R
    # 
    #------------------------------------------------------------


cat( '\nInitialising the offset model' );



    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

       
    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------


# read in the maps
if( OPT.specify.development.pool.with.map ) {
  
  dev.pool.map.filename <- PAR.development.pool.map.filename;

  development.pool.map <- as.matrix( read.table(dev.pool.map.filename ) );
}


if( OPT.specify.offset.pool.with.map ) {

  offset.pool.map.filename <- PAR.offset.pool.map.filename

  offset.pool.map <- as.matrix(read.table(offset.pool.map.filename ) );
}


pu.map <- as.matrix( read.table(planning.units.filename) );


# get the unique pu ids

unique.ids <-
  get.unique.ids.from.map( planning.units.filename, non.habitat.indicator)


# set up vectors to hold the PUs in the different pools

pus.in.development.pool <- rep( -999, len = length( unique.ids) );
pus.in.offset.pool <- rep( -999, len = length( unique.ids) );

# find the PUs that overlap the areas in the development pool and in
# the offset pool. 

pu.ctr <- 0;

for( cur.pu in unique.ids ) {

  pu.ctr <- pu.ctr + 1;
  
  # get the indices of the current PU
  cur.pu.indices <- which( pu.map == cur.pu ) 
  

  # get the values of the pixels of the loss mask at these locations

  if( OPT.specify.development.pool.with.map ) {

    development.pool.values <- development.pool.map[ cur.pu.indices ]
  
    if( max(development.pool.values) == 1   ) {
    
      # then the PU is in the area where it can be lost
      pus.in.development.pool[ pu.ctr ] <- cur.pu;
    
    }
  }

  
  if( OPT.specify.offset.pool.with.map ) {

    offset.pool.values <- offset.pool.map[ cur.pu.indices ]

    if( max( offset.pool.values ) == 1 ) {

      pus.in.offset.pool[ pu.ctr ] <- cur.pu;

    }
  }

  #browser();
}


# remove all the -999s that were in the initial vectors to just have a
# vector of planning units

pus.in.development.pool2 <-
  pus.in.development.pool[ which(pus.in.development.pool != -999) ];

pus.in.offset.pool2 <-
  pus.in.offset.pool[ which(pus.in.offset.pool != -999) ];




    #------------------------------------------------------------
    #  Write outputs
    #------------------------------------------------------------


cat( '\n Updating the database with PUs in dev and offset pool' );



if( OPT.specify.offset.pool.with.map ) {

  update.db.pu.ids.with.single.value(dynamicPUinfoTableName,
                                     unique.ids,
                                     0, 'IN_OFFSET_POOL' );
  
  update.db.pu.ids.with.single.value(dynamicPUinfoTableName,
                                     pus.in.offset.pool2,
                                     1, 'IN_OFFSET_POOL' );

}


if( OPT.specify.development.pool.with.map ) {

  update.db.pu.ids.with.single.value(dynamicPUinfoTableName,
                                     unique.ids,
                                     0,'IN_DEV_POOL' );


  update.db.pu.ids.with.single.value(dynamicPUinfoTableName,
                                     pus.in.development.pool2,
                                     1,'IN_DEV_POOL' );

}



write.table( pus.in.development.pool2,
            PAR.pus.in.dev.pool,
            row.names = FALSE, col.names = FALSE);

write.table( pus.in.offset.pool2,
            PAR.pus.in.offset.pool,
            row.names = FALSE, col.names = FALSE);

    #------------------------------------------------------------
    #  Now check whether there were any PUs are in both the
    #  offset and development pools. If they are in both the
    #  set IN_OFFSET_POOL to 0 so it will only be in the DEV_POOL
    #------------------------------------------------------------




query <- paste( 'select ID from ', dynamicPUinfoTableName,
               'where IN_DEV_POOL = 1 and IN_OFFSET_POOL = 1' ); 

ids.in.dev.and.offset.pools <- sql.get.data(PUinformationDBname, query);

cat( '\n The ids of Pus in both pools are: ' , ids.in.dev.and.offset.pools );

if( length( ids.in.dev.and.offset.pools ) > 0 ) {

  # set IN_OFFSET_POOL to zero for these PUs.

  update.db.pu.ids.with.single.value( dynamicPUinfoTableName,
                                     ids.in.dev.and.offset.pools,
                                     0, "IN_OFFSET_POOL");


}
