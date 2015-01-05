#===============================================================================

                #  gscp_10_clean_up_completed_graph_structures.R

#===============================================================================

    #  All node pairs should be loaded into the edge_list table now 
    #  and there should be no NA lines left in the table.
    
    #  However no duplicate links are allowed, so need to go through all 
    #  node pairs and remove non-unique ones.
                #  BTL - 2015 01 03 - Is this "no duplicates allowed" taken 
                #                       from the original algorithm?  
                #                       Need to be sure about that since 
                #                       it affects things downstream.

        #  NOTE:  I think that this unique() call only works if the 
        #           pairs are ordered within pair, i.e., if all from 
        #           nodes have a value less than or equal to the to value.
        #           That wouldn't be necessary if these were directed links, 
        #           but undirected, you couldn't recognize duplicates if 
        #           the order was allowed to occur both ways, i.e., (3,5) and 
        #           (5,3) would not be flagged as being duplicates.

unique_edge_list = unique (edge_list)  #  the edge list

num_non_unique_edge_list = dim (edge_list)[1]
num_unique_edge_list = dim (unique_edge_list)[1]

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nnum_non_unique_edge_list =", num_non_unique_edge_list)
    cat ("\nnum_unique_edge_list =", num_unique_edge_list)
    cat ("\n")    
    }

#===============================================================================

    #  Convert edge list to PU/spp table to give to Marxan.
    #
    #  Now that we have the edge list, we need to go through and 
    #  create a table where every link attached to a node appears on a 
    #  separate line of the table and is labelled with the node ID.  
    #  So, that means that we have to go through the whole edge list and 
    #  create 2 new table entries for each link in the edge list.  
    #  Each of those entries gives the ID of one of the end nodes of the 
    #  link plus the link's ID.  
    #
    #  This table needs to be built because it's the form that Marxan expects 
    #  the spp and PU data to be in, i.e., node=PU and link=spp and every 
    #  line in the table is specifying a PU and one of the species in it.  
    #  If we weren't feeding Marxan, there would be no need for this kind 
    #  of a table since we already have an edge list.
    #
    #  However, there is one other useful byproduct of building this table.
    #  It makes it easy to compute rank-abundance information and information 
    #  about the distribution of species across patches.
    #
    #  I just realized that this structure is also something like the 
    #  description of a bipartite network, so I may need to modify or use 
    #  it in doing the bipartite network analyses too.

num_node_link_pairs = 2 * num_unique_edge_list
node_link_pairs = matrix (NA, 
                          nrow=num_node_link_pairs, 
                          ncol=2, 
                          byrow=TRUE
                          )

node_link_pairs = as.data.frame (node_link_pairs)
names (node_link_pairs) = c("node_ID", "link_ID")

# next_node_link_pair_row = 1
# 
# for (cur_link_ID in 1:num_unique_edge_list)
#     {
#     updated_links = 
#         add_link (node_link_pairs, 
#                   next_node_link_pair_row, 
#                   unique_edge_list [cur_link_ID, 1], 
#                   unique_edge_list [cur_link_ID, 2], 
#                   cur_link_ID)
#     
#     node_link_pairs = updated_links$node_link_pairs
#     
#     next_node_link_pair_row = updated_links$next_node_link_pair_row
#     }

next_PU_spp_pair_row = 1

for (cur_spp_ID in 1:num_unique_edge_list)
    {
#    node_link_pairs [next_PU_spp_pair_row, "PU_ID"] = unique_edge_list [cur_spp_ID, 1]  #  smaller_PU_ID
    node_link_pairs [next_PU_spp_pair_row, "node_ID"] = unique_edge_list [cur_spp_ID, 1]  #  smaller_PU_ID
#    node_link_pairs [next_PU_spp_pair_row, "spp_ID"] = cur_spp_ID  #  next_spp_ID
    node_link_pairs [next_PU_spp_pair_row, "link_ID"] = cur_spp_ID  #  next_spp_ID
    next_PU_spp_pair_row = next_PU_spp_pair_row + 1    
    
#    node_link_pairs [next_PU_spp_pair_row, "PU_ID"] = unique_edge_list [cur_spp_ID, 2]  #  larger_PU_ID
    node_link_pairs [next_PU_spp_pair_row, "node_ID"] = unique_edge_list [cur_spp_ID, 2]  #  larger_PU_ID
#    node_link_pairs [next_PU_spp_pair_row, "spp_ID"] = cur_spp_ID  #  next_spp_ID
    node_link_pairs [next_PU_spp_pair_row, "link_ID"] = cur_spp_ID  #  next_spp_ID
    next_PU_spp_pair_row = next_PU_spp_pair_row + 1
    }

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\n=====>>>>>  node_link_pairs = \n")
    print (node_link_pairs)
    cat ("\n\n")    
    }

#===============================================================================

