#===============================================================================

                    #  gscp_14_read_marxan_output_files.R

#===============================================================================

timepoints_df = 
    timepoint (timepoints_df, "gscp_14", 
               "Starting gscp_14_read_marxan_output_files.R")

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
if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nAfter loading output_best.csv, marxan_best_df =")
    print (marxan_best_df)
    }

marxan_best_df = arrange (marxan_best_df, PUID)

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nAfter sorting, marxan_best_df = \n")
    print (marxan_best_df)
    cat ("\n\n-------------------")
    }

#---------------------------------

marxan_mvbest_df = 
    read.csv (paste (marxan_output_dir_path, marxan_output_mvbest_file_name, sep=''), 
              header=TRUE)

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nAfter loading output_mvbest.csv, marxan_mvbest_df =")
    print (marxan_mvbest_df)
    }

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

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nAfter sorting, marxan_mvbest_df = \n")
    print (marxan_mvbest_df)
    cat ("\n\n-------------------")
    }

#---------------------------------

marxan_ssoln_df = 
    read.csv (paste (marxan_output_dir_path, marxan_output_ssoln_file_name, sep=''),
              header=TRUE)
if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nAfter loading output_ssoln.csv, marxan_ssoln_df =")
    print (marxan_ssoln_df)    
    }

marxan_ssoln_df = arrange (marxan_ssoln_df, planning_unit)

if (DEBUG_LEVEL > 0)
    {
    cat ("\n\nAfter sorting, marxan_ssoln_df = \n")
    print (marxan_ssoln_df)
    cat ("\n\n-------------------")
    }

#===============================================================================

