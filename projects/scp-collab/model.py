import glob
import os

import basemodel

class Model(basemodel.BaseModel):
    def execute(self, runparams):

        variables = runparams.variables

        # self.logger.fine("\n--> Running maxent")
        # this is for testing the repetitions file
        # if variables['PAR.variable.to.test.repetitions'] > 0:
        #   self.logger.fine("Now Doing repetitions, PAR.variable.to.test.repetitions=%s" % \
        #         variables['PAR.variable.to.test.repetitions'])


        # run Zonation
        self.logger.fine("\n--> Running zonation")
        self.run_r_code( "run.zonation.scp-collab.R", runparams )
        
        self.run_r_code( "scp-collab.eval.z.results.R", runparams )
