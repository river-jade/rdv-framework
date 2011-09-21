import csv
import fnmatch
import optparse
import os
import subprocess
import sys

def parse_flags(parser, flags):
    """Configures the command-line flag parser.
    """
    parser.add_option("--runset", action="store", dest="runset", 
                      help="Runset to aggregate")
    parser.add_option("--outputpath", action="store", dest="outputpath", 
                      help="Runset to aggregate")
    parser.add_option("--ssh-username", action="store", dest="sshusername", 
                      default="rdv", help="Username for ssh connections")
    parser.add_option("--jar-path", action="store", dest="jarpath", 
                      default="rdv.jar", help="Path to jar file")

    options, args = parser.parse_args(flags)
    return options

def getinterestingids(path):
    """Examing each of the output.csv files in the output directory
    to see which ones match the criteria (currently 
    that norm.Norm.CPW.area > 0.01). Returns the list of ids for runs which
    match the criteria.
    """
    files = os.listdir(path)
    ids = []
    for f in files:
        if fnmatch.fnmatch(f, "*_output.csv"):
            reader = csv.reader(open(os.path.join(path, f), 'rb'))
            # field index for CPW.area column
            index = reader.next().index("norm.Norm.CPW.area")
            lastrow = [row for row in reader][-1]
            if lastrow[index] > 0.01:
                runid = f.split('_')[0]
                ids.append(runid)
    return ids

def retrieveparameters(ids, outputpath, jarpath):
    """Call the java program to retrieve the parameters for each run passed
    in the ids list"""
    for id in ids:
        csvoutput = open(os.path.join(outputpath, "%s_parameters.csv" % id), 'w')
        cmdarray = ["java", "-jar", jarpath, "printrun", 
                    "--runid=%s" % id, "--csv"]
        print "Executing: ", ' '.join(cmdarray)
        subprocess.call(cmdarray, stdout=csvoutput)

def combineparameters(ids, outputpath):
    """For each of the ids in the ids list, merge the parameters csv, adding
    a new column to contain the run id"""

    # The code below is probaly unnecessarily complex as it handles the case where the
    # parameters files have different fields and/or fields in different orders. This
    # is not possible given the current code structure (although may be in the future).
    # Probably should be simplified based on YAGNI.
    fieldnames = set()
    values = []
    for id in ids:
        reader = csv.reader(open(os.path.join(outputpath, "%s_parameters.csv" % id), 'rb'))
        headers = reader.next()
        fieldnames |= set(headers) # adds any new fieldnames to fieldnames set
        fieldnamemap = dict([(index, value) for index, value in enumerate(headers)])
        # rowtomap converts a row of values into a dictionary where the keys are the field
        # names (from the header of the csv file), and the values are the corresponding
        # values from the row.
        rowtomap = lambda row: dict([(fieldnamemap[index], value) for index, value in enumerate(row)])
        valuesmap = [rowtomap(row) for row in reader]
        values.append((id, valuesmap))
    # values now contains a list of lists of dictionaries, each of which maps from field names to values
    fields = list(fieldnames)
    paramfile = os.path.join(outputpath, "parameters.csv")
    f = open(paramfile, 'wb')
    writer = csv.writer(f)
    writer.writerow(["run_id"] + fields)
    for id, valuesmap in values:
        for row in valuesmap:
            writer.writerow([id] + [row[field] for field in fields])
    print "Wrote combined parameters to %s" % paramfile

parser = optparse.OptionParser()
options = parse_flags(parser, sys.argv)

if not options.runset: 
    parser.error("Must specify a runset name. Pass --help for usage info.")
if not options.outputpath: 
    parser.error("Must specify an output path. Pass --help for usage info.")

cmdarray = ["java", "-Duser.name=%s" % options.sshusername, "-jar", 
            options.jarpath, "aggregate", "--runset=%s" % options.runset, 
            "--outputpath=%s" % options.outputpath]
print "Executing: ", ' '.join(cmdarray)
cmd = subprocess.call(cmdarray)
ids = getinterestingids(options.outputpath)
retrieveparameters(ids, options.outputpath, options.jarpath)
combineparameters(ids, options.outputpath)
