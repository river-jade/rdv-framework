#===============================================================================

                        #  gscp_5_derive_control_parameters.R

#===============================================================================

    #  NOTE:  The runif() documentation says:
    #           "runif will not generate either of the extreme values unless 
    #            max = min or max-min is small compared to min, and in 
    #            particular not for the default arguments."

n__num_groups = parameters$n__num_groups    
if (parameters$use_unif_rand_n__num_groups)
    {
    n__num_groups = 
        integerize (runif (1, 
                           min = parameters$n__num_groups_lower_bound,
                           max = parameters$n__num_groups_upper_bound
                           ))
    }

alpha__ = parameters$alpha__
if (parameters$use_unif_rand_alpha__)
    {
    alpha__ = runif (1, 
                     min = parameters$alpha___lower_bound,
                     max = parameters$alpha___upper_bound
                     )
    }

p__prop_of_links_between_groups = parameters$p__prop_of_links_between_groups
if (parameters$use_unif_rand_p__prop_of_links_between_groups)
    {
    p__prop_of_links_between_groups = 
        runif (1, 
               min = parameters$p__prop_of_links_between_groups_lower_bound,
               max = parameters$p__prop_of_links_between_groups_upper_bound
               )
    }

r__density = parameters$r__density
if (parameters$use_unif_rand_r__density)
    {
    r__density = runif (1, 
                        min = parameters$p__r__density_lower_bound,
                        max = parameters$p__r__density_upper_bound
                        )
    }

#--------------------

    #  2014 12 11 - BTL - Adding to the original set of parameters
    #  Originally, there was only 1 independent node per group.  
    #  I'm going to try allowing more than that to see if it will still 
    #  build hard problems but allow the size of the solution set to drop 
    #  below 50% of the node set.

num_independent_nodes_per_group = 1

#-------------------------------------------------------------------------------

    #  Derived control parameters.

cat ("\n\n--------------------  Building derived control parameters.\n")

    #  Originally, this parameter was set assuming that there was only 
    #  1 independent node per group.  
    #  Now allowing there to be more than 1, so need to add to the 
    #  number of nodes per group.  However, we only want to add the 
    #  the excess independent nodes that are beyond the original 1, 
    #  so we have to subtract 1 from the number we're adding on.

    #    num_nodes_per_group = integerize (n__num_groups ^ alpha__)
num_nodes_per_group = integerize (n__num_groups ^ alpha__) - 
                      (num_independent_nodes_per_group - 1)

    #    num_independent_set_nodes = n__num_groups
num_independent_set_nodes = n__num_groups * num_independent_nodes_per_group

tot_num_nodes = n__num_groups * num_nodes_per_group

num_dependent_set_nodes = tot_num_nodes - num_independent_set_nodes
opt_solution_as_frac_of_tot_num_nodes = 
    num_dependent_set_nodes / tot_num_nodes

num_rounds_of_linking_between_groups = integerize (r__density * n__num_groups * log (n__num_groups))

    #  Is this right?  Even in the old version?  
    #  i.e., this count would allow links to ind. nodes too.
    #  Should it be "* num_dependent_nodes_per_group" instead of 
    #  "* num_nodes_per_group"?
    #  How is it defined in Xu?
    #  The interlinking code DOES make a check though and only allows 
    #  linking to dependent nodes.  
    #  The only thing that the code here seems like it would do is to 
    #  overallocate space.
    #  One weird thing though is that if you only have one dependent node, 
    #  how is a proportion of 0.2x going to cause anything at all to be 
    #  interlinked - unless, the integerize function is always giving a 
    #  value of at least 1?  But integerize() is currently round() and 
    #  with 2 nodes per group (to get  things down to 50% as the solution 
    #  fraction), anything less than p=0.5 should yield no interlinking?
    #  Actually, with rounding and 2 nodes per group, anything >= 0.25 will 
    #  yield at least one interlink.  So, should I just leave this alone?  
    #  Still, it's going to get very weird (and blow up?) if you have 
    #  4 or 5 independent nodes in a group and only 1 dependent node 
    #  because this is going to tell you that you have to have something 
    #  like p=0.3 times 5 or 6 instead of times 2.  That would lead to 
    #  many duplicate links, but does that really matter?  Seems like it 
    #  would in a predictive sense, i.e., the value assigned to p would 
    #  not have the same meaning in these lower bound saturating kinds of 
    #  circumstances compared to when there larger values that it could 
    #  take a real proportion of.  Even in the old version, there will be 
    #  an odd threshold effect in what p means, e.g., when it falls below 
    #  0.25 in the example above.  Still, isn't that always going to be the 
    #  case because the theory uses continuous values but the problem sizes 
    #  have to be integers and you will always have to map from continuous 
    #  to integer?
    #  Maybe the best solution here is to create an option that allows you 
    #  to choose the behavior you want and records that in the output.
    #  What would be the possible variants of this option?
    #  Compute target... from:
    #       a) num_nodes_per_group
    #       b) num_dependent_nodes_per_group
    #       c) at least 1, 
    #               i.e., max (1, [a or b above]) so that you always 
    #               get at least 1
    #  So, option c) would mean that you need two options instead of 1, 
    #  i.e., [a) or b)] and [max or actual value].  
    #  Another thing that should probably be an option is the choice of the 
    #  integerize function, since that also affects this.

base_for_target_num_links_between_2_groups_per_round = 
    parameters$base_for_target_num_links_between_2_groups_per_round

at_least_1_for_target_num_links_between_2_groups_per_round = 
    parameters$at_least_1_for_target_num_links_between_2_groups_per_round

target_num_links_between_2_groups_per_round = 
    integerize (p__prop_of_links_between_groups * num_nodes_per_group)  



    #  Compute how many links there will be within each group.  
    #  If there is more than one independent node, then not all possible 
    #  combinations of links will be made.  Have to subtract off 
    #  the number of possible links between independent nodes in 
    #  the group.
#    num_links_within_one_group = choose (num_nodes_per_group, 2)
num_links_within_one_group = choose (num_nodes_per_group, 2) - 
                             choose (num_independent_nodes_per_group, 2)

tot_num_links_inside_groups = n__num_groups * num_links_within_one_group

max_possible_num_links_between_groups = 
    integerize (target_num_links_between_2_groups_per_round * num_rounds_of_linking_between_groups)

max_possible_tot_num_links = integerize (tot_num_links_inside_groups + max_possible_num_links_between_groups)
max_possible_tot_num_node_link_pairs = 2 * max_possible_tot_num_links

cat ("\n\nInput variable settings")
cat ("\n\t\t n__num_groups = ", n__num_groups)
cat ("\n\t\t alpha__ = ", alpha__)
cat ("\n\t\t p__prop_of_links_between_groups = ", p__prop_of_links_between_groups)
cat ("\n\t\t r__density = ", r__density)

cat ("\n\nDerived variable settings")
cat ("\n\t\t num_nodes_per_group = ", num_nodes_per_group)
cat ("\n\t\t num_rounds_of_linking_between_groups = ", num_rounds_of_linking_between_groups)
cat ("\n\t\t target_num_links_between_2_groups_per_round = ", target_num_links_between_2_groups_per_round)
cat ("\n\t\t num_links_within_one_group = ", num_links_within_one_group)
cat ("\n\t\t tot_num_links_inside_groups = ", tot_num_links_inside_groups)
cat ("\n\t\t max_possible_num_links_between_groups = ", max_possible_num_links_between_groups)
cat ("\n\t\t max_possible_tot_num_links = ", max_possible_tot_num_links)
cat ("\n\t\t max_possible_tot_num_node_link_pairs = ", max_possible_tot_num_node_link_pairs)
cat ("\n\n")

#===============================================================================

    #  BTL - 2015 01 08
    #  
    #  Having problems with problem dimensions on some runs being either 
    #  too small and forcing array sizes of 0 or being too big and forcing 
    #  problems that are much larger than are relevant for biodiversity or 
    #  that just take too long to run in the current experimental setting.  
    #  For example, things can run for 6 or more hours when I want them to 
    #  be taking on the order of minutes instead of hours.  I may eventually 
    #  want to go ahead with these kinds of big runs, but for now, I want to 
    #  cut them down to be no larger than the biggest number of species 
    #  that I'm aware of in biodiversity problems.  At the moment, the 
    #  biggest ones that I know of have done around 2000 species.  
    #  The number of planning units has not been a problem yet since they 
    #  have been far less than the number of species.  They're also easier 
    #  to control through the choice of the number of groups, etc.  

#-------------------------------------------------------------------------------

    #  "Too small" problem
    #
    #  Running under tzar, this code crashes when it tries to allocate 
    #  arrays of size 0 and tzar marks that crash by renaming the output 
    #  directory to end in ".failed".  This is good enough for what I"m 
    #  doing because it tells me to skip over the directory in compiling 
    #  results and no harm is done.  I could imagine doing something fancier 
    #  and trying to choose a new set of parameters, but how to choose them 
    #  would be different for different situations (e.g., when they're being 
    #  generated randomly vs. single experiments where one specific 
    #  configuration is being tested).  Also, changing the input parameters 
    #  would have to mean also modifying the input yaml file if the yaml 
    #  was to be a reproducible and correct reflection of the parameters 
    #  used to do the experiment.  So, I think that what I'll do instead 
    #  is just make the failure be slightly more graceful by checking for 
    #  0 array sizes and giving an error message about it to the log file 
    #  before quitting.  
    #
    #  The one other issue here is that I could try to write out the various 
    #  results data frames with some kind of indicator that the run failed 
    #  so that they could still be read when all good results data frames 
    #  are collected.  That might be useful in providing information about 
    #  what parameter ranges end up being out of bounds or were not sampled 
    #  when trying to learn prediction functions.  However, it would end up 
    #  requiring more specialized code in the collection routines to deal 
    #  with failed runs instead of just being able to assume all went well.  
    #  At this point, simpler code seems like a bigger benefit than the 
    #  small amount of added and seldom-used information about failures, so 
    #  I'm going with the simpler solution here for now.  

# if ((num_links_within_one_group < 1) | (tot_num_links_inside_groups < 1))
#     {
#     too_small_failure_msg = 
#         paste0 ("\n\nFailing:  num_links_within_one_group (", 
#                 num_links_within_one_group, 
#                 ") < 1  OR  tot_num_links_inside_groups (", 
#                 tot_num_links_inside_groups, 
#                 ") < 1.\n\n")
#     quit (too_small_failure_msg, status=1)
#     }

if ((num_links_within_one_group < 1) | (tot_num_links_inside_groups < 1))
    {
    cat ("\n\nFailing:  num_links_within_one_group (", 
         num_links_within_one_group, 
         ") < 1  OR  tot_num_links_inside_groups (", 
         tot_num_links_inside_groups, 
         ") < 1.\n\n")
    quit (status=1)
    }

#-------------------------------------------------------------------------------

    #  "Too big" problem
    #
    #  I'm going to use the same reasoning about simplicity to decide here 
    #  to just pick a "too big" level and fail any job that hits it.  
    #  However, I'll make the "too big" threshold an input variable so that 
    #  it's easy to change.  I will also choose to set the threshold on 
    #  the maximum POSSIBLE number of links rather than the maximum realized 
    #  unique links because the actual number of links (species) isn't known  
    #  until the problem has been fully built and we can skip running that 
    #  generative code this way.

# if (max_possible_tot_num_links > parameters$max_allowed_possible_tot_num_links)
#     {
#     too_big_failure_msg = 
#         paste0 ("\n\nFailing:  max_possible_tot_num_links (", 
#                 max_possible_tot_num_links, 
#                 ") > maximum allowed (", 
#                 parameters$max_allowed_possible_tot_num_links, 
#                 ").\n\n")
#     quit (too_big_failure_msg, status=1)
#     }

if (max_possible_tot_num_links > parameters$max_allowed_possible_tot_num_links)
    {
    cat ("\n\nFailing:  max_possible_tot_num_links (", 
         max_possible_tot_num_links, ") > maximum allowed (", 
         parameters$max_allowed_possible_tot_num_links, 
         ").\n\n")
    quit (status=1)
    }

#===============================================================================

