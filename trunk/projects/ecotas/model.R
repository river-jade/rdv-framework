# R file for testing the output during dry runs

# define matrix to store the pop trajs 

pop.traj <- matrix( ncol=variables$no.timesteps+1, nrow=variables$reps )
pop.traj[,1] <- variables$init.pop.size

pop.traj.log <- matrix( ncol=variables$no.timesteps+1, nrow=variables$reps )
pop.traj.log[,1] <- log(variables$init.pop.size)


for( r in 1:variables$reps ) {
    
    eta <- rnorm(variables$no.timesteps, mean=0, sd=variables$sd )
    for( t in 1:(variables$no.timesteps) ) {

        pop.traj[r, t+1] <- pop.traj[r,t] * exp(variables$mu) * exp( eta[t] )
        pop.traj.log[r, t+1] <- pop.traj.log[r,t] + variables$mu + eta[t]
        #browser()
    }

}

# calculate the mean pop trajectories
mean.traj.log <- apply( pop.traj.log, 2, mean)
mean.traj <- apply( pop.traj, 2, mean)

#cat('\n***mean traj = \n' )
#print( mean.traj.log )


       #------------------------
       #  Calculate statistics
       #-------------------------



       #------------------------
       #  Write output files
       #-------------------------

cat( '\nRun id =', variables$run.id )
cat( "\noutput file is", outputFiles$output.plot, '\n' )
cat( "\noutput R dump file is", outputFiles$output.dump, '\n' )

# write a graph of a single relisatin (the 1st)
pdf( paste( outputFiles$output.plot, '.single.pdf', sep='' ) )
plot( 0:variables$no.timesteps, pop.traj.log[1,], type='l', ylim=c(2,8),
     xlab="Time (years)", ylab="Log of population size" )
dev.off()

# now make a plot showing all realisations
pdf( paste(outputFiles$output.plot, 'multiple.pdf',sep='') )

for( r in 1:variables$reps) {
    if( r==1 ) plot( 0:variables$no.timesteps, pop.traj.log[r,], type='l', ylim=c(0,8),
            xlab="Time (years)", ylab="Log of population size" )
    else lines (0:variables$no.timesteps, pop.traj.log[r,], type='l' )
}
# plot the mean line
lines(0:variables$no.timesteps, mean.traj.log, type='l', col='red', lwd=4  )

# show the version without the log transformation
for( r in 1:variables$reps) {
    if( r==1 ) plot( 0:variables$no.timesteps, pop.traj[r,], type='l', ylim=c(0,1200),
            xlab="Time (years)", ylab="Population size" )
    else lines (0:variables$no.timesteps, pop.traj[r,], type='l')
}
# plot the mean line
lines(0:variables$no.timesteps, mean.traj, type='l', col='red', lwd=4  )

dev.off()

# Dumpt all the matrix with all the poptrajectories. 
dump( "pop.traj", outputFiles$output.dump )



## pdf(outputFiles$output.plot.pdf)
## plot( 0:50, pop.traj, type='l' )
## dev.off()

#c(variables$run.id, mean.traj.log, 

#dev.copy( png, outputFiles$output.plot); dev.off()
