#==============================================================================

#               source ('matt.clusteringChapter.knitrVersion.R')

#  setwd ("/Users/bill/D/Projects_RMIT/ML_working_group/Case studies/Matt_clustering_case_study/R")

#==============================================================================

####  NOTE: I've marked a rough development sequence for the changes made 
####        to the code as we explored the problem.  
####        These can be used as the basis of the sequence in the text and 
####        the sweave file.  
####        The changes are marked with comments like:
####                #  Fourth change...

#==============================================================================

#  History:

#  BTL - 2013.08.26
#  Copied to the guppy directory and renamed from matt.nonmodular.v4.R to 
#  matt.clusteringChapter.knitr.R.  
#  Doing this for two reasons.  First, I want to strip out all the irrelevant 
#  stuff and rewrite the whole thing using knitr and/or latex inside of knitr 
#  in RStudio.  This will allow me to embed the output inline and make more 
#  reasonable explanations that are in line with what the book's text should 
#  look like.  Right now, there are scads of comments in the code saying 
#  "change number eighteen" etc.  They don't help see the flow and evolve the 
#  output.  That's why I renamed the file, but I've moved it to the guppy 
#  directory just to get it under version control for now because I'm going to 
#  be making lots and lots of changes.
#  Even though I've moved the code to the guppy directory, I should still be 
#  able to setwd() to the ml clustering chapter directory to work on the data 
#  files and not clutter up the guppy directory with all that.

#  BTL - 2011.02.01 
#  Converting to run on the mac and finding various failures immediately.
#  I'm commenting them out with the following comment marker before adding a 
#  replacement version:  "##macFail##  "
#  The two things that failed immediately were:
#    - The call to windows.options() to turn plot recording on.
#      The mac seems to do it automatically and doesn't even have the 
#      windows.options() call.
#    - The directory separation character is different on the mac, so this:
#          infile.name <- 
#              paste (data.directory, '\\', infile.names [infile.idx], sep='');
#      produces an illegal path name which leads to the following error msg:
#          Error in file(file, "rt") : cannot open the connection
#          In addition: Warning message:
#          In file(file, "rt") :
#            cannot open file 'Data\iris.test.csv': No such file or directory
#     Just need to swap the backslash to be a forward slash to make it work.
#     If I remember correctly, a forward slash may work on all systems in R, 
#     but need to check that.

#==============================================================================

rm (list = ls());    #  Remove any previously existing objects.

OPT.scale <- FALSE;
OPT.PCA <- FALSE;  
OPT.pca.cum.var.explained.cutoff <- 0.75;

num.clusters <- 3;
infile.idx <- 12;    #  maxent env variables



library (cluster)    # 
##macFail##  windows.options (record = TRUE);    #  For MS Windows only???

    #  Fourth change...
##infile.name <- 'Data/wilsons_prom_environmental_features.csv';
#infile.name <- 'Data/iris.test.csv';
#distance.type <- "gower";   #  This doesn't seem to change anything on iris, 
                             #  so maybe it's already invoking it by default.
			                 #  Duh, that's because I never gave the function 
			                 #  calls this as an argument...
    #  Tenth change...
infile.names <- c (
                   'iris.test.csv',   #   1
                   'joona.test.csv',  #   2
                   
                   'wilsons_prom_pres_abs_matrix.csv',               #   3
                   'wilsons_prom_environmental_features.csv',        #   4
                   'wilsons_prom_life_hist.csv',                     #   5
                   'wilsons_prom_physiognomy.csv',                   #   6
                   'wilsons_prom_physiology.csv',                    #   7
                   
                   'wilsons_prom_environmental_features_trunc.csv',  #   8
                   'wilsons_prom_life_hist_trunc.csv',      #   9
                   'wilsons_prom_physiognomy_trunc.csv',    #  10
				                    #  This one only has about 4 coordinates 
						            #  and shows almost nothing interesting 
						            #  either with or without scaling and pca.
						            #  There's basically just a crescent and 
						            #  then a second dispersed set of outliers.
						            #  (NOTE: that still might be something 
						            #   that's worth showing in the development
						            #   of the example since that's the kind 
						            #   of thing that you only find out by 
						            #   trial and error and then decide to 
						            #   toss.  It's the kind of thing that 
						            #   you wouldn't know happened in normal 
						            #   texts that only showed the final, 
						            #   trimmed down behavior.)
                   'wilsons_prom_physiology_trunc.csv',    #  11
                   'maxent.env.points.to.cluster.csv',    #  12
                   'maxent.mult.points.to.cluster.csv',    #  13
                   'maxent.add.points.to.cluster.csv'    #  14
                   
                   );
                   
plot.names <- c (
                 'IrisTest',
                 'JoonaTest', 
                 
                 'PresenceAbsence', 
                 'Env',
                 'LifeHist',
                 'Physiognomy',
                 'Physiology',
                 
                 'EnvTrunc',
                 'LifeHistTrunc',
                 'PhysiognomyTrunc',
                 'PhysiologyTrunc', 
                 
                 'MaxentEnv', 
                 'MaxentMult', 
                 'MaxentAdd'
                 
                 );
				 
#==============================================================================				 

    #----------------------------------------------
    #  Build the full file name including the path.
    #----------------------------------------------
	
data.directory <- 'Data';
output.directory <- 'Output';
#infile.name <- paste (data.directory, '\\', 'wilsons_prom_environmental_features_trunc.csv', sep='');
##macFail##  infile.name <- paste (data.directory, '\\', infile.names [infile.idx], sep='');
infile.name <- paste (data.directory, '/', infile.names [infile.idx], sep='');
			
			
			
    #  Fifth change...
	#  With Iris' data, I'm now wanting to know how different are these 
	#  clusterings with the different methods, that is, how much do they 
	#  agree or disagree?
	#  And, which cases do they disagree on the most?
	#  First though, I can compute agreements somehow (jaccard?  kappa?) 
	#  and then show a heat map with the relative agreement (e.g., total 
	#  agreement votes for each pair of points about whether they're in 
	#  the same cluster or not).  "extra.code.R" has the beginnings of 
	#  jaccard-like calculations around lines 54-75.
	#
	#  Also want to know how good are the clusterings?
	#  Also, how to pick a number of clusters to use?
	#  This can partly be handled by including silhouettes and maybe the 
	#  sum of squares calculations that work on k-means.  Not sure if they 
	#  can be applied directly to any classification or not.  Have to look 
	#  that up...  Just looked in extra.code...  Unfortunately, it's 
	#  calculated by the k-means class.  Plus, it doesn't make sense for 
	#  some of these things because it's based on the mean, which is not 
	#  necessarily useful.  Still worth calculating though?
	#  What about clvalid?  Maybe that's a way to get around this, if I 
	#  can just hand it a clustering and have it only do the validity 
	#  calculations instead of the full clustering...
	
	#  Need to write this code and put a call to it at the end of the file.
	#  It's going to take a bit of modifying overall so that I can keep 
	#  counts of agreement.  Either that, or save all of the results 
	#  and go back at the end to tally them up.  
	#  Use a database?  It's a useful thing for people to know how to do...
	
	#  One more interpretation problem for Iris' data is that the 2D plot 
	#  is only accounting for 40% of the variance, so there is probably a 
	#  better representation possible.  Need to try doing something with 
	#  nmds and plotting things myself.  Either that or use ggobi?
	
	#  For the book though, we need to do something to Matt's data to 
	#  force some of these same issues to come up by having values that 
	#  are Not continuous or else say why you shouldn't cluster discrete 
	#  data...
	
	#  Another option is to do nmds for 3D instead of 2D and then make 
	#  3D scatterplots for those to see if they look any different.  
	#  This might be particularly useful for Iris' data.  
	
	#  Need to turn some of this stuff into functions now as well, so 
	#  that you can try multiple distance measures, cluster counts, etc.
	

	
#------------------
	
  
    #  Can't figure out exactly what's expected to be in the id column 
    #  here.  Need to figure it out and document it better.
    
    #  Also, I never quite remember what's going on with order() vs. 
    #  sort().  Need to write up a little explanation of that in 
    #  Evernote and for inclusion in the R section of the book.
    
data <- read.csv (infile.name, as.is = TRUE);


maxent.cluster.test <- TRUE
num.maxent.indices <- 1000
if (maxent.cluster.test)
    {
    full.num.rows <- dim (data) [1]
    sample.indices <- sample (1:full.num.rows, num.maxent.indices)
    data <- data [sample.indices, 1:3]
    }




id.col <- 1;
data <- data [order (data [ , id.col]), ];
dataPointIDs <- data [ , id.col];    
data <- data [ , -id.col];
	rownames (data) <- dataPointIDs;
data <- unique (data);

cat ("\nOPT.scale = ", OPT.scale, "\n");
  #  *** Second thing to try...
  if (OPT.scale)
  {
  data <- scale (data);
  }

    #  Can't use PCA on Iris' data because there are more columns than rows.
    #  You get the following error message:
    #      Error in princomp.default(data, cor = T) : 
    #      'princomp' can only be used with more units than variables
    #
    #  NOTE:
    #              Could you fool it though by copying the whole data set 
    #              as many times as it takes to get the required number 
    #              of rows?   Copying the full set would make sure that each 
    #              original row had the same weight as in the original data 
    #              set.

cat ("\nOPT.PCA = ", OPT.PCA, "\n");

  #  *** Third thing to try
if (OPT.PCA)
{
cat ("\nOPT.pca.cum.var.explained.cutoff = ", OPT.pca.cum.var.explained.cutoff, "\n");

num.plot.rows <- 1;
num.plot.cols <- 3;
par (mfrow = c(num.plot.rows, num.plot.cols));

data.pca.cor <- princomp (data, cor = T);
#data.pca.cor <- prcomp (data, cor = T);
        #  Note that prcomp also has a screeplot function that you can
        #  run on the data.pca.cor structure instead of the straight plot
        #  function that John specified.  Both outputs look almost identical.
###plot (data.pca.cor, main= 'Screeplot (COR Approach)');
###screeplot (data.pca.cor);
        #  The R Help example has a line with dots instead of bars.
        #  It's quite a bit easier to use to pick out the elbow.
        #  I'm not sure what the "$sdev" is, but it was in the sample
        #  argument and gets at the total number of variables in the pca.
        #  It also works fine just plugging in any value like 75.
screeplot(data.pca.cor, npcs=length(data.pca.cor$sdev), type="lines");

#browser();  
        #  The R help also mentions a biplot function for prcomp.
        #  I have run it here, but it's such a mess that I'm not sure
        #  what it's supposed to show.
        #
        #  NOTE/QUESTION: If you use prcomp() instead of princomp(),
        #                 you get the following warning which you don't get
        #                 if you used princomp():
        #  Warning message:
        #  In arrows(0, 0, y[, 1L] * 0.8, y[, 2L] * 0.8, col = col[2L], length = arrow.len) :
        #    zero-length arrow is of indeterminate angle and so skipped
####biplot (data.pca.cor);

        #  NOTE/QUESTION: These two commands work fine after princomp()
        #                 but return NULL if you use prcomp().
##print (data.pca.cor$scores [1:5,1:6]);
##print (data.pca.cor$loadings);
##print (data.pca.cor$loadings [1:5,1:6]);
        #  "scores" contains the transformed data points.
dim (data.pca.cor$scores)
        #  "loadings" contains the transforms to apply to the data to get the
        #  scores.
dim (data.pca.cor$loadings)
        #  "predict" applies the pca loadings to transform a data point into
        #  the new pca space.
        #  This call to predict produces the first line of data.pca.cor$scores,
        #  i.e., e1 == data.pca.cor$scores[1,].
####e1 <- predict (data.pca.cor, data[1,]);

         
#data.pca.cov <- princomp (data, cor = F);
##data.pca.cov <- prcomp (data, cor = F);
#plot (data.pca.cov, main= 'Screeplot (COV Approach)');
#print (data.pca.cov$scores [1:5,1:6]);

    #  Look at the scree plot and pick the last pca coordinate to include,
    #  i.e., the "elbow".

    #  Or, since it shows the amount of variance explained to that point,
    #  pick a cutoff value and use that to choose the last coordinate to
    #  include.

#browser();

num.pca.coords <- length (data.pca.cor$sdev);
variances <- data.pca.cor$sdev * data.pca.cor$sdev;
cum.var.explained <- cumsum (variances) / num.pca.coords;
plot (cum.var.explained);
cat ("\n\ncumulative variance explained at each pca coordinate: \n");
for (pca.coord in 1:num.pca.coords)
  {
  cat ("  ", pca.coord, "  ",
       variances [pca.coord], "  ",
       cum.var.explained [pca.coord],
       "\n",  sep='');
  }
cat ("\n\n");

	#  Eleventh change...
	#  When I wanted to include all coordinates, I just set the cutoff to be 1.0, 
	#  but floating point arithmetic meant that cum.var.explained didn't quite make 
	#  it to 1.0 even when all values were added up.  So, I had to create an epsilon 
	#  to bump it up slightly.
	#  Here's the error message that I got:
	#      pca.elbow =  Inf  (i.e., last pca coord to include)
    #
    #      Error in 1:pca.elbow : result would be too long a vector
    #      In addition: Warning message:
    #      In min(which(cum.var.explained >= OPT.pca.cum.var.explained.cutoff)) :
    #        no non-missing arguments to min; returning Inf
	#  I picked 0.00001 out of thin air.  If it hadn't worked, I would have tried 
	#  something slightly larger.  I might be able to go with something much smaller 
	#  too, but I don't feel like messing with it right now...
epsilon <- 0.00001;
pca.elbow <-
    min (which ((cum.var.explained + epsilon) >= OPT.pca.cum.var.explained.cutoff));

cat ("pca.elbow = ", pca.elbow, " (i.e., last pca coord to include)\n\n");
  
#pca.elbow <- 8;
###data.to.cluster <- data.pca.cor$scores [ , 1:pca.elbow];
if (pca.elbow < 2)
{
pca.output.points <- as.matrix (data.pca.cor$scores, nrow = length (data.pca.cor$scores), ncol = 1);
plot(0);
} else
{
pca.output.points <- data.pca.cor$scores [ , 1:pca.elbow];
###plot (data.to.cluster [ , 1:2]);
plot (pca.output.points [ , 1:2]);
}

data <- pca.output.points;
#  pca.output.distances <- daisy (pca.output.points);
}



  
  
  
original.data.distances <- daisy (data);
data.distances <- original.data.distances;

num.plot.rows <- 2;
num.plot.cols <- 2;
par (mfrow = c(num.plot.rows, num.plot.cols));

cat("\nStarting kmeans...\n");
###plot(0);    #  dummy plot to make all plots fall in same location
num.kmeans.restarts <- 1;
kmeans.results <-
  kmeans (data,
          num.clusters,
          nstart = num.kmeans.restarts);
data.clus <- kmeans.results$cluster;		#  If you don't do this, you get error msg...  
clusplot (data.distances,
		  data.clus,
		  diss = TRUE, 
		  main = 'kmeans results', 
		  asp = 1, 
		  col.p = data.clus,
             labels = 4);  # color points and label ellipses
#          labels = 5);  # color points and label ellipses and identify pts

cat("\nStarting pam...\n");
pam.result <- pam (data.distances,  #  dissimilarity matrix for the data
                   num.clusters,  #  number of clusters
                   diss = TRUE); # use dissim, not original values
data.clus <- pam.result$clustering;
clusplot (data.distances,
		  data.clus,
		  diss = TRUE, 
		  main = 'pam results', 
		  asp = 1, 
		  col.p = data.clus,
             labels = 4);  # color points and label ellipses
#          labels = 5);  # color points and label ellipses and identify pts

###plot(0);    #  dummy plot to make all plots fall in same location
cat("\nStarting hclust single...\n");
clus <- hclust (data.distances, "single");
plot (clus);
rect.hclust (clus, num.clusters);
data.clus <- cutree (clus, num.clusters);
clusplot (data.distances,
		  data.clus,
		  diss = TRUE, 
		  main = 'single linkage results', 
		  asp = 1, 
		  col.p = data.clus,
             labels = 4);  # color points and label ellipses
#          labels = 5);  # color points and label ellipses and identify pts

###plot(0);    #  dummy plot to make all plots fall in same location
cat("\nStarting hclust complete...\n");
cluc <- hclust (data.distances, "complete");
plot (cluc);
rect.hclust (cluc, num.clusters);
data.clus <- cutree (cluc, num.clusters);
clusplot (data.distances,
		  data.clus,
		  diss = TRUE, 
		  main = 'complete linkage results', 
		  asp = 1, 
		  col.p = data.clus,
             labels = 4);  # color points and label ellipses
#          labels = 5);  # color points and label ellipses and identify pts

###plot(0);    #  dummy plot to make all plots fall in same location
cat("\nStarting hclust average...\n");
clua <- hclust (data.distances, "average");
plot (clua);
rect.hclust (clua, num.clusters);
data.clus <- cutree (clua, num.clusters);
clusplot (data.distances,
		  data.clus,
		  diss = TRUE, 
		  main = 'average linkage results', 
		  asp = 1, 
		  col.p = data.clus,
             labels = 4);  # color points and label ellipses
#          labels = 5);  # color points and label ellipses and identify pts

cat("\nStarting divisive...\n");
clud <- diana (data.distances);
#pltree (dc);    #  NOTE: pltree(), not plclust().
plot (clud, which.plots = c(2));    
                    #  Sixth change - adding "which.plots"
				    #  to get rid of banner plots
				    #  In text, should note that each of these 
				    #  plot calls invokes a more specific 
				    #  plotting routine, in this case, it's 
				    #  called plot.diana.  So, there must be 
				    #  one for each of the clustering types.
				    #  plot.agnes and plot.partition, etc. 
				    #  are worth looking at.  
				    #  Something has an "ask=TRUE" argument 
				    #  that looks like you can have it ask 
				    #  you whether to show the plot or not 
				    #  when you're doing lots of them.  
				    #  However, I just tried adding it to 
				    #  the diana plot and it didn't do anything, 
				    #  so I'm not sure what's up with that...
				    #
				    #  Would also like to be able to turn the 
				    #  ellipses and inter-center lines on and 
				    #  off.  Sometimes they're very helpful, 
				    #  but other times they just clutter the 
				    #  graph too much, particularly when you 
				    #  get more than 4 or 5 clusters.
									
				    #  Twelfth change...
				    #  The dendrograms for 654 points are just a 
				    #  black blob after 5 or 6 levels, so I'm 
				    #  not sure whether they're even worth showing - 
				    #  especially since it doesn't help to truncate 
				    #  them before the leaves, other than to show 
				    #  to some degree how balanced they are or aren't.
									
				    #  Thirteenth change...
				    #  Things are a lot slower with Matt's data, so 
				    #  I should add the arguments that limit how much 
				    #  stuff is copied back to the returned values.  
				    #  In particular, I think I saw something that 
				    #  said you could not copy the distances back 
				    #  or soemthing like that, basically, things that 
				    #  you alreadyy know and don't need returned are 
				    #  passed back and the copying uses up time and 
				    #  memory.
									
				    #  Fourteenth chanage...
				    #  All of these plots of Matt's data are showing a 
				    #  horshoe shape.  Can't remember what that meant 
				    #  other than not a good pca.  
				    #  Not sure what's the right thing to do.  Need to 
				    #  look that up.  May want to try nmds with more 
				    #  than two coordinates to try to take up some of 
				    #  the non-linearity?
									
				    #  Fifteenth change...
				    #  Trying scaling but not pca to see if that helps, 
				    #  but the display is still showing the results laid 
				    #  over a pca, so it's still shaped like horseshoe.
									
				    #  Sixteenth change...
				    #  The display is a bit weird because it always tells 
				    #  you how much of the variance is explained and it 
				    #  doesn't seem like it was saying it explained 100% 
				    #  when I ran pca but used all of the coordinates.  
				    #  Maybe that's just because the plot is only showing 
				    #  the first two coordinates no matter what.  Therefore,
				    #  it should explain however much the first two coordinates 
				    #  explained in the original pca.  Need to check this.
									
				    #  Eighteenth change...
				    #  Looking at Matt's presence absence clusters, the 
				    #  plot says it only explains 25% of the variance.  
				    #  This is where it seems like you'd 
				    #  want to break out ggobi and apply it to the clusters 
				    #  instead of using the 2D or even 3D plot.   
				    #  Since 75% of the variance is missing, you can't tell 
				    #  whether the clusters make sense overall.  
				    #  One other thing to do is to see if you can do what 
				    #  Matt had talked about before and see if you can take 
				    #  the clusters from the environmental variables and 
				    #  overlay them on the species to see if they're still 
				    #  clustered there.  
									
				    #  Nineteenth change...
				    #  Need to combine the environmental variables all into 
				    #  one file and cluster that instead of each one 
				    #  separately.  This could actually be done using cbind 
				    #  after reading each one in separately, rather than 
				    #  doing it outside of R.  
				    #  Also need to introduce some mixed variable types as 
				    #  well as some missing data values.  
				    #  Also, do I need to compute a covariance matrix for the 
				    #  combined data set to see if there's a lot of duplication 
				    #  in the sense of highly correlated variables?  
				    #  And do I need to use the correlation version of pca if 
				    #  I'm using pca?
									
rect.hclust (clud, num.clusters);
data.clus <- cutree (clud, num.clusters);
clusplot (data.distances,
		  data.clus,
		  diss = TRUE, 
		  main = 'divisive clustering results', 
		  asp = 1, 
		  col.p = data.clus,
             labels = 4);  # color points and label ellipses
#          labels = 5);  # color points and label ellipses and identify pts

cat("\nStarting agnes complete...\n");
agn2 <- agnes (data.distances, diss = TRUE, method = "complete")
plot (agn2, which.plots = c(2))
rect.hclust (agn2, num.clusters);
data.clus <- cutree (agn2, num.clusters);
clusplot (data.distances,
		  data.clus,
		  diss = TRUE, 
		  main = 'agnes complete results', 
		  asp = 1, 
		  col.p = data.clus,
             labels = 4);  # color points and label ellipses
#          labels = 5);  # color points and label ellipses and identify pts

cat("\nStarting agnes flexible...\n");
agnf <- agnes (data.distances, diss = TRUE, method = "flexible", par.meth = 0.6)
plot (agnf, which.plots = c(2))
rect.hclust (agnf, num.clusters);
data.clus <- cutree (agnf, num.clusters);
clusplot (data.distances,
		  data.clus,
		  diss = TRUE, 
		  main = 'agnes flexible results', 
		  asp = 1, 
		  col.p = data.clus,
             labels = 4);  # color points and label ellipses
#          labels = 5);  # color points and label ellipses and identify pts

cat("\nStarting agnes ward...\n");
agnw <- agnes (data.distances, diss = TRUE, method = "ward")
plot (agnw, which.plots = c(2))
rect.hclust (agnw, num.clusters);
data.clus <- cutree (agnw, num.clusters);
clusplot (data.distances,
		  data.clus,
		  diss = TRUE, 
		  main = 'agnes ward results', 
		  asp = 1, 
		  col.p = data.clus,
             labels = 4);  # color points and label ellipses
#          labels = 5);  # color points and label ellipses and identify pts


    #  Change number 7
	#  Looping over a number of cluster counts now that Ward looks best or 
	#  at least often looks good.
#num.plot.rows <- 2;
#num.plot.cols <- 4;
#par (mfrow = c(num.plot.rows, num.plot.cols));
				    #  Seventeenth change...
				    #  Looping over the ward results, you don't need to 
				    #  recalculate agnes each time.  You just need to cut 
				    #  the first tree at different levels.  This should 
				    #  speed things up a bit.
#cat("\nStarting agnes ward...\n");
#agnw <- agnes (data.distances, diss = TRUE, method = "ward");

for (num.clusters in 2:9)
{
#agnw <- agnes (data.distances, diss = TRUE, method = "ward")
plot (agnw, which.plots = c(2))
rect.hclust (agnw, num.clusters);
data.clus <- cutree (agnw, num.clusters);
clusplot (data.distances,
		  data.clus,
		  diss = TRUE, 
		  main = paste ('agnes ward', num.clusters, 'clusters'), 
		  asp = 1, 
		  col.p = data.clus,
             labels = 4);  # color points and label ellipses
#          labels = 5);  # color points and label ellipses and identify pts

}  #  end for - different numbers of clusters applied to ward

	#  Change number 8
	#  After running this loop, it looks like 4 is the best cluster count, 
	#  but it has 2 odd points that are in cluster 1 when they look like 
	#  the should be in cluster 3.  
	#  Now need to do the ID thing to see why.
num.clusters <- 4;
cat("\nStarting agnes ward...\n");
agnw <- agnes (data.distances, diss = TRUE, method = "ward")
plot (agnw, which.plots = c(2))
rect.hclust (agnw, num.clusters);
data.clus <- cutree (agnw, num.clusters);
clusplot (data.distances,
		  data.clus,
		  diss = TRUE, 
		  main = paste ('agnes ward', num.clusters, 'clusters'), 
		  asp = 1, 
		  col.p = data.clus,
             labels = 4);  # color points and label ellipses
#          labels = 5);  # color points and label ellipses and identify pts
		  
	#  Change number 9
	#  So, the ID thing says that they are points 26 and 29.
	#  Now need to dump cluster IDs out so that I can look at the data file 
	#  and see which ones are 26 and 29 and how they differ from 
	#  points in cluster 1.  
	#  They're closest to 22 and 13 and then to 25 and 2.
	#  Point 29 is particularly curious because it's right next to points 
	#  7 and 55 and then 31.
	#  27 and 48 are also odd because they're out on their own on the edge 
	#  of cluster 1.  Seems like they belong in a cluster all their own.
	#  Looking at all the other clusterings and cluster counts, those two points 
	#  are never in their own cluster.  They're always at the very edge of 
	#  other clusters.  Maybe this is an issue with projecting down to 2D 
	#  when there are so many other dimensions in the data...
	#  Interestingly though, even though they're right on top of each other, 
	#  pam puts them in separate clusters when it num.clusters = 3.
#...  Have to write this code  ...



if(FALSE)
{
range (data.distances);

cor (data.distances, cophenetic (clus));  #  
cor (data.distances, cophenetic (cluc));  #  
cor (data.distances, cophenetic (clua));  #  
cor (data.distances, cophenetic (clud));  #  
}
#==============================================================================

			  
	  