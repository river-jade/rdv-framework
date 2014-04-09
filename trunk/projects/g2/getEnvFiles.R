#===============================================================================

#  source ("getEnvFiles.R")

#===============================================================================

#  History

#  2014 02 01 - Created - BTL.
#  Extracted from g2.R.

#===============================================================================

    #--------------------------------------------------------------------------
    #  Contains 3 functions, but the first 2 are just support for the third 
    #  and are not likely to be used by any other code outside that function.
    #--------------------------------------------------------------------------

#  1)  matchFileLists ()
#  2)  verifyFileListCopiedCorrectly ()

#  3)  getEnvFiles ()
    
#===============================================================================

    #--------------------------------------------------------------------
    #  Have put this little bit of code into a function so that I can 
    #  easily test whether it works correctly when the file lists don't 
    #  match.  I just have to add one or more FALSE entries to the 
    #  fileListMatchTests argument before it's handed in, e.g., 
    #      fileListMatchTests [c(1,3)] = FALSE
    #      matchFileLists (fileListMatchTests, 
    #                      srcBaseNameList, targetBaseNameList)
    #--------------------------------------------------------------------

matchFileLists = 
    function (fileListMatchTests, srcBaseNameList, targetBaseNameList)
    {
    if (length (fileListMatchTests) != sum (fileListMatchTests))
        {
        #------------------------------------------------------------
        #  Fatal error: src and target file lists don't match.
        #
        #  Normally, I'd build an error message to hand to stop(), 
        #  but paste() didn't handle the which() output correctly 
        #  when I did that.  It made a separate copy of the rest of 
        #  the string for each element of the which() outcome.  
        #  Not sure why or if it can be fixed somehow...
        #------------------------------------------------------------
        
        cat ("\n\n*** In getEnvFiles(): ",
             "\n*** Source and target file lists ",
             "don't match at element(s): ",
             "\n***     ", which (! fileListMatchTests), 
             "\n*** fileListMatchTests = ", fileListMatchTests, 
             "\n*** srcBaseNameList = ", srcBaseNameList, 
             "\n*** targetBaseNameList = \n", targetBaseNameList,
             "\n\n")
        stop ()        
        } 
    }

#-------------------------------------------------------------------------------

    #  NOTE: This will also fail if the src and target directories have a 
    #        different number of files when the src files are written to 
    #        an existing directory using overwrite=TRUE and that directory 
    #        contains one or more files not in the src directory.  
    #        At the moment, I think that's what it should do, but there might 
    #        be some case in the future when that should become a legal option.

verifyFileListCopiedCorrectly = 
    function (srcDir, targetDir, filespec, verbose=TRUE)
    {
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

    matchFileLists (fileListMatchTests, srcBaseNameList, targetBaseNameList)
    }

#===============================================================================

#  This method of copying a list of files is based on:
#  http://stackoverflow.com/questions/2384517/using-r-to-copy-files

getEnvFiles = function (srcDir, targetDir, 
                        filespec = "*.asc", 
                        overwrite = FALSE, 
                        verbose=TRUE, 
                        dirSlash = dir.slash)
    {
        #---------------------------------------
        #  Get the list of files to copy from.
        #---------------------------------------
    
    srcFullNameList = list.files (srcDir, filespec, full.names = TRUE)
    if (verbose) 
        {
        cat ("\n\ngetEnvLayers()::at start, just before file.copy()")
        cat ("\n\    getEnvLayers()::srcDir = ", srcDir)
        cat ("\n\    getEnvLayers()::targetDir = ", targetDir)
        cat ("\n\    getEnvLayers()::srcFullNameList = ")
        print (srcFullNameList)
        }

    
#-------------------------------------------------------------------------------
#  NOTE:  srcFullNameList has EVERY file in the directory that matches the 
#         filespec (i.e., all .asc files).
#         In the project.yaml file and in some places in the code (e.g., 
#         in the clustering code I think), there is reference to what may 
#         be a subset of this file list, i.e., asciiImgFileNameRoots.  
#         It may be that this routine may need to be changed to make the 
#         list here match the asciiImgFileNameRoots list instead of all 
#         files in the directory.  At the moment, it doesn't seem to matter.
#         BTL - 2014 04 08
#-------------------------------------------------------------------------------

    
    
        #------------------------------------------------------------------
        #  If the target directory does not exist, create it now.
        #  If it does exist, then check whether to overwrite files there.
        #  If not, then quit.
        #------------------------------------------------------------------
    
    if (file.exists (targetDir))
        {
        if (! overwrite)
            {
            errMsg = paste0 ("\n\n*** In getEnvFiles(): ",
                             "\n*** overwrite = FALSE and targetDir = '",
                             targetDir, "'", 
                             "\n*** already exists.")
            stop (errMsg)
            }
        } else  #  Target does not exist yet, so create it now.
        {
        dir.create (targetDir, 
                    showWarnings = TRUE, 
                    recursive = TRUE, #  Not sure about this, but it's convenient.
                    mode = "0777")    #  Not sure if this is what we want for mode.
        }

        #-------------------------------------------------------------------
        #  Target directory exists now, so copy the list of files into it.
        #-------------------------------------------------------------------
            
    file.copy (srcFullNameList, targetDir)
    
        #--------------------------------------------------------------------
        #  Check to make sure that the copy worked, i.e., the list of files 
        #  in the target directory matches the list of files from the src.
        #  verifyFileListCopiedCorrectly() will quit if they don't.
        #--------------------------------------------------------------------
    
    verifyFileListCopiedCorrectly (srcDir, targetDir, filespec, verbose)
    
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

