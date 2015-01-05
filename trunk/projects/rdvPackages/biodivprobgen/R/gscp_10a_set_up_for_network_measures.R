#===============================================================================

                #  gscp_10a_set_up_for_network_measures.R

#===============================================================================

    #  Network metric functions need to know how many spp and PUs as well as 
    #  their values and names.
    #  This is the first point in the code where we actually know this for 
    #  the species.  We knew it for PUs much earlier, but it's more coherent  
    #  to set both things up in the same place here.

num_PUs = tot_num_nodes
PU_vertex_indices = 1:num_PUs
PU_vertex_names = str_c ("p", PU_vertex_indices)

num_spp = num_unique_edge_list
spp_vertex_indices = 1:num_spp
spp_vertex_names = str_c ("s", spp_vertex_indices)

#===============================================================================

                    #  Code for using igraph package.

#===============================================================================

library (igraph)

vertices = data.frame (name=c(spp_vertex_names, PU_vertex_names), 
                       type=c(rep(FALSE, num_spp),
                              rep(TRUE, num_PUs)))

if (FALSE)
{

    #  Does igraph require me to rename the columns to say 
    #  "from" and "to instead of "PU_ID" and "spp_ID"?
# bg = graph.data.frame (edge_df, directed=FALSE, vertices=vertices)
bg = graph.data.frame (PU_spp_pair_indices, directed=FALSE, vertices=vertices)
}
#===============================================================================

                    #  Code for using bipartite package.

#===============================================================================

library (bipartite)

###  Build input matrix for bipartite package...

bpm = matrix (0, 
              #rep (0, num_spp*num_PUs), 
              nrow=num_spp, 
              ncol=num_PUs, 
              byrow=TRUE
                #  Not sure whether to have dimnames or not.  
                #  Doesn't seem to hurt anything at the moment...
              , 
              dimnames=list (spp_vertex_names, 
                             PU_vertex_names)
              )

for (edge_idx in 1:num_PU_spp_pairs)
    {
    cur_row = PU_spp_pair_indices [edge_idx, "spp_ID"]
    cur_col = PU_spp_pair_indices [edge_idx, "PU_ID"]
#    cat ("\ncur rc = [", cur_row, ", ", cur_col, "]")

        #  I'm making this be "1 + ..." instead of just "1", 
        #  in case at some point, I need to keep counts of 
        #  duplicates instead of just presence/absence.  
        #  With unique values, you get the same matrix 
        #  either way.
    bpm [cur_row, cur_col] = 1 + bpm [cur_row, cur_col]
    }

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nbpm = \n")
    print (bpm)
    cat ("\n\n")
    }

#===============================================================================

