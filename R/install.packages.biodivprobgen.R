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


    #  Taken from install.packages.R

install.packages('RSQLite', dependencies=TRUE, repos='http://cran.r-project.org')
install.packages('maptools', dependencies=TRUE, repos='http://cran.r-project.org')
install.packages('msm', dependencies=TRUE, repos='http://cran.r-project.org')
install.packages('optparse',  dependencies=TRUE, repos='http://cran.r-project.org')
install.packages('rjson',  dependencies=TRUE, repos='http://cran.r-project.org')
install.packages('pixmap',  dependencies=TRUE, repos='http://cran.r-project.org')

    #  biodivprobgen specific packages
    
install.packages ('plyr', dependencies=TRUE, repos='http://cran.r-project.org')
install.packages ('stringr', dependencies=TRUE, repos='http://cran.r-project.org')
install.packages ('methods', dependencies=TRUE, repos='http://cran.r-project.org')
install.packages ('bipartite', dependencies=TRUE, repos='http://cran.r-project.org')
install.packages ('assertthat', dependencies=TRUE, repos='http://cran.r-project.org')
install.packages ('igraph', dependencies=TRUE, repos='http://cran.r-project.org')
install.packages ('reshape2', dependencies=TRUE, repos='http://cran.r-project.org')

    #  packages local to my mac - not sure how to install on nectar node yet...
    #  I can just put it in the package directory, but I need to build it 
    #  first.  Not sure how to do that on the linux machine.  
    #  May need to just put the R source files in the biodivprobgen directory 
    #  with all my other source code and then work up to using it as a 
    #  package.
    
#install.packages('marxan', repos='local?')  #  repos='http://cran.r-project.org')

