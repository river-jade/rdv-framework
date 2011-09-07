import glob
import logging
import os

import basemodel

logger = logging.getLogger('model')

class Model(basemodel.BaseModel):
    def execute(self, runparams):
        logger.info("I'm in model.py!!")
        self.run_r_code("example.R", runparams)
