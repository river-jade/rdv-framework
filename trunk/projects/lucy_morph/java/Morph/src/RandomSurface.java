import jwo.landserf.structure.*;   // For spatial object class.
import jwo.landserf.process.io.*;  // For file handling.
//import jwo.landserf.gui.SimpleGISFrame;

import java.io.File;
import jwo.landserf.process.SurfParam;
import jwo.landserf.process.SurfaceFeatureThread;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import jwo.landserf.process.RasterStats;

public class RandomSurface
{
    //------------------ Starter Method -----------------
    
    public static void main(String[] args)
    {
        // args[0] is the input file (relative path)
        // args [1] is the output file (relative path)
        // args[2] is the window size
        // args[3] is a text file with some summary statistics
        
        FakeGISFrame sgf = new FakeGISFrame();
        
        try// TODO replace and use the incoming args
        {
          // args are:
            //[0] String file name to read
            //[1] String srf file to write out
            //[2] window size to start with
            //[3] number of window sizes to try
            //[4] step size fr windows
            //[5] path and name of output csv file
            
            System.out.println("Trying to read file " + args[0]);

            RasterMap readRaster = LBTextRasterIO.readRaster(args[0], jwo.landserf.process.io.FileHandler.ARC_TEXT_R, sgf);
            
            BufferedWriter output = null;
            
            RasterStats rs = new RasterStats(readRaster);
            
            // Open file that results will go out to, and write out the general stats
            try 
            { 
                File file = new File(args[5]);

                output = new BufferedWriter(new FileWriter(file, true));
                
                output.write(rs.getFractalD() + ",");
                output.write(rs.getVariogramGradient() + ",");
                output.write(rs.getVariogramIntercept() + ",");
                output.write(rs.getMoran() + ",");
                output.write(rs.getKurtosis() + ",");
                output.write(rs.getSkew() + ",");
                    
                int windowSize = Integer.parseInt(args[2]);
                int windowCount = Integer.parseInt(args[3]);
                int windowStep = Integer.parseInt(args[4]);

                for (int wCount=0; wCount<windowCount; wCount++)
                {
                    readRaster.setWSize(windowSize);

                    System.out.println("About to calculate surface parameters with a window size of " + readRaster.getWSize());

                    sgf.addRaster(readRaster);

                    System.out.println("Original map is " + readRaster.getNumCols() + " by " + readRaster.getNumRows());

                    LBSurfaceFeatureThread sfThread = new LBSurfaceFeatureThread(sgf,2.2f);
                    sfThread.start();
                    try
                    {
                        sfThread.join(); // Join thread (i.e. wait until it is complete).

                        RasterMap sfRaster = sfThread.getSurfaceFetures();
                        System.out.println("Resulting map is " + sfRaster.getNumCols() + " by " + sfRaster.getNumRows());

                        //System.out.println("Writing out to " + args[1]);
                        //LandSerfIO.write(sfRaster, args[1]);

                        int[] results = sfRaster.getFrequencyDist(1,6,1);
                        int sfPixelNo = sfRaster.getNumCols() * sfRaster.getNumRows();

                        // Write out the results
                        output.write(Math.round(((float)results[0]/(float)sfPixelNo)*100) + ",");
                        output.write(Math.round(((float)results[1]/(float)sfPixelNo)*100) + ",");
                        output.write(Math.round(((float)results[2]/(float)sfPixelNo)*100) + ",");
                        output.write(Math.round(((float)results[3]/(float)sfPixelNo)*100) + ",");
                        output.write(Math.round(((float)results[4]/(float)sfPixelNo)*100) + ",");
                        output.write(Math.round(((float)results[5]/(float)sfPixelNo)*100) + ",");
                    }     
                    catch (InterruptedException e)
                    {
                            System.err.println("Error: Surface Feature generation thread interrupted.");
                    }
                    windowSize += windowStep;
                }
                output.write("\n");
                output.close();
                   
            }
            catch (IOException e)
            {

            }
        } 
        catch (Exception e)
        {
            System.out.println(e.getStackTrace()[0].toString());
            System.out.println(e.getMessage());
            
        }

    }

    //------------------- Constructor -------------------

    public RandomSurface()
    {
        
    }
}