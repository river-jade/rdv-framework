#===============================================================================

setwd ("/Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R")

#===============================================================================

integerize = function (x) 
    { 
    round (x) 
#    ceiling (x)
#    floor (x)
    }

#===============================================================================

cat ("\n\n0 ")

# n_values = c (10, 20, 50, 100, 200, 500)
# alpha_values = seq (0.5, 3.0, 0.5)
# r_values = seq (0.25, 1.0, 0.25)
# p_values = seq (0.25, 1.0, 0.25)

# n_values = c (100)
# alpha_values = seq (1.0)
# r_values = seq (0.1)
# p_values = seq (0.1)  

# n_values = c (20)
# alpha_values = seq (0.1, 1.0, 0.2)
# r_values = seq (0.25, 1.0, 0.25)
# p_values = seq (0.25, 1.0, 0.25)

# n_values = c (30)
# alpha_values = seq (0.1, 1.0, 0.2)
# r_values = seq (0.25, 1.0, 0.25)
# p_values = seq (0.25, 1.0, 0.25)

n_values = c (40)
alpha_values = seq (0.1, 1.0, 0.2)
r_values = seq (0.25, 1.0, 0.25)
p_values = seq (0.25, 1.0, 0.25)

num_n     = length (n_values)
num_alpha = length (alpha_values)
num_r     = length (r_values)
num_p     = length (p_values)

num_runs = num_n * num_alpha * num_r * num_p

results_df = 
    data.frame (run_ID = rep (NA, num_runs), 
                
                num_PUs = rep (NA, num_runs), 
                num_spp = rep (NA, num_runs), 
                
                    #  Xu options
                n__num_cliques = rep (NA, num_runs), 
                alpha__ = rep (NA, num_runs), 
                p__prop_of_links_between_cliques = rep (NA, num_runs), 
                r__density = rep (NA, num_runs),

                    #  Derived options
                opt_solution_as_frac_of_tot_num_nodes = rep (NA, num_runs),
                num_nodes_per_clique = rep (NA, num_runs),
                tot_num_nodes = rep (NA, num_runs),
                num_independent_set_nodes = rep (NA, num_runs),
                num_dependent_set_nodes = rep (NA, num_runs),
                num_rounds_of_linking_between_cliques = rep (NA, num_runs),
                target_num_links_between_2_cliques_per_round = rep (NA, num_runs), 
                num_links_within_one_clique = rep (NA, num_runs),
                tot_num_links_inside_cliques = rep (NA, num_runs),
                max_possible_num_links_between_cliques = rep (NA, num_runs),
                max_possible_tot_num_links = rep (NA, num_runs), 
                max_possible_tot_num_node_link_pairs = rep (NA, num_runs)
                )

cur_result_row = 0

#===============================================================================

# n__num_cliques                   = 12
# alpha__                          = 1.5
# p__prop_of_links_between_cliques = 0.3  
# r__density                       = 0.8
        
#-------------------------------------------------------------------------------

for (n__num_cliques in n_values)
{
for (alpha__ in alpha_values)
{
for (r__density in r_values)
{
for (p__prop_of_links_between_cliques in p_values)
{
        #  Derived control parameters.

#    cat ("\n\n--------------------  Building derived control parameters.\n")

# n__num_cliques = 100
# alpha__ = 1.0
# r__density = 0.1
# p__prop_of_links_between_cliques = 0.1    
    
    num_nodes_per_clique = integerize (n__num_cliques ^ alpha__)
    tot_num_nodes = n__num_cliques * num_nodes_per_clique

    num_independent_set_nodes = n__num_cliques
    num_dependent_set_nodes = tot_num_nodes - num_independent_set_nodes
    opt_solution_as_frac_of_tot_num_nodes = 
        num_dependent_set_nodes / tot_num_nodes
    
    num_rounds_of_linking_between_cliques = 
        integerize (r__density * n__num_cliques * log (n__num_cliques))
    
    target_num_links_between_2_cliques_per_round = 
        integerize (p__prop_of_links_between_cliques * num_nodes_per_clique)
    
    num_links_within_one_clique = choose (num_nodes_per_clique, 2)
    tot_num_links_inside_cliques = n__num_cliques * num_links_within_one_clique
    
    max_possible_num_links_between_cliques = 
        integerize (target_num_links_between_2_cliques_per_round * num_rounds_of_linking_between_cliques)
    
    max_possible_tot_num_links = integerize (tot_num_links_inside_cliques + max_possible_num_links_between_cliques)
    max_possible_tot_num_node_link_pairs = 2 * max_possible_tot_num_links

    num_PUs = tot_num_nodes
    num_spp = max_possible_tot_num_links

#===============================================================================

cur_result_row = cur_result_row + 1

if (cur_result_row %% 50) cat (".") else cat ("\n", cur_result_row, ".")


results_df$run_ID [cur_result_row]                                           = cur_result_row

results_df$num_PUs [cur_result_row]                                          = num_PUs
results_df$num_spp [cur_result_row]                                          = num_spp

    #  Xu options
results_df$n__num_cliques [cur_result_row]                                   = n__num_cliques
results_df$alpha__ [cur_result_row]                                          = alpha__
results_df$p__prop_of_links_between_cliques [cur_result_row]                 = p__prop_of_links_between_cliques
results_df$r__density [cur_result_row]                                       = r__density

    #  Derived Xu options
results_df$opt_solution_as_frac_of_tot_num_nodes [cur_result_row]            = opt_solution_as_frac_of_tot_num_nodes
results_df$num_nodes_per_clique [cur_result_row]                             = num_nodes_per_clique
results_df$tot_num_nodes [cur_result_row]                                    = tot_num_nodes
results_df$num_independent_set_nodes [cur_result_row]                        = num_independent_set_nodes
results_df$num_dependent_set_nodes [cur_result_row]                          = num_dependent_set_nodes
results_df$num_rounds_of_linking_between_cliques [cur_result_row]            = num_rounds_of_linking_between_cliques
results_df$target_num_links_between_2_cliques_per_round [cur_result_row]     = target_num_links_between_2_cliques_per_round
results_df$num_links_within_one_clique [cur_result_row]                      = num_links_within_one_clique
results_df$tot_num_links_inside_cliques [cur_result_row]                     = tot_num_links_inside_cliques
results_df$max_possible_num_links_between_cliques [cur_result_row]           = max_possible_num_links_between_cliques
results_df$max_possible_tot_num_links [cur_result_row]                       = max_possible_tot_num_links
results_df$max_possible_tot_num_node_link_pairs [cur_result_row]             = max_possible_tot_num_node_link_pairs

}  #  end for - p_values
    
}  #  end for - r_values
    
}  #  end for - alpha_values
    
}  #  end for - n_values

plot (results_df)


#write.csv (results_df, file = "./prob_diff_results.csv", row.names = FALSE)
write.csv (results_df, file = "./all_param_combinations.csv", row.names = FALSE)

#===============================================================================

