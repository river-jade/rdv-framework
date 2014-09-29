#===============================================================================

library (reshape2)  #  for melt()
library (plyr)      #  for arrange()

#===============================================================================
#  This function will be used down below after the list of lists has been 
#  melted.  
#===============================================================================

gen_spp_PU_amount_table_from_melted_patch_spp_list =
    function (melted_patch_spp_list,
              sppAmount = 1  #  Default to same amount for every species
             )
    {
            #---------------------------------------------------------------
            #  Allow the caller to specify either a vector of species 
            #  amount values or just give a single amount to be replicated 
            #  into a vector full of that value.
            #  Need to make the check here be a little bit stricter and 
            #  throw an error if it's neither a vector of ints nor an 
            #  int, but for the moment, this works.
            #---------------------------------------------------------------
            
    if (! is.vector (sppAmount))
        {
        total_num_spp_PU_pairs = dim (melted_patch_spp_list) [1]
        sppAmount              = rep (sppAmount, total_num_spp_PU_pairs)        
        } 
    
            #------------------------------------------------------------
            #  This creation of the table could be generalized a bit by 
            #  allowing the passing in of the column names for the spp 
            #  and the planning units.  
            #  That would allow you to have a list of spp w/in patches 
            #  or patches w/in spp.
            #------------------------------------------------------------
             
    spp_PU_amount_table =
        data.frame (species = as.numeric (unlist (melted_patch_spp_list ["value"])),
                    pu      = as.numeric (unlist (melted_patch_spp_list ["L1"])),
                    amount  = sppAmount)
    
                cat ("\n\nBefore sorting, spp_PU_amount_table = \n")
                print (spp_PU_amount_table)
                cat ("\n\n-------------------")
    
        #----------------------------------------------------------------------
        #  Sort the table in ascending order by species within planning unit.
        #  Taken from Wickham comment in:
        #  http://stackoverflow.com/questions/1296646/how-to-sort-a-dataframe-by-columns-in-r
        #----------------------------------------------------------------------
    
    spp_PU_amount_table = arrange (spp_PU_amount_table, pu, species)
    
    return (spp_PU_amount_table)
    }

#===============================================================================
#  This section converts the list of lists into a table of species 
#  and planning units by using the melt() function.  
#  It could be turned into a function...
#===============================================================================

    #---------------------------------------------
    #  Convert the list of lists to a dataframe.
    #---------------------------------------------
    
            cat ("\n\nBefore melting, subsetsCollAsList = \n")
            print (subsetsCollAsList)
            cat ("\n\n-------------------")

melted_patch_spp_list = melt (subsetsCollAsList)
            cat ("\n\nAfter melting, melted_patch_spp_list = \n")
            print (melted_patch_spp_list)
            cat ("\n\n-------------------")

    #---------------------------------------------------------------
    #  Convert species and patch lists to vectors.
    #  Remove duplicates and sort too.
    #  Sorting isn't strictly necessary, but makes debugging and 
    #  inspecting the data easier.
    #
    #  NOTE: the melt() function arbitrarily labelled the patch ID 
    #  column "L1".
    #---------------------------------------------------------------

spp_IDs = sort (unlist (unique (melted_patch_spp_list ["value"])))
#num_spp = length (spp_IDs)

PU_IDs = sort (unlist (unique (melted_patch_spp_list ["L1"])))
#num_PUs = length (PU_IDs)

    #-------------------------------------------------------------
    #  Strip out just the patch and species information from the 
    #  melted data and make it into a table.
    #  Also, marxan requires the table to be sorted in 
    #  increasing order by planning unit.
    #-------------------------------------------------------------

spp_PU_amount_table =
    gen_spp_PU_amount_table_from_melted_patch_spp_list (melted_patch_spp_list)

            cat ("\n\nAfter sorting, spp_PU_amount_table = \n")
            print (spp_PU_amount_table)
            cat ("\n\n-------------------")

            #  Remove duplicates.  
            #  Not generally necessary?
            #  Had this in there because of an error in the subset routine.
            #  Should this be an error check and give a warning instead 
            #  of just being done blindly?
            #  Not sure when you would ever want to allow duplicates though.
            #  However, even if you don't allow duplicates, you might 
            #  want to flag the fact that they existed, since that may 
            #  often be an indication that there was an error in the 
            #  generator.
        spp_PU_amount_table = unique (spp_PU_amount_table)

            cat ("\n\nAfter unique(), spp_PU_amount_table = \n")
            print (spp_PU_amount_table)
            cat ("\n\n-------------------")

#===============================================================================
#  Ready to write the marxan input files now.
#===============================================================================

library (marxan)

write_marxan_pu.dat_input_file (PU_IDs)
write_marxan_spec.dat_input_file (spp_IDs)

        #-----------------------------------------------------------
        #  This commented code is what used to generate a random 
        #  distribution and has now been replaced with getting the 
        #  distribution from the list of lists, e.g., from 
        #  distribute.spp...().
        #  I'm just leaving it in here to show you the 
        #  correspondence between the two different schemes.
        #-----------------------------------------------------------

    # spp_PU_amount_table = gen_random_spp_PU_amount_table (num_PUs, num_spp)
    # write_marxan_puvspr.dat_input_file (spp_PU_amount_table)

write_marxan_puvspr.dat_input_file (spp_PU_amount_table)

#===============================================================================


