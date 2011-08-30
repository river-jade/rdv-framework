#==============================================================================

###	Usage:
###        source ('build.rarity.distribution.given.by.function.or.user.R');

#	Split out of build.rarity.and.clumpiness.distributions.R.
#	22/2/07 - BTL.

#	Merged from build.rarity.distribution.given.by.function.R and 
#	build.rarity.distribution.given.by.user.R.
#	Also moved the opening "if" statement in from 
#	build.rarity.distribution.R.
#	21/6/07 - BTL.

#       Replaced spp.OCC.hab.patch.cts with 
#       rarity.target.num.OCC.patches.for.spp.
#       BTL - 8/15/07.

#==============================================================================

	#  The user can do one of two things here.
  
	#  1) They can specify the rarity as a vector of fractions where 
	#     each value in that vector tells what fraction of the total 
	#     number of patches in the landscape that each species 
	#     occupies.  
	#     So, the output of this is a vector that is tot.num.spp long.  
	#  		OR
	#  2) They can specify a type of distribution to sample from to 
	#     build a histogram showing the proportion of the total number 
	#     of species on the landscape that occupy any given number of 
	#     patches from 1 to the total number of patches.  
	#     So, the output of this is a vector that is tot.num.patches 
	#     long, instead of tot.num.spp long.

	#  In either case, the code that is called here will take the 
	#  appropriate steps to use either the fractions or the sampled 
	#  distribution to assign each species a specific number of patches 
	#  to occupy.  

#------------------------------------------------------------------------------

	#  After the rarity distribution or array of fractions by species 
	#  is built, you will use them to assign actual patch counts to 
	#  species.  
	#  Create the zeroed version of this vector of patch counts 
	#  now since it will be used regardless of whether you're using 
	#  sampled distributions or arrays of fractions by species.

rarity.target.num.OCC.patches.for.spp <- rep (0, num.spp);

#------------------------------------------------------------------------------

if (OPT.spp.rarity.distribution.is.GIVEN.by.user)
  {
  source ('generate.spp.rarity.dist.given.by.user.R');

  graph.subtitle.arg <- 'Distribution given by user';

  }  else		
  
#------------------------------------------------------------------------------

  {	#  spp distribution is sampled from distribution, 
	#  rather than explicitly specified by the user.

	#  These 3 lines look vestigial.  Not sure what they're for...
	#  Should probably get rid of them.  Looks like they might be 
	#  defaults for a normal distribution or something?
	#  BTL - 21/6/07
			#  dist shift = .075
			#  sd scale = 0.25
			#  dist scale = 1.0

  source ('generate.spp.rarity.dist.from.function.R'); 
  	
  graph.subtitle.arg <- 'Taken from a distribution';

  }  # end else 

#------------------------------------------------------------------------------

        #  Make sure that every species is on at least one patch
        #  (otherwise, why have it in the model?).
  zero.locs <- which(rarity.target.num.OCC.patches.for.spp == 0);
  if (length(zero.locs) > 0)
    {
    rarity.target.num.OCC.patches.for.spp [zero.locs] <- 1;
    }

#------------------------------------------------------------------------------

    		#  Plot the actual rarities instead of the sampling 
		#  distribution.

rarity.target.num.spp.having.given.patch.ct <- rep (0, tot.num.patches);

for (i in 1: tot.num.patches)  # not num.spp
  {
  rarity.target.num.spp.having.given.patch.ct [i] <- 
#          	  length (spp.num.OCC.patches [spp.num.OCC.patches  == i]);
    length (rarity.target.num.OCC.patches.for.spp [
                          rarity.target.num.OCC.patches.for.spp  == i]);
  }

    		#--------------------

#    plot (rarity.target.num.spp.having.given.patch.ct/num.spp,
plot (rarity.target.num.spp.having.given.patch.ct, 
      xlim=c(1,tot.num.patches), 
#      ylim=c(0, 1.0), 
      xlab='Number of patches occupied',
      ylab='Number of spp on a given # of patches', 
      type='h'
      );
mtext( "Target Species Rarity Cts", padj = -1  );
y.txt.loc <- max(rarity.target.num.spp.having.given.patch.ct) / 1.35;
x.txt.loc <- tot.num.patches / 1.3;

text( x.txt.loc, y.txt.loc,
     paste ("rarity.target.num.spp.having.given.patch.ct",
            "\ncalled in \n",
            "\nbuild.rarity.dist...given.by.function.or.user"),
     cex=0.8 );
##		}

#==============================================================================

