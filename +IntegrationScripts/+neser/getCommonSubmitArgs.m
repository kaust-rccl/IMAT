function commonSubmitArgs = getCommonSubmitArgs(cluster, numWorkers, jobName)
% Get any additional submit arguments for the Slurm sbatch command
% that are common to both independent and communicating jobs.

% Copyright 2018 KAUST
% Antonio M. Arena (antonio.arena@kaust.edu.sa)
% Iten Ismail (iten.ismail@kaust.edu.sa)
% Copyright 2016-2017 The MathWorks, Inc.

commonSubmitArgs = '';

validatedPropValue = str2func('@IntegrationScripts.common.validatedPropValue');

jn = validatedPropValue(cluster, 'JobName', 'char');
if isempty(jn)
    jn = jobName;
end
commonSubmitArgs = [' --job-name=' jn];

% Number of nodes/cores
ppn = validatedPropValue(cluster, 'ProcsPerNode', 'double');
if ~isempty(ppn) && ppn > 0
    % Don't request more cores/node than workers
    ppn = min(numWorkers, ppn);
    commonSubmitArgs = sprintf('%s --ntasks-per-node=%d -n %d --ntasks-per-socket=20 --threads-per-core=1', commonSubmitArgs, ppn, numWorkers);
else
    % Let SLURM figure out the number of nodes
    commonSubmitArgs = sprintf('%s -n %d --ntasks-per-socket=20 --threads-per-core=1 --ntasks-per-node=40', commonSubmitArgs, numWorkers);
end

%% REQUIRED
% Walltime
wt = validatedPropValue(cluster, 'WallTime', 'char');
if ~isempty(wt)
    commonSubmitArgs = [commonSubmitArgs ' -t ' wt];
else
    errorMsg = sprintf(['\n\tMust provide a wall time. E.g. 1 hour\n', ...
                        '\n\t\t>> %% E.g. set wall time to 1 hour', ...
                        '\n\t\t>> c = parcluster;', ...
                        '\n\t\t>> c.AdditionalProperties.WallTime = (''60'')', ...
                        '\n\t\t>> c.saveProfile', ...
                        '\n\t\tAcceptable time formats include:\n \t\t"minutes",', ...
                        ' "minutes:seconds", "hours:minutes:seconds", "days-hours",', ...
                        '"days-hours:minutes" and "days-hours:minutes:seconds"\n\n']);
    error(errorMsg)
end


%% OPTIONAL
% Account Name
an = validatedPropValue(cluster, 'ProjectName', 'char');
if ~isempty(an)
    commonSubmitArgs = [commonSubmitArgs ' -A ' an];
end

% Partition
qn = validatedPropValue(cluster, 'QueueName', 'char', 'workq');
commonSubmitArgs = [commonSubmitArgs ' --partition=' qn];

% Run on exclusive node
if validatedPropValue(cluster, 'RequiresExclusiveNode', 'bool', false)
    commonSubmitArgs = [commonSubmitArgs ' --exclusive'];
end


% Email notification
ea = validatedPropValue(cluster, 'EmailAddress', 'char');
if ~isempty(ea)
    commonSubmitArgs = [commonSubmitArgs ' --mail-type=ALL --mail-user=' ea];
end

% Catch-all
asa = validatedPropValue(cluster, 'AdditionalSubmitArgs', 'char');
if ~isempty(asa)
    commonSubmitArgs = [commonSubmitArgs ' ' asa];
end

commonSubmitArgs = strtrim(commonSubmitArgs);