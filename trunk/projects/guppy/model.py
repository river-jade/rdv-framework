import glob
import logging
import os

import basemodel

logger = logging.getLogger('model')

class Model(basemodel.BaseModel):
    def execute(self, runparams):

        variables = runparams.variables

        logger.info("Executing model.py for the Guppy project")

        # this is for testing the repetitions file
        if variables['PAR.variable.to.test.repetitions'] > 0:
            print "\nNow Doing repetitions, PAR.variable.to.test.repetitions=%s" %  \
                   variables['PAR.variable.to.test.repetitions']

        # test R code
        #self.run_r_code( "example.R", runparams )

        # run Maxent
        logger.info( "\n--> Running maxent" )
        self.run_r_code( "run.maxent.R", runparams )

        # run Zonation
        logger.info( "\n--> Running zonation" )
        self.run_r_code( "run.zonation.R", runparams )
