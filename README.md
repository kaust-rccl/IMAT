# KAUST HPC ADD-ON FOR MATLAB

`KAUST HPC Add-on for MATLAB` allows users to submit their job scripts to executed at Ibex cluster. 
Further, the output/results are directly written to Ibex cluster. This allows them likely to get 
a shorter execution time for their calculations and the MATLAB jobs are submitted via Slurm scheduler.


## Usage

### Steps to be done on Ibex:
1. Login to Ibex, ensure that you enable X forwarding (add the `-XY` flags to the SSH command).
```
ssh -XY $USER@ilogin.ibex.kaust.edu.sa
```

2. Setup passwordless authentication from remote workstation to IBEX. Otherwise, you will 
be prompted for your password every time you login to Ibex.
```
ssh-keygen -t rsa
ssh-copy-id -f $USER@ilogin.ibex.kaust.edu.sa
```

3. Run `setup.sh` script.  The `setup.sh` script will ask for the working directory, clone the repo, update the IMAT required files, and allocate 1 core with 10GB memory for MATLAB launch.
```
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
```

4. Load the MATLAB module
```
module load matlab/R2023b
```

5. Run the MATLAB GUI.
```
matlab &
```

### Steps to be done on the MATLAB GUI
On the matlab window, modify and execute the following examples to submit your job.

### Examples:
The examples below show how to use Matlab HPC Add-on to run serial (single CPU) jobs, multi-processor jobs on a single machine, and distributed parallel jobs running on multiple nodes.

### Example 1: Running a Simple Serial Job:
Create a Matlab script called `mywave.m` simply calculates a million points on a sine wave in a for loop.

```
%--  mywave.m --%

%  a simple 'for' loop (non-parallelized):
for i = 1:1000000
    A(i) = sin(i*2*pi/102400);
end
```
To run this job on the cluster, create a new script called `run_serial_job.m`:
```
clear all;
configCluster
ibex = parcluster('ibex');
ibex.AdditionalProperties.WallTime = ('1000');
ibex.AdditionalProperties.EmailAddress = 'ahmed.khatab@kaust.edu.sa';  % Your Email address (please modify).
ibex.AdditionalProperties.NumNodes = 1;      % Number of nodes requested 
ibex.AdditionalProperties.ProcsPerNode = 2;     % 1 more than number of Matlab workers per node.
% modify the line to point to the path of the private key file 
% to use for passwordless authentication for IBEX
ibex.AdditionalProperties.IdentityFile = '<path/to/identity/file>';
% In the following line, replace <script-name> with the name of 
% your m file without the ".m"
% <number-of-workers> is the number of cpus your job will use.
% Job = ibex.batch('<script-name>','pool',<number-of-workers>)
Job = ibex.batch('mywave','pool',1,'AutoAddClientPath',false);
% Wait for the job to finish.
wait(Job)
% load the 'A' array (computed in mywave) from the results of job 'myjob':
load(Job,'A');
%-- plot the results --%
plot(A);
```

### Example 2: Parallel Job on a Single Node:
The next example is to run a parallel job using 8 processors on a single node.  It is a parallelized version of mywave.m called `parallel_mywave.m` that uses the parfor statement to parallelize the previous for loop:

```
%--  parallel_mywave --%

% A parfor loop will use parallel workers if available.
parfor i = 1:10000000
    A(i) = sin(i*2*pi/2500000);
end
```
Now use a new Matlab script `run_parallel_job.m` (shown below) to run this job.
```
clear all;
configCluster
ibex = parcluster('ibex');
ibex.AdditionalProperties.WallTime = ('1000');
ibex.AdditionalProperties.EmailAddress = 'ahmed.khatab@kaust.edu.sa';  % Your Email address (please modify).
ibex.AdditionalProperties.NumNodes = 1;      % Number of nodes requested 
ibex.AdditionalProperties.ProcsPerNode = 9;     % 1 more than number of Matlab workers per node.
% modify the line to point to the path of the private key file 
% to use for passwordless authentication for IBEX
ibex.AdditionalProperties.IdentityFile = '<path/to/identity/file>';
% In the following line, replace <script-name> with the name of 
% your m file without the ".m"
% <number-of-workers> is the number of cpus your job will use.
% Job = ibex.batch('<script-name>','pool',<number-of-workers>)
Job = ibex.batch('parallel_mywave','pool',8,'AutoAddClientPath',false);
% Wait for the job to finish.
wait(Job)
% load the 'A' array (computed in mywave) from the results of job 'myjob':
load(Job,'A');
%-- plot the results --%
plot(A);
```

### Example 3: Distributed Parallel Job on Multiple Nodes:
The next example is to run a parallel job to calculate eigen values of random numbers using 48 processors on a multiple nodes.  It is a parallelized Matlab script called `parallel_eigen.m` that uses the parfor statement to parallelize the for loop:

```
% parallel_eigen.m

%   calculate eigen values of random numbers.
parfor i = 1:10000
    E(i) = max(eig(rand(1000)));
end
```
To run this job on the cluster, create `run_distributed_parallel_jobs.m`, which executes a function in parallel using 48 workers distributed to multiple nodes.
```
clear all;
configCluster
ibex = parcluster('ibex');
ibex.AdditionalProperties.WallTime = ('1000');
ibex.AdditionalProperties.EmailAddress = 'ahmed.khatab@kaust.edu.sa';  % Your Email address (please modify).
% modify the line to point to the path of the private key file 
% to use for passwordless authentication for IBEX
ibex.AdditionalProperties.IdentityFile = '<path/to/identity/file>';
% In the following line, replace <script-name> with the name of 
% your m file without the ".m"
% <number-of-workers> is the number of cpus your job will use.
% Job = ibex.batch('<script-name>','pool',<number-of-workers>)
Job = ibex.batch('parallel_eigen','pool',200,'AutoAddClientPath',false);
% Wait for the job to finish.  
wait(Job)
% load the 'E' array from the job results. (The values for 'E' are calculated in parallel_eigen.m):
load(Job,'E');
%-- plot the results --%
plot(E);
```

