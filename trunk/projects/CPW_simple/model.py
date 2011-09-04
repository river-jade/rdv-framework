import csv
import decimal
import glob
import logging
import os
import sys

import basemodel

logger = logging.getLogger('model')

# Names of the fields. These short versions are used because otherwise the code
# becomes unwieldy. They also map to the column names in the spreadsheet upon
# which this code is based.

# outside GC
O = 'Total.area.of.CPW'
Q = 'Developable.or.Offsettable.after.deg.inc.management.of.offsets'
R = 'Developable.or.Offsettable.after.deg.and.offsetting.and.dev'
S = 'Developable.or.Offsettable.after.deg.inc.NO.management.OR.offsets.OR.dev'
T = 'Developable.or.Offsettable.after.deg.inc.NO.management.OR.offsets.BUT.inc.dev.for.No.Offset'
W = 'Secured.after.deg'
X = 'Dev.target'
Y = 'Actual.Dev'
Z = 'Offset.target'
AA = 'Actual.Offset'
AB = 'Strat.Ass.extra.offsets.target'
AD = 'Actual.Dev.Do.nothing'
AE = 'Do.Nothing'
AF = 'Dev.no.offsets'

# inside GC
AK = 'Total.Area.of.CPW'
AL = 'Offsetable.after.deg.inc.offset.management'
AM = 'Offsetable.after.deg.DOESNT.inc.offset.management'
AN = 'Offsetable.after.deg.and.offset.inc.offset.management'
AO = 'Devlopable.after.deg'
AP = 'Devlopable.after.deg.and.dev'
AR = 'Undevelopabe'
AU = 'Dev.target'
AV = 'Actual.Dev'
AW = 'Offset.target'
AX = 'Offset.after.deg'
AY = 'Actual.Offset'
AZ = 'Do.Nothing'
BA = 'Dev.no.offsets'

class Model(basemodel.BaseModel):
    def execute(self, runparams):
        """Executes the model and writes the output to the CSV file specified in the project params.
        """
        # get parameters qualified by input and output file paths
        qualifiedparams = runparams.getQualifiedParams(self.inputpath, self.outputpath)

        # Convert all values into decimals, because otherwise multiplication fails when run in jython (because
        # decimals get passed as java.math.BigDecimal, which can't be used with '*')
        # Note that this will fail if there are any non-numeric values in the variables.
        variables = dict((k, decimal.Decimal(str(v))) for k, v in 
                         dict(runparams.getVariables()).iteritems())

        constants = self.createconstants(variables)
        modelstates = []
        currentstate = self.createmodelstate0(variables, constants)
        modelstates.append(currentstate)
        
        for x in range(0, variables['num.steps']):
            currentstate = currentstate.evolve()
            modelstates.append(currentstate)
            # print currentstate # for debugging
        writecsv(modelstates, qualifiedparams['csv_output'])
    
    def createconstants(self, variables):
        """Extracts the constants from the variables and place them in a new dictionary
        """
        constants = {}
        constants['Prop.that.degrade'] = variables['Prop.that.degrade']
        constants['Pre1750.amount.of.CPW'] = variables['Pre1750.amount.of.CPW']
        constants['Strategic.Assess.Offsets.Outside.GC'] = variables['Strategic.Assess.Offsets.Outside.GC']
        constants['Offsets.Per.Year'] = variables['Offsets.Per.Year']
        constants['OutsideGC.Effective.Multiplier'] = variables['OutsideGC.Multiplier'] * variables['OutsideGC.Prob.offset.required']
        constants['OutsideGC.Developable.Or.Offsettable'] = variables['OutsideGC.Developable.Or.Offsettable']
        
        constants['OutsideGC.Protected'] = variables['OutsideGC.Protected']
        constants['OutsideGC.Secured'] = variables['OutsideGC.Secured']
        constants['OutsideGC.Total.Cleared.per.year'] = variables['OutsideGC.Total.Cleared.per.year']

        constants['InsideGC.Lost.Per.Year.Total'] = variables['InsideGC.Lost.Per.Year.Total']
        constants['InsideGC.Lost.Per.Year.Total.SEPP'] = variables['InsideGC.Lost.Per.Year.Total.SEPP']
        constants['InsideGC.Protected'] = variables['InsideGC.Protected']
        constants['InsideGC.Secured'] = variables['InsideGC.Secured']
        return constants

    def createmodelstate0(self, variables, constants):
        """Creates the first modelstate, setting initial values from the provided variables.
        """
        outsideGC = {}
        insideGC = {}

        # setup initial values
        # question for Michael: why are ther 
        outsideGC[Q] = constants['OutsideGC.Developable.Or.Offsettable']
        outsideGC[R] = constants['OutsideGC.Developable.Or.Offsettable']
        outsideGC[S] = constants['OutsideGC.Developable.Or.Offsettable']
        outsideGC[T] = constants['OutsideGC.Developable.Or.Offsettable']
        outsideGC[W] = constants['OutsideGC.Secured']
        outsideGC[X] = variables['OutsideGC.Dev.target']
        outsideGC[Y] = variables['OutsideGC.Actual.Dev']
        outsideGC[AA] = variables['OutsideGC.Actual.Offset']
        outsideGC[AB] = variables['OutsideGC.Strat.Ass.extra.offsets.target']
        outsideGC[AD] = outsideGC[AB]
        outsideGC[O] = outsideGC[R] + constants['OutsideGC.Protected'] + outsideGC[W] + outsideGC[AA]
        outsideGC[AE] = outsideGC[S] + constants['OutsideGC.Protected'] + outsideGC[W]
        outsideGC[AF] = constants['OutsideGC.Protected'] + outsideGC[W] + outsideGC[T]

        insideGC[AL] = variables['InsideGC.Offsetable.after.deg.inc.offset.management']
        insideGC[AM] = insideGC[AL] 
        insideGC[AN] = insideGC[AL] 
        insideGC[AO] = variables['InsideGC.Devlopable.after.deg']
        insideGC[AP] = insideGC[AO] 
        insideGC[AR] = variables['InsideGC.Undevelopabe']
        insideGC[AU] = variables['InsideGC.Dev.target']
        insideGC[AV] = variables['InsideGC.Actual.Dev']
        insideGC[AW] = variables['InsideGC.Offset.target']
        insideGC[AX] = variables['InsideGC.Offset.after.deg']
        insideGC[AY] = variables['InsideGC.Actual.Offset']
        insideGC[AK] = insideGC[AR] + insideGC[AL] + insideGC[AP] + \
                constants['InsideGC.Protected'] + constants['InsideGC.Secured'] 
        insideGC[AZ] = constants['InsideGC.Secured'] + constants['InsideGC.Protected'] + \
                insideGC[AR] + insideGC[AM] + insideGC[AO]
        insideGC[BA] = constants['InsideGC.Secured'] + constants['InsideGC.Protected'] + \
                insideGC[AR] + insideGC[AM] + insideGC[AP]

        modelstate = ModelState(constants, insideGC, outsideGC)
        modelstate.calculatefinal()
        modelstate.normalise()
        return modelstate

class ModelState(object):
    """Class representing the state of the model at a single point in time.
    """
    def __init__(self, constants, insideGC=None, outsideGC=None):
        self.constants = constants
        self.outsideGC = outsideGC or {}
        self.insideGC = insideGC or {}
        self.final = {}
        self.normalised = {}

    def evolve(self):
        """Evolves the model from this modelstate to the next, returning the newly created next modelstate.
        This modelstate is unchanged.
        """ 
        insideGC = self.evolveInsideGC()
        outsideGC = self.evolveOutsideGC()

        next = ModelState(self.constants, insideGC, outsideGC)

        # TODO(michaell): it's a bit ugly that the evolve* methods don't mutate the
        # model state object but these following two methods do. Maybe make this consistent
        # if it gets confusing / annoying.
        next.calculatefinal()
        next.normalise()
        return next

    def normalise(self):
        """Calculates the normalised values from both inside and outside growth 
        centres.
        """
        normalised = self.normalised
        final = self.final
        constants = self.constants
        normalised['Norm.CPW.area'] = final['CPW.In.And.Out'] / constants['Pre1750.amount.of.CPW']
        normalised['Norm.Do.Nothing'] = final['Do.Nothing'] / constants['Pre1750.amount.of.CPW']
        normalised['Dev.no.offset'] = final['Dev.no.offset'] / constants['Pre1750.amount.of.CPW']
        normalised['Available.CPW.left.outside.GCs'] = 1 if self.outsideGC[R] > 0 else 0
        normalised['Available.offset.CPW.left.inside.GCs'] = 1 if self.insideGC[AN] > 0 else 0
        normalised['Available.dev.CPW.left.inside.GCs'] = 1 if self.insideGC[AP] > 0 else 0
        normalised['Available.dev.and.offset.CPW.left.inside.GCs'] = normalised['Available.offset.CPW.left.inside.GCs'] or normalised['Available.dev.CPW.left.inside.GCs']
        normalised['Aavailable.CPW.anywhere'] = normalised['Available.CPW.left.outside.GCs'] or normalised['Available.dev.and.offset.CPW.left.inside.GCs']
        
    def calculatefinal(self):
        """Calculate the derived values from both inside and outside growth 
        centres.
        """
        final = self.final
        outsideGC = self.outsideGC
        insideGC = self.insideGC
        final['CPW.In.And.Out'] = outsideGC['Total.area.of.CPW'] + insideGC['Total.Area.of.CPW']
        final['Do.Nothing'] = outsideGC['Do.Nothing'] + insideGC['Do.Nothing']
        final['Dev.no.offset'] = outsideGC[AF] + insideGC[BA]

    def evolveOutsideGC(self):
        """Evolve the outside growth centre to the next modelstate.
        This method does not mutate the current modelstate, but merely 
        creates and returns a new dictionary with the evolved values.
        """
        nextOgc = {}
        thisOgc = self.outsideGC
        constants = self.constants

        nextOgc[Q] = thisOgc[Q] - ((thisOgc[Q] - thisOgc[AA]) * constants['Prop.that.degrade'])

        nextOgc[S] = thisOgc[S] * (1 - constants['Prop.that.degrade'])

        nextOgc[W] = thisOgc[W] * (1 - constants['Prop.that.degrade'])
        nextOgc[X] = thisOgc[X] + constants['OutsideGC.Total.Cleared.per.year']

        nextOgc[AB] = min(thisOgc[AB] + constants['Offsets.Per.Year'], constants['Strategic.Assess.Offsets.Outside.GC'])

        nextOgc[T] = max(0, nextOgc[S] - thisOgc[AD])
        nextOgc[Y] = nextOgc[X] if nextOgc[T] > 0 else thisOgc[Y]
        nextOgc[AE] = nextOgc[S] + constants['OutsideGC.Protected'] + nextOgc[W]
        nextOgc[AF] = constants['OutsideGC.Protected'] + nextOgc[W] + nextOgc[T]
        nextOgc[R] = max(0, nextOgc[Q] - thisOgc[Y] - thisOgc[AA])
        nextOgc[Y] = nextOgc[X] if nextOgc[R] > 0 else thisOgc[Y]
        nextOgc[Z] = nextOgc[Y] * constants['OutsideGC.Effective.Multiplier'] + nextOgc[AB]
        nextOgc[AA] = nextOgc[Z] if nextOgc[R] > 0 else thisOgc[AA]

        nextOgc[O] = nextOgc[R] + constants['OutsideGC.Protected'] + nextOgc[W] + nextOgc[AA]
        nextOgc[AD] = nextOgc[X] if nextOgc[T] > 0 else thisOgc[AD]
        return nextOgc

    def evolveInsideGC(self):
        """Evolve the inside growth centre to the next modelstate.
        This method does not mutate the current modelstate, but merely 
        creates and returns a new dictionary with the evolved values.
        """
        nextIgc = {}
        thisIgc = self.insideGC
        constants = self.constants

        S0 = constants['InsideGC.Protected']
        T0 = constants['InsideGC.Secured']
        B0 = constants['Prop.that.degrade']
        R08 = constants['InsideGC.Lost.Per.Year.Total']
        R015 = constants['InsideGC.Lost.Per.Year.Total.SEPP']

        nextIgc[AL] = max(0, thisIgc[AL] - ((thisIgc[AL] - thisIgc[AY]) * B0))
        nextIgc[AM] = thisIgc[AM] * (1 - B0)
        nextIgc[AN] = max(0,nextIgc[AL] - thisIgc[AX])
        nextIgc[AO] = thisIgc[AO] * (1 - B0)
        nextIgc[AP] = max(nextIgc[AO] - thisIgc[AV], 0)
        nextIgc[AR] = thisIgc[AR] * (1 - B0)
        nextIgc[AU] = R08 + thisIgc[AU]
        nextIgc[AK] = T0 + S0 + nextIgc[AR] + nextIgc[AL] + nextIgc[AP]
        nextIgc[AV] = nextIgc[AU] if nextIgc[AP] > 0 else thisIgc[AV]
        nextIgc[AW] = thisIgc[AW] + R015
        nextIgc[AX] = nextIgc[AW] if nextIgc[AN] > 0 else thisIgc[AX]
        nextIgc[AY] = min(nextIgc[AX], R015 * 30)
        nextIgc[AZ] = T0 + S0 + nextIgc[AR] + nextIgc[AM] + nextIgc[AO]
        nextIgc[BA] = T0 + S0 + nextIgc[AR] + nextIgc[AM] + nextIgc[AP]
        return nextIgc

    def __str__(self):
        """To string method. Writes each element of the modelstate, grouped by 
        category and alpha-sorted.
        """
        # sort and format function. alpha sorts the dictionary by key, and 
        # formats the floats to 3 decimal places.
        sort = lambda dictionary : '\n\t'.join(["%s : %0.3f" % 
                (key, dictionary[key]) for key in sorted(dictionary.iterkeys())])

        return """
Constants:\n\t%s
OutsideGC:\n\t%s
InsideGC:\n\t%s
Final:\n\t%s
Normalised:\n\t%s
    """ % (sort(self.constants), sort(self.outsideGC), sort(self.insideGC), 
           sort(self.final), sort(self.normalised))

def writecsv(modelstates, filename):
    """Write the output for all modelstates out in CSV format.
    """
    # lambda function to qualify all keys in a dictionary with a unique string, 
    # to avoid key clashes
    q = lambda dic, prefix: [(prefix + k, str(v)) for k, v in dic.iteritems()]

    # lambda function to merge the dictionaries for the modelstate in each 
    # timestep into a list of tuples
    merge = lambda modelstate: q(modelstate.normalised, 'norm.') + q(modelstate.final, 'final.') + \
            q(modelstate.outsideGC, 'outsideGC.') + q(modelstate.insideGC, 'insideGC.')

    # extract the fieldnames (taken from the last modelstate)
    fieldnames = [pair[0] for pair in merge(modelstates[-1])]
    # open the csv file for writing from a dictionary
    writer = csv.DictWriter(open(filename, 'wb'), fieldnames, dialect=csv.excel)

    # we do a little trick to write the header row, passing a dictionary where 
    # the values are the keys. this is a built-in in py 2.7, but jython uses
    # 2.6 libraries.
    writer.writerow(dict((k, k) for k in fieldnames)) # write header row
    # flatten the model state for each timestep, and pass to the csv writer to 
    # be written to output file.
    writer.writerows(dict(merge(row)) for row in modelstates)
    logger.info("Wrote csv to: %s" % filename)

