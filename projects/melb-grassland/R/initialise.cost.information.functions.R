

#  source( "initialise.cost.information.functions.R" )



# Note that it's not very efficient to be building this distribution
# for each planning unit. Should change the code in
# initialise.cost.information.R. Leaving as is for now to test this
# and get it working.


sample.from.dist.of.real.melb.costs <- function() {

  # source the data file. This creates the object 
  # costs.melb.grassland.parcels

  source("costs.melb.grassland.parcels.Rdump")

  # make the distribution
  h.info <- hist( costs.melb.grassland.parcels$Price_per_metre_08, 
                  breaks = 80, plot = FALSE )

  # now construct a continous function that describes the histogram

  cost.vec <- c( 0, h.info$mids )               # x values
  cost.counts <- c(0, h.info$counts )           # y values

  # normalise and add 1 every hist entry (so there are no zero bins)
  prob.values <- (cost.counts+1) / sum( cost.counts + 1 )
  
  # make the function 
  cost.fn <- approxfun( cost.vec, prob.values  );	
  #curve( cost.fn(x))



  # Now sample from values this distribution

  max.cost <- 22
  cost.values <- seq( 0.04, max.cost, 0.001 ) 
  cost.probs <- cost.fn( cost.values )

  # sample 1 number from the distribution and return it
  real.dist.sample <- sample( cost.values, size = 1, 
                               prob = cost.probs, replace = TRUE )
 #hist( real.dist.samples, breaks = 80)

 return( real.dist.sample );

}



sample.lognorm.dist.fitted.to.real.melb.costs <- function( area.in.ha ) {

  # these are the parameters for the lognormal dist 
  # obtained from fitting the real melbourne cost data
  # ignoring area
	
  #meanlog.from.fit <- 0.3695849;
  #sdlog.from.fit <- 1.129054;


  # cost is also correlated with area so have made 2 distributions. 
  # 1 for areas below 150 ha and 1 for areas above.

  if( area.in.ha < 150 ) {
    # BELOW 150 ha
    meanlog.from.fit <- 0.39294818;
    sdlog.from.fit <- 1.01190716;
    # plot the function to check it out 
    # curve( dlnorm(x, meanlog=meanlog.from.fit, sdlog=sdlog.from.fit), 
    #         xlim = c(0,10) )

  } 

  if( area.in.ha  >= 150 ) {
    # ABOVE 150 ha
    meanlog.from.fit <- -1.15930125;
    sdlog.from.fit <-  0.88490993;
    # plot the function to check it out 
    # curve( dlnorm(x, meanlog=meanlog.from.fit, sdlog=sdlog.from.fit), 
    #         xlim = c(0,10) )

}



  cost.value <- rlnorm( 1, meanlog = meanlog.from.fit, 
                        sdlog = sdlog.from.fit);

  return(cost.value);
}

