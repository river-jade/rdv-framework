



# source( "plot.results.R" )

# rm( list = ls( all=TRUE ));

source( "dbms.functions.r" )
source( "plot.results.functions.R" )


par( mfrow = c(1,1))


PAR.line.width <- 3;
PAR.x.lim <- c(0,100)


# full runs with 20 ha expl
#base.name <- '..\\my_laptop\\2009-05-22\\evalCondition.';

# full runs with 20 ha expl
#base.name <- '..\\my_laptop\\2009-05-25\\evalCondition.';



#base.name <-    '..\\my_laptop\\2009-06-25\\evalCondition.';


y.lim <- c( 20000, 55000)
scen.descript <- c(
                   "All Pub (S)",       # scen 1
                   "All Priv (R)",      # scen 2
                   "50-50 mix", # scen 3
                   "Pub",       # scen 4
                   "Priv",      # scen 5
                   "50-50 mix", # scen 6
                   "Pub",       # scen 7
                   "Priv",      # scen 8
                   "50-50 mix", # scen 9
                   "Pub",       # scen 10
                   "Priv",      # scen 11
                   "50-50 mix"  # scen 12
                   )
base.name <- '..\\S_LT\\2009-06-26\\evalCondition.';

#multile.plot( 7:9, base.name, 'TOTAL_COND_SCORE_SUM',  y.lim );
#multiple.plot( 10:12, base.name, 'TOTAL_COND_SCORE_SUM', 'PLOT',y.lim);

y.lim <- c( 0, 30000)
#multiple.plot( 7:9, base.name, 'RESERVED_COND_SCORE_SUM', y.lim);
#multiple.plot( 10:12, base.name, 'RESERVED_COND_SCORE_SUM', y.lim  );

y.lim <- c( 5000, 55000)
#multiple.plot( 7:9, base.name, 'UNRESERVED_COND_SCORE_SUM', y.lim  );
#multiple.plot( 10:12, base.name, 'UNRESERVED_COND_SCORE_SUM', y.lim  );


y.lim <- c( 0, 55000)


#plot.tot.res.unres.cond ( 7, base.name, y.lim );
#plot.tot.res.unres.cond ( 4, base.name, y.lim );
#plot.tot.res.unres.cond ( 8, base.name, y.lim );
#plot.tot.res.unres.cond ( 5, base.name, y.lim );
#plot.tot.res.unres.cond ( 9, base.name, y.lim );
#plot.tot.res.unres.cond ( 6, base.name, y.lim );

#base.name <- '..\\S_LT\\2009-06-26\\evalCondition.';
base.name <-    '..\\all_results\\evalCondition.';

y.lim <- c( 0, 0.2)

#multiple.plot( 7:9, base.name, 'TOTAL_COND_SCORE_MEAN', y.lim );
#multiple.plot( 10:12, base.name, 'TOTAL_COND_SCORE_MEAN', y.lim);

#multiple.plot( 7:9, base.name, 'RESERVED_COND_SCORE_MEAN', y.lim  );
#multiple.plot( 10:12, base.name, 'RESERVED_COND_SCORE_MEAN', y.lim  );

#multiple.plot( 7:9, base.name, 'UNRESERVED_COND_SCORE_MEAN', y.lim  );
#multiple.plot( 10:12, base.name, 'UNRESERVED_COND_SCORE_MEAN', y.lim );



#####################
# plots 13 - 15  
#####################



#base.name <-    '..\\AG_LT\\2009-05-25\\evalCondition.';
base.name <-    '..\\all_results\\evalCondition.';

y.lim <<- c( 15000, 55000)
#base.name <- '..\\A_DT\\2009-06-26\\evalCondition.';
#multiple.plot( 16:18, base.name, 'TOTAL_COND_SCORE_SUM', y.lim  );

#base.name <- '..\\K_DT\\2009-06-26\\evalCondition.';
#multiple.plot( 19:21, base.name, 'TOTAL_COND_SCORE_SUM', y.lim  );

#base.name <- '..\\A_LT\\2009-06-27\\evalCondition.';
#multiple.plot( 25:27, base.name, 'TOTAL_COND_SCORE_SUM', y.lim);

#multiple.plot( 28:30, base.name, 'TOTAL_COND_SCORE_SUM', y.lim);

plot.3 <- function() {
  par( mfrow = c(2,2) );
  
  scen.descript <- c(
                   "All Pub (R)",
                   "All Priv (R)",
                   "50-50 Mix (R)"
                     )
  y.lim <- c( 2000, 55000)
  multiple.plot( 45:47, 'B=40k', base.name, 'TOTAL_COND_SCORE_SUM', y.lim);
  multiple.plot( 48:49, 'B=40k', base.name, 'TOTAL_COND_SCORE_SUM', y.lim);
  mtext( "Priv:Pub = 1:10; No loss", side = 3, outer=TRUE, line=-1, cex=1 )

}


plot.10 <- function() {
  
  #---------------------------------------------  
  # Priv:Pub = 1:10, with and without loss
  #
  #---------------------------------------------
  
  par( mfrow = c(2,2) );
  
  scen.descript <<- c(
                   "All Pub (S)",
                   "All Priv (R)"
                     )
  
  #y.lim <- c( 17000, 55000)
  y.lim <- c( 2000, 55000)
  multiple.plot( 63:64, 'B=10k', base.name, 'TOTAL_COND_SCORE_SUM', y.lim);
  multiple.plot( 65:66, 'B=20k', base.name, 'TOTAL_COND_SCORE_SUM', y.lim);
  multiple.plot( 67:68, 'B=40k', base.name, 'TOTAL_COND_SCORE_SUM', y.lim);
  multiple.plot( 69:70, 'B=60k', base.name, 'TOTAL_COND_SCORE_SUM', y.lim);
  mtext( "Priv:Pub = 1:10; No loss", side = 3, outer=TRUE, line=-1, cex=1 )

  
  y.lim <- c( 2000, 55000)
  multiple.plot( 87:88, 'B=10k', base.name, 'TOTAL_COND_SCORE_SUM', y.lim);
  multiple.plot( 89:90, 'B=20k', base.name, 'TOTAL_COND_SCORE_SUM', y.lim);
  multiple.plot( 91:92, 'B=40k', base.name, 'TOTAL_COND_SCORE_SUM', y.lim);
  multiple.plot( 93:94, 'B=60k', base.name, 'TOTAL_COND_SCORE_SUM', y.lim);

  mtext( "Priv:Pub = 1:10; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )

}

plot.11 <- function() {
  
  #---------------------------------------------  
  # Priv:Pub = 0.1:10, with and without loss
  #---------------------------------------------
  
  par( mfrow = c(2,2) );
  
  scen.descript <<- c(
                   "All Pub (S)",
                   "All Priv (R)",
                   "Do Nothing"
                     )
  
  y.lim <- c( 2000, 75000)
  multiple.plot(c(79:80,104),'B=10k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  multiple.plot(c(81:82,104),'B=20k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  multiple.plot( c(83:84,104),'B=40k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  multiple.plot( c(85:86,104),'B=60k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  mtext( "Priv:Pub = 0.1:10; No loss",side = 3,outer=TRUE,line=-1,cex=1 )
  
  par( mfrow = c(2,2) );
  multiple.plot( c(71:72,104),'B=10k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  multiple.plot( c(73:74,104),'B=20k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  multiple.plot( c(75:76,104),'B=40k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  multiple.plot( c(77:78,104),'B=60k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  mtext( "Priv:Pub = 0.1:10; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )

}



plot.12 <- function() {
  
  #---------------------------------------------  
  # Priv:Pub = 10:10, without loss, range of budgets
  #---------------------------------------------

  # testing situation where pub and private costs the same

  par( mfrow = c(2,2) );
  
  scen.descript <<- c(
                   "All Pub (S)",
                   "All Priv (R)",
                   "Do Nothing"
                     )
  
  y.lim <- c( 2000, 75000)
  #y.lim <- c( 2000, 55000)
  multiple.plot(c(95:96,104),'B=10k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  multiple.plot(c(97:98,104),'B=20k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  multiple.plot(c(99:100,104),'B=40k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  multiple.plot(c(101:102,104),'B=60k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  mtext( "Priv:Pub = 10:10; No loss", side = 3, outer=TRUE, line=-1, cex=1 )

  
}


plot.13 <- function() {
  
  #---------------------------------------------  
  # Priv:Pub = 1:10, without loss, range of budgets
  #---------------------------------------------

  # testing situation where pub and private costs the same

  par( mfrow = c(2,2) );
  
  scen.descript <<- c(
                   'All Pub (S)',
                   'All Priv (R)',
                   'Do Nothing',
                   'All Priv (R) 15yr', 
                   'All Priv (R) 30yr' 
                     )
  
  y.lim <- c( 15000, 75000)
  multiple.plot(c(105:106,104),'B=20k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  multiple.plot(c(107:108,104),'B=60k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  multiple.plot(c(107:108,104,109:110),'B=60k',base.name,
                'TOTAL_COND_SCORE_SUM',y.lim);
  mtext( 'Priv:Pub = 1:10; No loss', side = 3, outer=TRUE, line=-1, cex=1 )

  # note run 104 (do nothing) didn't have the code present to save
  # SUMMED_COND_ABOVE_THRESH yet so have to leave it out
  
  scen.descript <<- c(
                   'All Pub (S)',
                   'All Priv (R)',
                   'All Priv (R) 15yr', 
                   'All Priv (R) 30yr' 
                     )
  
  par( mfrow = c(2,2) );
  y.lim <- c( 200, 20000)
  multiple.plot(c(105:106),'B=20k',base.name,'SUMMED_COND_ABOVE_THRESH',y.lim);
  multiple.plot(c(107:108),'B=60k',base.name,'SUMMED_COND_ABOVE_THRESH',y.lim);
  multiple.plot(c(107:110),'B=60k',base.name,'SUMMED_COND_ABOVE_THRESH',y.lim);
  mtext( 'Priv:Pub = 1:10; No loss', side = 3, outer=TRUE, line=-1, cex=1 )
  
  par( mfrow = c(2,2) );
  y.lim <- c( 0.4, 0.9)
  multiple.plot(c(105:106),'B=20k',base.name,'MEAN_COND_ABOVE_THRESH',y.lim);
  multiple.plot(c(107:108),'B=60k',base.name,'MEAN_COND_ABOVE_THRESH',y.lim);
  multiple.plot(c(107:110),'B=60k',base.name,'MEAN_COND_ABOVE_THRESH',y.lim);
  mtext( 'Priv:Pub = 1:10; No loss', side = 3, outer=TRUE, line=-1, cex=1 )
  
  par( mfrow = c(2,2) );
  y.lim <- c( 200, 40000)
  multiple.plot(c(105:106),'B=20k',base.name,'RESERVED_COND_SCORE_SUM',y.lim);
  multiple.plot(c(107:108),'B=60k',base.name,'RESERVED_COND_SCORE_SUM',y.lim);
  multiple.plot(c(107:110),'B=60k',base.name,'RESERVED_COND_SCORE_SUM',y.lim);
  mtext( 'Priv:Pub = 1:10; No loss', side = 3, outer=TRUE, line=-1, cex=1 )

  par( mfrow = c(2,2) );
  y.lim <- c( 0.0, 0.9)
  multiple.plot(c(105:106),'B=20k',base.name,'RESERVED_COND_SCORE_MEAN',y.lim);
  multiple.plot(c(107:108),'B=60k',base.name,'RESERVED_COND_SCORE_MEAN',y.lim);
  multiple.plot(c(107:110),'B=60k',base.name,'RESERVED_COND_SCORE_MEAN',y.lim);
  mtext( 'Priv:Pub = 1:10; No loss', side = 3, outer=TRUE, line=-1, cex=1 )

  
  
  par( mfrow = c(2,2) );

  time.step = 80;
  min.val.to.display <- 0.13;
  #plot.cond.hist( 105:110, time.step, min.val.to.display );
  
}


plot.14 <- function() {
  
  #---------------------------------------------  
  # Priv:Pub = 1:1, without loss, runing both RANDOM and
  # and CONDITON on each of pub private with the same budget
  #---------------------------------------------

  # testing situation where pub and private costs the same

  par( mfrow = c(2,2) );
  
  y.lim <- c( 2000, 55000);
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)", "Do Nothing" );
  multiple.plot(c(111,113,104),'B=40k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)", "Do Nothing" );
  multiple.plot(c(112,114,104),'B=40k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);

  y.lim <- c( 100, 18000) ;
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)" );
  multiple.plot(c(111,113),'B=40k',base.name,'SUMMED_COND_ABOVE_THRESH',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)" );
  multiple.plot(c(112,114),'B=40k',base.name,'SUMMED_COND_ABOVE_THRESH',y.lim);

  mtext( "Priv:Pub = 1:1; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )


  # -- NEW SCREEN -- 

  y.lim <- c( 2000, 55000);
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)", "Do Nothing" );
  multiple.plot(c(115,117,104),'B=40k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)", "Do Nothing" );
  multiple.plot(c(116,118,104),'B=40k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);

  y.lim <- c( 100, 18000) ;
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)" );
  multiple.plot(c(115,117),'B=40k',base.name,'SUMMED_COND_ABOVE_THRESH',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)" );
  multiple.plot(c(116,118),'B=40k',base.name,'SUMMED_COND_ABOVE_THRESH',y.lim);
  
  mtext( "Priv:Pub = 1:1; No Loss", side = 3, outer=TRUE, line=-1, cex=1 )

  
  # -- NEW SCREEN -- 

  y.lim <- c( 2000, 55000);
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)", "Do Nothing" );
  multiple.plot(c(119,121,104),'B=80k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)", "Do Nothing" );
  multiple.plot(c(120,122,104),'B=80k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);

  y.lim <- c( 100, 18000) ;
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)" );
  multiple.plot(c(119,121),'B=80k',base.name,'SUMMED_COND_ABOVE_THRESH',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)" );
  multiple.plot(c(120,122),'B=80k',base.name,'SUMMED_COND_ABOVE_THRESH',y.lim);
  
  mtext( "Priv:Pub = 1:1; No Loss", side = 3, outer=TRUE, line=-1, cex=1 )


  
  # -- NEW SCREEN -- 
  
  y.lim <- c( 0.35, 0.9);
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)" );
  multiple.plot(c(111,113),'B=40k',base.name,'MEAN_COND_ABOVE_THRESH',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)" );
  multiple.plot(c(112,114),'B=40k',base.name,'MEAN_COND_ABOVE_THRESH',y.lim);

  #mtext( "Priv:Pub = 1:1; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )

  
  y.lim <- c( 200, 28000)
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)" );
  multiple.plot(c(111,113),'B=40k',base.name,'RESERVED_COND_SCORE_SUM',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)" );
  multiple.plot(c(112,114),'B=40k',base.name,'RESERVED_COND_SCORE_SUM',y.lim);

  mtext( "Priv:Pub = 1:1; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )

  # -- NEW SCREEN -- 

  
  y.lim <- c( 0.35, 0.9);
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)" );
  multiple.plot(c(115,117),'B=40k',base.name,'MEAN_COND_ABOVE_THRESH',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)" );
  multiple.plot(c(116,118),'B=40k',base.name,'MEAN_COND_ABOVE_THRESH',y.lim);

  #mtext( "Priv:Pub = 1:1; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )

  
  y.lim <- c( 200, 28000)
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)" );
  multiple.plot(c(115,117),'B=40k',base.name,'RESERVED_COND_SCORE_SUM',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)" );
  multiple.plot(c(116,118),'B=40k',base.name,'RESERVED_COND_SCORE_SUM',y.lim);

  mtext( "Priv:Pub = 1:1; No Loss", side = 3, outer=TRUE, line=-1, cex=1 )

  
  # -- NEW SCREEN -- 

  
  y.lim <- c( 0.35, 0.9);
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)" );
  multiple.plot(c(119,121),'B=80k',base.name,'MEAN_COND_ABOVE_THRESH',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)" );
  multiple.plot(c(120,122),'B=80k',base.name,'MEAN_COND_ABOVE_THRESH',y.lim);

  #mtext( "Priv:Pub = 1:1; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )

  
  y.lim <- c( 200, 28000)
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)" );
  multiple.plot(c(119,121),'B=80k',base.name,'RESERVED_COND_SCORE_SUM',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)" );
  multiple.plot(c(120,122),'B=80k',base.name,'RESERVED_COND_SCORE_SUM',y.lim);

  mtext( "Priv:Pub = 1:1; No Loss", side = 3, outer=TRUE, line=-1, cex=1 )


  # -- NEW SCREEN -- 
  
  par( mfrow = c(2,2) );
  y.lim <- c( 0, 0.9);
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)" );
  multiple.plot(c(111,113),'B=40k',base.name,'RESERVED_COND_SCORE_MEAN',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)" );
  multiple.plot(c(112,114),'B=40k',base.name,'RESERVED_COND_SCORE_MEAN',y.lim);

  mtext( "Priv:Pub = 1:1; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )

   # -- NEW SCREEN -- 
  
  par( mfrow = c(2,2) );
  y.lim <- c( 0, 0.9);
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)" );
  multiple.plot(c(115,117),'B=40k',base.name,'RESERVED_COND_SCORE_MEAN',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)" );
  multiple.plot(c(116,118),'B=40k',base.name,'RESERVED_COND_SCORE_MEAN',y.lim);

  mtext( "Priv:Pub = 1:1; No Loss", side = 3, outer=TRUE, line=-1, cex=1 )

   # -- NEW SCREEN -- 
  
  par( mfrow = c(2,2) );
  y.lim <- c( 0, 0.9);
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (S)" );
  multiple.plot(c(119,121),'B=80k',base.name,'RESERVED_COND_SCORE_MEAN',y.lim);

  scen.descript <<- c( "All Pub  (R)", "All Priv (R)" );
  multiple.plot(c(120,122),'B=80k',base.name,'RESERVED_COND_SCORE_MEAN',y.lim);

  mtext( "Priv:Pub = 1:1; No Loss", side = 3, outer=TRUE, line=-1, cex=1 )



   # -- NEW SCREEN -- 
  
  par( mfrow = c(2,2) );
  time.step = 80;
  min.val.to.display <- 0.13;
  base.dir <- '..\\all_results\\';
  plot.cond.hist( 111:114, time.step, min.val.to.display, base.dir );

  
}




plot.15 <- function() {

  #---------------------------------------------  
  # Testing the 3d plotting for runs both runs 
  # 105 and 106
  #---------------------------------------------
 
  time.steps <- seq( 20, 80, 10 )
  base.dir <-
    'D:\\analysis\\reserve_selection\\svn\\framework2\\runall\\results\\run';
  
  max.z.value <- 15000
  extract.data.for.3d.plots( 105:106, base.dir, time.steps, max.z.value);

  # to replot the last graph use:
  # make.3d.plots(time.steps, cond.vec, 106 )
  
}


plot.15.5 <- function() {

  #---------------------------------------------  
  # Testing the 3d plotting for runs both runs 
  # 105 and 106
  #---------------------------------------------
 
  time.steps <- seq( 20, 100, 10 );
  base.dir <-
    'I:\\COMMON\\GENERAL\\E&P\\rdv\\results\\2009\\S_LT\\2009-07-13\\run';

  max.z.value <- 8500
  extract.data.for.3d.plots( c(143,146), base.dir, time.steps, max.z.value);
  
  base.dir <-
    'I:\\COMMON\\GENERAL\\E&P\\rdv\\results\\2009\\KS_DT\\2009-07-11\\run';

  max.z.value <- 8500
  extract.data.for.3d.plots( c(123,126), base.dir, time.steps, max.z.value);
  


}

plot.16 <- function() {

  #----------------------------------------------------
  # Getting ready for final runs for the paper
  # Extended the run time to 100 years (in 5 year steps)
  #-----------------------------------------------------


  # 1:20 cost ratio
  par( mfrow = c(2,2) );
  
  y.lim <- c( 15000, 54000);
  multiple.plot(c(123,126,131,132),'B=40k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  
  y.lim <- c( 100, 18000) ;
  multiple.plot(c(123,126,131,132),'B=40k',base.name,'SUMMED_COND_ABOVE_THRESH',y.lim);
  
  y.lim <- c( 0.35, 0.9);
  multiple.plot(c(123,126,131,132),'B=40k',base.name,'MEAN_COND_ABOVE_THRESH',y.lim);

  y.lim <- c( 0.0, 0.9);
  multiple.plot(c(123,126,131,132),'B=40k',base.name,'RESERVED_COND_SCORE_MEAN',y.lim);
  
  mtext( "Priv:Pub = 1:10; no loss", side = 3, outer=TRUE, line=-1, cex=1 )
  
  # -- NEW SCREEN --
  # 1:20 cost ratio

  y.lim <- c( 15000, 54000);
  multiple.plot(c(127,130),'B=40k',base.name,'TOTAL_COND_SCORE_SUM',y.lim);
  
  y.lim <- c( 100, 18000) ;
  multiple.plot(c(127,130),'B=40k',base.name,'SUMMED_COND_ABOVE_THRESH',y.lim);
  
  y.lim <- c( 0.35, 0.9);
  multiple.plot(c(127,130),'B=40k',base.name,'MEAN_COND_ABOVE_THRESH',y.lim);

  y.lim <- c( 0.0, 0.9);
  multiple.plot(c(127,130),'B=40k',base.name,'RESERVED_COND_SCORE_MEAN',y.lim);
  
  mtext( "Priv:Pub = 1:20; no loss", side = 3, outer=TRUE, line=-1, cex=1 )

 

}
plot.17 <- function() {

  #---------------------------------------------  
  # Getting ready for final runs for the paper
  # Extended the run time to 100 years (in 5 year steps)
  #---------------------------------------------

  par( mfrow = c(2,2) );
  scen.descript <<- c( "All Pub  (S)", "All Priv (R)", "Do Nothing",
                      "Mixed (S)", "Mixed (R)" );
  
  # 1:20 cost ratio
  paper.plots.4.var( c(123,126, 139), 'B=40k' );
  mtext( "Priv:Pub = 1:10; no loss", side = 3, outer=TRUE, line=-1, cex=1 )
  
  # -- NEW SCREEN --
  
  # 1:20 cost ratio
  paper.plots.4.var( c(127,130, 139), 'B=40k' );
  mtext( "Priv:Pub = 1:20; no loss", side = 3, outer=TRUE, line=-1, cex=1 )
  

  # -- NEW SCREEN --
  
  # 1:10 cost ratio with loss
  paper.plots.4.var( c(143,146, 141), 'B=40k' );
  mtext( "Priv:Pub = 1:10; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )


}


plot.18 <- function() {

  #---------------------------------------------  
  # Test with the prob of crossing threshold set 
  # to a 1.
  # 
  #---------------------------------------------

  par( mfrow = c(2,2) );
  scen.descript <<- c( "All Pub  (S)", "All Pub (R)",
                      "All Priv (S)", "All Priv (R)",
                      "Do Nothing" )
  
  # 1:20 cost ratio
  paper.plots.4.var( c(135,138,139), 'B=40k' );
  mtext( "Priv:Pub = 1:10; no loss, Prob thresh cross =1 ",
        side = 3, outer=TRUE, line=-1, cex=1 )
}



plot.19 <- function() {


  #---------------------------------------------  
  # first cut at some final plots for the paper 
  # PAPER PLOT
  # Figure 3 in the paper
  #---------------------------------------------

  par( mfrow = c(3,2) );
  scen.descript <<- c( "All public ", "All private", "Mixed",
                      "Do nothing"  );
  
  # 1:20 cost ratio
  paper.plots.2.var( c(127,130, 148, 139), 'No development; 1:20 cost ratio',
                    c( '(a)', '(b)'), 63, c(51500,11500) );


  # -- NEW SCREEN --
  
  # 1:10 cost ratio
  paper.plots.2.var( c(123,126,147, 139), 'No development; 1:10 cost ratio',
                    c( '(c)', '(d)'), 63, c(51500,11500) );


  
  paper.plots.2.var( c(143,146, 149, 141), 'Development; 1:10 cost ratio',
                    c( '(e)', '(f)'), 63, c(51500,11500) );

  #mtext( "Priv:Pub = 1:10; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )

  
  # -- NEW SCREEN --
  
  # 1:10 cost ratio with loss
  #paper.plots.4.var( c(143,146, 141), 'B=40k' );
  #mtext( "Priv:Pub = 1:10; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )

plotfile.name <- "Fig3.emf";  #  Change extension if not eps.
savePlot (filename = plotfile.name,
          type = "emf")
}


plot.20 <- function() {
  #---------------------------------------------  
  # This is figure 4 from the paper
  # NOTE: plot15.5() needs to be run first 
  #---------------------------------------------


  # 3d contour plots. 
  par( mfrow = c(2,2) );

  
  z.lims <- c(0, 3500)
  plot.3d.contours( c(123,126), z.lims, 'No development; 1:10 cost ratio', '(a)' )

  plot.3d.contours( c(143,146), z.lims, 'Development; 1:10 cost ratio', '(b)'  )



  
  time.step = 80;
  min.val.to.display <- 0.15;

  #plot(1)
  base.dir <-
    'I:\\COMMON\\GENERAL\\E&P\\rdv\\results\\2009\\S_LT\\2009-07-13\\run143\\'
  #plot.cond.hist( 143, 50, min.val.to.display, base.dir );
  #plot.cond.hist( 143, 80, min.val.to.display, base.dir );
  
  base.dir <-
    'I:\\COMMON\\GENERAL\\E&P\\rdv\\results\\2009\\S_LT\\2009-07-13\\run146\\'
  #plot.cond.hist( 146, 50, min.val.to.display, base.dir );
  #plot.cond.hist( 146, 80, min.val.to.display, base.dir );

  base.dir <-
    'I:\\COMMON\\GENERAL\\E&P\\rdv\\results\\2009\\KS_DT\\2009-07-11\\run123\\'
  #plot.cond.hist( 123, 50, min.val.to.display, base.dir );
  #plot.cond.hist( 123, 80, min.val.to.display, base.dir );
  
  base.dir <-
    'I:\\COMMON\\GENERAL\\E&P\\rdv\\results\\2009\\KS_DT\\2009-07-11\\run126\\'
  #plot.cond.hist( 126, 50, min.val.to.display, base.dir );
  #plot.cond.hist( 126, 80, min.val.to.display, base.dir );

plotfile.name <- "Fig4.emf";  #  Change extension if not eps.
savePlot (filename = plotfile.name,
          type = "emf")

  

}


plot.21 <- function() {
  
  #---------------------------------------------  
  # results with the new condition with no threshold
  #---------------------------------------------


  par( mfrow = c(2,2) );
  scen.descript <<- c( "All Pub  (S)", "All Priv (R)", "Mixed",
                      "Do Nothing"  );

  paper.plots.4.var( c(143,146, 149, 141), 'old cond model' );
  mtext( "Priv:Pub = 1:10; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )

  
  # new cond model with no threshold
  paper.plots.4.var( c(165:167, 168), 'New cond model' );
  mtext( "Priv:Pub = 1:10; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 );
  
  paper.plots.4.var( c(169:171, 168), 'New cond model' );
  mtext( "Priv:Pub = 1:10; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 );


}


plot.22 <- function() {

  
  #---------------------------------------------  
  # Comparing a smaller budget of 20k (to older runs 
  # with a budget of 40k). 20k looks more interesting
  #---------------------------------------------

  par( mfrow = c(2,2) );
  
  scen.descript <<- c( "All Pub  (S)", "All Priv (R)", "Mixed",
                      "Do Nothing"  );

  #  budget of 40k - no loss 
  paper.plots.4.var( c(123,126, 147, 141), 'B = 40k' );
  mtext( "Priv:Pub = 1:10; No loss", side = 3, outer=TRUE, line=-1, cex=1 )

  
  # smaller budget of 20k - no loss 
  paper.plots.4.var( c(159:161, 141), 'B = 20k' );
  mtext( "Priv:Pub = 1:10; No Loss", side = 3, outer=TRUE, line=-1, cex=1 );


  #  budget of 10k - no loss 
  paper.plots.4.var( c(178,180, 147, 141), 'B = 10k' );
  mtext( "Priv:Pub = 1:10; No loss", side = 3, outer=TRUE, line=-1, cex=1 )
 

  
  #  budget of 40k - loss 
  paper.plots.4.var( c(143,146, 149, 141), 'B = 40k' );
  mtext( "Priv:Pub = 1:10; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 )

  
  # smaller budget of 20k - loss 
  paper.plots.4.var( c(162:164, 141), 'B = 20k' );
  mtext( "Priv:Pub = 1:10; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 );
  
  # smaller budget of 10k - loss 
  paper.plots.4.var( c(181:182, 141), 'B = 10k' );
  mtext( "Priv:Pub = 1:10; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 );

  

}



plot.23 <- function() {


  #---------------------------------------------  
  # Testing plot for 1:30 ratio
  # 
  #---------------------------------------------

  par( mfrow = c(2,2) );
  scen.descript <<- c( "All Pub  (S)", "All Priv (R)", 
                      "Do Nothing"  );
  
  # 1:10 cost ratio
  paper.plots.4.var( c(123,126, 139), 'Priv:Pub = 1:10; no loss' );
  
  # -- NEW SCREEN --
  
  # 1:20 cost ratio
  paper.plots.4.var( c(127,130, 139), 'Priv:Pub = 1:20; no loss' );
  
  # -- NEW SCREEN --
  
  # 1:30 cost ratio
  paper.plots.4.var( c(155,158, 139), 'Priv:Pub = 1:30; no loss' );


}



plot.24 <- function() {

  
  #---------------------------------------------  
  # using a smaller budget of 20k to get some final 
  # results 
  #---------------------------------------------

  par( mfrow = c(3,2) );
  
  scen.descript <<- c( "All Pub (S)", "All Priv (R)", "Mixed",
                      "Do Nothing"  );

  
  # smaller budget of 20k - no loss 
  paper.plots.2.var( c(159:161, 141), 'Priv:Pub = 1:10; No Loss' );
  
  # smaller budget of 10k - no loss  1:20 cost ratio
  paper.plots.2.var( c(172:174, 141), 'Priv:Pub = 1:20; No loss' );
  
  # smaller budget of 20k - loss 
  paper.plots.2.var( c(162:164, 141), 'Priv:Pub = 1:10; 90 PUs/ts' );

  mtext( "B = 20k", side = 3, outer=TRUE, line=-1, cex=1 );
  
  
  # smaller budget of 20k - loss 1:20 cost ratio
  #paper.plots.2.var( c(175:177, 141), 'B = 20k' );
  #mtext( "Priv:Pub = 1:20; 90 PUs/ts", side = 3, outer=TRUE, line=-1, cex=1 );
  

  

}



plot.25 <- function() {
  #---------------------------------------------  
  # paper plot: figure 5
  # NOTE: plot15.5() needs to be run first 
  #---------------------------------------------

  par( mfrow = c(1,3) )

  min.x.val.to.display <- 0.0;

  base.dir <-
    'I:\\COMMON\\GENERAL\\E&P\\rdv\\results\\2009\\KS_DT\\2009-07-11\\run126\\'
  #plot.cond.hist( 126, 50, min.val.to.display, base.dir );
  plot.cond.hist( 126, 80, min.x.val.to.display, 116000, base.dir,
                 'All Private; 1:10 cost ratio', '(a)', 0.3, 105500 );

  h.val = 1900;

  #abline( h = h.val, col = 'grey' );
  
  base.dir <-
    'I:\\COMMON\\GENERAL\\E&P\\rdv\\results\\2009\\KS_DT\\2009-07-11\\run123\\'

  #plot.cond.hist( 123, 50, min.x.val.to.display, base.dir );
  plot.cond.hist( 123, 80, min.x.val.to.display, 116000, base.dir,
                 'All public; 1:10 cost ratio', '(b)', 0.3, 105500 );

  #abline( h = h.val, col = 'grey' );

  min.val.to.display <- 0.2;
  plot.cond.hist( 123, 80, min.val.to.display, 1700, base.dir,
                 'All public; 1:10 cost ratio', '(c)', 0.3, 1570  );
 

  #abline( h = h.val, col = 'grey' );

plotfile.name <- "Fig5.emf";  #  Change extension if not eps.
savePlot (filename = plotfile.name,
          type = "emf")

  

 
}
