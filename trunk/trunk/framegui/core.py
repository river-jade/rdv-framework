'''
Created on 24.4.2010

@author: jlehtoma
'''

import yaml

class Parameters(object):

    def __init__(self, params):
        self.pnames = params.keys()
        for key, value in params.iteritems():
            setattr(self, key, value)

    def __dir__(self):
        return self.pnames

    def __str__(self):
        attributes = []
        for attribute in dir(self):
            attributes.append("%s: %s -- %s" % (attribute,
                                                str(getattr(self, attribute)[0]).ljust(10),
                                                str(getattr(self, attribute)[1])))
        return '\n'.join(attributes)

if __name__ == '__main__':
    attrs = {'foo': (1, 'int'),
             'bar': ('nice', 'String')}
    p = Parameters(attrs)
    print p