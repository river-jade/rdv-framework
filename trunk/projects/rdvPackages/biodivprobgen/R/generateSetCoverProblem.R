#===============================================================================

#  v1 - 
#  v2 - 
#  v3 - add degree distribution calculations
#  v4 - cleaning up code layout formatting
#  v5 - replacing node_link_pairs with link_node_pairs to match marxan puvspr

#===============================================================================

library (plyr)    #  For count()
library (marxan)

#-------------------------------------------------------------------------------

seed = 17
set.seed (seed)

#-------------------------------------------------------------------------------

integerize = function (x) 
    { 
    round (x) 
#    celiing (x)
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
        
n__num_cliques                   = 5
alpha__                          = 0.8
p__prop_of_links_between_cliques = 0.5  
r__density                       = 0.5

# n__num_cliques                   = 12
# alpha__                          = 1.5
# p__prop_of_links_between_cliques = 0.3  
# r__density                       = 0.8

#-------------------------------------------------------------------------------

    #  Derived control parameters.

    cat ("\n\n--------------------  Building derived control parameters.\n")
    
    num_nodes_per_clique = integerize (n__num_cliques ^ alpha__)
    tot_num_nodes = n__num_cliques * num_nodes_per_clique

    num_independent_set_nodes = n__num_cliques
    num_dependent_set_nodes = tot_num_nodes - num_independent_set_nodes
    
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

cat ("\n\n--------------------  Writing out the data as Marxan input files.\n")

library (marxan)

sppAmount = 1

num_node_link_pairs = length (node_link_pairs [,"node_ID"])
PU_IDs = unique (node_link_pairs [,"node_ID"])
spp_IDs = unique (node_link_pairs [,"link_ID"])

spp_PU_amount_table =
    data.frame (species = node_link_pairs [,"link_ID"],
                pu      = node_link_pairs [,"node_ID"],
                amount  = rep (sppAmount, num_node_link_pairs))

write_all_marxan_input_files (PU_IDs, spp_IDs, spp_PU_amount_table)


x2 <- by (spp_PU_amount_table$amount, spp_PU_amount_table$pu, sum)
do.call(rbind,as.list(x2))
cat ("\n\nx2 =\n")
print (x2)

#-------------------------------------------------------------------------------

#  TODO:

    #  NOTE:  Many of the entries below have to do with reading marxan output 
    #         and loading it into this program and doing something with it.
    #         I should build functions for doing those things and add them to 
    #         the marxan package.  Should talk to Ascelin about this too and 
    #         see if there is any overlap with what he's doing.

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

    #  Copy results to marxan input area.

    #  Build marxan input.dat file.
        #  The user's manual has a table showing all options and their 
        #  default values.  Can use that as a starting point.

    #  Build some kind of a program that searches for good input settings 
    #  for a given input problem.  This could also be added to the marxan 
    #  package and be elaborated on by marxan experts.
        #  Seems like this and some of the other things here are fairly 
        #  generic to any reserve selector or other kind of mathematical 
        #  conservation tool.  So, may be worth making some kind of OOP 
        #  abstraction of this stuff and apply it to Zonation as a test 
        #  of its general utility.

    #  Run marxan.
        #  Should include this in the marxan package.

    #  Read various marxan outputs into this program.
        #  Should include these in the marxan package.
        #  Marxan's best solution.
        #  Marxan's votes for including each planning unit.
        #  

    #  Compute or extract number of species represented by marxan solution.

    #  Compare marxan results to correct solution.

    #  Compute marxan error.

    #  Compute what percentage of species were represented in the marxan 
    #  solution.

    #  Compute the cost benefit ratio for the marxan solution, i.e., 
    #  (number of patches / number of species represented) in solution.

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

    #************************************
    #  I can still ask questions like all of these under uncertainty by using 
    #  the same problem generator and then adding known uncertainties to it 
    #  so that we still know the correct answer.
    #************************************

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

    #  Need to write test functions if this is going to be made more 
    #  publically available and used to support production of papers.

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


