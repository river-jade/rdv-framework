#===============================================================================

                        #  generateSetCoverProblem.R

#===============================================================================

#  *** Future code should include test routines.  Would be good if those  
#  routines could be explicit tests of the assumptions (and conclusions?) of  
#  the 4 cases in the proof.

#===============================================================================

#  Procedure to run a single test case EMULATING tzar:

#   - Duplicate single_test.yaml into project.yaml.

#   - Set the tzar emulation flags wherever necessary.
#       In emulatingTzarFlag.R, set:
#           emulatingTzar = TRUE
#       In this file (generateSetCoverProblem.R), set:
#           running_tzar_or_tzar_emulator = TRUE
#       However, for nearly everything that _I_ am doing, that flag will never 
#       change since I'm nearly always using tzar.  It would be more of an 
#       issue for someone else who is not using tzar.

#           IS THIS STEP RIGHT?  DOES IT MATTER?  NOT SURE...
#   - Make sure current working directory is:    
#       /Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R
#     e,g, 
#       setwd ("/Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R")

#   - Source this file (generateSetCoverProblem.R)
#       Under RStudio, that just means having this file open in the 
#       edit window and hitting the Source button.
#       
#   - Just to give a ballpark estimate of how long to expect the test to run, 
#     as the code and yaml file stand right now (2015 01 26 4:40 pm) took about 
#     1 minute 45 seconds to run on my MacBook Pro with much of the memory 
#     and disk unavailable and a backup copying process going on 
#     in the background. 

#  NOTE that the choice of random seed in the yaml file is important 
#  because the example creates a test problem based on drawing the control 
#  parameters from a random distribution.  When the seed was 111, the 
#  test crashed with the message below.  When I changed it to 701, it 
#  ran to completion.
#       Failing:  max_possible_tot_num_links ( 3291 ) > maximum allowed ( 2000 ).
#       Save workspace image to ~/D/rdv-framework/projects/rdvPackages/biodivprobgen/.RData? [y/n/c]: 
#  However, the fail was just what it was supposed to do when those 
#  parameters came up, so the yaml file could be changed to use 111 
#  instead of 701 if you want to induce a crash to test that error 
#  trapping.
    
#-------------------------------------------------------------------------------

#  Procedure to run a single test case USING tzar:

#   - Same as above, except:

#   - Set the emulatingTzar flag to FALSE, i.e., 
#       In emulatingTzarFlag.R, set:
#           emulatingTzar = FALSE

#   - In a terminal window, Make sure current working directory is not where 
#     the source code is, but rather, in a terminal window, cd to where the 
#     tzar jar is:    
#       /Users/bill/D/rdv-framework

#   - Instead of sourcing this R file, run the following command in the 
#     terminal window:
#           To put results in the tzar default area
#       java -jar tzar.jar execlocalruns /Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/
#   OR
#           To use a specially named tzar area for the test
#       java -jar tzar.jar execlocalruns /Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/ --runset=single_test_unifRand_p_r_n_a_seed_701_in_phase_transition_area
#       
#   - Just to give a ballpark estimate of how long to expect the test to run, 
#     as the code and yaml file stand right now (2015 01 26 4:40 pm) took about 
#     1 minute 15 or 20 seconds to run on my MacBook Pro with much of the  
#     memory and disk unavailable but no backup copying process going on 
#     in the background. 

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

#  2014 12 25 - BTL
#       - Split long original file into 17 source files and sourced them 
#         since the file had gotten unmanageable to work on and understand.

#  2014 12 28 - BTL
#       - Changed all source() calls to use the full path name since the 
#         source files weren't being found.  I think that tzar had the 
#         current directory set to biodivprobgen but the source is all in 
#         biodivprobgen/R.
#       - Revised all of the tzar emulation code since it wasn't working.  
#         Much of this was due to River having introduced the "metadata/" 
#         subdirectory into the tzar output directory structure and putting 
#         the parameters.R file in there instead of in the output directory 
#         itself.

#  2014 12 29 - BTL
#       - Moved both tzar control flag settings up into this file so that 
#         they are easier to find and control in one place.  I'm still 
#         leaving the actual setting of emulatingTzar in the file called 
#         emulatingTzarFlag.R for the reasons explained below, but I'm 
#         sourcing that file from here instead of in gscp_2_tzar_emulation.R 
#         because I couldn't remember where it was happening when I wanted 
#         to change it between runs.

#===============================================================================

    #  debugging level: 0 means don't output debugging write statements.
    #  Having this as an integer instead of binary so that I can have 
    #  multiple levels of detail if I want to.
DEBUG_LEVEL = 0

#===============================================================================

    #  Need to do this in a better way so that it is appropriate for  
    #  anybody's setup.
if (!exists ("sourceCodeLocationWithSlash"))
    sourceCodeLocationWithSlash = 
        "/Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/"

#===============================================================================

    #  2014 12 29 - BTL
    #  At this point, this flag will probably almost never change again 
    #  because my code is relying on the parameters list that tzar builds 
    #  and it would be too big of a pain in the ass to build the parameters 
    #  structure myself, as would be required if NOT running under tzar or 
    #  tzar emulation.  However, I have made it possible to do that using 
    #  the function called local_build_parameters_list() in 
    #  gscp_3_get_parameters.R.  That is mostly aimed at later use though, 
    #  e.g., if the source code is distributed to someone else and they 
    #  don't want to use tzar or tzar emulation.

running_tzar_or_tzar_emulator = TRUE

    #  Need to set emulation flag every time you swap between emulating 
    #  and not emulating.  
    #  This is the only variable you should need to set for that.
    #  Make the change in the file called emulatingTzarFlag.R so that 
    #  every file that needs to know the value of this flag is using 
    #  the synchronized to the same value.

        #  2014 12 29 - BTL 
        #  Moving this to the top level code so that it's easier to see and 
        #  control.

source (paste0 (sourceCodeLocationWithSlash, "emulatingTzarFlag.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_2_tzar_emulation.R"))

#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "gscp_3_get_parameters.R"))

#===============================================================================

library (plyr)    #  For count() and arrange()
library (marxan)

#===============================================================================

    #  The rest of this code has to come after tzar or someone else has 
    #  created the "parameters" object.

#===============================================================================

seed = parameters$seed
set.seed (seed)

#---------------------------------------------------------------    
    #  Determine the OS so you can assign the correct name for 
    #  the marxan executable, etc.
    #   - for linux this returns linux-gnu
    #   - for mac this currently returns os = 'darwin13.4.0'
    #   - for windows this returns mingw32

current_os <- sessionInfo()$R.version$os
cat ("\n\nos = '", current_os, "'\n", sep='')

#---------------------------------------------------------------    

cat ("\n\n", parameters$runset_description, "\n\n")

#---------------------------------------------------------------    

plot_output_dir = parameters$fullOutputDirWithSlash

#---------------------------------------------------------------    

source (paste0 (sourceCodeLocationWithSlash, "timepoints.R"))

#===============================================================================
#                   Generate a problem, i.e, create the Xu graph.
#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "gscp_9a_create_Xu_graph.R"))

edge_list = 
    create_Xu_graph (num_nodes_per_group, 
                     n__num_groups, 
                     nodes, 
                     max_possible_tot_num_links, 
                     target_num_links_between_2_groups_per_round, 
                     num_rounds_of_linking_between_groups
                     )

#===============================================================================
#                       Clean up after graph creation.
#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "gscp_9b_convert_Xu_graph_to_spp_PU_problem.R"))

#===============================================================================
#                       Compute network metrics.
#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "gscp_11a_network_measures_using_bipartite_package.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_11b_network_measures_using_igraph_package.R"))

#===============================================================================
#                                   Run marxan.
#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "gscp_12_write_network_to_marxan_files.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_13_write_marxan_control_file_and_run_marxan.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_14_read_marxan_output_files.R"))

#===============================================================================
#                   Dump all of the different kinds of results.
#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "gscp_15_create_master_output_structure.R"))

#===============================================================================
#                                   Clean up.
#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "gscp_16_clean_up_run.R"))

#-------------------------------------------------------------------------------

    #  Writing the timepoints output file has to come BEFORE the tzar 
    #  emulation cleanup because the directory name used to locate the 
    #  output here will be changed by the emulator cleanup.

timepoints_df = timepoint (timepoints_df, "end", "End of run...")
timepoints_df = timepoints_df [1:cur_timepoint_num,]  #  Remove excess NA lines.
write.csv (timepoints_df, 
           file = parameters$timepoints_filename, 
           row.names = FALSE)

#-------------------------------------------------------------------------------

source (paste0 (sourceCodeLocationWithSlash, "gscp_17_clean_up_tzar_emulation.R"))

#===============================================================================

