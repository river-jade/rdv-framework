#===============================================================================

            #  gscp_13_write_marxan_control_file_and_run_marxan.R

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

