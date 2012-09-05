import glob
import os
import SpectralSynthesisFM2D
import Hydro_Network
import time
import pylab
import LB_ArrayUtils

import basemodel

class Model(basemodel.BaseModel):
    def execute(self, runparams):
        # the logging levels are (in descending order): severe, warning, info, config, fine,
        # finer, finest
        # by default tzar will log all at info and above to the console, and all logging to a logfile.
        # if the --verbose flag is specified, all logging will also go to the console.
        # self.logger.fine("I'm in model.py!!")

        # get parameters qualified by input and output file paths
        # This is only required if you want to read / write input / output files from python.
        qualifiedparams = runparams.getQualifiedParams(self.inputpath, self.outputpath)

        # gets the variables, with (java) decimal values converted to python decimals
        # this is useful if you want to use arithmetic operations within python.
        variables = self.get_decimal_params(runparams)

# Line below is for testing outside the framework
# variables = dict(window_size=5, ascii_dem="Output/DEM.asc", output_features="Output/surfaceFeatures.srf", landserf_output="Output/landserf_results.txt", max_level=9, sigma=1, seed=0, normalise=True, H1=0.7, H2=0.65, H3=0.4, H1wt=0.7, H2wt=0.2, H3wt=0.1, elev_min=0, elev_max=1309, erosion_num=1, river_drop=5)

        # self.run_r_code("example.R", runparams)

# Create two lists of up to 5 H-values and weights TODO

# Create and add DEMs, using 3 H values and weights supplied TODO use these 4 lines, not the 2 below
        generated_DEMs = Hydro_Network.GenerateDEM(variables['H1'],variables['H1wt'],variables['H2'],variables['H2wt'],variables['H3'],variables['H3wt'],variables['elev_min'], variables['elev_max'])

        # pylab.imsave("Output/DEM_input1",generated_DEMs[1])
        # pylab.imsave("Output/DEM_input2",generated_DEMs[2])
        # pylab.imsave("Output/DEM_input3",generated_DEMs[3])

        # generated_DEMs =[]
        # generated_DEMs.append(SpectralSynthesisFM2D.SpectralSynthesisFM2D(variables['max_level'],variables['sigma'],variables['seed'], variables['H1'], variables['normalise'], variables['elev_min'], variables['elev_max']))
        # TODO remove the 2 lines above - this is just to speed up testing

##        # Run the hydro erosion the specified number of times.
##        erosion_runs = variables['erosion_num'] # TODO not really necessary
##        erodedDEMs = []
##        erodedDEMs.append(generated_DEMs[0])
##
##        for i in range(1,(erosion_runs+1)):
##        
##            newDEM = Hydro_Network.RiverNetwork(erodedDEMs[i-1], generated_DEMs, i, variables['river_drop'], qualifiedparams['output_dir'])
##            erodedDEMs.append(newDEM)
##        
##        # Now we should have the whole sequence of erosions - let's save them and see how it looks
##        DEM_filename = "%s/DEM_before_erosion" % (qualifiedparams['output_dir'])
##        pylab.imsave(DEM_filename, erodedDEMs[0])
####        for i in range(1,erosion_runs):
####            erodedDEMname = "Output/DEM_input%d" % i
####            pylab.imsave(erodedDEMname,erodedDEMs[i])

        # Now export the final DEM to an Arc ASCII format
        LB_ArrayUtils.writeArrayToFile(qualifiedparams['ascii_dem'], generated_DEMs[0], "Float", "E", 1)
        #LB_ArrayUtils.writeArrayToFile(qualifiedparams['ascii_dem'], erodedDEMs[i], "Float", "E", 1)

        print ("writing file to %s" % qualifiedparams['ascii_dem'])

        # Construct a command string for Landserf
        # input file = the DEM that was just written out 
        # output file = qualifiedparams['output_csv']
        # window size = variables['window_size']

        java_comm = "java -Djava.awt.headless=true -classpath .%s../../../lib/landserf/landserf230.jar%s../../../lib/landserf/utils230.jar RandomSurface" % (os.pathsep, os.pathsep)
        print "Java command is:"
        
        # NB - for Windows a semi-colon is needed, rather than a colon :-(

        # Append space and input file name TODO
        java_command = "%s \"%s\" \"%s\" %d \"%s\"" % (java_comm, qualifiedparams['ascii_dem'], qualifiedparams['output_features'], variables['window_size'], qualifiedparams['landserf_output']) 
        # java_command += qualifiedparams['ascii_dem']
        #java_command += qualifiedparams['output_features']
        # java_command += variables['window_size']
        #java_command += qualifiedparams['landserf_output']
        print java_command

        # cd to java directory TODO
        savedPath = os.getcwd()
        newPath = "%s/projects/lucy_morph/java" % savedPath
        os.chdir(newPath)
                
        # run java
        os.system(java_command)

        os.chdir(savedPath)
