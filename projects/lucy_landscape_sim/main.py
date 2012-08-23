import glob
import os
import SpectralSynthesisFM2D
import Hydro_Network
import DecisionTree
import VegetationClassify 
import Geometry
import time
import pylab

import sys
print sys.path

time0 = time.time()
print("Running Spectral Synthesis code")
# sda = SpectralSynthesisFM2D.SpectralSynthesisFM2D(variables['max_level'],variables['sigma'],variables['seed'], variables['H'], variables['normalise'], variables['lowerBound'], variables['upperBound'])
sda = SpectralSynthesisFM2D.SpectralSynthesisFM2D(9, 1, 0, 0.7, True, 0, 255)

pylab.imsave('Output/ss_dem',sda)

time1 = time.time()
print("Time taken to generate DEM , with spectral synthesis is" , (time1 -time0),"seconds")

print("Running Digital Elevation Model and River Network module")
	  
da = Hydro_Network.RiverNetwork(0.7, 0.7, 0.65, 0.2, 0.4, 0.1,0, 1309)
# da = Hydro_Network.RiverNetwork(variables['H1'],variables['H1wt'],variables['H2'],variables['H2wt'],variables['H3'],variables['H3wt'],variables['elev_min'], variables['elev_max'])
time2 = time.time()
print("Time taken to generate DEM , River Network, Catchment Matrix is" , (time2 -time1),"seconds")
pylab.imsave("Output/DEM",da)
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
