import LB_ArrayUtils, os

def calculate_surface_features(temp_ascii_dem, input_array, output_srf, window_size, output_text_file, erosions):
    
    # Now export the final DEM to an Arc ASCII format
    LB_ArrayUtils.writeArrayToFile(temp_ascii_dem, input_array, "Float", "E", 1)

    print ("writing file to %s" % temp_ascii_dem)

    # Construct a command string for Landserf

    java_comm = "java -classpath .%s../../../lib/landserf/landserf230.jar%s../../../lib/landserf/utils230.jar RandomSurface" % (os.pathsep, os.pathsep)
    print "Java command is:"

    # NB - for Windows a semi-colon is needed, rather than a colon :-(

    # Append space and input file name 
    java_command = "%s \"%s\" \"%s\" %d \"%s\" %d" % (java_comm, temp_ascii_dem, output_srf, window_size, output_text_file, erosions) 
    print java_command

    # cd to java directory 
    savedPath = os.getcwd()
    newPath = "%s/projects/lucy_morph/java" % savedPath
    os.chdir(newPath)
            
    # run java
    os.system(java_command)

    os.chdir(savedPath)
