import jwo.landserf.structure.*;   // For spatial object class.
import jwo.landserf.process.io.*;  // For file handling.
import jwo.landserf.gui.SimpleGISFrame;
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
        
        SimpleGISFrame sgf = new SimpleGISFrame();
        
        try// TODO replace and use the incoming args
        {
          
            System.out.println("Trying to read file " + args[0]);

            RasterMap readRaster = TextRasterIO.readRaster(args[0], jwo.landserf.process.io.FileHandler.ARC_TEXT_R, sgf, null);
            readRaster.setWSize(Integer.parseInt(args[2]));
            
            System.out.println("About to calculate surface parameters with a window size of " + readRaster.getWSize());
            
            sgf.addRaster(readRaster);
            
            System.out.println("Original map is " + readRaster.getNumCols() + " by " + readRaster.getNumRows());
            
            SurfaceFeatureThread sfThread = new SurfaceFeatureThread(sgf,2.2f);
            sfThread.start();
            try
            {
                sfThread.join(); // Join thread (i.e. wait until it is complete).
                
                RasterMap sfRaster = sfThread.getSurfaceFetures();
                System.out.println("Resulting map is " + sfRaster.getNumCols() + " by " + sfRaster.getNumRows());
            
                System.out.println("Writing out to " + args[1]);
                LandSerfIO.write(sfRaster, args[1]);
                
                int[] results = sfRaster.getFrequencyDist(-10,10,1);
                int sfPixelNo = sfRaster.getNumCols() * sfRaster.getNumRows();
                RasterStats rs = new RasterStats(readRaster);
            
                // Write out the results
                try 
                { 
                    File file = new File(args[3]);
                    BufferedWriter output = new BufferedWriter(new FileWriter(file));
                    output.write("Pits " + ((float)results[0]/(float)sfPixelNo)*100 + "\n");
                    output.write("Channels " + ((float)results[1]/(float)sfPixelNo)*100 + "\n");
                    output.write("Passes " + ((float)results[2]/(float)sfPixelNo)*100 + "\n");
                    output.write("Ridges " + ((float)results[3]/(float)sfPixelNo)*100 + "\n");
                    output.write("Peaks " + ((float)results[4]/(float)sfPixelNo)*100 + "\n");
                    output.write("Planes " + ((float)results[5]/(float)sfPixelNo)*100 + "\n");
                    output.write(rs.toString());
                    output.close();

                }
                catch (IOException e)
                {

                }
            }
            catch (InterruptedException e)
            {
                System.err.println("Error: Surface Feature generation thread interrupted.");
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