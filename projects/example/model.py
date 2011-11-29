import glob
import os

import basemodel

class Model(basemodel.BaseModel):
    def execute(self, runparams):
        self.logger.info("I'm in model.py!!")
        self.run_r_code("example.R", runparams)
