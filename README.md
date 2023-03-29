# KAUST HPC ADD-ON FOR MATLAB

`KAUST HPC Add-on for MATLAB` allows users to submit their scripts and output files for execution
on the KAUST cluster IBEX from their local computer, and also to retrieve the 
output results from this cluster. This allows them to free up their local computer,
and likely to get a shorter turnaround time for their calculations.

This version only is only tested with MATLAB versions starting R2019a.

## Usage

### Steps to be done on the workstation
1. Setup passwordless authentication from local machines to IBEX. Otherwise, you will 
be prompted for your password every time you submit a job.
2. Load the MATLAB module
  `module load matlab/R2021a`
3. export the correct timezone `export TZ="Asia/Riyadh"`
4. Clone `ibex-mat` and export MATLABPATH
```
cd
git clone https://github.com/kaust-rccl/ibex-mat.git
export MATLABPATH=$HOME/ibex-mat
```
5. Run the MATLAB GUI `matlab &`

### Steps to be done on the MATLAB GUI
On the matlab window, modify and execute the following commands to submit your job.
```
clear all;
configCluster
ibex = parcluster('ibex');
ibex.AdditionalProperties.WallTime = ('1000');
% modify the line to point to the path of the private key file 
% to use for passwordless authentication for IBEX
ibex.AdditionalProperties.IdentityFile = '<path/to/identity/file>';
% In the following line, replace <script-name> with the name of 
% your m file without the ".m"
% <number-of-workers> is the number of cpus your job will use.
Job = ibex.batch('<script-name>','pool',<number-of-workers>); 
```
