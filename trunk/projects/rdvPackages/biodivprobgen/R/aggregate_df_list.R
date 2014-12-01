

full_run_list = 1:125
failed_run_list = c (1,2,6,7,11,12,16,17,21,22)
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


    #  Build current file name.
build_cur_file_name = function (run_num)
    {
    top_dir_name_w_slash = "/Users/bill/tzar/outputdata/biodivprobgen/default_runset/"
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



