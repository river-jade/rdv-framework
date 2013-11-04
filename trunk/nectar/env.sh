#!/bin/sh

# Environment variables set in the file will be passed to tzar.

# Environment variables that tzar recognises:
# TZAR_DB: database connection string (required)
# REPOSITORY_PREFIXES: allowed repository prefixes (required)
# CLUSTER_NAME: name of cluster - only execute runs scheduled for this cluster
# SCP_OUTPUT_HOST: host to copy output data to
# SCP_OUTPUT_PATH: path on remote host to copy output data to (required if SCP_OUTPUT_HOST is set)
# PEMFILE: private key for ssh authentication on SCP_OUTPUT_HOST (required if SCP_OUTPUT_HOST is set)
# TZAR_VERSION: version of tzar to run. format x.x.x, eg 0.4.1

# EXTRA_TZAR_FLAGS: extra flags to pass to tzar
