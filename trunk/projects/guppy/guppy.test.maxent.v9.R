#===============================================================================

#      Commands to run guppy project. 

#      2012 07 24 - BTL
#      Starting to try to use tsar again so I've created a new file here 
#      in case I mess something up.
#      One thing to note was that when I opened the v8 file, the cursor 
#      was sitting at the lines:
#          ##  BTL - 2011.10.03
#          ##
#          ##  I JUST REALIZED THAT THIS IS WRONG FROM HERE ON !
#      Just want to remember that so that I can go back and have a look at it 
#      once I get a little farther.

#      Note (2011.09.20 - BTL:
#      These are taken from the tzarbabushka documentation file on google docs 
#      section on guppy.  (Should add these observations to the csar 
#      documentation.)
#      I dumped an early version of that to a pdf so that I didn't have to be 
#      online to read it, but it wrapped long commands onto multiple lines 
#      and in the process it sometimes separated the option flag marker "--" 
#      from the option name.  For example, "--projectspec=..." might become 
#      "-- projectspec=...".  This causes errors when you run the framework 
#      (I think it was something like 'no such option'), so that separation 
#      is the first thing to look for if you're copying a command in from 
#      a documentation file that does line wrapping.

#      NOTE: I have also added the "-v" at the end of the command to get 
#            verbose output while I'm testing.  Remove this for real runs.
#            "verbose" means that output that normally just goes to the log 
#            file will also be echoed to the terminal.

#  cd /Users/bill/D/rdv-framework/

#  java -Drunnerclass=JythonRunner -jar rdv.jar execlocalruns --projectspec=projects/guppy/projectparams.json --globalparams=projects/globalparams.json --revision=-1 --localcodepath=. --commandlineflags="-pguppy -v"

#  If using a repetitions file:
#  java -Drunnerclass=JythonRunner -jar rdv.jar execlocalruns --projectspec=projects/guppy/projectparams.json --globalparams=projects/globalparams.json --revision=-1 --localcodepath=. --commandlineflags="-pguppy -v" --numruns=1 --repetitionsfile=projects/guppy/repetitions.json

#  Also, to get help on command options:
#  java -Drunnerclass=JythonRunner -jar rdv.jar execlocalruns

#===============================================================================

#  NOTE: I'm using "#-#" to comment things out in converting from the maxent 
#        test version developed around the time of Austin ESA 2011 to the 
#        new framework2 guppy version.

#-#rm (list = ls());    #  Remove any previously existing objects.
#-#base.dir = '/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/'
#-#setwd (base.dir)
#-#getwd ()

PAR.num.processors = 1      #  default value for number of processors in the 
                            #  current machine in case it's not set in the 
                            #  json file.
                            #  maxent can use this value to speed up some 
                            #  of its operations by creating more threads.
                            #  It's not a necessary thing to set for any other 
                            #  reason.

source ('variables.R')

    #----------

#PAR.random.num.seed = 17
#random.num.seed <- PAR.random.num.seed
#set.seed (random.num.seed)

    #  Turning this off while I do some repetitions and am unable to 
    #  get the random seed to set properly. 
    #  BTL - 2011.09.27
#random.seed = 100  #  temporary fix

    #  This is set in globalparms.json with a default value.
    #  Currently, that value is the run number.
cat ("\nrandom.seed = ", random.seed, sep='')
set.seed (random.seed)

#===============================================================================

#  To run the current version of the code: 

#      source ('guppy.test.maxent.v8.R')

#  Note that it currently assumes the following directory structure 
#  of that MaxentTest directory:

#    drwxr-xr-x   5 bill  staff     170 20 Jan 11:20 AlexsSyntheticLandscapes
#    drwxr-xr-x   6 bill  staff     204 17 Feb 13:09 MaxentEnvLayers
#    drwxr-xr-x  14 bill  staff     476 17 Feb 13:48 MaxentOutputs
#    drwxr-xr-x   4 bill  staff     136 17 Feb 12:55 MaxentProbDistLayers
#    drwxr-xr-x   2 bill  staff      68 17 Feb 11:15 MaxentProjectionLayers
#    drwxr-xr-x   5 bill  staff     170 17 Feb 13:10 MaxentSamples
#    drwxr-xr-x   3 bill  staff     102 18 Feb 12:30 ResultsAnalysis
#    -rw-r--r--@  1 bill  staff   25339 18 Feb 12:55 test.maxent.R
#    -rw-r--r--@  1 bill  staff    8617 17 Feb 13:22 w.R

#  Also note that w.R is a modified version of w.R from the framework.  
#  Need to commit it to the framework so that the changes to write.asc.file()
#  are generally available.  Those changes are simple ones and only involve 
#  making a bunch of the parameters able to be specified in the call rather 
#  than fixed inside the routine.  All of the new call arguments default to 
#  the old values though, so no existing framework code should be broken by 
#  this.

#-------------------------

#  NOTE: things to add to the ML book 
#        (have added this to evernote on 2011.07.17)
#        
#      - Having spaces in a file path can cause R to choke on the mac.
#        If I do something like:
#            dir (probabilities.dir)
#        when probabilities directory ccontains embedded spaces like this:
#            probabilities.dir <- "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated ecology/MaxentTests/MaxentProbDistLayers/"
#        then R returns 
#            char(0)
#        which is similar to what the shell terminal window gives:
#            > ls -l /Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01 - simulated ecology/MaxentTests/MaxentProbDistLayers/
#            > ls: -: No such file or directory


#===============================================================================

#  History 
#
#  2011.02.18 - BTL
#  Have now completed a prototype that goes all the way through the process 
#  of:
#    - reading a pair of environment layers from .pnm files
#    - combining them in some way to produce a "correct" probability 
#      distribution
#    - drawing a "correct" population of presences from that distribution
#    - sampling from that correct population to get the "apparent" population 
#    - running maxent on that sample plus the environment layers
#    - reading maxent's resulting estimate of the probability distribution
#    - computing the error between maxent's normalized distribution and the 
#      correct normalized distribution
#    - computing some statistics and possibly showing a heatmap of the errors 
#      as a first cut at examining the spatial distribution of error.
#
#  There are lots of restrictions and assumptions about formats and locations 
#  and hard-coded rules for combining layers and you still have to run maxent 
#  by hand.  However, some version of every step is there and it works from 
#  end to end to get a result.  Now we just need to:
#    - expand the capabilities of each step 
#    - add the ability to inject error in all inputs and processes
#    - turn it into a class to make it easier to use and to swap methods 
#      in and out
#    - make a project for it in the framework and give it access to yaml 
#      files for setting control variables and run over many different 
#      scenarios and inputs

#  2011.08.07 - BTL
#  Working on ESA version now. 
#  Most of that work will happen in the guppy project of framework2, but 
#  some things may happen here as well.
#    - Just moved defn of get.img.matrix.from.pnm() to w.R in framework2/R.
#    - Extracted all of the function definitions into test.maxent.functions.v4.R
#      since this file was too complicated to read easily.

#  2011.08.26 - BTL 
#  Did a quick hack on test.maxent.v5.R to generate a new maxent error image 
#  to include in the revised TREE paper proofs.  That quick hack file is 
#  called test.maxent.v5.tree.only.R.

#  2011.09.12 - BTL
#  Never did end up moving the code into framework2 while I was working on 
#  it in Austin at ESA.  Today, I'm starting the move.
#
#  Note that while most of the work now will be derived from test.maxent.v5.R in 
#  /Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/, 
#  there are some other files in that area that are not being moved but might 
#  have useful code in them for cannabalizing later.  In particular, 
#  test.maxent.misc.and.one.time.only.code.v5 might have useful snippets.  
#
#  Another useful file, if only for documentation of where we're headed is:
#  terror flowgraph P1030739.jpg.  This file has a photo of the big spaghetti 
#  diagram that I drew at the CEED workshop to explain to Peter Vesk what we're 
#  trying to do.  I also included it (very briefly) in the ESA talk itself to 
#  illustrate the complexity of the problem
#  
#  Copied test.maxent.v5.R from 
#  /Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/
#  to /Users/bill/D/rdv-framework/R and renamed it to guppy.test.maxent.v6.R 
#  to indicate that I have started from that old version and am now moving and 
#  modifying it to work inside the guppy project of framework2 (which has just 
#  been moved from sourceforge to google code repository).  In the framework2 
#  code set newly installed from google code, there is file called 
#  test.maxent.R.  I think that this is a much earlier version of 

#  2011.09.22 - BTL 
#  Changed from v6 to v7 to freeze the version before I change zonation to 
#  run in a zonation subdirectory instead of in the generic output directory.
#  At this point, everything seems to be working in the guppy project version 
#  of this code up to the point where I have run zonation on the apparent 
#  species.  I'm now going to add a zonation directory in the generic output 
#  directory and write all zonation output there.  I need to add a parameter 
#  for the zonation directory into the json parameters file.  I also need to 
#  get zonation running the rest of the way throught this source file to deal 
#  with the correct data too instead of just the apparent.  

#===============================================================================

    #  Changed this back to Not specifying the path since it should already be 
    #  in the framework R directory when running this now.
    #  BTL - 2011.09.19
source ('w.R')
#-#source ('/Users/bill/D/rdv-svn/rdv-framework/trunk/framework2/rdv/R/w.R')
        
library (pixmap)

#===============================================================================

######source.dir <- getwd()
source.dir = "/Users/bill/D/rdv-framework"
  
cat( "\n The path to the current run's output dir is", PAR.current.output.directory )
cat( "\n\n The path back to the source tree is ", source.dir)

    #--------------------

    #  BTL - What if these are not all in H05?  Don't really want them all 
    #        to have to come from there.  Some might be at different scales.
    #        Probably need to move this into a routine that bundles up 
    #        everything having to do with getting environmental input layers.
#PAR.input.img.dir = "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/AlexsSyntheticLandscapes/IDLOutputAll2/H05/"
input.img.dir = PAR.input.img.dir
#input.img.dir <- '/AlexsSyntheticLandscapes/IDLOutputAll2/H05/'

cat ("\ninput.img.dir = '", input.img.dir, "'", sep='')
if( !file.exists (input.img.dir)) 
  {
  errMsg = paste ("\ninput.img.dir required to already exist but does not: '", 
                  input.img.dir, "'", sep='')
  stop (errMsg, call. = FALSE)
  } 

    #--------------------

    #  Create the directory where the environmental layers used by 
    #  maxent will go.
    #  They might be copied in from somewhere else or they might be 
    #  created here.
#-#env.layers.dir = "./MaxentEnvLayers/"    #7/17#  maxent env inputs?

env.layers.dir = paste (PAR.current.output.directory, "/", 
                        PAR.maxent.env.layers.base.name, "/", sep='')

cat ("\nenv.layers.dir = '", env.layers.dir, "'", sep='')
if( !file.exists (env.layers.dir)) 
  {
  dir.create (env.layers.dir)
  }

    #--------------------

    #  Not sure why this full name is needed...

#-#cur.full.maxent.env.layers.dir.name = '/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/MaxentEnvLayers/'
cur.full.maxent.env.layers.dir.name = paste (PAR.current.output.directory, "/", 
                                             PAR.maxent.env.layers.base.name, 
                                             "/", sep='')

cat ("\ncur.full.maxent.env.layers.dir.name = '", 
     cur.full.maxent.env.layers.dir.name, "'", sep='')
  
    #--------------------

#PAR.maxent.samples.dir.name = "MaxentSamples"
samples.dir = paste (PAR.current.output.directory, "/", 
                     PAR.maxent.samples.dir.name, "/", sep='')

cat ("\nsamples.dir = '", samples.dir, "'", sep='')
if( !file.exists (samples.dir)) 
  {
  dir.create (samples.dir)
  }

    #--------------------

#if (FALSE)    #  commenting out for now since it doesn't seem like it's used
#{
#  IS THIS EVEN USED?

#prob.dist.layers.dir = "./MaxentProbDistLayers/"    #7/17#  what we want maxent to generate, i.e., the true layers?
#PAR.prob.dist.layers.dir.name = "MaxentProbDistLayers"
prob.dist.layers.dir = paste (PAR.current.output.directory, "/", 
                              PAR.prob.dist.layers.dir.name, "/", sep='')
cat ("\nprob.dist.layers.dir = '", prob.dist.layers.dir, "'", sep='')
if ( !file.exists (prob.dist.layers.dir)) 
  {
  dir.create (prob.dist.layers.dir)
  }
#}

    #--------------------

#PAR.maxent.output.dir.name = "MaxentOutputs"
maxent.output.dir = paste (PAR.current.output.directory, "/", 
                           PAR.maxent.output.dir.name, "/", sep='')
cat ("\nmaxent.output.dir = '", maxent.output.dir, "'", sep='')
if ( !file.exists (maxent.output.dir)) 
  {
  dir.create (maxent.output.dir)
  }

    #--------------------

#PAR.zonation.dir.name = "Zonation"
zonation.output.dir = paste (PAR.current.output.directory, "/", 
                           PAR.zonation.dir.name, "/", sep='')
cat ("\nzonation.output.dir = '", zonation.output.dir, "'", sep='')
if ( !file.exists (zonation.output.dir)) 
  {
  dir.create (zonation.output.dir)
  }

    #--------------------

#analysis.dir = "./ResultsAnalysis/"
#PAR.analysis.dir.name = "ResultsAnalysis"
analysis.dir = paste (PAR.current.output.directory, "/", 
                      PAR.analysis.dir.name, "/", sep='')
cat ("\nanalysis.dir = '", analysis.dir, "'", sep='')
if ( !file.exists (analysis.dir)) 
  {
  dir.create (analysis.dir)
  }

    #--------------------

#setwd (PAR.current.output.directory)
#system ('ls -l maxent.jar')

#PAR.path.to.maxent = "../lib/maxent"
PAR.path.to.maxent = "lib/maxent"
#-#maxent.full.path.name = '/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/'
maxent.full.path.name <- paste (source.dir, '/', PAR.path.to.maxent,  
                                '/', 'maxent.jar', sep = '')

cat ("\nmaxent.full.path.name = '", maxent.full.path.name, "'", sep='')
if( !file.exists (maxent.full.path.name)) 
  {
  errMsg = paste ("\nmaxent.full.path.name required to already exist but does not: '", 
                  maxent.full.path.name, "'", sep='')
  stop (errMsg, call. = FALSE)
  } ### else cat ("OK")

    #--------------------

#       write.to.file : TRUE,
        write.to.file = PAR.write.to.file

#   	  use.draw.image : FALSE,
        use.draw.image = PAR.use.draw.image

#   	  use.filled.contour : TRUE,
        use.filled.contour = PAR.use.filled.contour

            #  BEWARE: if this is FALSE, the get.env.layers() routine in 
            #          guppy.maxent.functions.v6.R does something vestigial 
            #          that you may not expect (or want) at all !  
            #          Need to fix that.
            #          BTL - 2011.09.20
            #  BTL - 2011.10.03 - Is this note even relevant anymore?
            #                     Looks like this variable isn't even used now.
#   	  use.pnm.env.layers : TRUE ,       
        use.pnm.env.layers = PAR.use.pnm.env.layers    

#===============================================================================

par (mfrow=c(2,2))        

#===============================================================================

    #  Moved this to the framework2 R directory and renamed it.
source ('guppy.maxent.functions.v8.R')

cat ( '\n\nDone loading source and variables.');

#===============================================================================
#===============================================================================
#===============================================================================

##PAR.use.old.maxent.output.for.input = TRUE
##PAR.old.maxent.env.files = "/Users/bill/tzar/outputdata/Guppy_Scen_1_4/MaxentEnvLayers"
if (PAR.use.old.maxent.output.for.input)
    {
        #  glob2rx() converts a wildcard expression to a regular expression.
        #  Here, I want to get the names of all of the H* files in the old 
        #  maxent directory and they all begin with H.  More importantly, 
        #  the old directory also has at least one other file in there called 
        #  maxent.cache and I don't want to pick that one up too.
        #  Note: the ignore.case argument is to make sure things behave under 
        #  Windows.  
    flist = list.files (PAR.old.maxent.env.files, 
                        glob2rx ('H*'), 
                        full.names = TRUE, ignore.case = TRUE)
                
    if (! file.copy (flist, #PAR.old.maxent.env.files,
                     cur.full.maxent.env.layers.dir.name,
                     overwrite = TRUE )) 
        {
        stop (paste ('\n\nCould not copy ', PAR.old.maxent.env.files, ' to ', 
                     cur.full.maxent.env.layers.dir.name), 
                     call. = FALSE )
        }
        
    } else
    {
    source ("guppy.get.env.layers.v8.R")
    }

#===============================================================================
#===============================================================================
      #  End of global setup.  Now it gets species-specific.
#===============================================================================
#===============================================================================

#  NOTE: This section that computes a probability distribution by combining 
#        environment layers is Extremely simplistic right now.  
#        The beginnings of a more complex version of it can be found in 
#        Desktop/MaxentTests/test.maxent.v4.R where things like hinge functions 
#        are mentioned.  I think that is where I was working on it at Austin ESA
#        but ran out of time and reverted back to this very simple version.
#        I think that there may be some better examples in a Dorfmann paper 
#        that simulated various species, but I think the paper is at home.  
#        I think that he had 3 main classes of combining functions.
#        BTL - 2011.09.22

#===============================================================================

#  PAR.num.spp = 2
  
for (spp.id in 1:PAR.num.spp.in.reserve.selection)
{
#spp.id = 1      #  This needs to become the head of a for loop...    
#spp.id = 2   
spp.name <- paste ('spp.', spp.id, sep='')

#-----------------------------------

norm.prob.matrix = NULL
PAR.old.maxent.output.dir = "/Users/bill/tzar/outputdata/Guppy_Scen_1_4/MaxentOutputs/"

if (PAR.use.old.maxent.output.for.input)
    {
    norm.prob.matrix = read.asc.file.to.matrix (spp.name, PAR.old.maxent.output.dir)

    norm.prob.matrix <- 
            normalize.prob.distribution.from.env.layers (norm.prob.matrix)    

    } else
    {

    rel.prob.matrix <- matrix ()
    
    if (spp.id == 1)
        {
        combination.rule <- CONST.product.rule
        
        } else
        {
        combination.rule <- CONST.add.rule
        }
            
    ##for ()
    ##  {
        if (combination.rule == CONST.product.rule)
            {
        rel.prob.matrix = env.layers [[1]]
        for (cur.env.layer.idx in 2:num.env.layers)
            {
              rel.prob.matrix <- rel.prob.matrix * env.layers [[cur.env.layer.idx]]
            }
            
            } else
            {
            if (combination.rule == CONST.add.rule)
                {
            rel.prob.matrix = env.layers [[1]]
            for (cur.env.layer.idx in 2:num.env.layers)
                {
                  rel.prob.matrix <- rel.prob.matrix + env.layers [[cur.env.layer.idx]]
                }		    
                } else
                {
                stop ("\n\nUndefined combination rule for environmental layers.\n\n")
                }
            }
        
        print (rel.prob.matrix [1:3,1:3])    #  Echo a bit of the result...
    ##  }
    
      norm.prob.matrix <- 
            normalize.prob.distribution.from.env.layers (rel.prob.matrix)    
            
            
    }  #  end else - do not use old maxent output as input


#####stop ("\n\nCheck that copy worked correctly.\n\n")

num.rows <- (dim (norm.prob.matrix)) [1]
num.cols <- (dim (norm.prob.matrix)) [2]
num.cells <- num.rows * num.cols

cat ("\n\nnum.rows = ", num.rows)  
cat ("\nnum.cols = ", num.cols)  
cat ("\nnum.cells = ", num.cells)  
      
#===============================================================================

	#-------------------------------------------------------------
	#  Sample presences from the mapped probability distribution 
	#  according to the probabilities.
	#-------------------------------------------------------------


spp.true.presence.fractions.of.landscape = 
    runif (PAR.num.spp.in.reserve.selection, 
           min = PAR.min.true.presence.fraction.of.landscape, 
           max = PAR.max.true.presence.fraction.of.landscape)

#spp.true.presence.fractions.of.landscape = c (50/num.cells, 100/num.cells)
cat ("\n\nspp.true.presence.fractions.of.landscape = \n")
print (spp.true.presence.fractions.of.landscape)
      
spp.true.presence.cts = num.cells * spp.true.presence.fractions.of.landscape
cat ("\nspp.true.presence.cts = ")
print (spp.true.presence.cts)
      
num.true.presences = spp.true.presence.cts [spp.id]
cat ("\nnum.true.presences = ", num.true.presences)
      
true.presence.indices <- sample (1:(num.rows * num.cols), 
								num.true.presences, 
								replace = FALSE, 
								prob = norm.prob.matrix)
cat ("\ntrue.presence.indices = ")
print (true.presence.indices)

	#----------------------------------------------------------------
	#  Convert the sample from single index values to x,y locations 
	#  relative to the lower left corner of the map.
	#----------------------------------------------------------------

true.presence.locs.x.y <- 
	matrix (rep (0, (num.true.presences * 2)), 
			nrow = num.true.presences, ncol = 2, byrow = TRUE)

	#  Can probably replace this with an apply() call instead...
for (cur.loc in 1:num.true.presences)
	{
	true.presence.locs.x.y [cur.loc, ] <- 
		xy.rel.to.lower.left (true.presence.indices [cur.loc], num.rows)
	}

    #-----------------------------------------------------------------------
    #  Bind the species names to the presence locations to make a data frame 
    #  that can be written out in one call rather than writing it out one 
    #  line at a time.
    #  Unfortunately, this cbind call turns the numbers into quoted strings 
    #  too.  There may be a way to fix that, but at the moment, I don't 
    #  know how to do that so I'll strip all quotes in the write.csv call.
    #  That, in turn, may cause a problem for the species name if it has a 
    #  space in it.  Not sure what maxent thinks of that form.
    #-----------------------------------------------------------------------

species <- rep (spp.name, num.true.presences)    
true.presences.table <- 
	data.frame (cbind (species, true.presence.locs.x.y))
names (true.presences.table) <- c('species', 'longitude', 'latitude')

    #--------------------------------------------------------------------
	  #  Write the true presences out to a .csv file to be fed to maxent.
	  #  This will represent the case of "perfect" information 
  	#  (for a given population size), i.e., it contains the true 
  	#  location of every member of the population at the time of the 
   	#  sampling.  For stationary species like plants, this will be 
	  #  "more perfect" than for things that can move around.
    #--------------------------------------------------------------------
    
  
        #  2011.09.21 - BTL - Have changed the name sampled.presences.filename 
        #                     to true.presences.filename here because that 
        #                     seems like it was an error before but didn't 
        #                     show up because it gets written over further 
        #                     down in the file.  I may be wrong so I'm flagging
        #                     it for the moment with '###'.
outfile.root <- paste (spp.name, ".truePres", sep='')
###sampled.presences.filename <- paste (samples.dir, outfile.root, ".csv", sep='')
true.presences.filename <- paste (samples.dir, outfile.root, ".csv", sep='')
write.csv (true.presences.table, 
###  	   file = sampled.presences.filename, 
  	   file = true.presences.filename, 
		   row.names = FALSE, 
		   quote=FALSE)
	
#===============================================================================

    #---------------------------------------------------------------------
    #  Have now finished generating the true occurrences of the species.  
    #  Ready to simulate the sampling of the species to generate a 
    #  sampled occurrence layer to feed to maxent.
    #---------------------------------------------------------------------

#PAR.use.all.samples = TRUE
PAR.use.all.samples = FALSE

    #  This is just a hack for now.  
    #  Need to figure out a better way to pass in arrays of numbers of 
    #  true sample sizes and subsample sizes.
PAR.num.samples.to.take = num.true.presences    
if (! PAR.use.all.samples)
    {
    PAR.num.samples.to.take = num.true.presences / 2   
    }

sampled.locs.x.y = NULL  
sample.presence.indices.into.true.presence.indices = 1:num.true.presences

if (PAR.use.all.samples)
  {
  sampled.locs.x.y = true.presence.locs.x.y
  } else
  {
  num.samples.to.take = min (num.true.presences, PAR.num.samples.to.take)
  sample.presence.indices.into.true.presence.indices = 
        sample (1:num.true.presences, 
				num.samples.to.take, 
				replace=FALSE)  #  Should this be WITH rep instead?
  sampled.locs.x.y <- 
      build.presence.sample (sample.presence.indices.into.true.presence.indices, 
                             true.presence.locs.x.y)    
  }

#  temporary comment to try to get rid of sample points on image - aug 25 2011
# plot (true.presence.locs.x.y [,1], true.presence.locs.x.y [,2],
# 	  xlim = c (0, num.cols), ylim = c(0, num.rows), 
# 	  asp = 1,
# 	  main = paste ("True presences \nnum.true.presences = ", 
# 	  				num.true.presences, sep='')
# 	  )
# 
# plot (sampled.locs.x.y [,1], sampled.locs.x.y [,2],
# 	  xlim = c (0, num.cols), ylim = c(0, num.rows), 
# 	  asp = 1,
# 	  main = paste ("Sampled presences \nnum.samples = ", 
# 	  				num.samples.to.take, sep='')
# 	  )

sampled.presences.table <- 
	data.frame (cbind (species [1:num.samples.to.take], sampled.locs.x.y))
names (sampled.presences.table) <- c('species', 'longitude', 'latitude')

    #--------------------------------------------------------------------
	#  Write the true presences out to a .csv file to be fed to maxent.
	#  This will represent the case of "perfect" information 
	#  (for a given population size), i.e., it contains the true 
	#  location of every member of the population at the time of the 
	#  sampling.  For stationary species like plants, this will be 
	#  "more perfect" than for things that can move around.
    #--------------------------------------------------------------------
    
outfile.root <- paste (spp.name, ".sampledPres", sep='')
sampled.presences.filename <- paste (samples.dir, outfile.root, ".csv", sep='')
write.csv (sampled.presences.table, 
		   file = sampled.presences.filename, 
		   row.names = FALSE, 
		   quote=FALSE)
	
#===============================================================================

	#  This is where we need to exec maxent, but it has a fair number of 
	#  options to set, so I'll leave coding that call for later.  
	#  Right now, we can just pause, run the maxent gui, and then come 
	#  back and finish up below.

    ###    Example java calls from maxent help file
    ###java -mx512m -jar maxent.jar environmentallayers=layers samplesfile=samples\bradypus.csv outputdirectory=outputs togglelayertype=ecoreg redoifexists autorun
    ###java -mx512m -jar maxent.jar -e layers -s samples\bradypus.csv -o MaxentOutputs -t ecoreg -r -a

cat ("\n\n		-----  Run maxent now  -----\n\n")
#cat ("\nHit c when Maxent has finished.\n")
#browser()   #  this browser should be deleted when system() call works.

## cur.spp.name <- spp.name
## sample.path <- paste ("MaxentSamples/", cur.spp.name, ".sampledPres.csv", sep='')
## system (paste ("java -mx512m -jar maxent.jar -e MaxentEnvLayers -s ", 
##             sample.path, " -o outputs -a", sep=''))
## ###system ('do1.bat')    #  the call to run zonation - makes it wait to return?
## browser()

    #  NOTE: THIS DOES NOT DEAL WITH THE CREATION OF THE SAMPLES FILE 
    #  THAT IS CURRENTLY CALLED SOMETHING LIKE 
    #      ../MaxentSamples/spp.sampledPres.combined.csv.  
    #  HAVE TO BUILD THAT BASED ON THE CHOICE OF SPECIES BUILT.

    #  setting up for maxent requires the following:
    #      - asc file for each species showing its true probability 
    #        distribution to use to build the samples file (it's not 
    #        used by maxent itself)
    #      - an equation for each species (to build the true probability map 
    #        for each species)
    
    #  maxent needs the following:
    #      - csv file with the list of samples for each species
    #      - asc file for each environment layer
    #        these env layers are the same for every species in a particular 
    #        run and they are the ones that are drawn from alex's set




longMaxentCmd = paste ('java -mx512m -jar ', 
                       
                       maxent.full.path.name, 
#                       "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/maxent.jar",
                       
#-#                       ' outputdirectory=MaxentOutputs',
                       ' outputdirectory=', maxent.output.dir,
                       
#                       ' samplesfile=MaxentSamples/spp.sampledPres.combined.csv',
                       ' samplesfile=', sampled.presences.filename, 
                       
#-#                       ' environmentallayers=MaxentEnvLayers', 
                       ' environmentallayers=', env.layers.dir, 
                       
                            #  If you have more than one processor in your 
                            #  machine, then setting the thread count to the 
                            #  number of processors can speed up things like 
                            #  jacknife operations (and hopefully, replicate 
                            #  operations) by using all of the processors.
                       ' threads=', PAR.num.processors, 
                       
                       ' autorun  ',
                       ' replicates=10  replicatetype=bootstrap ',
                       
    #  There are some random seed issues here when doing bootstrap replicates.
    #  It looks like you cannot choose the seed yourself so you cannot get 
    #  a reproducible result.  If you set randomseed to false and then try 
    #  this, maxent will put up a prompt telling you that it is going to 
    #  set randomseed to true.
    #  Need to talk to the maxent developers about this.
    #  2011.09.21 - BTL                       
                       ' randomseed=true',
#                       ' randomseed=false',
                       
                       ' redoifexists ',
#                       ' nowarnings  ',

                            #  Looks like you have to set the "novisible" flag 
                            #  in the argument list to maxent and then it will 
                            #  return a 1 if it fails.  Without the "novisible" 
                            #  flag, it seems to assume that you know there was 
                            #  a problem and returns an exit code that says it 
                            #  succeeded instead of failed.
#                       ' novisible', 
                       sep = '')

shortMaxentCmd = paste( 'java -mx512m -jar ',
                        
                        maxent.full.path.name,
                        
#-#                       ' outputdirectory=MaxentOutputs',
                       ' outputdirectory=', maxent.output.dir,
                        
#-#                        ' samplesfile=MaxentSamples/spp.sampledPres.combined.csv',
                       ' samplesfile=', sampled.presences.filename, 
                        
#-#                        ' environmentallayers=', cur.full.maxent.env.layers.dir.name,
                       ' environmentallayers=', env.layers.dir, 

                            #  If you have more than one processor in your 
                            #  machine, then setting the thread count to the 
                            #  number of processors can speed up things like 
                            #  jacknife operations (and hopefully, replicate 
                            #  operations) by using all of the processors.
                       ' threads=', PAR.num.processors, 
                                               
                            #  Looks like you have to set the "novisible" flag 
                            #  in the argument list to maxent and then it will 
                            #  return a 1 if it fails.  Without the "novisible" 
                            #  flag, it seems to assume that you know there was 
                            #  a problem and returns an exit code that says it 
                            #  succeeded instead of failed.
                       ' novisible', 

                        ' autorun  redoifexists', 
                        
                        sep = '' )

maxentCmd = shortMaxentCmd     

if (PAR.do.maxent.replicates)  { maxentCmd = longMaxentCmd }
cat( '\n\nThe long command to run maxent is:', longMaxentCmd, '\n' )
cat( '\n\nThe short command to run maxent is:', shortMaxentCmd, '\n' )

cat( '\n\nThe command to run maxent is:', maxentCmd, '\n' )

                       
maxent.exit.code = system (maxentCmd)

cat ("\n\nmaxent.exit.code = ", maxent.exit.code, ", class (maxent.exit.code) = ", class (maxent.exit.code))
if (maxent.exit.code != 0)
  {
  stop (paste ("\n\nmaxent failed: maxent.exit.code = ", 
               maxent.exit.code, sep=''), 
        call. = FALSE)
  } else { cat ("\n\nmaxent run succeeded (i.e., exit code == 0).") }

#===============================================================================

	#  Maxent is done now, so compare its results to the correct values.
	
#===============================================================================

    #  When you use the replicates option in maxent (e.g., bootstrapping or 
    #  cross-validation), it changes its naming convention.  Instead of spp.1.asc, 
    #  you get spp.1_0.asc, spp.1_1.asc, etc.  
    #  I'm just going to arbitrarily copy the first replicate into a spp.?.asc 
    #  file so that all of the naming conventions from before still hold up.  
    #  I don't think that it matters which replicate you choose and I don't 
    #  think that using a single more "representative" one like the median 
    #  of the replicates will necessarily preserve the spatial errors.  

if (PAR.do.maxent.replicates)
  {
#  maxentFirstReplicateFilename = paste ("MaxentOutputs/", spp.name, "_0.asc", sep='')
  maxentFirstReplicateFilename = paste (maxent.output.dir, spp.name, "_0.asc", sep='')
#  maxentNoReplicateFilename = paste ("MaxentOutputs/", spp.name, ".asc", sep='')
  maxentNoReplicateFilename = paste (maxent.output.dir, spp.name, ".asc", sep='')
  if( ! file.copy( maxentFirstReplicateFilename,
                   maxentNoReplicateFilename,
                   overwrite = TRUE )) 
    {  
    cat( '\nCould not copy ', maxentFirstReplicateFilename, ' to ', 
         maxentNoReplicateFilename);
    stop( '\nAborted due to error.', call. = FALSE );
    }
  }                       
                       
                       
    #  Get maxent's resulting probability distribution.
    #  Then, subtract it from the true distribution to see the spatial pattern.
     
		#  Load the maxent output distribution into a matrix.
#7/17/11#maxent.rel.prob.dist.filename <- paste (maxent.output.dir, spp.name, '.asc', sep='')
#7/23/11  Replaced the following calls with a call to a new function added 
# to w.R:  read.asc.file.to.matrix().
#maxent.rel.prob.dist.filename <- paste (spp.name, '.asc', sep='')
# maxent.rel.prob.dist <- 
# 	as.matrix (read.table (
# 	           paste (maxent.output.dir, maxent.rel.prob.dist.filename, sep=''), 
# 	           skip=6))
maxent.rel.prob.dist <- read.asc.file.to.matrix (spp.name, maxent.output.dir)
        
        

		#  Normalize the matrix to allow comparison with true distribution.
tot.maxent.rel.prob.dist <- sum (maxent.rel.prob.dist)
maxent.norm.prob.dist <- maxent.rel.prob.dist/tot.maxent.rel.prob.dist
sum (maxent.norm.prob.dist)    #  Make sure it's a prob dist, i.e., sums to 1

	#  Compute the difference between the correct and maxent probabilities 
	#  and save it to a file for display.	
err.between.maxent.and.true.prob.dists <- maxent.norm.prob.dist - norm.prob.matrix

num.img.rows <- dim (err.between.maxent.and.true.prob.dists) [1]
num.img.cols <- dim (err.between.maxent.and.true.prob.dists) [2]

      #  NECESSARY TO WRITE THIS ASC AND PGM FILE OUT?
      #  DOESN'T SEEM LIKE THEY'RE USED FOR ANYTHING.
write.asc.file (err.between.maxent.and.true.prob.dists, 
				paste (analysis.dir, "raw.error.in.dist.", spp.name, sep=''), 
            	num.img.rows, num.img.cols
            	, xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
                , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
                                      #  is not actually on the map.  It's just off the lower 
                                      #  left corner.
                , no.data.value = -9999
                , cellsize = 1
                )
write.pgm.file (err.between.maxent.and.true.prob.dists, 
				paste (analysis.dir, "raw.error.in.dist.", spp.name, sep=''), 
            	num.img.rows, num.img.cols)                

    #-------------------------------------------------------------------------
    #  Plot that pattern.
    #  Compute non-spatial statistics that compare the two distributions.
    #    - rank correlation
    #    - correlation
    #    - KS test  (is KS the test that compares two distributions?)
    #  One question: are there any computer arithmetic issues with all these 
    #  small numbers in these distributions?
    #-------------------------------------------------------------------------
    
    #--------------------------------------------------------------------
    #  IMPORTANT
    #  NOTE:  May want to do these tests using several different views 
    #         that reflect something like a cost-sensitive view.  
    #         For example, what is most important in a Madagascar-style 
    #         use of maxent + zonation is how the true top 10% of the 
    #         distribution performs.
    #         So, you may want to use which() to pull out certain 
    #         subsets of locations to analyze.
    #         More importantly, probably want to do a which() that 
    #         selects the top 10% or so of locations in the true 
    #         distribution and the true Zonation ranking.  Then, 
    #         do various statistics on just those locations in the 
    #         Maxent data to get an idea of how well it does on those.
    #         One more thing - percent error may not be the right 
    #         error to look at in a probability distribution.  
    #         May want to look at the absolute error instead.  
    #         Not sure...
    #--------------------------------------------------------------------    

err.magnitudes <- abs (err.between.maxent.and.true.prob.dists)
write.asc.file (err.magnitudes, 
				paste (analysis.dir, "abs.error.in.dist.", spp.name, sep=''), 
            	num.img.rows, num.img.cols
            	, xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
                , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
                                      #  is not actually on the map.  It's just off the lower 
                                      #  left corner.
                , no.data.value = -9999
                , cellsize = 1
                )

write.pgm.file (err.magnitudes, 
				paste (analysis.dir, "abs.error.in.dist.", spp.name, sep=''), 
            	num.img.rows, num.img.cols)


tot.err.magnitude <- sum (err.magnitudes)
max.err.magnitude <- max (err.magnitudes)

  ####  PROBLEM: norm.prob.matrix not defined?  maxent.norm.prob.dist not defined?
####  Actually, norm.problmatrix IS defined.  Not sure why this comment is here.
####  May be vestigial. Will leave it though until I clean everything up and 
####  make sure it's ok to delete it.
####  BTL - 2011.09.22

npm.vec <- as.vector (norm.prob.matrix)
mnpd.vec <- as.vector (maxent.norm.prob.dist)

pearson.cor <- cor (npm.vec, mnpd.vec, 
     			    method = "pearson"
     			   )
spearman.rank.cor <- cor (npm.vec, mnpd.vec, 
     			    method = "spearman"
     			   )
     			   
#  this one hung R every time I used it...     			   
##kendall.cor <- cor (npm.vec, mnpd.vec,        
##     			    method = "kendall"
##     			   )

##par (mfrow=c(4,2))    #  4 rows, 2 cols
par (mfrow=c(2,2))    #  2 rows, 2 cols

percent.err.magnitudes <- (err.magnitudes / norm.prob.matrix) * 100
hist (percent.err.magnitudes [percent.err.magnitudes <= 100])

write.pgm.file (percent.err.magnitudes, 
				paste (analysis.dir, "percent.error.in.dist.", spp.name, sep=''), 
            	num.img.rows, num.img.cols)    

abs.percent.err.magnitudes <- abs (percent.err.magnitudes)
write.pgm.file (abs.percent.err.magnitudes, 
  			paste (analysis.dir, "abs.percent.error.in.dist.", spp.name, sep=''), 
            	num.img.rows, num.img.cols)

            	
##    #  Reset the largest errors to one fairly large value so that 
##    #  you can reduce the dynamic range of the image and make it 
##    #  easier to differentiate among smaller values.

truncated.err.img <- abs.percent.err.magnitudes 
truncated.err.img [abs.percent.err.magnitudes >= 50] <- 50
write.pgm.file (truncated.err.img, 
				paste (analysis.dir, "truncated.percent.err.img.", spp.name, sep=''), 
            	num.img.rows, num.img.cols)                


show.heatmap <- FALSE
if (show.heatmap)
	{
    		#-----------------------------------------------------------------------
   			#  standard color schemes that I know of that you can use: 
    		#  heat.colors(n), topo.colors(n), terrain.colors(n), and cm.colors(n)
    		#
    		#  I took this code from an example I found on the web and it uses 
    		#  some options that I don't know anything about but it works.
    		#  May want to refine it later.
    		#-----------------------------------------------------------------------
    		
	heatmap (err.between.maxent.and.true.prob.dists, 
		 		Rowv = NA, Colv = NA, 
		 		col = heat.colors (256), 
				###		 scale="column",     #  This can rescale colors within columns.
		 		margins = c (5,10)
		 		)
	}

#===============================================================================

####  NOTES

##  This part works but I'm not sure if it's what we want to do...

#### quantile (norm.prob.matrix, c(0.1,0.9))
#### top.10 <- which(norm.prob.matrix >= quantile (norm.prob.matrix, 0.9))
#### truncated.err <- percent.err.magnitudes
#### truncated.err [percent.err.magnitudes >= quantile (percent.err.magnitudes, 0.95)] <- 50
#### write.pgm.file (truncated.err, 
#### 				paste (analysis.dir, "truncated.err.img", sep=''), 
####             	num.img.rows, num.img.cols)                


##  This part is a copy of the fooling around I did in R to get the stuff 
##  above to work...

#### > x <- pixmap (as.vector(percent.err.magnitudes), nrow=1025)
#### > plot(x)
#### Error in t(x@index[nrow(x@index):1, , drop = FALSE]) : 
####   subscript out of bounds
#### > x
#### Pixmap image
####   Type          : pixmap 
####   Size          : 1025x1025 
####   Resolution    : 1x1 
####   Bounding box  : 0 0 1025 1025 
#### 
#### > img <- read.pnm ('./ResultsAnalysis/percent.error.in.dist.pgm')
#### Read 1050625 items
#### > plot(img)
#### > truncated.err <- norm.prob.matrix
#### > truncated.err [norm.prob.matrix >= quantile (norm.prob.matrix, 0.95)] <- 50
#### > 
#### > truncated.err <- percent.err.magnitudes
#### > truncated.err [percent.err.magnitudes >= quantile (percent.err.magnitudes, 0.95)] <- 50
#### > 
#### > write.pgm.file (truncated.err, 
#### + 				paste (analysis.dir, "truncated.err.img", sep=''), 
#### +             	num.img.rows, num.img.cols)                
#### 
#### wrote ./ResultsAnalysis/truncated.err.img.pgm
#### > 
#### > img <- read.pnm ('./ResultsAnalysis/truncated.err.img.pgm')
#### Read 1050625 items
#### > plot(img)
#### > 

#===============================================================================

#num.cols <- 1025
#num.rows <- 1025
num.rows <- dim (truncated.err.img)[1]
num.cols <- dim (truncated.err.img)[2]

par (mfrow=c(1,1))

#img.matrix <- truncated.err.img
#jpeg (paste (analysis.dir, "test.jpg", sep=''))
#draw.img (img.matrix)    
#points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")


    #  NOTE: There is one issue with comparing the outputs of filled.contour().
    #        It rescales to fit the data, so the same color scheme may give 
    #        different colors to the same values on different maps.  
    #        I think that you Can control the max and min values in the 
    #        scaling though.  Need to look at some of the arguments that 
    #        I commented out when I cloned the example from R help or the web.

if (! PAR.use.old.maxent.output.for.input)
{
    if (write.to.file)  tiff (paste (analysis.dir, "env.layer.1.tiff", sep=''))    
#    draw.img (env.layers [[1]])
#    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
#    plot.main.title <- "Env Layer 1"
#    plot.key.title <- "Env\nMeasure1"
#    map.colors <- cm.colors
#    point.color <- "red"

    draw.filled.contour.img (env.layers [[1]], 
                             "Env Layer 1", "Env\nMeasure1", 
                             cm.colors, "red")
    if (write.to.file)  dev.off()
}

# write.to.file = TRUE
# analysis.dir = "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/ResultsAnalysis/"
# test.img = matrix (1:256, nrow=256,ncol=256)
#     if (write.to.file)  tiff (paste (analysis.dir, "test.tiff", sep=''))    
#     draw.filled.contour.img (test.img, 
#                              "Test Image", "Env\nMeasure1", 
#                              cm.colors, "red")
#     if (write.to.file)  dev.off()




if (! PAR.use.old.maxent.output.for.input)
{
    if (write.to.file)  tiff (paste (analysis.dir, "env.layer.2.tiff", sep=''))
#    draw.img (env.layers [[2]])
#    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
    draw.filled.contour.img (env.layers [[2]], 
                             "Env Layer 2", "Env\nMeasure2", 
                             cm.colors, "red")
    if (write.to.file)  dev.off()
}
    
    if (write.to.file)  tiff (paste (analysis.dir, "true.prob.dist.", spp.name,".tiff",sep=''))
#    draw.img (norm.prob.matrix) 
#    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
    draw.filled.contour.img (norm.prob.matrix, 
                             "True Prob Distribution", "Prob", 
                             terrain.colors, "red")
    if (write.to.file)  dev.off()

    if (write.to.file)  tiff (paste (analysis.dir, "maxent.prob.dist.", spp.name,".tiff",sep=''))
#    draw.img (maxent.norm.prob.dist) 
#    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
    draw.filled.contour.img (maxent.norm.prob.dist, 
                             "Maxent Prob Distribution", "Prob", 
                             terrain.colors, "red")
    if (write.to.file)  dev.off()


    if (write.to.file)  tiff (paste (analysis.dir, "raw.error.map.", spp.name,".tiff", sep=''))
#    plot.main.title <- "Raw error in Maxent Probability"
#    plot.key.title <- "Error"
#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
    contour.levels.to.draw <- c (20)
    draw.contours = TRUE 
    draw.filled.contour.img (err.between.maxent.and.true.prob.dists, 
                             "Raw error in Maxent Probability", 
                             "Error", 
                             heat.colors, "turquoise", 
                             draw.contours, 
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()
#write.table (err.between.maxent.and.true.prob.dists, 
#             file = paste (analysis.dir, "raw.error.map.", spp.name,".table", sep=''))
# x = "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/ResultsAnalysis/raw.error.map.spp.2.table"

    if (write.to.file)  tiff (paste (analysis.dir, "abs.raw.error.map.", spp.name,".tiff", sep=''))
#    plot.main.title <- "Abs value of raw error in Maxent Probability"
#    plot.key.title <- "Error\nAbs Value"
#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
    contour.levels.to.draw <- c (20)
    draw.contours = TRUE 
    draw.filled.contour.img (err.magnitudes, 
                             "Abs value of raw error in Maxent Probability", 
                             "Error\n(Abs Value)", 
                             heat.colors, "turquoise", 
                             draw.contours, 
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()
    if (write.to.file)  tiff (paste (analysis.dir, "error.map.", spp.name,".tiff", sep=''))
#    plot.main.title <- "Percent error in Maxent Probability"
#    plot.key.title <- "Error\n(percent)"
#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
    contour.levels.to.draw <- c (20)
    draw.contours = TRUE 
    draw.filled.contour.img (truncated.err.img, 
                             "Percent error in Maxent Probability", 
                             "Error\n(percent)", 
                             heat.colors, "turquoise", 
                             draw.contours, 
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()

if (PAR.do.maxent.replicates)  
  {                
maxent.bootstrap.sd = 
    read.asc.file.to.matrix (paste (spp.name, "_stddev", sep=''), 
                             maxent.output.dir)

#  Just realized this is probably not necessary because maxent
#  writes a .png of the sd values in the plots directory.                             
    if (write.to.file)  tiff (paste (maxent.output.dir, "maxent.bootstrap.sd.", spp.name,".tiff", sep=''))
#    plot.main.title <- "Percent error in Maxent Probability"
#    plot.key.title <- "Error\n(percent)"
#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
    contour.levels.to.draw <- c (20)
    draw.contours = TRUE 
    draw.filled.contour.img (maxent.bootstrap.sd, 
                             paste ("Maxent ", spp.name, ".bootstrap std dev", sep=''), 
                             "StdDev", 
                             terrain.colors, "red", 
                             draw.contours, 
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()
}                             
                             
                             
    #  Not using this at the moment since I've gotten the filled.contour() 
    #  code to behave pretty well.  May need this more stripped down stuff 
    #  later though.  It also will draw contour lines on the image instead 
    #  of just doing a graded image.  (However, I've just figured out how 
    #  to draw contour lines on the filled.contour maps too, so maybe it 
    #  doesn't matter.)
if (use.draw.image)
	{
    par (mfrow=c(1,2))

if (! PAR.use.old.maxent.output.for.input)
{    
    draw.img (env.layers [[1]])
    draw.img (env.layers [[2]])
}

    draw.img (norm.prob.matrix) 
    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
    draw.img (maxent.norm.prob.dist) 
    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
    
    draw.img (truncated.err.img)
    points (sampled.locs.x.y, pch = 19, bg = "red", col = "red")
    }

#===============================================================================

    #  This "weird function" is taken from the R help file for levelplot.
    #  It makes an interesting radially banded pattern that could be a useful 
    #  synthetic test as a landscape pattern.
## library(lattice)
## x <- seq(pi/4, 5 * pi, length.out = 100)
## y <- seq(pi/4, 5 * pi, length.out = 100)
## r <- as.vector(sqrt(outer(x^2, y^2, "+")))
## grid <- expand.grid(x=x, y=y)
## grid$z <- cos(r^2) * exp(-r/(pi^3))
## levelplot(z~x*y, grid, cuts = 50, scales=list(log="e"), xlab="",
##            ylab="", main="Weird Function", sub="with log scales",
##            colorkey = FALSE, region = TRUE)

    #  That help file also gives an example of labelled contours that 
    #  could be useful too.
## require(stats)
## attach(environmental)
## ozo.m <- loess((ozone^(1/3)) ~ wind * temperature * radiation,
##        parametric = c("radiation", "wind"), span = 1, degree = 2)
## w.marginal <- seq(min(wind), max(wind), length.out = 50)
## t.marginal <- seq(min(temperature), max(temperature), length.out = 50)
## r.marginal <- seq(min(radiation), max(radiation), length.out = 4)
## wtr.marginal <- list(wind = w.marginal, temperature = t.marginal,
##         radiation = r.marginal)
## grid <- expand.grid(wtr.marginal)
## grid[, "fit"] <- c(predict(ozo.m, grid))
## contourplot(fit ~ wind * temperature | radiation, data = grid,
##             cuts = 10, region = TRUE,
##             xlab = "Wind Speed (mph)",
##             ylab = "Temperature (F)",
##             main = "Cube Root Ozone (cube root ppb)")
## detach()

}  #  end - for each species
                        
#===============================================================================

    #-----------------
    #  Run Zonation.
    #-----------------

#PAR.current.run.directory = PAR.current.output.directory

spp.used.in.reserve.selection.vector <- 1:PAR.num.spp.in.reserve.selection

current.os <- sessionInfo()$R.version$os
slash.in.path.for.this.os = "/"
if( current.os == 'mingw32' ) { slash.in.path.for.this.os = "\\" }
os.specific.lead.in = ""
if (current.os != 'mingw32')  { os.specific.lead.in = "wine " }   

setwd (PAR.current.output.directory)
                        
full.path.to.zonation.exe <- paste (source.dir, '/', PAR.path.to.zonation,'/',
                                    PAR.zonation.exe.filename, sep = '')
cat( '\n\n full.path.to.zonation.exe=', full.path.to.zonation.exe )

    #  Copy the Zonation parameter settings file to the zonation dir

from.filename = paste (source.dir, '/',PAR.path.to.zonation, '/', 
                        PAR.zonation.parameter.filename, sep = '' )
cat( '\n\nfrom.filename =', from.filename)
                        
to.filename = paste (zonation.output.dir, 
                     PAR.zonation.parameter.filename, sep = '' )
cat( '\n\nto.filename =', to.filename)
                      
if (!file.copy (from.filename, to.filename, overwrite = TRUE )) 
  {    
  cat( '\nCould not copy zonation parameter settings file to zonation directory\n' );
  stop( '\nAborted due to error.', call. = FALSE );    
  }
                        
    #---------------------------------------------------------------------------
    #  Done with generic setup for both apparent and correct runs of zonation.
    #  Ready to set up for apparent now.
    #---------------------------------------------------------------------------
                             
    # Generate the APPARENT species list file name for zonation 
    
zonation.app.spp.list.full.filename = paste (zonation.output.dir, 
                                             PAR.zonation.app.spp.list.filename, 
                                             sep ='' )
cat ("\n\nzonation.app.spp.list.full.filename = ", 
     zonation.app.spp.list.full.filename, sep='')

if (file.exists (zonation.app.spp.list.full.filename)) 
    file.remove (zonation.app.spp.list.full.filename) 

    #----------
    # Now generate the file contents.
    #----------    
    
for (cur.spp.id in spp.used.in.reserve.selection.vector) 
  {
  filename <- paste (PAR.maxent.output.dir.name, '\\spp.', cur.spp.id, 
#  filename <- paste (PAR.maxent.output.dir.name, '/spp.', cur.spp.id, 
                     '.asc', sep = '');  
  line.of.text <- paste ("1.0 1.0 1 1 1 ", filename, "\n", sep = "");
  cat (line.of.text, 
       file = zonation.app.spp.list.full.filename, append = TRUE);  
  }

    #------------------------------------------------
    #  Ascelin's code from run.zonation.R
    #  it assumes that you're sitting in the output 
    #  directory when you call zonation and all 
    #  paths are relative to that
    #------------------------------------------------
    
    #  Parameter file name should be same for both apparent and correct.
zonation.parameter.filename = paste ("Zonation", "/", PAR.zonation.parameter.filename, sep='')

    #  Species list file name and output file name should be different for 
    #  apparent and correct.  
    #  Not sure if the slash has to change based on the os.  
    #  Doing nothing about that at the moment, but can easily change it 
    #  to the slash variable set above if this fails on windows machines.    
zonation.spp.list.filename = paste ("Zonation", "/", PAR.zonation.app.spp.list.filename, sep='')
zonation.output.filename = paste ("Zonation", "/", PAR.zonation.app.output.filename, sep='')

      #  Since Zonation is a windows-only program at this point, 
      #  we have to run it under a windows emulator (wine) if we're  
      #  running on linux or a mac
      
      #  NOTE: Have not tested any of the windows-specific stuff on windows yet.
      #        BTL - 2011.09.22
      
system.command.run.zonation <- paste (os.specific.lead.in, 
                                      full.path.to.zonation.exe, '-r',
                                      zonation.parameter.filename, 
                                      zonation.spp.list.filename, 
                                      zonation.output.filename,
#                                     "0.0 0 1.0 0" )    #  stay open after finished
                                      "0.0 0 1.0 1" ) 
  

cat ('\n The system command to run zonation on APPARENT will be:', 
     system.command.run.zonation)
     
    #-------------------------------------------------------------------------
    #  NOTE: The logic here having to do with trapping exit codes 
    #        does not work correctly yet because I'm not getting the 
    #        exit code from zonation passed back up through wine and I don't 
    #        know if zonation is even passing a non-zero exit code when it 
    #        has a problem.  I'll leave the code here for now though because 
    #        it's not hurting anything and it's what we do want to do in the 
    #        end.
    #        BTL - 2011.09.22
    #-------------------------------------------------------------------------
    
zonation.exit.code = system (system.command.run.zonation)

cat ("\n\nzonation.exit.code = ", maxent.exit.code, ", class (zonation.exit.code) = ", class (zonation.exit.code))
if (zonation.exit.code != 0)
  {
  stop (paste ("\n\nzonation failed: zonation.exit.code = ", 
               maxent.exit.code, sep=''), 
        call. = FALSE)
  } else { cat ("\n\nzonation run succeeded (i.e., exit code == 0).") }
                        
    #--------------------
    #  Done running zonation on apparent.
    #  Ready to set up for correct now.
    #--------------------

    # Generate the CORRECT species list file name for zonation 
    
zonation.cor.spp.list.full.filename = paste (zonation.output.dir, 
                                             PAR.zonation.cor.spp.list.filename, 
                                             sep ='' )
cat ("\n\nzonation.cor.spp.list.full.filename = ", 
     zonation.cor.spp.list.full.filename, sep='')

if (file.exists (zonation.cor.spp.list.full.filename)) 
    file.remove (zonation.cor.spp.list.full.filename) 

    #----------
    # Now generate the file contents.
    #----------    
    
for (cur.spp.id in spp.used.in.reserve.selection.vector) 
  {
  filename <- paste (PAR.prob.dist.layers.dir.name, 
                     '\\true.prob.dist.spp.', cur.spp.id, 
                     '.asc', sep = '');  
  line.of.text <- paste ("1.0 1.0 1 1 1 ", filename, "\n", sep = "");
  cat (line.of.text, 
       file = zonation.cor.spp.list.full.filename, append = TRUE);  
  }

    #  Species list file name and output file name should be different for 
    #  apparent and correct.  
    #  Not sure if the slash has to change based on the os.  
    #  Doing nothing about that at the moment, but can easily change it 
    #  to the slash variable set above if this fails on windows machines.    
zonation.spp.list.filename = paste ("Zonation", "/", PAR.zonation.cor.spp.list.filename, sep='')
zonation.output.filename = paste ("Zonation", "/", PAR.zonation.cor.output.filename, sep='')

      #  Since Zonation is a windows-only program at this point, 
      #  we have to run it under a windows emulator (wine) if we're  
      #  running on linux or a mac
      
      #  NOTE: Have not tested any of the windows-specific stuff on windows yet.
      #        BTL - 2011.09.22
      
system.command.run.zonation <- paste (os.specific.lead.in, 
                                      full.path.to.zonation.exe, '-r',
                                      zonation.parameter.filename, 
                                      zonation.spp.list.filename, 
                                      zonation.output.filename,
#                                     "0.0 0 1.0 0" )    #  stay open after finished
                                      "0.0 0 1.0 1" ) 
  

cat ('\n The system command to run zonation on CORRECT will be:', 
     system.command.run.zonation)
     
    #-------------------------------------------------------------------------
    #  NOTE: The logic here having to do with trapping exit codes 
    #        does not work correctly yet because I'm not getting the 
    #        exit code from zonation passed back up through wine and I don't 
    #        know if zonation is even passing a non-zero exit code when it 
    #        has a problem.  I'll leave the code here for now though because 
    #        it's not hurting anything and it's what we do want to do in the 
    #        end.
    #        BTL - 2011.09.22
    #-------------------------------------------------------------------------
    
zonation.exit.code = system (system.command.run.zonation)

cat ("\n\nzonation.exit.code = ", maxent.exit.code, ", class (zonation.exit.code) = ", class (zonation.exit.code))
if (zonation.exit.code != 0)
  {
  stop (paste ("\n\nzonation failed: zonation.exit.code = ", 
               maxent.exit.code, sep=''), 
        call. = FALSE)
  } else { cat ("\n\nzonation run succeeded (i.e., exit code == 0).") }
                        
#===============================================================================

## if( ! file.copy( "../zonation/zonation_output.rank.asc", ".",
##                 overwrite = TRUE )) {
  
##   cat( '\nCould not copy zonation result to runall directory\n' );
##   stop( '\nAborted due to error.', call. = FALSE );

## }

## # read in the zonation output file. Remove the header that the ".asc"
## # file contains 

#rows = num.rows
#number.asc.header.rows <- 6;  #number of header rows in the ascii files for
#                              #zonation.

zonation.app.rank = 
    read.asc.file.to.matrix ("zonation_app_output.rank", 
#                             "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/Zonation/")
                             zonation.output.dir)
                            
zonation.cor.rank = 
    read.asc.file.to.matrix ("zonation_cor_output.rank", 
#                             "/Users/bill/D/Projects_RMIT/AAA_PapersInProgress/G01_simulated_ecology/MaxentTests/Zonation/")
                             zonation.output.dir)
  
    #--------------------
                             
  #  Compute the difference between the correct and zonation probabilities 
	#  and save it to a file for display.	
err.between.app.and.zonation.ranks <- zonation.app.rank - zonation.cor.rank

num.img.rows <- dim (err.between.app.and.zonation.ranks) [1]
num.img.cols <- dim (err.between.app.and.zonation.ranks) [2]

write.pgm.file (err.between.app.and.zonation.ranks, 
				paste (analysis.dir, "raw.error.in.zonation.ranks", sep=''), 
            	num.img.rows, num.img.cols)                

    #-------------------------------------------------------------------------
    #  Plot that pattern.
    #  Compute non-spatial statistics that compare the two distributions.
    #    - rank correlation
    #    - correlation
    #    - KS test  (is KS the test that compares two distributions?)
    #  One question: are there any computer arithmetic issues with all these 
    #  small numbers in these distributions?
    #-------------------------------------------------------------------------
    
    #--------------------------------------------------------------------
    #  IMPORTANT
    #  NOTE:  May want to do these tests using several different views 
    #         that reflect something like a cost-sensitive view.  
    #         For example, what is most important in a Madagascar-style 
    #         use of maxent + zonation is how the true top 10% of the 
    #         distribution performs.
    #         So, you may want to use which() to pull out certain 
    #         subsets of locations to analyze.
    #         More importantly, probably want to do a which() that 
    #         selects the top 10% or so of locations in the true 
    #         distribution and the true Zonation ranking.  Then, 
    #         do various statistics on just those locations in the 
    #         Maxent data to get an idea of how well it does on those.
    #         One more thing - percent error may not be the right 
    #         error to look at in a probability distribution.  
    #         May want to look at the absolute error instead.  
    #         Not sure...
    #--------------------------------------------------------------------    

err.magnitudes <- abs (err.between.app.and.zonation.ranks)
# write.asc.file (err.magnitudes, 
# 				paste (analysis.dir, "abs.error.in.dist.", spp.name, sep=''), 
#             	num.img.rows, num.img.cols
#             	, xllcorner = 1    #  Looks like maxent adds the xy values to xllcorner, yllcorner
#                 , yllcorner = 1    #  so they must be (0,0) instead of (1,1), i.e., the origin
#                                       #  is not actually on the map.  It's just off the lower 
#                                       #  left corner.
#                 , no.data.value = -9999
#                 , cellsize = 1
#                 )
write.pgm.file (err.magnitudes, 
				paste (analysis.dir, "abs.error.in.zonation.ranks", sep=''), 
            	num.img.rows, num.img.cols)


tot.err.magnitude <- sum (err.magnitudes)
max.err.magnitude <- max (err.magnitudes)

#####---------------------------------------------------------------------------
#####  I don't think these actually apply for zonation.
#####  Were they just cloned from the maxent analysis?
#####  ####  PROBLEM: norm.prob.matrix not defined?  zonation.norm.prob.dist not defined?

#####npm.vec <- as.vector (norm.prob.matrix)
#####mnpd.vec <- as.vector (zonation.norm.prob.dist)

#####pearson.cor <- cor (npm.vec, mnpd.vec, 
#####     			    method = "pearson"
#####     			   )
#####spearman.rank.cor <- cor (npm.vec, mnpd.vec, 
#####     			    method = "spearman"
#####     			   )
     			   
######  this one hung R every time I used it...     			   
#######kendall.cor <- cor (npm.vec, mnpd.vec,        
#######     			    method = "kendall"
#######     			   )
#####---------------------------------------------------------------------------

##par (mfrow=c(4,2))    #  4 rows, 2 cols
par (mfrow=c(2,2))    #  2 rows, 2 cols

percent.err.magnitudes <- (err.magnitudes / zonation.cor.rank) * 100
hist (percent.err.magnitudes [percent.err.magnitudes <= 100])

write.pgm.file (percent.err.magnitudes, 
				paste (analysis.dir, "percent.error.in.zonation.ranks", sep=''), 
            	num.img.rows, num.img.cols)    

abs.percent.err.magnitudes <- abs (percent.err.magnitudes)
write.pgm.file (abs.percent.err.magnitudes, 
				paste (analysis.dir, "abs.percent.error.in.zonation.ranks", sep=''), 
            	num.img.rows, num.img.cols)

            	
##    #  Reset the largest errors to one fairly large value so that 
##    #  you can reduce the dynamic range of the image and make it 
##    #  easier to differentiate among smaller values.

truncated.err.img <- abs.percent.err.magnitudes 
truncated.err.img [percent.err.magnitudes >= 50] <- 50
write.pgm.file (truncated.err.img, 
				paste (analysis.dir, "truncated.zonation.rank.percent.err.img", sep=''), 
            	num.img.rows, num.img.cols)                


    if (write.to.file)  tiff (paste (analysis.dir, "percent.error.zonation.rank.map.tiff", sep=''))
#    plot.main.title <- "Percent error in Zonation rank"
#    plot.key.title <- "Error\n(percent)"
#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
    contour.levels.to.draw <- c (20)
    draw.contours = TRUE 
    draw.filled.contour.img (truncated.err.img, 
                             "Truncated percent error in Zonation rank", 
                             "Error\n(percent)", 
                             terrain.colors, "red", 
                             draw.contours, 
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()
                
    if (write.to.file)  tiff (paste (analysis.dir, "raw.error.zonation.rank.map.tiff", sep=''))
#    plot.main.title <- "Percent error in Zonation rank"
#    plot.key.title <- "Error\n(percent)"
#    draw.filled.contour.img (truncated.err.img, plot.main.title, plot.key.title)
    contour.levels.to.draw <- c (-0.50, 0.0)
    draw.contours = TRUE 
    draw.filled.contour.img (err.between.app.and.zonation.ranks, 
                             "Raw error in Zonation rank", 
                             "Error\n(raw)", 
                             terrain.colors, "red", 
                             draw.contours, 
                             contour.levels.to.draw
                             )
    if (write.to.file)  dev.off()

#  Not sure what's going on here.  Trying to put a contour around the top 
#  10% or so of zonation ranks, but it doesn't seem to agree with the .jpg 
#  files that zonation writes out (bright red, etc.).
#     if (write.to.file)  tiff (paste (analysis.dir, "zonation.app.rank.map.tiff", sep=''))
#     contour.levels.to.draw <- c (0.10)
#     draw.contours = TRUE 
#     draw.filled.contour.img (zonation.app.rank, 
#                              "Zonation Apparent rank", 
#                              "Rank", 
#                              terrain.colors, "red", 
#                              draw.contours, 
#                              contour.levels.to.draw
#                              )
#     if (write.to.file)  dev.off()
# 
#     if (write.to.file)  tiff (paste (analysis.dir, "zonation.cor.rank.map.tiff", sep=''))
#     contour.levels.to.draw <- c (0.10)
#     draw.contours = TRUE 
#     draw.filled.contour.img (zonation.cor.rank, 
#                              "Zonation Correct rank", 
#                              "Rank", 
#                              terrain.colors, "red", 
#                              draw.contours, 
#                              contour.levels.to.draw
#                              )
#     if (write.to.file)  dev.off()

#===============================================================================

    #-------------------------------------------------------------------
    #
    #  Compute and plot the fraction of correct high-ranking 
    #  pixels that are captured by selecting a given level of apparent 
    #  high-ranking pixels.  
    #  This is somewhat like an ROC curve.
    #
    #  This works now, but I have a bunch of questions about whether 
    #  it may have a few problems.  Don't have time to investigate 
    #  these right now but I will flag them here for checking when 
    #  I come back to working on this project.
    #  BTL - 2011.09.26
    #
    #  1) What if ranks are not integers?  Does this work right?
    #     Zonation ranks are actually fractions of 0 to 1 and I'm 
    #     not sure whether that matters to this code.
    #
    #  2) ** Important ** - I don't think that ties are currently 
    #     addressed at all, much less handled correctly.  
    #     May be able to do something through the choice of tie 
    #     behavior in the call to order() or rank(), but that's 
    #     probably still not everything that has to be done.
    #
    #  3) Need to do a little inductive proof to make sure that the 
    #     code to compute frac.true below is correct.  
    #     Would also be good to run a brute force test that does a 
    #     direct select and sum for each threshold level to then 
    #     compare that with the incremental version that I've put 
    #     in here to make things go faster.  The brute force version 
    #     would be much slower (I think, though maybe not that bad for 
    #     only doing at each percent level rather than every pixel), 
    #     but the code is Much more straightforward.
    #
    #  4) Need to make a function out of this code so that cor and app
    #     can be reversed.
    #
    #  5) Probably want to write the percent level gain and frac.true 
    #     values out to a file and/or database so that they can be 
    #     summarized across many runs.
    #
    #  6) Ascelin had suggested making some kind of a plot related to 
    #     representation goals, i.e., how much apparent do you have to 
    #     to get to achieve a certain representation level across all 
    #     species.  We can extend this to not having to choose a level 
    #     by plotting it for each possible apparent level.  However, 
    #     both of these plots will take a fair bit more coding because 
    #     it now comes down to visiting every species map for each of 
    #     these questions.  We also have to make a decision about how 
    #     to measure representation achieved.  
    #
    #     a) It could be by adding up the probabilities at pixels.  
    #
    #     b) Or, it could be that you pick a probability threshold and 
    #     set 0 or 1 based on the threshold then add up the resulting 
    #     0 and 1 values.  
    #
    #     c) *** Or, most interesting of all, *** 
    #     you could define a probability of representation as the 
    #     target rather than adding up either of the above.  In the 
    #     case of this kind of target, you'd need to compute something 
    #     like the joint probabilty of not representing the species 
    #     (product of all the (1-prob) values) and then subtracting 
    #     that from 1.  [NOTE: I just realized that this is really 
    #     only giving the probability of having ONE instance.  The 
    #     probability calculation would be considerably more difficult 
    #     for having more than 1 instance.]
    #
    #     Actually, this might be more interesting to 
    #     have as the y value in a plot like the frac.true.  That is, 
    #     you could compute this value for every level of correct 
    #     probability (and apparent probability) in the selection 
    #     based on the apparent.
    #
    #-------------------------------------------------------------------

z.cor = zonation.cor.rank

z.app = zonation.app.rank

    #  This is a hack to quickly generate some random reserve selections to 
    #  see what that curve would look like in comparison to the typical 
    #  checkmark shape that a normal reserve selection often generates.
    #  After doing this a few times, it looks, as expected, like a 1:1 line.
    #  So, an interesting question is to see how much you gain above this 
    #  "neutral" model of reserve selection.  I've added a gain calculation 
    #  at the end of this to reflect that.  
PAR.try.random.z.app = FALSE
if (PAR.try.random.z.app)
    z.app = sample (1:num.cells, replace=FALSE)

rank.z.cor = rank (z.cor)
order.z.app = order (z.app)
z.app.ordered.z.cor.ranks = rank.z.cor [order.z.app]

z.app.le.true.cts = rep (0, num.cells)
frac.true = rep (0, num.cells)
gain = rep (0, num.cells)
for (i in 1:num.cells)
    {    
    cur.cor.rank = z.app.ordered.z.cor.ranks [i]
    
    if (cur.cor.rank < i)
        {
        z.app.le.true.cts [i] = z.app.le.true.cts [i] + 1
        
        } else 
        {
        z.app.le.true.cts [z.app.ordered.z.cor.ranks [i]] = 
            z.app.le.true.cts [z.app.ordered.z.cor.ranks [i]] + 1        
        }
    
    if (i > 1)  
        {
        z.app.le.true.cts [i] = z.app.le.true.cts [i] + 
                                z.app.le.true.cts [i - 1]
        }
        
        
    frac.true [i] = z.app.le.true.cts [i] / i
    gain [i] = frac.true [i] - i/num.cells
    }
        
percent.indices = round (1:100 * (num.cells / 100))
reduced.frac.true = frac.true [percent.indices]
reduced.gain = gain [percent.indices]

    if (write.to.file)  pdf (paste (analysis.dir, "reduced.frac.true.pdf", sep=''))
plot (reduced.frac.true, 
        ylim=c(0,1), 
        xlab="Percent of landscape reserved using apparent ranks", 
        ylab="Fraction reserved having correct rank at least as good as apparent rank")    
    if (write.to.file)  dev.off()

    if (write.to.file)  pdf (paste (analysis.dir, "gain.pdf", sep=''))
plot (reduced.gain, 
        ylim=c(0,1), 
        xlab="Percent of landscape reserved using apparent ranks", 
        ylab="Gain over random reserve")    
    if (write.to.file)  dev.off()

#---------------------------------------

    #  Write the values to a file so that they can be compiled across runs 
    #  later on.
percent.reserved = 1:100
write.csv (cbind (percent.reserved, percent.indices, 
           reduced.frac.true, reduced.gain), 
           "frac.true.csv")

#---------------------------------------

if (write.to.file)  pdf (paste (analysis.dir, "captured.pop.pdf", sep=''))

    #  Plot the fraction of populations captured by each zonation reserve 
    #  level (similar to an ROC curve).
        #  Sort locations by Zonation rank.
    
        #  Plot x = Zonation rank (i.e., fraction of landscape reserved) 
        #    by y = cumulative fraction of total samples.
    
        #  Can do this for:
        #      - each species
        #      - worst represented species 
        #      - 95th percentile (i.e., almost worst) represented species 

##------------------------------------------------------------------------------
##  xxx
##  BTL - 2011.10.03
##
##  I JUST REALIZED THAT THIS IS WRONG FROM HERE ON !
##  IT'S ONLY PLOTTING FOR THE LAST SPECIES THAT WAS CREATED.
##  IT'S NOT DOING IT FOR ALL SPECIES OR EVEN THE WORST SPECIES.
##  IT'S JUST WHATEVER IS LEFT HANGING AROUND THE SAMPLE.PRESENCE.INDICES...
##  FROM THE LAST SPECIES THAT WAS LOADED.
##  xxx
##------------------------------------------------------------------------------

        #  Find the species locations (already have true from 
        #  the original draw).
sample.presence.indices = 
    true.presence.indices [sample.presence.indices.into.true.presence.indices]

#####  temporary
#####num.true.presences = 10
#####num.samples.to.take = num.true.presences / 2

# Define colors to be used for the different population coverages.
#plot.colors = c (rgb(r=0.0,g=0.0,b=0.9), "red", "forestgreen")
plot.colors = c ("blue", "red")
    
        #  Look up the Zonation rankings (% of landscape) for each location.
fracTruePop = 1:num.true.presences / num.true.presences
#####(true.presence.zonation.cor.rank = sort (runif (num.true.presences)))
true.presence.zonation.cor.rank = sort (zonation.cor.rank [true.presence.indices])
#  Make sure that the bottom axis of the plot doesn't get cut off on my 
#  small MacBook Pro screen.
#####quartz (height = 6)
plot (c (0.0, true.presence.zonation.cor.rank, 1.0), c (0.0, fracTruePop, 1.0), 
  	  xlim = c (0.0, 1.0), 
  	  xlab = "Fraction of landscape reserved", 
  	  ylim = c (0.0, 1.0), 
  	  ylab = "Fraction of population covered", 
  	  asp = 1,
  	  lty = "solid", 
  	  type = "l", 
  	  col = plot.colors [1],
  	  main = "Frac of population covered at given frac of landscape reserved"
  	  )
  	  
fracAppPop = 1:num.samples.to.take / num.samples.to.take
(app.presence.zonation.cor.rank = sort (runif (num.samples.to.take)))
app.presence.zonation.cor.rank = sort (zonation.cor.rank [sample.presence.indices])

lines (c (0, jitter (app.presence.zonation.cor.rank), 1), c (0, fracAppPop, 1), 
  	  lty = 1,
  	  col = plot.colors [2]
  	  )
        
lines (c (0, jitter (app.presence.zonation.cor.rank), 1), c (0, fracAppPop, 1), 
  	  lty = 1,
  	  col = plot.colors [2]
  	  )
                
#####(app.presence.zonation.app.rank = sort (runif (num.samples.to.take)))
app.presence.zonation.app.rank = sort (zonation.app.rank [sample.presence.indices])
lines (c (0, app.presence.zonation.app.rank, 1), c (0, fracAppPop, 1), 
  	  lty = 2,
  	  col = plot.colors [2]
  	  )
        
# Create a legend in the top-left corner that is slightly  
# smaller and has no border
legend("topleft", c ("full pop on cor   (solid = correct)","sample on cor","","sample on app (dashed = apparent)"), cex=0.8, col=plot.colors, 
#   lty=1:3, lwd=2, bty="n");
   lty=c(1,1,0,2), lwd=2, bty="n");
 
 
if (write.to.file)  dev.off()
 
 
 
 
 
 
 
 
 
 
 
#===============================================================================

    #  JUNKYARD FOR TEST CODE IN BUILDING CODE ABOVE.
    #  NOT READY TO DELETE ALL THESE LITTLE BITS YET BECAUSE 
    #  SOME POINT TO USEFUL THINGS (E.G., KNN).
    #  BTL - 2011.09.28

    #--------------------
                        
  if (FALSE)

{    # commenting out of rest of code for testing 
#stop( '\n\n', call. = FALSE );
# Run command (should die before it hits this):
# java -Drunnerclass=JythonRunner -jar rdv.jar execlocalruns --projectspec=projects/guppy/projectparams.json --revision=-1 --localcodepath=. --commandlineflags="-pguppy"  

  
##num.rows = 5
##num.cols = 5
##num.cells = num.rows * num.cols

##z.cor = matrix (sample (num.cells), nrow=num.rows, ncol=num.cols, byrow=TRUE)
z.cor = zonation.cor.rank
##cat ("\nz.cor = \n")
##print (z.cor)

##z.app = matrix (sample (num.cells), nrow=num.rows, ncol=num.cols, byrow=TRUE)
z.app = zonation.app.rank
##cat ("\nz.app = \n")
##print (z.app)

##cat ("\n\norder (z.cor) = \n")
##print (order (z.cor))

##cat ("\n\norder (z.app) = \n")
##print (order (z.app))

    #  Determine which apparent values are less than or equal to their true 
    #  ranks, i.e., which apparent ones are really ones that we would want to 
    #  buy if we were spending up to that level in the correct ranking.  
    #  These are something like True Positives.  
z.app.le.z.cor = (z.app <= z.cor)

##cat ("\n\nz.app.le.z.cor = \n")
##print (z.app.le.z.cor)

    #  Order these values by their true zonation rank.
ordered.z.app.le.z.cor = z.app.le.z.cor [order(z.cor)]

percent.indices = round (1:100 * (num.cells / 100))

    #  For each position in that ordered set, count up the total 
    #  number of "true positives" up to that position and then divide 
    #  it by the true rank of that position to get a running fraction 
    #  of "true positives" up to each position in zonation's correct  
    #  ordering of the landscape. 
running.num.cor = cumsum (ordered.z.app.le.z.cor)
##plot (running.num.cor)
    if (write.to.file)  pdf (paste (analysis.dir, "running.num.cor.pdf", sep=''))
plot (running.num.cor [percent.indices])    
    if (write.to.file)  dev.off()
    
##     SOMETHING IS NOT RIGHT HERE
##     BECAUSE WHEN I PLOT THE RESULTS, THEY SHOULD END UP WITH THE FRACTION 
##     EQUAL TO 1 WHEN YOU GET TO THE LAST CELL BECAUSE EVERY ONE OF THE 
##     VALUES WILL HAVE BEEN LESS THAN THAT LAST VALUE.
##     WHAT I'M ADDING UP IS THE NUMBER OF CELLS THAT ARE AT LEAST AS GOOD AS 
##     THEY'RE SUPPOSED TO BE.  THE THING THAT SHOULD GO TO 1 IS THE NUMBER OF 
##     CELLS BEFORE THIS ONE IN THE RANKING THAT HAVE A VALUE LESS THAN _IT_.  
##     THAT MEANS THAT IF THE CORRECT RANK OF SOMETHING WAS 15 AND ITS 
##     APPARENT RANK WAS 17, IT SHOULD STILL BE COUNTED AS GOOD AT ANY VALUE 
##     GREATER THAN OR EQUAL TO 17.  HOWEVER, THAT REQUIRES REDOING THE WHOLE 
##     CALCULATION FOR EVERY RANKING VALUE AND SAYING, HOW MANY PIXELS IN THE 
##     APPARENT RANKING _SHOULD_ BE LESS THAN ME AND _ARE_ LESS THAN ME, 
##     _REGARDLESS_ OF WHETHER THEY'RE LESS THAN WHAT THEY SHOULD HAVE BEEN 
##     FOR THAT PARTICULAR PIXEL.
    
running.frac.cor = cumsum (ordered.z.app.le.z.cor) / (1:num.cells)

    #  Plot those fractions so that we can choose any fraction of the 
    #  landscape we want to assume we will buy and see how well we would 
    #  do at that level in terms of getting things that really should 
    #  have been ranked at least that well.
##plot (running.frac.cor)    
    if (write.to.file)  pdf (paste (analysis.dir, "running.frac.cor.pdf", sep=''))
plot (running.frac.cor [percent.indices])    
    if (write.to.file)  dev.off()

normalized.cor.ranks.of.all.cells = rank (z.cor) / num.cells

    frac.true.pos = rep (-1, num.cells)
    cat ("\nAbout to generate frac.true.pos curve:\n")
    for (i in percent.indices)
        {
        cat (" ", i)
        cellsThatShouldRankLowerThanCurCell = which (z.cor <= z.cor [i])
        
        cur.num.true.pos = 
            sum (z.app [cellsThatShouldRankLowerThanCurCell] <= i)
        frac.true.pos [i] = cur.num.true.pos / i
        }
        if (write.to.file)  pdf (paste (analysis.dir, "frac.true.pos.pdf", sep=''))
    plot (frac.true.pos)
        if (write.to.file)  dev.off()


#===============================================================================

# From: nearest-neighbor.pdf slides
# 
# Distance-Weighting
# Rather than treating each neighbor equally, give more weight to closer neighbors. Predict with:
# - Classification: the class with the highest sum of weights.
# - Regression: the weighted average, e.g.,
#     y = [sum from i=1 to k (yi / d(x,xi))] / 
#         [sum from i=1 to k (1 / d(x,xi))]
# To avoid division by 0, add a small value to d.
# BTL: (e.g., maybe use min value of d (divided by 10 or 100 or ?)?)
#
# Issues of kNN 
# 
# Scaling
# Attributes can have widely different ranges, e.g., Aluminum and Refractive Index. Consider:
# • Normalization. Rescale attribute so that its minimum is 0 (or −1) and its maximum is 1.
# • Standardization. Rescale attribute so that its mean is 0 and its standard deviation is 1.
# 
# Attributes can be redundant, e.g., Petal Length and Petal Width. 
# Consider Mahalanobis dis- tance (Duda/Hart/Stork).
# 
# Other Distance Issues
# Attributes can be irrelevant. The textbook hints at sophisticated ways to address this issue, but consider multiplying an attribute times its cor- relation with the outcome (after scaling).
# Nominal attributes are either equal or different. Consider being different as a difference of 1, or convert to binary attributes.
# Attribute values can be missing. Consider using some fixed value for the difference.
# 
# For basic kNN, no training is needed, but might
# be desired for scaling or selecting training exs.
# An open problem is more efficient algorithms to find NN.
# Roughly, case-based and analogical learning are based on closeness of symbolic descriptions.
# What is the inductive bias of kNN? Does kNN have an overfitting problem? Will increasing k always improve performance?

#===============================================================================

library (knnflex)
num.rows = 256
num.cols = 256
num.entries = num.rows * num.cols

idx.to.xy.table = matrix (0, nrow=num.entries, ncol=2)

curIdx = 0
for (curRow in 1:num.rows)
  {
  for (curCol in 1:num.cols)
    {
    curIdx = curIdx + 1
    idx.to.xy.table [curIdx,1:2] = c(curRow,curCol)
    }
  }

dist.between.all.xy.locs = knn.dist (idx.to.xy.table)

#===============================================================================

    #  Some code to compute and plot the running true positive and false 
    #  positive scores for zonation results up to any given fraction of the 
    #  landscape.

num.rows = 3
num.cols = num.rows
num.cells = num.rows * num.cols

z.cor = matrix (sample (num.cells), nrow=num.rows, ncol=num.cols, byrow=TRUE)
##z.cor = zonation.cor.rank
cat ("\nz.cor = \n")
print (z.cor)

z.app = matrix (sample (num.cells), nrow=num.rows, ncol=num.cols, byrow=TRUE)
##z.app = zonation.app.rank
cat ("\nz.app = \n")
print (z.app)

cat ("\n\norder (z.cor) = \n")
print (order (z.cor))

cat ("\n\norder (z.app) = \n")
print (order (z.app))

    #  Determine which apparent values are less than or equal to their true 
    #  ranks, i.e., which apparent ones are really ones that we would want to 
    #  buy if we were spending up to that level in the correct ranking.  
    #  These are something like True Positives.  
z.app.le.z.cor = (z.app <= z.cor)

cat ("\n\nz.app.le.z.cor = \n")
print (z.app.le.z.cor)

    #  Order these values by their true zonation rank.
ordered.z.app.le.z.cor = z.app.le.z.cor [order(z.cor)]

percent.indices = round (1:100 * (num.cells / 100))

    
    #  Start with the apparent rankings and progress through them in 
    #  increasing order.
    #  For each position, compute the number of positions below it in the 
    #  apparent order have values at the corresponding location in the 
    #  CORRECT image whose values are less than or equal to the current 
    #  apparent ranking.  In other words, if we choose this cutoff point 
    #  in the apparent rankings, what fraction of the values in the correct 
    #  ranking really are less than or equal to this apparent value.  
    #  We care about this because if we choose this rank in the apparent 
    #  rankings, we are assuming that we are getting at that much of the 
    #  highest valued landscape.  For example, if we choose a 20% cutoff 
    #  in the apparent Zonation rankings, we are trying to get the best 
    #  20% of the landscape.  What we want to know is, how much of the 
    #  correct top 20% do we actually get?

    #  At position 1 in the apparent ranking, we know that the fraction 
    #  correct at that point is 1 if the correct ranking of position 1 is also  
    #  1 and 0 otherwise.
    #  At position 2, in the apparent ranking, we know that the fraction 
    #  correct at position 2 is whatever the result is for position 2 added 
    #  to the value for position 1 divided by the current position, i.e., 2.
    
    z.cor.ranks = rank (z.cor)
    z.app.ranks = rank (z.app)
    z.cor.cts = rep (0, num.cells)
    for (cur.idx in 1:num.cells)
        {
        cur.app.rank = z.app.ranks [cur.idx]
        cur.cor.rank = z.cor.ranks [cur.idx]
        z.cor.cts [cur.rank] = z.cor.cts [cur.rank] + 1
        }

    cum.z.cor.cts = cumsum (z.cor.cts)
    frac.true = cum.z.cor.cts / 1:num.cells

#---------------------------------------

num.cells = 500

z.cor = sample (num.cells)
#z.cor = c (3, 2, 5, 1, 4)
    cat ("\nz.cor = \n")
    print (z.cor)

z.app = sample (num.cells)
#z.app = c (2, 3, 1, 5, 4)
    cat ("\nz.app = \n")
    print (z.app)

#---------------------------------------

DEBUG = FALSE

rank.z.cor = rank (z.cor)
if (DEBUG) {
    cat ("\nrank.z.cor = \n")
    print (rank.z.cor)
    }

order.z.app = order (z.app)
if (DEBUG) {
    cat ("\norder.z.app = \n")
    print (order.z.app)
    }

z.app.ordered.z.cor.ranks = rank.z.cor [order.z.app]
if (DEBUG) {
cat ("\nz.app.ordered.z.cor.ranks = \n")
    print (z.app.ordered.z.cor.ranks)
    }

if (DEBUG) cat ("\n")
z.app.le.true.cts = rep (0, num.cells)
frac.true = rep (0, num.cells)
if (DEBUG) cat ("\n\n------------------------------------------")
for (i in 1:num.cells)
    {
if (DEBUG) {
cat ("\n\ni = ", i, " before incrementing:", 
                         "\n    z.app.ordered.z.cor.ranks [", i, "] = ", 
                         z.app.ordered.z.cor.ranks [i], 
                         "\n    z.app.le.true.cts [z.app.ordered.z.cor.ranks [", i, "] = ", 
                         z.app.le.true.cts [z.app.ordered.z.cor.ranks [i]], 
                         "\n    z.app.le.true.cts = ", 
                         z.app.le.true.cts        
                         )
                         }
    
    cur.cor.rank = z.app.ordered.z.cor.ranks [i]
if (DEBUG)     cat ("\n\ncur.cor.rank = ", cur.cor.rank)
    
    if (cur.cor.rank < i)
        {
        z.app.le.true.cts [i] = z.app.le.true.cts [i] + 1
        } else 
        {
        z.app.le.true.cts [z.app.ordered.z.cor.ranks [i]] = 
            z.app.le.true.cts [z.app.ordered.z.cor.ranks [i]] + 1        
        }
    
    if (i > 1)  
        {
        z.app.le.true.cts [i] = z.app.le.true.cts [i] + 
                                z.app.le.true.cts [i - 1]
        }
        
        
    frac.true [i] = z.app.le.true.cts [i] / i
        
if (DEBUG) {
cat ("\n\nafter incrementing:", 
                         "\n    z.app.le.true.cts = ", 
                         z.app.le.true.cts,         
                         "\n    frac.true = ", 
                         frac.true,   
                         "\n\n------------------------------------------"
                         )
                         }
    }

if (DEBUG) cat ("\n\n")

if (DEBUG) {
cat ("\n\nFinal cts and fractions:", 
                         "\n    z.app.le.true.cts = ", 
                         z.app.le.true.cts,         
                         "\n    frac.true = ", 
                         frac.true,   
                         "\n\n------------------------------------------"
                         )
                         }

percent.indices = round (1:100 * (num.cells / 100))

reduced.frac.true = frac.true [percent.indices]

plot (reduced.frac.true)

#---------------------------------------




        
    #  For each position in that ordered set, count up the total 
    #  number of "true positives" up to that position and then divide 
    #  it by the true rank of that position to get a running fraction 
    #  of "true positives" up to each position in zonation's correct  
    #  ordering of the landscape. 
running.num.cor = cumsum (ordered.z.app.le.z.cor)
plot (running.num.cor)    
plot (running.num.cor [percent.indices])    

running.frac.cor = cumsum (ordered.z.app.le.z.cor) / (1:num.cells)


    #  Plot those fractions so that we can choose any fraction of the 
    #  landscape we want to assume we will buy and see how well we would 
    #  do at that level in terms of getting things that really should 
    #  have been ranked at least that well.
plot (running.frac.cor)    
plot (running.frac.cor [percent.indices])    



    frac.true.pos = rep (-1, num.cells)
    for (i in 1:(round(num.cells * 0.2)))
        {

        cellsThatShouldRankLowerThanCurCell = which (z.cor <= i)
        
        cur.num.true.pos = 
            sum (z.app [cellsThatShouldRankLowerThanCurCell] <= i)
        frac.true.pos [i] = cur.num.true.pos / i
        }
    plot (frac.true.pos)

#===============================================================================

}  # end commenting out of rest of code for testing

