#===============================================================================

setUpAndRunZonation = function (spp.list.filename,
                                zonation.files.dir,
                                zonation.input.maps.dir,
                                spp.used.in.reserve.selection.vector,
                                zonation.output.filename,
                                full.path.to.zonation.parameter.file,
                                full.path.to.zonation.exe,
                                runZonation,
                                sppFilePrefix,
                                closeZonationWindowOnCompletion
)
{
    zonation.spp.list.full.filename <-
        paste (zonation.files.dir, '/', spp.list.filename, sep ='' )
    
    if (file.exists (zonation.spp.list.full.filename))
        file.remove (zonation.spp.list.full.filename)
    
    #  Need to build the spp_list.dat file.
    #  In /Users/bill/D/rdv-svn/rdv-framework/trunk/framework2/rdv/lib/zonation/spp_list.dat
    #      1.0 1.0 2 10 1.0 /Users/ascelin/analysis/zonation/wine_test2_data/spp1.asc
    #      1.0 1.0 2 10 1.0 /Users/ascelin/analysis/zonation/wine_test2_data/spp2.asc
    #      1.0 1.0 2 10 1.0 /Users/ascelin/analysis/zonation/wine_test2_data/spp3.asc
    
    zonation.input.maps.dir = gsub ("Documents and Settings", "DOCUME~1", zonation.input.maps.dir)
    for (cur.spp.id in spp.used.in.reserve.selection.vector)
    {
        #		filename <- paste (zonation.input.maps.dir, '/', 'spp.', cur.spp.id, '.asc', sep = '' );
        ##		filename <- paste ('"', zonation.input.maps.dir, dir.slash, 'spp.',
        ##							cur.spp.id, '.asc', '"', sep = '' );
        #  sppFilePrefix is different for correct and apparent species.
        #  For apparent, it will just be "spp", but for correct,
        #  it will probably be something like "true.prob.dist.spp".
        filename <- paste (zonation.input.maps.dir, dir.slash, sppFilePrefix, '.',
                           cur.spp.id, '.asc', sep = '' );
        line.of.text <- paste ("1.0 1.0 1 1 1 ", filename, "\n", sep = "");
        cat (line.of.text, file = zonation.spp.list.full.filename, append = TRUE);
    }
    
    #  From /Users/bill/D/rdv-svn/rdv-framework/trunk/framework2/rdv/lib/zonation/README.txt
    #  Example to call zonation with wine on mac or linux:
    #  > wine zig2 -r Z_parameter_settings.dat spp_list.dat output.txt 0.0 0 1.0 1
    #  The last number in the list autoclose (if set to 0 then zonation will stay open after it finishes running)
    
    zonation.full.output.filename =
        paste (zonation.files.dir, '/', zonation.output.filename, sep='')
    
    #  Maxent's command line parsing chokes on Windows file names that
    #  contain spaces, so you need to put quotes around all the path
    #  or file names that you hand to it.
    filenameQuote = '"'
    
    full.path.to.zonation.exe = gsub ("Documents and Settings", "DOCUME~1", full.path.to.zonation.exe)
    full.path.to.zonation.parameter.file = gsub ("Documents and Settings", "DOCUME~1", full.path.to.zonation.parameter.file)
    zonation.spp.list.full.filename = gsub ("Documents and Settings", "DOCUME~1", zonation.spp.list.full.filename)
    zonation.full.output.filename = gsub ("Documents and Settings", "DOCUME~1", zonation.full.output.filename)
    
    
    
    
    ##	system.command.run.zonation <- paste (
    ##	######									'/sw/bin/wine',
    ##		filenameQuote,
    ##										full.path.to.zonation.exe,
    ##		filenameQuote, " ",
    ##
    ##										'-r', " ",
    ##		filenameQuote,
    ##										full.path.to.zonation.parameter.file,
    ##		filenameQuote, " ",
    ##
    ##		filenameQuote,
    ##										zonation.spp.list.full.filename,
    ##		filenameQuote, " ",
    ##
    ##		filenameQuote,
    ##										zonation.full.output.filename,
    ##		filenameQuote, " ",
    ##
    ##
    ##	#                                      "0.0 0 1.0 1" ,    #  close Zonation after finished
    ##										  "0.0 0 1.0 0" ,    #  stay open after finished
    ##										  sep='')
    
    
    ##if (closeZonationWindowOnCompletion)
    
    
    system.command.run.zonation <- paste (
        ######									'/sw/bin/wine',
        full.path.to.zonation.exe,
        '-r',
        full.path.to.zonation.parameter.file,
        zonation.spp.list.full.filename,
        zonation.full.output.filename,
        "0.0 0 1.0",
        as.integer (closeZonationWindowOnCompletion)
    )
    
    cat( '\n The system command to run zonation will be:', system.command.run.zonation, "'\n\n")
    
    #---------------------
    
    #  Can't run zonation under wine yet, so only allow it to be tried
    #  under Windows for now...
    
    cat("\n =====> The current wd is", getwd() )
    
    ##if (current.os == "mingw32")
    ##{
    #  Run Zonation.
    if (runZonation)
    {
        ##		system (system.command.run.zonation)
        
        ###		if( current.os == 'mingw32' )
        if (regexpr ("ming*", current.os) != -1)
            
        {
            ##			system.specific.cmd <- ''
            retval = system (system.command.run.zonation)
            
            ###			} else if (current.os == 'darwin9.8.0')                
        } else if (regexpr ("darwin*", current.os) != -1)
            
        {
            cat ("\n\n=====>  Can't run zonation on Mac yet since wine doesn't work properly yet.",
                 "\n=====>  Quitting now.\n\n",
                 sep='')
            
        } else
        {
            system.specific.cmd <- 'wine'
            cat ("\n\nAbout to run zonation using system.specific.cmd = '", system.specific.cmd, "'\n\n", sep='')
            
            
            
            ##		retval = system2( system.specific.cmd, args=system.command.run.zonation, env="DISPLAY=:1" )
            retval = system2( system.specific.cmd, args=system.command.run.zonation, env="DISPLAY=:1" )
        }
        
        cat ("\n\nzonation retval = '", retval, "'.\n\n", sep='')
        
    }
    ##}
}

#===============================================================================

