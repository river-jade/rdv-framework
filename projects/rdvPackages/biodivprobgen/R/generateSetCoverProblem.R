#===============================================================================

#  v1 - 
#  v2 - 
#  v3 - add degree distribution calculations
#  v4 - cleaning up code layout formatting

#===============================================================================

library (plyr)    #  For count()
library (marxan)

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
    cat ("\n\t\t[", smaller_node_ID, ",", larger_node_ID, "]")
    
    node_link_pairs [next_node_link_pair_row, "node_ID"] = smaller_node_ID
    node_link_pairs [next_node_link_pair_row, "link_ID"] = next_link_ID
#             cat ("\n\t\t\tnode_link_pairs [", next_node_link_pair_row, ", ] = \n")
#             print (node_link_pairs [next_node_link_pair_row,])
    next_node_link_pair_row = next_node_link_pair_row + 1
    
    node_link_pairs [next_node_link_pair_row, "node_ID"] = larger_node_ID
    node_link_pairs [next_node_link_pair_row, "link_ID"] = next_link_ID
#             cat ("\n\t\t\tnode_link_pairs [", next_node_link_pair_row, ", ] = \n")
#             print (node_link_pairs [next_node_link_pair_row,])
    next_node_link_pair_row = next_node_link_pair_row + 1

    next_link_ID = next_link_ID + 1
#             cat ("\n\t\tnext_link_ID = ", next_link_ID)
    
    updated_links = list()
    updated_links$next_node_link_pair_row = next_node_link_pair_row
    updated_links$next_link_ID = next_link_ID
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
        
#-------------------------------------------------------------------------------

    #  Derived control parameters.
    
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
    
    node_IDs = 1:tot_num_nodes
    
    clique_IDs = 1 + (0:(tot_num_nodes - 1) %/% num_nodes_per_clique)
    
    independent_node_IDs = seq (from=1, 
                                by=num_nodes_per_clique, 
                                length.out=n__num_cliques)
    
    dependent_set_members = rep (TRUE, tot_num_nodes)
    dependent_set_members [independent_node_IDs] = FALSE
    
    dependent_node_IDs = node_IDs [which (dependent_set_members)]
    
#    nodes = cbind (node_IDs, clique_IDs, dependent_set_member)
    nodes = data.frame (node_ID = node_IDs,
                        clique_ID = clique_IDs, 
                        dependent_set_member = dependent_set_members)

    cat ("\n\t\t independent_node_IDs = ", independent_node_IDs)
    cat ("\n\t\t dependent_node_IDs = ", dependent_node_IDs)
    
    cat ("\n\nnodes = \n")
    print (nodes)
    cat ("\n\n")
    
#    nodes_df = as.data.frame (nodes)
#    browser()
    
    max_possible_tot_num_node_link_pairs = 2 * max_possible_tot_num_links
    node_link_pairs = matrix (NA, 
                              nrow=max_possible_tot_num_node_link_pairs, 
                              ncol=2)
    node_link_pairs = as.data.frame (node_link_pairs)
    names (node_link_pairs) = c("node_ID", "link_ID")
    
    next_node_link_row = 1
    next_link_ID = 1
    cur_clique_ID = 1
    
        #  Link all nodes within each clique.
    all_clique_IDs = 1:n__num_cliques

    cat ("\n\nCliques")
    
#df[df$value>3.0,] 

#-------------------------------------------------------------------------------

if (num_nodes_per_clique < 2)
    quit ("\n\n***  num_nodes_per_clique (", num_nodes_per_clique, 
          ") must be at least 2.\n\n")


    num_nodes_per_clique_minus_1 = num_nodes_per_clique - 1
    next_node_link_pair_row = 1
    next_link_ID = 1

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
        
        for (cur_idx in 1:num_nodes_per_clique_minus_1)
            {
            for (other_node_idx in (cur_idx+1):num_nodes_per_clique)
                {
                updated_links = 
                    add_link (node_link_pairs, next_node_link_pair_row, 
                              cur_clique_nodes_sorted [cur_idx], 
                              cur_clique_nodes_sorted [other_node_idx], 
                              next_link_ID)
                next_node_link_pair_row = updated_links$next_node_link_pair_row
                next_link_ID = updated_links$next_link_ID
                node_link_pairs = updated_links$node_link_pairs
                }
            }
        }
        
    cat ("\n\nnode_link_pairs = \n")
    print (node_link_pairs)
    cat ("\n\n")

#-------------------------------------------------------------------------------

initial_link_counts_for_each_node = 
    count (node_link_pairs, vars="node_ID")
initial_node_counts_for_each_link = 
    count (node_link_pairs, vars="link_ID")

#===============================================================================

#  Now all cliques and their within clique links have been built.  

#  Ready to start doing rounds of interclique linking.

for (cur_round in 1:num_rounds_of_linking_between_cliques)
    {
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
    
    clique_1 = min (cur_clique_pair [1])
    clique_1_nodes = nodes [nodes$clique_ID == clique_1, "node_ID"]
    
    clique_2 = max (cur_clique_pair [2])
    clique_2_nodes = nodes [nodes$clique_ID == clique_2, "node_ID"]
    
    clique_1_sampled_nodes = 
        sample (clique_1_nodes, target_num_links_between_2_cliques_per_round, 
                replace=TRUE)
    clique_2_sampled_nodes = 
        sample (clique_2_nodes, target_num_links_between_2_cliques_per_round, 
                replace=TRUE)
    
        #  Make sure that there are no duplicate links in the list.
    pairs = unique (cbind (clique_1_sampled_nodes, clique_2_sampled_nodes))
#                 cat ("\n\n interclique pairs for round ", cur_round, " = \n")
#                 print (pairs)
#                 cat ("\n")
    
    for (cur_idx in 1:length (pairs))
        {
        updated_links = 
            add_link (node_link_pairs, next_node_link_pair_row, 
                      pairs [1], 
                      pairs [2], 
                      next_link_ID)
        next_node_link_pair_row = updated_links$next_node_link_pair_row
        next_link_ID = updated_links$next_link_ID
        node_link_pairs = updated_links$node_link_pairs
        }
    
    }

#===============================================================================

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

cat ("\n\nNumber of links per node BEFORE interclique linking:\n")
print (initial_link_counts_for_each_node)

final_link_counts_for_each_node = count (node_link_pairs, vars="node_ID")

cat ("\n\nNumber of links per node AFTER interclique linking:\n")
print (final_link_counts_for_each_node)

final_degree_dist = arrange (final_link_counts_for_each_node, -freq)
final_degree_dist[,"node_ID"] = 1:dim(final_degree_dist)[1]
plot (final_degree_dist)

#-------------------------------------------------------------------------------

cat ("\n\nNumber of nodes per link BEFORE interclique linking:\n")
print (initial_node_counts_for_each_link)

final_node_counts_for_each_link = count (node_link_pairs, vars="link_ID")

cat ("\n\nNumber of nodes per link AFTER interclique linking:\n")
print (final_node_counts_for_each_link)

final_rank_abundance_dist = arrange (final_node_counts_for_each_link, -freq)
final_rank_abundance_dist[,"link_ID"] = 1:dim(final_rank_abundance_dist)[1]
plot (final_rank_abundance_dist)

#===============================================================================

#  Something was wrong here at first, but it does suggest some good tests 
#  to build based on what I'm expecting here.

#  1)  Each node in the initial linking should have exactly 3 links in this 
#      case, i.e., num_links should be num_nodes_per_clique - 1.
#
#  2)  All of the nodes should appear in the first list, i.e., not just the 
#      first 12.

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


