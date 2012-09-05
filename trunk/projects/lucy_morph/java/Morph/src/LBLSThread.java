import java.io.PrintStream;
//import FakeGISFrame;


public abstract class LBLSThread extends Thread
  
{

    private FakeGISFrame gisFrame;
    private String startMessage;
    private String endMessage;
    private float time;
    private boolean hasError;
    private long startTime;
    private volatile int threadStatus;
    private static final int NO_THREAD = 0;
    private static final int IS_RUNNING = 1;
    private static final int IS_PAUSED = 2;
    private static final int IS_STOPPED = 3;

    public LBLSThread(String startMessage, FakeGISFrame gisFrame)
    {
        this.startMessage = startMessage;
        this.gisFrame = gisFrame;
        hasError = false;
        threadStatus = 0;
    }

    public void run()
    {
        threadStatus = 1;
        
        resetTimer();
        
        doProcessing();
        time = (float)Math.round((System.currentTimeMillis() - startTime) / 10L) / 100F;
        if(endMessage == null)
        {
            setFinalMessage("Completed");
        }
        
        if((double)time < 0.01D || hasError)
        {
            setFinalMessage(endMessage + ".");
        } else
        if(threadStatus == 3)
        {
            setFinalMessage("Process interrupted after " + time + " seconds.");
        } else
        {
            setFinalMessage(endMessage + " in " + time + " seconds.");
        }
    
    }

    public void resetTimer()
    {
        startTime = System.currentTimeMillis() - 1L;
    }

    public abstract void doProcessing();

    /**
     * @deprecated Method setMessage is deprecated
     */

    public void setMessage(String m)
    {
        setFinalMessage(m);
    }

    public void setFinalMessage(String m)
    {
        endMessage = m;
        if(threadStatus == 0)
        {
            System.out.println(endMessage);
        }
    }

    public void setErrorMessage(String m)
    {
        endMessage = m;
        hasError = true;
        if(threadStatus == 0)
        {
            System.err.println(endMessage);
        }
    }

    public void interruptionRequested()
    {
        if(threadStatus == 0 || threadStatus == 3)
        {
            return;
        }
        threadStatus = 3;
     
    }

    public boolean checkStoppedThread()
    {
        while(threadStatus == 2) 
        {
            try
            {
                sleep(100L);
                continue;
            }
            catch(InterruptedException e) { }
            break;
        }
        return threadStatus == 3;
    }
}
