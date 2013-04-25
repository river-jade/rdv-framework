#=========================================================================================

#                                 runMaxent.v3.R

#=========================================================================================

#  To run this code locally using tzar (by calling the R code from model.py):

#      cd /Users/bill/D/rdv-framework

#          All of this goes on one line; I've written two ways, all on one and then 
#          again, broken broken into separate lines for clarity.
#          One thing that I don't understand though, why is --rscript=run.maxent.R 
#          inside the commandlineflags argument instead of on its own like all the 
#          other -- flags.
#  java -jar tzar.jar execlocalruns --runnerclass=au.edu.rmit.tzar.runners.RRunner --projectspec=projects/guppy/projectparams.yaml --localcodepath=. --commandlineflags="-p guppy --rscript=runMaxent.R"
#  java -jar tzar.jar execlocalruns 
#      --runnerclass=au.edu.rmit.tzar.runners.RRunner 
#      --projectspec=projects/guppy/projectparams.yaml 
#      --localcodepath=. 
#      --commandlineflags="-p guppy --rscript=runMaxent.R" --commandlineflags="-p guppy --rscript=runMaxent.R" 

#    The only yaml file variables that seem to be referenced in the code here.
# PAR.current.run.directory = outputFiles$'PAR.current.run.directory'
# PAR.path.to.maxent = variables$'PAR.path.to.maxent'
# PAR.input.directory = inputFiles$'PAR.input.directory'
# PAR.maxent.env.layers.base.name = variables$'PAR.maxent.env.layers.base.name'
# PAR.path.to.maxent.input.data = variables$'PAR.path.to.maxent.input.data'

#=========================================================================================

# source( 'runMaxent.R' )

#  Do NOT do this rm() at the start of the code.
#  If you do, it erases the lists of variables that are passed in.
#####rm( list = ls( all=TRUE ))

startingDir = getwd()
cat ("\n\nstartingDir = '", startingDir, "'", sep='')

cat ("\n\n=========  START str of the 3 lists  =========\n\n")
str(inputFiles)
str(outputFiles)
str(variables)
cat ("\n\n=========  END str of the 3 lists  =========\n\n")

#----------------------

PAR.rdv.directory = variables$PAR.rdv.directory
cat ("\n\nPAR.rdv.directory = '", PAR.rdv.directory, "'", sep='')

#----------------------

###  cat ("\n\ngetwd() = '", getwd(), "'", sep='')

###  PAR.input.directory = inputFiles$'PAR.input.directory'
###  #hack
###  ################## PAR.input.directory = '/Users/Bill/D/rdv-framework/projects/guppy/input_data'

###  # PAR.input.directory <- "/Users/Bill/D/rdv-framework/./projects/guppy/input_data"
###  cat ("\n\nPAR.input.directory = '", PAR.input.directory, "'", sep='')
###  cat ("\nShould say: '/Users/Bill/D/rdv-framework/./projects/guppy/input_data'")
###  ###[FINE|6:14:03]: PAR.input.directory = './projects/guppy/' 
###  ###[FINE|6:14:03]: Should say: '/Users/Bill/D/rdv-framework/./projects/guppy/input_data' 

PAR.input.directory.from.yaml = inputFiles$'PAR.input.directory'
PAR.input.directory = paste (PAR.rdv.directory, '/', 
                             substr (PAR.input.directory.from.yaml, 
                                     3, nchar (PAR.input.directory.from.yaml)), 
                             sep='')
cat ("\n\nPAR.input.directory = '", PAR.input.directory, "'", sep='')

#----------------------

PAR.current.run.directory = outputFiles$'PAR.current.run.directory'
# PAR.current.run.directory <- "/Users/Bill/tzar/outputdata/Guppy/default_runset/2_Scen_1.inprogress"
cat ("\n\nPAR.current.run.directory = '", PAR.current.run.directory, "'", sep='')
cat ("\nShould say: '/Users/Bill/tzar/outputdata/Guppy/default_runset/2_Scen_1.inprogress'")

#------------------------------------------------------------------------------

###  ASCELIN QUESTIONS:
###  When runs are scheduled, tzar seems to assume that you are running tzar from the 
###  rdv directory.  For example, in the tzar documentation it gives the following 
###  example, where the projectspec option gives no lead-in directory specification 
###  before the projects/lucy... directory specification:

###  Submit some runs on linux (single quotes round password)

###  java -jar tzar.jar scheduleruns 
###      --runnerclass=PythonRunner 
###      --commandlineflags="-p lucy_landscape_sim" 
###      --dburl 'jdbc:postgresql://arcs-01.ivec.org:5432/rdv?user=rdv&password=Asc#!in' 
### -->  --projectspec projects/lucy_landscape_sim/projectparams.yaml 
###      --revision=96 
###      --runset="lucy_test"  
###      --numruns=20

###  If tzar was run from some arbitrary directory other than the rdv directory, 
###  it seems like it would not know where to look to find the projects directory.  
###  Every example that I've seen in the documentation seems to follow this pattern.  

###  If pollandrun picks up a job that specificies "projects/lucy...", how does it 
###  know where to look for the projects directory if it's not assuming that it's 
###  sitting in the rdv directory?  It seems like everything assumes that you 
###  start tzar from the rdv directory - which is ok, but if that's true, then 
###  we can capture that directory's path at startup and use it to get rid of 
###  these ".." and "." bits in the yaml file where they don't have a constant 
###  meaning and are totally confusing to someone picking up the yaml file.  

###  One other thing that's confusing is this: how does a linux machine (e.g., 
###  a nectar machine) know where the rdv directory is to begin with when it's 
###  running tzar?

###  Maybe tzar should have a config directory and/or file that's created 
###  when it's installed.  Tzar could default (i.e., no argument given) to 
###  assuming that it's running from the directory where it's installed.  
###  There could be a command line argument to tell it where that directory 
###  is if you want to run it from somewhere else.  This would get rid of the 
###  need for an environment variable.

#------------------------------------------------------------------------------

    #  ASCELIN QUESTION:
    #  Seems like there's no reason that the current directory is actually in  
    #  the source tree.  For example, I have runMaxent.R in the guppy project  
    #  area rather than the R directory.  Your original example program 
    #  run.maxent.R was in the R directory when it was run from model.py, 
    #  but it seems odd to have model.py sit in the guppy project directory 
    #  and R code forced to go in the R directory.  Is other python code 
    #  forced to go somewhere (e.g., either a python directory or the 
    #  guppy project directory)?
    #  So, is this even right ???
source.dir <- getwd()
cat( "\n\n The path back to the source tree is ", source.dir, "\n")

#------------------------------------------------------------------------------

    #  Move to the output directory.
cat( "\n The path to the run dir is", PAR.current.run.directory )
setwd( PAR.current.run.directory )  # this is the output directory

#---------------------

cat ("\n\n******  Just before lots of .. arguments, getwd() = '", getwd(), "'")

PAR.path.to.maxent = variables$'PAR.path.to.maxent'
# PAR.path.to.maxent <- "../lib/maxent"
cat ("\n\nPAR.path.to.maxent = '", PAR.path.to.maxent, "'", sep='')
cat ("\nShould say: '../lib/maxent'")

maxent.full.path.name <- paste( PAR.rdv.directory, '/', PAR.path.to.maxent,  '/', 'maxent.jar', sep = '')

cat ("\n\nmaxent.full.path.name = '", maxent.full.path.name, "'")

#longMaxentCmd = 'java -mx2512m -jar ./maxent.jar  outputdirectory=MaxentOutputs  samplesfile=MaxentSamples/spp.sampledPres.combined.csv  environmentallayers=MaxentEnvLayers  autorun  replicates=3  replicatetype=bootstrap  randomseed=true  redoifexists  nowarnings  novisible'
#shortMaxentCmd = 'java -mx2512m -jar ./maxent.jar  outputdirectory=MaxentOutputs  samplesfile=MaxentSamples/spp.sampledPres.combined.csv  environmentallayers=MaxentEnvLayers  autorun  redoifexists'

if( !file.exists ( "MaxentOutputs" ) ) {
  dir.create( "MaxentOutputs" )
}

    #------------------------------------------------------------
    #  Now choose the set of input environmental layers to use
    #
    #      - This is done by looking at all the input dirs
    #        in PAR.path.to.maxent.input.data that match the pattern
    #        PAR.maxent.env.layers.base.name
    #      - Then randomly selecting one of these
    #
    #------------------------------------------------------------

PAR.path.to.maxent.input.data = variables$'PAR.path.to.maxent.input.data'
# PAR.path.to.maxent.input.data <- ".."
cat ("\n\nPAR.path.to.maxent.input.data = '", PAR.path.to.maxent.input.data, "'", sep='')
cat ("\nShould say: '..'")

PAR.maxent.env.layers.base.name = variables$'PAR.maxent.env.layers.base.name'
# PAR.maxent.env.layers.base.name <- "MaxentEnvLayers"
cat ("\n\nPAR.maxent.env.layers.base.name = '", PAR.maxent.env.layers.base.name, "'", sep='')
cat ("\nShould say: 'MaxentEnvLayers'")

# First get the list of potential input dirs
#maxent.input.dirs.vec <- dir( PAR.path.to.maxent.input.data, pattern=PAR.maxent.env.layers.base.name )
cat ("\n\n*******  Just before .vec, PAR.input.directory = '", PAR.input.directory, "'", sep='')
cat ("\n\n*******  Just before .vec, dir(PAR.input.directory) = '", dir(PAR.input.directory), "'", sep='')
cat ("\n\n*******  Just before .vec, dir('.') = '", dir("."), "'", sep='')
cat ("\n\n*******  Just before .vec, dir('/Users/Bill/D/rdv-framework/projects/guppy/input_data') = '", dir("/Users/Bill/D/rdv-framework/projects/guppy/input_data"), "'", sep='')
maxent.input.dirs.vec <- dir( PAR.input.directory)
cat ("\nmaxent.input.dirs.vec 1 = '", maxent.input.dirs.vec, "'")
maxent.input.dirs.vec <- dir( PAR.input.directory, pattern=PAR.maxent.env.layers.base.name )
cat ("\nmaxent.input.dirs.vec 2 = '", maxent.input.dirs.vec, "'")

# now choose one of them to be the maxent input
cur.maxent.env.layers.dir.name <- sample(maxent.input.dirs.vec, 1)

cat( "\n***\n*** Using", cur.maxent.env.layers.dir.name, "\n***\n"  )

#cur.full.maxent.env.layers.dir.name <- paste( PAR.path.to.maxent.input.data, '/',
#                                        cur.maxent.env.layers.dir.name, sep = '' )

cur.full.maxent.env.layers.dir.name <- paste( PAR.input.directory, '/',
                                        cur.maxent.env.layers.dir.name, sep = '' )

cat( '\n cur.maxent.env.layers.dir.name =', cur.full.maxent.env.layers.dir.name )

#cat('\n')


longMaxentCmd = paste( 'java -mx512m -jar ', maxent.full.path.name,
                       ' outputdirectory=MaxentOutputs',
                       #' samplesfile=../MaxentSamples/spp.sampledPres.combined.csv',
                       ' samplesfile=',PAR.input.directory, '/spp.sampledPres.combined.csv',
                       ' environmentallayers=', cur.full.maxent.env.layers.dir.name,
                       ' autorun  replicates=3  replicatetype=bootstrap  randomseed=true',
                       ' redoifexists  nowarnings  novisible', sep = '')

shortMaxentCmd = paste( 'java -mx512m -jar ',
                        maxent.full.path.name,
                        ' outputdirectory=MaxentOutputs',
                        #' samplesfile=../MaxentSamples/spp.sampledPres.combined.csv',
                        ' samplesfile=',PAR.input.directory,'/MaxentSamples/spp.sampledPres.combined.csv',  
                        ' environmentallayers=', cur.full.maxent.env.layers.dir.name,
                        ' autorun  redoifexists', sep = '' )
#maxentCmd = longMaxentCmd
maxentCmd = shortMaxentCmd


cat( '\n\nThe command to run maxent is:', maxentCmd, '\n' )

    cat( '\n----------------------------------' );
    cat( '\n Running Maxent' );
    cat( '\n----------------------------------' );


system ( maxentCmd )


setwd( source.dir )

#=========================================================================================

if (FALSE)
{
minH = 1
maxH = 10
H = sample (minH:maxH, 1)
if (H < 10) 
    Hstring = paste ('0', H, sep='') else 
    Hstring = as.character(H)

leadChrDir = "http://glass.eres.rmit.edu.au/tzar_input/guppy/AlexFractalData/H"
chrDir = paste (leadChrDir, Hstring, "/", sep='')

minImgNum = 1
maxImgNum = 100
imgNum = sample (minImgNum:maxImgNum, 1)
imgFileName = paste ("H", Hstring, "_", imgNum, ".tif", sep='')
url = paste (chrDir, imgFileName, sep='')
err = try (download.file (url, destfile = imgFileName , quiet = TRUE), silent = TRUE )
if ( class (err)=="try-error")
  {
        #  you may be hitting the server too hard , so backoff and try again later.
  Sys.sleep ( 5 ) #in seconds , adjust as necessary
  try (download.file (url, destfile = imgFileName , quiet = TRUE), silent = TRUE )
  }
}
