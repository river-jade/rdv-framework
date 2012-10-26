import glob
#import SpectralSynthesisFM2D
import Hydro_Network
import time
import numpy
import pylab
from scipy import ndimage 
import Morphometry
import SummaryFileWriter

import basemodel

def import_file(full_path_to_module):
    try:
        import os
        module_dir, module_file = os.path.split(full_path_to_module)
        module_name, module_ext = os.path.splitext(module_file)
        save_cwd = os.getcwd()
        os.chdir(module_dir)
        module_obj = __import__(module_name)
        module_obj.__file__ = full_path_to_module
        globals()[module_name] = module_obj
        os.chdir(save_cwd)
    except:
        raise ImportError

#import_file('Y:/My Documents/GitHub/landscapeSim/Hydro_Network.py')
#import_file('Y:/My Documents/GitHub/landscapeSim/DecisionTree.py')
#import_file('Y:/My Documents/GitHub/landscapeSim/VegetationClassify.py')
#import_file('Y:/My Documents/GitHub/landscapeSim/Geometry.py')
#import_file('Y:/My Documents/GitHub/landscapeSim/surface_plot.py')

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

        # Create a holder for the results of the erosion iterations
        erosion_runs = variables['erosion_num'] # TODO not really necessary
        erodedDEMs = []
        
        # Create lists of file names and file titles - these will be populated as we go along, then written out to the 'index.html' file for quick views of results
        erodedDEMfileNames = [None] * erosion_runs
        erodedDEMfileTitles = [None] * erosion_runs
        catchmentFileNames = [None] * erosion_runs
        catchmentFileTitles = [None] * erosion_runs

        DEMinputFileNames = [None] * 3
        DEMinputFileTitles = [None] * 3
        DEMinputFileTitles[0] = "H %0.1f, wt %0.1f" % (variables['H1'],variables['H1wt'])
        DEMinputFileTitles[1] = "H %0.1f, wt %0.1f" % (variables['H2'],variables['H2wt'])
        DEMinputFileTitles[2] = "H %0.1f, wt %0.1f" % (variables['H3'],variables['H3wt'])
        # TODO - when numbers of inputs vary, make this a loop that responds to the number of H-values

        # Create two lists of up to 5 H-values and weights 
        H_values = [variables['H1'], variables['H2'], variables['H3']]
        H_weights = [variables['H1wt'], variables['H2wt'], variables['H3wt']]
        seeds = [variables['seed1'], variables['seed2'], variables['seed3']]
        elev_range = [variables['elev_min'], variables['elev_max']]

        # Call the DEM creator method which will create a composite elevation model
        generated_DEMs = Hydro_Network.DEM_creator(H_values, H_weights, seeds, elev_range, variables['max_level'], variables['DEMcreator_option'])

        for i in range(0,len(generated_DEMs[1])):
            file_name = "%s/%s" % (qualifiedparams['output_dir'],generated_DEMs[2][i])
            pylab.imsave(file_name, generated_DEMs[1][i])
            DEMinputFileNames[i] = "%s.png" % (generated_DEMs[2][i])

        # Run the hydro erosion the specified number of times.
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

            newDEM = erodedDEMs[i-1]
                                                
            # Create file names for writing out to HTML
            erodedDEMfileNames[i-1] = "Combined_eroded_DEM%d" % (i)
            catchmentFileNames[i-1] = "Catchment%d" % (i)
            erodedDEMfileTitles[i-1] = "Erosion step %d" % (i)
            catchmentFileTitles[i-1] = "Catchments %d" % (i)
          
            #Remove sink using 3x3 window by calling Single_Cell_PitRemove(originalDEM, no_of_itr)
            newDEM = Hydro_Network.Single_Cell_PitRemove(newDEM, no_of_itr = 6)
            (x_len,y_len) = newDEM.shape
            max_posn = ndimage.maximum_position(newDEM)
            Flow_dirn_arr = numpy.zeros((x_len,y_len,2), dtype="int" )
            #Flow_arr will be used for the purpose of catchment extraction
            Flow_arr = numpy.zeros((x_len, y_len), dtype = "uint8")
            River_arr = numpy.ones((x_len, y_len), dtype = "int")
            pit_list = [] #Not required now
            ( pit_list, Flow_dirn_arr, DEM ) = Hydro_Network.Get_Flow_Dirn_using_9x9_window(newDEM, Flow_dirn_arr, pit_list)
            # call Flow_Dirn_3x3(DEM, Flow_arr , pit_list) for the purpose of catchment extraction
            pit_list = [] #Required for catchment extraction
            ( pit_list, Flow_arr ) = Hydro_Network.Flow_Dirn_3x3(newDEM, Flow_arr , pit_list)
            
            #Catchment extraction, calling CatchmentExtraction(pit_list, DEM_arr, max_posn)
            (newDEM, Found_arr, Catchment_boundary_arr) = Hydro_Network.CatchmentExtraction(pit_list, newDEM, Flow_arr, max_posn)
            #Write result to Output file
            file_name = "%s/%s" % (qualifiedparams['output_dir'], catchmentFileNames[i-1])
            pylab.imsave(file_name, Found_arr)
            catchmentFileNames[i-1] += '.png'
            
            #file_name = "%s/Catchment_Boundary%s" % (qualifiedparams['output_dir'], i)
            #pylab.imsave(file_name, Catchment_boundary_arr)
            
            #Assignnig flow dirnection again after catchment extraction and Depression filling
            ( pit_list, Flow_dirn_arr, newDEM ) = Hydro_Network.Get_Flow_Dirn_using_9x9_window(newDEM, Flow_dirn_arr , pit_list)
            
            #Calculate flow accumulation by Calling Flow_accumulation(Flow_dirn_arr ,River_arr , DEM)
            River_arr = Hydro_Network.Flow_accumulation(Flow_dirn_arr ,River_arr, newDEM)
            #Write result to Output file
            #file_name = "%s/River%s" % (qualifiedparams['output_dir'],i)
            #pylab.imsave(file_name, River_arr)
            
            #"Eroding the DEM based on Distance from River ...Calling Erosion(River_arr,DEM_arr,river_drop)
            (newDEM, Distance_arr) = Hydro_Network.Erosion(River_arr, newDEM, variables['river_drop'])  
            #Write result to Output file
            file_name = "%s/%s" % (qualifiedparams['output_dir'], erodedDEMfileNames[i-1])
            pylab.imsave(file_name, newDEM)
            erodedDEMfileNames[i-1] += '.png'
            #file_name = "%s/RiverDistance%s" % (qualifiedparams['output_dir'], i)
            #pylab.imsave(file_name, Distance_arr)

            # Add this DEM to the list of eroded results
            erodedDEMs.append(newDEM)

            # Generate Landserf stats for this phase
            Morphometry.calculate_surface_features(qualifiedparams['ascii_dem'], erodedDEMs[i], qualifiedparams['output_features'], variables['window_size'], variables['window_count'], variables['window_step'], qualifiedparams['landserf_output']) 

            
        # Now we should have the whole sequence of erosions - let's save them and see how it looks
        DEM_filename = "%s/DEM_before_erosion" % (qualifiedparams['output_dir'])
        pylab.imsave(DEM_filename, erodedDEMs[0])

        #---------------------------------------------------------------------------
        # Write out details to HTML tables and hyperlinks
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
