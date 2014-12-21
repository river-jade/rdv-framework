#===============================================================================

                        #  generateSetCoverProblem.R

#===============================================================================

#  *** Future code should include test routines.  Would be good if those  
#  routines could be explicit tests of the assumptions (and conclusions?) of  
#  the 4 cases in the proof.

#  *** Future code should include test routines.  Would be good if those  
#  routines could be explicit tests of the assumptions (and conclusions?) of  
#  the 4 cases in the proof.

#===============================================================================

#  History:

#  v1 - 
#  v2 - 
#  v3 - add degree distribution calculations
#  v4 - cleaning up code layout formatting
#  v5 - replacing node_link_pairs with link_node_pairs to match marxan puvspr

#  2014 12 10 - BTL
#       Starting to replace the data frames and methods for operating on them 
#       so that it's mostly done with sqlite.  It should make the code clearer 
#       and make it easy to keep the whole structure in files in the tzar 
#       output directory for each run.  This, in turn, will make it much 
#       easier to go back and do post-hoc operations on the graph and output 
#       data after the run.  Currently, as the experiments evolve, I keep 
#       finding that I want to do things that I had not foreseen and I need 
#       access to the data without re-running the whole set of experiments.
#
#       Before making the big changes, I've removed the huge block of notes 
#       and code that I had at the end of the file that were related to 
#       marxan and things I need to do.  I cut all of that out and pasted it 
#       into another R file called:
#           /Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/
#               oldCommentedMarxanNotesCodeRemovedFrom_generateSetCoverProblem_2014_12_10.R

#  2014 12 11 - BTL
#       - Replacing all references to "group" with "group", since I'm going to 
#           add the ability to have more than one independent node per group.   
#           These groups will no longer be groups if there is more than one 
#           independent node because by definition, no independent nodes can 
#           be linked.  There will still be a group inside the group, i.e., the 
#           dependent nodes, and the independent nodes will still link to those 
#           dependent nodes.  They just won't link to each other.  
#           Renaming also means that I need to change the names of a couple of 
#           variables in the yaml file who have "clique" in their name.
#
#       - Converted choice of integerize() function from hard-coded value to 
#           switch statement based on option given in yaml file.

#===============================================================================
                    #  START EMULATION CODE
#===============================================================================

    #  Need to set emulation flag every time you swap between emulating 
    #  and not emulating.  
    #  This is the only variable you should need to set for that.
    #  Make the change in the file called emulatingTzarFlag.R so that 
    #  every file that needs to know the value of this flag is using 
    #  the synchronized to the same value.

source ("emulatingTzarFlag.R")

#--------------------

    #  Need to set these variables just once, i.e., at start of a new project. 
    #  Would never need to change after that for that project unless 
    #  something strange like the path to the project or to tzar itself has 
    #  changed.  
    #  Note that the scratch file can go anywhere you want and it will be 
    #  erased after the run if it is successful and you have inserted the 
    #  call to the cleanup code at the end of your project's code.  
    #  However, if your code crashes during the emulation, you may have to 
    #  delete the file yourself.  I don't think it hurts anything if it's 
    #  left lying around though.

projectPath = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R"
tzarJarPath = "~/D/rdv-framework/tzar.jar"
tzarEmulation_scratchFileName = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/tzarEmulation_scratchFile.txt"

#-------------------------------------------------------------------------------

    #  This is the only code you need to run the emulator.
    #  However, if you want it to clean up the tzar directory name extensions 
    #  after it is finished, you also need to run the routine called 
    #  cleanUpAfterTzarEmulation() after your project code has finished 
    #  running, e.g., as the last act in this file. 

source ('emulateRunningUnderTzar.R')

if (emulateRunningUnderTzar)
    {
    cat ("\n\nIn generateSetCoverProblem:  emulating running under tzar...")

    parameters = emulateRunningTzar (projectPath, 
                                     tzarJarPath, 
                                     tzarEmulation_scratchFileName)
    }

#===============================================================================
                    #  END EMULATION CODE
#===============================================================================

    #  Dummy function to build parameters list if tzar was not run.
    #  This is just meant as a place holder that other users could modify 
    #  if they were neither running tzar nor running the tzar emulator.
    #  They would just change all of the NA values in here to whatever 
    #  they want for the run.  
    #  More lines may need to be added to this in the future if more 
    #  values from the parameters list are used in this program.  
    #  I generated this list by running the following bash command and 
    #  editing the resulting lines:
    #       grep 'parameters\$' generateSetCoverProblem.R

local_build_parameters_list = function ()
    {   
    parameters = list()
    
    parameters$seed = NA
    parameters$integerize_string = NA
    parameters$n__num_groups = NA
    parameters$use_unif_rand_n__num_groups = NA
    parameters$n__num_groups_lower_bound = NA
    parameters$n__num_groups_upper_bound = NA
    parameters$alpha__ = NA
    parameters$use_unif_rand_alpha__) = NA
    parameters$alpha___lower_bound = NA
    parameters$alpha___upper_bound = NA
    parameters$p__prop_of_links_between_groups = NA
    parameters$use_unif_rand_p__prop_of_links_between_groups = NA
    parameters$p__prop_of_links_between_groups_lower_bound = NA
    parameters$p__prop_of_links_between_groups_upper_bound = NA
    parameters$r__density = NA
    parameters$use_unif_rand_r__density = NA
    parameters$p__r__density_lower_bound = NA
    parameters$p__r__density_upper_bound = NA
    parameters$base_for_target_num_links_between_2_groups_per_round = NA
    parameters$at_least_1_for_target_num_links_between_2_groups_per_round = NA
    parameters$marxan_spf_const = NA
    parameters$marxan_num_reps = NA
    parameters$marxan_num_iterations = NA
    parameters$run_id = NA
    parameters$summary_filename = NA

    return (parameters)
    }

#===============================================================================

#browser()

library (plyr)    #  For count()
library (marxan)

#-------------------------------------------------------------------------------

running_tzar_or_tzar_emulator = TRUE

if (! running_tzar_or_tzar_emulator)
    {
    if (exists ("parameters"))
        {
        system.quit (paste0 ("\n\nSomething is wrong.  ", 
                             "Not running tzar or tzar emulator but ", 
                             "parameters variable still exists.\n\n"))
        
        } else  parameters = local_build_parameters_list ()
    }

#-------------------------------------------------------------------------------

#seed = 19
seed = parameters$seed
set.seed (seed)

#-------------------------------------------------------------------------------

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

#-------------------------------------------------------------------------------

add_link = function (node_link_pairs, next_node_link_pair_row, 
                     smaller_node_ID, larger_node_ID, 
                     next_link_ID)
    {
#     cat ("\n\t\t[", smaller_node_ID, ",", larger_node_ID, "]")
    
    node_link_pairs [next_node_link_pair_row, "node_ID"] = smaller_node_ID
    node_link_pairs [next_node_link_pair_row, "link_ID"] = next_link_ID
#              cat ("\n\t\t\tnode_link_pairs [", next_node_link_pair_row, ", ] = \n")
#              print (node_link_pairs [next_node_link_pair_row,])

    next_node_link_pair_row = next_node_link_pair_row + 1    
    node_link_pairs [next_node_link_pair_row, "node_ID"] = larger_node_ID
    node_link_pairs [next_node_link_pair_row, "link_ID"] = next_link_ID
#              cat ("\n\t\t\tnode_link_pairs [", next_node_link_pair_row, ", ] = \n")
#              print (node_link_pairs [next_node_link_pair_row,])
    next_node_link_pair_row = next_node_link_pair_row + 1

#     next_link_ID = next_link_ID + 1
#              cat ("\n\t\tnext_link_ID = ", next_link_ID)
    
    updated_links = list()
    updated_links$next_node_link_pair_row = next_node_link_pair_row
#     updated_links$next_link_ID = next_link_ID
    updated_links$node_link_pairs = node_link_pairs
    
    return (updated_links)
    }

#-------------------------------------------------------------------------------

    #  Run marxan.
        #  Should include this in the marxan package.

    #*******
    #  NOTE:  Random seed is set to -1 in the cplan input.dat.
    #           I think that means to use a different seed each time.
    #           I probably need to change this to any positive number, 
    #           at least in the default input.dat that I'm using now 
    #           so that I get reproducible results.
    #*******

run_marxan = function ()
    {
    marxan_dir = "/Users/bill/D/Marxan/"
    
    original_dir = getwd()
    cat ("\n\noriginal_dir =", original_dir)
    
    cat ("\n\nImmediately before calling marxan, marxan_dir = ", marxan_dir)
    setwd (marxan_dir)
    
    cat("\n =====> The current wd is", getwd() )
    
        #  The -s deals with the problem of Marxan waiting for you to hit 
        #  return at the end of the run when you're running in the background.  
        #  Without it, the system() command never comes back.
        #       (From p. 24 of marxan.net tutorial:
        #        http://marxan.net/tutorial/Marxan_net_user_guide_rev2.1.pdf
        #        I'm not sure if it's even in the normal user's manual or 
        #        best practices manual for marxan.)
    
    system.command.run.marxan = "./MarOpt_v243_Mac64 -s"    
    cat( "\n\n>>>>>  The system command to run marxan will be:\n'", 
         system.command.run.marxan, "'\n>>>>>\n\n", sep='')
    
    retval = system (system.command.run.marxan)    #  , wait=FALSE)
    cat ("\n\nmarxan retval = '", retval, "'.\n\n", sep='')        
    
    setwd (original_dir)
    cat ("\n\nAfter setwd (original_dir), sitting in:", getwd(), "\n\n")
    
    return (retval)
    }

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

        #--------------------------------------------------
        #  Create structures to hold the nodes and links.
#  NEED TO DESCRIBE ALL OF THE MAJOR DATA STRUCTURES USED IN HERE 
#  AND WHAT (IF ANYTHING), THEY ASSUME.
        #--------------------------------------------------    

    cat ("\n\n--------------------  Creating structures to hold the nodes and links.\n")

    node_IDs = 1:tot_num_nodes
    
#--------------------

            #  For each node ID, what group does it belong to?
    group_IDs = 1 + (0:(tot_num_nodes - 1) %/% num_nodes_per_group)

            #  Assign lowest node IDs in each group to be the independent nodes 
            #  in that group.
#     independent_node_IDs = seq (from=1, 
#                                 by=num_nodes_per_group, 
#                                 length.out=n__num_groups)

    independent_node_ID_starts = seq (from=1, 
                                      by=num_nodes_per_group, 
                                      length.out=n__num_groups)
    independent_node_IDs = c()
    for (idx in 0:(num_independent_nodes_per_group-1))
        {
        independent_node_IDs = 
                c(independent_node_IDs, (idx + independent_node_ID_starts))
        }            
    independent_node_IDs = sort (independent_node_IDs)

#--------------------

            #  For each node ID, flag whether it is in the dependent set or not.
    dependent_set_members = rep (TRUE, tot_num_nodes)
    dependent_set_members [independent_node_IDs] = FALSE
    
            #  Collect the IDs of just the dependent nodes.
    dependent_node_IDs = node_IDs [-independent_node_IDs]
    
            #  Build an overall data frame that shows for each node, 
            #  its node ID and group ID, plus a flag indicating whether 
            #  it's in the dependent set or not.  For example, if there 
            #  are 3 nodes per group:
            #
            #       node_ID     group_ID       dependent_set_member
            #         1            1                 TRUE
            #         2            1                 TRUE
            #         3            1                 FALSE
            #         4            2                 TRUE
            #         5            2                 TRUE
            #         6            2                 FALSE
            #        ...          ...                 ...


#    nodes = cbind (node_IDs, group_IDs, dependent_set_member)
    nodes = data.frame (node_ID = node_IDs,
                        group_ID = group_IDs, 
                        dependent_set_member = dependent_set_members)

#     cat ("\n\nnodes and their group IDs:")
#     for (cur_node_ID in 1:tot_num_nodes)
#         {
#         cat ("\n\t", cur_node_ID, "\t", group_IDs [cur_node_ID])    
#         }
#     cat ("\n")

    cat ("\n\t\t independent_node_IDs = ", independent_node_IDs)
    cat ("\n\t\t dependent_node_IDs = ", dependent_node_IDs)
    
    cat ("\n\nnodes = \n")
    print (nodes)
    cat ("\n\n")
    
#    nodes_df = as.data.frame (nodes)
    
    linked_node_pairs = matrix (NA, 
                                nrow = max_possible_tot_num_links, 
                                ncol = 2, 
                                byrow = TRUE)

            #  Build a data frame with all the links for all of the nodes.  
            #  For each node, there is a separate line for each link associated 
            #  with that node.  So, for example, if there are two nodes, 3 and 5, 
            #  and node 3 has 2 links, 18 and 93, and node 5 has 3 links, 11,15, and 21, 
            #  then there should be 5 lines in the table:
            #
            #      node_ID    link_ID
            #       3            18
            #       3            93
            #       5            11
            #       5            15
            #       5            21

    max_possible_tot_num_node_link_pairs = 2 * max_possible_tot_num_links
#     node_link_pairs = matrix (NA, 
#                               nrow=max_possible_tot_num_node_link_pairs, 
#                               ncol=2, 
#                               byrow=TRUE
#                               )
#     node_link_pairs = as.data.frame (node_link_pairs)
#     names (node_link_pairs) = c("node_ID", "link_ID")

    next_node_link_row = 1    #  NEVER USED?  DELETE THIS?
    next_link_ID = 1
    cur_group_ID = 1
    
        #  Link all nodes within each group.
    all_group_IDs = 1:n__num_groups

    cat ("\n\ngroups")
    
#df[df$value>3.0,] 

#===============================================================================
#  Start adding dbms code to replace data frames.
#  Most of this part is cloned from dbms.initialise.melb.grassland.R
#===============================================================================

source ("dbms_functions.R")

db_name = "test.db"

    #------------------------------------------------------------
    #  Check whether database exists and remove it if it does.
    #------------------------------------------------------------

safe.remove.file.if.exists (db_name)

    #------------------------------------------------------------
    #  Create the DB and make the tables and
    #  column headings
    #------------------------------------------------------------

connect_to_database (db_name)

# db_driver <- dbDriver("SQLite")
# db_con <- dbConnect (db_driver, db_name)

    #------------------------------------------------------------
    #  Define the column names and types of the table 
    #------------------------------------------------------------

node_table_defn = 
    matrix (c ('ID', 'int',
               'GROUP_ID', 'int', 
               'DEPENDENT_SET_MEMBER', 'int'
               ),
            byrow = TRUE,
            ncol = 2 )

link_table_defn = 
    matrix (c ('ID', 'int',
               'NODE_1', 'int',
               'NODE_2', 'int', 
               'LINK_DIRECTION', 'string'    #  "UN", "BI", "FT", "TF"
               ),
            byrow = TRUE,
            ncol = 2 )

    #------------------------------------------------------------
    #  Build the sql expression to create the table using SQLite
    #------------------------------------------------------------

node_table_name = "nodes"
sql_create_table_query = 
  build_sql_create_table_expression (node_table_name,
                                     node_table_defn)
sql_send_operation (sql_create_table_query)

link_table_name = "links"
sql_create_table_query = 
  build_sql_create_table_expression (link_table_name,
                                     node_table_defn)
sql_send_operation (sql_create_table_query)


    #  add some dummy data for testing 
testSqlCmd <- paste0 ('insert into ', node_table_name, 
                     ' values (1, 0, 1)')
sql_send_operation (testSqlCmd)

#query2s <- 'insert into staticPUinfo values(1, 4567)';
#sql.send.operation( query2s );
testSqlCmd <- paste0 ('insert into ', link_table_name, 
                     ' values (1, 2, "un")')
sql_send_operation (testSqlCmd)


# some other example queries

#query4 <- 'update PUstatus set RESERVED = -1 where ID = 1';
#sql.send.operation( query4 );

    #----------

close_database_connection()

#===============================================================================
#===============================================================================

cat ("\n\n--------------------  Linking nodes WITHIN each group.\n")

if (num_nodes_per_group < 2)
    quit ("\n\n***  num_nodes_per_group (", num_nodes_per_group, 
          ") must be at least 2.\n\n")


num_nodes_per_group_minus_1 = num_nodes_per_group - 1
cur_row = 1

for (cur_group_ID in 1:n__num_groups)
    {
    #  NOTE:  The code in this loop assumes the group nodes are sorted.  
    #         These group nodes are probably already sorted, 
    #         but this just makes sure, as a safeguard against 
    #         some future change.
    cur_group_nodes_sorted = 
        sort (nodes [nodes$group_ID == cur_group_ID, "node_ID"])
    cat ("\n\ncur_group_nodes_sorted for group ", cur_group_ID, " = ")
    print (cur_group_nodes_sorted)
    
    #  Link each node in the group to all nodes with a higher node ID in 
    #  the same group.  
    #  Doing it this way insures that all nodes in the group are linked to 
    #  all other nodes in the group but that the linking action is only done 
    #  once for each pair.
    
    for (cur_idx in 1:num_nodes_per_group_minus_1)
        {
        for (other_node_idx in (cur_idx+1):num_nodes_per_group)
            {
            linked_node_pairs [cur_row, 1] = cur_group_nodes_sorted [cur_idx]
            linked_node_pairs [cur_row, 2] = cur_group_nodes_sorted [other_node_idx]
            cur_row = cur_row + 1
            }
        }
    }

cat ("\n\nlinked_node_pairs (with last lines NA to hold intergroup links to be loaded in next step):\n\n")
print (linked_node_pairs)
cat ("\n\n")

#===============================================================================

    #  linked_node_pairs gives the edge list.
        #  However, can't use it until it's completely finished, i.e., 
        #  close to when it's handed to Marxan.
    #  igraph needs an edge list.
    #  THe row number is also the edge/link ID.
    #  The two columns are the nodes that are connected.
    #  This is the edge list the igraph needs, I think.
    #  However, I need more than one graph.  

#===============================================================================

    #  Now all groups and their within group links have been built.  
    #  Ready to start doing rounds of intergroup linking.

cat ("\n\n--------------------  Doing rounds of intergroup linking.\n")

for (cur_round in 1:num_rounds_of_linking_between_groups)
    {
    cat ("\nRound", cur_round)
    
    #  Draw a random pair of groups to link in this round.
    cur_group_pair = sample (1:n__num_groups, 2, replace=FALSE)
    
    #  I'm using min and max here because smaller group IDs were 
    #  filled with smaller node IDs, so every node ID in the 
    #  smaller group ID should be the smaller node ID of any pairing 
    #  of nodes between the groups and the linking routine 
    #  expcts the smaller node ID to come before the larger one 
    #  in the linking argument list.  This may be a vestigial thing 
    #  from earlier schemes that doesn't matter any more, but 
    #  it's easy to maintain here for the moment, just in case it 
    #  does still matter in some way.  In any case, it doesn't 
    #  hurt anything to do this now other than the little bit of 
    #  extra execution time to compute the min and max.
    
    group_1 = min (cur_group_pair)
    group_1_nodes = nodes [(nodes$group_ID == group_1) & (nodes$dependent_set_member), 
                            "node_ID"]
    
    group_2 = max (cur_group_pair)
    group_2_nodes = nodes [(nodes$group_ID == group_2) & (nodes$dependent_set_member), 
                            "node_ID"]
    
    #***-----------------------------------------------------------------------------------
    
    group_1_sampled_nodes = 
        sample (group_1_nodes, target_num_links_between_2_groups_per_round, 
                replace=TRUE)
    group_2_sampled_nodes = 
        sample (group_2_nodes, target_num_links_between_2_groups_per_round, 
                replace=TRUE)
    
    for (cur_node_pair_idx in 1:target_num_links_between_2_groups_per_round)
        {                
        linked_node_pairs [cur_row, 1] = group_1_sampled_nodes [cur_node_pair_idx]
        linked_node_pairs [cur_row, 2] = group_2_sampled_nodes [cur_node_pair_idx]
        cur_row = cur_row + 1
        }
    }

#===============================================================================

    #  All node pairs should be loaded into the linked_node_pairs table now 
    #  and there should be no NA lines left in the table.
    
    #  However no duplicate links are allowed, so need to go through all 
    #  node pairs and remove non-unique ones.

unique_linked_node_pairs = unique (linked_node_pairs)

num_non_unique_linked_node_pairs = dim (linked_node_pairs)[1]
num_unique_linked_node_pairs = dim (unique_linked_node_pairs)[1]

cat ("\n\nnum_non_unique_linked_node_pairs =", num_non_unique_linked_node_pairs)
cat ("\nnum_unique_linked_node_pairs =", num_unique_linked_node_pairs)
cat ("\n")

#===============================================================================

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

cat ("\n\n--------------------  Computing and plotting degree distribution of node graph.\n")

#  Compute and plot the degree distribution of the node graph.
#  It may be that we can use metrics over this graph as features of the 
#  problem that give information about its difficulty.
#  For example, people are always going off about power laws in the 
#  degree distribution.  Would something like that explain anything?

#  What about other measures like various forms of centrality?

#  Also, need to plot the graph using eric's software (or something similar) 
#  to see if the visual layout gives any information.

#  After plotting, I realized that this degree distribution has the same 
#  shape as a rank abundance curve, however, it's the opposite of a rank 
#  abundance curve in that it's saying how many spp per patch, not how 
#  many patches per spp.  I need to plot that now to see how it compares 
#  to a typical rank abundance curve.  However, because of the way that 
#  this problem generator currently works, the distribution will be 
#  perfectly flat, i.e. 2 patches for every species, one for each end of 
#  the link.  I need to start adding copies of the link IDs to other 
#  patches after this generator finishes and see if you're still able to 
#  have a deceptive problem even without the flat rank abundance 
#  distribution?  In fact, can you add link IDs/species to non-independent 
#  patches that still preserves the correct solution but purposely drives 
#  the optimizer toward a wrong solution by knowing what kinds of things 
#  it values?  Could you use annealing (or even Marxan itself) to search 
#  for better "plate stackings" that lie over the hidden solution and 
#  the optimizer finds some feature that lets it drive toward finding 
#  difficult problems?  (Need good change operators too though.  However, 
#  Marxan's own change operator is mindlessly simple and might work for 
#  this as well if you do enough iterations the way Marxan does.)

#  What about cooccurrence matrices for the species?  Is there any measure 
#  or visual display over those (e.g., something about their degree 
#  distribution) that can be used as a predictive feature?

# cat ("\n\nNumber of links per node BEFORE intergroup linking:\n")
# print (initial_link_counts_for_each_node)

final_link_counts_for_each_node = count (node_link_pairs, vars="node_ID")

cat ("\n\nNumber of links per node AFTER intergroup linking:\n")
print (final_link_counts_for_each_node)

final_degree_dist = arrange (final_link_counts_for_each_node, -freq)
final_degree_dist[,"node_ID"] = 1:dim(final_degree_dist)[1]
plot (final_degree_dist)

#-------------------------------------------------------------------------------

# cat ("\n\nNumber of nodes per link BEFORE intergroup linking:\n")
# print (initial_node_counts_for_each_link)

final_node_counts_for_each_link = count (node_link_pairs, vars="link_ID")

cat ("\n\nNumber of nodes per link AFTER intergroup linking:\n")
print (final_node_counts_for_each_link)

final_rank_abundance_dist = arrange (final_node_counts_for_each_link, -freq)
final_rank_abundance_dist[,"link_ID"] = 1:dim(final_rank_abundance_dist)[1]
plot (final_rank_abundance_dist)

#===============================================================================

    #  Write out the data as Marxan input files.

#-------------------------------------------------------------------------------

cat ("\n\n--------------------  Writing out the data as Marxan input files.\n")

library (marxan)

sppAmount = 1

num_node_link_pairs = length (node_link_pairs [,"node_ID"])

PU_IDs = unique (node_link_pairs [,"node_ID"])
num_PUs = length (PU_IDs)

spp_IDs = unique (node_link_pairs [,"link_ID"])
num_spp = length (spp_IDs)

spp_PU_amount_table =
    data.frame (species = node_link_pairs [,"link_ID"],
                pu      = node_link_pairs [,"node_ID"],
                amount  = rep (sppAmount, num_node_link_pairs))

    #----------------------------------------------------------------------
    #  Sort the table in ascending order by species within planning unit.
    #  Taken from Wickham comment in:
    #  http://stackoverflow.com/questions/1296646/how-to-sort-a-dataframe-by-columns-in-r
    #
    #  BTL - 2014 11 28
    #
    #  Note that Marxan doesn't work correctly if the table is not sorted 
    #  by planning unit ID (e.g., it can't find satisfying solutions).  
    #  Ascelin said that the Marxan manual shows a picture of the values 
    #  sorted incorrectly, i.e., by species.
    #
    #  I should probably move this arrange() call into the code that 
    #  writes the table as a Marxan input file.  That would make sure 
    #  that no one can write the table out incorrectly if they use that 
    #  call.
    #----------------------------------------------------------------------

spp_PU_amount_table = arrange (spp_PU_amount_table, pu, species)

#-------------------------------------------------------------------------------

#  Choosing spf values
#  Taken from pp. 38-39 of Marxan_User_Manual_2008.pdf.
#  Particularly note the second paragraph, titled "Getting Started".

# 3.2.2.4 Conservation Feature Penalty Factor

# Variable – ‘spf’ Required: Yes
# Description: The letters ‘spf’ stands for Species Penalty Factor. This
# variable is more correctly referred to as the Conservation Feature
# Penalty Factor. The penalty factor is a multiplier that determines the
# size of the penalty that will be added to the objective function if the
# target for a conservation feature is not met in the current reserve
# scenario (see Appendix B -1.4 for details of how this penalty is
# calculated and applied). The higher the value, the greater the relative
# penalty, and the more emphasis Marxan will place on ensuring that
# feature’s target is met. The SPF thus serves as a way of distinguishing
# the relative importance of different conservation features. Features of
# high conservation value, for example highly threatened features or those
# of significant social or economic importance, should have higher SPF
# values than less important features. This signifies that you are less
# willing to compromise their representation in the reserve system.
# Choosing a suitable value for this variable is essential to achieving
# good solutions in Marxan. If it is too low, the representation of
# conservation features may fall short of the targets. If it is too high,
# Marxan’s ability to find good solutions will be impaired (i.e. it will
# sacrifice other system properties such as lower cost and greater
# compactness in an effort to fully meet the conservation feature targets).

# Getting Started: It will often require some experimentation to determine
# appropriate SPFs. This should be done in an iterative fashion. A good
# place to start is to choose the lowest value that is of the same order
# of magnitude as the number of conservation features, e.g. if you have 30
# features, start with test SPFs of, say, 10 for all features. Do a number
# of repeat of runs (perhaps 10) and see if your targets are being met in
# the solutions. If not all targets are being met try increasing the SPF
# by a factor of two and doing the repeat runs again. When you get to a
# point where all targets are being met, decrease the SPFs slightly and
# see if they are still being met. 

# After test runs are sorted out, then
# differing relative values can be applied, based on considerations such
# as rarity, ecological significance, etc., as outlined above.
# Even if all your targets are being met, always try lower values . By
# trying to achieve the lowest SPF that produces satisfactory solutions,
# Marxan has the greatest flexibility to find good solutions. In general,
# unless you have some a priori reason to weight the inclusion of features
# in your reserve system, you should start all features with the same SPF.
# If however, the targets for one or two features are consistently being
# missed even when all other features are adequately represented , it may
# be appropriate to raise the SPF for these features. Once again, see the
# MGPH for more detail on setting SPFs.

#spf_const = 10 ^ (floor (log10 (num_spp)))
spf_const = parameters$marxan_spf_const

#-------------------------------------------------------------------------------

    #***  Need to modify the write_all...() function to prepend the 
    #***  name of the directory to put the results in (but can  
    #***  default to writing in "." instead?).

marxan_input_dir = "/Users/bill/D/Marxan/input/"
write_all_marxan_input_files (PU_IDs, spp_IDs, spp_PU_amount_table, 
                              spf_const)
#                               spf_const = spf_const)
# write_all_marxan_input_files (PU_IDs, spp_IDs, spp_PU_amount_table, 
#                                          spf_const = 1, 
#                                          target_const = 1, 
#                                          cost_const = 1, 
#                                          status_const = 0)

system ("rm /Users/bill/D/Marxan/output/*")

system ("rm /Users/bill/D/Marxan/input/pu.dat")
system ("cp ./pu.dat /Users/bill/D/Marxan/input")

system ("rm /Users/bill/D/Marxan/input/spec.dat")
system ("cp ./spec.dat /Users/bill/D/Marxan/input")

system ("rm /Users/bill/D/Marxan/input/puvspr.dat")
system ("cp ./puvspr.dat /Users/bill/D/Marxan/input")


#===============================================================================
    
    #  TODO:

    #  NOTE:  Many of the entries below have to do with reading marxan output 
    #         and loading it into this program and doing something with it.
    #         I should build functions for doing those things and add them to 
    #         the marxan package.  Should talk to Ascelin about this too and 
    #         see if there is any overlap with what he's doing.

#===============================================================================
    
    #  Build structures holding:
        #  Make a function to automatically do these subtotalling actions 
        #  since I need to do it all the time.
            #  May want one version for doing these give a table or dataframe 
            #  and another for doing them given a list or list of lists 
            #  since those are the most common things I do (e.g, in 
            #  distSppOverPatches()).
        #  Species richness for each patch.
        #  Number of patches for each spp.
        #  Correct solution.
        #  Things in dist spp over patches?
            #  Patch list for each species.
            #  Species list for each patch.
    #  Are some of these already built for the plotting code above?

    #  *** Maybe this should be done using sqlite instead of lists of lists and 
    #  tables and data frames?


    #  http://stackoverflow.com/questions/1660124/how-to-group-columns-by-sum-in-r
    #  Is this counting up the number of species on each patch?
# x2  <-  by (spp_PU_amount_table$amount, spp_PU_amount_table$pu, sum)
# do.call(rbind,as.list(x2))
# 
# cat ("\n\nx2 =\n")
# print (x2)

#===============================================================================

    #  Aside:  The mention of distSppOverPatches() above reminds me that I 
    #           found something the other day saying that copulas were 
    #           a way to generate distributions with specified marginal 
    #           distributions.  I think that I saved a screen grab and 
    #           named the image using copula in the title somehow...

#===============================================================================

    #  General Parameters
marxan_BLM = 1
marxan_PROP  = 0.5
marxan_RANDSEED  = seed
marxan_NUMREPS  = parameters$marxan_num_reps

    #  Annealing Parameters
marxan_NUMITNS  = parameters$marxan_num_iterations
marxan_STARTTEMP  = -1
marxan_NUMTEMP  = 10000

    #  Cost Threshold
marxan_COSTTHRESH   = "0.00000000000000E+0000"
marxan_THRESHPEN1   = "1.40000000000000E+0001"
marxan_THRESHPEN2   = "1.00000000000000E+0000"

    #  Input Files
marxan_INPUTDIR  = "input"
marxan_PUNAME  = "pu.dat"
marxan_SPECNAME  = "spec.dat"
marxan_PUVSPRNAME  = "puvspr.dat"

    #  Save Files
marxan_SCENNAME  = "output"
marxan_SAVERUN  = 3
marxan_SAVEBEST  = 3
marxan_SAVESUMMARY  = 3
marxan_SAVESCEN  = 3
marxan_SAVETARGMET  = 3
marxan_SAVESUMSOLN  = 3
marxan_SAVEPENALTY  = 3
marxan_SAVELOG  = 2
marxan_OUTPUTDIR  = "output"

    #  Program control
marxan_RUNMODE  = 1
marxan_MISSLEVEL  = 1
marxan_ITIMPTYPE  = 0
marxan_HEURTYPE  = -1
marxan_CLUMPTYPE  = 0
marxan_VERBOSITY  = 3

marxan_SAVESOLUTIONSMATRIX  = 3

#-------------------

marxan_input_parameters_file_name = "/Users/bill/D/Marxan/input.dat"
#marxan_input_parameters_file_name = parameters$marxan_input_parameters_file_name

rm_cmd = paste ("rm", marxan_input_parameters_file_name)
system (rm_cmd)

#marxan_input_file_conn = file (marxan_input_parameters_file_name)
marxan_input_file_conn = marxan_input_parameters_file_name
    
cat ("Marxan input file", file=marxan_input_file_conn, append=TRUE)

cat ("\n\nGeneral Parameters", file=marxan_input_file_conn, append=TRUE)

cat ("\nBLM", marxan_BLM, file=marxan_input_file_conn, append=TRUE)
cat ("\nPROP", marxan_PROP, file=marxan_input_file_conn, append=TRUE)
cat ("\nRANDSEED", marxan_RANDSEED, file=marxan_input_file_conn, append=TRUE)
cat ("\nNUMREPS", marxan_NUMREPS, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nAnnealing Parameters", file=marxan_input_file_conn, append=TRUE)
cat ("\nNUMITNS", marxan_NUMITNS, file=marxan_input_file_conn, append=TRUE)
cat ("\nSTARTTEMP", marxan_STARTTEMP, file=marxan_input_file_conn, append=TRUE)
cat ("\nNUMTEMP", marxan_NUMTEMP, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nCost Threshold", file=marxan_input_file_conn, append=TRUE)
cat ("\nCOSTTHRESH", marxan_COSTTHRESH, file=marxan_input_file_conn, append=TRUE)
cat ("\nTHRESHPEN1", marxan_THRESHPEN1, file=marxan_input_file_conn, append=TRUE)
cat ("\nTHRESHPEN2", marxan_THRESHPEN2, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nInput Files", file=marxan_input_file_conn, append=TRUE)
cat ("\nINPUTDIR", marxan_INPUTDIR, file=marxan_input_file_conn, append=TRUE)
cat ("\nPUNAME", marxan_PUNAME, file=marxan_input_file_conn, append=TRUE)
cat ("\nSPECNAME", marxan_SPECNAME, file=marxan_input_file_conn, append=TRUE)
cat ("\nPUVSPRNAME", marxan_PUVSPRNAME, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nSave Files", file=marxan_input_file_conn, append=TRUE)
cat ("\nSCENNAME", marxan_SCENNAME, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVERUN", marxan_SAVERUN, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVEBEST", marxan_SAVEBEST, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVESUMMARY", marxan_SAVESUMMARY, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVESCEN", marxan_SAVESCEN, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVETARGMET", marxan_SAVETARGMET, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVESUMSOLN", marxan_SAVESUMSOLN, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVEPENALTY", marxan_SAVEPENALTY, file=marxan_input_file_conn, append=TRUE)
cat ("\nSAVELOG", marxan_SAVELOG, file=marxan_input_file_conn, append=TRUE)
cat ("\nOUTPUTDIR", marxan_OUTPUTDIR, file=marxan_input_file_conn, append=TRUE)

cat ("\n\nProgram control.", file=marxan_input_file_conn, append=TRUE)
cat ("\nRUNMODE", marxan_RUNMODE, file=marxan_input_file_conn, append=TRUE)
cat ("\nMISSLEVEL", marxan_MISSLEVEL, file=marxan_input_file_conn, append=TRUE)
cat ("\nITIMPTYPE", marxan_ITIMPTYPE, file=marxan_input_file_conn, append=TRUE)
cat ("\nHEURTYPE", marxan_HEURTYPE, file=marxan_input_file_conn, append=TRUE)
cat ("\nCLUMPTYPE", marxan_CLUMPTYPE, file=marxan_input_file_conn, append=TRUE)
cat ("\nVERBOSITY", marxan_VERBOSITY, file=marxan_input_file_conn, append=TRUE)

cat ("\nSAVESOLUTIONSMATRIX", marxan_SAVESOLUTIONSMATRIX, file=marxan_input_file_conn, append=TRUE)

#close (marxan_input_file_conn)

#===============================================================================

run_marxan()

#===============================================================================

    #  Read various marxan outputs into this program.
        #  Should include these in the marxan package.
        #  Marxan's best solution.
        #  Marxan's votes for including each planning unit.
    
        #  Marxan output files to read from the Marxan output directory 
        #  (need to look these file names up in the manual):

            #  output_best.csv
            #  output_mvbest.csv

            #  output_ssoln.csv
            #  output_solutionsmatrix.csv
            #  output_sum.csv

            #  output_penalty_planning_units.csv
            #  output_penalty.csv

            #  output_sen.dat

marxan_output_dir_path = "/Users/bill/D/Marxan/output/"

marxan_output_best_file_name = "output_best.csv"
marxan_output_ssoln_file_name = "output_ssoln.csv"
marxan_output_mvbest_file_name = "output_mvbest.csv"


    #  Make sure both are sorted in increasing order of planning unit ID.
    #  "arrange()" syntax taken from Wickham comment in:
    #  http://stackoverflow.com/questions/1296646/how-to-sort-a-dataframe-by-columns-in-r

library (plyr)      #  for arrange()

#---------------------------------

marxan_best_df = 
    read.csv (paste (marxan_output_dir_path, marxan_output_best_file_name, sep=''), 
              header=TRUE)
cat ("\n\nAfter loading output_best.csv, marxan_best_df =")
print (marxan_best_df)

marxan_best_df = arrange (marxan_best_df, PUID)

cat ("\n\nAfter sorting, marxan_best_df = \n")
print (marxan_best_df)
cat ("\n\n-------------------")

#---------------------------------

marxan_mvbest_df = 
    read.csv (paste (marxan_output_dir_path, marxan_output_mvbest_file_name, sep=''), 
              header=TRUE)
cat ("\n\nAfter loading output_mvbest.csv, marxan_mvbest_df =")
print (marxan_mvbest_df)

    #  The call to "arrange()" below gives a weird error when run on the 
    #  data frame because the column names have spaces in them (e.g., 
    #  "Conservation Feature").  Renaming them seems to fix the problem
names (marxan_mvbest_df) = 
    c ("ConservationFeature", 
       "FeatureName",
       "Target",
       "AmountHeld",
       "OccurrenceTarget",
       "OccurrencesHeld",
       "SeparationTarget",
       "SeparationAchieved",
       "TargetMet",
       "MPM"  
       )

marxan_mvbest_df = arrange (marxan_mvbest_df, ConservationFeature)

cat ("\n\nAfter sorting, marxan_mvbest_df = \n")
print (marxan_mvbest_df)
cat ("\n\n-------------------")

#---------------------------------

marxan_ssoln_df = 
    read.csv (paste (marxan_output_dir_path, marxan_output_ssoln_file_name, sep=''),
              header=TRUE)
cat ("\n\nAfter loading output_ssoln.csv, marxan_ssoln_df =")
print (marxan_ssoln_df)

marxan_ssoln_df = arrange (marxan_ssoln_df, planning_unit)

cat ("\n\nAfter sorting, marxan_ssoln_df = \n")
print (marxan_ssoln_df)
cat ("\n\n-------------------")

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

results_df$run_ID [cur_result_row]                                          = parameters$run_id
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


#write.csv (results_df, file = "./prob_diff_results.csv", row.names = FALSE)
write.csv (results_df, file = parameters$summary_filename, row.names = FALSE)

#===============================================================================

cat ("\n\n")
sessionInfo()
cat ("\n\n")

#===============================================================================
#===============================================================================
#===============================================================================
#===============================================================================
                    #  START EMULATION CODE
#===============================================================================

if (emulateRunningUnderTzar)
    {
    cat ("\n\nIn generateSetCoverProblem:  Cleaning up after running emulation...\n\n")
    cleanUpAfterTzarEmulation (parameters)
    }

#===============================================================================
                    #  END EMULATION CODE
#===============================================================================

