#===============================================================================

                        #  generateSetCoverProblem.R

#===============================================================================

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

if (!exists ("sourceCodeLocationWithSlash"))
    sourceCodeLocationWithSlash = 
        "/Users/bill/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/"

#-------------------------------------------------------------------------------

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

#===============================================================================

source (paste0 (sourceCodeLocationWithSlash, "gscp_2_tzar_emulation.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_3_get_parameters.R"))

source (paste0 (sourceCodeLocationWithSlash, "gscp_4_support_functions.R"))

source (paste0 (sourceCodeLocationWithSlash, "gscp_5_derive_control_parameters.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_6_create_data_structures.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_7_set_up_dbms.R"))

source (paste0 (sourceCodeLocationWithSlash, "gscp_8_link_nodes_within_groups.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_9_link_nodes_between_groups.R"))

source (paste0 (sourceCodeLocationWithSlash, "gscp_10_clean_up_completed_graph_structures.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_11_summarize_and_plot_graph_structure_information.R"))

source (paste0 (sourceCodeLocationWithSlash, "gscp_12_write_network_to_marxan_files.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_13_write_marxan_control_file_and_run_marxan.R"))

source (paste0 (sourceCodeLocationWithSlash, "gscp_14_read_marxan_output_files.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_15_create_master_output_structure.R"))

source (paste0 (sourceCodeLocationWithSlash, "gscp_16_clean_up_run.R"))
source (paste0 (sourceCodeLocationWithSlash, "gscp_17_clean_up_tzar_emulation.R"))

#===============================================================================

