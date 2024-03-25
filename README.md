# KAUST HPC ADD-ON FOR MATLAB

`KAUST HPC Add-on for MATLAB` allows users to submit their scripts and output files for execution
on the KAUST cluster IBEX from remote workstation, and also to retrieve the 
output results from this cluster. This allows them to free up their local computer,
and likely to get a shorter turnaround time for their calculations.


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
4. Mount the created directory on remote workstation to `scratch` on Ibex.
```
mkdir ~/scratch
sshfs <username>@ilogin.ibex.kaust.edu.sa:/ibex/scratch/<username> ~/scratch -o direct_io
```
> ### Important note: The directory `/ibex/scratch/<username>` will be mounted temporarily to `~/scratch` on remote workstation. 
> ### so, once you've finished your workload, please don't close the session but just logout..

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
% modify the line to point to the path of the private key file 
% to use for passwordless authentication for IBEX
ibex.AdditionalProperties.IdentityFile = '/home/khatabah/.ssh/id_rsa';
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
ibex.AdditionalProperties.IdentityFile = '/home/khatabah/.ssh/id_rsa';
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
ibex.AdditionalProperties.IdentityFile = '/home/khatabah/.ssh/id_rsa';
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

