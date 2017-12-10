#!/bin/bash -l

# Copyright 2016 KAUST
# Antonio M. Arena (antonio.arena@kaust.edu.sa)

fabrics="tcp"

# Let's read in the inputs
while [ $# -gt 0 ]; do
    case "$1" in
        --fabrics)
            shift
            fabrics="$1"
            shift
        ;;

        --help|-h)
cat << EOF
usage: $0
    --fabrics         <fabrics spec>, Select a particular network fabric to be used for communication
                      Allowed values are: {shm, dapl, tcp, tmi, ofa, ofi}
EOF
            exit 0
        ;;

        -*)
            echo "$0: error - unrecognized option $1" 1>&2;
            exit 1
        ;;

        *)  break
        ;;
    esac
done

# Load the latest INTEL compiler suite
module load intel/2017

# Select a particular network fabric to be used for communication
export I_MPI_FABRICS="shm:$fabrics"

# Set the I_MPI_PMI_LIBRARY environment variable to point to
# the Slurm Process Management Interface (PMI) library
export I_MPI_PMI_LIBRARY="/usr/lib64/libpmi.so"

# Shutdown PSM signal handlers that otherwise interfere with MATLAB's JVM
export IPATH_NO_BACKTRACE=1
