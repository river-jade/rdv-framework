# from PIL import Image
import random
import math
import pylab
import numpy

def SpectralSynthesisFM2D(max_level,sigma,seed,H,normalise, lbound, ubound):
  
  N = 2**max_level 
  A = numpy.zeros((N,N), dtype = complex)
  random.seed(seed) #seed the random number generator
  PI = 3.141592
  for i in range(0,N/2):
    for j in range(0,N/2):
      phase = 2*PI*random.random()#/random.randrange(1,Arand)
      if i != 0 or j != 0:
        rad = pow((i*i + j*j),(-(H+1)/2) )*random.gauss(0.0, sigma)
      else:
        rad = 0.0
      
      A[i][j] = rad*math.cos(phase) + rad*math.sin(phase)*j 
      
      if i ==0: 
        i0 = 0
      else:
        i0 = N - i
      
      if j==0:
        j0 = 0
      else:
        j0 = N - j
    
      A[i0][j0] = rad * math.cos(phase) - rad*math.sin(phase)*j
  
  for i in range(1,N/2):
    for j in range(1,N/2):
      phase = 2*PI*random.random()#/random.randrange(1,Arand)
      rad = pow((i*i + j*j),(-(H+1)/2) )*random.gauss(0.0, sigma)
      A[i][N-j] = rad * math.cos(phase) + rad* math.sin(phase)*j
      A[N-i][j] = rad * math.cos(phase) - rad* math.sin(phase)*j
  
  Grid = numpy.real(pylab.ifft2(( A ) ))
  if(normalise):
        Grid += numpy.amin(Grid)*-1 + lbound
        Grid = (Grid/numpy.amax(Grid)) * ubound
  return Grid

# def Main():
    # Grid = SpectralSynthesisFM2D(max_level = 9,sigma = 1,seed = 0,H= 0.70 ,normalise=True, lbound=0, ubound=255)
    # Image.fromarray(Grid).show()
# if __name__ == "__main__":
#     Main();
