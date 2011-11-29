import csv
import decimal
import glob
import os
import sys

import basemodel

import java.math.BigDecimal

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

        # Convert all BigDecimal values into decimals, because otherwise 
        # multiplication fails when run in jython (because
        # decimals get passed as java.math.BigDecimal, which can't be used with '*')
        # TODO(michaell): Do this in modelrunner.py so that it works for other projects.
        variables = dict((k, decimal.Decimal(str(v)) if type(v) is java.math.BigDecimal else v) for k, v in 
                         dict(runparams.getVariables()).iteritems())

        constants = self.createconstants(variables)
        modelstates = []
        currentstate = self.createmodelstate0(variables, constants)
        modelstates.append(currentstate)

        self.logger.fine("Prop.that.degrade = " + str(constants['Prop.that.degrade']))
        self.logger.fine("OutsideGC.Multiplier = " + str(variables['OutsideGC.Multiplier']))
        
        for x in range(0, variables['num.steps']):
            currentstate = currentstate.evolve()
            modelstates.append(currentstate)
            # self.logger.fine(currentstate) # for debugging
        writecsv(modelstates, qualifiedparams['csv_output'], self.logger)
    
    def createconstants(self, variables):
        """Extracts the constants from the variables and place them in a new dictionary
        """
        constants = {}
        constants['Prop.that.degrade'] = variables['Prop.that.degrade']
        constants['Pre1750.amount.of.CPW'] = variables['Pre1750.amount.of.CPW']
        constants['Strategic.Assess.Offsets.Outside.GC'] = variables['Strategic.Assess.Offsets.Outside.GC']
        constants['Strat.Assess.Offsets.Per.Year'] = variables['Strat.Assess.Offsets.Per.Year']
        constants['OutsideGC.Effective.Multiplier'] = variables['OutsideGC.Multiplier'] * variables['OutsideGC.Prob.offset.required']
        constants['OutsideGC.Developable.Or.Offsettable'] = variables['OutsideGC.initial.area.developable.or.offsettable']
        
        constants['OutsideGC.Protected'] = variables['OutsideGC.initial.area.protected']
        constants['OutsideGC.Secured'] = variables['OutsideGC.initial.area.secured']
        constants['OutsideGC.Total.Cleared.per.year'] = variables['OutsideGC.Total.Cleared.per.year']

        constants['InsideGC.Lost.Per.Year.Total'] = variables['InsideGC.Lost.Per.Year.Total']
        constants['InsideGC.Offset.Total.SEPP'] = variables['InsideGC.Offset.Total.SEPP']
        constants['InsideGC.Offset.Per.Year.Total.SEPP'] = variables['InsideGC.Offset.Per.Year.Total.SEPP']
        constants['InsideGC.Protected'] = variables['InsideGC.initial.area.protected']
        constants['InsideGC.Secured'] = variables['InsideGC.initial.area.secured']
        return constants

    def createmodelstate0(self, variables, constants):
        """Creates the first modelstate, setting initial values from the provided variables.
        """
        outsideGC = {}
        insideGC = {}

        # setup initial values
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

        insideGC[AL] = variables['InsideGC.initial.area.available.for.offsets']
        insideGC[AM] = insideGC[AL] 
        insideGC[AN] = insideGC[AL] 
        insideGC[AO] = variables['InsideGC.initial.area.available.for.dev']
        insideGC[AP] = insideGC[AO] 
        insideGC[AR] = variables['InsideGC.initial.area.undevelopabe']
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
        normalised['Available.dev.and.offset.CPW.left.inside.GCs'] = \
                                                normalised['Available.offset.CPW.left.inside.GCs'] \
                                                or normalised['Available.dev.CPW.left.inside.GCs']
        normalised['Aavailable.CPW.anywhere'] = normalised['Available.CPW.left.outside.GCs'] \
                                                or normalised['Available.dev.and.offset.CPW.left.inside.GCs']
        
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

        #--------------------------------------------------------------
        # Calculate the total amounts of CPW including combinations of
        # deg, dev, and offsets 
        #--------------------------------------------------------------

        # "Developable / Offsettable after deg (inc management of
        # offsets)" and offsetting
        nextOgc[Q] = thisOgc[Q] - ((thisOgc[Q] - thisOgc[AA]) * constants['Prop.that.degrade'])
        
        # "Developable / Offsettable after deg and offsetting and dev"
        nextOgc[R] = max(0, nextOgc[Q] - thisOgc[Y] - thisOgc[AA])   # "max" not in spreadsheed

        # "Developable / Offsettable after deg (inc NO management OR offsets OR dev)"
        nextOgc[S] = thisOgc[S] * (1 - constants['Prop.that.degrade'])

        # "Developable / Offsettable after deg (inc NO management OR
        # offsets) BUT inc dev for No Offset)"
        #   This tracks the amount of CPW left if there is no offsets
        #   but develompment and deg occur.  This is for the do nothing
        #   scenario.
        nextOgc[T] = max(0, nextOgc[S] - thisOgc[AD])
        

        #---------------
        # Secured land
        #---------------

        # "Secured after deg" - degrade the secured land
        nextOgc[W] = thisOgc[W] * (1 - constants['Prop.that.degrade'])
        

        #---------------
        # Development
        #---------------

        # Target amount to be developed
        nextOgc[X] = thisOgc[X] + constants['OutsideGC.Total.Cleared.per.year']

        # Actual amount developed with dev and offsetting occurring
        # TODO: check if this is bug original line below from Michael                
        # nextOgc[Y] = nextOgc[X] if nextOgc[T] > 0 else thisOgc[Y] 
        nextOgc[Y] = nextOgc[X] if nextOgc[R] > 0 else thisOgc[Y]            

        # Actual amount developed (if offsetting occurs)
        nextOgc[Y] = nextOgc[X] if nextOgc[R] > 0 else thisOgc[Y]
        
        # Actual amount developed (if no offsetting occurs)
        nextOgc[AD] = nextOgc[X] if nextOgc[T] > 0 else thisOgc[AD]

        #---------------
        # Offsets
        #---------------

        # Strat Ass extra offsets target
        nextOgc[AB] = min(thisOgc[AB] + constants['Strat.Assess.Offsets.Per.Year'], \
                          constants['Strategic.Assess.Offsets.Outside.GC'])
        
        # Offset target
        nextOgc[Z] = nextOgc[Y] * constants['OutsideGC.Effective.Multiplier'] + nextOgc[AB]

        # Actual amount offset
        nextOgc[AA] = nextOgc[Z] if nextOgc[R] > 0 else thisOgc[AA]


        #----------------------------------------------------------
        # Calculate area of CPW for offset and non-offset scenarios
        #----------------------------------------------------------

        # Tracking the total area of CPW
        nextOgc[O] = nextOgc[R] + constants['OutsideGC.Protected'] + nextOgc[W] + nextOgc[AA]

        # Tracking the area of CPW for "Do nothing"
        nextOgc[AE] = nextOgc[S] + constants['OutsideGC.Protected'] + nextOgc[W]

        # Tracking the area of CPW for "Dev no offsets"
        nextOgc[AF] = constants['OutsideGC.Protected'] + nextOgc[W] + nextOgc[T]
        
        return nextOgc
    

    def evolveInsideGC(self):
        """Evolve the inside growth centre to the next modelstate.
        This method does not mutate the current modelstate, but merely 
        creates and returns a new dictionary with the evolved values.
        """
        nextIgc = {}
        thisIgc = self.insideGC
        constants = self.constants

        # Note: inside the GC, there are separate areas to be
        # developed and offset that don't overlap
        
        # "Offsetable after deg (inc offset management)"
        nextIgc[AL] = max(0, thisIgc[AL] - ((thisIgc[AL] - thisIgc[AY]) * constants['Prop.that.degrade']))

        # "Offsetable after deg (DOESNT inc offset management)" - for the Do Nothing scenario
        nextIgc[AM] = thisIgc[AM] * (1 - constants['Prop.that.degrade'])

        # "Offsetable after deg and offset (inc offset management)" - inc offset from previous time steop
        nextIgc[AN] = max(0,nextIgc[AL] - thisIgc[AX])

        # "Devlopable after deg"
        nextIgc[AO] = thisIgc[AO] * (1 - constants['Prop.that.degrade'])

        # "Devlopable after deg and dev" 
        nextIgc[AP] = max(nextIgc[AO] - thisIgc[AV], 0)

        # Undevelopabe
        nextIgc[AR] = thisIgc[AR] * (1 - constants['Prop.that.degrade'])


        #---------------
        # Development
        #---------------

        # Dev target
        nextIgc[AU] = constants['InsideGC.Lost.Per.Year.Total'] + thisIgc[AU]

        # Actual dev        
        nextIgc[AV] = nextIgc[AU] if nextIgc[AP] > 0 else thisIgc[AV]

        #---------------
        # Offsets
        #---------------
        
        # Offset target
        nextIgc[AW] = thisIgc[AW] + constants['InsideGC.Offset.Per.Year.Total.SEPP']
        
        # "Offset after deg" - if there is nothing left to offset then don't offset anything
        nextIgc[AX] = nextIgc[AW] if nextIgc[AN] > 0 else thisIgc[AX]

        # Actual offset (making sure it doesn't go above the total SEPP ampunt)
        nextIgc[AY] = min(nextIgc[AX], constants['InsideGC.Offset.Total.SEPP'] )


        #----------------------------------------------------------
        # Calculate area of CPW for offset and non-offset scenarios
        #----------------------------------------------------------
        
        S0 = constants['InsideGC.Protected']
        T0 = constants['InsideGC.Secured']

        # Total area of CPW (note AP and AQ in the spreadsheet have been merged into 1 value here
        nextIgc[AK] = S0 + T0 + nextIgc[AR] + nextIgc[AL] + nextIgc[AP]

        # Do Nothing
        nextIgc[AZ] = T0 + S0 + nextIgc[AR] + nextIgc[AM] + nextIgc[AO]

        # Dev no offsets
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

def writecsv(modelstates, filename, logger):
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
    f = open(filename, 'wb')
    writer = csv.DictWriter(f, fieldnames, dialect=csv.excel)

    # we do a little trick to write the header row, passing a dictionary where 
    # the values are the keys. this is a built-in in py 2.7, but jython uses
    # 2.6 libraries.
    writer.writerow(dict((k, k) for k in fieldnames)) # write header row
    # flatten the model state for each timestep, and pass to the csv writer to 
    # be written to output file.
    writer.writerows(dict(merge(row)) for row in modelstates)
    f.close()
    logger.fine("Wrote csv to: %s" % filename)

