


# Variables needed for plot.band()

PAR.fill.line.density <- 500
PAR.outline.interval <- TRUE
PAR.fill.interval <- TRUE



# source( "plot.results.functions.R" )

multiple.plot <- function(scen.nums, plot.title, base.filename, query.variable,
                          y.lim, single.col.opt=FALSE, single.col=1 ){

  ctr <- 0;
  
  for( cur.scen.num in scen.nums ) {

    ctr <- ctr + 1;

    
    #CondDBbname <- paste( base.filename, cur.scen.num, '.dbms',
    #                    sep ='' )
    CondDBbname <- paste( base.filename, 'evalCondition.', cur.scen.num, '.dbms',
                        sep ='' )
    if( file.exists( CondDBbname) ) {
      connect.to.database( CondDBbname );
    } else {
      cat( '\nError: the database file: ', CondDBbname, 'does not exist\n' );
      stop();
    }


    land.query1 <- paste( 'select TIME_STEP,', query.variable,
                         'from LANDSCAPE_COND');
  
    land.query1.result <- sql( land.query1 );

    # work out the x-values
    x.values <- land.query1.result$TIME_STEP


    #work out the y-values
    y.values.col <- which ( colnames(land.query1.result) == query.variable )
    y.values <- land.query1.result[,y.values.col]



    # replace any NA's with zeros
    y.values[ is.na(y.values) ] <- 0;
    lty.val <- 1;
    if( single.col.opt ) col.val <- single.col
    else col.val <- ctr;
    
    # make the do nothing scenario dashed (this is usualy the 4th scen)
    if( ctr == 4 ){ lty.val <- 2; }


    # make nice lable for y axis

    y.lable <- query.variable;
    
    if( query.variable == 'TOTAL_COND_SCORE_SUM' ) {
      y.lable = 'Total summed condition'
    }
    
    if( query.variable == 'SUMMED_COND_ABOVE_THRESH' ) {
      y.lable = 'Summed condition above threshold'
    }
    
    if( ctr > 1 | single.col.opt ) {
      lines( x.values, y.values, type = 'l', 
            ylim = y.lim,
            #xlim = PAR.x.lim,
            lty = lty.val,
            col = col.val, lwd = PAR.line.width )
      
    } else {
      plot( x.values, y.values, type = 'l',
           ylab = y.lable,
           xlab = 'Time (years)',
           ylim = y.lim,
           #xlim = PAR.x.lim, #main =query.variable,
           lty = lty.val,
           col = col.val, lwd = PAR.line.width )

      
    }



   #plot.values <- cbind( x.values, round(y.values, 3));
    plot.values <- round(y.values, 3);
  
    #write.table( plot.values,
    #            paste('plot.vals', cur.scen.num, '.txt', sep = '' ),
    #            row.names = FALSE, col.names = FALSE);


    
    if( length( which( is.na(y.values) == TRUE ) > 0   ) ){
      # check for  NA's
      # if there are NA's then max won't work in an if statement.
      
      rounded.y.values <- round(y.values,3);

      # replace the NA's with zeros
      

      
    } else  {
      if( max(y.values) < 1 ) {
      
        rounded.y.values <- round(y.values,3);
      
      } else {

        rounded.y.values <- round(y.values,0);
      }
    }

    
    cat('\nS', cur.scen.num, query.variable, ':',
        rounded.y.values);
    
    close.database.connection();


  }

  # add a global title
  mtext( plot.title, side = 3, line = 1.5, outer=FALSE, cex=1 )

  # add a text tag for the (a) (b) etc..

  cat( '\n\n----\n' );
  
  
}


#============================================================================

paper.plots.4.var <- function( run.num.vec, tag ) {

  y.lim <- c( 2000, 54000);

  multiple.plot(run.num.vec,tag,PAR.base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  
  y.lim <- c( 100, 18000) ;
  multiple.plot(run.num.vec,tag,PAR.base.name,'SUMMED_COND_ABOVE_THRESH',y.lim);
  
  y.lim <- c( 0, 1);
  multiple.plot(run.num.vec,tag,PAR.base.name,'MEAN_COND_ABOVE_THRESH',y.lim);

  multiple.plot(run.num.vec,tag,PAR.base.name,'MEAN_COND_BELOW_THRESH',y.lim);
  
  
}
#============================================================================

paper.plots.2.var <- function( run.num.vec, title, text.tag.vec = c('',''),
                              tag.x.loc=0, tag.y.loc.vec=c(0,0) ) {

  y.lim <- c( 2000, 54000);
  multiple.plot(run.num.vec,title,PAR.base.name,'TOTAL_COND_SCORE_SUM', y.lim,
                text.tag.vec[1], tag.x.loc, tag.y.loc.vec[1]);
  
  y.lim <- c( 100, 12000) ;
  multiple.plot(run.num.vec,title,PAR.base.name,'SUMMED_COND_ABOVE_THRESH',y.lim,
                text.tag.vec[2], tag.x.loc, tag.y.loc.vec[2]);
  
  
}


#============================================================================


multiple.plot.integrated.cond <- function(scen.nums, base.filename,
                                          query.variable, plot.option,
                                          y.lim ) {


  ctr <- 0;
  
  for( cur.scen.num in scen.nums ) {

    ctr <- ctr + 1;

    if( file.exists( CondDBbname) ) {
      connect.to.database( CondDBbname );
    } else {
      cat( '\nError: the database file: ', CondDBbname, 'does not exist\n' );
      stop();
    }

    connect.to.database( CondDBbname );

    land.query1 <- paste( 'select TIME_STEP,', query.variable,
                         'from LANDSCAPE_COND');
  
    land.query1.result <- sql( land.query1 );

    # work out the x-values
    x.values <- land.query1.result$TIME_STEP


    #work out the y-values
    y.values.col <- which ( colnames(land.query1.result) == query.variable )
    y.values <- land.query1.result[,y.values.col]

    # calc integrated y values
    integrated.y.val.vec <- vector( length = length( y.values ) )
    #discounted.y.vals <- vector( length = length( y.values ) )
    
    for( y.ctr in 1:length(y.values) ){

      
      #discounted.y.vals[y.ctr] <- y.values[y.ctr] #* 1/(y.ctr^0);
      
      integrated.y.val.vec[y.ctr] <- sum(y.values[1:y.ctr] );
      #integrated.y.val.vec[y.ctr] <- sum(discounted.y.vals[1:y.ctr] );

    }

    
    if( ctr > 1 ) {
      lines( x.values, integrated.y.val.vec, type = 'l', ylab = query.variable,
            ylim = y.lim,
            xlim = PAR.x.lim, 
            col = ctr, lwd = PAR.line.width )
      
    } else {
      plot( x.values, integrated.y.val.vec, type = 'l', ylab = query.variable,
           xlab = 'Time (years)',
           ylim = y.lim,
           xlim = PAR.x.lim, main =query.variable,
           col = ctr, lwd = PAR.line.width )

      
    }


  
    close.database.connection();

    plot.values <- cbind( x.values, round(y.values, 3));
    plot.values <- round(y.values, 3);
  
    #write.table( plot.values,
    #            paste('plot.vals', cur.scen.num, '.txt', sep = '' ),
    #            row.names = FALSE, col.names = FALSE);


    cat("\n", integrated.y.val.vec, "\n" );

  }

  
  legend( "topright",
         scen.descript[scen.nums],     
         fill = 1:ctr );

  
  
}




#============================================================================

plot.tot.res.unres.cond <-  function(scen.num, base.filename, y.lim ) {

  
  single.plot( scen.num, base.filename, 'TOTAL_COND_SCORE_SUM', 'PLOT',
              'black', PAR.line.width, PAR.x.lim, y.lim  );

  single.plot( scen.num, base.filename, 'RESERVED_COND_SCORE_SUM', 'OVERLAY',
              'green', PAR.line.width, PAR.x.lim, y.lim  );

  single.plot( scen.num, base.filename, 'UNRESERVED_COND_SCORE_SUM', 'OVERLAY',
              'red', PAR.line.width, PAR.x.lim, y.lim  );
  
  legend( "topright",
         c("Total cond", "unreserved cond", "reserved cond" ),
         fill = c("black", "red", "green" ) );

}


#============================================================================

plot.cond.hist <- function(runs, time, min.val, max.y.val, base.dir,
                           plot.title = '',
                           plot.txt = '', txt.x.loc = 0, txt.y.loc = 0 ){


  for( cur.run in runs ) {

    
    # add the padded zeros to the fro of the run
    cur.f.run <- formatC( cur.run, width = 4, flag = "0" )

    filename <- paste( base.dir, '\\r', cur.f.run, '_ts.cond.map', time,
                      '.txt', sep = '' );

    if( plot.txt == '' ) {
      hist.title <- paste( 'r', cur.run, '_ts.cond.map', time, '.txt',
                          sep = '' );
    } else {

      hist.title = plot.title;
      
    }

    cat( '\n filename = ', filename, '\n' );
  
    cond.matrix <- as.matrix(read.table( filename ))

    cond.matrix <- cond.matrix[ which(cond.matrix > min.val)];

    par( ylog = TRUE ) ;
    
    hist.data <- hist(cond.matrix, main = hist.title, breaks = 25,
                      xlab = 'Grassland condition score'
                      ,ylim = c(0, max.y.val));

    #counts <- hist.data$counts

    #breaks <- hist.data$breaks;
    
    #namesarg <- breaks[1:(length(breaks)-1) ];
    
    #barplot( log(counts),names.arg = namesarg ,
    #        xlab = 'Grassland condition score',
    #        ylab = 'Log(Fequency)' );

    
    text( txt.x.loc, txt.y.loc, plot.txt,  cex = 1.5 )
   
  }
  
}


#============================================================================

plot.3d.contours <- function( run.vec, z.lims, main.title = '', tag = '' ) {


  run.ctr <- 0;
  for( cur.run in run.vec ) {
    cat( '\n--\n' )

    run.ctr <- run.ctr + 1;
    
    x.results.matrix.filename <- paste( 'r',cur.run,'x.results.txt',sep = '' );
    y.results.matrix.filename <- paste( 'r',cur.run,'y.results.txt',sep = '' );
    z.results.matrix.filename <- paste( 'r',cur.run,'z.results.txt',sep = '' );
  
    x.vals <- as.matrix( read.table(x.results.matrix.filename ) );
    y.vals <- as.matrix( read.table(y.results.matrix.filename ) );
    z.vals <- as.matrix( read.table(z.results.matrix.filename ) );


    y.lim = c(0, max(z.vals) );
    ctr <- 0;

    if( run.ctr == 1 ) {
      line.type = 1;
    } else {
      line.type = 2;
    }

#    cond.scores.indices <- 6:(length(z.vals[,1])-1) ;
    #cond.scores.indices <- c(2,6,8);
    cond.scores.indices <- c(2,8);
    
    for( cur.cond.val in cond.scores.indices ) {

      cat( '\nContour at:', y.vals[cur.cond.val] );
      
      ctr <- ctr + 1;

      
      z.vec <- z.vals[cur.cond.val, ];
      # this is in pixels. Convert it to ha
      # 1 pixel = 50*50 m 1 ha = 100* 100 so conversion is
      # 50*50 / (100*100 ) = 0.25

      z.vec.ha <- z.vec * 0.25;

      cat( '\nArea values =', z.vec.ha );
      if( ctr == 1 & run.ctr == 1) {
        plot( x.vals, z.vec.ha , type='l', ylim=z.lims,
             col=ctr, lwd = 2, lty = line.type,
             xlab = 'Time (years)', ylab = 'Area of grassland (ha)',
             main = main.title )
      } else {
        lines( x.vals, z.vec.ha, type='l', col=ctr, lwd = 2,
              lty = line.type);
      }
      
    }
  }

  text( 52, 3400, tag, cex = 1.3 );
  
  scen.descriptor <- paste( 'condition > ', y.vals[cond.scores.indices], sep = '' );
  # make a legend.

  legend( "topright", scen.descriptor, fill = 1:length( scen.descriptor) );
  
}


#============================================================================

single.3d.plot <- function(x.vec, y.vec, plot.matrix, z.label, run, max.z.val) {


  #max.z.val <- 15000;
  #max.z.val <- 48000;
  
  persp( x = x.vec,
        y = y.vec,
        z = plot.matrix,
        zlim = c(0,max.z.val ),
        xlab = ' Cond threshold',
        ylab = ' Time(years)',
        zlab = z.label,
        theta = 140,        
        phi = 30,
        expand = 0.6,
        col = "lightblue",
        ltheta = 180,
        ticktype = "detailed",
        cex.lab=0.8,
        cex.axis=0.9,
        cex.main = 1.5,
        main = paste( 'Run', run )
       );


  # not plot all the lines on a 2d graph with time as the x-axis
  y.lim = c(0, max(plot.matrix) );
  ctr <- 0;
  
  for( cur.cond.val in 1:length(plot.matrix[,1]) ) {

    ctr <- ctr + 1;

    if( ctr == 1 ) {
      
      #plot( y.vec, plot.matrix[cur.cond.val, ], type='l', ylim=y.lim, col=ctr )

    } else {

      #lines( y.vec,plot.matrix[cur.cond.val,], type='l', ylim=y.lim, col=ctr);

    }

  }

}

#============================================================================


make.3d.plots <- function(time.step.vec, cond.vec, run, max.z.val) {

  
  # plot the results

  par( mfrow = c(1,1))
 

  single.3d.plot( cond.vec, time.step.vec, summed.cond.results.matrix,
                 'Summed Cond', run, max.z.val )
  single.3d.plot( cond.vec, time.step.vec, summed.area.results.matrix,
                'Summed Area', run, max.z.val )


  x.results.matrix.filename <- paste( 'r', run, 'x.results.txt', sep = '' );
  y.results.matrix.filename <- paste( 'r', run, 'y.results.txt', sep = '' );
  z.results.matrix.filename <- paste( 'r', run, 'z.results.txt', sep = '' );


  
  write.table( time.step.vec, file = x.results.matrix.filename,
              row.names = FALSE, col.names = FALSE );
  
  write.table( cond.vec, file = y.results.matrix.filename,
              row.names = FALSE, col.names = FALSE );
  
  #write.table( summed.cond.results.matrix, file = z.results.matrix.filename,
  #            row.names = FALSE, col.names = FALSE );
  
  write.table( summed.area.results.matrix, file = z.results.matrix.filename,
              row.names = FALSE, col.names = FALSE );
  

}


#============================================================================

extract.data.for.3d.plots <- function(runs, base.dir, time.step.vec, max.z.val){

  
  # example filename r106_ts.cond.map80.txt
  #base.dir <- 'D:\\analysis\\reserve_selection\\svn\\framework2\\runall\\results\\run';


   # a vector of the condition values that will be looped over 
  cond.vec <<- seq( 0.35, .75, 0.05 );
  #cond.vec <<- seq( 0.5, .74, 0.03 );

  
  

  for( cur.run in runs ) {
    
    cat( '\n\nRun =', cur.run );
    
    base.dir.run <- paste( base.dir, cur.run, '\\', sep = '' )


    # make a matrix to store the results
    summed.cond.results.matrix <<-
      matrix( NA, nrow = length( cond.vec ), ncol = length( time.step.vec ));
    summed.area.results.matrix <<-
      matrix( NA, nrow = length( cond.vec ), ncol = length( time.step.vec ));


    t.ctr <- 0;
    for( cur.time in time.step.vec ) {

      t.ctr <- t.ctr + 1;
      
      cat( '\nTime step =', cur.time );

      
      
      # add the padded zeros to the fro of the run
      # "f" for formatted
      cur.f.run <- formatC( cur.run, width = 4, flag = "0" )

      filename <- paste( base.dir.run, 'r', cur.f.run, '_ts.cond.map',
                        cur.time, '.txt', sep = '' );


      cat( '\n filename = ', filename, '\n' );
  
      cond.matrix <- as.matrix(read.table( filename ))

      # vectors the hold the results for the current time step
      summed.cond.results.vec <- vector( length = length( cond.vec ) );
      summed.area.results.vec <- vector( length = length( cond.vec ) );

      cond.ctr <- 0;
      for( cur.cond.thresh in cond.vec ) {

        cond.ctr <- cond.ctr + 1;
    
        cond.matrix <- cond.matrix[ which(cond.matrix > cur.cond.thresh)];
        
        summed.cond.results.vec[cond.ctr] <- sum( cond.matrix ) ;
        summed.area.results.vec[cond.ctr] <- length( cond.matrix ) ;

        cat( '\nsummed cond above', cur.cond.thresh, '=', sum( cond.matrix ));
      
      }

      # save the results for the current time step 
      summed.cond.results.matrix[ , t.ctr] <<- summed.cond.results.vec;
      summed.area.results.matrix[ , t.ctr] <<- summed.area.results.vec;

      cat( '\n--' );
      show( summed.cond.results.matrix );
      show( summed.cond.results.matrix );
      cat( '\n--' );
    
    }  #  end - for( cur.time in time.step.vec )


    make.3d.plots(time.step.vec, cond.vec, cur.run, max.z.val )

    
    
  }  #  end - for( cur.run in runs ) 


  cat( '\n' )





}

#============================================================================


single.plot <- function(cur.scen.num, base.filename, query.variable,
                        plot.option, plot.col, width, x.lim = c(0,200),
                        y.lim  ) {


#    CondDBbname <<- paste( base.filename, cur.scen.num, '.dbms',
#                          sep ='' );
    CondDBbname <- paste( base.filename, cur.scen.num, 'evalCondition.dbms',
                        sep ='' )
  

    connect.to.database( CondDBbname );

    land.query1 <- paste( 'select TIME_STEP,', query.variable,
                         'from LANDSCAPE_COND');
  
    land.query1.result <- sql( land.query1 );

    # work out the x-values
    x.values <- land.query1.result$TIME_STEP


    #work out the y-values
    y.values.col <- which ( colnames(land.query1.result) == query.variable )
    y.values <- land.query1.result[,y.values.col]


    if( plot.option == 'OVERLAY' ) {
      lines( x.values, y.values, type = 'l', ylab = query.variable,
            ylim = y.lim,
            xlim = x.lim, main =scen.descript[cur.scen.num],
            col = plot.col, lwd = width )
      
    } else {
      plot( x.values, y.values, type = 'l', ylab = query.variable,
           xlab = 'Time (years)',
           ylim = y.lim,
           xlim = x.lim, main =scen.descript[cur.scen.num],
           col = plot.col, lwd = width )

      
    }


  
    close.database.connection();

   #plot.values <- cbind( x.values, round(y.values, 3));
    plot.values <- round(y.values, 3);
  
    write.table( plot.values, paste('plot.vals', cur.scen.num,'.txt', sep=''),
                row.names = FALSE, col.names = FALSE);

    cat("\n", y.values );

}

#============================================================================

plot.multiple.bands <- function(list.of.scen.run.nums, plot.var, y.lim, title,
                                legend.op = TRUE, show.all.runs=FALSE ){


  # Overide the title with the plot variable
  title <- plot.var


  fist.el <- list.of.scen.run.nums[[1]][1]

  # this is just to set up the plot
  multiple.plot(fist.el,'', PAR.base.name, plot.var, y.lim)

  num.scenarios <- length(list.of.scen.run.nums)

  ctr <- 1;          # want to count from one
  # first loop through and plot all the bands
  for( scen.num in 1:num.scenarios ) {
    
    curr.scens <- list.of.scen.run.nums[[ctr]]
    plot.opt <- "BAND"

    if( show.all.runs ) {
      
      # If the show.all.runs is set than call multiple plot rather
      # than plot.band. This will plot a line for each run rather than
      # a band that covers all.
      multiple.plot(curr.scens,'', PAR.base.name, plot.var, y.lim, single.col.opt=TRUE,
                    single.col=PAR.col.vec[ctr])

    } else {

      plot.band( curr.scens, ctr, title, PAR.base.name, plot.var, y.lim,
                PAR.col.vec[ctr], PAR.lty.vec[ctr], PAR.lwd.vec[ctr], plot.opt )
      
    }
    
    ctr <- ctr + 1
    
  }

  if( !show.all.runs ) {

    # now loop through and plot all the means
    ctr <- 1          
    for( scen.num in 1:num.scenarios ) {
      
      curr.scens <- list.of.scen.run.nums[[ctr]]
      plot.opt <- "MEAN"
      plot.band( curr.scens, ctr, '', PAR.base.name, plot.var, y.lim,
                PAR.col.vec[ctr], PAR.lty.vec[ctr], PAR.lwd.vec[ctr], plot.opt )    
      ctr <- ctr + 1
      
    }
  }

  if ( legend.op ) {
    
    legend( "topright", names(list.of.scen.run.nums), lty = PAR.lty.vec, col = PAR.col.vec,
           lwd = PAR.lwd.vec )
    
  }


}
  
#============================================================================

  # Note in plot.band the options are
  #  MEAN - mean vals only
  #  MEAN.AND.BAND - plot the bands with mean superimposed
  #  BAND - plot the bands only without the means
  # The default setting is MEAN.AND.BAND


plot.band <- function( scen.nums, scen.ctr, plot.title, base.filename, query.variable,
                      y.lim, fill.colour, lty.val, lwd.val,
                      plot.option = 'MEAN.AND.BAND',
                      fig.tag = '',
                      tag.x.loc = 0, tag.y.loc = ''){

  y.lable <- query.variable;

  
  # get some x.values and y.values to work out the size of the array
  # to store the results in
  x.values <- get.x.values( base.filename, scen.nums[1], query.variable );
  y.values <- get.y.values( base.filename, scen.nums[1], query.variable );


  # make a matrix to store the results

  x.val.matrix <- matrix( ncol = length( x.values), nrow = length(scen.nums));
  y.val.matrix <- matrix( ncol = length( y.values), nrow = length(scen.nums));
  
 
  ctr <- 0;  
  for( cur.scen.num in scen.nums ) {
    ctr <- ctr + 1

    x.values <- get.x.values( base.filename, cur.scen.num, query.variable )
    y.values <- get.y.values( base.filename, cur.scen.num, query.variable )

    x.val.matrix[ctr, ] <- x.values
    y.val.matrix[ctr, ] <- y.values
  }


  # add a text tag for the (a) (b) etc..
  text( tag.x.loc, tag.y.loc, fig.tag, cex = 1.5 );


  # loop through each of the y values and find the max/min
  y.max.vals    <- vector( length = length( y.values) )
  y.min.vals    <- vector( length = length( y.values) )
  y.mean.vals   <- vector( length = length( y.values) )
  y.median.vals <- vector( length = length( y.values) )

  # add a global title
  mtext( plot.title, side = 3, line = 0.3, outer=FALSE, cex=0.8 )

  #cat( '\n scen ', scen.descript.num[scen.ctr] )
  
  for( y.ctr in 1:length(y.values) ) {

    y.max.vals[y.ctr] <- max( y.val.matrix[,y.ctr]);
    y.min.vals[y.ctr] <- min( y.val.matrix[,y.ctr]);
    y.mean.vals[y.ctr] <- mean( y.val.matrix[,y.ctr]);
    y.median.vals[y.ctr] <- median( y.val.matrix[,y.ctr]);

    #cat( '\n', y.val.matrix[,y.ctr] )
  }

  # plot the max and min lines
  
  #3plot( x.values, y.max.vals, ylim = y.lim,
  #         xlim = PAR.x.lim, type = 'l' )

  
  if( plot.option == "MEAN.AND.BAND" | plot.option == "BAND" ) {

    plot.interval.on.existing.plot( y.min.vals, y.max.vals, x.values,
                                   PAR.x.lim, y.lim, PAR.fill.line.density,
                                   fill.colour, PAR.outline.interval,
                                   PAR.fill.interval );
  }
  
  if( plot.option == "MEAN.AND.BAND" | plot.option == "MEAN" ) {

    # add the mead/ median line 
    lines( x.values, y.median.vals, col = fill.colour, lwd = lwd.val,
          lty = lty.val );
    fill.col <- 'grey70'
    lines( x.values, y.max.vals, col = fill.col, lwd = 0.07,
          lty = lty.val );
    lines( x.values, y.min.vals, col = fill.col, lwd = 0.07,
          lty = lty.val );
    #lines( x.values, y.mean.vals, col = 'green', lwd = 0.2,
    #      lty = lty.val );
    
    last.y.val <- y.median.vals[max(length(y.median.vals) )] + 500
    x.val <- jitter(85, amount = 4)

    #text( x.val, last.y.val, scen.descript.num[scen.ctr], cex = 0.7)
    

    
  }
  
}

#============================================================================

get.x.values <- function(base.filename, cur.scen.num, query.variable ) {

#  CondDBbname <- paste( base.filename, scen.num, '.dbms',
#                       sep ='' );
    CondDBbname <- paste( base.filename, 'evalCondition.', cur.scen.num, '.dbms',
                        sep ='' )
  
  if( file.exists( CondDBbname) ) {
    connect.to.database( CondDBbname );
  } else {
    cat( '\nError: the database file: ', CondDBbname, 'does not exist\n' );
    stop();
  }
  land.query1 <- paste( 'select TIME_STEP,', query.variable,
                       'from LANDSCAPE_COND');
  land.query1.result <- sql( land.query1 );
  
  # work out the x-values
  x.values <- land.query1.result$TIME_STEP

  close.database.connection();

  return( x.values );
  
}

#============================================================================

get.y.values <- function(base.filename, cur.scen.num, query.variable ) {

#  CondDBbname <- paste( base.filename, scen.num, '.dbms',
#                       sep ='' );
  CondDBbname <- paste( base.filename, 'evalCondition.', cur.scen.num, '.dbms',
                        sep ='' )
  
  if( file.exists( CondDBbname) ) {
    connect.to.database( CondDBbname );
  } else {
    cat( '\nError: the database file: ', CondDBbname, 'does not exist\n' );
    stop();
  }
  land.query1 <- paste( 'select TIME_STEP,', query.variable,
                       'from LANDSCAPE_COND');
  land.query1.result <- sql( land.query1 );
  
  #work out the y-values
  y.values.col <- which ( colnames(land.query1.result) == query.variable )
  y.values <- land.query1.result[,y.values.col]
  # replace any NA's with zeros
  y.values[ is.na(y.values) ] <- 0;

  
  close.database.connection();
  return( y.values )
}


#==============================================================================


plot.interval.on.existing.plot <- function (interval.bottom.values,
                                            interval.top.values,
                                            x.values,
                                            x.limits, y.limits,
                                            number.of.lines,
                                            outline.colour,
                                            outline.interval,
                                            fill.interval
                                            ) {


  fill.colour <- "grey90"

  bot.xy <- approx( x.values, interval.bottom.values, n = number.of.lines );
  top.xy <- approx( x.values, interval.top.values, n = number.of.lines );
  
  interval.bottom.values <- bot.xy$y
  interval.top.values <- top.xy$y
  
  x.values <- top.xy$x
  
  num.entries <- length (x.values);

  if (fill.interval)
    {
        #-------------------------------------------------------
        #  Draw the grey background for the confidence interval.
        #-------------------------------------------------------
    
    for (i in 1:num.entries)
      {
      segments (x.values [i],
                interval.top.values [i],
                x.values [i],
                interval.bottom.values [i],
                lwd = 2.5, 
                col = fill.colour);
      }
    }

  if (outline.interval)
    {
      
        #------------------------------------------------------
        #  Draw the bottom boundary of the confidence interval.
        #------------------------------------------------------
    
    lines (x.values,
           interval.bottom.values, 
           ylim=y.limits, xlim = x.limits,
           type = 'l',
           lwd = 0.13,
           col = outline.colour,
           lty = 2
           #col = 'cyan'
           );
  
        #---------------------------------------------------
        #  Draw the top boundary of the confidence interval.
        #---------------------------------------------------
    
    lines (x.values,
           interval.top.values, 
           ylim=y.limits, xlim = x.limits,
           type = 'l',
           lwd = 0.13,
           col = outline.colour,
           lty =2
           #col = 'cyan'
           );
    }
  }

#==============================================================================

