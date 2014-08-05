import os

import basemodel

class Model(basemodel.BaseModel):
    def execute(self, runparams):        
        #def run_r_code(rscript, timestep=None, variables=None, inputfiles={}, 
        #           outputfiles=None):
        # def run_r_code(rscript, timestep=None, variables=None):
        #     if (timestep):
        #         if not variables: variables = {}
        #         variables['current.time.step'] = timestep
            
        #     self.run_r_code(rscript, variables )
            
        #variables = runparams.variables
        variables = self.get_decimal_params(runparams)
        
        self.logger.fine("I'm in model.py!!")
        overrides = {}
        inputOverDict = {}
        inputOveride = ''


        if variables['OPT.offset.pool.option'] ==  "RANDOM":
            inputOveride = variables['PAR.offset.pool.map.filename.random']
            inputOverDict = {'PAR.offset.pool.map.filename' : inputOveride}
            
        if variables['OPT.offset.pool.option'] ==  "STRATEGIC":
            inputOveride = variables['PAR.offset.pool.map.filename.strategic']
            inputOverDict = {'PAR.offset.pool.map.filename' : inputOveride }


        cur_check_point = 0

        self.logger.fine("\nrunning dbms initialise: %s" % variables['dbmsFunctionsRFileName'])

        self.run_r_code("dbms.initialise.melb.grassland.R", runparams )

        t=1
        if t ==1 :
            cur_check_point += 1           # now cur_check_point == 1
            
            if variables['start_point'] <= cur_check_point:
                
                self.logger.fine("\nrunning initialise Planning Unit information...")
                self.run_r_code("initialise.planning.unit.information.R", runparams )
        
            cur_check_point += 1      # now cur_check_point == 2

            if variables['start_point'] <= cur_check_point:

                self.logger.fine("\nrunning initialise cost information...")
                self.run_r_code("initialise.cost.information.R", runparams )
        
            cur_check_point += 1      # now cur_check_point == 3

            #raw_input("Hit enter to continue:" )

            # Initialisation is complete now loop through time steps

            #params = runparams['parameters']
                    
            self.logger.fine("variables['numTimeSteps']= %s" % variables['numTimeSteps'])
            #self.logger.fine("\n runparams = %s", runparams['numTimeSteps'] )
            # self.logger.fine("\n runparams = %s", runparams )
            #self.logger.fine("\n params = %s", params['numTimeSteps'] )
            
            xrangeTimeUpperBound = (variables['numTimeSteps'] + 1) * variables['step.interval']

            for timeStep in xrange(0, xrangeTimeUpperBound, variables['step.interval']):
                
                overrides = {'current.time.step': timeStep }
                
                self.logger.fine( '\n')
                self.logger.fine('='*50)
                self.logger.fine(" Starting time step %s" % timeStep)
                self.logger.fine('='*50)
                
                self.logger.fine("\ngrassland condition model...")
                self.run_r_code("grassland.condition.model.R", runparams, overrides )
                
                self.logger.fine("\nupdate.planning.unit.info...")
                self.run_r_code("update.planning.unit.info.R", runparams, overrides )
                
        
                if (timeStep == 0) and \
                       (variables['reserveSelectionMethod'] == "ZONATION"):
                    
                    if not variables['usePreviousZonationResult']:
                        self.logger.fine("\nrun zonation...")
                        self.run_r_code("run.zonation.R", runparams, overrides )
        
                    self.logger.fine("\nreserve zonation...")
                    self.run_r_code("reserve.zonation.R", runparams, overrides )
        
                    self.logger.fine("\ngen reserved PUs...")
                    self.run_r_code("gen.reserved.pus.from.patches.R", runparams, overrides)

                self.logger.fine("\nloss model...")
                # Note: currently offset model is called from inside loss model
                #self.run_r_code("loss.model.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)
                self.run_r_code("loss.model.melb.grassland.R",  runparams, overrides)

                # now save the output of the offset model
				
                    #  Included an if statement around echoing loss
                    #  model output to file - to speed up when
                    #  debugging not required - DWM 29/09/2009
                                
                overrides['DebugSaveLossModelOutFiles'] = False
                if overrides['DebugSaveLossModelOutFiles']:
			
                    filename1 = "loss.model.out"
                    filename2 = "loss.model.ts." + \
                                str(variables['current.time.step'])+".out"
                    
                    os.system("copy %s %s" % (filename1, filename2))
					
                self.logger.fine("\nevaluate condition model...")
                self.run_r_code("eval.cond.R", runparams, overrides)

                
        #raw_input("Hit enter to continue:" )
