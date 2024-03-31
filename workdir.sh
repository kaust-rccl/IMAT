#!/bin/bash

echo -e "Please enter your working directory: \n"

read workdir

sed -i '250s|.*|ljsl = ['\'''$workdir/Jobs/''\'' release '\'''/''\''];|g' $MATLABPATH/+IntegrationScripts/+common/communicatingSubmitFcn.m
sed -i '50s|.*|cd '$workdir'|g' $MATLABPATH/+IntegrationScripts/+common/communicatingJobWrapper.sh
sed -i '46s|.*|rjsl = ['\'''$workdir/Jobs/''\'' release];|g' $MATLABPATH/configCluster.m

