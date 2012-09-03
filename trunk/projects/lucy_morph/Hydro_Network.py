import numpy
import scipy
import math
import pylab
import MapGeneration_pure_python
import Flow_accum
from scipy import ndimage
import city_block_dist_erosion

def pixel_exist(p,q,x_len,y_len):
  """Check weather the pixel lie within the boundary of the grid"""
  return ( (p >= 1) and (q >= 1) and ( p <= x_len - 2) and (q <= x_len-2) )

def GenerateDEM(H1, H1wt, H2, H2wt, H3, H3wt, elev_min, elev_max):

  print "Generating Digital Elevation Maps using FM2D algorithm"

  #Generate first DEM with gradient = 1 (i.e. TRUE) and high H value 
  DEM_arr1 = MapGeneration_pure_python.midPointFm2d(max_level = 9, sigma = 1, H = H1, addition = True,\
                        wrap = False, gradient = 1,seed = 0, normalise=True,lbound=elev_min, ubound=elev_max)

  #Generate second DEM with gradient = 0 (i.e. FLASE) and medium H value 
  DEM_arr2 = MapGeneration_pure_python.midPointFm2d(max_level = 9, sigma = 1, H = H2, addition = True,\
                        wrap = False, gradient = 0,seed = 65, normalise = True,lbound=elev_min, ubound=elev_max)

  #Generate third DEM with gradient = 0 (i.e. FLASE) and medium H value 
  DEM_arr3 = MapGeneration_pure_python.midPointFm2d(max_level = 9, sigma = 1, H = H3, addition = True,\
                        wrap = False, gradient = 0,seed = 6, normalise = True,lbound=elev_min, ubound=elev_max)

  DEM_arr_final = DEM_arr1
  (x_len,y_len) = DEM_arr_final.shape
  
  #Get the co-ordinates having highest elev , required for catchment extraction
  (max_x, max_y) = ndimage.maximum_position(DEM_arr_final)

  for i in range(0,x_len):
    for j in range(0,y_len):
      #Combine 3 DEM's 
      DEM_arr_final[i][j] = (H1wt * DEM_arr1[i][j]) + (H2wt * DEM_arr2[i][j]) + (H3wt * DEM_arr3[i][j])

  # Return a list containing all 4 DEMs
  # TODO allow 1-5 DEMs to be combined - vectors in, useful structure out
  returned_DEMs = [DEM_arr_final, DEM_arr1, DEM_arr2, DEM_arr3]
  
  return returned_DEMs  

def RiverNetwork(originalDEM, inputDEMs, counter, river_drop):

  (x_len,y_len) = originalDEM.shape
  (max_x, max_y) = ndimage.maximum_position(originalDEM)
  
  print "Iteratively removing sink using 3x3 window"
  for p in range(0,6):
    for i in range(1,x_len-1):
      for j in range(1,y_len-1):
        #Remove pits by 3 x 3 window
        A = min(originalDEM[i-1][j-1],originalDEM[i-1][j],originalDEM[i-1][j+1],\
                originalDEM[i][j-1],originalDEM[i][j+1],originalDEM[i+1][j-1],
                originalDEM[i+1][j],originalDEM[i+1][j+1])
        if originalDEM[i][j] < A:
          originalDEM[i][j] = A + 1

  #Initialize various arrays to hold flow direction, Flow accumulation,catchment info etc
  Flow_arr = numpy.zeros((x_len,y_len) , dtype = "uint8" )
  # River_arr will hold the River_accumulation matrix
  River_arr = numpy.ones((x_len,y_len) , dtype = "int" )
  # Catchment_boundary_arr will hold the Catchment boundaries
  Catchment_boundary_arr = numpy.zeros((x_len,y_len) , dtype = "uint8" )
  # Found_arr will hold the catchment with different labels
  Found_arr = numpy.zeros((x_len,y_len),dtype = "uint8")
  # Pour_point_arr keeps track of pour point of a catchment on the map
  Pour_point_arr = numpy.zeros((x_len,y_len),dtype = "uint8")
  Pour_point_list = [] #keep track of Pour_point in a list

  pit_list = [] #contains all the pit in DEM
  print "Assigning Flow Directions"
  for i in range(1,x_len-1): 
    for j in range(1,y_len-1):
      #Assign Flow direction
      (value,dirn) =max(((originalDEM[i][j] - originalDEM[i-1][j-1])/1.41,3),\
                    (originalDEM[i][j]-originalDEM[i-1][j],2),((originalDEM[i][j]-originalDEM[i-1][j+1])/1.41,1),\
                    (originalDEM[i][j] - originalDEM[i][j-1],4),(0,8),(originalDEM[i][j] - originalDEM[i][j+1],0),\
                    ((originalDEM[i][j] - originalDEM[i+1][j-1])/1.41,5),(originalDEM[i][j] - originalDEM[i+1][j],6),\
                    ((originalDEM[i][j] - originalDEM[i+1][j+1])/1.41,7))
      Flow_arr[i][j] = dirn
      if dirn == 8:
        # If there is a pit append it to the pit_list
        pit_list.append((i,j))

  label = 0 # will be used to assign labels to differnet catchments

#_____________Catchment Extraction_____________________________________________
  print "Extracting Catchment and filling Depressions"
  while len(pit_list) >= 1:
  #_______________For each and every pit in the DEM do _________________________
    stack = []
    pit = pit_list.pop(0)
    stack.append(pit)
    label = label + 1 #increase the label being assigned to the catchment 
    #_______________________Identify catchment for each and every pit
    catchment_pixels = []
    catchment_pixels.append((originalDEM[pit[0],pit[1]],pit[0],pit[1]))
    while len(stack) > 0:
      (p,q) = stack.pop(0)
      Found_arr[p][q] = label
      #Pop an element from stack check if its adjacent pixels exist and contribute 
      # its flow to the central pixel(pixel popped) then append it into list, continue
      # this while stack gets empty
      if pixel_exist(p-1,q-1,x_len,y_len):
        if Flow_arr[p-1][q-1] == 7:
          stack.append((p-1,q-1))
          catchment_pixels.append((originalDEM[p-1,q-1],p-1,q-1))
      if pixel_exist(p-1,q,x_len,y_len):
        if Flow_arr[p-1][q] == 6 :
          catchment_pixels.append((originalDEM[p-1,q],p-1,q))
          stack.append((p-1,q))
      if pixel_exist(p-1,q+1,x_len,y_len):
        if Flow_arr[p-1][q+1] == 5:
          catchment_pixels.append((originalDEM[p-1,q+1],p-1,q+1))
          stack.append((p-1,q+1))
      if pixel_exist(p,q-1,x_len,y_len):
        if Flow_arr[p][q-1] == 0 :
          catchment_pixels.append((originalDEM[p,q-1],p,q-1))
          stack.append((p,q-1))
      if pixel_exist(p,q+1,x_len,y_len):
        if Flow_arr[p][q+1] == 4:
          catchment_pixels.append((originalDEM[p,q+1],p,q+1))
          stack.append((p,q+1))
      if pixel_exist(p+1,q-1,x_len,y_len):
        if Flow_arr[p+1][q-1] == 1:
          catchment_pixels.append((originalDEM[p+1,q-1],p+1,q-1))
          stack.append((p+1,q-1))
      if pixel_exist(p+1,q,x_len,y_len):
        if Flow_arr[p+1][q] == 2 :
          catchment_pixels.append((originalDEM[p+1,q],p+1,q))
          stack.append((p+1,q))
      if pixel_exist(p+1,q+1,x_len,y_len):
        if Flow_arr[p+1][q+1] == 3 :
          catchment_pixels.append((originalDEM[p+1,q+1],p+1,q+1))
          stack.append((p+1,q+1))
    # Find catchment Outlet
    pour_point = (max_x, max_y)
    flag = 0
    for i in range(0,len(catchment_pixels)):
      (p,q) = ( catchment_pixels[i][1],catchment_pixels[i][2] )
      label = Found_arr[p][q]
      # Catchment Outlet will be the minimum catchment boundary pixel
      if (Found_arr[p-1][q-1] != label or Found_arr[p-1][q] != label or Found_arr[p-1][q+1] != label or 
         Found_arr[p][q-1] != label or Found_arr[p][q+1] != label or Found_arr[p+1][q-1] != label or
         Found_arr[p+1][q] != label or Found_arr[p+1][q+1] != label):# if pixel lie on boundary of catchment
        Catchment_boundary_arr[p][q] = 255
        if originalDEM[ pour_point[0] ][ pour_point[1] ] > originalDEM[p][q]:#if height of boundary is less then update pour point
          pour_point = (p,q)
          flag = 1
    if flag == 1:
      Pour_point_list.append((originalDEM[pour_point],pour_point[0],pour_point[1]))
      Pour_point_arr[pour_point] = 255
      for i in range(0,len(catchment_pixels)):
        if catchment_pixels[i][0] < originalDEM[pour_point]:
          #fill the depression in the catchment
          originalDEM[catchment_pixels[i][1],catchment_pixels[i][2]] = originalDEM[pour_point]

  print "Assignnig flow dirnection again after Depression filling"
  for i in range(1,x_len-1):
    for j in range(1,y_len-1):
    # Again assign Flow direction again after filling the depressions
      (value, dirn ) = max( ((originalDEM[i][j] - originalDEM[i-1][j-1])/1.41,3),(originalDEM[i][j] - originalDEM[i-1][j],2),((originalDEM[i][j] - originalDEM[i-1][j+1])/1.41,1),\
                            (originalDEM[i][j] - originalDEM[i][j-1],4),(0,8),(originalDEM[i][j] - originalDEM[i][j+1],0),\
                            ((originalDEM[i][j] - originalDEM[i+1][j-1])/1.41,5),(originalDEM[i][j] - originalDEM[i+1][j],6),((originalDEM[i][j] - originalDEM[i+1][j+1])/1.41,7))
      Flow_arr[i][j] = dirn
      if value <= 0:
        Flow_arr[i][j] = 8

  # Calculate flow accumulation by calling Generate_River function
  print "Performing Flow accumulation"
  
  River_arr  = Flow_accum.Generate_River( Flow_arr,River_arr,originalDEM)

  Distance_arr = city_block_dist_erosion.CityBlock(River_arr)
  # Create a mask for differnet distances used for DEM erosion
  print "Eroding DEM"
  mask4 = [ Distance_arr <= 15 ]
  mask5 = [ Distance_arr > 3 ]
  mask3 = [Distance_arr == 3]
  mask2 = [Distance_arr == 2]
  mask1 = [Distance_arr == 1]
  mask0 = [Distance_arr == 0]
  max_flow_accum = numpy.max(River_arr)

# TODO - maybe change the block below - have already combined the DEMs. Weight erosion more simply
  for i in range(0,x_len):
    for j in range(0,y_len):
      #Erode the landscape using diffent weighing factor for different distances from 
      #river while combining 3 DEM's 
##      if mask0[0][i][j] == True:
##        originalDEM[i][j] = 0.3*originalDEM[i][j] + 0.45*inputDEMs[2][i][j] + 0.19*inputDEMs[3][i][j]
##      elif mask1[0][i][j] == True:
##        originalDEM[i][j] = 0.3*originalDEM[i][j] + 0.46*inputDEMs[2][i][j] + 0.20*inputDEMs[3][i][j]
##      elif mask2[0][i][j] == True:
##        originalDEM[i][j] = 0.3*originalDEM[i][j] + 0.46*inputDEMs[2][i][j] + 0.21*inputDEMs[3][i][j]
##      elif mask3[0][i][j] == True:
##        originalDEM[i][j] = 0.3*originalDEM[i][j] + 0.46*inputDEMs[2][i][j] + 0.23*inputDEMs[3][i][j]
##      elif mask4[0][i][j] == True and mask5[0][i][j] == True:
##        originalDEM[i][j] = 0.3*originalDEM[i][j] + 0.47*inputDEMs[2][i][j] + 0.23*inputDEMs[3][i][j]
##      else:     
##        originalDEM[i][j] = 0.3*originalDEM[i][j] + 0.50*inputDEMs[2][i][j] + 0.25*inputDEMs[3][i][j]

      if mask0[0][i][j] == True:
        originalDEM[i][j] = originalDEM[i][j] - river_drop
      elif mask1[0][i][j] == True:
        originalDEM[i][j] = originalDEM[i][j] - (river_drop * 0.8)
      elif mask2[0][i][j] == True:
        originalDEM[i][j] = originalDEM[i][j] - (river_drop * 0.6)
      elif mask3[0][i][j] == True:
        originalDEM[i][j] = originalDEM[i][j] - (river_drop * 0.4)
      elif mask4[0][i][j] == True and mask5[0][i][j] == True:
        originalDEM[i][j] = originalDEM[i][j] - (river_drop * 0.2)
      else:     
        originalDEM[i][j] = originalDEM[i][j] - (river_drop * 0.1)
#Output different statistics for display and further use
  print "printing statistics ...see the Output Folder"
  
  numpy.save("River.npy",River_arr) 
  numpy.save("DEM.npy",originalDEM)

  River_file = "Output/River%d" % counter
  pylab.imsave(River_file, River_arr)

  Catchment_file = "Output/Catchment%d" % counter
  pylab.imsave(Catchment_file,Found_arr)

  Catchment_bound_file = "Output/CatchmentBounds%d" % counter
  pylab.imsave(Catchment_bound_file,Catchment_boundary_arr)

  DEM_file = "Output/Combined_eroded_DEM%d" % counter
  pylab.imsave(DEM_file, originalDEM)

  RiverDist_file = "Output/RiverDist%d" % counter
  pylab.imsave(RiverDist_file,Distance_arr)

  return originalDEM
