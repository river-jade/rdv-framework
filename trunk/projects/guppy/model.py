import glob
import os

import basemodel

class Model(basemodel.BaseModel):
    def execute(self, runparams):

        variables = runparams.variables

        self.logger.info("Executing model.py for the Guppy project")

        # this is for testing the repetitions file
        if variables['PAR.variable.to.test.repetitions'] > 0:
            print "\nNow Doing repetitions, PAR.variable.to.test.repetitions=%s" %  \
                   variables['PAR.variable.to.test.repetitions']

        # test R code
        #self.run_r_code( "example.R", runparams )

        # run Maxent
        self.logger.info( "\n--> Running maxent" )
        self.run_r_code( "run.maxent.R", runparams )

        # run Zonation
        self.logger.info( "\n--> Running zonation" )
        self.run_r_code( "run.zonation.R", runparams )
