#===============================================================================

                #  gscp_15_create_master_output_structure.R

#===============================================================================

#  Build a master table containing:
    #  planning unit ID
            #  marxan_best_df$PUID
    #  correct (optimal) answer (as boolean flags on sorted planning units)
    #  best marxan guess
            #  marxan_best_df$SOLUTION
    #  marxan number of votes for each puid
            #  marxan_ssoln_df$number
    #  difference between correct and best (i.e., (cor - best), FP, FN, etc)
    #  absolute value of difference (to make counting them easier)
    #  number of species on each patch (i.e., simple richness)

#  Need to bind together:
#   problem setup
#       - planning unit IDs (goes with all of these, even if they're split 
#         into separate tables)
#       - number of species (simple richness) on patch as counts
#   correct/optimal solution
#       - correct/optimal solution as 0/1
#   marxan solution(s)
#       - marxan best solution as 0/1
#       - marxan solution votes as counts
#   performance measure(s)
#       - difference between marxan best and optimal solution to represent 
#         error direction (e.g., FP, FN, etc.)
#       - abs (difference) to represent error or no error

    #  *** Need to be sure that the puid column matches in the nodes data frame 
    #  and the marxan data frames.  Otherwise, there could be a mismatch in 
    #  the assignments for inclusion or exclusion of patches in the solutions.

    #  Create table holding all the information to compare solutions.
signed_difference = marxan_best_df$SOLUTION - nodes$dependent_set_member
abs_val_signed_difference = abs (signed_difference)

solutions_df = data.frame (puid = marxan_best_df$PUID,
                           optimal_solution = nodes$dependent_set_member, 
                           marxan_best_solution = marxan_best_df$SOLUTION, 
                           marxan_votes = marxan_ssoln_df$number, 
                           signed_diff = signed_difference, 
                           abs_val_diff = abs_val_signed_difference, 
                           num_spp_on_patch = final_link_counts_for_each_node$freq
                           )

#  STILL NEED TO DO THIS
#       However, might be able to read these values from the marxan summary 
#       file that talks about missing values.  I'm just not sure how to 
#       tell which line in there corresponds to the "best" solution.
#
#       - marxan best solution % of species covered
#               - sum of number of uniques species in marxan best solution set
#                       - unique (select (species) where (puid in best solution))
#               - This suggests that there should be a function that computes 
#                 these values for ANY given solution.
#                         percentSppCovered = function (solutionAs01, sppPuidDB)
#                             {
#                             unique (select (species) where puids[which (solutionAs01==TRUE)])   
#                             }
#       - representation shortfall:  marxan best solution err fraction
#               - (1 - marxan best solution % of species covered)



#  Aggregate measures not in binding (may be computed From the bound data)

    #  correct/optimal number of patches (cost)
    #  This is also just the size of the dependent set...
#       - correct/optimal number of patches (cost)
#               - sum of 0/1 bits in correct solution
#                 Although, this is more directly available as the size of 
#                 the dependent set.  Still, it's more reusable to compute it 
#                 rather than assume the existance of a dependent set. 
cor_num_patches = sum (solutions_df$optimal_solution)
cat ("\n\ncor_num_patches =", cor_num_patches)

    #  marxan best solution number of patches (cost)
#       - marxan best solution number of patches (cost)
#               - sum of 0/1 bits in marxan solution
marxan_best_num_patches = sum (solutions_df$marxan_best_solution)
cat ("\nmarxan_best_num_patches =", marxan_best_num_patches)

    #  signed marxan best solution err fraction
#       - marxan best solution err fraction
#               - abs (1 - (correct/optimal number of patches - 
#                           marxan best solution number of patches))
marxan_best_solution_cost_err_frac = 
    (marxan_best_num_patches - cor_num_patches) / cor_num_patches
cat ("\nmarxan_best_solution_cost_err_frac =", marxan_best_solution_cost_err_frac)

    #  unsigned marxan best solution err fraction
abs_marxan_best_solution_cost_err_frac = 
    abs (marxan_best_solution_cost_err_frac)
cat ("\nabs_marxan_best_solution_cost_err_frac =", 
     abs_marxan_best_solution_cost_err_frac)

#       - marxan best solution % of species covered
#               - sum of number of uniques species in marxan best solution set
#                       - unique (select (species) where (puid in best solution))
#               - This suggests that there should be a function that computes 
#                 these values for ANY given solution.
#                         percentSppCovered = function (solutionAs01, sppPuidDB)
#                             {
#                             unique (select (species) where puids[which (solutionAs01==TRUE)])   
#                             }
#       - representation shortfall:  marxan best solution err fraction
#               - (1 - marxan best solution % of species covered)
marxan_best_solution_NUM_spp_covered = sum (marxan_mvbest_df$MPM)
marxan_best_solution_FRAC_spp_covered = marxan_best_solution_NUM_spp_covered / num_spp
spp_rep_shortfall = 1 - marxan_best_solution_FRAC_spp_covered

cat ("\n\nmarxan_best_solution_NUM_spp_covered =", marxan_best_solution_NUM_spp_covered)
cat ("\nmarxan_best_solution_FRAC_spp_covered =", marxan_best_solution_FRAC_spp_covered)
cat ("\nspp_rep_shortfall =", spp_rep_shortfall)

#===============================================================================

#  Supporting data not in binding
#   species vs planning units (database?) to allow computation of performance 
#   measures related to which species are covered in solutions
#   (e.g., SELECT species WHERE planning unit ID == curPlanningUnitID)
#   (e.g., SELECT planning unit ID WHERE species == curSpeciesID))
#       - planning unit IDs
#       - set of species on planning unit

#-------------------------------------------------------------------------------

num_runs = 1

results_df = 
    data.frame (run_ID = rep (NA, num_runs), 
                num_PUs = rep (NA, num_runs), 
                num_spp = rep (NA, num_runs), 
                seed = rep (NA, num_runs), 
                
                    #  Xu options
                n__num_groups = rep (NA, num_runs), 
                alpha__ = rep (NA, num_runs), 
                p__prop_of_links_between_groups = rep (NA, num_runs), 
                r__density = rep (NA, num_runs),

                    #  Results
                opt_solution_as_frac_of_tot_num_nodes = rep (NA, num_runs),
                cor_num_patches = rep (NA, num_runs),
                marxan_best_num_patches = rep (NA, num_runs), 
                abs_marxan_best_solution_cost_err_frac = rep (NA, num_runs), 
                marxan_best_solution_cost_err_frac = rep (NA, num_runs), 
                spp_rep_shortfall = rep (NA, num_runs),                
                marxan_best_solution_NUM_spp_covered = rep (NA, num_runs), 
                marxan_best_solution_FRAC_spp_covered = rep (NA, num_runs), 
                
                    #  Derived options
                num_nodes_per_group = rep (NA, num_runs),
                tot_num_nodes = rep (NA, num_runs),
                num_independent_set_nodes = rep (NA, num_runs),
                num_dependent_set_nodes = rep (NA, num_runs),
                num_rounds_of_linking_between_groups = rep (NA, num_runs),
                target_num_links_between_2_groups_per_round = rep (NA, num_runs), 
                num_links_within_one_group = rep (NA, num_runs),
                tot_num_links_inside_groups = rep (NA, num_runs),
                max_possible_num_links_between_groups = rep (NA, num_runs),
                max_possible_tot_num_links = rep (NA, num_runs), 
                
                    #  Marxan options
                marxan_spf_const = rep (NA, num_runs),
                marxan_PROP = rep (NA, num_runs),
                marxan_RANDSEED = rep (NA, num_runs),
                marxan_NUMREPS = rep (NA, num_runs),

                    #  Marxan Annealing Parameters
                marxan_NUMITNS = rep (NA, num_runs),
                marxan_STARTTEMP = rep (NA, num_runs),
                marxan_NUMTEMP = rep (NA, num_runs),

                    #  Marxan Cost Threshold
                marxan_COSTTHRESH = rep (NA, num_runs),
                marxan_THRESHPEN1 = rep (NA, num_runs),
                marxan_THRESHPEN2 = rep (NA, num_runs),

                    #  Marxan Program control
                marxan_RUNMODE = rep (NA, num_runs),
                marxan_MISSLEVEL = rep (NA, num_runs),
                marxan_ITIMPTYPE = rep (NA, num_runs),
                marxan_HEURTYPE = rep (NA, num_runs),
                marxan_CLUMPTYPE = rep (NA, num_runs)
                )

cur_result_row = 0

#-------------------------------------------------------------------------------

cur_result_row = cur_result_row + 1

#results_df$run_ID [cur_result_row]                                          = parameters$run_id
results_df$num_PUs [cur_result_row]                                          = num_PUs
results_df$num_spp [cur_result_row]                                          = num_spp
results_df$seed [cur_result_row]                                             = seed

    #  Xu options
results_df$n__num_groups [cur_result_row]                                   = n__num_groups
results_df$alpha__ [cur_result_row]                                          = alpha__
results_df$p__prop_of_links_between_groups [cur_result_row]                 = p__prop_of_links_between_groups
results_df$r__density [cur_result_row]                                       = r__density

    #  Results
results_df$opt_solution_as_frac_of_tot_num_nodes [cur_result_row]            = opt_solution_as_frac_of_tot_num_nodes
results_df$cor_num_patches [cur_result_row]                                  = cor_num_patches
results_df$marxan_best_num_patches [cur_result_row]                          = marxan_best_num_patches
results_df$abs_marxan_best_solution_cost_err_frac [cur_result_row]           = abs_marxan_best_solution_cost_err_frac
results_df$marxan_best_solution_cost_err_frac [cur_result_row]               = marxan_best_solution_cost_err_frac
results_df$spp_rep_shortfall [cur_result_row]                                = spp_rep_shortfall                
results_df$marxan_best_solution_NUM_spp_covered [cur_result_row]             = marxan_best_solution_NUM_spp_covered
results_df$marxan_best_solution_FRAC_spp_covered [cur_result_row]            = marxan_best_solution_FRAC_spp_covered

    #  Derived Xu options
results_df$num_nodes_per_group [cur_result_row]                             = num_nodes_per_group
results_df$tot_num_nodes [cur_result_row]                                    = tot_num_nodes
results_df$num_independent_set_nodes [cur_result_row]                        = num_independent_set_nodes
results_df$num_dependent_set_nodes [cur_result_row]                          = num_dependent_set_nodes
results_df$num_rounds_of_linking_between_groups [cur_result_row]            = num_rounds_of_linking_between_groups
results_df$target_num_links_between_2_groups_per_round [cur_result_row]     = target_num_links_between_2_groups_per_round
results_df$num_links_within_one_group [cur_result_row]                      = num_links_within_one_group
results_df$tot_num_links_inside_groups [cur_result_row]                     = tot_num_links_inside_groups
results_df$max_possible_num_links_between_groups [cur_result_row]           = max_possible_num_links_between_groups
results_df$max_possible_tot_num_links [cur_result_row]                       = max_possible_tot_num_links

    #  Marxan options
results_df$marxan_spf_const [cur_result_row]                                 = spf_const
results_df$marxan_PROP [cur_result_row]                                      = marxan_PROP
results_df$marxan_RANDSEED [cur_result_row]                                  = marxan_RANDSEED
results_df$marxan_NUMREPS [cur_result_row]                                   = marxan_NUMREPS

    #  Marxan Annealing Parameters
results_df$marxan_NUMITNS [cur_result_row]                                   = marxan_NUMITNS
results_df$marxan_STARTTEMP [cur_result_row]                                 = marxan_STARTTEMP
results_df$marxan_NUMTEMP [cur_result_row]                                   = marxan_NUMTEMP

    #  Marxan Cost Threshold
results_df$marxan_COSTTHRESH [cur_result_row]                                = marxan_COSTTHRESH
results_df$marxan_THRESHPEN1 [cur_result_row]                                = marxan_THRESHPEN1
results_df$marxan_THRESHPEN2 [cur_result_row]                                = marxan_THRESHPEN2

    #  Marxan Program control
results_df$marxan_RUNMODE [cur_result_row]                                   = marxan_RUNMODE
results_df$marxan_MISSLEVEL [cur_result_row]                                 = marxan_MISSLEVEL
results_df$marxan_ITIMPTYPE [cur_result_row]                                 = marxan_ITIMPTYPE
results_df$marxan_HEURTYPE [cur_result_row]                                  = marxan_HEURTYPE
results_df$marxan_CLUMPTYPE [cur_result_row]                                 = marxan_CLUMPTYPE


#  Getting an error.  Not sure why...  Is it because the free variable names 
#  like num_PUs, are the same as the list element names, like results_df$num_PUs?
#
#  Error in `$<-.data.frame`(`*tmp*`, "num_PUs", value = c(NA, 12L)) :  
#    replacement has 2 rows, data has 1 
#  Calls: source ... withVisible -> eval -> eval -> $<- -> $<-.data.frame 
#  Execution halted 


    #  Need to bind the network measures to the data frame too.

results_df = cbind (results_df, 
                    bipartite_metrics_from_bipartite_package, 
                    bipartite_metrics_from_igraph_package_df
                    )

    #  Write the results out to 2 separate and nearly identical files.
    #  The only difference between the two files is that the run ID in 
    #  one of them is always set to 0 and in the other, it's the correct 
    #  current run ID.  This is done to make it easier to automatically 
    #  compare the output csv files of different runs when the only thing 
    #  that should be different between the two runs is the run ID.  
    #  Having different run IDs causes diff or any similar comparison to 
    #  think that the run outputs don't match.  If they both have 0 run ID, 
    #  then diff's output will correctly flag whether there are differences 
    #  in the outputs.

results_df$run_ID [cur_result_row] = 0
write.csv (results_df, file = parameters$summary_without_run_id_filename, row.names = FALSE)

results_df$run_ID [cur_result_row] = parameters$run_id
write.csv (results_df, file = parameters$summary_filename, row.names = FALSE)

#===============================================================================

