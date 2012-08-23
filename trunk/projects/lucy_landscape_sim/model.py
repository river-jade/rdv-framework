import glob
import os
import SpectralSynthesisFM2D
import Hydro_Network
import DecisionTree
import VegetationClassify 
import Geometry
import time
import pylab

import basemodel

class Model(basemodel.BaseModel):
    def execute(self, runparams):
        self.logger.fine("I'm in model.py!!")

        # get parameters qualified by input and output file paths
        qualifiedparams = runparams.getQualifiedParams(self.inputpath, self.outputpath)

        variables = self.get_decimal_params(runparams)

        # This is how to run R code directly if you plan to:
        # however, in this example, R is called from python using rpy.
        # self.run_r_code("example.R", runparams)

        time0 = time.time()
        self.logger.fine("Running Spectral Synthesis code")
        sda = SpectralSynthesisFM2D.SpectralSynthesisFM2D(variables['max_level'],variables['sigma'],variables['seed'], variables['H'], variables['normalise'], variables['lowerBound'], variables['upperBound'])
        
        pylab.imsave(qualifiedparams['ssdem_output'],sda)

        time1 = time.time()
        self.logger.fine("Time taken to generate DEM , with spectral synthesis is" , (time1 -time0),"seconds")

##        self.logger.fine("Running Digital Elevation Model and River Network module")
##        da = Hydro_Network.RiverNetwork(variables['H1'],variables['H1wt'],variables['H2'],variables['H2wt'],variables['H3'],variables['H3wt'],variables['elev_min'], variables['elev_max'])
##        time2 = time.time()
##        self.logger.fine("Time taken to generate DEM , River Network, Catchment Matrix is" , (time2 -time1),"seconds")
##        pylab.imsave("Output/DEM",da)
##
##        DecisionTree.DecisionTree()
##        time3 = time.time()
##        self.logger.fine("Time taken to generate decision tree is " , (time3 - time2) ,"seconds")
##
##        time3 = time.time()
##        vc = VegetationClassify.VegetationClassify()
##        time4 = time.time()
##        self.logger.fine("Time taken to assign landcover is " , (time4 - time3),"seconds")
##
##        pylab.imsave("Output/Landcover",vc)
##
##        Geometry.GeometricFeature(min_area = 40,max_area = 400,aspect_ratio = 1.8,agri_area_limit = 0.3)
##        time5 = time.time()
##        self.logger.fine("Time taken to generate Geometric Features is " ,(time5 - time4) ,"seconds")
