## Some notes below about how to check if a library is already
## installed Might also want to think about the case where it is
## installed but not for the current version of R. - AG 2011.10.31

## # defining this one line function does the trick
## is.installed <- function(mypkg) is.element(mypkg, installed.packages()[,1])

## # test:

## > is.installed ("rjson" )
## [1] TRUE

## > is.installed ("abc" )
## [1] FALSE


## Ref: http://r.789695.n4.nabble.com/test-if-a-package-is-installed-td1750671.html#a1750674



install.packages('RSQLite', repos='http://cran.r-project.org')
install.packages('maptools', repos='http://cran.r-project.org')
install.packages('msm', repos='http://cran.r-project.org')
install.packages('optparse',  repos='http://cran.r-project.org')
install.packages('rjson',  repos='http://cran.r-project.org')
install.packages('rpart',  repos='http://cran.r-project.org')

