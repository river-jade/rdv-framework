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

    #  Convert edge list to PU/spp table to give to Marxan and to network 
    #  functions for bipartite networks:
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

num_PU_spp_pairs = 2 * num_unique_edge_list

        #  BTL - 2015 01 07
        #  Later in this file, I also create a data frame that uses the names 
        #  of these pairs rather than their indices.  
        #  Though the two data frames carry identical information, it looks 
        #  like both of them are necessary because different network packages 
        #  expect different inputs.  
        #  The bipartite package creates an adjacency matrix based on the 
        #  indices, but the igraph package creates a bipartite graph using 
        #  either the indices or the vertex names.  However, if I'm going to 
        #  use the vertex indices, I need to go back and renumber either the 
        #  spp vertices or the PU vertices so that they don't overlap the 
        #  other set.  That may end up being the better strategy when graphs 
        #  get big, but at the moment, giving them names seems less likely 
        #  to introduce some kind of indexing bug.
        
PU_spp_pair_indices = data.frame (PU_ID = rep (NA, num_PU_spp_pairs),
                                  spp_ID = rep (NA, num_PU_spp_pairs))

PU_col_name = names (PU_spp_pair_indices)[1]
spp_col_name = names (PU_spp_pair_indices)[2]

next_PU_spp_pair_row = 1

for (cur_spp_ID in 1:num_unique_edge_list)
    {
    PU_spp_pair_indices [next_PU_spp_pair_row, PU_col_name] = unique_edge_list [cur_spp_ID, 1]  #  smaller_PU_ID
    PU_spp_pair_indices [next_PU_spp_pair_row, spp_col_name] = cur_spp_ID  #  next_spp_ID    
    next_PU_spp_pair_row = next_PU_spp_pair_row + 1    
    
    PU_spp_pair_indices [next_PU_spp_pair_row, PU_col_name] = unique_edge_list [cur_spp_ID, 2]  #  larger_PU_ID
    PU_spp_pair_indices [next_PU_spp_pair_row, spp_col_name] = cur_spp_ID  #  next_spp_ID
    next_PU_spp_pair_row = next_PU_spp_pair_row + 1
    }

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\n=====>>>>>  PU_spp_pair_indices = \n")
    print (PU_spp_pair_indices)
    cat ("\n\n")    
    }

#===============================================================================

    #  Network metric functions need to know how many spp and PUs as well as 
    #  their values and names.
    #  This is the first point in the code where we actually know this for 
    #  the species.  We knew it for PUs much earlier, but it's more coherent  
    #  to set both things up in the same place here.
    #
    #  Will create names for PU vertices by prepending the vertex ID with a "p".
    #  Similarly, spp vertices will be named by prepending with an "s".
    #  Note that we have to either uniquely name the vertices or we have to  
    #  renumber either the spp or the PUs.  This is because the numbering of 
    #  both sets of vertices starts at 1 and that means the vertex IDs are 
    #  not unique when the two sets are combined.  

#browser()

cat ("\n\nAbout to compute num_PUs and num_spp...")

num_PUs = tot_num_nodes
PU_vertex_indices = 1:num_PUs
PU_vertex_names = str_c ("p", PU_vertex_indices)

num_spp = num_unique_edge_list
spp_vertex_indices = 1:num_spp
spp_vertex_names = str_c ("s", spp_vertex_indices)

cat ("\n\nDone computing num_PUs and num_spp...")

PU_spp_pair_names = 
    data.frame (PU_ID = str_c ("p", PU_spp_pair_indices [,PU_col_name]),
                spp_ID = str_c ("s", PU_spp_pair_indices [,spp_col_name]), 
                stringsAsFactors = FALSE)

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\n=====>>>>>  PU_spp_pair_names = \n")
    print (PU_spp_pair_names)
    cat ("\n\n")    
    }

#===============================================================================

