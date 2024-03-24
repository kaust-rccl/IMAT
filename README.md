# KAUST HPC ADD-ON FOR MATLAB

`KAUST HPC Add-on for MATLAB` allows users to submit their scripts and output files for execution
on the KAUST cluster IBEX from remote workstation, and also to retrieve the 
output results from this cluster. This allows them to free up their local computer,
and likely to get a shorter turnaround time for their calculations.

This version only is only tested with MATLAB versions starting R2019a.

## Usage

### How to access the remote workstation
1. Use your KAUST credentials to access the remote workstation via the following link
https://myws.kaust.edu.sa/engineframe/vdi/vdi.xml?_uri=//com.engineframe.interactive/list.sessions
2. Initiate an `Ubuntu22.04-select host` session.

### Steps to be done on the workstation
1. Open a new terminal and add the following 2 lines to your ~/.bashrc and source it.
```
source /etc/profile.d/modules.sh
export MATLABPATH=/sw/workstations/modules/linux-ubuntu22.04-ivybridge

source ~/.bashrc
```

2. Setup passwordless authentication from remote workstation to IBEX. Otherwise, you will 
be prompted for your password every time you submit a job.
```
ssh-keygen -t rsa
ssh-copy-id <username>@ilogin.ibex.kaust.edu.sa
```

3. Create the mount point directory on remote workstation.
4. Mount the created directory on remote workstation to scratch on Ibex.
```
mkdir ~/scratch
sshfs <username>@ilogin.ibex.kaust.edu.sa:/ibex/scratch/<username> ~/scratch -o direct_io
```
### Note: The directory `/ibex/scratch/<username>` will be mounted temporarily to `~/scratch` on remote workstation. You have to run mount command every new session and If you faced an issue in mounting, please select another session host.

5. Load the MATLAB module
  `module load matlab/R2023b`
6. export the correct timezone `export TZ="Asia/Riyadh"`
7. Clone `IMAT` and export MATLABPATH
8. Run the MATLAB GUI `matlab &`
```
cd
module load matlab/R2023b
git clone https://github.com/kaust-rccl/IMAT.git
export MATLABPATH=$HOME/IMAT
matlab &
```

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
