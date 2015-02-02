#===============================================================================

                        #  gscp_6_create_data_structures.R

#===============================================================================

        #--------------------------------------------------
        #  Create structures to hold the nodes and links.
#  NEED TO DESCRIBE ALL OF THE MAJOR DATA STRUCTURES USED IN HERE 
#  AND WHAT (IF ANYTHING), THEY ASSUME.
        #--------------------------------------------------    

    cat ("\n\n--------------------  Creating structures to hold the nodes and links.\n")

    node_IDs = 1:tot_num_nodes
    
#--------------------

            #  For each node ID, what group does it belong to?
    group_IDs = 1 + (0:(tot_num_nodes - 1) %/% num_nodes_per_group)

            #  Assign lowest node IDs in each group to be the independent nodes 
            #  in that group.
#     independent_node_IDs = seq (from=1, 
#                                 by=num_nodes_per_group, 
#                                 length.out=n__num_groups)

    independent_node_ID_starts = seq (from=1, 
                                      by=num_nodes_per_group, 
                                      length.out=n__num_groups)
    independent_node_IDs = c()
    for (idx in 0:(num_independent_nodes_per_group-1))
        {
        independent_node_IDs = 
                c(independent_node_IDs, (idx + independent_node_ID_starts))
        }            
    independent_node_IDs = sort (independent_node_IDs)

#--------------------

            #  For each node ID, flag whether it is in the dependent set or not.
    dependent_set_members = rep (TRUE, tot_num_nodes)
    dependent_set_members [independent_node_IDs] = FALSE
    
            #  Collect the IDs of just the dependent nodes.
    dependent_node_IDs = node_IDs [-independent_node_IDs]
    
            #  Build an overall data frame that shows for each node, 
            #  its node ID and group ID, plus a flag indicating whether 
            #  it's in the dependent set or not.  For example, if there 
            #  are 3 nodes per group:
            #
            #       node_ID     group_ID       dependent_set_member
            #         1            1                 TRUE
            #         2            1                 TRUE
            #         3            1                 FALSE
            #         4            2                 TRUE
            #         5            2                 TRUE
            #         6            2                 FALSE
            #        ...          ...                 ...


#    nodes = cbind (node_IDs, group_IDs, dependent_set_member)
    nodes = data.frame (node_ID = node_IDs,
                        group_ID = group_IDs, 
                        dependent_set_member = dependent_set_members)

#     cat ("\n\nnodes and their group IDs:")
#     for (cur_node_ID in 1:tot_num_nodes)
#         {
#         cat ("\n\t", cur_node_ID, "\t", group_IDs [cur_node_ID])    
#         }
#     cat ("\n")

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\t\t independent_node_IDs = ", independent_node_IDs)
    cat ("\n\t\t dependent_node_IDs = ", dependent_node_IDs)
    
    cat ("\n\nnodes = \n")
    print (nodes)
    cat ("\n\n")    
    }
    
#     edge_list = matrix (NA, 
#                                 nrow = max_possible_tot_num_links, 
#                                 ncol = 2, 
#                                 byrow = TRUE)

#===============================================================================

