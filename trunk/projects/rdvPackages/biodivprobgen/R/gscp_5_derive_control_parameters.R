#===============================================================================

                        #  gscp_5_derive_control_parameters.R

#===============================================================================

# derive_control_parameters = 
#     function (n__num_groups = 3, 
#               alpha__ = 1, 
#               p__prop_of_links_between_groups = 0.5,     	#  p__prop_of_links_between_groups   
#                                                             #  not the right name?
#                                                             #  is it really the proportion of nodes in one group 
#                                                             #  to link to another group during one round?
#                                                             #  p__prop_of_nodes_in_group_to_try_to_interlink_in_one_round?
#                                                             #  p__prop_to_link_between_two_groups_in_one_round?
#                                                             #  p__prop    
#               r__density = 0.5
#              )
#     {

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
    cat ("\n\n")

#===============================================================================

