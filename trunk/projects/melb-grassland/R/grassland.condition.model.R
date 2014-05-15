

# source( 'grassland.condition.model.R' )

rm( list = ls( all=TRUE ))


    #------------------------------------------------------------
    #  Other code that needs to be sourced
    #------------------------------------------------------------

source( 'w.R' )
source( 'variables.R' )
source( 'grassland.condition.model.functions.R' )
source( 'utility.functions.R' )
source( 'dbms.functions.R' )

    #------------------------------------------------------------
    #  variables needed
    #------------------------------------------------------------

#  moved to python...

    #------------------------------------------------------------
    #  Outputs/returned
    #------------------------------------------------------------


    #------------------------------------------------------------
    #  start code
    #------------------------------------------------------------


#-----------------------------------------------------------------------------
if (use.run.number.as.seed) {
  #set.seed(random.seed)
  set.seed(runID)
}

if( current.time.step == 0 ) {

  # Initialise things on the 0'th time step

  if( OPT.use.raster.maps.for.input.and.output ) {

    cur.cond.model.file.name.base <- paste( cond.model.root.filename,
                                           current.time.step, sep = "")

    # Copy the initial habitat map the to timestep 0 condition model map (asc,txt,pgm)  
    file.copy(paste( master.habitat.map.zo1.base.filename, '.txt', sep = ''),
              paste( cur.cond.model.file.name.base,   '.txt', sep = '' ),
              overwrite = TRUE )
            
    file.copy(paste( master.habitat.map.zo1.base.filename, '.pgm', sep = ''),
              paste( cur.cond.model.file.name.base,   '.pgm', sep = '' ),
              overwrite = TRUE )
            
    file.copy(paste( master.habitat.map.zo1.base.filename, '.asc', sep = ''),
              paste( cur.cond.model.file.name.base,   '.asc', sep = '' ),
              overwrite = TRUE )
  } else {

    # In this case using the database directly for input/output
   
  }
            

} else {

  # update the condition of the grassland map

  cur.cond.model.input.map.name <- paste( cond.model.root.filename,
                                 (current.time.step - step.interval),
                                 '.txt', sep = "" )
  
  run.condition.model( cur.cond.model.input.map.name, current.time.step )

}



