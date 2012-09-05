import java.util.Vector;
import jwo.landserf.structure.*;

public class FakeGISFrame
{
    private RasterMap rast1;
    private RasterMap rast2;
    private VectorMap vect1;
    private VectorMap vect2;
    private Vector rasterMaps;
    private Vector vectorMaps;

    public FakeGISFrame()
    {
        super();
        rasterMaps = new Vector();
        vectorMaps = new Vector();
    }

    public void addRaster(RasterMap newRast)
    {
        addRaster(newRast, 1);
    }

    public void addRaster(RasterMap newRast, int selection)
    {
        if(selection == 1)
        {
            rast1 = newRast;
        } else
        if(selection == 2)
        {
            rast2 = newRast;
        }
        rasterMaps.add(newRast);
    }

    public void addVectorMap(VectorMap newVect)
    {
        addVectorMap(newVect, 1);
    }

    public void addVectorMap(VectorMap newVect, int selection)
    {
        if(selection == 1)
        {
            vect1 = newVect;
        } else
        if(selection == 2)
        {
            vect2 = newVect;
        }
        vectorMaps.add(newVect);
    }

    public void removeSpatialObjects()
    {
        rasterMaps.clear();
        vectorMaps.clear();
        rast1 = null;
        rast2 = null;
        vect1 = null;
        vect2 = null;
    }

    public void removeSpatialObject(SpatialObject spObj)
    {
        if(spObj instanceof RasterMap)
        {
            rasterMaps.remove(spObj);
            if(rast1 == spObj)
            {
                rast1 = null;
            } else
            if(rast2 == spObj)
            {
                rast2 = null;
            }
        } else
        if(vect1 == spObj)
        {
            vect1 = null;
        } else
        if(vect2 == spObj)
        {
            vect2 = null;
        }
    }

    public void setRaster1(RasterMap raster)
    {
        if(!rasterMaps.contains(raster))
        {
            addRaster(raster, 1);
        } else
        {
            rast1 = raster;
        }
    }
    
    public void setMessage(String s)
    {
        
    }

    public void setProgress(int i)
    {
        
    }

    public void setVectorMap1(VectorMap vectorMap)
    {
        if(!vectorMaps.contains(vectorMap))
        {
            addVectorMap(vectorMap, 1);
        } else
        {
            vect1 = vectorMap;
        }
    }

    public void setVectorMap2(VectorMap vectorMap)
    {
        if(!vectorMaps.contains(vectorMap))
        {
            addVectorMap(vectorMap, 2);
        } else
        {
            vect2 = vectorMap;
        }
    }

    public RasterMap getRaster1()
    {
        return rast1;
    }

    public RasterMap getRaster2()
    {
        return rast2;
    }

    public Vector getRasterMaps()
    {
        return rasterMaps;
    }

    public VectorMap getVectorMap1()
    {
        return vect1;
    }

    public VectorMap getVectorMap2()
    {
        return vect2;
    }

    public Vector getVectorMaps()
    {
        return vectorMaps;
    }
}
