setwd("/Users/bill/rdv/R/ErrorModel")

b00807092-10:R bill$ svn commit ErrorModel -m "Temporary changes to ErrorModel classes to allow ascelin to use the truncated normal error model.  This is a quick fix that will be replaced later and right now you should only use normal and additive error model."


num.reps <- 1000
ret.values <- rep (-1, num.reps)
mean.value <- 0
sd <- 0.1
lower.bound <- -0.7
upper.bound <- 0.3

for (i in 1:num.reps)
    {
    ret.values [i] <- rtnorm (1, mean=mean.value, sd=sd, 
                             lower=lower.bound, 
                             upper=upper.bound)
                       
    cat ("\n    ", i, ": ", ret.values [i])
    }
    
plot (ret.values)    
hist (ret.values)    
                             
   
   
x <- seq(50, 90, by=1)
plot(x, dnorm(x, 70, 10), type="l", ylim=c(0,0.06)) ## standard Normal distribution
lines(x, dtnorm(x, 70, 10, 60, 80), type="l")       ## truncated Normal distribution

x <- seq(-0.7, 0.3, by=0.1)
plot(x, dnorm(x, 0.70, 0.10), type="l"
#	, ylim=c(0,0.0006)
	) ## standard Normal distribution
lines(x, dtnorm(x, 0.70, 0.10, 0.60, 0.80), type="l")       ## truncated Normal distribution

mean <- 0
sd <- 0.9
lb <- -0.7
ub <- 0.3
x <- seq (-0.8, 0.4, by = 0.05)
plot (x, dtnorm (x, mean, sd, lb, ub), type="l")
lines (x, dnorm (x, mean, sd), type="l")
