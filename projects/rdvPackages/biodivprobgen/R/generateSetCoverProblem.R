#===============================================================================
#  v1 - 
#  v2 - 
#  v3 - add degree distribution calculations
#  v4 - cleaning up code layout formatting
#  v5 - replacing node_link_pairs with link_node_pairs to match marxan puvspr

#===============================================================================
                    #  START EMULATION CODE
#===============================================================================

    #  Need to set emulation flag every time you swap between emulating 
    #  and not emulating.  
    #  This is the only variable you should need to set for that.
    #  Make the change in the file called emulatingTzarFlag.R so that 
    #  every file that needs to know the value of this flag is using 
    #  the synchronized to the same value.

source ("emulatingTzarFlag.R")

#--------------------

    #  Need to set these variables just once, i.e., at start of a new project. 
    #  Would never need to change after that for that project unless 
    #  something strange like the path to the project or to tzar itself has 
    #  changed.  
    #  Note that the scratch file can go anywhere you want and it will be 
    #  erased after the run if it is successful and you have inserted the 
    #  call to the cleanup code at the end of your project's code.  
    #  However, if your code crashes during the emulation, you may have to 
    #  delete the file yourself.  I don't think it hurts anything if it's 
    #  left lying around though.

projectPath = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R"
tzarJarPath = "~/D/rdv-framework/tzar.jar"
tzarEmulation_scratchFileName = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/tzarEmulation_scratchFile.txt"

#-------------------------------------------------------------------------------

    #  This is the only code you need to run the emulator.
    #  However, if you want it to clean up the tzar directory name extensions 
    #  after it is finished, you also need to run the routine called 
    #  cleanUpAfterTzarEmulation() after your project code has finished 
    #  running, e.g., as the last act in this file. 

source ('emulateRunningUnderTzar.R')

if (emulateRunningUnderTzar)
    {
    cat ("\n\nIn generateSetCoverProblem:  emulating running under tzar...")

    parameters = emulateRunningTzar (projectPath, 
                                     tzarJarPath, 
                                     tzarEmulation_scratchFileName)
    }

#===============================================================================
                    #  END EMULATION CODE
#===============================================================================

#browser()

library (plyr)    #  For count()
library (marxan)

#-------------------------------------------------------------------------------

seed = 19
seed = parameters$seed
set.seed (seed)

#-------------------------------------------------------------------------------

integerize = function (x) 
    { 
    round (x) 
#    ceiling (x)
#    floor (x)
    }

#-------------------------------------------------------------------------------

add_link = function (node_link_pairs, next_node_link_pair_row, 
                     smaller_node_ID, larger_node_ID, 
                     next_link_ID)
    {
#     cat ("\n\t\t[", smaller_node_ID, ",", larger_node_ID, "]")
    
    node_link_pairs [next_node_link_pair_row, "node_ID"] = smaller_node_ID
    node_link_pairs [next_node_link_pair_row, "link_ID"] = next_link_ID
#              cat ("\n\t\t\tnode_link_pairs [", next_node_link_pair_row, ", ] = \n")
#              print (node_link_pairs [next_node_link_pair_row,])

    next_node_link_pair_row = next_node_link_pair_row + 1    
    node_link_pairs [next_node_link_pair_row, "node_ID"] = larger_node_ID
    node_link_pairs [next_node_link_pair_row, "link_ID"] = next_link_ID
#              cat ("\n\t\t\tnode_link_pairs [", next_node_link_pair_row, ", ] = \n")
#              print (node_link_pairs [next_node_link_pair_row,])
    next_node_link_pair_row = next_node_link_pair_row + 1

#     next_link_ID = next_link_ID + 1
#              cat ("\n\t\tnext_link_ID = ", next_link_ID)
    
    updated_links = list()
    updated_links$next_node_link_pair_row = next_node_link_pair_row
#     updated_links$next_link_ID = next_link_ID
    updated_links$node_link_pairs = node_link_pairs
    
    return (updated_links)
    }

#-------------------------------------------------------------------------------

    #  Run marxan.
        #  Should include this in the marxan package.

    #*******
    #  NOTE:  Random seed is set to -1 in the cplan input.dat.
    #           I think that means to use a different seed each time.
    #           I probably need to change this to any positive number, 
    #           at least in the default input.dat that I'm using now 
    #           so that I get reproducible results.
    #*******

run_marxan = function ()
    {
    marxan_dir = "/Users/bill/D/Marxan/"
    
    original_dir = getwd()
    cat ("\n\noriginal_dir =", original_dir)
    
    cat ("\n\nImmediately before calling marxan, marxan_dir = ", marxan_dir)
    setwd (marxan_dir)
    
    cat("\n =====> The current wd is", getwd() )
    
        #  The -s deals with the problem of Marxan waiting for you to hit 
        #  return at the end of the run when you're running in the background.  
        #  Without it, the system() command never comes back.
        #       (From p. 24 of marxan.net tutorial:
        #        http://marxan.net/tutorial/Marxan_net_user_guide_rev2.1.pdf
        #        I'm not sure if it's even in the normal user's manual or 
        #        best practices manual for marxan.)
    
    system.command.run.marxan = "./MarOpt_v243_Mac64 -s"    
    cat( "\n\n>>>>>  The system command to run marxan will be:\n'", 
         system.command.run.marxan, "'\n>>>>>\n\n", sep='')
    
    retval = system (system.command.run.marxan)    #  , wait=FALSE)
    cat ("\n\nmarxan retval = '", retval, "'.\n\n", sep='')        
    
    setwd (original_dir)
    cat ("\n\nAfter setwd (original_dir), sitting in:", getwd(), "\n\n")
    
    return (retval)
    }

#===============================================================================

# derive_control_parameters = 
#     function (n__num_cliques = 3, 
#               alpha__ = 1, 
#               p__prop_of_links_between_cliques = 0.5,     	#  p__prop_of_links_between_cliques   
#                                                             #  not the right name?
#                                                             #  is it really the proportion of nodes in one clique 
#                                                             #  to link to another clique during one round?
#                                                             #  p__prop_of_nodes_in_clique_to_try_to_interlink_in_one_round?
#                                                             #  p__prop_to_link_between_two_cliques_in_one_round?
#                                                             #  p__prop    
#               r__density = 0.5
#              )
#     {

n__num_cliques                   = parameters$n__num_cliques
alpha__                          = parameters$alpha__
p__prop_of_links_between_cliques = parameters$p__prop_of_links_between_cliques
r__density                       = parameters$r__density

# n__num_cliques                   = 5
# alpha__                          = 0.8
# p__prop_of_links_between_cliques = 0.5  
# r__density                       = 0.5

# n__num_cliques                   = 12
# alpha__                          = 1.5
# p__prop_of_links_between_cliques = 0.3  
# r__density                       = 0.8

# for (n__num_cliques in 3:7)
# {
# for (cur_repeat in 1:5)
# {
        
#-------------------------------------------------------------------------------

    #  Derived control parameters.

    cat ("\n\n--------------------  Building derived control parameters.\n")
    
    num_nodes_per_clique = integerize (n__num_cliques ^ alpha__)
    tot_num_nodes = n__num_cliques * num_nodes_per_clique

    num_independent_set_nodes = n__num_cliques
    num_dependent_set_nodes = tot_num_nodes - num_independent_set_nodes
    opt_solution_as_frac_of_tot_num_nodes = 
        num_dependent_set_nodes / tot_num_nodes
    
    num_rounds_of_linking_between_cliques = integerize (r__density * n__num_cliques * log (n__num_cliques))
    
    target_num_links_between_2_cliques_per_round = 
        integerize (p__prop_of_links_between_cliques * num_nodes_per_clique)
    
    num_links_within_one_clique = choose (num_nodes_per_clique, 2)
    tot_num_links_inside_cliques = n__num_cliques * num_links_within_one_clique
    
    max_possible_num_links_between_cliques = 
        integerize (target_num_links_between_2_cliques_per_round * num_rounds_of_linking_between_cliques)
    
    max_possible_tot_num_links = integerize (tot_num_links_inside_cliques + max_possible_num_links_between_cliques)

    cat ("\n\nInput variable settings")
    cat ("\n\t\t n__num_cliques = ", n__num_cliques)
    cat ("\n\t\t alpha__ = ", alpha__)
    cat ("\n\t\t p__prop_of_links_between_cliques = ", p__prop_of_links_between_cliques)
    cat ("\n\t\t r__density = ", r__density)
    
    cat ("\n\nDerived variable settings")
    cat ("\n\t\t num_nodes_per_clique = ", num_nodes_per_clique)
    cat ("\n\t\t num_rounds_of_linking_between_cliques = ", num_rounds_of_linking_between_cliques)
    cat ("\n\t\t target_num_links_between_2_cliques_per_round = ", target_num_links_between_2_cliques_per_round)
    cat ("\n\t\t num_links_within_one_clique = ", num_links_within_one_clique)
    cat ("\n\t\t tot_num_links_inside_cliques = ", tot_num_links_inside_cliques)
    cat ("\n\t\t max_possible_num_links_between_cliques = ", max_possible_num_links_between_cliques)
    cat ("\n\t\t max_possible_tot_num_links = ", max_possible_tot_num_links)
    cat ("\n\n")

#-------------------------------------------------------------------------------

        #--------------------------------------------------
        #  Create structures to hold the nodes and links.
        #--------------------------------------------------    

    cat ("\n\n--------------------  Creating structures to hold the nodes and links.\n")

    node_IDs = 1:tot_num_nodes
    
            #  For each node ID, what clique does it belong to?
    clique_IDs = 1 + (0:(tot_num_nodes - 1) %/% num_nodes_per_clique)

            #  Assign lowest node ID in each clique to be the independent node 
            #  in that clique.
    independent_node_IDs = seq (from=1, 
                                by=num_nodes_per_clique, 
                                length.out=n__num_cliques)

            #  For each node ID, flag whether it is in the dependent set or not.
    dependent_set_members = rep (TRUE, tot_num_nodes)
    dependent_set_members [independent_node_IDs] = FALSE
    
            #  Collect the IDs of just the dependent nodes.
    dependent_node_IDs = node_IDs [-independent_node_IDs]
    
            #  Build an overall data frame that shows for each node, 
            #  its node ID and clique ID, plus a flag indicating whether 
            #  it's in the dependent set or not.  For example, if there 
            #  are 3 nodes per clique:
            #
            #       node_ID     clique_ID       dependent_set_member
            #         1            1                 TRUE
            #         2            1                 TRUE
            #         3            1                 FALSE
            #         4            2                 TRUE
            #         5            2                 TRUE
            #         6            2                 FALSE
            #        ...          ...                 ...


#    nodes = cbind (node_IDs, clique_IDs, dependent_set_member)
    nodes = data.frame (node_ID = node_IDs,
                        clique_ID = clique_IDs, 
                        dependent_set_member = dependent_set_members)

#     cat ("\n\nnodes and their clique IDs:")
#     for (cur_node_ID in 1:tot_num_nodes)
#         {
#         cat ("\n\t", cur_node_ID, "\t", clique_IDs [cur_node_ID])    
#         }
#     cat ("\n")

    cat ("\n\t\t independent_node_IDs = ", independent_node_IDs)
    cat ("\n\t\t dependent_node_IDs = ", dependent_node_IDs)
    
    cat ("\n\nnodes = \n")
    print (nodes)
    cat ("\n\n")
    
#    nodes_df = as.data.frame (nodes)
    
    linked_node_pairs = matrix (NA, 
                                nrow = max_possible_tot_num_links, 
                                ncol = 2, 
                                byrow = TRUE)

            #  Build a data frame with all the links for all of the nodes.  
            #  For each node, there is a separate line for each link associated 
            #  with that node.  So, for example, if there are two nodes, 3 and 5, 
            #  and node 3 has 2 links, 18 and 93, and node 5 has 3 links, 11,15, and 21, 
            #  then there should be 5 lines in the table:
            #
            #      node_ID    link_ID
            #       3            18
            #       3            93
            #       5            11
            #       5            15
            #       5            21

    max_possible_tot_num_node_link_pairs = 2 * max_possible_tot_num_links
#     node_link_pairs = matrix (NA, 
#                               nrow=max_possible_tot_num_node_link_pairs, 
#                               ncol=2, 
#                               byrow=TRUE
#                               )
#     node_link_pairs = as.data.frame (node_link_pairs)
#     names (node_link_pairs) = c("node_ID", "link_ID")

    next_node_link_row = 1    #  NEVER USED?  DELETE THIS?
    next_link_ID = 1
    cur_clique_ID = 1
    
        #  Link all nodes within each clique.
    all_clique_IDs = 1:n__num_cliques

    cat ("\n\nCliques")
    
#df[df$value>3.0,] 

#===============================================================================

cat ("\n\n--------------------  Linking all nodes within each clique.\n")

if (num_nodes_per_clique < 2)
    quit ("\n\n***  num_nodes_per_clique (", num_nodes_per_clique, 
          ") must be at least 2.\n\n")


num_nodes_per_clique_minus_1 = num_nodes_per_clique - 1
cur_row = 1

for (cur_clique_ID in 1:n__num_cliques)
    {
    #  NOTE:  The code in this loop assumes the clique nodes are sorted.  
    #         These clique nodes are probably already sorted, 
    #         but this just makes sure, as a safeguard against 
    #         some future change.
    cur_clique_nodes_sorted = 
        sort (nodes [nodes$clique_ID == cur_clique_ID, "node_ID"])
    cat ("\n\ncur_clique_nodes_sorted for clique ", cur_clique_ID, " = ")
    print (cur_clique_nodes_sorted)
    
    #  Link each node in the clique to all nodes with a higher node ID in 
    #  the same clique.  
    #  Doing it this way insures that all nodes in the clique are linked to 
    #  all other nodes in the clique but that the linking action is only done 
    #  once for each pair.
    
    for (cur_idx in 1:num_nodes_per_clique_minus_1)
        {
        for (other_node_idx in (cur_idx+1):num_nodes_per_clique)
            {
            linked_node_pairs [cur_row, 1] = cur_clique_nodes_sorted [cur_idx]
            linked_node_pairs [cur_row, 2] = cur_clique_nodes_sorted [other_node_idx]
            cur_row = cur_row + 1
            }
        }
    }

cat ("\n\nlinked_node_pairs (with last lines NA to hold interclique links to be loaded in next step):\n\n")
print (linked_node_pairs)
cat ("\n\n")

#===============================================================================

    #  Now all cliques and their within clique links have been built.  
    #  Ready to start doing rounds of interclique linking.

cat ("\n\n--------------------  Doing rounds of interclique linking.\n")

for (cur_round in 1:num_rounds_of_linking_between_cliques)
    {
    cat ("\nRound", cur_round)
    
    #  Draw a random pair of cliques to link in this round.
    cur_clique_pair = sample (1:n__num_cliques, 2, replace=FALSE)
    
    #  I'm using min and max here because smaller clique IDs were 
    #  filled with smaller node IDs, so every node ID in the 
    #  smaller clique ID should be the smaller node ID of any pairing 
    #  of nodes between the cliques and the linking routine 
    #  expcts the smaller node ID to come before the larger one 
    #  in the linking argument list.  This may be a vestigial thing 
    #  from earlier schemes that doesn't matter any more, but 
    #  it's easy to maintain here for the moment, just in case it 
    #  does still matter in some way.  In any case, it doesn't 
    #  hurt anything to do this now other than the little bit of 
    #  extra execution time to compute the min and max.
    
    clique_1 = min (cur_clique_pair)
    clique_1_nodes = nodes [(nodes$clique_ID == clique_1) & (nodes$dependent_set_member), 
                            "node_ID"]
    
    clique_2 = max (cur_clique_pair)
    clique_2_nodes = nodes [(nodes$clique_ID == clique_2) & (nodes$dependent_set_member), 
                            "node_ID"]
    
    #***-----------------------------------------------------------------------------------
    
    clique_1_sampled_nodes = 
        sample (clique_1_nodes, target_num_links_between_2_cliques_per_round, 
                replace=TRUE)
    clique_2_sampled_nodes = 
        sample (clique_2_nodes, target_num_links_between_2_cliques_per_round, 
                replace=TRUE)
    
    for (cur_node_pair_idx in 1:target_num_links_between_2_cliques_per_round)
        {                
        linked_node_pairs [cur_row, 1] = clique_1_sampled_nodes [cur_node_pair_idx]
        linked_node_pairs [cur_row, 2] = clique_2_sampled_nodes [cur_node_pair_idx]
        cur_row = cur_row + 1
        }
    }

#===============================================================================

    #  All node pairs should be loaded into the linked_node_pairs table now 
    #  and there should be no NA lines left in the table.
    
    #  However no duplicate links are allowed, so need to go through all 
    #  node pairs and remove non-unique ones.

unique_linked_node_pairs = unique (linked_node_pairs)

num_non_unique_linked_node_pairs = dim (linked_node_pairs)[1]
num_unique_linked_node_pairs = dim (unique_linked_node_pairs)[1]

cat ("\n\nnum_non_unique_linked_node_pairs =", num_non_unique_linked_node_pairs)
cat ("\nnum_unique_linked_node_pairs =", num_unique_linked_node_pairs)
cat ("\n")

#===============================================================================

num_node_link_pairs = 2 * num_unique_linked_node_pairs
node_link_pairs = matrix (NA, 
                          nrow=num_node_link_pairs, 
                          ncol=2, 
                          byrow=TRUE
                          )

node_link_pairs = as.data.frame (node_link_pairs)
names (node_link_pairs) = c("node_ID", "link_ID")

next_node_link_pair_row = 1

for (cur_link_ID in 1:num_unique_linked_node_pairs)
    {
    updated_links = 
        add_link (node_link_pairs, 
                  next_node_link_pair_row, 
                  unique_linked_node_pairs [cur_link_ID, 1], 
                  unique_linked_node_pairs [cur_link_ID, 2], 
                  cur_link_ID)
    
    node_link_pairs = updated_links$node_link_pairs
    
    next_node_link_pair_row = updated_links$next_node_link_pair_row
    }

#===============================================================================

cat ("\n\n--------------------  Computing and plotting degree distribution of node graph.\n")

#  Compute and plot the degree distribution of the node graph.
#  It may be that we can use metrics over this graph as features of the 
#  problem that give information about its difficulty.
#  For example, people are always going off about power laws in the 
#  degree distribution.  Would something like that explain anything?

#  What about other measures like various forms of centrality?

#  Also, need to plot the graph using eric's software (or something similar) 
#  to see if the visual layout gives any information.

#  After plotting, I realized that this degree distribution has the same 
#  shape as a rank abundance curve, however, it's the opposite of a rank 
#  abundance curve in that it's saying how many spp per patch, not how 
#  many patches per spp.  I need to plot that now to see how it compares 
#  to a typical rank abundance curve.  However, because of the way that 
#  this problem generator currently works, the distribution will be 
#  perfectly flat, i.e. 2 patches for every species, one for each end of 
#  the link.  I need to start adding copies of the link IDs to other 
#  patches after this generator finishes and see if you're still able to 
#  have a deceptive problem even without the flat rank abundance 
#  distribution?  In fact, can you add link IDs/species to non-independent 
#  patches that still preserves the correct solution but purposely drives 
#  the optimizer toward a wrong solution by knowing what kinds of things 
#  it values?  Could you use annealing (or even Marxan itself) to search 
#  for better "plate stackings" that lie over the hidden solution and 
#  the optimizer finds some feature that lets it drive toward finding 
#  difficult problems?  (Need good change operators too though.  However, 
#  Marxan's own change operator is mindlessly simple and might work for 
#  this as well if you do enough iterations the way Marxan does.)

#  What about cooccurrence matrices for the species?  Is there any measure 
#  or visual display over those (e.g., something about their degree 
#  distribution) that can be used as a predictive feature?

# cat ("\n\nNumber of links per node BEFORE interclique linking:\n")
# print (initial_link_counts_for_each_node)

final_link_counts_for_each_node = count (node_link_pairs, vars="node_ID")

cat ("\n\nNumber of links per node AFTER interclique linking:\n")
print (final_link_counts_for_each_node)

final_degree_dist = arrange (final_link_counts_for_each_node, -freq)
final_degree_dist[,"node_ID"] = 1:dim(final_degree_dist)[1]
plot (final_degree_dist)

#-------------------------------------------------------------------------------

# cat ("\n\nNumber of nodes per link BEFORE interclique linking:\n")
# print (initial_node_counts_for_each_link)

final_node_counts_for_each_link = count (node_link_pairs, vars="link_ID")

cat ("\n\nNumber of nodes per link AFTER interclique linking:\n")
print (final_node_counts_for_each_link)

final_rank_abundance_dist = arrange (final_node_counts_for_each_link, -freq)
final_rank_abundance_dist[,"link_ID"] = 1:dim(final_rank_abundance_dist)[1]
plot (final_rank_abundance_dist)

#===============================================================================

    #  Write out the data as Marxan input files.

#-------------------------------------------------------------------------------

cat ("\n\n--------------------  Writing out the data as Marxan input files.\n")

library (marxan)

sppAmount = 1

num_node_link_pairs = length (node_link_pairs [,"node_ID"])

PU_IDs = unique (node_link_pairs [,"node_ID"])
num_PUs = length (PU_IDs)

spp_IDs = unique (node_link_pairs [,"link_ID"])
num_spp = length (spp_IDs)

spp_PU_amount_table =
    data.frame (species = node_link_pairs [,"link_ID"],
                pu      = node_link_pairs [,"node_ID"],
                amount  = rep (sppAmount, num_node_link_pairs))

    #----------------------------------------------------------------------
    #  Sort the table in ascending order by species within planning unit.
    #  Taken from Wickham comment in:
    #  http://stackoverflow.com/questions/1296646/how-to-sort-a-dataframe-by-columns-in-r
    #
    #  BTL - 2014 11 28
    #
    #  Note that Marxan doesn't work correctly if the table is not sorted 
    #  by planning unit ID (e.g., it can't find satisfying solutions).  
    #  Ascelin said that the Marxan manual shows a picture of the values 
    #  sorted incorrectly, i.e., by species.
    #
    #  I should probably move this arrange() call into the code that 
    #  writes the table as a Marxan input file.  That would make sure 
    #  that no one can write the table out incorrectly if they use that 
    #  call.
    #----------------------------------------------------------------------

spp_PU_amount_table = arrange (spp_PU_amount_table, pu, species)

#-------------------------------------------------------------------------------

#  Choosing spf values
#  Taken from pp. 38-39 of Marxan_User_Manual_2008.pdf.
#  Particularly note the second paragraph, titled "Getting Started".

# 3.2.2.4 Conservation Feature Penalty Factor

# Variable – ‘spf’ Required: Yes
# Description: The letters ‘spf’ stands for Species Penalty Factor. This
# variable is more correctly referred to as the Conservation Feature
# Penalty Factor. The penalty factor is a multiplier that determines the
# size of the penalty that will be added to the objective function if the
# target for a conservation feature is not met in the current reserve
# scenario (see Appendix B -1.4 for details of how this penalty is
# calculated and applied). The higher the value, the greater the relative
# penalty, and the more emphasis Marxan will place on ensuring that
# feature’s target is met. The SPF thus serves as a way of distinguishing
# the relative importance of different conservation features. Features of
# high conservation value, for example highly threatened features or those
# of significant social or economic importance, should have higher SPF
# values than less important features. This signifies that you are less
# willing to compromise their representation in the reserve system.
# Choosing a suitable value for this variable is essential to achieving
# good solutions in Marxan. If it is too low, the representation of
# conservation features may fall short of the targets. If it is too high,
# Marxan’s ability to find good solutions will be impaired (i.e. it will
# sacrifice other system properties such as lower cost and greater
# compactness in an effort to fully meet the conservation feature targets).

# Getting Started: It will often require some experimentation to determine
# appropriate SPFs. This should be done in an iterative fashion. A good
# place to start is to choose the lowest value that is of the same order
# of magnitude as the number of conservation features, e.g. if you have 30
# features, start with test SPFs of, say, 10 for all features. Do a number
# of repeat of runs (perhaps 10) and see if your targets are being met in
# the solutions. If not all targets are being met try increasing the SPF
# by a factor of two and doing the repeat runs again. When you get to a
# point where all targets are being met, decrease the SPFs slightly and
# see if they are still being met. 

# After test runs are sorted out, then
# differing relative values can be applied, based on considerations such
# as rarity, ecological significance, etc., as outlined above.
# Even if all your targets are being met, always try lower values . By
# trying to achieve the lowest SPF that produces satisfactory solutions,
# Marxan has the greatest flexibility to find good solutions. In general,
# unless you have some a priori reason to weight the inclusion of features
# in your reserve system, you should start all features with the same SPF.
# If however, the targets for one or two features are consistently being
# missed even when all other features are adequately represented , it may
# be appropriate to raise the SPF for these features. Once again, see the
# MGPH for more detail on setting SPFs.

#spf_const = 10 ^ (floor (log10 (num_spp)))
spf_const = parameters$marxan_spf_const

#-------------------------------------------------------------------------------

    #***  Need to modify the write_all...() function to prepend the 
    #***  name of the directory to put the results in (but can  
    #***  default to writing in "." instead?).

marxan_input_dir = "/Users/bill/D/Marxan/input/"
write_all_marxan_input_files (PU_IDs, spp_IDs, spp_PU_amount_table, 
                              spf_const)
#                               spf_const = spf_const)
# write_all_marxan_input_files (PU_IDs, spp_IDs, spp_PU_amount_table, 
#                                          spf_const = 1, 
#                                          target_const = 1, 
#                                          cost_const = 1, 
#                                          status_const = 0)

system ("rm /Users/bill/D/Marxan/output/*")

system ("rm /Users/bill/D/Marxan/input/pu.dat")
system ("cp ./pu.dat /Users/bill/D/Marxan/input")

system ("rm /Users/bill/D/Marxan/input/spec.dat")
system ("cp ./spec.dat /Users/bill/D/Marxan/input")

system ("rm /Users/bill/D/Marxan/input/puvspr.dat")
system ("cp ./puvspr.dat /Users/bill/D/Marxan/input")


#===============================================================================
    
    #  TODO:

    #  NOTE:  Many of the entries below have to do with reading marxan output 
    #         and loading it into this program and doing something with it.
    #         I should build functions for doing those things and add them to 
    #         the marxan package.  Should talk to Ascelin about this too and 
    #         see if there is any overlap with what he's doing.

#===============================================================================
    
    #  Build structures holding:
        #  Make a function to automatically do these subtotalling actions 
        #  since I need to do it all the time.
            #  May want one version for doing these give a table or dataframe 
            #  and another for doing them given a list or list of lists 
            #  since those are the most common things I do (e.g, in 
            #  distSppOverPatches()).
        #  Species richness for each patch.
        #  Number of patches for each spp.
        #  Correct solution.
        #  Things in dist spp over patches?
            #  Patch list for each species.
            #  Species list for each patch.
    #  Are some of these already built for the plotting code above?

    #  *** Maybe this should be done using sqlite instead of lists of lists and 
    #  tables and data frames?


    #  http://stackoverflow.com/questions/1660124/how-to-group-columns-by-sum-in-r
    #  Is this counting up the number of species on each patch?
# x2  <-  by (spp_PU_amount_table$amount, spp_PU_amount_table$pu, sum)
# do.call(rbind,as.list(x2))
# 
# cat ("\n\nx2 =\n")
# print (x2)

#===============================================================================

    #  Aside:  The mention of distSppOverPatches() above reminds me that I 
    #           found something the other day saying that copulas were 
    #           a way to generate distributions with specified marginal 
    #           distributions.  I think that I saved a screen grab and 
    #           named the image using copula in the title somehow...

#===============================================================================

    #  General Parameters
marxan_BLM = 1
marxan_PROP  = 0.5
marxan_RANDSEED  = seed
marxan_NUMREPS  = parameters$marxan_num_reps

    #  Annealing Parameters
marxan_NUMITNS  = parameters$marxan_num_iterations
marxan_STARTTEMP  = -1
marxan_NUMTEMP  = 10000

    #  Cost Threshold
marxan_COSTTHRESH   = "0.00000000000000E+0000"
marxan_THRESHPEN1   = "1.40000000000000E+0001"
marxan_THRESHPEN2   = "1.00000000000000E+0000"

    #  Input Files
marxan_INPUTDIR  = "input"
marxan_PUNAME  = "pu.dat"
marxan_SPECNAME  = "spec.dat"
marxan_PUVSPRNAME  = "puvspr.dat"

    #  Save Files
marxan_SCENNAME  = "output"
marxan_SAVERUN  = 3
marxan_SAVEBEST  = 3
marxan_SAVESUMMARY  = 3
marxan_SAVESCEN  = 3
marxan_SAVETARGMET  = 3
marxan_SAVESUMSOLN  = 3
marxan_SAVEPENALTY  = 3
marxan_SAVELOG  = 2
marxan_OUTPUTDIR  = "output"

    #  Program control
marxan_RUNMODE  = 1
marxan_MISSLEVEL  = 1
marxan_ITIMPTYPE  = 0
marxan_HEURTYPE  = -1
marxan_CLUMPTYPE  = 0
marxan_VERBOSITY  = 3

marxan_SAVESOLUTIONSMATRIX  = 3

#-------------------

marxan_input_parameters_file_name = "/Users/bill/D/Marxan/input.dat"
#marxan_input_parameters_file_name = parameters$marxan_input_parameters_file_name

rm_cmd = paste ("rm", marxan_input_parameters_file_name)
system (rm_cmd)

#marxan_input_file_conn = file (marxan_input_parameters_file_name)
marxan_input_file_conn = marxan_input_parameters_file_name
    
cat ("Marxan input file", file=marxan_input_file_conn, append=TRUE)

cat ("\n\nGeneral Parameters", file=marxan_input_file_conn, append=TRUE)

cat ("\nBLM", marxan_BLM, file=marxan_input_file_conn, append=TRUE)
cat ("\nPROP", marxan_PROP, file=marxan_input_file_conn, append=TRUE)
cat ("\nRANDSEED", marxan_RANDSEED, file=marxan_input_file_conn, append=TRUE)
cat ("\nNUMREPS", marxan_NUMREPS, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nAnnealing Parameters", file=marxan_input_file_conn, append=TRUE)
cat ("\nNUMITNS", marxan_NUMITNS, file=marxan_input_file_conn, append=TRUE)
cat ("\nSTARTTEMP", marxan_STARTTEMP, file=marxan_input_file_conn, append=TRUE)
cat ("\nNUMTEMP", marxan_NUMTEMP, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nCost Threshold", file=marxan_input_file_conn, append=TRUE)
cat ("\nCOSTTHRESH", marxan_COSTTHRESH, file=marxan_input_file_conn, append=TRUE)
cat ("\nTHRESHPEN1", marxan_THRESHPEN1, file=marxan_input_file_conn, append=TRUE)
cat ("\nTHRESHPEN2", marxan_THRESHPEN2, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nInput Files", file=marxan_input_file_conn, append=TRUE)
cat ("\nINPUTDIR", marxan_INPUTDIR, file=marxan_input_file_conn, append=TRUE)
cat ("\nPUNAME", marxan_PUNAME, file=marxan_input_file_conn, append=TRUE)
cat ("\nSPECNAME", marxan_SPECNAME, file=marxan_input_file_conn, append=TRUE)
cat ("\nPUVSPRNAME", marxan_PUVSPRNAME, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nSave Files", file=marxan_input_file_conn, append=TRUE)
cat ("\nSCENNAME", marxan_SCENNAME, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVERUN", marxan_SAVERUN, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVEBEST", marxan_SAVEBEST, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVESUMMARY", marxan_SAVESUMMARY, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVESCEN", marxan_SAVESCEN, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVETARGMET", marxan_SAVETARGMET, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVESUMSOLN", marxan_SAVESUMSOLN, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVEPENALTY", marxan_SAVEPENALTY, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVELOG", marxan_SAVELOG, file=marxan_input_file_conn, append=TRUE)
cat ("\nOUTPUTDIR", marxan_OUTPUTDIR, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nProgram control.", file=marxan_input_file_conn, append=TRUE)
cat ("\nRUNMODE", marxan_RUNMODE, file=marxan_input_file_conn, append=TRUE)
cat ("\nMISSLEVEL", marxan_MISSLEVEL, file=marxan_input_file_conn, append=TRUE)
cat ("\nITIMPTYPE", marxan_ITIMPTYPE, file=marxan_input_file_conn, append=TRUE)
cat ("\nHEURTYPE", marxan_HEURTYPE, file=marxan_input_file_conn, append=TRUE)
cat ("\nCLUMPTYPE", marxan_CLUMPTYPE, file=marxan_input_file_conn, append=TRUE)
cat ("\nVERBOSITY", marxan_VERBOSITY, file=marxan_input_file_conn, append=TRUE)

cat ("\nSAVESOLUTIONSMATRIX", marxan_SAVESOLUTIONSMATRIX, file=marxan_input_file_conn, append=TRUE)

#close (marxan_input_file_conn)

#===============================================================================

run_marxan()

#===============================================================================

    #  Read various marxan outputs into this program.
        #  Should include these in the marxan package.
        #  Marxan's best solution.
        #  Marxan's votes for including each planning unit.
    
        #  Marxan output files to read from the Marxan output directory 
        #  (need to look these file names up in the manual):

            #  output_best.csv
            #  output_mvbest.csv

            #  output_ssoln.csv
            #  output_solutionsmatrix.csv
            #  output_sum.csv

            #  output_penalty_planning_units.csv
            #  output_penalty.csv

            #  output_sen.dat

marxan_output_dir_path = "/Users/bill/D/Marxan/output/"

marxan_output_best_file_name = "output_best.csv"
marxan_output_ssoln_file_name = "output_ssoln.csv"
marxan_output_mvbest_file_name = "output_mvbest.csv"


    #  Make sure both are sorted in increasing order of planning unit ID.
    #  "arrange()" syntax taken from Wickham comment in:
    #  http://stackoverflow.com/questions/1296646/how-to-sort-a-dataframe-by-columns-in-r

library (plyr)      #  for arrange()

#---------------------------------

marxan_best_df = 
    read.csv (paste (marxan_output_dir_path, marxan_output_best_file_name, sep=''), 
              header=TRUE)
cat ("\n\nAfter loading output_best.csv, marxan_best_df =")
print (marxan_best_df)

marxan_best_df = arrange (marxan_best_df, PUID)

cat ("\n\nAfter sorting, marxan_best_df = \n")
print (marxan_best_df)
cat ("\n\n-------------------")

#---------------------------------

marxan_mvbest_df = 
    read.csv (paste (marxan_output_dir_path, marxan_output_mvbest_file_name, sep=''), 
              header=TRUE)
cat ("\n\nAfter loading output_mvbest.csv, marxan_mvbest_df =")
print (marxan_mvbest_df)

    #  The call to "arrange()" below gives a weird error when run on the 
    #  data frame because the column names have spaces in them (e.g., 
    #  "Conservation Feature").  Renaming them seems to fix the problem
names (marxan_mvbest_df) = 
    c ("ConservationFeature", 
       "FeatureName",
       "Target",
       "AmountHeld",
       "OccurrenceTarget",
       "OccurrencesHeld",
       "SeparationTarget",
       "SeparationAchieved",
       "TargetMet",
       "MPM"  
       )

marxan_mvbest_df = arrange (marxan_mvbest_df, ConservationFeature)

cat ("\n\nAfter sorting, marxan_mvbest_df = \n")
print (marxan_mvbest_df)
cat ("\n\n-------------------")

#---------------------------------

marxan_ssoln_df = 
    read.csv (paste (marxan_output_dir_path, marxan_output_ssoln_file_name, sep=''),
              header=TRUE)
cat ("\n\nAfter loading output_ssoln.csv, marxan_ssoln_df =")
print (marxan_ssoln_df)

marxan_ssoln_df = arrange (marxan_ssoln_df, planning_unit)

cat ("\n\nAfter sorting, marxan_ssoln_df = \n")
print (marxan_ssoln_df)
cat ("\n\n-------------------")

#===============================================================================

#  Build a master table containing:
    #  planning unit ID
            #  marxan_best_df$PUID
    #  correct (optimal) answer (as boolean flags on sorted planning units)
    #  best marxan guess
            #  marxan_best_df$SOLUTION
    #  marxan number of votes for each puid
            #  marxan_ssoln_df$number
    #  difference between correct and best (i.e., (cor - best), FP, FN, etc)
    #  absolute value of difference (to make counting them easier)
    #  number of species on each patch (i.e., simple richness)

#  Need to bind together:
#   problem setup
#       - planning unit IDs (goes with all of these, even if they're split 
#         into separate tables)
#       - number of species (simple richness) on patch as counts
#   correct/optimal solution
#       - correct/optimal solution as 0/1
#   marxan solution(s)
#       - marxan best solution as 0/1
#       - marxan solution votes as counts
#   performance measure(s)
#       - difference between marxan best and optimal solution to represent 
#         error direction (e.g., FP, FN, etc.)
#       - abs (difference) to represent error or no error

    #  *** Need to be sure that the puid column matches in the nodes data frame 
    #  and the marxan data frames.  Otherwise, there could be a mismatch in 
    #  the assignments for inclusion or exclusion of patches in the solutions.

    #  Create table holding all the information to compare solutions.
signed_difference = marxan_best_df$SOLUTION - nodes$dependent_set_member
abs_val_signed_difference = abs (signed_difference)

solutions_df = data.frame (puid = marxan_best_df$PUID,
                           optimal_solution = nodes$dependent_set_member, 
                           marxan_best_solution = marxan_best_df$SOLUTION, 
                           marxan_votes = marxan_ssoln_df$number, 
                           signed_diff = signed_difference, 
                           abs_val_diff = abs_val_signed_difference, 
                           num_spp_on_patch = final_link_counts_for_each_node$freq
                           )

#  STILL NEED TO DO THIS
#       However, might be able to read these values from the marxan summary 
#       file that talks about missing values.  I'm just not sure how to 
#       tell which line in there corresponds to the "best" solution.
#
#       - marxan best solution % of species covered
#               - sum of number of uniques species in marxan best solution set
#                       - unique (select (species) where (puid in best solution))
#               - This suggests that there should be a function that computes 
#                 these values for ANY given solution.
#                         percentSppCovered = function (solutionAs01, sppPuidDB)
#                             {
#                             unique (select (species) where puids[which (solutionAs01==TRUE)])   
#                             }
#       - representation shortfall:  marxan best solution err fraction
#               - (1 - marxan best solution % of species covered)



#  Aggregate measures not in binding (may be computed From the bound data)

    #  correct/optimal number of patches (cost)
    #  This is also just the size of the dependent set...
#       - correct/optimal number of patches (cost)
#               - sum of 0/1 bits in correct solution
#                 Although, this is more directly available as the size of 
#                 the dependent set.  Still, it's more reusable to compute it 
#                 rather than assume the existance of a dependent set. 
cor_num_patches = sum (solutions_df$optimal_solution)
cat ("\n\ncor_num_patches =", cor_num_patches)

    #  marxan best solution number of patches (cost)
#       - marxan best solution number of patches (cost)
#               - sum of 0/1 bits in marxan solution
marxan_best_num_patches = sum (solutions_df$marxan_best_solution)
cat ("\nmarxan_best_num_patches =", marxan_best_num_patches)

    #  signed marxan best solution err fraction
#       - marxan best solution err fraction
#               - abs (1 - (correct/optimal number of patches - 
#                           marxan best solution number of patches))
marxan_best_solution_cost_err_frac = 
    (marxan_best_num_patches - cor_num_patches) / cor_num_patches
cat ("\nmarxan_best_solution_cost_err_frac =", marxan_best_solution_cost_err_frac)

    #  unsigned marxan best solution err fraction
abs_marxan_best_solution_cost_err_frac = 
    abs (marxan_best_solution_cost_err_frac)
cat ("\nabs_marxan_best_solution_cost_err_frac =", 
     abs_marxan_best_solution_cost_err_frac)

#       - marxan best solution % of species covered
#               - sum of number of uniques species in marxan best solution set
#                       - unique (select (species) where (puid in best solution))
#               - This suggests that there should be a function that computes 
#                 these values for ANY given solution.
#                         percentSppCovered = function (solutionAs01, sppPuidDB)
#                             {
#                             unique (select (species) where puids[which (solutionAs01==TRUE)])   
#                             }
#       - representation shortfall:  marxan best solution err fraction
#               - (1 - marxan best solution % of species covered)
marxan_best_solution_NUM_spp_covered = sum (marxan_mvbest_df$MPM)
marxan_best_solution_FRAC_spp_covered = marxan_best_solution_NUM_spp_covered / num_spp
spp_rep_shortfall = 1 - marxan_best_solution_FRAC_spp_covered

cat ("\n\nmarxan_best_solution_NUM_spp_covered =", marxan_best_solution_NUM_spp_covered)
cat ("\nmarxan_best_solution_FRAC_spp_covered =", marxan_best_solution_FRAC_spp_covered)
cat ("\nspp_rep_shortfall =", spp_rep_shortfall)

#===============================================================================

#  Supporting data not in binding
#   species vs planning units (database?) to allow computation of performance 
#   measures related to which species are covered in solutions
#   (e.g., SELECT species WHERE planning unit ID == curPlanningUnitID)
#   (e.g., SELECT planning unit ID WHERE species == curSpeciesID))
#       - planning unit IDs
#       - set of species on planning unit

#-------------------------------------------------------------------------------

num_runs = 1

results_df = 
    data.frame (run_ID = rep (NA, num_runs), 
                num_PUs = rep (NA, num_runs), 
                num_spp = rep (NA, num_runs), 
                seed = rep (NA, num_runs), 
                
                    #  Xu options
                n__num_cliques = rep (NA, num_runs), 
                alpha__ = rep (NA, num_runs), 
                p__prop_of_links_between_cliques = rep (NA, num_runs), 
                r__density = rep (NA, num_runs),

                    #  Results
                opt_solution_as_frac_of_tot_num_nodes = rep (NA, num_runs),
                cor_num_patches = rep (NA, num_runs),
                marxan_best_num_patches = rep (NA, num_runs), 
                abs_marxan_best_solution_cost_err_frac = rep (NA, num_runs), 
                marxan_best_solution_cost_err_frac = rep (NA, num_runs), 
                spp_rep_shortfall = rep (NA, num_runs),                
                marxan_best_solution_NUM_spp_covered = rep (NA, num_runs), 
                marxan_best_solution_FRAC_spp_covered = rep (NA, num_runs), 
                
                    #  Derived options
                num_nodes_per_clique = rep (NA, num_runs),
                tot_num_nodes = rep (NA, num_runs),
                num_independent_set_nodes = rep (NA, num_runs),
                num_dependent_set_nodes = rep (NA, num_runs),
                num_rounds_of_linking_between_cliques = rep (NA, num_runs),
                target_num_links_between_2_cliques_per_round = rep (NA, num_runs), 
                num_links_within_one_clique = rep (NA, num_runs),
                tot_num_links_inside_cliques = rep (NA, num_runs),
                max_possible_num_links_between_cliques = rep (NA, num_runs),
                max_possible_tot_num_links = rep (NA, num_runs), 
                
                    #  Marxan options
                marxan_spf_const = rep (NA, num_runs),
                marxan_PROP = rep (NA, num_runs),
                marxan_RANDSEED = rep (NA, num_runs),
                marxan_NUMREPS = rep (NA, num_runs),

                    #  Marxan Annealing Parameters
                marxan_NUMITNS = rep (NA, num_runs),
                marxan_STARTTEMP = rep (NA, num_runs),
                marxan_NUMTEMP = rep (NA, num_runs),

                    #  Marxan Cost Threshold
                marxan_COSTTHRESH = rep (NA, num_runs),
                marxan_THRESHPEN1 = rep (NA, num_runs),
                marxan_THRESHPEN2 = rep (NA, num_runs),

                    #  Marxan Program control
                marxan_RUNMODE = rep (NA, num_runs),
                marxan_MISSLEVEL = rep (NA, num_runs),
                marxan_ITIMPTYPE = rep (NA, num_runs),
                marxan_HEURTYPE = rep (NA, num_runs),
                marxan_CLUMPTYPE = rep (NA, num_runs)
                )

cur_result_row = 0

#-------------------------------------------------------------------------------

cur_result_row = cur_result_row + 1

results_df$run_ID [cur_result_row]                                          = parameters$run_id
results_df$num_PUs [cur_result_row]                                          = num_PUs
results_df$num_spp [cur_result_row]                                          = num_spp
results_df$seed [cur_result_row]                                             = seed

    #  Xu options
results_df$n__num_cliques [cur_result_row]                                   = n__num_cliques
results_df$alpha__ [cur_result_row]                                          = alpha__
results_df$p__prop_of_links_between_cliques [cur_result_row]                 = p__prop_of_links_between_cliques
results_df$r__density [cur_result_row]                                       = r__density

    #  Results
results_df$opt_solution_as_frac_of_tot_num_nodes [cur_result_row]            = opt_solution_as_frac_of_tot_num_nodes
results_df$cor_num_patches [cur_result_row]                                  = cor_num_patches
results_df$marxan_best_num_patches [cur_result_row]                          = marxan_best_num_patches
results_df$abs_marxan_best_solution_cost_err_frac [cur_result_row]           = abs_marxan_best_solution_cost_err_frac
results_df$marxan_best_solution_cost_err_frac [cur_result_row]               = marxan_best_solution_cost_err_frac
results_df$spp_rep_shortfall [cur_result_row]                                = spp_rep_shortfall                
results_df$marxan_best_solution_NUM_spp_covered [cur_result_row]             = marxan_best_solution_NUM_spp_covered
results_df$marxan_best_solution_FRAC_spp_covered [cur_result_row]            = marxan_best_solution_FRAC_spp_covered

    #  Derived Xu options
results_df$num_nodes_per_clique [cur_result_row]                             = num_nodes_per_clique
results_df$tot_num_nodes [cur_result_row]                                    = tot_num_nodes
results_df$num_independent_set_nodes [cur_result_row]                        = num_independent_set_nodes
results_df$num_dependent_set_nodes [cur_result_row]                          = num_dependent_set_nodes
results_df$num_rounds_of_linking_between_cliques [cur_result_row]            = num_rounds_of_linking_between_cliques
results_df$target_num_links_between_2_cliques_per_round [cur_result_row]     = target_num_links_between_2_cliques_per_round
results_df$num_links_within_one_clique [cur_result_row]                      = num_links_within_one_clique
results_df$tot_num_links_inside_cliques [cur_result_row]                     = tot_num_links_inside_cliques
results_df$max_possible_num_links_between_cliques [cur_result_row]           = max_possible_num_links_between_cliques
results_df$max_possible_tot_num_links [cur_result_row]                       = max_possible_tot_num_links

    #  Marxan options
results_df$marxan_spf_const [cur_result_row]                                 = spf_const
results_df$marxan_PROP [cur_result_row]                                      = marxan_PROP
results_df$marxan_RANDSEED [cur_result_row]                                  = marxan_RANDSEED
results_df$marxan_NUMREPS [cur_result_row]                                   = marxan_NUMREPS

    #  Marxan Annealing Parameters
results_df$marxan_NUMITNS [cur_result_row]                                   = marxan_NUMITNS
results_df$marxan_STARTTEMP [cur_result_row]                                 = marxan_STARTTEMP
results_df$marxan_NUMTEMP [cur_result_row]                                   = marxan_NUMTEMP

    #  Marxan Cost Threshold
results_df$marxan_COSTTHRESH [cur_result_row]                                = marxan_COSTTHRESH
results_df$marxan_THRESHPEN1 [cur_result_row]                                = marxan_THRESHPEN1
results_df$marxan_THRESHPEN2 [cur_result_row]                                = marxan_THRESHPEN2

    #  Marxan Program control
results_df$marxan_RUNMODE [cur_result_row]                                   = marxan_RUNMODE
results_df$marxan_MISSLEVEL [cur_result_row]                                 = marxan_MISSLEVEL
results_df$marxan_ITIMPTYPE [cur_result_row]                                 = marxan_ITIMPTYPE
results_df$marxan_HEURTYPE [cur_result_row]                                  = marxan_HEURTYPE
results_df$marxan_CLUMPTYPE [cur_result_row]                                 = marxan_CLUMPTYPE


#  Getting an error.  Not sure why...  Is it because the free variable names 
#  like num_PUs, are the same as the list element names, like results_df$num_PUs?
#
#  Error in `$<-.data.frame`(`*tmp*`, "num_PUs", value = c(NA, 12L)) :  
#    replacement has 2 rows, data has 1 
#  Calls: source ... withVisible -> eval -> eval -> $<- -> $<-.data.frame 
#  Execution halted 


#write.csv (results_df, file = "./prob_diff_results.csv", row.names = FALSE)
write.csv (results_df, file = parameters$summary_filename, row.names = FALSE)

#===============================================================================


# }  #  end - for cur_repeat
#     
# }  #  end - for n__num_cliques
# 
# plot (1:num_runs, results_df$spp_rep_shortfall)

#===============================================================================
#===============================================================================
#===============================================================================
#===============================================================================

if (FALSE)    #  Basically just commenting out a big scratch area down to EOF
{
    
#===============================================================================

    #  Write one or more lines of summary output to be collected by tzar's 
    #  aggregation operator.
    #       - Does the current aggregation operator assume that it's reading 
    #         from a flat file with a single line or something like that?
    #       - Could you do more complex structures, e.g., sqlite?

    #  What needs to go in that output?
    #  That depends on what I'm going to do down the line with that output.
    #  1)  Learn a model to predict the error given the problem characteristics.
    #  2)  Display summary plot(s) of marxan behavior given the problem 
    #      characteristics or even just overall (to show the minimum range of  
    #      different performance levels that marxan can exhibit).
    #           a)  Note that this has been done to a certain extent in the 
    #               papers by the linear programming people.
    #               However, none of those papers (that I have seen) use 
    #               synthetic problems to explore the space.  They all seem 
    #               to be the usual small collection of real world case 
    #               studies.
    #  3)  Use the data as the seed/basis for something like active learning in 
    #      searching for hard and easy problems.

    #  So, that means that each run needs to record:
    #       - Problem characteristics
    #           - problem input characteristics
    #               - Xu control parameters: alpha, etc.
    #               - number of species
    #               - number of patches
    #               - target rank abundance distribution shape
    #                   - flat, lognormal, etc.
    #                   - how to characterize this?
    #                       - curve type
    #                       - fit parameters
    #           - problem characteristics measured after the problem is 
    #             generated
    #               - network measures over the adjacency matrix?
    #               - diversity measures 
    #                   - alpha, beta, gamma, etc
    #                   - or do these end up being inputs as well?
    #               - actual (not target) rank abundance distribution shape
    #                   - flat, lognormal, etc.
    #                   - how to characterize this?
    #                       - curve type
    #                       - fit parameters
    #       - Performance measures
    #           - Single number aggregates
    #               - % error in estimation of cost of optimal solution
    #                   - e.g., number of patches as cost
    #               - % of species achieving their representation targets
    #               - cost/benefit ratios
    #                 Not sure if these are actually useful, but the marxan 
    #                 crowd seems to be in love with them right now...
    #                 Seems like they might be hard to compare across solutions, 
    #                 e.g., you might choose just one parcel and it has a 
    #                 great cost/benefit ratio, but comes nowhere near 
    #                 representing all species.  When something like that 
    #                 is happening, then you have to get into designing all 
    #                 kinds of penalty functions to be able to make fair 
    #                 comparison between solutions...
    #                   - cost/benefit ratio for marxan solution
    #                   - cost/benefit ratio for optimal solution
    #           - Rolling measures
    #             These might just be output as plots in in the tzar output 
    #             area for the given run so that they could be selectively 
    #             viewed later instead of actually being aggregated.
    #               - curve of % of species achieving targets as a function of 
    #                 choosing patches in order by:
    #                   - simple richness
    #                   - unprotected richness
    #                   - ssoln votes for patch
    #                   - cost/benefit ratio for patch
    #                       - When cost is 1 for every patch, this degenerates 
    #                         to richness.
    #           - *** Fully interrogatable species/patch record for 
    #               - marxan solution
    #               - optimal solution
    #             so that you can come back to the problem later without having 
    #             to re-run things when you come up with some new measure to 
    #             apply to the data.  This could also serve as an object that 
    #             could be served up over the web for people to operate on 
    #             without having to do the runs themselves.  Would need a 
    #             similar kind of structure for the problem itself.  Maybe 
    #             all of the things that I've listed above become an sqlite 
    #             database (or some other more complex structure?) and that 
    #             is the universally addressed object that you can write code 
    #             to service.
    #               - Seems like spatial information like maps will also have 
    #                 to figure in this somehow (which might imply the need 
    #                 for postgresql gis-related functions).
    #               - How does all of this relate to zonation?  
    #                   - Can it be treated similarly?
    #                   - Is there some hierarchical view of all this that 
    #                     allows some parts of this to be identical for 
    #                     for marxan and zonation but eventually has to split 
    #                     because of their different world views?

#-------------------------------------------------------------------------------

    #  Compute or extract number of species represented by marxan solution.

#-------------------------------------------------------------------------------

    #  Compare marxan results to correct solution.
    #  Compute marxan error.

#-------------------------------------------------------------------------------

    #  Compute what percentage of species were represented in the marxan 
    #  solution.

#-------------------------------------------------------------------------------

    #  Compute the cost benefit ratio for the marxan solution, i.e., 
    #  (number of patches / number of species represented) in solution.

#-------------------------------------------------------------------------------

    #  Plot total representation as you add planning units to the reserve 
    #  set in decreasing order by the number of votes received.
        #  NOTE:  See all areas of the Marxan user manual where Fischer is 
        #         cited.  There are lots of things there about how you 
        #         have to be careful about how you interpret the summed 
        #         solution.  Also talks about various sensitivity analysis 
        #         things.
        #  Might be good to show on the same plot the identical curve if 
        #  you were to add planning units in order by:
            #  simple richness
            #  unprotected richness
            #  cost/benefit of planning unit
                #  though at the moment, all costs are the same, so 
                #  benefit (i.e., species (protected or unprotected)) 
                #  is all that matters
            #  unprotected cost/benefit of planning unit

#===============================================================================

#  Build marxan input.dat file.
#  The user's manual has a table showing all options and their 
#  default values.  Can use that as a starting point.

#  Definitely need to set at least the following values:
#  random seed

#  An example on one of the web pages I found tonight reads in the 
#  input.dat file and modifies something, then writes it back out...
#  http://lists.science.uq.edu.au/pipermail/marxan/2008-May/000319.html

####################### MARXAN RUNS ############################################

####################### Step 1 #################################################

#  Read and obtain Input.dat parameters

input.file <- dir (pattern  = "input.dat")
input <- readLines (input.file[1], n  = -1)

#  Parameters to be changed in input.dat file

nreps  = 5    #  Numreps
blm <- as.character (format (c (0.00, 1.00), nsmall  = 2)) # Vector of Blm to be used

#  Penalty factor to be used

spf.t <- sprintf ("%03d", c (1, 10, 100)) # Vector of spf to be used

#  Read and obtain target.dat parameters

target.file <- dir (pattern = "target.dat")
target <- read.table (target.file[1], header = T, dec = ".", sep = ",")

####################### Step 2 #################################################

#  Loop for sequential sfp

for (ii in 1:length (spf.t))
{
    # Target parameters ## NOT USED YET
    
    target[, 4] <- rep (spf.t[ii], nrow (target))
    write.table (target, "target.dat", sep = ",", row.names = F)
    
    #  Loop for sequential Marxan Runs
    
    for (i in 1:length (blm))        
    {
        #  Input.dat parameters
        
        #blmf = blm[i] # Variation in BLM
        
        input[10] <- paste ("BLM", blm[i]) # BLM in input.dat        
        input[14] <- paste ("NUMREPS", nreps) # Number of runs in input.dat        
        input[35] <- paste ("SCENNAME", "", formatC (ii, width = 3, flag = "0"), "_", 
                            formatC (i, width = 3, flag = "0"), "output", 
                            "spf", spf.t[ii], "blm", blm[i], sep = "") # Output name for series 
        
        write (input, "input.dat")    # Re-write input file at each run with the corresponding parameters changed
        
        system ("Marxan.exe", wait = T, invisible = T) # Call Marxan to execute
    }
}

#  I’m now trying to produce interpretable graphs. 
#  All outputs can be mapped with maptools, with something similar to:

grid <- read.shape ("grid1.shp")
win.graph () # New window
par (mfrow = c (2, 3))
nblm <- as.numeric (blm)

for (i in 1:length (blm))    
{    
    sortd <- d.soln[order (d.soln$blm, d.soln$planning.unit), ]    
    cores <- sortd$number[sortd$blm==blm[i]]    
    cores <- cores+1
    
    #  Plot of the Grid for each BLM used
    
    plot (grid, 
          fg = topo.colors ((max(cores) - min(cores)),  alpha = 1) [cores], 
          main = paste ("Blm:", blm[i])) # Plotting of the grid with resulting summed result
}

####################### END CODE FOR MARXAN RUNS ###############################

#===============================================================================

#  Build some kind of a program that searches for good input settings 
#  for a given input problem.  This could also be added to the marxan 
#  package and be elaborated on by marxan experts.
#  Seems like this and some of the other things here are fairly 
#  generic to any reserve selector or other kind of mathematical 
#  conservation tool.  So, may be worth making some kind of OOP 
#  abstraction of this stuff and apply it to Zonation as a test 
#  of its general utility.

#===============================================================================

    #  I can still ask questions like all of these under uncertainty by using 
    #  the same problem generator and then adding known uncertainties to it 
    #  so that we still know the correct answer.

#===============================================================================

    #  Programs to search for hard problems.
        #  Don't just want to find hard problems though.  Want to be able to 
            #  predict what problems will be easy and hard, i.e., what is the 
            #  likely error or suboptimality of the reserve selector?
        #  Kinds of search to try:
            #  Systematic grid search using tzar's control option.
            #  Some kind of gradient search that runs over continuous problem 
                #  characteristics.
                #  However, this requires a parametric description of the 
                #  problem space to do the optimization over.  
                #  Learn a predictive model and do gradient search over that  
                    #  learned model.
                    #  Active learning?
                    #  Systematic experimentation?
                    #  Experimental design?
                    #  Something from the SAMO course?
            #  Heuristic search like simulated annealing.
            #  Integer/linear/... programming search.

#===============================================================================

    #  Features that might be useful in measuring problem difficulty and 
    #  in problem generation.  Some of these have occurred to me as 
    #  features just because I was thinking algorithmically about how 
    #  you might make the problem harder.

        #  Network measures over the adjacency matrix as input features for 
            #  predicting performance/difficulty.
    
        #  Do any of the entropy/diversity measures that people like Christy 
            #  use have any predictive power here?  
                #  alpha, beta, gamma diversity
                #  Shannon information measures
                    #  entropy
            #  This seems like it might be important because evenness of species 
                #  distribution seems like it makes it harder to get a feasible 
                #  solution.
    
        #  What about some variant of expressing/measuring complementarity of 
            #  co-occurrence?  
            #  Seems like things that occur as ensembles/communities may also 
            #  make the problem easier (somehow reducing entropy again?) since 
            #  you know that if one species occurs in a place, a whole suite 
            #  of other ones may occur there as well.  This would allow you 
            #  to search for solutions over a much smaller set of species and 
            #  thereby reduce the computational complexity of the search.

#===============================================================================

    #  Need to write test functions if this is going to be made more 
    #  publicly available and used to support production of papers.

#===============================================================================

    #  These linear programming papers ignore the uncertainty issues in 
    #  optimality, but are worth paying attention to in differentiating 
    #  what my results are aimed at doing, particularly prediction of 
    #  of likely accuracy given a problem description.  
    #  Need to be sure that this is in the foreground of my paper, 
    #  i.e., that the primary contribution is related to prediction 
    #  and to defining features that characterize what makes 
    #  problems hard or easy.  
        #  1)  vanderkam et al 2007. "Heuristic algorithms vs. linear programs 
        #  for designing efficient conservation reserve networks: Evaluation 
        #  of solution optimality and processing time"
        #  2)  fischer and church 2005.  "The SITES reserve selection system: 
        #  a critical review"

#===============================================================================

    #  Need to add a test of ensemble optimization based on choosing best 
    #  solution when evaluated across a family of possible disturbances 
    #  rather than just summing or some other kind of voting method.  
    #  This is an important thing to do so that things are a bit more 
    #  constructive rather than always being about showing what's wrong 
    #  with existing methods.

#===============================================================================
#===============================================================================

#  Something was wrong here at first, but it does suggest some good tests 
#  to build based on what I'm expecting here.

#  1)  Each node in the initial linking should have exactly 3 links in this 
#      case, i.e., num_links should be num_nodes_per_clique - 1.
#
#  2)  All of the nodes should appear in the first list, i.e., not just the 
#      first 12.
#
#  More general things that should always be true based on the underlying idea 
#  behind the design of the algorithm:
#
#  3)  No node in the independent set should be connected to any other node 
#      in the independent set.
#
#  4)  No node in the independent set should be connected to any node in 
#      a different clique?

# Number of links per node BEFORE interclique linking:
#     node_ID freq
# 1        1    3
# 2        2    3
# 3        3    3
# 4        4    3
# 5        5    3
# 6        6    3
# 7        7    3
# 8        8    3
# 9        9    3
# 10      10    1
# 11      11    1
# 12      12    1
# 
# 
# Number of links per node AFTER interclique linking:
#     node_ID freq
# 1        1    3
# 2        2    3
# 3        3    3
# 4        4    3
# 5        5    3
# 6        6    3
# 7        7    3
# 8        8    3
# 9        9    3
# 10      10    3
# 11      11    3
# 12      12    3
# 13      13    3
# 14      14    3
# 15      15    2
# 16      16    2

#===============================================================================

#  Some R files for Marxan from marxan tutorials
#       http://marxan.net/tutorial.html
#  
#  http://marxan.net/tutorial/MarxanTutorial_rev2.1.R
#######################################################################################
# Author: Matt Watts, m.watts@uq.edu.au                                               #
# Date: November 2013                                                                 #
# Run Marxan, perform cluster analysis, display output graphs, maps and tables.       #
# This file, MarxanTutorial_rev2.1.R, contains the commands you need to run Marxan with #
# R Studio Server on Marxan.net                                                       #
# It includes commands for the "MPA_Activity" and "Tas_Activity" datasets.            #
#######################################################################################
#
#  http://marxan.net/tutorial/Marxan_rev2.1.R
# Software purpose: Run Marxan, perform cluster analysis, display output
# graphs, maps and tables.
# This file, Marxan_rev2.1.R, contains the R function definitions.

#===============================================================================

}  #  end - if (FALSE)    #  Basically just commenting out a big block

#===============================================================================

cat ("\n\n")
sessionInfo()
cat ("\n\n")



#===============================================================================
#===============================================================================
#===============================================================================
#===============================================================================
                    #  START EMULATION CODE
#===============================================================================

if (emulateRunningUnderTzar)
    {
    cat ("\n\nIn generateSetCoverProblem:  Cleaning up after running emulation...\n\n")
    cleanUpAfterTzarEmulation (parameters)
    }

#===============================================================================
                    #  END EMULATION CODE
#===============================================================================

