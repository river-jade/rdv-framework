import glob
import os
import shutil

import basemodel

class Model(basemodel.BaseModel):
    def execute(self, params):
        def run_r_code(rscript, timestep=None, variables={}, inputfiles={}, outputfiles={}):
            if (timestep):
                variables['current.time.step'] = timestep
            myparams = params
            if (variables or inputfiles or outputfiles):
                myparams = params.mergeParameters(variables, inputfiles, outputfiles)
            self.run_r_code(rscript, myparams)

        variables = params.variables

        self.logger.fine("\n--> running dbms initialise: %s" % variables['dbmsFunctionsRFileName'])

        run_r_code("dbms.initialise.R")

        #raw_input("1 Hit enter to continue" )

        if variables['test_modelling_and_reserving_loop']:
            
            self.logger.fine("\n--> running initialise Planning Unit information...")
            run_r_code("initialise.planning.unit.information.R")
            
            #raw_input("2 Hit enter to continue: about to init CPW info" )

            run_r_code("initialise.CPW.information.R")


            # Initialisation is complete now loop through time steps
            
            xrangeTimeUpperBound = (variables['numTimeSteps'] + 1) * variables['step.interval']
            
            for timestep in xrange(0, xrangeTimeUpperBound, variables['step.interval']):

                self.logger.fine('\n')
                self.logger.fine('='*50)
                self.logger.fine(" Starting time step %s" % (timestep))
                self.logger.fine('='*50)

                self.logger.fine("\n--> grassland condition model...")
                # Make a loop to run the condition model on each category of CPW
                aggCondDBFields = ['SCORE_OF_C1_CPW', 'SCORE_OF_C2_CPW', 'SCORE_OF_C3_CPW']
                for curAggCondDBField in aggCondDBFields:
                    run_r_code("grassland.condition.model.R", timestep,
                            variables={'PAR.aggregate.parcel.condition.db.table.field' : curAggCondDBField},
                            inputfiles={'PAR.managed.above.thresh.filename' : 'CPW_protected_regen.txt'})
                    #raw_input("Ran cond model using "+curAggCondDBField + " Hit enter to continue" )
          
                self.logger.fine("\n--> limit.evolution of CPW initial condition...")
                run_r_code("limit.evolution.of.CPW.initial.condition.R", timestep)

                self.logger.fine("\n--> loss model...")
                run_r_code("loss.model.R", timestep)


                if variables['OPT.include.random.reserves.outside.GC'] and timestep > 0:
                    self.logger.fine("\n--> reserve random outside growth centres...")
                    #raw_input("About to run reserve random outside growth centres" )
                    
                    run_r_code("reserve.random.R", timestep, 
                        variables={'PAR.rate.of.CPW.reserved.per.timestep' : variables['PAR.rate.of.CPW.reserved.per.timestep.outside.GC'],
                            'PAR.limit.for.random.reserves' : variables['PAR.limit.for.random.reserves.outside.GC'],
                            'PAR.random.reserve.criteria.1' : variables['PAR.random.reserve.outside.GC.criteria.1'],
                            'PAR.random.reserve.criteria.2' : variables['PAR.random.reserve.outside.GC.criteria.2']},
                        outputfiles={'PAR.reserve.random.tmp.info.filename' : 'tmp.info.reserve.random.outside.gc.txt'})

                if variables['OPT.include.random.reserves.inside.GC'] and timestep > 0:
                    self.logger.fine("\n--> reserve random inside growth centres...")
                    #raw_input("About to run reserve random inside growth centres" )
                    
                    run_r_code("reserve.random.R", timestep, 
                        variables = {'PAR.rate.of.CPW.reserved.per.timestep' : variables['PAR.rate.of.CPW.reserved.per.timestep.inside.GC'],
                            'PAR.limit.for.random.reserves' : variables['PAR.limit.for.random.reserves.inside.GC'],
                            'PAR.random.reserve.criteria.1' : variables['PAR.random.reserve.inside.GC.criteria.1'],
                            'PAR.random.reserve.criteria.2' : variables['PAR.random.reserve.inside.GC.criteria.2']},
                        outputfiles={'PAR.reserve.random.tmp.info.filename' : 'tmp.info.reserve.random.inside.gc.txt'} )
                    #raw_input("Finished runnning reserve random inside growth centres" )
                    

                self.logger.fine("\n--> evaluate condition model for polygons...")
                run_r_code("eval.cond.polygon.R", timestep)

                if variables['OPT.generate.polygon.time.series']:
                    self.logger.fine("\n--> write.time.series.polygons...")
                    run_r_code("write.time.series.polygons.R", timestep)

                self.logger.fine("\n")
        return
