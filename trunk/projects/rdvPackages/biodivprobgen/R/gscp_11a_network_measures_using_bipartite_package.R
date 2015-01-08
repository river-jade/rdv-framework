#===============================================================================

            #  gscp_11a_network_measures_using_bipartite_package.R

#===============================================================================

                    #  Code for using bipartite package.

#===============================================================================

timepoints_df = 
    timepoint (timepoints_df, "gscp_11a", 
               "Starting gscp_11a_network_measures_using_bipartite_package.R")

#===============================================================================

library (bipartite)

#===============================================================================

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
#     cur_row = PU_spp_pair_indices [edge_idx, "spp_ID"]
#     cur_col = PU_spp_pair_indices [edge_idx, "PU_ID"]
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

all_except_slow_indices <- 
    c(
        "number of species", 
        "connectance", 
        "web asymmetry", 
        "links per species", 
#           "number of compartments",           #  #6a slowest ("calls a recursive and hence relatively slow algorithm.") 
#           "compartment diversity",            #  #6b slowest ("calls a recursive and hence relatively slow algorithm.")
        "cluster coefficient", 
#            "degree distribution",              #  #3 slowest ("somewhat time consuming")
        "mean number of shared partners", 
        "togetherness", 
        "C score", 
        "V ratio", 
#            "discrepancy",                      #  #7c slowest ("excluding discrepancy can also moderately decrease computation time")
#            "nestedness",                       #  #5a slowest ("not the fastest of routines")
#            "weighted nestedness",              #  #5b slowest ("not the fastest of routines")
        "ISA", 
        "SA", 
#            "extinction slope",                 #  #1a slowest
#            "robustness",                       #  #1b slowest 
        "niche overlap", 
#            "weighted cluster coefficient",     #  #2 slowest
        "weighted NODF", 
        "partner diversity", 
        "generality", 
        "vulnerability", 
        "linkage density", 
        "weighted connectance", 
#            "Fisher alpha",                     #  #4 slowest ("computed iteratively and hence time consuming")
        "interaction evenness", 
        "Alatalo interaction evenness", 
        "Shannon diversity", 
        "functional complementarity" 
)
#            , "H2                                 #  #7a slowest ("require an iterative, heuristic search algorithm", #7b - same for specialisation asymmetry but it's not in this list)
#        )


    bipartite_metrics_from_bipartite_package <- 
# #         t (networklevel (bpm, index=c ("links per species",
# #                                      "H2",
# #                                      "interaction evenness")))
    
                #  BTL - 2015 01 07
                #  On a small network, ALLBUTDD took a miniscule amount 
                #  of extra time compared to all_except_slow_indices, 
                #  so I'm going to use ALLBUTDD for now.  If bigger 
                #  networks show this is too slow, then can revert to 
                #  using all_except_slow_indices.
         t (networklevel (bpm, index=all_except_slow_indices))
#        t (networklevel (bpm, index="ALLBUTDD"))

cat ("\n\nbipartite_metrics_from_bipartite_package = \n")
print (bipartite_metrics_from_bipartite_package)

    #  Clean up metric names...
    #  
    #  The bipartite metrics output has spaces in some of the metric names. 
    #  This can cause problems sometimes for downstream uses of the output, so 
    #  you need to replace the spaces with something other than white space.  
    #  Here, I'll replace them with underscores.  Some of the metrics already 
    #  use periods instead of spaces, but I won't mess with those for now in 
    #  case it helps match them up with some other expectation from a paper or 
    #  something.

library (stringr)

metrics_col_names = colnames (bipartite_metrics_from_bipartite_package)  
cat ("\n\nmetrics_col_names = \n")
print (metrics_col_names)

new_metrics_col_names = 
    str_replace_all (string=metrics_col_names, pattern=" ", repl="_")
cat ("\n\nnew_metrics_col_names = \n")
print (new_metrics_col_names)
cat ("\n\n")

colnames (bipartite_metrics_from_bipartite_package) = new_metrics_col_names

cat ("\n\nbipartite_metrics_from_bipartite_package with spaces removed from column names = \n")
print (bipartite_metrics_from_bipartite_package)
cat ("\n\n")

#===============================================================================

