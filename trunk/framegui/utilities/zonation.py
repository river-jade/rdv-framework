#!usr/bin python
# zigcom.py
# coding=utf-8

import pickle
import os, sys
from configobj import ConfigObj
from types import IntType, FloatType
from util import Readexcel

class Zigcommander(object):


    '''A class for creating batch-run capability for Zonation.
    '''

    def __init__(self, name=None, pickle_file=None, autosave=False, home=""):

        self.index = -1

        self.name = name
        self.home = home

        # Set the DOS command parameters 'command name of .exe'
        self.doscommand = 'call %s ' % os.path.join(self.home, 'zig2')

        self.autosave = autosave
        if autosave:
            self.pickle_file = pickle_file

        # Create a batch-run container
        self.runs = []

        if pickle_file != None and os.path.exists(os.path.join(self.home, pickle_file)):
            print 'Using existing configuration file'
            # Open the shelf file
            pkl_file = open(os.path.join(self.home, pickle_file), 'rb')
            self.runs  = pickle.load(pkl_file)

            pkl_file.close()

    def __str__(self):
        return str(self.runs)

    def __iter__(self):
        return self

    def next(self):
        if self.index == len(self.runs) - 1:
            raise StopIteration
        self.index = self.index + 1
        return self.runs[self.index]

    def __del__(self):
        if self.autosave and self.runs != []:
                self.pickle_data(self.runs, self.pickle_file)

    def create_batch_file(self, output=None, exclude=None, append=False):
        '''Method to print batch file into a file. Exclude
        parameter defines a list of object parameters to be excluded.
        '''
        if not output:
            output = os.path.join(self.home, 'run_multiple.bat')
        else:
            output = os.path.join(self.home, output)

        if self.runs:
            if append:
                outfile = open(output, 'a')
            else:
                outfile = open(output, 'w')
            # Loop through self.runs objects and pretty print parameters,
            # finally strip out trailing newline
            outfile.write(''.join(self.doscommand + cont.pprint(exclude)
                                   for cont in self))
            outfile.close()

            return output

    def create_config_file(self, filename='zig.dat', use_default=True):
        return Zigconfig(filename, use_default, home=self.home)

    def create_run_object(self, **kwargs):
        self.runs.append(Zigrun(home=self.home, **kwargs))

    def getname(self):
        return self.name

    def get_z_home(self):
        return self.home

    def pickle_data(self, data, pickle_file):
        output = open(os.path.join(self.home, pickle_file), 'wb')
        # Pickle the data using the highest protocol available.
        pickle.dump(data, output, -1)

class Zigconfig(object):

    '''A class for creating Zonation configuration files.
    '''

    def __init__(self, filename=None, use_default=False, home=""):

        self.home = home
        self.default = os.path.join(self.home, 'settings_template.dat')
        if filename is None and os.path.exists(self.default) or use_default:
            self.config = ConfigObj(self.default)
        else:
            self.config = ConfigObj(filename)
        self.config.filename = os.path.join(self.home, filename)
        # Initiate sections, keywords and values

    def default_values(self):
        if os.path.exists(self.default):
            self.config = ConfigObj(self.default)
            self.config.filename = self.default
        else:
            print 'No default template available.'

    def get_all_sections(self):
        return self.config.keys()

    def get_all_keywords(self, section):
        return self.config[section].scalars

    def has_section(self, section):
        return section in self.config.keys()

    def has_keyword(self, section, keyword):
        return keyword in self.config[section].scalars

    def get_value(self, section, keyword):
        try:
            return self.config[section][keyword]
        except:
            return -1

    def set_value(self, section, keyword, value):
        if self.has_section(section) and self.has_keyword(section, keyword):
            self.config[section][keyword] = str(value)

    def write(self):
        outfile = open(self.config.filename, 'w')
        self.config.write(outfile)

class Ziginspector(object):
    '''A class for handling Zonation result files and plotting figures.
    '''

    def __init__(self, resultfile):

        try:
            self.file = open(resultfile, 'r')
            results = self.file.readlines()
            # First data list holds the used run parameters
            self.runparams = []
            self.curves =  []

            # Run parameters come first
            target = self.runparams

            # Iterate through the lines excluding the first line
            for line in results[1:]:
                target.append(line.split())
                # Change target when curve headers is reached
                if 'Prop_landscape_lost' in line:
                    target = self.curves

        except IOError:
            print 'Input result file name wrong!'

    def plot_data(self, species):

        import pylab as p

        data = []
        lost = []
        for line in self.curves[1:]:
            data.append(line[species+5])
            lost.append(line[0])
        p.plot(data, lost, color='red', lw=2)
        p.axis([0, 1.0, 0, 1.0])
        p.xlabel('Proportion of landscape lost')
        p.ylabel('Proportion of distribution remaining')
        p.show()

class Zigrun(object):

    '''A class representing single Zonation run in a batch mode.
    '''

    # Class variable keeps track of instantiated objects
    refcounter = 0
    # UID variable to be assigned as an id
    UID = 0

    def __init__(self, **kwargs):
        '''Constructor can have a shelf file (shelved object) as
        a parameter if previous configuration data exists.
        '''

        # Adjust reference counter and UID
        Zigrun.refcounter = Zigrun.refcounter + 1
        Zigrun.UID = Zigrun.UID + 1

        # Create a list holding the parameter names for order
        self._pnames = ['id', 'load', 'settings', 'sppfiles', 'output',
                        'UCA', 'DS', 'alphamult', 'closewin']


        # Create a parameter dictionary with the right keys and default values
        self._params = {self._pnames[0]: Zigrun.UID,
                    # Previous solution loading
                    self._pnames[1]: '-r',
                    # Zonation run-settings file
                    self._pnames[2]: 'settings.dat',
                    # Zonation species list file/files
                    self._pnames[3]: 'specieslistfile.spp',
                    # Name of the output file
                    self._pnames[4]: 'output.txt',
                    # Uncertainty analysis
                    self._pnames[5]: 0.0,
                    # Distribution smoothing
                    self._pnames[6]: 0,
                    # Dispersal kernel (alpha) multiplier
                    self._pnames[7]: 1.0,
                    # Should Zonation window be closed after each run
                    self._pnames[8]: 1}

        if kwargs != {}:
            for key in kwargs.keys():
                if self._params.has_key(key):
                    self._params[key] = kwargs[key]

    def __str__(self):
        values = self.getparams()
        keys = self._params.keys()
        keys.sort()
        return '%s%s' % ('\n'.join((item + ':' + self.padding(item) *
                                      '\t' + values[item]) for item in keys),
                          '\n')

    def __del__(self):
        # Release the unique id number
        Zigrun.refcounter = Zigrun.refcounter - 1

    def get_id(self):
        return self._params['id']

    def get_load(self):
        return self._params['load']

    def set_load(self, bool):
        self._params['load'] = bool

    def get_output(self):
        return self._params['output']

    def set_output(self, name):
        self._params['output'] = name

    def get_UCA(self):
        return self._params['UCA']

    def set_UCA(self, value):
        self._params['UCA'] = value

    def get_DS(self):
        return self._params['DS']

    def set_DS(self, value):
        self._params['DS'] = value

    def get_settings(self):
        return self._params['settings']

    def set_settings(self, value):
        self._params['settings'] = value

    def get_sppfiles(self):
        return self._params['sppfiles']

    def set_sppfiles(self, value):
        self._params['sppfiles'] = value

    def get_alphamult(self):
        return self._params['alphamult']

    def set_alphamult(self, value):
        self._params['alphamult'] = value

    def get_closewin(self):
        return self._params['closewin']

    def set_closewin(self, value):
        self._params['closewin'] = value

    id = property(get_id)
    load = property(get_load, set_load, '')
    output = property(get_output, set_output, '')
    UCA = property(get_UCA, set_UCA, '')
    DS = property(get_DS, set_DS, '')
    settings = property(get_settings, set_settings, '')
    sppfiles = property(get_sppfiles, set_sppfiles, '')
    alphamult = property(get_alphamult, set_alphamult, '')
    closewin = property(get_closewin, set_closewin, '')

    # Helper methods

    def create_spp_file(self, filename=''):
        pass

    def getparams(self):
        """Returns a dictionary with parameters and corresponding values. Keys
        are parameter names held in class list params, values are corresponding
        values. All values are given as strings.
        """
        return{'id': str(self.id), 'load': str(self.load),
                'output': str(self.output), 'UCA': str(self.UCA),
                'DS': str(self.DS), 'settings': str(self.settings),
                'sppfiles': str(self.sppfiles), 'alphamult': str(self.alphamult),
                'closewin': str(self.closewin)}

    def padding(self, string):
        """Helper functions that return a factor for tab padding in string
        representation."""
        if len(string) < 7:
            return 2
        else:
            return 1

    def pprint(self, exclude=None):
        '''Return a pretty print representation of object parameters. Exclude
        parameter defines a list of object parameters to be excluded.

        Return String
        '''
        values = self.getparams()
        selparams = self._pnames
        if exclude != None:
            for exc in exclude:
                if exc in selparams:
                    selparams.remove(exc)

        return '%s%s' % (' '.join((values[item]) for item in selparams), '\n')

class Sppobject(object):
    '''Class instances represent a single Zonation input object (i.e. raster layer).
    Numerical parameters and file path are represented as properties.
    '''

    # Class variable keeps track of instantiated objects
    refcounter = 0
    # UID variable to be assigned as an id
    UID = 0

    #weight=1.0, alpha=1.0, bqp=1, bqp_b=1, cellrem=1.0, sppfile=None

    def __init__(self, params, index=0):
        '''Constructor method has default values for parameters
        to enable batch creation of objects. However, these refer
        to dummy variables in Zonation manual.
        '''

        # Adjust reference counter and UID
        Sppobject.refcounte = Sppobject.refcounter + 1
        Sppobject.UID = Sppobject.UID + 1

        # Assign instance variables if given to the constructor
        self.__id = Sppobject.UID
        self.__weight = params['weight'][index]
        self.__alpha = params['alpha'][index]
        self.__bqp = params['bqp'][index]
        self.__bqp_b = params['bqp_b'][index]
        self.__cellrem = params['cellrem'][index]
        self.__sppfile = params['sppfile'][index]

        # A list holding the names for important parameters
        self.__params = ['id', 'weight', 'alpha', 'bqp', 'bqp_b',
                        'cellrem', 'sppfile']

        # Set local assertion warnings
        self.s_typeint = 'Value must be integer type >> current type: '
        self.s_typeintflt = 'Value must be integer or float type >> current type: '
        self.s_pos = 'Value must be positive >> current value: '
        self.s_path = 'File entered does not exist >> current path: '
        self.s_file = 'File entered is not an ASCII raster >> file extension: '

    def __str__(self):
        values = self.getparams()
        return '%s%s' % ('\n'.join((item + ':' + self.padding(item) *
                                      '\t' + values[item]) for item in self.__params),
                          '\n')

    def __del__(self):
        # Release the unique id number
        Sppobject.refcounter = Sppobject.refcounter - 1

    # Accessor methods

    # ------ id -------
    def getid(self):
        return self.__id

    def setid(self, value):
        assert type(value) is IntType, '%s%s' % (self.s_typeint, type(value))
        self.__id = value

    def delid(self):
        del self.__id

    # ------ weight -------

    def setweight(self, value):
        assert type(value) in (IntType, FloatType), '%s%s' % (self.s_typeintflt, type(value))
        assert value > 0, '%s%s' % (self.s_pos, value)
        self.__weight = float(value)

    def getweight(self):
        return self.__weight

    def delweight(self):
        del self.__weight

    # ------ alpha -------

    def getalpha(self):
        return self.__alpha

    def setalpha(self, value):
        assert type(value) in (IntType, FloatType), '%s%s' % (self.s_typeintflt, type(value))
        assert value >= 0.0, '%s%s' % (self.s_pos, value)
        self.__alpha = value

    def delalpha(self):
        del self.__alpha

    # ------ bqp -------

    def getbqp(self):
        return self.__bqp

    def setbqp(self, value):
        assert type(value) in (IntType, FloatType), '%s%s' % (self.s_typeintflt, type(value))
        assert value > 0.0, '%s%s' % (self.s_pos, value)
        self.__bqp = value

    def delbqp(self):
        del self.__bqp

    # ------ bqp_b -------

    def getbqp_b(self):
        return self.__bqp_b

    def setbqp_b(self, value):
        assert type(value) in (IntType, FloatType), '%s%s' % (self.s_typeintflt, type(value))
        assert value > 0.0, '%s%s' % (self.s_pos, value)
        self.__bqp = value

    def delbqp_b(self):
        del self.__bqp

    # ------ cellrem -------

    def getcellrem(self):
        return self.__cellrem

    def setcellrem(self, value):
        assert type(value) in (IntType, FloatType), '%s%s' % (self.s_typeintflt, type(value))
        assert value > 0.0, '%s%s' % (self.s_pos, value)
        self.__cellrem = value

    def delcellrem(self):
        del self.__cellrem

    # ------ sppfile -------

    def getsppfile(self):
        return self.__sppfile

    def setsppfile(self, value):
        assert os.path.exists(value), '%s%s' % (self.s_path, value)
        self.__sppfile = value

    def delsppfile(self):
        del self.__sppfile

    id = property(getid, setid, delid, '')
    weight = property(getweight, setweight, delweight, '')
    alpha = property(getalpha, setalpha, delalpha, '')
    bqp = property(getbqp, setbqp, delbqp, '')
    bqp_b = property(getbqp_b, setbqp_b, delbqp_b, '')
    cellrem = property(getcellrem, setcellrem, delcellrem, '')
    sppfile = property(getsppfile, setsppfile, delsppfile, '')

    # Helper methods

    def getparams(self):
        """Returns a dictionary with parameters and corresponding values. Keys
        are parameter names held in class list params, values are corresponding
        values. All values are given as strings. Exclude
        parameter defines a list of object parameters to be excluded.
        """
        return{self.__params[0]: str(self.getid()), self.__params[1]: str(self.getweight()),
                self.__params[2]: str(self.getalpha()), self.__params[3]: str(self.getbqp()),
                self.__params[4]: str(self.getbqp_b()), self.__params[5]: str(self.getcellrem()),
                self.__params[6]: str(self.getsppfile())}

    def padding(self, string):
        """Helper functions that return a factor for tab padding in string
        representation."""
        if len(string) < 7:
            return 2
        else:
            return 1

    def pprint(self, exclude=None):
        '''Return a pretty print representation of object parameters. Exclude
        parameter defines a list of object parameters to be excluded.

        Return String
        '''
        values = self.getparams()
        selparams = self.__params
        for exc in exclude:
            if exc in selparams:
                selparams.remove(exc)

        return '%s%s' % (' '.join((values[item]) for item in selparams), '\n')

class Sppfactory(object):
    '''Class for creating input list file for Zonation. Instantiates individual
    Sppobjects.
    '''

    def __init__(self, home="", name='specieslistfile', params={'weight':[1.0],
                'alpha':[1.0], 'bqp':[1], 'bqp_b':[1], 'cellrem':[1.0],
                'sppfile':[]}):
        # Counter variable to track the number of live Sppobjects
        self.sppobject = 0
        # List to hold created Sppobjects
        self.objectrack = []
        # Iteratot index
        self.index = 0 - 1
        # Object nam
        self.name = name

        self.params = params

        self.envar = 'ZONATION_HOME'
        if os.environ.get(self.envar):
            self.home = os.environ.get(self.envar)
            #print 'Zonation home (%s) set to: %s' % (self.envar, self.home)
        elif home is not "":
            self.home = home
        else:
            print 'Environment variable (%s) not set.' % self.envar
            print 'Provide home location manually.'
            sys.exit(0)

    def __iter__(self):
        return self

    def next(self):
        if self.index == len(self.objectrack) - 1:
            raise StopIteration
        self.index = self.index + 1
        return self.objectrack[self.index]

    def add_to_rack(self, path, inputdir, ext='.asc', sheet=None, duplicate=False,
                    weight=False, alpha=0, method=1, con=False):
        '''Method creates Sppobject(s) from input path. If path points
        to a single ASCII raster file only one Spp object is created and
        added to objectrack. If path points to a directory, all files in
        the directory receive a respective Sppobject representation. By
        default duplicate is off (False) -> if file already has an object
        in objectstack it will not be added.

        An additional Excel file can used a configuration reference, in
        this case the path passed as a parameter points to a valid Excel
        file. In this case also a correct sheet name must be provided.
        '''

        if (inputdir):
            path = os.path.join(path, inputdir)

        if os.path.exists(path) and path.endswith('.xls'):
            # Read in the Excel file
            xl = Readexcel(path)

            # Parameter lists from the right sheet
            # TODO: column headers hard coded
            if weight == 1:
                self.params['weight'] = xl.getcol(sheet, 'Weight')
            elif weight == 2:
                self.params['weight'] = xl.getcol(sheet, 'localWeight')
            elif weight == 3:
                self.params['weight'] = xl.getcol(sheet, 'abcWeight')
            else:
                self.params['weight'] = xl.getcol(sheet, 'nonWeight')

            # TODO: this is dysfunctional
            alphas = {False: 'Alpha',
                      True: 'Alpha'}

            self.params['alpha'] = xl.getcol(sheet, alphas[alpha])

            self.params['bqp'] = map(int, xl.getcol(sheet, 'BQP'))
            self.params['bqp_b'] = map(int, xl.getcol(sheet, 'BQP_b'))

            if method == 1:
                self.params['cellrem'] = xl.getcol(sheet, 'Cellrem')
            elif method == 2:
                self.params['cellrem'] = xl.getcol(sheet, 'smallCellrem')

            # Check that the spp file specified exists
            ascii = xl.getcol(sheet, 'Filepath_ascii')
            error = False
            for file in ascii:
                if not os.path.exists(file):
                    print 'ASCII file %s does not exist.' % file
                    error = True
            if error:
                print 'One or more ASCII files did not exist, aborting.'
                sys.exit(0)

            self.params['sppfile'] = ascii

            for i in xrange(xl.nrows(sheet) - 1):
                self.objectrack.append(Sppobject(self.params, i))

        elif os.path.exists(path) and path.endswith(ext) and not duplicate:
            # Path points to a single file, no duplicate
            if path not in self.getpaths():
                self.params['sppfile'] = path
                self.objectrack.append(Sppobject(self.params))
        elif os.path.exists(path) and path.endswith(ext):
            # Path points to a single file, duplicate
            self.params['sppfile'] = path
            self.objectrack.append(Sppobject(self.params))
        elif os.path.exists(path):
            # Path is a directory path that exists
            files = self.listfiles(path, ext)
            for i, file in enumerate(files):
                if path != self.home:
                    file = os.path.join(path, file)
                if inputdir:
                    file = os.path.join(inputdir, file)
                # TODO: ugly hack!
                if len(self.params['sppfile']) < 1:
                    self.params['sppfile'].append(file)
                else:
                    self.params['sppfile'][0] = file
                self.objectrack.append(Sppobject(self.params))
        else:
            print 'File / path entered does not exist.'

    def describe(self):
        '''Method descirbes object rack by printing string representations
        of individual objects.
        '''
        for obj in self:
            print str(obj)
        self.index = -1

    def getname(self):
        return self.name

    def getpaths(self):
        '''Methods returns a list holding all file paths in objectrack.

        Return list
        '''
        list = []
        for obj in self.objectrack:
            list.append(obj.sppfile)
        return list

    def listfiles(self, path, ext=None):
        '''Method lists all files in a directory specified by a file
        extension.

        Return list
        '''
        return [file for file in os.listdir(path) if file.endswith(ext)]

    def set_params(self, params):
        self.params = params

    def printfile(self, dirname=None, exclude=None, append=False):
        '''Method to print object rack into a file. Exclude
        parameter defines a list of object parameters to be excluded.
        '''
        if not dirname:
            dirname = os.path.join(self.home, (self.name + '.spp'))
        else:
            dirname = os.path.join(dirname, (self.name + '.spp'))

        if self.objectrack:

            if append:
                outfile = open(dirname, 'a')
            else:
                outfile = open(dirname, 'w')
            # Loop through objectrack objects and pretty print parameters,
            # finally strip out trailing newline
            outfile.write(''.join(cont.pprint(exclude) for cont
                                  in self).rstrip('\r\n'))
            outfile.close()

if __name__ == '__main__':
    pth = r'C:\Users\jlehtoma\Documents\EclipseWorkspace\Framework\trunk\framework\zonation'
    zig = Zigcommander(home=pth)
    zig.create_run_object(sppfiles='spplist1.spp',
                          output=os.path.join(pth, 'output1', 'output1.txt'))
    #zig.create_batch_file(exclude=['id'])
    zig.create_run_object(sppfiles='spplist2.spp',
                          output=os.path.join(pth, 'output2', 'output.txt'))
    zig.create_batch_file(exclude=['id'])
    c = Zigconfig('settings.dat', True, home=pth)
    c.write()

    factory = Sppfactory(home=pth)

    dir = r'C:\Users\jlehtoma\Documents\EclipseWorkspace\Framework\trunk\framework\zonation'
    inputdirs = ['input1', 'input2']
    appends = [True, False]

    for input in inputdirs:
        factory.add_to_rack(dir, input)
        factory.describe()
    factory.printfile(dirname=input, exclude=['id'])
