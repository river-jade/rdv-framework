#===============================================================================

                        #  gscp_9a_create_Xu_graph.R

#===============================================================================

    #  BTL - 2015 02 25 - Temporary testing code for tzar's rrunner.R
    #
    #  The following couple of lines were used to test the new version of the 
    #  rrunner.R code in tzar.  
    #  The changes there were done to improve the output when your R code 
    #  crashes while running tzar, e.g., to generate a traceback.
    #  The first line here was just to make the rrunner generate a warning.
    #  The second was to make it generate a fatal error and crash the program.
    #  I'm going to leave these in here in case I need to go back and test 
    #  rrunner crash behavior under tzar again later.

#  This should warn...
#kkkkk = log (-1)

#  This should crash...
#aaaaa = bbbbb

#===============================================================================


default_integerize_string = "round"
integerize_string = default_integerize_string

integerize_string = parameters$integerize_string

#integerize_string = "round"
#integerize_string = "ceiling"
#integerize_string = "floor"

integerize = switch (integerize_string, 
                     round=round, 
                     ceiling=ceiling, 
                     floor=floor, 
                     round)    #  default to round()

# integerize = function (x) 
#     { 
#     round (x) 
# #    ceiling (x)
# #    floor (x)
#     }

#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "gscp_5_derive_control_parameters.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_6_create_data_structures.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_8_link_nodes_within_groups.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_9_link_nodes_between_groups.R"))

#===============================================================================

timepoints_df = 
    timepoint (timepoints_df, "gscp_9a_create_Xu_graph", 
               "Starting gscp_9a_create_Xu_graph.R")

#===============================================================================

sort_within_rows = function (a_2_col_matrix, decreasing=FALSE)
    {
    for (row in 1:dim(a_2_col_matrix)[1])
        {
        a_2_col_matrix [row,] = sort (a_2_col_matrix [row,], decreasing)
        }
    
    return (a_2_col_matrix)
    }

#===============================================================================

create_Xu_graph = function (num_nodes_per_group, 
                            n__num_groups, 
                            nodes, 
                            max_possible_tot_num_links, 
                            target_num_links_between_2_groups_per_round, 
                            num_rounds_of_linking_between_groups, 
                            duplicate_links_allowed=FALSE
                            )
    {
    edge_list = matrix (NA, 
                        nrow = max_possible_tot_num_links, 
                        ncol = 2, 
                        byrow = TRUE)

    #---------------------------------------------------------------------------
    
    timepoints_df = 
        timepoint (timepoints_df, "gscp_9a_create_Xu_graph", 
                   "Starting link_nodes_within_groups.R")


    edge_list_and_cur_row = 
        link_nodes_within_groups (num_nodes_per_group, 
                                  n__num_groups, 
                                  nodes, 
                                  edge_list)

    #---------------------------------------------------------------------------
    
    timepoints_df = 
        timepoint (timepoints_df, "gscp_9a_create_Xu_graph", 
                   "Starting link_nodes_between_groups")

#    edge_list_and_cur_row = 
    edge_list = 
        link_nodes_between_groups (target_num_links_between_2_groups_per_round, 
                                   num_rounds_of_linking_between_groups, 
                                   n__num_groups, 
                                   nodes, 
                                   edge_list_and_cur_row$edge_list, 
                                   edge_list_and_cur_row$cur_row)
    
    #---------------------------------------------------------------------------

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
            #           nodes have a "from" value less than or equal to the "to"
            #           value.
            #           That wouldn't be necessary if these were directed links, 
            #           but undirected, you couldn't recognize duplicates if 
            #           the order was allowed to occur both ways, i.e., (3,5) and 
            #           (5,3) would not be flagged as being duplicates.

    if (! duplicate_links_allowed)
        {
            #  Sort each of the rows to be sure that from-to pairs are in 
            #  sorted order.  They're probably already in sorted order, 
            #  but this is safer (e.g., in case the earlier code changes 
            #  or I am wrong in my assumption about them already being sorted).
        
        edge_list = sort_within_rows (edge_list)  #  be sure pairs are sorted
        num_non_unique_edge_list = dim (edge_list)[1]

        edge_list = unique (edge_list)        
        num_unique_edge_list = dim (edge_list)[1]
        
        if (DEBUG_LEVEL > 0)
            {
            cat ("\n\nnum_non_unique_edge_list =", num_non_unique_edge_list)
            cat ("\nnum_unique_edge_list =", num_unique_edge_list)
            cat ("\n")    
            }
        }

    
#    return (edge_list_and_cur_row)
    return (edge_list)
    }

#===============================================================================

