#!/bin/bash
echo -e "Please enter your absolute working directory for MATLAB: \n"
read workdir ;
cd $workdir ;
echo " ... wait for cloning the HPC Add-on code ........."
echo  " **************************************** "
echo  "   HPC Add-on codes at: $workdir/IMAT "
echo  "   Job logs available at: $workdir/Jobs "
echo  "   To launch the MATLAB, please use: "
echo  "     module load matlab "
echo  "     matlab & "
echo " Dedicated node (1 core with 10GB of 1 hour) allocated for your MATLAB GUI based job submission ..!"
echo  " *************************************** "
git clone https://github.com/kaust-rccl/IMAT.git ;
export MATLABPATH=$workdir/IMAT ;
sed -i '250s|.*|ljsl = ['\'''$workdir/Jobs/''\'' release '\'''/''\''];|g' $MATLABPATH/+IntegrationScripts/+common/communicatingSubmitFcn.m
sed -i '50s|.*|cd '$workdir'|g' $MATLABPATH/+IntegrationScripts/+common/communicatingJobWrapper.sh
sed -i '46s|.*|rjsl = ['\'''$workdir/Jobs/''\'' release];|g' $MATLABPATH/configCluster.m
srun --time=1:00:00 --mem=10GB -c 1 --pty bash
