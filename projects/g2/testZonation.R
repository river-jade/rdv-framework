#===============================================================================

current.os <- sessionInfo()$R.version$os
cat ("\n\nos = '", current.os, "'\n", sep='')

#current.os = "darwin10.8.0"
#current.os = "mingw32"

output_path.mac = "/Users/Bill/tzar/outputdata/g2/default_runset/464_default_scenario"
#####output_path.windows.vmware = "C:\\Documents and Settings\\bill\\tzar\\outputdata\\g2\\default_runset\\464_default_scenario"
output_path.windows.vmware = "\\\\vmware-host\\Shared Folders\\Bill\\tzar\\outputdata\\g2\\default_runset\\464_default_scenario"
output_path.linux = "unknown linux output_path right now..."

    #  Imitate project.yaml.

parameters =  list()

parameters$userPath.mac = "/Users/Bill"
parameters$userPath.windows.vmware = "\\\\vmware-host\\Shared Folders\\Bill"
parameters$userPath.linux = "unknown linux userPath right now..."

parameters$rdvRootDir.mac = "D/rdv-framework"
parameters$rdvRootDir.windows.vmware = "D\\rdv-framework"
parameters$rdvRootDir.linux = "unknown linux rdvRootDir right now"

parameters$fullPathToZonationExe.mac = "D/rdv-framework/lib/zonation/zig3.exe"
parameters$fullPathToZonationExe.windows.vmware = "D\\rdv-framework\\lib\\zonation\\zig3.exe"
parameters$fullPathToZonationExe.linux = "unknown linux fullPathToZonationExe right now..."

parameters$fullPathToZonationParameterFile.mac = "D/rdv-framework/lib/zonation/Z_parameter_settings.dat"
parameters$fullPathToZonationParameterFile.windows.vmware = "D\\rdv-framework\\lib\\zonation\\Z_parameter_settings.dat"
parameters$fullPathToZonationParameterFile.linux = "unknown linux fullPathToZonationParameterFile right now..."
#PAR.zonation.parameter.filename = "Z:\\Bill\\D\\rdv-framework\\lib\\zonation\\Z_parameter_settings.dat"

parameters$sppFilePrefix = "spp"

parameters$runZonation = TRUE


parameters$closeZonationWindowOnCompletion = TRUE

#    PAR.zonation.spp.list.filename = zonation_spp_list.dat
#    PAR.zonation.output.filename = zonation_output

parameters$zonationAppSppListFilename = "zonation_app_spp_list.dat"
parameters$zonationAppOutputFilename = "zonation_app_output"

parameters$zonationCorSppListFilename = "zonation_cor_spp_list.dat"
parameters$zonationCorOutputFilename = "zonation_cor_output"

parameters$zonationFilesDirName = "Zonation"  #  $$output_path$$/Zonation

parameters$numSppInReserveSelection = 11    #  28    ##  100    #  No reserve selection yet.

parameters$writeToFile = TRUE




    #  Imitate initializeG2options.R.

  #  Default to mac paths.

dir.slash = "/"

if (current.os == "mingw32")
    {
    dir.slash = "\\"
    
    output_path = output_path.windows.vmware
    userPath = parameters$userPath.windows.vmware  
    
    rdvRootDir = parameters$rdvRootDir.windows.vmware
    fullPathToZonationExe = parameters$fullPathToZonationExe.windows.vmware
    fullPathToZonationParameterFile = parameters$fullPathToZonationParameterFile.windows.vmware
    #PAR.zonation.parameter.filename = "Z:\\Bill\\D\\rdv-framework\\lib\\zonation\\Z_parameter_settings.dat"    
    
    } else 
    {
    
    output_path = output_path.mac
    userPath = parameters$userPath.mac 
    
    rdvRootDir = parameters$rdvRootDir.mac
    fullPathToZonationExe = parameters$fullPathToZonationExe.mac    
    fullPathToZonationParameterFile = parameters$fullPathToZonationParameterFile.mac
    }

cat ("\n\noutput_path = ", output_path)
cat ("\nuserPath = ", userPath)
cat ("\n")

cat ("\n\n    fullPathToZonationExe = '", fullPathToZonationExe, "'", sep='')
cat ("\n    fullPathToZonationParameterFile = '", fullPathToZonationParameterFile, "'", sep='')


#fullMaxentOutputDirWithSlash = file.path (output_path, "MaxentOutputs")
fullMaxentOutputDirWithSlash = paste0 (output_path, dir.slash, "MaxentOutputs")

#sppGenOutputDirWithSlash = file.path (output_path, "SppGenOutputs")
sppGenOutputDirWithSlash = paste0 (output_path, dir.slash, "SppGenOutputs")

fullAnalysisDirWithSlash  = paste0 (output_path, dir.slash, 
                                    "ResultsAnalysis", dir.slash)
writeToFile = parameters$writeToFile


rdvRootDir = paste0 (userPath, dir.slash, rdvRootDir)

rdvSharedRsrcDir = paste0 (rdvRootDir, dir.slash, "R")
g2ProjectRsrcDir = paste0 (rdvRootDir, dir.slash, "projects", dir.slash, "g2")
#g2ProjectRsrcDirWithSlash = paste (g2ProjectRsrcDir, "/", sep='')

cat ("\n\nrdvRootDir = ", rdvRootDir, sep='')
cat ("\nrdvSharedRsrcDir = ", rdvSharedRsrcDir, sep='')
#cat ("\ng2ProjectRsrcDirWithSlash = ", g2ProjectRsrcDirWithSlash, sep='')
cat ("\n\n")

#  I think that this may already be done by tzar, but I'm not sure 
#  exactly where it does cd to at the start.  Need to put that in 
#  the documentation.
#  Just did a quick check.  Looks like it sets the working directory to 
#  projects/g2 in this case, which is the directory given on the command 
#  line for the execlocalruns command.  Not sure what it does when 
#  running from a repository instead of a local directory.
###############setwd (rdvRootDir)    #  Is this still necessary (and correct to do)?

source (paste0 (g2ProjectRsrcDir, dir.slash, 'read.R'))    #  Required for init...
source (paste0 (g2ProjectRsrcDir, dir.slash, 'w.R'))
source (paste0 (g2ProjectRsrcDir, dir.slash, 'g2Utilities.R'))
source (paste0 (g2ProjectRsrcDir, dir.slash, 'setUpAndRunZonation.R'))
source (paste0 (g2ProjectRsrcDir, dir.slash, 'evaluateZonationResults.R'))


runZonation = parameters$runZonation

if (runZonation)
    {
#     if (regexpr ("darwin*", current.os) != -1)
#         {
#         stop (paste0 ("\n\n=====>  Can't run zonation on Mac yet since wine doesn't work properly yet.",
#                       "\n=====>  Quitting now.\n\n"))
#         }

    zonationFilesDir = paste0 (output_path, dir.slash, parameters$zonationFilesDirName)

        #  Kluge to deal with lots of Windows problems running zonation
        #  using file names with embedded spaces.
        #  So far, they're all due to the "Documents and Settings" directory,
        #  so I'll deal with that.  In the Windows terminal window you can
        #  ask Windows for a no-spaces version of the name of a directory
        #  by using the -x option on dir, e.g., sitting above the
        #  "Documents and Settings" in C: and giving the command "dir /x", will
        #  list the shortened names of all the files and directories there,
        #  including "DOCUME~1 for "Documents and Settings".
        #  I think that these problems may primarily be coming from the use of
        #  the Windows environment variable called HOMEPATH to determine
        #  where to hang the temporary output directories.  I suspect that
        #  is what tzar is doing.  If we could get tzar to fix it up right
        #  when it's created, then none of this would be necessary here.
        #  Note, I found HOMEPATH by running the SET command with no arguments
        #  to see all declared variables in the environment, because a web site
        #  had mentioned that the similarly troublesome directory called
        #  "Program Files" has a name stored in the environment that you can
        #  use to avoid these space-based problems.

    zonationFilesDir = gsub ("Documents and Settings", "DOCUME~1", zonationFilesDir)
    zonationFilesDirWithSlash = paste0 (zonationFilesDir, dir.slash)
    
    cat ("\nzonationFilesDir before testing whether to create = '", zonationFilesDir, "'", sep='')
    if ( !file.exists (zonationFilesDir))  dir.create (zonationFilesDir)

        #  2014 02 19 - NOT SURE IF THIS SHOULD BE SET TO fullMaxentOutputDirWithSlash
        #               OR SOMETHING ELSE.  NEED TO SEE WHERE IT'S USED AND SEE IF
        #               SOMETHING IS BUILDING OFF SOMETHING LESS THAN THE FULL PATH.
        #       This may be a problem if you want to use something other than the
        #       maxent output as the zonation input !!!
    zonationAppInputMapsDir = fullMaxentOutputDirWithSlash
    zonationCorInputMapsDir = sppGenOutputDirWithSlash

        #  2014 02 19 - THIS NEEDS TO LINK UP WITH THE RESULTS OF COMPUTING THE
        #               NUMBER OF SPECIES BASED ON THE NUMBER OF CLUSTERS.
        #               PROBABLY MEANS THAT IT HAS TO BE SET JUST BEFORE ZONATION
        #               RUNNING SECTION IN G2, i.e., num.spp.in.reserve = numSpp...
        #               Should have the leading path?
    numSppInReserveSelection = parameters$numSppInReserveSelection
    sppUsedInReserveSelectionVector = 1:numSppInReserveSelection

    zonationAppSppListFilename = parameters$zonationAppSppListFilename
    zonationAppOutputFilename = parameters$zonationAppOutputFilename

    zonationCorSppListFilename = parameters$zonationCorSppListFilename
    zonationCorOutputFilename = parameters$zonationCorOutputFilename

    fullPathToZonationParameterFile = paste0 (userPath, dir.slash, fullPathToZonationParameterFile)
    fullPathToZonationExe = paste0 (userPath, dir.slash, fullPathToZonationExe)

    closeZonationWindowOnCompletion = parameters$closeZonationWindowOnCompletion

    sppFilePrefix = parameters$sppFilePrefix
    }

#stop ("\n***  END TEST SETUP  ***\n\n")

#===============================================================================

    #  APPARENT
cat ("\n\nJust before setUpAndRunZonation on APPARENT:")
cat ("\n    zonationAppSppListFilename = ", zonationAppSppListFilename)
cat ("\n    zonationFilesDir = ", zonationFilesDir)
cat ("\n    zonationAppInputMapsDir = ", zonationAppInputMapsDir)
cat ("\n    sppUsedInReserveSelectionVector = ", sppUsedInReserveSelectionVector)
cat ("\n    zonationAppOutputFilename = ", zonationAppOutputFilename)
cat ("\n    fullPathToZonationParameterFile = ", fullPathToZonationParameterFile)
cat ("\n    fullPathToZonationExe = ", fullPathToZonationExe)
cat ("\n    runZonation = ", runZonation)
cat ("\n    sppFilePrefix = ", sppFilePrefix)
cat ("\n    closeZonationWindowOnCompletion = ", closeZonationWindowOnCompletion)
cat ("\n\n")

setUpAndRunZonation (zonationAppSppListFilename,
                     zonationFilesDir,
                     zonationAppInputMapsDir,
                     sppUsedInReserveSelectionVector,
                     zonationAppOutputFilename,
                     fullPathToZonationParameterFile,
                     fullPathToZonationExe,
                     runZonation,
                     sppFilePrefix,
                     closeZonationWindowOnCompletion, 
                     dir.slash
                    )

    #  CORRECT
cat ("\n\nJust before setUpAndRunZonation on CORRECT:")
cat ("\n    zonationCorSppListFilename = ", zonationCorSppListFilename)
cat ("\n    zonationFilesDir = ", zonationFilesDir)
cat ("\n    zonationCorInputMapsDir = ", zonationCorInputMapsDir)
cat ("\n    sppUsedInReserveSelectionVector = ", sppUsedInReserveSelectionVector)
cat ("\n    zonationCorOutputFilename = ", zonationCorOutputFilename)
cat ("\n    fullPathToZonationParameterFile = ", fullPathToZonationParameterFile)
cat ("\n    fullPathToZonationExe = ", fullPathToZonationExe)
cat ("\n    runZonation = ", runZonation)
cat ("\n    true.prob.dist.spp = ", "true.prob.dist.spp")
cat ("\n    closeZonationWindowOnCompletion = ", closeZonationWindowOnCompletion)
cat ("\n\n")

setUpAndRunZonation (zonationCorSppListFilename,
                     zonationFilesDir,
                     zonationCorInputMapsDir,
                     sppUsedInReserveSelectionVector,
                     zonationCorOutputFilename,
                     fullPathToZonationParameterFile,
                     fullPathToZonationExe,
                     runZonation,
                     "true.prob.dist.spp",
                     closeZonationWindowOnCompletion, 
                     dir.slash
                    )


evaluateZonationResults (zonationFilesDirWithSlash, 
                         fullAnalysisDirWithSlash, 
                         writeToFile
                        )

#===============================================================================

