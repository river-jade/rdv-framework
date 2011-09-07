#------------------------------------------------------------
    #            generate.pu.assessment.biases.R                #
    #
    #
    #  Generates two vectors of positive and negative biases
    #  to be used as the fixed assessment error for each pu
    #
    #  DWM - 16 November 2009
    #
    #  source('..\\R\\generate.pu.assessment.biases.R')        #
    #------------------------------------------------------------
    
# Developer assessments overestimate the pu score by an amount drawn from
# the positive side of a normal distribution. At each time step this quantum
# is multiplied by the current pu score (done in offset.model.R)

# Seller assessments underestimate the score in the same way



library(msm);

generate.pu.assessment.biases <- function( 
                                  number.of.pus, 
                                  Developer.error.upper.bound,
                                  Developer.error.lower.bound, 
                                  Seller.error.upper.bound,
                                  Seller.error.lower.bound, 
                                  Developer.error.mean,
                                  Seller.error.mean,
                                  Developer.error.st.deviation,
                                  Seller.error.st.deviation )
{
  biases.mx <- matrix(0, nrow = number.of.pus, ncol = 2);

  for( i in 1:number.of.pus )
  {

    # developer biases
    biases.mx[i,1] <-  1 + rtnorm( 1, 
                                   Developer.error.mean, 
                                   Developer.error.st.deviation, 
                                   Developer.error.lower.bound,
                                   Developer.error.upper.bound 
                                 );
    # seller biases
    biases.mx[i,2] <-  1 + rtnorm( 1, 
                                   Seller.error.mean, 
                                   Seller.error.st.deviation, 
                                   Seller.error.lower.bound,
                                   Seller.error.upper.bound 
                                 );
  }

 return( biases.mx);
}

