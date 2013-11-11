# R file for testing the output during dry runs

cat('In example.R...\n')

print('')
for (i in 1:20) {
  cat('A sample output line: ', i, '\n') 
  Sys.sleep(.005)
} 

cat('Value for test variable 1 is:', variables$test.variable.1, '\n')
cat('Value for test variable 2 is:', variables$test.variable.2, '\n')
cat('Value for test variable 3 is:', variables$test.variable.3, '\n')
cat('Value for test variable 4 is:', variables$test.variable.4, '\n')

cat('The working dir is', getwd(), '\n')
cat('test.output.filename=', outputFiles$test.output.filename, '\n')


test.text <- rep(1:10) 
write.table(test.text, outputFiles$test.output.filename )

