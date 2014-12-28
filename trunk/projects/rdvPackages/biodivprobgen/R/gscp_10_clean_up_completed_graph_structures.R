#===============================================================================

                #  gscp_10_clean_up_completed_graph_structures.R

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

