
    #  This web page on dplyr may be useful to all this...
#  http://rpubs.com/justmarkham/dplyr-tutorial


JUST FINISHED - 2015 01 09 11:30 PM
full_run_list__test100unifRand_p_r_n_a_seed_301_with_error_trapping_and_timing = 1:100
failed_run_list__test100unifRand_p_r_n_a_seed_301_with_error_trapping_and_timing = 
    c (2, 3, 5, 9, 10, 11, 12, 13, 15, 19, 21, 23, 26, 28, 30, 
       31, 33, 36, 37, 41, 42, 44, 46, 48, 51, 52, 54, 55, 56, 
       57, 59, 60, 62, 63, 64, 65, 69, 70, 73, 74, 75, 76, 77, 
       78, 83, 86, 87, 95, 96, 98, 99) 


full_run_list__test100unifRand_p_r_n_a_seed_401_with_error_trapping_and_timing = 1:100
failed_run_list__test100unifRand_p_r_n_a_seed_401_with_error_trapping_and_timing = 
Failed IDs were: [1, 2, 4, 7, 8, 12, 14, 20, 22, 25, 29, 31, 32, 37, 39, 40, 41, 43, 45, 46, 47, 50, 52, 53, 55, 59, 62, 64, 65, 71, 72, 77, 82, 83, 84, 86, 88, 91, 94, 95, 96, 98, 100] 



full_run_list__test100unifRand_p_r_n_a_seed_501_with_error_trapping_and_timing = 1:100
failed_run_list__test100unifRand_p_r_n_a_seed_501_with_error_trapping_and_timing = 
Failed IDs were: [2, 4, 6, 8, 13, 19, 22, 23, 24, 25, 28, 29, 33, 37, 39, 40, 41, 42, 43, 45, 49, 50, 53, 54, 55, 59, 67, 68, 71, 72, 75, 76, 78, 79, 81, 88, 89, 91, 92, 93, 98, 99] 


full_run_list__test100unifRand_p_r_n_a_seed_601_with_error_trapping_and_timing = 1:100
failed_run_list__test100unifRand_p_r_n_a_seed_601_with_error_trapping_and_timing = 
Failed IDs were: [3, 4, 6, 7, 8, 10, 11, 13, 16, 17, 19, 26, 27, 28, 30, 31, 33, 34, 41, 42, 43, 44, 46, 47, 48, 49, 52, 57, 59, 61, 65, 68, 79, 87, 90, 93, 94, 95, 97, 98, 99] 


full_run_list = 1:327
failed_run_list = c (4,6,7,9,12,14,33,34,37,41,45,46,47,
                    54,65,66,69,71,72,73,77,80,81,84,92,98,
                    104,115,116,120,124,126,128,129,133,143,147,
                    151,154,159,163,172,183,184,189,196,197,
                    201,202,203,205,206,207,214,215,219,220,226,234,245,249,
                    258,267,268,277,279,282,288,290,291,292,298,
                    303,304,307,312,313,314,321)

full_run_list = 1:100
failed_run_list = failed_run_list__test100unifRand_p_r_n_a_seed_301_with_error_trapping_and_timing

successful_run_list = full_run_list
for (kkk in failed_run_list)
    {
    cat ("\nkkk = ", kkk)
    idx_to_remove = which (successful_run_list[]==kkk)
    cat ("\n    idx_to_remove = ", idx_to_remove)
    successful_run_list = successful_run_list [-idx_to_remove]
    cat ("\nsuccessful_run_list = \n")
    print (successful_run_list)
    }


num_successful_runs = length (successful_run_list)

#/Users/bill/tzar/outputdata/biodivprobgen/test100unifRand_p_r/99_default_scenario

    #  Build current file name.
build_cur_file_name = function (run_num)
    {
#    top_dir_name_w_slash = "/Users/bill/tzar/outputdata/biodivprobgen/default_runset/"
    top_dir_name_w_slash = "/Users/bill/tzar/outputdata/biodivprobgen/test500unifRand_p_r_n_a/"
#    run_num_dir_name_tail_w_slash = "_default_scenario/"
    run_num_dir_name_tail_w_slash = "_default_scenario/"
    file_name = "prob_diff_results.csv"
    
    full_cur_file_path = paste0 (top_dir_name_w_slash, 
                                 run_num, 
                                 run_num_dir_name_tail_w_slash, 
                                 file_name)
    
    return (full_cur_file_path)
    }

    #  Load current file.

full_cur_file_path = build_cur_file_name (successful_run_list [1])
aggregated_df = read.csv (full_cur_file_path, header=TRUE)

for (cur_run_num in successful_run_list [-1])
    {
    full_cur_file_path = build_cur_file_name (cur_run_num)
    cur_run_df = read.csv (full_cur_file_path, header=TRUE)

        #  Append current file line to aggregate file.
    aggregated_df = rbind (aggregated_df, cur_run_df)
    }

run_range_start = full_run_list [1]
run_range_end = full_run_list [length (full_run_list)]
top_dir_name_w_slash = "/Users/bill/tzar/outputdata/biodivprobgen/default_runset/"
aggregated_file_name = "aggregated_prob_diff_results."
run_range_string = paste0 ("runs_", run_range_start, "-", run_range_end)

full_aggregated_filename = paste0 (top_dir_name_w_slash, 
                                   aggregated_file_name, 
                                   run_range_string, 
                                   ".csv")

write.csv (aggregated_df, file = full_aggregated_filename, row.names = FALSE)



