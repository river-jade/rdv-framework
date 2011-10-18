# Wrapper script for the java RRunner to call.
# Parses a json file containing parameters and assigns
# them to global variables. Note that this is pretty hacky
# and we should instead put them into a dictionary in global scope.
# This script takes two mandatory command-line arguments:
# --paramfile, and --rscript, which are the json file containing the
# parameters, and the rscript to be executed, respectively.

library("optparse")
cmd_args <- commandArgs(TRUE);
option_list <- list(
    make_option("--paramfile"),
    make_option("--rscript")
)
args <- parse_args(OptionParser(option_list = option_list), args = c(cmd_args))

library("rjson")
print(args$paramfile)
tzar <- fromJSON(paste(readLines(args$paramfile, warn=FALSE), collapse=""))

source(args$rscript)

# for debugging: prints out the parameters
# for (i in 1:length(json_data)) {
#   cat(names(json_data[i]), '=', get(names(json_data[i])), '\n')
# }
