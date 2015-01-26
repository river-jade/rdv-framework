#===============================================================================

                        #  aggregate_df_list.R

#  Code to collapse a bunch of biodivprobgen csv files into a single file 
#  with all failed runs removed.

#===============================================================================

#  History:

#  2014 ?? ?? - BTL
#       Created initial one-off script with very little encapsulated in 
#       functions.
#
#  2015 01 10 - BTL
#       Refactoring into functions and more generalizable behavior.  

#===============================================================================

    #  This web page on dplyr may be useful to all this...
#  http://rpubs.com/justmarkham/dplyr-tutorial

#===============================================================================

remove_failed_runs_from_full_run_list = function (full_run_list, failed_run_list) 
    {
    if (! is.null (failed_run_list))
        full_run_list = full_run_list [-failed_run_list]
    
    return (full_run_list)
    }

#===============================================================================

build_cur_file_name = 
    function (run_num, 
              top_dir_name_without_slash, #  "/Users/bill/tzar/outputdata/biodivprobgen/test500unifRand_p_r_n_a", 
              run_num_dir_name_tail_without_slash = "_default_scenario", 
              file_name = "prob_diff_results.csv"
              )
    {
    full_cur_file_path = paste0 (top_dir_name_without_slash, "/", 
                                 run_num, 
                                 run_num_dir_name_tail_without_slash, "/", 
                                 file_name)
    
    return (full_cur_file_path)
    }

#===============================================================================

read_successful_results_into_aggregated_data_frame = 
    function (successful_run_list, 
              top_dir_name_without_slash, #  "/Users/bill/tzar/outputdata/biodivprobgen/test500unifRand_p_r_n_a", 
              run_num_dir_name_tail_without_slash = "_default_scenario", 
              file_name = "prob_diff_results.csv"
             )         
    {
        #  Load current file into a data frame as the seed for  
        #  the fully aggregated file.  
        #  All of the other results files in the list will be 
        #  read in and appended to this seed data frame.
#browser()    
    full_cur_file_path = build_cur_file_name (successful_run_list [1], 
                                              top_dir_name_without_slash, 
                                              run_num_dir_name_tail_without_slash, 
                                              file_name)
    aggregated_df = read.csv (full_cur_file_path, header=TRUE)
    
    for (cur_run_num in successful_run_list [-1])
        {
        full_cur_file_path = 
            build_cur_file_name (cur_run_num, 
                                 top_dir_name_without_slash, 
                                 run_num_dir_name_tail_without_slash, 
                                 file_name
                                 )

        cur_run_df = read.csv (full_cur_file_path, header=TRUE)
        
            #  Append current file line to aggregate file.
        aggregated_df = rbind (aggregated_df, cur_run_df)
        }
    
    return (aggregated_df)
    }

#===============================================================================

write_aggregated_results_file <- 
    function (full_run_list, 
              aggregated_df, 
              runset_name, 
              top_dir_name_without_slash = "/Users/bill/tzar/outputdata/biodivprobgen/default_runset", 
              aggregated_file_name = "aggregated_prob_diff_results"
              ) 
    {
    run_range_start = full_run_list [1]
    run_range_end = full_run_list [length (full_run_list)]    
    run_range_string = paste0 ("runs_", run_range_start, "-", run_range_end)
    
    full_aggregated_filename = paste0 (top_dir_name_without_slash, 
                                       "/",
                                       aggregated_file_name, 
                                       "__", 
                                       runset_name, 
                                       ".", 
                                        run_range_string, 
                                        ".csv")
    write.csv (aggregated_df, 
               file = full_aggregated_filename, 
               row.names = FALSE)
    }

#===============================================================================

do_it = function (full_run_list, failed_run_list, top_dir_name_without_slash, 
                  runset_name)
    {
    cur_successful_run_list = 
        remove_failed_runs_from_full_run_list (full_run_list, failed_run_list)
        
    
    aggregated_df = 
        read_successful_results_into_aggregated_data_frame (cur_successful_run_list, 
                                                            top_dir_name_without_slash
                                                            )
    
    write_aggregated_results_file (cur_successful_run_list, 
                                   aggregated_df, 
                                   runset_name, 
                                   top_dir_name_without_slash
                                   )
    }

#===============================================================================

    #  Data old runs.

#       OLD...
# full_run_list = 1:327
# failed_run_list = c (4,6,7,9,12,14,33,34,37,41,45,46,47,
#                     54,65,66,69,71,72,73,77,80,81,84,92,98,
#                     104,115,116,120,124,126,128,129,133,143,147,
#                     151,154,159,163,172,183,184,189,196,197,
#                     201,202,203,205,206,207,214,215,219,220,226,234,245,249,
#                     258,267,268,277,279,282,288,290,291,292,298,
#                     303,304,307,312,313,314,321)

#===============================================================================

# full_run_list__test100unifRand_p_r_n_a_seed_301_with_error_trapping_and_timing = 1:100
# failed_run_list__test100unifRand_p_r_n_a_seed_301_with_error_trapping_and_timing = 
#     c (2, 3, 5, 9, 10, 11, 12, 13, 15, 19, 21, 23, 26, 28, 30, 
#        31, 33, 36, 37, 41, 42, 44, 46, 48, 51, 52, 54, 55, 56, 
#        57, 59, 60, 62, 63, 64, 65, 69, 70, 73, 74, 75, 76, 77, 
#        78, 83, 86, 87, 95, 96, 98, 99) 
# top_dir_name_without_slash_301 = "/Users/bill/tzar/outputdata/biodivprobgen/test100unifRand_p_r_n_a_seed_301_with_error_trapping_and_timing__GOOD_SAVE"
# 
# 
# do_it (full_run_list__test100unifRand_p_r_n_a_seed_301_with_error_trapping_and_timing, 
#        failed_run_list__test100unifRand_p_r_n_a_seed_301_with_error_trapping_and_timing, 
#        top_dir_name_without_slash_301)
# 
#===============================================================================

# full_run_list__test100unifRand_p_r_n_a_seed_401_with_error_trapping_and_timing = 1:100
# failed_run_list__test100unifRand_p_r_n_a_seed_401_with_error_trapping_and_timing = 
#     c (1, 2, 4, 7, 8, 12, 14, 20, 22, 25, 29, 31, 32, 37, 39, 40, 
#        41, 43, 45, 46, 47, 50, 52, 53, 55, 59, 62, 64, 65, 71, 72, 
#        77, 82, 83, 84, 86, 88, 91, 94, 95, 96, 98, 100)
# top_dir_name_without_slash_401 = "/Users/bill/tzar/outputdata/biodivprobgen/test100unifRand_p_r_n_a_seed_401_with_error_trapping_and_timing__GOOD_SAVE"
# 
#  
# do_it (full_run_list__test100unifRand_p_r_n_a_seed_401_with_error_trapping_and_timing, 
#        failed_run_list__test100unifRand_p_r_n_a_seed_401_with_error_trapping_and_timing, 
#        top_dir_name_without_slash_401)
# 
#===============================================================================

# full_run_list__test100unifRand_p_r_n_a_seed_501_with_error_trapping_and_timing = 1:100
# failed_run_list__test100unifRand_p_r_n_a_seed_501_with_error_trapping_and_timing = 
#     c (2, 4, 6, 8, 13, 19, 22, 23, 24, 25, 28, 29, 33, 37, 39, 40, 
#        41, 42, 43, 45, 49, 50, 53, 54, 55, 59, 67, 68, 71, 72, 75, 
#        76, 78, 79, 81, 88, 89, 91, 92, 93, 98, 99)
# top_dir_name_without_slash_501 = "/Users/bill/tzar/outputdata/biodivprobgen/test100unifRand_p_r_n_a_seed_501_with_error_trapping_and_timing__GOOD_SAVE"
# 
# 
# do_it (full_run_list__test100unifRand_p_r_n_a_seed_501_with_error_trapping_and_timing, 
#        failed_run_list__test100unifRand_p_r_n_a_seed_501_with_error_trapping_and_timing, 
#        top_dir_name_without_slash_501)
# 
#===============================================================================

# full_run_list__test100unifRand_p_r_n_a_seed_601_with_error_trapping_and_timing = 1:100
# failed_run_list__test100unifRand_p_r_n_a_seed_601_with_error_trapping_and_timing = 
#     c (3, 4, 6, 7, 8, 10, 11, 13, 16, 17, 19, 26, 27, 28, 30, 31, 
#        33, 34, 41, 42, 43, 44, 46, 47, 48, 49, 52, 57, 59, 61, 65, 
#        68, 79, 87, 90, 93, 94, 95, 97, 98, 99)
# top_dir_name_without_slash_601 = "/Users/bill/tzar/outputdata/biodivprobgen/test100unifRand_p_r_n_a_seed_601_with_error_trapping_and_timing__GOOD_SAVE"
# 
# 
# do_it (full_run_list__test100unifRand_p_r_n_a_seed_601_with_error_trapping_and_timing, 
#        failed_run_list__test100unifRand_p_r_n_a_seed_601_with_error_trapping_and_timing, 
#        top_dir_name_without_slash_601)
# 
#===============================================================================

# full_run_list__test100unifRand_p_r_n30_retry = 1:100
# failed_run_list__test100unifRand_p_r_n30_retry = c ()
# top_dir_name_without_slash_n30_retry = "/Users/bill/tzar/outputdata/biodivprobgen/test100unifRand_p_r_n30_retry__GOOD_SAVE"
# 
# 
# do_it (full_run_list__test100unifRand_p_r_n30_retry, 
#        failed_run_list__test100unifRand_p_r_n30_retry, 
#        top_dir_name_without_slash_n30_retry)

#===============================================================================

runset_name = test100unifRand_p_r_n_a_seed_701_in_phase_transition_area
full_run_list__test100unifRand_p_r_n_a_seed_701_in_phase_transition_area = 1:100
failed_run_list__test100unifRand_p_r_n_a_seed_701_in_phase_transition_area = 
    c(3, 4, 6, 7, 8, 9, 10, 13, 16, 17, 19, 26, 27, 28, 30, 
      33, 34, 41, 42, 43, 46, 47, 48, 49, 57, 59, 61, 65, 
      68, 79, 87, 90, 93, 94, 95, 97, 98, 99) 
top_dir_name_without_slash_701_in_phase = "/Users/bill/tzar/outputdata/biodivprobgen/test100unifRand_p_r_n_a_seed_701_in_phase_transition_area__GOOD_SAVE"


do_it (full_run_list__test100unifRand_p_r_n_a_seed_701_in_phase_transition_area, 
       failed_run_list__test100unifRand_p_r_n_a_seed_701_in_phase_transition_area, 
       top_dir_name_without_slash_701_in_phase, 
       runset_name)

#===============================================================================



