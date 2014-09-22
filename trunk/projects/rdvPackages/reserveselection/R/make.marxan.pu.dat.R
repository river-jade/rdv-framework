#===============================================================================

make.marxan.pu.dat <-
    function (planning.units.filename,
              non.habitat.indicator,
              patch.attributes.file,
                    pu.area.and.cost.APP.filename,
              PAR.Marxan2.input.dir,
              OPT.use.marxan.with.multiple.actors,
                    OPT.use.cost.in.marxan,
                    current.planning.unit  #  temp idx in for loop
              )
        {
  # make.marxan.pu.dat<-function(planning.units.filename,
  #                              non.habitat.indicator,
  #                              patch.attributes.file,
  #                              OPT.use.marxan.with.multiple.actors,
  #                              PAR.Marxan2.input.dir
  # ){

      # e.g. make.marxan.pu.dat(planning.units.filename,non.habitat.indicator, patch.attributes.file,OPT.use.marxan.with.multiple.actors,PAR.Marxan2.input.dir)

      #
      #  Make the 'pu.dat' file for marxan (formaly pustat.dat, cost.dat and puxy.dat)
      #
      #  The 'pu.da't file is made of the following columns
      #   id, cost, status, xloc, yloc
      #  However the reserve design algorithmn only makes use of the following columns
      #   id, cost, status
      #
      #  id -  Planning Unit ID. A unique numerical identifier for each planning unit.
      #
      #  cost - Planning Unit Cost. The cost of including each p{lanning unit in the
      #        reserve system. The value entered for this variable will be the amount
      #        added to the objective function (see Section 1.5) when that planning
      #        unit is included in the reserve system.
      #
      #  status -  Planning Unit Status. This variable defines whether a planning
      #         unit (PU) is locked in or out of the initial and final reserve systems.
      #         It can take one of four values:
      #
      #            Status 0 - The planning unit is not guaranteed to be in the
      #	        initial or 'seed' portfolio. However it still may be. Its
      #	        chance of being included in the initial portfolio is
      #	        exactly the 'starting proportion' from input.dat.  ##
      #
      #	        Status 1 The planning unit will be included in the 'seed'
      #	        portfolio or the initial portfolio. It may or may not be in
      #	        the final portfolio.  #####
      #
      #	        Status 2 The planning unit is fixed in the portfolio. It
      #	        starts in the initial portfolio and cannot be removed.
      #
      #	        Status 3 The planning unit is fixed outside of the
      #	        portfolio. It is not included in the initial portfolio and
      #	        cannot be added.
      #
      #      For now set the staus of all PU status to 0

      #first read in the files the will be needed.
      pu.matrix  <- as.matrix ( read.table(planning.units.filename) );
      pu.matrix <- pu.matrix[ pu.matrix != non.habitat.indicator ]
      planning.units.vector <- sort( unique( as.vector ( pu.matrix )));
      tot.num.planning.units <- length( planning.units.vector );

      #read in the patch attributes file
      patch.attributes <- as.matrix ( read.table( patch.attributes.file ) );

      pu.area.and.cost <- read.table( pu.area.and.cost.APP.filename );

      pu.filename<-paste(PAR.Marxan2.input.dir, "pu.dat", sep="")

      if( !OPT.use.marxan.with.multiple.actors ) {

          # Only want to make this pustat file if NOT using multiple actors
          # When running with multiple actors this file will need to be
          # regenerated as each actors undertakes conservation actions e.g. to
          # recored which PUs are reserved as the actors act. .

          cat( '\n\nAbout to make pu.dat file for MARXAN\n' );

          cat("id,cost,status\n", file=pu.filename,append=FALSE)

          for(current.planning.unit in 1:tot.num.planning.units){

              if( OPT.use.cost.in.marxan ){

                  pu.dat.cost <- pu.area.and.cost[current.planning.unit,3]
              }else{
                  pu.dat.cost <- 0
              }

              pu.dat.id <- pu.area.and.cost[current.planning.unit,1]

              pu.dat.status <- 0

              cat(paste(pu.dat.id,",",pu.dat.cost,",",pu.dat.status,"\n",sep=""), file=pu.filename,append=TRUE)

          }

      }

  # } #End make.marxan.pu.dat
}

#===============================================================================

