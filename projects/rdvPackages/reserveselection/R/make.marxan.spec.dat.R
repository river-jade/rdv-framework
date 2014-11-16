
#  Arguments with extra indentation are globals that were not
#  in the argument list that ascelin had created when making this
#  a function.

make.marxan.spec.dat <-
    function (     PAR.Marxan2.input.dir,
                   PAR.species.penalty.factor,
                        OPT.read.represenation.goals.from.file,
                        BATCH,
                   Res.path,
                   repetition,
                   PAR.objfun.results.file,
                        reprsent.goal.scale.factor,
                   OPT.use.patches.in.representation,
                       spp.hab.info.table.A.TOT,
                       spp.used.in.reserve.selection.vector,
                       spp,  #  temp idx in for loop?
                       num.objective.funs.entries,
                       OPT.representation.calculation,
                       OPT.VAL.use.proportions.in.represerntaion.goal,
                       PAR.spp.representation.goals,
                       OPT.VAL.use.absolute.num.patches.in.represerntaion.goal
                   )
{
  #===============================================================================

  # make.marxan.spec.dat<-function(PAR.Marxan2.input.dir,
  #                                PAR.species.penalty.factor,
  #                                Res.path,
  #                                PAR.objfun.results.file,
  #                                repetition,
  #                                OPT.use.patches.in.representation
  # ){

      # e.g. make.marxan.spec.dat(PAR.Marxan2.input.dir, PAR.species.penalty.factor,Res.path,                              PAR.objfun.results.file, repetition,OPT.use.patches.in.representation)

      ################################################################
      #  Make the 'spec.dat' file for MARXAN.
      #
      #  The Conservation Feature File contains information about each of the conservation
      #  features being considered, such as their name, target representation, and the penalty
      #  if the representation target is not met. It has the default name ?spec.dat?. Because of
      #  this name it is sometimes referred to as the Species File, although conservation
      #  features will oftenbe surrogates such as habitat type rather than actual species.
      #  Importantly, this file does not contain information on the distribution of conservation
      #  features across planning units. This information is held in the Planning Unit versus
      #  Conservation Feature File.
      #
      #  The species.dat file is made of the following columns
      #   id, type, target, spf, target2, targetocc, name, sepnum, sepdistance
      #  However the reserve design algorithmn only makes use of the following columns
      #   id, target,spf,name
      #
      #  id - A unique numerical identifier for each conservation feature. Be careful
      #  not to duplicate id numbers as Marxan will ignore all but the last one.
      #
      #  target - Feature Representation Target The target amount of each
      #  conservation feature to be included in the solutions. These values
      #  represent constraints on potential solutions to the reserve selection problem.
      #
      #  spf - Conservation Feature Penalty Factor.  The letters ?spf? stands for
      #  Species Penalty Factor.  The penalty factor is a multiplier that determines
      #  the size of the penalty that will be added to the objective function if
      #  the target for a conservation feature is not met in the current reserve scenario
      #
      #  name -  The alphabetical (no numbers!) name of each conservation
      # feature (e.g. cloud forest). This variable is unusual in that it can include spaces.

      cat( '\nAbout to make spec.dat file for MARXAN\n' );

      species.filename<-paste(PAR.Marxan2.input.dir, 'spec.dat', sep="");

      #set the attributes for each species.
      element.id <- 111;    # call species 111,112,113 etc for now.
      species.penalty.factor <- PAR.species.penalty.factor;

      species.name.base <- 'species.num.' # just set this species.num.1,2,3..
      # for now.

      cat("id,target,spf,name\n", file=species.filename,append=FALSE)

      # Calculate the representation goals.
      if( OPT.read.represenation.goals.from.file ){

          cat( '\nReading representation goals from file' );
          # reading the representation goals from a file so they can be the
          # same as what results from running ZONATION or RICHNESS

          # both repetition, and PAR.objfun.results.file are set in multi.batch.R
          # or rdv.configuration
          if( BATCH ) {
              # if in batch mode, then append the repetition number to the
              # front of the rep. goal filename
              rep.goal.filename <- paste( Res.path, '/', repetition, '.',
                                          PAR.objfun.results.file, sep ='' );
          } else {
              # otherwise, don't
              # assuming that file has been specified completely, including the run
              # repetition number, if necessary
              rep.goal.filename <-
                  paste( Res.path, '/', PAR.objfun.results.file, sep ='' );

          }

          rep.goal.results <- as.matrix( read.table( rep.goal.filename ) );

          # work out which row in the rep.goal.results matrix to extract the
          # representation goals from. rep.goal.results[,1] gives the first
          # column which shows the fraction.of.patches.to.reserve
          row.to.extract.from <-
              which( rep.goal.results[,1] == reprsent.goal.scale.factor );

          # check there actually was an entry in the matrix that matched the
          # reprsent.goal.scale.factor

          if( length(row.to.extract.from)== 0 ) {
              cat( '\nError in make.other.marxan.files.R:\n',
                   ' trying to extract representation goals\n  from file:',
                   rep.goal.filename, '\n  for reprsent.goal.scale.factor=',
                   reprsent.goal.scale.factor, '\n  Can\'t find line to match',
                   'reprsent.goal.scale.factor.\n'   )
              stop();
          }

          if( OPT.use.patches.in.representation ){

              index.value <- 6; # <6 is the num patches of damaged hab>
              # (change to 5 for the num patches of real hab
          } else{
              # use the number of pixels instead

              index.value <- 11; # <11 no pixels in damaged hab map>
              # (change to 7 for num of  pixels in real hab )

          }

      }  else {         # end - if( OPT.read.represenation.goals.from.file )

          # in this case you are specifying the representation goals
          # exactly

          # read in the hab info file. It has format
          # <Spp.number> <pixels.of.habitat> <patches.of.habitat>
          spp.hab.info.matrix <- as.matrix( read.table( spp.hab.info.table.A.TOT  ) );

          #make a list of either number of patches or pixels that each spp occupies
          if( OPT.use.patches.in.representation ){

              spp.hab.info.vec <- spp.hab.info.matrix[,3];

          } else {

              spp.hab.info.vec <- spp.hab.info.matrix[,2];

          }
      } # end - if/else ( OPT.read.represenation.goals.from.file )

      spp.ctr <- 0;

      for( spp in spp.used.in.reserve.selection.vector ) {

          spp.ctr <- spp.ctr + 1;

          if( OPT.read.represenation.goals.from.file ) {
              # first workout the index of for the spp
              objfn.index <- (spp-1)* num.objective.funs.entries + index.value;

              # extract the num of pixels of (damaged) habitat of each spp
              spp.rep.goal <- rep.goal.results[row.to.extract.from, objfn.index];
              cat( '\n sp=',spp, 'QPM index is ', objfn.index );

          } else {


              if( OPT.representation.calculation ==
                      OPT.VAL.use.proportions.in.represerntaion.goal) {

                  spp.rep.goal <-
                      PAR.spp.representation.goals[spp.ctr]*spp.hab.info.vec[spp];
                  spp.rep.goal <- round( spp.rep.goal );

              } else {

                  if(  OPT.representation.calculation ==
                           OPT.VAL.use.absolute.num.patches.in.represerntaion.goal ) {

                      spp.rep.goal <- PAR.spp.representation.goals[spp.ctr];

                  } else {

                      cat('\nERROR, OPT.representation.calculation set to unknown value' );
                      stop();

                  }


              }

          }

          cat( '\n sp=',spp, 'rep goal = ', spp.rep.goal );

          sp.name <- paste( species.name.base, spp, sep='' );

          ##  round( habitat.info[ spp, 3] * spp.representation.goal );
          #rep.goal.as.num.of.elements <-    #make the representation goal in m^2
          #  habitat.info[ spp, 2] * pixel.size^2  * spp.representation.goal;

          file.line <- paste( element.id,",",spp.rep.goal,",",
                              species.penalty.factor,",",sp.name,'\n',sep="" );

          #id,prop,target,spf,name

          #cat( file.line ) ;
          cat( file.line, file = species.filename, append = TRUE );

          element.id <- element.id + 1;

      }

  # }
}

