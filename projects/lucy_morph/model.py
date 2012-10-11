import glob
import SpectralSynthesisFM2D
import Hydro_Network
import time
import pylab
import Morphometry
import SummaryFileWriter

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
        generated_DEMs = Hydro_Network.GenerateDEM(variables['H1'],variables['H1wt'],variables['H2'],variables['H2wt'],variables['H3'],variables['H3wt'],variables['elev_min'], variables['elev_max'], variables['seed1'], variables['seed2'], variables['seed3'])

        DEM1_file = "%s/DEM_input1" % (qualifiedparams['output_dir'])
        pylab.imsave(DEM1_file,generated_DEMs[1])
        DEM2_file = "%s/DEM_input2" % (qualifiedparams['output_dir'])
        pylab.imsave(DEM2_file,generated_DEMs[2])
        DEM3_file = "%s/DEM_input3" % (qualifiedparams['output_dir'])
        pylab.imsave(DEM3_file,generated_DEMs[3])

        # Run the hydro erosion the specified number of times.
        erosion_runs = variables['erosion_num'] # TODO not really necessary
        erodedDEMs = []
        erodedDEMs.append(generated_DEMs[0])

        wsz = variables['window_size']
        
        # Open file to write out Landserf results
        f = open(qualifiedparams['landserf_output'], 'w')
        
        f.write("FractalDimension,VariogramGradient,VariogramIntercept,Moran,Kurtosis,Skew,")
        
        for x in range(0,variables['window_count']):
            
            # Write headers
            f.write(("Pits%d,Channels%d,Passes%d,Ridges%d,Peaks%d,Planes%d") % (wsz,wsz,wsz,wsz,wsz,wsz))
            if x<(variables['window_count']-1):
                f.write(",")
            else:
                f.write("\n")
            wsz = wsz + variables['window_step']
        # Close file
        f.close()

        for i in range(1,(erosion_runs+1)):
        
            newDEM = Hydro_Network.RiverNetwork(erodedDEMs[i-1], generated_DEMs, i, variables['river_drop'], qualifiedparams['output_dir'])
            # TODO return a vector of different things - the DEM, the file name of the DEM image and the filename of the catchments image
            erodedDEMs.append(newDEM)

            # Generate Landserf stats for this phase
            Morphometry.calculate_surface_features(qualifiedparams['ascii_dem'], erodedDEMs[i], qualifiedparams['output_features'], variables['window_size'], variables['window_count'], variables['window_step'], qualifiedparams['landserf_output']) 
        
        # Now we should have the whole sequence of erosions - let's save them and see how it looks
        DEM_filename = "%s/DEM_before_erosion" % (qualifiedparams['output_dir'])
        pylab.imsave(DEM_filename, erodedDEMs[0])

        for i in range(1, (erosion_runs+1)):
            Catchment_file = "%s/Catchment%d.png" % (qualifiedparams['output_dir'], i)

        for i in range(1, (erosion_runs+1)):
            DEM_file = "%s/Combined_eroded_DEM%d.png" % (qualifiedparams['output_dir'], i)

        #---------------------------------------------------------------------------
        # Create details to be written out to HTML table
        DEMinputFileNames = [None] * 3
        DEMinputFileNames = ["DEM_input1.png", "DEM_input2.png", "DEM_input3.png"]
        DEMinputFileTitles = [None] * 3
        DEMinputFileTitles[0] = "H %0.1f, wt %0.1f" % (variables['H1'],variables['H1wt'])
        DEMinputFileTitles[1] = "H %0.1f, wt %0.1f" % (variables['H2'],variables['H2wt'])
        DEMinputFileTitles[2] = "H %0.1f, wt %0.1f" % (variables['H3'],variables['H3wt'])

        erodedDEMfileNames = [None] * erosion_runs
        erodedDEMfileTitles = [None] * erosion_runs
        catchmentFileNames = [None] * erosion_runs
        catchmentFileTitles = [None] * erosion_runs

        for i in range(0,erosion_runs):

          erodedDEMfileNames[i] = "Combined_eroded_DEM%d.png" % (i+1)
          catchmentFileNames[i] = "Catchment%d.png" % (i+1)
          erodedDEMfileTitles[i] = "Erosion step %d" % (i+1)
          catchmentFileTitles[i] = "Catchments %d" % (i+1) 
            
        index_file = "%s/index.html" % qualifiedparams['output_dir']
        indexF = SummaryFileWriter.open_file(index_file)   
        SummaryFileWriter.writeHTMLTop("Run results", indexF)

        SummaryFileWriter.writeURL("Collated Landserf output", "output.csv", indexF)
        SummaryFileWriter.writeURL("Run parameters", "parameters.yaml", indexF)
        SummaryFileWriter.writeURL("Run log", "logging.log", indexF)

        SummaryFileWriter.writeHTMLTable("Input DEMs", DEMinputFileNames, DEMinputFileTitles, 8, indexF)
        SummaryFileWriter.writeHTMLTable("Erosion steps", erodedDEMfileNames, erodedDEMfileTitles, 8, indexF)
        SummaryFileWriter.writeHTMLTable("Catchment evolution", catchmentFileNames, catchmentFileTitles, 8, indexF)

        SummaryFileWriter.writeHTMLBottom(indexF)
