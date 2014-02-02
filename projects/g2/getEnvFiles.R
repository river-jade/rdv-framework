#===============================================================================

#  source ("getEnvFiles.R")

#===============================================================================

#  History

#  2014 02 01 - Created - BTL.
#  Extracted from g2.R.

#===============================================================================

#  This method of copying a list of files is based on:
#  http://stackoverflow.com/questions/2384517/using-r-to-copy-files

getEnvFiles = function (srcDir, targetDir, 
                         filespec = "*.asc", 
                         verbose=TRUE, 
                         dirSlash = dir.slash)
{
    #-----------------------------------------------------------------------
    #  Get the list of files to copy from, then copy them to the target dir.
    #-----------------------------------------------------------------------
    
    srcFullNameList = list.files (srcDir, filespec, full.names = TRUE)
    if (verbose) 
        {
        cat ("\n\ngetEnvLayers()::at start, just before file.copy()")
        cat ("\n\    getEnvLayers()::srcDir = ", srcDir)
        cat ("\n\    getEnvLayers()::targetDir = ", targetDir)
        cat ("\n\    getEnvLayers()::srcFullNameList = ")
        print (srcFullNameList)
        }
    
    file.copy (srcFullNameList, targetDir)
    
    #--------------------------------------------
    #  Check to make sure that the copy worked.
    #--------------------------------------------
    
    srcBaseNameList = list.files (srcDir, filespec, full.names = FALSE)
    if (verbose) 
    {
        cat ("\n\nsrcBaseNameList = \n")
        print (srcBaseNameList)
    }
    
    targetBaseNameList = list.files (targetDir, filespec, full.names = FALSE)
    if (verbose) 
    {
        cat ("\n\ntargetBaseNameList = \n")
        print (targetBaseNameList)
    }
    
    cat ("\n\n============  About to test match  ===============")
    fileListMatchTests = (srcBaseNameList == targetBaseNameList)
    #    fileListMatchTests [4] = FALSE  #  To force test of mismatch...
    cat ("\n\n  ----------  fileListMatchTests = ", fileListMatchTests, "\n\n")
    if (length (fileListMatchTests) != sum (fileListMatchTests))
    {
        cat ("\n\n***** QUITTING:  Source and target file lists don't match in getEnvLayers(). *****")
        cat ("\n", fileListMatchTests, "\n\n")
        quit()        
    } 
    
    if (verbose) cat ("\n\nsrcBaseNameList DOES EQUAL targetBaseNameList.")
    
    #---------------------------------------------------------------------
    #  Make the list of new files available downstream.
    #  Not sure if this will be necessary, but I have it in hand right 
    #  now so I'll return it.  Can always remove it later if not needed.
    #---------------------------------------------------------------------
    
    targetFullNameList = list.files (targetDir, filespec, full.names = TRUE)
    if (verbose) 
    {
        cat ("\n\ntargetFullNameList = \n")        
        print (targetFullNameList)
    }
    
    return (targetFullNameList)
}

#===============================================================================

