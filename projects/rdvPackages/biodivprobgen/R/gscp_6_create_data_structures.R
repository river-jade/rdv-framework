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
    
#    nodes_df = as.data.frame (nodes)
    
    edge_list = matrix (NA, 
                                nrow = max_possible_tot_num_links, 
                                ncol = 2, 
                                byrow = TRUE)

#-------------------------------------------------------------------------------
#    I don't think that anything from here on in this file is used anymore.
#    I'm going to test this by putting an "if (FALSE)" around it all to see 
#    whether anything breaks.  If everything continues to work fine, then 
#    I can remove all of this.  
#    However, the comment immediately below here seems like it must apply 
#    to something that has been created elsewhere now and possibly given 
#    a different name.
#-------------------------------------------------------------------------------

            #  Is this comment no longer applicable?
            #  Or, does it apply to something else that's built later on?
            #  BTL - 2014 12 29
            #  
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


#     node_link_pairs = matrix (NA, 
#                               nrow=max_possible_tot_num_node_link_pairs, 
#                               ncol=2, 
#                               byrow=TRUE
#                               )
#     node_link_pairs = as.data.frame (node_link_pairs)
#     names (node_link_pairs) = c("node_ID", "link_ID")

if (FALSE)
{
    next_node_link_row = 1    #  NEVER USED?  DELETE THIS?
    next_link_ID = 1
    cur_group_ID = 1
    
        #  Link all nodes within each group.
    all_group_IDs = 1:n__num_groups    #  NEVER USED?  DELETE THIS?

    cat ("\n\ngroups")
    
#df[df$value>3.0,] 
    
}

#===============================================================================

