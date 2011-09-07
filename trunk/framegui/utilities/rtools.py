'''
Created on 16.4.2010

@author: jlehtoma
'''
import os
import rpy2.robjects as robjects

def fix_path(path):
    return path.replace('\\', '/')

def get_rfunction(function):
    try:
        return robjects.r[function]
    except LookupError, e:
        print 'Function not found in R global environment'
        print e

def get_rvariable(variable):
    try:
        return robjects.r[variable]
    except LookupError, e:
        print 'Variable not found in R global environment'
        print e

def run_rfunction(function, *args, **kwargs):
    rfunction = get_rfunction(function)
    rfunction(*args, **kwargs)

if __name__ == '__main__':
    r_home = r'C:\Users\jlehtoma\Documents\EclipseWorkspace\Framework\trunk\framework\R'
    r_file = r'hg.simulation.R'
    run_rfunction('source', fix_path(os.path.join(r_home, r_file)))
    input = 'correct_input/3'
    output = 'correct_output/3'
    type = 'GaussRF'
    landscapes = 3
    run_rfunction('run.simulation', input, output, type=type,
                  landscapes=landscapes)