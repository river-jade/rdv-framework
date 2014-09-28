#====================================================================================

                #  source ('write_marxan_input_files.R')

#====================================================================================

write_marxan_pu.dat_input_file = function (PU_IDs)
    {
    num_PUs = length (PU_IDs)
    pu_cost_status_table = data.frame (id = PU_IDs,
                                       cost = rep (1, num_PUs),
                                       status = rep (0, num_PUs))

    write.table (pu_cost_status_table,
                 file="./pu.dat",
                 sep=",",
                 quote=FALSE,
                 row.names=FALSE)
    }

#-------------------------------------------------------------------------------

write_marxan_spec.dat_input_file = function (spp_IDs)
    {
    num_spp = length (spp_IDs)
    spp_target_spf_table = data.frame (id = spp_IDs,
                                       target = rep (1, num_spp),  #  prop?
                                       spf = rep (1, num_spp))

    write.table (spp_target_spf_table,
                 file="./spec.dat",
                 sep=",",
                 quote=FALSE,
                 row.names=FALSE)
    }

#-------------------------------------------------------------------------------

# choose_random_spp_for_patch = function (num_spp)
#     {
#     num_spp_for_patch = sample (1:num_spp, 1)
#     spp_for_patch = sample (1:num_spp, num_spp_for_patch, replace=FALSE)
#
#     return (spp_for_patch)
#     }

#-------------------------------------------------------------------------------

gen_random_spp_PU_amount_table =
        function (num_PUs, num_spp,
                  sppAmount = 1  #  Use same amount for every species
                 )
    {
#    sppAmount = 1  #  Use same amount for every species

    num_spp_in_PU = sample (1:num_spp, num_PUs, replace=TRUE)
    total_num_spp_PU_pairs = sum (num_spp_in_PU)

    spp_PU_amount_table =
        data.frame (species = rep (NA, total_num_spp_PU_pairs),
                    pu      = rep (NA, total_num_spp_PU_pairs),
                    amount  = rep (sppAmount, total_num_spp_PU_pairs))

    cur_table_row = 0
    for (cur_PU in 1:num_PUs)
        {
        spp_for_cur_PU = sample (1:num_spp,
                                 num_spp_in_PU [cur_PU],
                                 replace=FALSE)

        for (cur_spp in spp_for_cur_PU)
            {
            cur_table_row = cur_table_row + 1

            spp_PU_amount_table [cur_table_row, 1] = cur_spp
            spp_PU_amount_table [cur_table_row, 2] = cur_PU
            }
        }

    return (spp_PU_amount_table)
    }

#-------------------------------------------------------------------------------

write_marxan_puvspr.dat_input_file = function (spp_PU_amount_table)
    {
    write.table (spp_PU_amount_table,
                 file="./puvspr.dat",
                 sep=",",
                 quote=FALSE,
                 row.names=FALSE)
    }

#------------------------------------------------------------------

test_write_marxan_input_files <- function ()
    {
    seed = 1
    set.seed (seed)

    num_PUs = 100
    num_spp = 3

    PU_IDs = 1:num_PUs
    spp_IDs = 1:num_spp

    write_marxan_pu.dat_input_file (PU_IDs)
    write_marxan_spec.dat_input_file (spp_IDs)

    spp_PU_amount_table = gen_random_spp_PU_amount_table (num_PUs, num_spp)
    write_marxan_puvspr.dat_input_file (spp_PU_amount_table)
    }

#------------------------------------------------------------------
