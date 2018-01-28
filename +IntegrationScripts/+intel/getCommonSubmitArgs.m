function commonSubmitArgs = getCommonSubmitArgs(cluster, numWorkers, jobName)
% Get any additional submit arguments for the Slurm sbatch command
% that are common to both independent and communicating jobs.

% Copyright 2016-2017 The MathWorks, Inc.

% wiki:

commonSubmitArgs = '';

validatedPropValue = str2func('@IntegrationScripts.common.validatedPropValue');

jn = validatedPropValue(cluster, 'JobName', 'string');
if isempty(jn)
    jn = jobName;
end
commonSubmitArgs = [' --job-name=' jn];

% Number of nodes/cores
ppn = validatedPropValue(cluster, 'ProcsPerNode', 'double');
if ~isempty(ppn) && ppn > 0
    % Don't request more cores/node than workers
    ppn = min(numWorkers, ppn);
    commonSubmitArgs = sprintf('%s --ntasks-per-node=%d -n %d', commonSubmitArgs, ppn, numWorkers);
else
    % Let SLURM figure out the number of nodes
    commonSubmitArgs = sprintf('%s -n %d', commonSubmitArgs, numWorkers);
end

commonSubmitArgs = sprintf('%s -C intel', commonSubmitArgs);

%% REQUIRED

% Walltime
wt = validatedPropValue(cluster, 'WallTime', 'char');
if ~isempty(wt)
    commonSubmitArgs = [commonSubmitArgs ' -t ' wt];
else
    emsg = sprintf('\n\tMust provide a wall time. E.g. 1 hour\n\n\t>> ClusterInfo.setWallTime(''0-1'')\n\tAcceptable time formats include "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds"');
    error(emsg) %#ok<SPERR>
end

% % Partition / Check for GPU
% numGpus = validatedPropValue(cluster, 'GpusPerNode', 'double');
% if numGpus > 0
%    qn = 'gpu';
% else
%    qn = validatedPropValue(cluster, 'QueueName', 'char');
% end
% % Use the specified partition
% if ~isempty(qn)
%    commonSubmitArgs = [commonSubmitArgs ' -p ' qn];
% % Otherwise, if no partition is specified, throw an error
% else
%    emsg = sprintf(['\n\t\t>> %% Must set QueueName to use. E.g.:\n\n', ...
%                   '\t\t>> c = parcluster;\n', ...
% 	            '\t\t>> c.AdditionalProperties.QueueName = ''queue_name'';\n', ...
% 		    '\t\t>> c.saveProfile\n\n']);
%    error(emsg) %#ok<SPERR>
% end


%% OPTIONAL

% Account Name
an = validatedPropValue(cluster, 'Account', 'char');
if ~isempty(an)
    commonSubmitArgs = [commonSubmitArgs ' -A ' an];
end

% Partition / Check for GPU
UseGpu = validatedPropValue(cluster, 'UseGpu', 'bool');
if UseGpu == true
    ngpus = validatedPropValue(cluster, 'GpusPerNode', 'double');
    if isempty(ngpus)
        ngpus = 2;
    end
    % In case someone specifies it as a string.
    ngpus = str2num(ngpus); %#ok<ST2NM>
    qn = [commonSubmitArgs 'defaultq --gres=gpu:' num2str(ngpus)];
else
    qn = validatedPropValue(cluster, 'QueueName', 'char');
end

qn = validatedPropValue(cluster, 'JobName', 'char');
if isempty(qn)
    qn = 'batch';
end
commonSubmitArgs = [commonSubmitArgs ' --partition=' qn];

%% Physical Memory used by an entire node
% mu = validatedPropValue(cluster, 'MemUsage', 'char');
%if isempty(mu)==false
%    % -C SMALLMEM, BIGMEM, HUGEMEM
%    asa = [asa ' --mem-per-cpu=' mu];
%    asa = [asa ' -C ' mu];
%end

% Run on exclusive node
ex = validatedPropValue(cluster, 'RequireExclusiveNode', 'bool');
if ex == true
    commonSubmitArgs = [commonSubmitArgs ' --exclusive'];
end


% Email notification
% ea = validatedPropValue(cluster, 'EmailAddress', 'char');
% if ~isempty(ea)
%     commonSubmitArgs = [commonSubmitArgs ' --mail-type=ALL --mail-user=' ea];
% end

% Every job is going to require a certain number of MDCS licenses.
% Specification of MDCS licenses which must be allocated to this
% job. The /etc/slurm/slurm.conf file must list
%
%   # MDCS licenses
%   Licenses=mdcs:600
%
% And then call
%
%   % scontrol reconfigure
%
% asa = sprintf('%s --licenses=mdcs:%d', asa, ntasks);

% Catch-all
asa = validatedPropValue(cluster, 'AdditionalSubmitArgs', 'char');
if ~isempty(asa)
    commonSubmitArgs = [commonSubmitArgs ' ' asa];
end

commonSubmitArgs = strtrim(commonSubmitArgs);
