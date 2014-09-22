    #  Taken from
    #      https://github.com/hadley/testthat#integration-with-r-cmd-check
    #  on 2014 09 22 where it said that this is now the official way to get
    #  "R CMD check" to run all of your tests for a given package.
library ("testthat")
test_check ("reserveselection")

