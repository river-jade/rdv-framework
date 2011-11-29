import os

import basemodel

class Model(basemodel.BaseModel):
    def execute(self, params):
        def run_r_code(rscript, timestep=None, variables=None, inputfiles={}, 
                   outputfiles=None):
            if (timestep):
                if not variables: variables = {}
                variables['current.time.step'] = timestep
            #myparams = params
            self.run_r_code(rscript, params, variables, inputfiles, outputfiles)

        variables = params.variables
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

        run_r_code("dbms.initialise.melb.grassland.R", variables=overrides, inputfiles=inputOverDict)

        if variables['test_modelling_and_reserving_loop']:
            cur_check_point += 1           # now cur_check_point == 1
            
            if variables['start_point'] <= cur_check_point:
                
                self.logger.fine("\nrunning initialise Planning Unit information...")
                run_r_code("initialise.planning.unit.information.R", variables=overrides, inputfiles=inputOverDict)
        
            cur_check_point += 1      # now cur_check_point == 2

            if variables['start_point'] <= cur_check_point:

                self.logger.fine("\nrunning initialise cost information...")
                run_r_code("initialise.cost.information.R", variables=overrides, inputfiles=inputOverDict)
        
            cur_check_point += 1      # now cur_check_point == 3

            #raw_input("Hit enter to continue:" )

            # Initialisation is complete now loop through time steps
            
            xrangeTimeUpperBound = (variables['numTimeSteps'] + 1) * variables['step.interval']

            for timeStep in xrange(0, xrangeTimeUpperBound, variables['step.interval']):
                
                
                self.logger.fine( '\n')
                self.logger.fine('='*50)
                self.logger.fine(" Starting time step %s" % timeStep)
                self.logger.fine('='*50)
                
                self.logger.fine("\ngrassland condition model...")
                run_r_code("grassland.condition.model.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)

                run_r_code("update.planning.unit.info.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)
        
                if (timeStep == 0) and \
                       (variables['reserveSelectionMethod'] == "ZONATION"):
                    
                    if not variables['usePreviousZonationResult']:
                        self.logger.fine("\nrun zonation...")
                        run_r_code("run.zonation.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)
        
                    self.logger.fine("\nreserve zonation...")
                    run_r_code("reserve.zonation.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)
        
                    self.logger.fine("\ngen reserved PUs...")
                    run_r_code("gen.reserved.pus.from.patches.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)
        
                else:
                    if variables['BudgetForPubReserves'] > 0:
                        overrides['PAR.budget.for.timestep'] = variables['BudgetForPubReserves']
                        overrides['PAR.reserve.duration'] = variables['publicReserveDuration']
                        overrides['OPT.action.type'] = variables['OPT.VAL.public.reserve']
                        
                        if variables['reserveSelectionMethod'] == "RANDOM":
                            self.logger.fine("\nreserve RANDOM for public reserves...")
                            run_r_code("reserve.random.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)

                        if variables['reserveSelectionMethod'] == "CONDITION":
                            self.logger.fine("\nreserve CONDITION for public reserves...")
                            run_r_code("reserve.condition.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)
                            
                    if variables['BudgetForPrivateManagement'] > 0:
                        overrides['PAR.budget.for.timestep'] = variables['BudgetForPrivateManagement']
                        overrides['OPT.action.type'] = variables['OPT.VAL.private.management']
                        overrides['PAR.reserve.duration'] = variables['privateReserveDuration']
						
                        if variables['reserveSelectionMethod'] == "RANDOM":
                            self.logger.fine("\nreserve RANDOM for private management...")
                            run_r_code("reserve.random.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)

                        if variables['reserveSelectionMethod'] == "CONDITION":
                            self.logger.fine("\nreserve CONDITDION for private managemnt")
                            run_r_code("reserve.condition.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)


                    if variables['reserveSelectionMethod'] == "CONDITION_AND_RANDOM":

                        # for now only using the case where running
                        # RANDOM for private and CONDITION for public.
                        
                        if variables['BudgetForPrivateManagement'] > 0:
                            self.logger.fine("\nRunning CONDITION_AND_RANDOM")
                            self.logger.fine("reserve RANDOM for private management...")
                            overrides['PAR.budget.for.timestep'] = variables['BudgetForPrivateManagement']
                            overrides['OPT.action.type'] = variables['OPT.VAL.private.management']
                            overrides['PAR.reserve.duration'] = variables['privateReserveDuration']
                            run_r_code("reserve.random.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)
                            
                        if variables['BudgetForPubReserves'] > 0:
                            self.logger.fine("\nRunning CONDITION_AND_RANDOM")
                            self.logger.fine("reserve CONDITION for public reserves...")
                            overrides['PAR.budget.for.timestep'] = variables['BudgetForPubReserves']
                            overrides['PAR.reserve.duration'] = variables['publicReserveDuration']
                            overrides['OPT.action.type'] = variables['OPT.VAL.public.reserve']
                            run_r_code("reserve.condition.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)
                
                self.logger.fine("\nloss model...")
                # Note: currently offset model is called from inside loss model
                #run_r_code("loss.model.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)
                run_r_code("loss.model.melb.grassland.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)

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
                run_r_code("eval.cond.R", timestep=timeStep, variables=overrides, inputfiles=inputOverDict)

                
        #raw_input("Hit enter to continue:" )
