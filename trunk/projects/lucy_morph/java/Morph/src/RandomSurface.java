import jwo.landserf.structure.*;   // For spatial object class.
import jwo.landserf.process.io.*;  // For file handling.
import jwo.landserf.gui.SimpleGISFrame;
import java.io.File;
import jwo.landserf.process.SurfParam;
import jwo.landserf.process.SurfaceFeatureThread;

public class RandomSurface
{
    //------------------ Starter Method -----------------
    
    public static void main(String[] args)
    {
        // args[0] is the input file (relative path)
        // args [1] is the output file (relative path)
        // args[2] is the window size
        
        SimpleGISFrame sgf = new SimpleGISFrame();
        
        args = new String[] {"../input_data/new_elev.asc", "../output_data/output_elev.srf","5"};
        try
        {
          
            File iF = new File(args[0]);
            System.out.println("Trying to read file " + iF.getAbsolutePath());

            if (!iF.exists())
            {
                System.out.println("File does not exist");
            }
            else
            {
                System.out.println("File exists");
            }
            RasterMap readRaster = TextRasterIO.readRaster(iF.getAbsolutePath(), jwo.landserf.process.io.FileHandler.ARC_TEXT_R, sgf, null);
            readRaster.setWSize(Integer.parseInt(args[2]));
            
            System.out.println("About to calculate surface parameters with a window size of " + readRaster.getWSize());
            
//            // Calculate surface parameters
//            SurfParam spChannel = new SurfParam(sgf, jwo.landserf.process.SurfParam.CHANNEL);
//            spChannel.findParam();
//            RasterMap channelRaster = spChannel.getSurfParam();
//            
//            LandSerfIO.write(channelRaster, "channel_" + args[1]);
            
            // System.out.println("Frame contains " + sgf.getRasterMaps().size() + " raster maps");
            sgf.addRaster(readRaster);
            
            // Calculate surface parameters
            System.out.println("about to calculate peaks...");
            SurfParam spPeak = new SurfParam(sgf, jwo.landserf.process.SurfParam.PEAK);
            spPeak.findParam();
            System.out.println("peaks calculated");
            
            RasterMap peakRaster = spPeak.getSurfParam();
            System.out.println("Resulting map is " + peakRaster.getNumCols() + " by " + peakRaster.getNumRows());
            
            File oF = new File(args[1]);
            String outPath = oF.getParent() + "peak_" + oF.getName();
            System.out.println("Writing out to " + outPath);
            LandSerfIO.write(peakRaster, outPath);
            
            SurfaceFeatureThread sfThread = new SurfaceFeatureThread(sgf,2.2f);
            sfThread.start();
            try
            {
                sfThread.join(); // Join thread (i.e. wait until it is complete).
                sfThread.doProcessing();
                
                RasterMap sfRaster = spPeak.getSurfParam();
                System.out.println("Resulting map is " + sfRaster.getNumCols() + " by " + peakRaster.getNumRows());
            
                String outPath2 = oF.getParent() + "\\sf_" + oF.getName();
                System.out.println("Writing out to " + outPath2);
                LandSerfIO.write(sfRaster, outPath2);
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
//        
//        for (int row=0; row<raster.getNumRows();row++)
//        {
//            for (int col=0; col<raster.getNumCols();col++)
//            {
//                raster.setAttribute(row,col,(float)Math.random()*100);        
//            }
//        }
        
    }

    //------------------- Constructor -------------------

    public RandomSurface()
    {
        
    }
}