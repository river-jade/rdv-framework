#===============================================================================

                        #  gscp_9_link_nodes_between_groups.R

#===============================================================================

    #  Now all groups and their within group links have been built.  
    #  Ready to start doing rounds of intergroup linking.

cat ("\n\n--------------------  Doing rounds of intergroup linking.\n")

for (cur_round in 1:num_rounds_of_linking_between_groups)
    {
    cat ("\nRound", cur_round)
    
    #  Draw a random pair of groups to link in this round.
    cur_group_pair = sample (1:n__num_groups, 2, replace=FALSE)
    
    #  I'm using min and max here because smaller group IDs were 
    #  filled with smaller node IDs, so every node ID in the 
    #  smaller group ID should be the smaller node ID of any pairing 
    #  of nodes between the groups and the linking routine 
    #  expcts the smaller node ID to come before the larger one 
    #  in the linking argument list.  This may be a vestigial thing 
    #  from earlier schemes that doesn't matter any more, but 
    #  it's easy to maintain here for the moment, just in case it 
    #  does still matter in some way.  In any case, it doesn't 
    #  hurt anything to do this now other than the little bit of 
    #  extra execution time to compute the min and max.
    
    group_1 = min (cur_group_pair)
    group_1_nodes = nodes [(nodes$group_ID == group_1) & (nodes$dependent_set_member), 
                            "node_ID"]
    
    group_2 = max (cur_group_pair)
    group_2_nodes = nodes [(nodes$group_ID == group_2) & (nodes$dependent_set_member), 
                            "node_ID"]
    
#***----------------------------------------------------------------------------
    
    group_1_sampled_nodes = 
        sample (group_1_nodes, target_num_links_between_2_groups_per_round, 
                replace=TRUE)
    group_2_sampled_nodes = 
        sample (group_2_nodes, target_num_links_between_2_groups_per_round, 
                replace=TRUE)
    
    for (cur_node_pair_idx in 1:target_num_links_between_2_groups_per_round)
        {                
        edge_list [cur_row, 1] = group_1_sampled_nodes [cur_node_pair_idx]
        edge_list [cur_row, 2] = group_2_sampled_nodes [cur_node_pair_idx]
        cur_row = cur_row + 1
        }
    }

#===============================================================================

