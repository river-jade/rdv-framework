import glob
import os

import basemodel

from pprint import pprint

import pickle

"""
To run example code using jython:
java -jar tzar.jar execlocalruns --runnerclass=JythonRunner  --projectspec=projects/example-jython/projectparams.yaml --localcodepath=. --commandlineflags="-p example-jython"



To run guppy code using PYTHON:

cd rdv-framework
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
#        print(qualifiedparams)
        pprint(qualifiedparams)
        print ("\n\n")

        # gets the variables, with (java) decimal values converted to python decimals
        # this is useful if you want to use arithmetic operations within python.
        variables = self.get_decimal_params(runparams)

        print("variables = ")
#        print(variables)
        pprint(variables)
        print ("\n\n")

        print("current directory = ")
        print(os.getcwd())

        print("runparams = ")
        print(runparams)
#        pprint(runparams)
        print ("\n\n")



		# write python dict to a file
#		mydict = {'a': 1, 'b': 2, 'c': 3}
		pickleFileName = 'testParams.pkl'
		output = open (pickleFileName, 'wb')
		pickle.dump (qualifiedparams, output)
		output.close ()

		# read python dict back from the file
		pkl_file = open (pickleFileName, 'rb')
		qp = pickle.load (pkl_file)
		pkl_file.close ()

		print "\n\n=========================\nunpickled qualifiedparams = \n"
		pprint (qp)


        # NOTE: this run_r_code fucntion calls the example on the R
        # directory ie rdv-framework/R/example.R

#         self.run_r_code("example.R", runparams)
###        self.run_r_code("                                         example.R", runparams)

    def __init__(self):			#  Just dummying this in for the moment...
        self.qualifiedparams = {}
        self.variables = {}
        self.runparams = {}

