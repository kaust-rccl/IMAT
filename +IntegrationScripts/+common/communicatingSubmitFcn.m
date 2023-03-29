function communicatingSubmitFcn(cluster, job, environmentProperties)
%COMMUNICATINGSUBMITFCN Submit a communicating MATLAB job to a Slurm cluster
%
% Set your cluster's IntegrationScriptsLocation to the parent folder of this
% function to run it when you submit a communicating job.
%
% See also parallel.cluster.generic.communicatingDecodeFcn.
%

% Copyright 2010-2016 The MathWorks, Inc.

if strcmp(job.Tag,'Created_by_matlabpool') || strcmp(job.Tag,'Created_by_parpool')
    displayPoolError(cluster,job)
end

% Store the current filename for the errors, warnings and dctSchedulerMessages
currFilename = mfilename;
if ~isa(cluster, 'parallel.Cluster')
    error('parallelexamples:GenericSLURM:SubmitFcnError', ...
          'The function %s is for use with clusters created using the parcluster command.', currFilename)
end

decodeFunction = 'parallel.cluster.generic.communicatingDecodeFcn';

if cluster.HasSharedFilesystem
    error('parallelexamples:GenericSLURM:SubmitFcnError', ...
          'The submit function %s is for use with nonshared filesystems.', currFilename)
end

if ~isprop(cluster.AdditionalProperties, 'ClusterHost')
    error('parallelexamples:GenericSLURM:MissingAdditionalProperties', ...
          'Required field %s is missing from AdditionalProperties.', 'ClusterHost');
end
clusterHost = cluster.AdditionalProperties.ClusterHost;

if ~isprop(cluster.AdditionalProperties, 'RemoteJobStorageLocation')
    error('parallelexamples:GenericSLURM:MissingAdditionalProperties', ...
          'Required field %s is missing from AdditionalProperties.', 'RemoteJobStorageLocation');
end
remoteJobStorageLocation = cluster.AdditionalProperties.RemoteJobStorageLocation;

if isprop(cluster.AdditionalProperties, 'UseUniqueSubfolders')
    makeLocationUnique = cluster.AdditionalProperties.UseUniqueSubfolders;
else
    makeLocationUnique = false;
end

if ~strcmpi(cluster.OperatingSystem, 'unix')
    error('parallelexamples:GenericSLURM:SubmitFcnError', ...
          'The submit function %s only supports clusters with unix OS.', currFilename)
end

if ~ischar(clusterHost)
    error('parallelexamples:GenericSLURM:IncorrectArguments', ...
          'ClusterHost must be a character vector');
end

if ~ischar(remoteJobStorageLocation)
    error('parallelexamples:GenericSLURM:IncorrectArguments', ...
          'RemoteJobStorageLocation must be a character vector');
end

if ~islogical(makeLocationUnique)
    error('parallelexamples:GenericSLURM:IncorrectArguments', ...
          'UseUniqueSubfolders must be a logical scalar');
end

remoteConnection = getRemoteConnection(cluster, clusterHost, remoteJobStorageLocation, makeLocationUnique);

% The job specific environment variables
% Remove leading and trailing whitespace from the MATLAB arguments
matlabArguments = strtrim(environmentProperties.MatlabArguments);

debugOn = validatedPropValue(cluster, 'DebugMessagesTurnedOn', 'bool');
if debugOn
    mdceDebug = 'true';
else
    mdceDebug = 'false';
end

straceOn = validatedPropValue(cluster, 'StraceOn', 'bool');
if straceOn
    mdceStrace = 'true';
else
    mdceStrace = 'false';
end

mpiExt = validatedPropValue(cluster, 'DataParallelism', 'char');

ClusterName = validatedPropValue(cluster, 'ClusterName', 'char');

variables = {'PARALLEL_SERVER_DECODE_FUNCTION', decodeFunction; ...
    'PARALLEL_SERVER_STORAGE_CONSTRUCTOR', environmentProperties.StorageConstructor; ...
    'PARALLEL_SERVER_JOB_LOCATION', environmentProperties.JobLocation; ...
    'PARALLEL_SERVER_MATLAB_EXE', environmentProperties.MatlabExecutable; ...
    'PARALLEL_SERVER_MATLAB_ARGS', matlabArguments; ...
    'PARALLEL_SERVER_DEBUG', mdceDebug; ...
    'MLM_WEB_LICENSE', environmentProperties.UseMathworksHostedLicensing; ...
    'MLM_WEB_USER_CRED', environmentProperties.UserToken; ...
    'MLM_WEB_ID', environmentProperties.LicenseWebID; ...
    'PARALLEL_SERVER_LICENSE_NUMBER', environmentProperties.LicenseNumber; ...
    'PARALLEL_SERVER_STORAGE_LOCATION', remoteConnection.JobStorageLocation; ...
    'PARALLEL_SERVER_CMR', strip(cluster.ClusterMatlabRoot, 'right', '/'); ...
    'PARALLEL_SERVER_TOTAL_TASKS', num2str(environmentProperties.NumberOfTasks); ...
    'PARALLEL_SERVER_NUM_THREADS', num2str(cluster.NumThreads)};
% Environment variable names different prior to 19b
if verLessThan('matlab', '9.7')
    variables(:,1) = replace(variables(:,1), 'PARALLEL_SERVER_', 'MDCE_');
end

% Trim the environment variables of empty values.
nonEmptyValues = cellfun(@(x) ~isempty(strtrim(x)), variables(:,2));
variables = variables(nonEmptyValues, :);

% Get the correct quote and file separator for the Cluster OS.
% This check is unnecessary in this file because we explicitly
% checked that the ClusterOsType is unix.  This code is an example
% of how your integration code should deal with clusters that
% can be unix or pc.
if strcmpi(cluster.OperatingSystem, 'unix')
    quote = '''';
    fileSeparator = '/';
else
    quote = '"';
    fileSeparator = '\';
end

% The local job directory
localJobDirectory = cluster.getJobFolder(job);
% How we refer to the job directory on the cluster
remoteJobDirectory = remoteConnection.getRemoteJobLocation(job.ID, cluster.OperatingSystem);

% This is for ssh & srun (not hydra).
% The python script name is tasks_per_node.py
dirpart = fileparts(mfilename('fullpath'));
scriptName = 'tasks_per_node.py';
localScript = fullfile(dirpart, scriptName);
% Copy python script to the job directory
copyfile(localScript, localJobDirectory);

scriptLocation = '+common';

configClusterLocation = fileparts(which('configCluster.m'));
% dirpart = fullfile(configClusterLocation, '+IntegrationScripts', scriptLocation);
% scriptName = ['communicatingJobWrapper.sh-' mpiExt];

% % The wrapper script location depends on cluster we're using
% localScript = fullfile(dirpart, scriptName);

% % Copy the local wrapper script to the job directory
% copyfile(localScript, localJobDirectory);

if verLessThan('matlab', '9.6') || ...
    validatedPropValue(cluster, 'UseSmpd', 'bool', false)
jobWrapperName = 'communicatingJobWrapperSmpd.sh';
else
jobWrapperName = 'communicatingJobWrapper.sh';
end
% The wrapper script is in the same directory as this file
dirpart = fileparts(mfilename('fullpath'));
localScript = fullfile(dirpart, jobWrapperName);
% Copy the local wrapper script to the job directory
copyfile(localScript, localJobDirectory);

% The script to execute on the cluster to run the job
wrapperPath = sprintf('%s%s%s', remoteJobDirectory, fileSeparator, jobWrapperName);
quotedWrapperPath = sprintf('%s%s%s', quote, wrapperPath, quote);

% Choose a file for the output
logFile = sprintf('%s%s%s', remoteJobDirectory, fileSeparator, sprintf('Job%d.log', job.ID));
quotedLogFile = sprintf('%s%s%s', quote, logFile, quote);
dctSchedulerMessage(5, '%s: Using %s as log file', currFilename, quotedLogFile);

jobName = sprintf('Job%d', job.ID);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CUSTOMIZATION MAY BE REQUIRED %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% You might want to customize this section to match your cluster,
% for example to limit the number of nodes for a single job.
additionalSubmitArgs = sprintf('--comment="MATLAB HPC Add-on running %d cores"', environmentProperties.NumberOfTasks);
getCommonSubmitArgs = str2func(['@IntegrationScripts.' ClusterName '.getCommonSubmitArgs']);
commonSubmitArgs = getCommonSubmitArgs(cluster, environmentProperties.NumberOfTasks, jobName);
if ~isempty(commonSubmitArgs) && ischar(commonSubmitArgs)
    additionalSubmitArgs = strtrim([additionalSubmitArgs, ' ', commonSubmitArgs]) %#ok<NOPRT>
end
% Create a script to submit a Slurm job - this will be created in the job directory
dctSchedulerMessage(5, '%s: Generating script for job.', currFilename);
localScriptName = tempname(localJobDirectory);
[~, scriptName] = fileparts(localScriptName);
remoteScriptLocation = sprintf('%s%s%s', remoteJobDirectory, fileSeparator, scriptName);
createSubmitScript(localScriptName, jobName, quotedLogFile, quotedWrapperPath, variables, additionalSubmitArgs);
% Create the command to run on the remote host.
commandToRun = sprintf('/bin/bash %s', remoteScriptLocation);
dctSchedulerMessage(4, '%s: Starting mirror for job %d.', currFilename, job.ID);
% Start the mirror to copy all the job files over to the cluster
remoteConnection.startMirrorForJob(job);

% Now ask the cluster to run the submission command
dctSchedulerMessage(4, '%s: Submitting job using command:\n\t%s', currFilename, commandToRun);
% Execute the command on the remote host.
[cmdFailed, cmdOut] = remoteConnection.runCommand(commandToRun);
if cmdFailed
    % Stop the mirroring if we failed to submit the job - this will also
    % remove the job files from the remote location
    % Only stop mirroring if we are actually mirroring
    if remoteConnection.isJobUsingConnection(job.ID)
        dctSchedulerMessage(5, '%s: Stopping the mirror for job %d.', currFilename, job.ID);
        try
            remoteConnection.stopMirrorForJob(job);
        catch err
            warning('parallelexamples:GenericSLURM:FailedToStopMirrorForJob', ...
                    'Failed to stop the file mirroring for job %d.\nReason: %s', ...
                    job.ID, err.getReport);
        end
    end
    error('parallelexamples:GenericSLURM:FailedToSubmitJob', ...
          'Failed to submit job to Slurm using command:\n\t%s.\nReason: %s', ...
          commandToRun, cmdOut);
end

jobIDs = extractJobId(cmdOut);
% jobIDs must be a cell array
if isempty(jobIDs)
    warning('parallelexamples:GenericSLURM:FailedToParseSubmissionOutput', ...
            'Failed to parse the job identifier from the submission output: "%s"', ...
            cmdOut);
end
if ~iscell(jobIDs)
    jobIDs = {jobIDs};
end

% set the cluster host, remote job storage location and job ID on the job cluster data
jobData = struct('ClusterJobIDs', {jobIDs}, ...
                 'RemoteHost', clusterHost, ...
                 'RemoteJobStorageLocation', remoteConnection.JobStorageLocation, ...
                 'HasDoneLastMirror', false);
cluster.setJobClusterData(job, jobData);
