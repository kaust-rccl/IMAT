#!/bin/bash -l

module load "matlab/${1}"
matlab -nodisplay -nosplash -nodesktop -softwareopengl -r "run_all_tests"
