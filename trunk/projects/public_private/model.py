import os

import basemodel

class Model(basemodel.BaseModel):
    def execute(self, params):
        def run_r_code(rscript, timestep=None, variables=None, inputfiles=None, 
                   outputfiles=None):
            if (timestep):
                if not variables: variables = {}
                variables['current.time.step'] = timestep
            self.run_r_code(rscript, params, variables, inputfiles, outputfiles)

        variables = params.variables

        cur_check_point = 0

        self.logger.info("\nrunning dbms initialise: %s" % \
                    variables['dbmsFunctionsRFileName'])

        run_r_code("dbms.initialise.R")

        if variables['test_modelling_and_reserving_loop']:
            cur_check_point += 1           # now cur_check_point == 1
            
            if variables['start_point'] <= cur_check_point:
                
                self.logger.info("\nrunning initialise Planning Unit information...")
                run_r_code("initialise.planning.unit.information.R")
        
            cur_check_point += 1      # now cur_check_point == 2

            if variables['start_point'] <= cur_check_point:

                self.logger.info("\nrunning initialise cost information...")
                run_r_code("initialise.cost.information.R")
        
            cur_check_point += 1      # now cur_check_point == 3

            #raw_input("Hit enter to continue:" )

            # Initialisation is complete now loop through time steps
            
            xrangeTimeUpperBound = (variables['numTimeSteps'] + 1) * variables['step.interval']

            for timeStep in xrange(0, xrangeTimeUpperBound, variables['step.interval']):
                
                
                overrides = {}
                self.logger.info( '\n' )
                self.logger.info('='*50)
                self.logger.info(" Starting time step %s" % timeStep)
                self.logger.info('='*50)
                
                self.logger.info("\ngrassland condition model...")
                run_r_code("grassland.condition.model.R", timestep=timeStep, variables=overrides)

                run_r_code("update.planning.unit.info.R", timestep=timeStep, variables=overrides)
        
                if (timeStep == 0) and \
                       (variables['reserveSelectionMethod'] == "ZONATION"):
                    
                    if not variables['usePreviousZonationResult']:
                        self.logger.info("\nrun zonation...")
                        run_r_code("run.zonation.R", timestep=timeStep, variables=overrides)
        
                    self.logger.info("\nreserve zonation...")
                    run_r_code("reserve.zonation.R", timestep=timeStep, variables=overrides)
        
                    self.logger.info("\ngen reserved PUs...")
                    run_r_code("gen.reserved.pus.from.patches.R", timestep=timeStep, variables=overrides)
        
                else:
                    if variables['BudgetForPubReserves'] > 0:
                        overrides['PAR.budget.for.timestep'] = variables['BudgetForPubReserves']
                        overrides['PAR.reserve.duration'] = variables['publicReserveDuration']
                        overrides['OPT.action.type'] = variables['OPT.VAL.public.reserve']
                        
                        if variables['reserveSelectionMethod'] == "RANDOM":
                            self.logger.info("\nreserve RANDOM for public reserves...")
                            run_r_code("reserve.random.R", timestep=timeStep, variables=overrides)

                        if variables['reserveSelectionMethod'] == "CONDITION":
                            self.logger.info("\nreserve CONDITION for public reserves...")
                            run_r_code("reserve.condition.R", timestep=timeStep, variables=overrides)
                    if variables['BudgetForPrivateManagement'] > 0:
                        overrides['PAR.budget.for.timestep'] = variables['BudgetForPrivateManagement']
                        overrides['OPT.action.type'] = variables['OPT.VAL.private.management']
                        overrides['PAR.reserve.duration'] = variables['privateReserveDuration']
						
                        if variables['reserveSelectionMethod'] == "RANDOM":
                            self.logger.info("\nreserve RANDOM for private management...")
                            run_r_code("reserve.random.R", timestep=timeStep, variables=overrides)

                        if variables['reserveSelectionMethod'] == "CONDITION":
                            self.logger.info("\nreserve CONDITDION for private managemnt") 
                            run_r_code("reserve.condition.R", timestep=timeStep, variables=overrides)


                    if variables['reserveSelectionMethod'] == "CONDITION_AND_RANDOM":

                        # for now only using the case were running
                        # RANDOM for private and CONDITION for public.
                        
                        if variables['BudgetForPrivateManagement'] > 0:
                            self.logger.info("\nRunning CONDITION_AND_RANDOM")
                            self.logger.info("reserve RANDOM for private management...")
                            overrides['PAR.budget.for.timestep'] = variables['BudgetForPrivateManagement']
                            overrides['OPT.action.type'] = variables['OPT.VAL.private.management']
                            overrides['PAR.reserve.duration'] = variables['privateReserveDuration']
                            run_r_code("reserve.random.R", timestep=timeStep, variables=overrides)
                            
                        if variables['BudgetForPubReserves'] > 0:
                            self.logger.info("\nRunning CONDITION_AND_RANDOM")
                            self.logger.info("reserve CONDITION for public reserves...")
                            overrides['PAR.budget.for.timestep'] = variables['BudgetForPubReserves']
                            overrides['PAR.reserve.duration'] = variables['publicReserveDuration']
                            overrides['OPT.action.type'] = variables['OPT.VAL.public.reserve']
                            run_r_code("reserve.condition.R", timestep=timeStep, variables=overrides)
                
                self.logger.info("\nloss model...")
                # Note: currently offset model is called from inside loss model
                run_r_code("loss.model.R", timestep=timeStep, variables=overrides)

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
					
                self.logger.info("\nevaluate condition model...")
                run_r_code("eval.cond.R", timestep=timeStep, variables=overrides)

                
        #raw_input("Hit enter to continue:" )
