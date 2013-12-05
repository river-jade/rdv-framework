# R file for testing the output during dry runs

cat('In example.R...\n')

print('')
for (i in 1:20) {
  cat('A sample output line: ', i, '\n') 
  Sys.sleep(.005)
} 

cat('Value for test variable 1 is:', parameters$test.variable.1, '\n')
cat('Value for test variable 2 is:', parameters$test.variable.2, '\n')
cat('Value for test variable 3 is:', parameters$test.variable.3, '\n')
cat('Value for test variable 4 is:', parameters$test.variable.4, '\n')

cat('The working dir is', getwd(), '\n')
cat('test.output.filename=', parameters$test.output.filename, '\n')


test.text <- rep(1:10) 
write.table(test.text, parameters$test.output.filename )

