#===============================================================================

                #  gscp_10c_build_adj_and_cooccurrence_matrices.R

#===============================================================================

timepoints_df = 
    timepoint (timepoints_df, "gscp_10c", 
               "Starting gscp_10c_build_adj_and_cooccurrence_matrices.R")

#===============================================================================

#  History:

#  2015 02 19 - BTL
#       Created by cutting creation of adj matrix out of 
#       gscp_11a_network_measures_using_bipartite_package.R.

#===============================================================================

###  Build input matrix for bipartite package...

cat ("\n\nAbout to create bpm matrix.")

create_adj_matrix_with_spp_rows_vs_PU_cols = 
    function (num_spp, 
              num_PUs, 
              spp_vertex_names, 
              PU_vertex_names, 
              num_PU_spp_pairs, 
              PU_spp_pair_indices, 
              edge_idx, 
              spp_col_name, 
              PU_col_name) 
    {
        #  Create the adjacency matrix that will be viewed as a 
        #  bipartite matrix (bpm) by the bipartite network routines 
        #  with species as rows and planning units as columns.
    bpm = matrix (0, 
                  nrow=num_spp, 
                  ncol=num_PUs, 
                  byrow=TRUE
                  
                      #  Not sure whether to have dimnames or not.  
                      #  Doesn't seem to hurt anything at the moment...
                  , 
                  dimnames=list (spp_vertex_names, 
                                 PU_vertex_names)
                  )
    
    cat ("\n\nAbout to fill in bpm matrix.")
    
    for (edge_idx in 1:num_PU_spp_pairs)
        {
        cur_row = PU_spp_pair_indices [edge_idx, spp_col_name]
        cur_col = PU_spp_pair_indices [edge_idx, PU_col_name]
        
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
    
    return (bpm)
    }

bpm = 
    create_adj_matrix_with_spp_rows_vs_PU_cols (num_spp,                                                 
                                                  num_PUs, 
                                                  spp_vertex_names, 
                                                  PU_vertex_names, 
                                                  num_PU_spp_pairs, 
                                                  PU_spp_pair_indices, 
                                                  edge_idx, 
                                                  spp_col_name, 
                                                  PU_col_name) 

#===============================================================================

    #  Verify that the the generated optimal solution really is a solution.
    #  Theoretically, this should not be necessary, but checking it here to 
    #  make sure that the implementation is working correctly.
    #  Correct solutions will have every species attaining a representation 
    #  fraction of their target of at least 1 (where 1 means exactly meeting 
    #  their target).

spp_rep_targets = rep (1, num_spp)
spp_rep_fracs = compute_rep_fraction (bpm, 
                                      dependent_node_IDs, 
                                      spp_rep_targets)
stopifnot (spp_rep_fracs >= 1)

solution_cost = compute_solution_cost (dependent_node_IDs, rep (1, num_PUs))
#browser()
stopifnot (all.equal (solution_cost, length (dependent_node_IDs)))

    #  If an error message needs to be written too, then one of these 
    #  might be a more appropriate call.
#assertError(expr, verbose = FALSE)
#assertWarning(expr, verbose = FALSE)
#assertCondition(expr, ..., .exprString = , verbose = FALSE)
#warning(..., call. = TRUE, immediate. = FALSE, noBreaks. = FALSE,
#        domain = NULL)
#stop(..., call. = TRUE, domain = NULL)

#===============================================================================

