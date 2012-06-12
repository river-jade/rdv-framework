import csv
import fnmatch
import optparse
import os
import subprocess
import sys


timestep_to_save = 50

def parse_flags(parser, flags):
    """Configures the command-line flag parser.
    """
    parser.add_option("--jar-path", action="store", dest="jarpath", 
                      default="rdv.jar", help="Path to jar file")
    parser.add_option("--nocopy", action="store_false", dest="copy", 
                      help="If set, don't copy files (to save time if they've "
                      "already been copied)", default=True)
    parser.add_option("--outputpath", action="store", dest="outputpath", 
                      help="Runset to aggregate")
    parser.add_option("--runset", action="store", dest="runset", 
                      help="Runset to aggregate")
    parser.add_option("--ssh-username", action="store", dest="sshusername", 
                      default="rdv", help="Username for ssh connections")
    parser.add_option("--nowritefinalvalues", action="store_false", dest="writefinalvalues", 
                      default="True", help="Don't write final values from the relevant runs out to a file.")
    parser.add_option("--noretrieveparams", action="store_false", dest="retrieveparams", 
                      default="True", help="Don't retrieve the parameters from the database.")
	

    options, args = parser.parse_args(flags)
    return options

def getinterestingids(path, filterfunction=None):
    """Function to determine which ids we're interested in.
    """
    if not filterfunction:
        filterfunction = lambda x: x # if no filter function provided, just return all ids
    return filterfunction([f.split('_')[0] for f in getoutputfiles(path)])

def writefinalvalues(ids, path, timestep, errors=None):
    """Writes the final values for each run out as a CSV file.
    """
    if errors == None: errors = []
    fieldnames = set()
    values = []
    for id in ids:
        try:
          reader = csv.reader(open(os.path.join(path, "%s_output.csv" % id), 'rb'))
          # field index for CPW.area column
          headers = reader.next()
          fieldnames |= set(headers)

          # Check that timestep is not greater than the number of entires in the file
          rows = [row for row in reader]
          if timestep > len(rows):
            print "ERROR: Timestep was larger than number of rows. Exiting"
            sys.exit(1)
          
          # this is where the last value is selected
          #row_to_save = [row for row in reader][-1]
          row_to_save = rows[timestep]
          valuesmap = dict(zip(headers, row_to_save))
          values.append((id, valuesmap))

        except Exception as e:
          error = "Error in file with id: %s" % id
          print error
          errors.append((error, e))
            
    fields = list(fieldnames)
    f = open(os.path.join(path, "finalvalues.csv"), 'wb')
    writer = csv.writer(f)
    writer.writerow(["run_id"] + fields)
    for id, valuesmap in values:
        writer.writerow([id] + [valuesmap[field] for field in fields])
    print "Wrote final values %s" % f.name

def getoutputfiles(path):
    return filter(lambda f: fnmatch.fnmatch(f, "*_output.csv"), os.listdir(path))

def retrieveparameters(ids, outputpath, jarpath):
    """Call the java program to retrieve the parameters for each run passed
    in the ids list"""
    for id in ids:
        csvoutput = open(os.path.join(outputpath, "%s_parameters.csv" % id), 'w')
        cmdarray = ["java", "-jar", jarpath, "printrun", 
                    "--runid=%s" % id, "--csv"]
    # Note the default way the database to use is specified is via the
    # environment variable TZAR_DB. For example to use the ARCS
    # database it would need to be set to
    # jdbc:postgresql://arcs-01.ivec.org:5432/rdv?user=rdv&password=<password>
    # To set this within a shell use the command
    # export TZAR_DB="jdbc:postgresql://arcs-01.ivec.org:5432/rdv?user=rdv&password=<password>"
    
    # or can put the above command within .bashrc file otherwise to
    # hardcode the db into this script can add the commond line flag
    # to the call as replacing the line of code above with
    # "--runid=%s" % id, "--csv", "--dburl", "jdbc:postgresql://arcs-01.ivec.org:5432/rdv?user=rdv&password=<password>"]
        
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
    
    f = open(os.path.join(outputpath, "parameters.csv"), 'wb')
    writer = csv.writer(f)
    writer.writerow(["run_id"] + fields)
    for id, valuesmap in values:
        for row in valuesmap:
            writer.writerow([id] + [row[field] for field in fields])
    print "Wrote combined parameters to %s" % f.name

def copyfiles(sshusername, jarpath, runset, outputpath):
    """Aggregate the results into a single directory, using the tzar aggregate 
    command."""
    cmdarray = ["java", "-Duser.name=%s" % sshusername, "-jar", 
                jarpath, "aggregate", "--runset=%s" % runset, 
                "--outputpath=%s" % outputpath]
    # Note the default way the database to use is specified is via the
    # environment variable TZAR_DB. For example to use the ARCS
    # database it would need to be set to
    # jdbc:postgresql://arcs-01.ivec.org:5432/rdv?user=rdv&password=<password>
    # To set this within a shell use the command
    # export TZAR_DB="jdbc:postgresql://arcs-01.ivec.org:5432/rdv?user=rdv&password=<password>"
    
    # or can put the above command within .bashrc file otherwise to
    # hardcode the db into this script can add the commond line flag
    # to the call as replacing the line of code above with
    # "--outputpath=%s" % outputpath, "--dburl", "jdbc:postgresql://arcs-01.ivec.org:5432/rdv?user=rdv&password=<password>"
    
    print "Executing: ", ' '.join(cmdarray)
    cmd = subprocess.call(cmdarray)

def main(argv=None):
    argv = argv or sys.argv
    parser = optparse.OptionParser()
    options = parse_flags(parser, argv)

    options.runset or parser.error("Must specify a runset name. Pass --help for usage info.")
    options.outputpath or parser.error("Must specify an output path. Pass --help for usage info.")

    if options.copy:
        copyfiles(options.sshusername, options.jarpath, options.runset, 
                options.outputpath)

    outputpath = options.outputpath
    ids = getinterestingids(outputpath)

    if options.retrieveparams:
      retrieveparameters(ids, outputpath, options.jarpath)
      combineparameters(ids, outputpath)
    if options.writefinalvalues:
      errors = []
      writefinalvalues(ids, outputpath, timestep_to_save, errors)
      if errors:
          print "At least one error occurred:"
          print errors 

if __name__ == "__main__":
    sys.exit(main())
