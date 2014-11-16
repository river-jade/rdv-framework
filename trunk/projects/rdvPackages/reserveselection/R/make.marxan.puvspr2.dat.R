#===============================================================================

make.marxan.puvspr2.dat <-
    function (PAR.Marxan2.input.dir,
              planning.units.filename,
              use.patches.as.planning.units,
              non.habitat.indicator,
              spp.used.in.reserve.selection.vector,
              hab.map.zo1.A.TOT.spp.filename.base,
                    cur.spp.id,  #  temp idx of for loop?
                    pu,  #  temp idx of for loop?
                    pixel.size,
              OPT.use.patches.in.representation,
                    # vars in ascelin list but not in extracted list
                  sp.in.pu,  #  created in here, not passed in?
                  pu.spp.rep.filename  #  created in here, not passed in?
              )
        {
  # make.marxan.puvspr2.dat<-function(planning.units.filename,
  #                                   use.patches.as.planning.units,
  #                                   spp.used.in.reserve.selection.vector,
  #                                   non.habitat.indicator,
  #                                   hab.map.zo1.A.TOT.spp.filename.base,
  #                                   sp.in.pu,
  #                                   OPT.use.patches.in.representation,
  #                                   pu.spp.rep.filename,
  #                                   PAR.Marxan2.input.dir
  # ){

      #e.g. make.marxan.puvspr2.dat(planning.units.filename, use.patches.as.planning.units,                              spp.used.in.reserve.selection.vector,non.habitat.indicator, hab.map.zo1.A.TOT.spp.filename.base, sp.in.pu, OPT.use.patches.in.representation, pu.spp.rep.filename,PAR.Marxan2.input.dir )

      # puvspr2.dat -  file consists of a long matrix with three columns
      #     With a format species,pu,amount. The 1st
      #    column is the speces refers to the element ID (eg can be species or vegetaion
      #	type etc..), the second column refers to the ID number of each planning unit.
      #	and the third column is the amount of that
      #	element in that planning unit.  This shows how much the
      #	unit can contribute toward the representation goals.
      #
      #     Need to make sure that the amounts are in the same units as the
      #     element representation goal in the species.dat file
      #

      # source( '../R/make.marxan.puvspr.file.R' )

      # change to the marxan input file directory



      cat( '\n\nAbout to make puvspr.dat file for MARXAN' );

      pu.spp.rep.filename<-paste(PAR.Marxan2.input.dir, 'puvspr2.dat', sep="");

      pu.matrix  <- as.matrix ( read.table(planning.units.filename) );

      if( use.patches.as.planning.units ) {

          # In this case we are getting the PU map from the patch map.
          # So we need to remove the non-habitat pixels (marxan
          # can't handle a planing unit with value 0.
          planning.units <- sort (unique( as.vector ( pu.matrix )));
          planning.units <- planning.units[planning.units != non.habitat.indicator]

      } else {
          # otherwise the planning unit has been generated and should start at
          # 1
          planning.units <- sort (unique( as.vector ( pu.matrix )));
          planning.units <- planning.units[planning.units != non.habitat.indicator]

      }


      #Create new puvspr2.dat file with header
      cat("species,pu,amount\n", file=pu.spp.rep.filename,append=FALSE)



      # loop over planning units
      for( pu in planning.units ) {

          # loop over species.
          element.id <- 111;   # this is species name, reset to 1st species.
          # Note calling species 111, 112,,113 etc as this was what
          # they were called in the spcies.dat file.

          for( cur.spp.id in spp.used.in.reserve.selection.vector ) {


              #cat( "\nPU =", pu, "spp =", cur.spp.id )
              cur.spp.filename <- paste( hab.map.zo1.A.TOT.spp.filename.base, cur.spp.id,
                                         '.txt', sep = "" );

              sp.hab.map <- as.matrix( read.table( cur.spp.filename ) );
              #cat( paste( '\nCalculating for:', cur.spp.filename ));


              # select the habitat in a planning unit
              sp.in.pu <- sp.hab.map[ pu.matrix == pu ]; # this is the line that seems to
              # be making the loop run slow.

              #browser()
              # determing the no. of pixels of habitat
              no.pixels <- length( sp.in.pu[ sp.in.pu !=  non.habitat.indicator ] );
              area <- no.pixels * pixel.size * pixel.size; # convert to meters.

              if( area > 0 ) { #if any habiat, record the amount.

                  #cat( paste( '\nMap:', cur.spp.filename, 'sp.no:', cur.spp.id));
                  #cat( paste( '\nPU', pu, 'has species number', element.id,
                  #           'with area:', area, '\n'));

                  if( OPT.use.patches.in.representation  ){
                      # in this case just store a 0/1 depending on whether the spp is
                      # present in the patch
                      area <- 1;
                  }

                  #Append new data to puvspr2.dat file
                  cat( paste(element.id,",",pu,",", area,"\n", sep=""),
                       file = pu.spp.rep.filename, append=TRUE)

                  #browser()
              }
              element.id <- element.id + 1;

          }

          #cat( '\n' );
      }

  # } #end  make.marxan.puvspr2.dat
}

#===============================================================================



