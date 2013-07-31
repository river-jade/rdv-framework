import glob
import os

import basemodel

from pprint import pprint

import pickle

from Guppy import Guppy

"""
To run example code using jython:
java -jar tzar.jar execlocalruns --runnerclass=JythonRunner  --projectspec=projects/example-jython/projectparams.yaml --localcodepath=. --commandlineflags="-p example-jython"



To run guppy code using PYTHON:

cd /Users/Bill/D/rdv-framework
java -jar tzar.jar execlocalruns --runnerclass=PythonRunner  --projectspec=projects/guppy/projectparams.yaml --localcodepath=. --commandlineflags="-p guppy"

"""

class Model(basemodel.BaseModel):
    def execute(self, runparams):

#         variables = runparams.variables
#
#         self.logger.fine("\n--> Running maxent")
#
#         # this is for testing the repetitions file
#         if variables['PAR.variable.to.test.repetitions'] > 0:
#           self.logger.fine("Now Doing repetitions, PAR.variable.to.test.repetitions=%s" % \
#                 variables['PAR.variable.to.test.repetitions'])
#
#         # test R code
#         #self.run_r_code( "example.R", runparams )
#
#         # run Maxent
#         self.logger.fine("\n--> Running maxent")
#         self.run_r_code( "run.maxent.R", runparams )
#
#         # run Zonation
#         self.logger.fine("\n--> Running zonation")
#         self.run_r_code( "run.zonation.guppy.R", runparams )


        # the logging levels are (in descending order): severe, warning, info, config, fine,
        # finer, finest
        # by default tzar will log all at info and above to the console, and all logging to a logfile.
        # if the --verbose flag is specified, all logging will also go to the console.
        self.logger.fine("I'm in model.py!!")

        # get parameters qualified by input and output file paths
        # This is only required if you want to read / write input / output files from python.
        qualifiedparams = runparams.getQualifiedParams(self.inputpath, self.outputpath)

        print("qualifiedparams = ")
        pprint(qualifiedparams)
        print ("\n\n")

        # gets the variables, with (java) decimal values converted to python decimals
        # this is useful if you want to use arithmetic operations within python.
        variables = self.get_decimal_params(runparams)

        print("variables = ")
        pprint(variables)
        print ("\n\n")

        print("current directory = ")
        print(os.getcwd())
        print ("\n\n")

            #-------------------------------------------------------------------
            #  Write the qualifiedparams and variables dictionaries to
            #  a pickle file so that they can be unpickled by a test program
            #  that runs independent of tzar and just needs a pair of
            #  realistic dictionaries to test initialization of guppy values.
            #  Will remove this little code section once initialization
            #  code is working.
        pickleDictionariesForTesting = False
        if pickleDictionariesForTesting:
            self.pickleDictionaries (qualifiedparams, variables)
            #-------------------------------------------------------------------

        constants = None
        guppy = Guppy (variables, qualifiedparams)

    def pickleDictionaries (self, qualifiedparams, variables):

            #  Based on:
            #  http://www.saltycrane.com/blog/2008/01/saving-python-dict-to-file-using-pickle/

        pickleFileName = '/Users/Bill/D/rdv-framework/projects/guppy/pickeledGuppyInitializationTestParams.pkl'

            #  Write python dicts to a file.
        output = open (pickleFileName, 'wb')
        pickle.dump (qualifiedparams, output)
        pickle.dump (variables, output)
        output.close ()

            #  Read python dicts back from the file and echo to log file
            #  for comparison later.
        pkl_file = open (pickleFileName, 'rb')
        qp = pickle.load (pkl_file)
        v = pickle.load (pkl_file)
        pkl_file.close ()

        print "\n\n=========================\nunpickled qualifiedparams = \n"
        pprint (qp)
        print "\n\n=========================\nunpickled variables = \n"
        pprint (v)



