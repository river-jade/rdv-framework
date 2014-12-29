#===============================================================================

                #  gscp_10_clean_up_completed_graph_structures.R

#===============================================================================

    #  All node pairs should be loaded into the linked_node_pairs table now 
    #  and there should be no NA lines left in the table.
    
    #  However no duplicate links are allowed, so need to go through all 
    #  node pairs and remove non-unique ones.

        #  NOTE:  I think that this unique() call only works if the 
        #           pairs are ordered within pair, i.e., if all from 
        #           nodes have a value less than or equal to the to value.
        #           That wouldn't be necessary if these were directed links, 
        #           but undirected, you couldn't recognize duplicates if 
        #           the order was allowed to occur both ways, i.e., (3,5) and 
        #           (5,3) would not be flagged as being duplicates.

unique_linked_node_pairs = unique (linked_node_pairs)  #  the edge list

num_non_unique_linked_node_pairs = dim (linked_node_pairs)[1]
num_unique_linked_node_pairs = dim (unique_linked_node_pairs)[1]

cat ("\n\nnum_non_unique_linked_node_pairs =", num_non_unique_linked_node_pairs)
cat ("\nnum_unique_linked_node_pairs =", num_unique_linked_node_pairs)
cat ("\n")

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
    #  However, there is one other useful byproduct of building this table.
    #  It makes it easy to compute rank-abundance information and information 
    #  about the distribution of species across patches.

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

