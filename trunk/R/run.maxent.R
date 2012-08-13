
# source( 'run.maxent.R' )

rm( list = ls( all=TRUE ))


source( 'variables.R' )

    cat( '\n----------------------------------' );
    cat( '\n Running Maxent' );
    cat( '\n----------------------------------' );


# First get the OS
#   for linux this returns linux-gnu
#   for mac this returns darwin9.8.0
#   for windos this returns mingw32

current.os <- sessionInfo()$R.version$os

source.dir <- getwd()

cat( "\n The path to the run dir is", PAR.current.run.directory )
cat( "\n\n The path back to the source tree is ", source.dir, "\n")


setwd( PAR.current.run.directory )  # this is the output directory


#setwd ('/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/')
#setwd ('~/bill/MaxentTests')'
#getwd()
#system ('ls -l maxent.jar')

maxent.full.path.name <- paste( source.dir, '/', PAR.path.to.maxent,  '/', 'maxent.jar', sep = '')

#longMaxentCmd = 'java -mx2512m -jar ./maxent.jar  outputdirectory=MaxentOutputs  samplesfile=MaxentSamples/spp.sampledPres.combined.csv  environmentallayers=MaxentEnvLayers  autorun  replicates=3  replicatetype=bootstrap  randomseed=true  redoifexists  nowarnings  novisible'
#shortMaxentCmd = 'java -mx2512m -jar ./maxent.jar  outputdirectory=MaxentOutputs  samplesfile=MaxentSamples/spp.sampledPres.combined.csv  environmentallayers=MaxentEnvLayers  autorun  redoifexists'

if( !file.exists ( "MaxentOutputs" ) ) {
  dir.create( "MaxentOutputs" )
}

    #------------------------------------------------------------
    #  Now chose the set of input environmental layers to use
    #
    #      - This is done by looking at all the input dirs
    #        in PAR.path.to.maxent.input.data that match the pattern
    #        PAR.maxent.env.layers.base.name
    #      - Then randomly selecting one of these
    #
    #------------------------------------------------------------



# First get the list of potential input dirs
#maxent.input.dirs.vec <- dir( PAR.path.to.maxent.input.data, pattern=PAR.maxent.env.layers.base.name )
maxent.input.dirs.vec <- dir( PAR.input.directory, pattern=PAR.maxent.env.layers.base.name )

# now choose one of them to be the maxent input
cur.maxent.env.layers.dir.name <- sample(maxent.input.dirs.vec, 1)


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

system ( maxentCmd )


setwd( source.dir )
