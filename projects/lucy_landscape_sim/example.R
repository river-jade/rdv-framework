# R file for testing the output during dry runs

# an example of sourcing another R doc
source( "R/w.R" ) 

cat('In test.for.python.dry.run.R...\n')

print('')
for (i in 1:20) {
  cat('A sample output line: ', i, '\n') 
  Sys.sleep(.005)
} 

x <- matrix( nrow=20, ncol=20)
x[] <- 1:(20*20) 


cat('Value for test variable 1 is:', tzar[['test.variable.1']], '\n')
cat('Value for test variable 2 is:', tzar[['test.variable.2']], '\n')
cat('Value for test variable 3 is:', tzar[['test.variable.3']], '\n')
cat('Value for test variable 4 is:', tzar[['test.variable.4']], '\n')

cat('The working dir is', getwd(), '\n')
cat('PAR.testing.output.filename=', tzar[['PAR.testing.output.filename']], '\n')

cat('\n\n##The current working dir is', getwd(), '\n\n' ) 


test.text <- rep(1:10) 

write.table(test.text, tzar[['PAR.testing.output.filename']] )
write.table(x, tzar[['PAR.testing.output.filename2']] )
