import java.io.PrintStream;
import java.util.Iterator;
import java.util.Vector;
import jwo.landserf.process.proj.Projection;
import jwo.landserf.structure.*;
import jwo.utils.structure.JWPriorityQueue;

// Referenced classes of package jwo.landserf.process:
//            LSThread

public class LBSurfaceFeatureThread extends LBLSThread
{
    private class RasterCell
        implements Comparable
    {

        private RasterPosition cell;
        private RasterCell parentCell;

        public RasterPosition getPosition()
        {
            return cell;
        }

        public RasterCell getParent()
        {
            return parentCell;
        }

        public int compareTo(Object o)
        {
            return cell.compareTo(((RasterCell)o).getPosition());
        }

        public String toString()
        {
            return new String(cell + " parent: [" + parentCell + "]");
        }

        public RasterCell(RasterPosition cell, RasterCell parentCell)
        {
            this.cell = cell;
            this.parentCell = parentCell;
        }
    }

    private class RasterPosition
        implements Comparable
    {

        public int row;
        public int col;

        public Integer getOffset()
        {
            return new Integer(row * 16384 + col);
        }

        public int compareTo(Object o)
        {
            return getOffset().compareTo(((RasterPosition)o).getOffset());
        }

        public String toString()
        {
            return new String("(" + row + "," + col + ")");
        }

        public RasterPosition(int row, int col)
        {
            this.row = row;
            this.col = col;
        }

        public RasterPosition(RasterPosition pos)
        {
            row = pos.row;
            col = pos.col;
        }
    }

    private FakeGISFrame gisFrame;
    private float minDrop;
    private int visitedR[][];
    private Vector visitedV;
    private int visitID;
    private RasterPosition passLocation;
    private RasterMap dem;
    private RasterMap features;
    private VectorMap featureNetwork;
    private VectorMap overlay;

    public LBSurfaceFeatureThread(FakeGISFrame gisFrame, float minDrop)
    {
        super("Classifying surface features...", gisFrame);
        this.gisFrame = gisFrame;
        this.minDrop = minDrop;
        
    }

    public void doProcessing()
    {
        if(minDrop == 1.401298E-045F)
        {
            setErrorMessage("No minimum drop/climb set");
            return;
        }
        dem = gisFrame.getRaster1();
        if(dem == null)
        {
            setErrorMessage("No DEM provided for classification.");
            return;
        }
        if(minDrop <= 0.0F)
        {
            setErrorMessage("Minimum drop must be greater than 0.");
            return;
        }
        Footprint fp = new Footprint(dem.getBounds());
        fp.setMERWidth(dem.getXRes());
        fp.setMERHeight(dem.getYRes());
        features = new RasterMap(dem.getNumRows(), dem.getNumCols(), fp);
        features.setProjection(new Projection(dem.getProjection()));
        featureNetwork = null;
        for(int row = 0; row < features.getNumRows(); row++)
        {
            for(int col = 0; col < features.getNumCols(); col++)
            {
                features.setAttribute(row, col, 0.0F);
            }

        }

        JWPriorityQueue summitHierarchy = new JWPriorityQueue();
        visitedV = new Vector();
        visitedR = new int[dem.getNumRows()][dem.getNumCols()];
        visitID = 0;
        StringBuffer featureNotes = new StringBuffer("Feature classification of " + dem.getHeader().getTitle() + " with");
        featureNotes.append(" relative drop of " + minDrop + " surrounding the summit/immit");
        if(checkStoppedThread())
        {
            visitedR = null;
            features = null;
            return;
        }
        System.out.println("Finding summit/pass locations...");
        for(int row = 0; row < features.getNumRows(); row++)
        {
            if(checkStoppedThread())
            {
                visitedR = null;
                features = null;
                return;
            }
            for(int col = 0; col < features.getNumCols(); col++)
            {
                float startHeight = dem.getAttribute(row, col);
                if(startHeight >= dem.getMinAttribute() + minDrop && features.getAttribute(row, col) == 0.0F)
                {
                    float drop = findDrop(row, col, minDrop, false, false);
                    if(drop >= minDrop)
                    {
                        Vector summits = new Vector();
                        float xBar = 0.0F;
                        float yBar = 0.0F;
                        int numPeakPoints = 0;
                        for(Iterator i = visitedV.iterator(); i.hasNext();)
                        {
                            RasterPosition p = ((RasterCell)i.next()).getPosition();
                            float dropFromSummit = startHeight - dem.getAttribute(p.row, p.col);
                            if(dropFromSummit <= drop)
                            {
                                xBar += p.col;
                                yBar += p.row;
                                numPeakPoints++;
                                features.setAttribute(p.row, p.col, 6F);
                                if(dropFromSummit == 0.0F)
                                {
                                    summits.add(new RasterPosition(p));
                                }
                            }
                        }

                        if(summits.size() == 1)
                        {
                            features.setAttribute(row, col, 5F);
                            findDrop(row, col, minDrop, true, false);
                            if(passLocation != null)
                            {
                                features.setAttribute(passLocation.row, passLocation.col, 3F);
                            }
                        } else
                        {
                            xBar /= numPeakPoints;
                            yBar /= numPeakPoints;
                            float minDistance2 = 3.402823E+038F;
                            RasterPosition centreSummit = new RasterPosition(0, 0);
                            RasterPosition p;
                            for(Iterator i = summits.iterator(); i.hasNext(); features.setAttribute(p.row, p.col, 15F))
                            {
                                p = (RasterPosition)i.next();
                                if(((float)p.col - xBar) * ((float)p.col - xBar) + ((float)p.row - yBar) * ((float)p.row - yBar) < minDistance2)
                                {
                                    minDistance2 = ((float)p.col - xBar) * ((float)p.col - xBar) + ((float)p.row - yBar) * ((float)p.row - yBar);
                                    centreSummit.col = p.col;
                                    centreSummit.row = p.row;
                                }
                            }

                            features.setAttribute(centreSummit.row, centreSummit.col, 5F);
                            findDrop(centreSummit.row, centreSummit.col, minDrop, true, false);
                            if(passLocation != null)
                            {
                                features.setAttribute(passLocation.row, passLocation.col, 3F);
                            }
                        }
                    } else
                    {
                        for(Iterator i = visitedV.iterator(); i.hasNext();)
                        {
                            RasterPosition p = ((RasterCell)i.next()).getPosition();
                            if(dem.getAttribute(p.row, p.col) == startHeight && features.getAttribute(p.row, p.col) == 0.0F)
                            {
                                features.setAttribute(p.row, p.col, 6F);
                            }
                        }

                    }
                } else
                if(startHeight < dem.getMinAttribute() + minDrop)
                {
                    features.setAttribute(row, col, 6F);
                }
            }

            //System.out.println((100 * row) / features.getNumRows());
        }

        System.out.println("Calculating drops and climbs...");
        featureNetwork = new VectorMap(features);
        AttributeTable attTable = new AttributeTable(5);
        attTable.setHeadings(new String[] {
            "id", "Drop/climb", "Elevation", "Feature type", "Type id"
        });
        attTable.addAttributes(-4F, new Object[] {
            new Float(0.0F), new Float(0.0F), "Ridge", new Integer(4)
        });
        attTable.addAttributes(-2F, new Object[] {
            new Float(0.0F), new Float(0.0F), "Channel", new Integer(2)
        });
        for(int row = 0; row < dem.getNumRows(); row++)
        {
            if(checkStoppedThread())
            {
                visitedR = null;
                features = null;
                return;
            }
            for(int col = 0; col < dem.getNumCols(); col++)
            {
                if(features.getAttribute(row, col) == 5F)
                {
                    traceRidge(row, col, false);
                    float drop = findDrop(row, col, minDrop, true, false);
                    summitHierarchy.insert(new RasterPosition(row, col), drop);
                } else
                if(features.getAttribute(row, col) == 1.0F)
                {
                    traceChannel(row, col, false, false);
                    float drop = findDrop(row, col, minDrop, true, true);
                    summitHierarchy.insert(new RasterPosition(row, col), -drop);
                } else
                if(features.getAttribute(row, col) == 3F)
                {
                    summitHierarchy.insert(new RasterPosition(row, col), 0.0F);
                }
            }

            //System.out.println((100 * row) / dem.getNumRows());
        }

        System.out.println("Processing hierarchy...");
        int id = 1;
        for(; summitHierarchy.size() > 0; summitHierarchy.removeFirst())
        {
            RasterPosition peak = (RasterPosition)summitHierarchy.getFirst();
            float drop = summitHierarchy.getPriority(peak);
            float elev = dem.getAttribute(peak.row, peak.col);
            Footprint peakLocation = dem.getFootprint(peak.row, peak.col);
            featureNetwork.add(new GISVector(peakLocation.getXOrigin(), peakLocation.getYOrigin(), id), false);
            Object attributes[] = new Object[4];
            attributes[0] = new Float(drop);
            attributes[1] = new Float(elev);
            if(drop > 0.0F)
            {
                attributes[2] = new String("Summit");
                attributes[3] = new Integer(5);
            } else
            if(drop == 0.0F)
            {
                attributes[2] = new String("Pass");
                attributes[3] = new Integer(3);
            } else
            {
                attributes[2] = new String("Immit");
                attributes[3] = new Integer(1);
            }
            attTable.addAttributes(id, attributes);
            id++;
        }

        attTable.setActiveColumn(4);
        featureNetwork.setAttributeTable(attTable);
        featureNetwork.updateBounds();
        featureNetwork.setBounds(dem.getBounds());
        featureNetwork.getHeader().setTitle("SSPs");
        featureNetwork.getHeader().setNotes(featureNotes.toString());
        featureNetwork.setColourTable(ColourTable.getPresetColourTable(101));
        gisFrame.addVectorMap(featureNetwork, 1);
        features.getHeader().setTitle("Surface features");
        features.getHeader().setNotes(featureNotes.toString());
        features.setColourTable(ColourTable.getPresetColourTable(101));
        features.setType(11);
        gisFrame.addRaster(features, 2);
        setFinalMessage("Features identified");
    }

//    public void footprintReceived(Footprint fp)
//    {
//        RasterPosition pos = new RasterPosition(dem.getRow(fp.getYOrigin()), dem.getCol(fp.getXOrigin()));
//        overlay = new VectorMap(dem);
//        overlay.setColourTable(ColourTable.getPresetColourTable(101));
//        traceRidge(pos.row, pos.col, true);
//        traceChannel(pos.row, pos.col, false, true);
//        gisFrame.getGraphicsArea().setVectorOverlay(overlay);
//    }

    public RasterMap getSurfaceFetures()
    {
        return features;
    }

    public VectorMap getSurfaceNetwork()
    {
        return featureNetwork;
    }

    private float findDrop(int r, int c, float maxDrop, boolean findPass, boolean invertDEM)
    {
        passLocation = null;
        float relativeDrop = 0.0F;
        float drop = 0.0F;
        float startHeight = dem.getAttribute(r, c);
        if(invertDEM)
        {
            startHeight *= -1F;
        }
        visitID++;
        visitedR[r][c] = visitID;
        visitedV.clear();
        RasterCell currentLocation = new RasterCell(new RasterPosition(r, c), null);
        visitedV.add(currentLocation);
        JWPriorityQueue toBeProcessed = new JWPriorityQueue();
        if(invertDEM)
        {
            toBeProcessed.insert(new RasterCell(new RasterPosition(r, c), null), -dem.getAttribute(r, c));
        } else
        {
            toBeProcessed.insert(new RasterCell(new RasterPosition(r, c), null), dem.getAttribute(r, c));
        }
        while(toBeProcessed.size() != 0) 
        {
            currentLocation = (RasterCell)toBeProcessed.removeFirst();
            int row = currentLocation.getPosition().row;
            int col = currentLocation.getPosition().col;
            if(invertDEM)
            {
                drop = startHeight + dem.getAttribute(row, col);
            } else
            {
                drop = startHeight - dem.getAttribute(row, col);
            }
            if(drop < 0.0F)
            {
                if(findPass)
                {
                    findPassLocation(invertDEM);
                }
                return relativeDrop;
            }
            if(relativeDrop >= maxDrop && drop == 0.0F)
            {
                if(findPass)
                {
                    findPassLocation(invertDEM);
                }
                return relativeDrop;
            }
            if(drop > relativeDrop)
            {
                relativeDrop = drop;
            }
            if(row == 0 || row == dem.getNumRows() - 1 || col == 0 || col == dem.getNumCols() - 1)
            {
                visitedV.add(currentLocation);
                if(findPass)
                {
                    findPassLocation(invertDEM);
                }
                return relativeDrop;
            }
            RasterCell neighbour = null;
            if(relativeDrop < maxDrop || findPass)
            {
                if(visitedR[row - 1][col - 1] != visitID)
                {
                    neighbour = new RasterCell(new RasterPosition(row - 1, col - 1), currentLocation);
                    visitedR[row - 1][col - 1] = visitID;
                    visitedV.add(neighbour);
                    if(invertDEM)
                    {
                        toBeProcessed.insert(neighbour, -dem.getAttribute(row - 1, col - 1));
                    } else
                    {
                        toBeProcessed.insert(neighbour, dem.getAttribute(row - 1, col - 1));
                    }
                }
                if(visitedR[row - 1][col] != visitID)
                {
                    neighbour = new RasterCell(new RasterPosition(row - 1, col), currentLocation);
                    visitedR[row - 1][col] = visitID;
                    visitedV.add(neighbour);
                    if(invertDEM)
                    {
                        toBeProcessed.insert(neighbour, -dem.getAttribute(row - 1, col));
                    } else
                    {
                        toBeProcessed.insert(neighbour, dem.getAttribute(row - 1, col));
                    }
                }
                if(visitedR[row - 1][col + 1] != visitID)
                {
                    neighbour = new RasterCell(new RasterPosition(row - 1, col + 1), currentLocation);
                    visitedR[row - 1][col + 1] = visitID;
                    visitedV.add(neighbour);
                    if(invertDEM)
                    {
                        toBeProcessed.insert(neighbour, -dem.getAttribute(row - 1, col + 1));
                    } else
                    {
                        toBeProcessed.insert(neighbour, dem.getAttribute(row - 1, col + 1));
                    }
                }
                if(visitedR[row][col - 1] != visitID)
                {
                    neighbour = new RasterCell(new RasterPosition(row, col - 1), currentLocation);
                    visitedR[row][col - 1] = visitID;
                    visitedV.add(neighbour);
                    if(invertDEM)
                    {
                        toBeProcessed.insert(neighbour, -dem.getAttribute(row, col - 1));
                    } else
                    {
                        toBeProcessed.insert(neighbour, dem.getAttribute(row, col - 1));
                    }
                }
                if(visitedR[row][col + 1] != visitID)
                {
                    neighbour = new RasterCell(new RasterPosition(row, col + 1), currentLocation);
                    visitedR[row][col + 1] = visitID;
                    visitedV.add(neighbour);
                    if(invertDEM)
                    {
                        toBeProcessed.insert(neighbour, -dem.getAttribute(row, col + 1));
                    } else
                    {
                        toBeProcessed.insert(neighbour, dem.getAttribute(row, col + 1));
                    }
                }
                if(visitedR[row + 1][col - 1] != visitID)
                {
                    neighbour = new RasterCell(new RasterPosition(row + 1, col - 1), currentLocation);
                    visitedR[row + 1][col - 1] = visitID;
                    visitedV.add(neighbour);
                    if(invertDEM)
                    {
                        toBeProcessed.insert(neighbour, -dem.getAttribute(row + 1, col - 1));
                    } else
                    {
                        toBeProcessed.insert(neighbour, dem.getAttribute(row + 1, col - 1));
                    }
                }
                if(visitedR[row + 1][col] != visitID)
                {
                    neighbour = new RasterCell(new RasterPosition(row + 1, col), currentLocation);
                    visitedR[row + 1][col] = visitID;
                    visitedV.add(neighbour);
                    if(invertDEM)
                    {
                        toBeProcessed.insert(neighbour, -dem.getAttribute(row + 1, col));
                    } else
                    {
                        toBeProcessed.insert(neighbour, dem.getAttribute(row + 1, col));
                    }
                }
                if(visitedR[row + 1][col + 1] != visitID)
                {
                    neighbour = new RasterCell(new RasterPosition(row + 1, col + 1), currentLocation);
                    visitedR[row + 1][col + 1] = visitID;
                    visitedV.add(neighbour);
                    if(invertDEM)
                    {
                        toBeProcessed.insert(neighbour, -dem.getAttribute(row + 1, col + 1));
                    } else
                    {
                        toBeProcessed.insert(neighbour, dem.getAttribute(row + 1, col + 1));
                    }
                }
            } else
            {
                return relativeDrop;
            }
        }
        System.out.println("Warning: Unexpected feature search location");
        return relativeDrop;
    }

    private void findPassLocation(boolean invertDEM)
    {
        RasterCell currentLocation = (RasterCell)visitedV.lastElement();
        RasterPosition pos = currentLocation.getPosition();
        Vector coords = null;
        passLocation = new RasterPosition(pos);
        if(featureNetwork != null)
        {
            coords = new Vector();
            coords.add(dem.getFootprint(pos.row, pos.col));
        }
        float minValue = dem.getAttribute(pos.row, pos.col);
        if(invertDEM)
        {
            minValue = -minValue;
        }
        for(; currentLocation.getParent() != null; currentLocation = currentLocation.getParent())
        {
            pos = currentLocation.getPosition();
            float height = dem.getAttribute(pos.row, pos.col);
            if(invertDEM)
            {
                height = -height;
            }
            if(height <= minValue)
            {
                if(coords != null)
                {
                    coords = new Vector();
                }
                minValue = height;
                passLocation = new RasterPosition(pos);
            }
            if(coords != null)
            {
                coords.add(dem.getFootprint(pos.row, pos.col));
            }
        }

        if(coords != null)
        {
            coords.add(dem.getFootprint(currentLocation.getPosition().row, currentLocation.getPosition().col));
            float x[] = new float[coords.size()];
            float y[] = new float[coords.size()];
            for(int i = 0; i < coords.size(); i++)
            {
                Footprint fp = (Footprint)coords.get(i);
                x[i] = fp.getXOrigin();
                y[i] = fp.getYOrigin();
            }

            if(invertDEM)
            {
                featureNetwork.add(new GISVector(x, y, 1, -2F));
            } else
            {
                featureNetwork.add(new GISVector(x, y, 1, -4F));
            }
        }
    }

    private void traceRidge(int r, int c, boolean doOverlay)
    {
        passLocation = null;
        visitID++;
        visitedR[r][c] = visitID;
        visitedV.clear();
        RasterCell currentLocation = new RasterCell(new RasterPosition(r, c), null);
        visitedV.add(currentLocation);
        JWPriorityQueue toBeProcessed = new JWPriorityQueue();
        toBeProcessed.insert(new RasterCell(new RasterPosition(r, c), null), dem.getAttribute(r, c));
        while(toBeProcessed.size() != 0) 
        {
            currentLocation = (RasterCell)toBeProcessed.removeFirst();
            int row = currentLocation.getPosition().row;
            int col = currentLocation.getPosition().col;
            if(row == 0 || row == dem.getNumRows() - 1 || col == 0 || col == dem.getNumCols() - 1)
            {
                visitedV.add(currentLocation);
                if(doOverlay)
                {
                    findLinkVector(4);
                } else
                {
                    findLink(4);
                }
                return;
            }
            RasterCell neighbour = null;
            if(visitedR[row - 1][col - 1] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row - 1, col - 1), currentLocation);
                visitedR[row - 1][col - 1] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, dem.getAttribute(row - 1, col - 1));
            }
            if(visitedR[row - 1][col] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row - 1, col), currentLocation);
                visitedR[row - 1][col] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, dem.getAttribute(row - 1, col));
            }
            if(visitedR[row - 1][col + 1] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row - 1, col + 1), currentLocation);
                visitedR[row - 1][col + 1] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, dem.getAttribute(row - 1, col + 1));
            }
            if(visitedR[row][col - 1] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row, col - 1), currentLocation);
                visitedR[row][col - 1] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, dem.getAttribute(row, col - 1));
            }
            if(visitedR[row][col + 1] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row, col + 1), currentLocation);
                visitedR[row][col + 1] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, dem.getAttribute(row, col + 1));
            }
            if(visitedR[row + 1][col - 1] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row + 1, col - 1), currentLocation);
                visitedR[row + 1][col - 1] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, dem.getAttribute(row + 1, col - 1));
            }
            if(visitedR[row + 1][col] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row + 1, col), currentLocation);
                visitedR[row + 1][col] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, dem.getAttribute(row + 1, col));
            }
            if(visitedR[row + 1][col + 1] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row + 1, col + 1), currentLocation);
                visitedR[row + 1][col + 1] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, dem.getAttribute(row + 1, col + 1));
            }
        }
        System.out.println("Warning: Unexpected ridge search location");
    }

    private void findLink(int featType)
    {
        for(RasterCell currentLocation = (RasterCell)visitedV.lastElement(); currentLocation.getParent() != null; currentLocation = currentLocation.getParent())
        {
            RasterPosition pos = currentLocation.getPosition();
            if(features.getAttribute(pos.row, pos.col) == 6F)
            {
                features.setAttribute(pos.row, pos.col, featType);
            }
        }

    }

    private void findLinkVector(int featType)
    {
        RasterCell currentLocation = (RasterCell)visitedV.lastElement();
        Vector coords = new Vector();
        for(; currentLocation.getParent() != null; currentLocation = currentLocation.getParent())
        {
            RasterPosition pos = currentLocation.getPosition();
            coords.add(dem.getFootprint(pos.row, pos.col));
        }

        float x[] = new float[coords.size()];
        float y[] = new float[coords.size()];
        for(int i = 0; i < coords.size(); i++)
        {
            Footprint fp = (Footprint)coords.get(i);
            x[i] = fp.getXOrigin();
            y[i] = fp.getYOrigin();
        }

        overlay.add(new GISVector(x, y, 1, featType));
    }

    private void traceChannel(int r, int c, boolean backTrace, boolean doOverlay)
    {
        passLocation = null;
        visitID++;
        visitedR[r][c] = visitID;
        visitedV.clear();
        RasterCell currentLocation = new RasterCell(new RasterPosition(r, c), null);
        visitedV.add(currentLocation);
        JWPriorityQueue toBeProcessed = new JWPriorityQueue();
        toBeProcessed.insert(new RasterCell(new RasterPosition(r, c), null), -dem.getAttribute(r, c));
        while(toBeProcessed.size() != 0) 
        {
            currentLocation = (RasterCell)toBeProcessed.removeFirst();
            int row = currentLocation.getPosition().row;
            int col = currentLocation.getPosition().col;
            if(row == 0 || row == dem.getNumRows() - 1 || col == 0 || col == dem.getNumCols() - 1)
            {
                visitedV.add(currentLocation);
                if(backTrace)
                {
                    backTraceChannel(row, col, doOverlay);
                    return;
                }
                if(doOverlay)
                {
                    findLinkVector(2);
                } else
                {
                    findLink(2);
                }
                return;
            }
            RasterCell neighbour = null;
            if(visitedR[row - 1][col - 1] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row - 1, col - 1), currentLocation);
                visitedR[row - 1][col - 1] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, -dem.getAttribute(row - 1, col - 1));
            }
            if(visitedR[row - 1][col] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row - 1, col), currentLocation);
                visitedR[row - 1][col] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, -dem.getAttribute(row - 1, col));
            }
            if(visitedR[row - 1][col + 1] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row - 1, col + 1), currentLocation);
                visitedR[row - 1][col + 1] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, -dem.getAttribute(row - 1, col + 1));
            }
            if(visitedR[row][col - 1] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row, col - 1), currentLocation);
                visitedR[row][col - 1] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, -dem.getAttribute(row, col - 1));
            }
            if(visitedR[row][col + 1] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row, col + 1), currentLocation);
                visitedR[row][col + 1] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, -dem.getAttribute(row, col + 1));
            }
            if(visitedR[row + 1][col - 1] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row + 1, col - 1), currentLocation);
                visitedR[row + 1][col - 1] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, -dem.getAttribute(row + 1, col - 1));
            }
            if(visitedR[row + 1][col] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row + 1, col), currentLocation);
                visitedR[row + 1][col] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, -dem.getAttribute(row + 1, col));
            }
            if(visitedR[row + 1][col + 1] != visitID)
            {
                neighbour = new RasterCell(new RasterPosition(row + 1, col + 1), currentLocation);
                visitedR[row + 1][col + 1] = visitID;
                visitedV.add(neighbour);
                toBeProcessed.insert(neighbour, -dem.getAttribute(row + 1, col + 1));
            }
        }
        System.out.println("Warning: Unexpected channel search location");
    }

    private void backTraceChannel(int r, int c, boolean doOverlay)
    {
        passLocation = null;
        visitID++;
        visitedR[r][c] = visitID;
        visitedV.clear();
        RasterCell currentLocation = new RasterCell(new RasterPosition(r, c), null);
        visitedV.add(currentLocation);
        JWPriorityQueue toBeProcessed = new JWPriorityQueue();
        toBeProcessed.insert(new RasterCell(new RasterPosition(r, c), null), -dem.getAttribute(r, c));
        int numRows = dem.getNumRows();
        int numCols = dem.getNumCols();
        while(toBeProcessed.size() != 0) 
        {
            currentLocation = (RasterCell)toBeProcessed.removeFirst();
            int row = currentLocation.getPosition().row;
            int col = currentLocation.getPosition().col;
            if(features.getAttribute(row, col) == 3F)
            {
                return;
            }
            features.setAttribute(row, col, 11F);
            RasterCell neighbour = null;
            if(row > 1 && col > 1 && visitedR[row - 1][col - 1] != visitID && dem.getAttribute(row - 1, col - 1) >= dem.getAttribute(row, col))
            {
                neighbour = new RasterCell(new RasterPosition(row - 1, col - 1), currentLocation);
                visitedR[row - 1][col - 1] = visitID;
                toBeProcessed.insert(neighbour, -dem.getAttribute(row - 1, col - 1));
            }
            if(row > 1 && col > 0 && col < numCols - 1 && visitedR[row - 1][col] != visitID && dem.getAttribute(row - 1, col) >= dem.getAttribute(row, col))
            {
                neighbour = new RasterCell(new RasterPosition(row - 1, col), currentLocation);
                visitedR[row - 1][col] = visitID;
                toBeProcessed.insert(neighbour, -dem.getAttribute(row - 1, col));
            }
            if(row > 1 && col < numCols - 2 && visitedR[row - 1][col + 1] != visitID && dem.getAttribute(row - 1, col + 1) >= dem.getAttribute(row, col))
            {
                neighbour = new RasterCell(new RasterPosition(row - 1, col + 1), currentLocation);
                visitedR[row - 1][col + 1] = visitID;
                toBeProcessed.insert(neighbour, -dem.getAttribute(row - 1, col + 1));
            }
            if(col > 1 && row > 0 && row < numRows - 1 && visitedR[row][col - 1] != visitID && dem.getAttribute(row, col - 1) >= dem.getAttribute(row, col))
            {
                neighbour = new RasterCell(new RasterPosition(row, col - 1), currentLocation);
                visitedR[row][col - 1] = visitID;
                toBeProcessed.insert(neighbour, -dem.getAttribute(row, col - 1));
            }
            if(col < numCols - 2 && row > 0 && row < numRows - 1 && visitedR[row][col + 1] != visitID && dem.getAttribute(row, col + 1) >= dem.getAttribute(row, col))
            {
                neighbour = new RasterCell(new RasterPosition(row, col + 1), currentLocation);
                visitedR[row][col + 1] = visitID;
                toBeProcessed.insert(neighbour, -dem.getAttribute(row, col + 1));
            }
            if(row < numRows - 2 && col > 1 && visitedR[row + 1][col - 1] != visitID && dem.getAttribute(row + 1, col - 1) >= dem.getAttribute(row, col))
            {
                neighbour = new RasterCell(new RasterPosition(row + 1, col - 1), currentLocation);
                visitedR[row + 1][col - 1] = visitID;
                toBeProcessed.insert(neighbour, -dem.getAttribute(row + 1, col - 1));
            }
            if(row < numRows - 2 && col > 0 && col < numCols - 1 && visitedR[row + 1][col] != visitID && dem.getAttribute(row + 1, col) >= dem.getAttribute(row, col))
            {
                neighbour = new RasterCell(new RasterPosition(row + 1, col), currentLocation);
                visitedR[row + 1][col] = visitID;
                toBeProcessed.insert(neighbour, -dem.getAttribute(row + 1, col));
            }
            if(row < numRows - 2 && col < numCols - 2 && visitedR[row + 1][col + 1] != visitID && dem.getAttribute(row + 1, col + 1) >= dem.getAttribute(row, col))
            {
                neighbour = new RasterCell(new RasterPosition(row + 1, col + 1), currentLocation);
                visitedR[row + 1][col + 1] = visitID;
                toBeProcessed.insert(neighbour, -dem.getAttribute(row + 1, col + 1));
            }
        }
        System.out.println("Warning: Unexpected reverse channel search location");
    }
}
