    #-----------------------------------------------------------#
    #                                                           #
    #             make.Mondrian.planning.units.R                #
    #                                                           #
    #  Make a planning unit map. This is for use with the MARXAN#
    #  reserve selection software.                              #
    #  Create the planning units by dropping lots of random     #
    #  size rectangles at random locations so that it looks     #
    #  a bit like a Mondrian painting.                          #
    #  The goal here is to create lots of planning units with   #
    #  boundaries that have Some complexity, but not too much.  #
    #                                                           #
    #  Cloned from make.rectangular.planning.units.R.           #
    #  August 31, 2007 - BTL                                    #
    #                                                           #
    #  source( 'make.Mondrian.planning.units.R' )        #
    #                                                           #
    #-----------------------------------------------------------#

#source( 'variables.R' )

source( 'w.R' ) 


    #  Create the base map for the planning units.
    #  Initialize the background value to be the non-habitat indicator
    #  value.  
background.value <- as.integer( non.habitat.indicator );
pu.map <- matrix (background.value, nrow=rows, ncol=cols);

rect.size.range <-
    PAR.Mondrian.min.rectangle.size:PAR.Mondrian.max.rectangle.size;

for (cur.rect.ID in 1:PAR.Mondrian.num.rectangles)
  {
      #  Choose a random size for the rectangle.
  cur.rect.height <- sample (rect.size.range, 1, replace=TRUE);
  cur.rect.width <- sample (rect.size.range, 1, replace=TRUE);

      #  Choose a random location for the rectangle.
  last.legal.row <- rows - cur.rect.height + 1;
  last.legal.col <- cols - cur.rect.width + 1;
  
  cur.upper.left.row <- sample (1:last.legal.row, 1, replace=T) - 1;
  cur.upper.left.col <- sample (1:last.legal.col, 1, replace=T) - 1;

  if (DEBUG)
    {
    cat ("\nAt ", cur.rect.ID,
         ", llr = ", last.legal.row,
         ", llc = ", last.legal.col,
         ", h = ", cur.rect.height,
         ", w = ", cur.rect.width,
         ", ulr = ", cur.upper.left.row,
         ", ulc = ", cur.upper.left.col,
         "\n");
    }
  
      #  Draw the rectangle on the map.
  for (i in 1:cur.rect.width)
    {
    for (j in 1:cur.rect.height)
      {
      pu.map [cur.upper.left.row + j, cur.upper.left.col + i] <- cur.rect.ID;
      }
    }
  }

#write.pgm.file (pu.map, "Mondrian", rows, cols);
#write.pgm.txt.files( pu.map, planning.units.filename.base, rows, cols );
write.to.3.forms.of.files( pu.map, planning.units.filename.base, rows, cols );

#write.asc.file( pu.map, planning.units.filename.base, rows, cols );

