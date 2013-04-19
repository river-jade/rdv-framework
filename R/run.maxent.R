#=========================================================================================

#  To run this code locally using tzar (by calling the R code from model.py):

#      cd /Users/bill/D/rdv-framework

#          All of this goes on one line; I've broken it here for clarity.
#      java -jar tzar.jar 
#           execlocalruns 
#           --runnerclass=JythonRunner  
#           --projectspec=projects/guppy/projectparams.yaml 
#           --localcodepath=. 
#           --commandlineflags="-p guppy"




#          All of this goes on one line; I've broken it here for clarity.
#      java -jar tzar.jar execlocalruns --runnerclass=au.edu.rmit.tzar.runners.RRunner  --projectspec=projects/guppy/projectparams.yaml --localcodepath=. --commandlineflags="-p guppy"

# b01211027b-02b:rdv-framework Bill$ java -jar tzar.jar execlocalruns --runnerclass=au.edu.rmit.tzar.runners.RRunner  --projectspec=projects/guppy/projectparams.yaml --localcodepath=. --commandlineflags="-p guppy"
# [INFO|5:16:13]: Created 1 runs. 
# [INFO|5:16:13]: Creating temporary outputdir: /Users/Bill/tzar/outputdata/Guppy/default_runset/3_Scen_1.inprogress 
# [INFO|5:16:13]: Running model: ., run_id: 3, Project name: Guppy, Scenario name: Scen 1, Flags: -p guppy 
# [SEVERE|5:16:14]: An unrecoverable error occurred. 
# au.edu.rmit.tzar.api.RdvException: Error parsing flag string: [-p, guppy]
# 	at au.edu.rmit.tzar.runners.SystemRunner.parseFlags(SystemRunner.java:63)
# 	at au.edu.rmit.tzar.runners.RRunner.runModel(RRunner.java:24)
# 	at au.edu.rmit.tzar.ExecutableRun.execute(ExecutableRun.java:113)
# 	at au.edu.rmit.tzar.commands.ExecLocalRuns.executeRun(ExecLocalRuns.java:73)
# 	at au.edu.rmit.tzar.commands.ExecLocalRuns.execute(ExecLocalRuns.java:51)
# 	at au.edu.rmit.tzar.commands.Main.main(Main.java:78)
# Caused by: com.beust.jcommander.ParameterException: The following option is required:     --rscript 
# 	at com.beust.jcommander.JCommander.validateOptions(JCommander.java:314)
# 	at com.beust.jcommander.JCommander.parse(JCommander.java:276)
# 	at com.beust.jcommander.JCommander.parse(JCommander.java:258)
# 	at au.edu.rmit.tzar.runners.SystemRunner.parseFlags(SystemRunner.java:61)
# 	... 5 more
# b01211027b-02b:rdv-framework Bill$ 

#  java -jar tzar.jar execlocalruns --runnerclass=au.edu.rmit.tzar.runners.RRunner --projectspec=projects/guppy/projectparams.yaml --localcodepath=. --commandlineflags="-p guppy --rscript=run.maxent.R"

# b01211027b-02b:rdv-framework Bill$ java -jar tzar.jar execlocalruns --runnerclass=au.edu.rmit.tzar.runners.RRunner --projectspec=projects/guppy/projectparams.yaml --localcodepath=. --commandlineflags="-p guppy --rscript=run.maxent.R"
# [INFO|5:20:09]: Created 1 runs. 
# [INFO|5:20:09]: Creating temporary outputdir: /Users/Bill/tzar/outputdata/Guppy/default_runset/4_Scen_1.inprogress 
# [INFO|5:20:09]: Running model: ., run_id: 4, Project name: Guppy, Scenario name: Scen 1, Flags: -p guppy --rscript=run.maxent.R 
# [INFO|5:20:09]: Renaming "/Users/Bill/tzar/outputdata/Guppy/default_runset/4_Scen_1.inprogress" to "/Users/Bill/tzar/outputdata/Guppy/default_runset/4_Scen_1.failed" 
# [WARNING|5:20:09]: Run 4 failed. 
# [WARNING|5:20:09]: Executed 1 runs: 0 succeeded. 1 failed 
# [WARNING|5:20:09]: Failed IDs were: [4] 
# b01211027b-02b:rdv-framework Bill$ 

#=========================================================================================

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

system ( maxentCmd )


setwd( source.dir )

#=========================================================================================

