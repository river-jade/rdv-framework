import java.awt.Dimension;
import java.io.*;
import java.util.StringTokenizer;

import jwo.landserf.process.LSThread;
import jwo.landserf.process.proj.Ellipsoid;
import jwo.landserf.process.proj.Projection;
import jwo.landserf.structure.*;
import jwo.landserf.process.io.FileIO;

// Referenced classes of package jwo.landserf.process.io:
//            FileIO

public class LBTextRasterIO extends FileIO
{

    private static final int USGS_FEET = 1;
    private static final int USGS_METRES = 2;
    private static final int USGS_ARC_SECONDS = 3;
    private static final int USGS_GEOGRAPHIC = 0;
    private static final int USGS_UTM = 1;
    private static final int USGS_STATE_PLANE = 2;
    private static final int USGS_NAD27 = 1;
    private static final int USGS_WGS72 = 2;
    private static final int USGS_WGS84 = 3;
    private static final int USGS_NAD83 = 4;
    private static int numHeaderLines;

    public LBTextRasterIO()
    {
    }

    public static RasterMap readRaster(String fileName, int fileFormat, FakeGISFrame gisFrame)
    {
        reset();
        numHeaderLines = 0;
        RasterMap raster = null;
        Dimension size = new Dimension();
        BufferedReader bufferedReader = null;
        StringBuffer notes = new StringBuffer();
        gisFrame.setProgress(0);
        try
        {
            bufferedReader = new BufferedReader(new FileReader(fileName));
        }
        catch(IOException e)
        {
            errorMessage = new String("Problem opening text file <" + fileName + ">");
            return null;
        }
        String typeName;
        Footprint originPixel = null;
        switch(fileFormat)
        {
        case 26: // '\032'
            typeName = new String("ArcGIS text raster");
            originPixel = readArcHeader(bufferedReader, size);
            try
            {
                bufferedReader.close();
                bufferedReader = new BufferedReader(new FileReader(fileName));
                for(int i = 0; i < numHeaderLines; i++)
                {
                    bufferedReader.readLine();
                }

            }
            catch(IOException e)
            {
                errorMessage = new String("Problem reading header of <" + fileName + ">");
                return null;
            }
            break;

        
        }
        if(originPixel == null || size.width == 0 || size.height == 0)
        {
            return null;
        }
        raster = new RasterMap(size.height, size.width, originPixel);
        raster.getHeader().setTitle((new File(fileName)).getName());
        raster.getHeader().setNotes("Imported from " + fileName + " in Arc ASCII format." + notes.toString());
        boolean success;
        
        success = readRasterRowPrime(bufferedReader, fileFormat, raster, gisFrame);
        if(success)
        {
            raster.setDefaultColours();
            gisFrame.setProgress(100);
            return raster;
        } else
        {
            gisFrame.setProgress(100);
            return null;
        }
    }

    
    private static Footprint readArcHeader(BufferedReader bufferedReader, Dimension size)
    {
        Footprint originPixel;
        originPixel = new Footprint(0.0F, 0.0F, 1.0F, 1.0F);
        numHeaderLines = 0;
        boolean isHeader;
        String word = null;
        isHeader = true;

        String line;
        StringTokenizer sToken;
            
        try
        {
            line = (new String(bufferedReader.readLine())).trim();
            sToken = new StringTokenizer(line);
            word = sToken.nextToken().toUpperCase();
            if(word.startsWith("NCOL"))
            {
                size.width = Integer.parseInt(sToken.nextToken());
            } 
            line = (new String(bufferedReader.readLine())).trim();
            sToken = new StringTokenizer(line);
            word = sToken.nextToken().toUpperCase();
            if(word.startsWith("NROW"))
            {
                size.height = Integer.parseInt(sToken.nextToken());
            } 
            line = (new String(bufferedReader.readLine())).trim();
            sToken = new StringTokenizer(line);
            word = sToken.nextToken().toUpperCase();
            if(word.startsWith("XLL"))
            {
                originPixel.setXOrigin(Float.parseFloat(sToken.nextToken()));
            } 
            line = (new String(bufferedReader.readLine())).trim();
            sToken = new StringTokenizer(line);
            word = sToken.nextToken().toUpperCase();
            if(word.startsWith("YLL"))
            {
                originPixel.setYOrigin(Float.parseFloat(sToken.nextToken()));
            } 
            line = (new String(bufferedReader.readLine())).trim();
            sToken = new StringTokenizer(line);
            word = sToken.nextToken().toUpperCase();
            if(word.startsWith("CELLSIZE"))
            {
                originPixel.setMERWidth(Float.parseFloat(sToken.nextToken()));
                originPixel.setMERHeight(originPixel.getMERWidth());
            } 
            line = (new String(bufferedReader.readLine())).trim();
            sToken = new StringTokenizer(line);
            word = sToken.nextToken().toUpperCase();
            if(word.startsWith("NODATA"))
            {
                substituteNull = true;
                nullCode = Float.parseFloat(sToken.nextToken());
            } 
        }           
        catch(IOException e)
        {
            errorMessage = new String("Problem opening ArcGIS header (" + e + ").");
            return null;
        }
           
        return originPixel;
    }


    private static boolean readRasterRowPrime(BufferedReader inFile, int fileType, RasterMap raster, FakeGISFrame gisFrame)
    {
        int row;
        int col;
        row = 0;
        col = 0;
         
        try
        {
            String line = new String(inFile.readLine());
            while (line != null)
            {
                lineNumber++;
                if(!line.trim().startsWith("#"))
                {
                    StringTokenizer sToken = new StringTokenizer(line);
                    int rowToRead;
                    rowToRead = row;

                    while(sToken.hasMoreTokens()) 
                    {
                        float rasterValue;
                        try
                        {
                            rasterValue = Float.valueOf(sToken.nextToken()).floatValue();
                            if(substituteNull && rasterValue == nullCode)
                            {
                                rasterValue = 1.401298E-045F;
                            } else
                            if(useMultiplier)
                            {
                                rasterValue *= zMultiplier;
                            }
                        }
                        catch(NumberFormatException e)
                        {
                            rasterValue = 1.401298E-045F;
                        }
                        raster.setAttribute(rowToRead, col, rasterValue);
                        if(col == raster.getNumCols() - 1)
                        {
                            col = 0;
                            row++;

                            rowToRead = row;

                            //gisFrame.setProgress((100 * row) / (raster.getNumRows() - 1));
                        } else
                        {
                            col++;
                        }
                    }
                }
                line = inFile.readLine();
            } 
        }
        catch (IOException e)
        {
            
        }
        return true;
    }

  
}
