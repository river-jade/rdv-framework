import glob
import os

import basemodel

class Model(basemodel.BaseModel):
    def execute(self, runparams):

        variables = runparams.variables

        self.logger.fine("\n--> Running maxent")

        # this is for testing the repetitions file
        if variables['PAR.variable.to.test.repetitions'] > 0:
          self.logger.fine("Now Doing repetitions, PAR.variable.to.test.repetitions=%s" % \
                variables['PAR.variable.to.test.repetitions'])

        # test R code
        #self.run_r_code( "example.R", runparams )

        # run Maxent
        self.logger.fine("\n--> Running maxent")
        self.run_r_code( "run.maxent.R", runparams )

        # run Zonation
        self.logger.fine("\n--> Running zonation")
        self.run_r_code( "run.zonation.guppy.R", runparams )
