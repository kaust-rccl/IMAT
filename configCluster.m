function configCluster
% Configure MATLAB to submit to the cluster.

% Copyright 2016-2018 KAUST
% Antonio M. Arena (antonio.arena@kaust.edu.sa)
% Copyright 2013-2017 The MathWorks, Inc.

% The version of MATLAB being supported
release = ['R' version('-release')];

% Import cluster definitions
def.NumWorkers = 600;

% Cluster list
cluster_dir = fullfile(fileparts(mfilename('fullpath')), '+IntegrationScripts');

% Listing of setting file(s).  Derive the specific one to use.
cluster_list = dir(cluster_dir);

% Ignore . and .. directories
cluster_list = cluster_list(arrayfun(@(x) x.name(1), cluster_list) ~= '.');
len = length(cluster_list);
if len == 0
    error('Failed to find profiles. Contact your System Administrator.')
elseif len == 1
    cluster = cluster_list.name;
else
    cluster = lExtractPfile(cluster_list);
end

% Determine the name of the cluster profile
cluster = erase(cluster, '+');
profile = lProfileName(cluster, release);

% Delete the old profile (if it exists)
profiles = parallel.clusterProfiles();
idx = strcmp(profiles, profile);
ps = parallel.Settings;
ws = warning;
warning off
ps.Profiles(idx).delete
warning(ws)

def.ClusterMatlabRoot = lGetMatlabRoot(cluster, release);
def.ClusterHost = lGetLoginNode(cluster);

% Create the user's local Job Storage Location folder
rootd = lGetLocalRoot();
strtindex = regexp(rootd, 'MATLAB', 'once');
if isempty(strtindex)
    jfolder = fullfile(rootd, 'Documents', 'MATLAB', 'Jobs', cluster, release);
else
    jfolder = fullfile(rootd, 'Jobs', cluster, release);
end
if ~exist(jfolder, 'dir')
    [status, err, eid] = mkdir(jfolder);
    if ~status
        error(eid, err)
    end
end

% Configure the user's remote storage location and assemble the cluster profile
user = lower(char(java.lang.System.getProperty('user.name')));
rjsl = lGetScratch(cluster, user, release);
assembleClusterProfile(jfolder, rjsl, cluster, user, profile, def);

% Uncomment this if you want to display a banner for users.
lNotifyUserOfCluster(upper(cluster))

end


function cluster_name = lExtractPfile(cl)
% Display profile listing to user to select from
len = length(cl);
for pidx = 1:len
    name = cl(pidx).name;
    names{pidx, 1} = name; %#ok<AGROW>
end

% Delete common from the list of clusters
names = erase(names, '+common');
names = names(~cellfun('isempty', names));
len = length(names);

selected = false;
while ~selected
    for pidx = 1:len
        name = erase(names{pidx}, '+');
        fprintf('\t[%d] %s\n', pidx, name);
    end
    idx = input(sprintf('Select a cluster [1-%d]: ', len));
    selected = idx >= 1 && idx <= len;
end
% cluster_name = cl(idx).name;
cluster_name = names{idx};

end


function desc = lProfileName(cluster, release)

switch lower(cluster)
    case {'amd', 'intel'}
        desc = ['IBEX ' cluster ' ' release];
    case {'shaheen'}
        desc = ['SHAHEEN ' cluster ' ' release];
    otherwise
        error('Unsupported cluster %s', cluster)
end

end


function matRoot = lGetMatlabRoot(cluster, release)

switch lower(cluster)
    case {'amd'}
        matRoot = ['/sw/csa/matlab/' release '/el7_binary'];
    case {'intel'}
        matRoot = ['/sw/csi/matlab/' release '/el7_binary'];
    case {'shaheen'}
        matRoot = ['/lustre/sw/xc40/matlab/' release];
    otherwise
        error('Unsupported cluster %s', cluster)
end

end


function loginnode = lGetLoginNode(cluster)

switch lower(cluster)
    case {'amd'}
        loginnode = 'alogin.dragon.kaust.edu.sa';
    case {'intel'}
        loginnode = 'ilogin.dragon.kaust.edu.sa';
    case {'shaheen'}
        loginnode = 'shaheen.hpc.kaust.edu.sa';
    otherwise
        error('Unsupported cluster %s', cluster)
end

end


function r = lGetLocalRoot()

rootPath = userpath;
if isempty(rootPath)
    uh = java.lang.System.getProperty('user.home');
    uh = uh.toLowerCase;
    r = char(uh);
else
    delim = ':';

    if ispc
        delim = ';';
    end

    r = strtok(rootPath, delim);
end

end


function scratch = lGetScratch(cluster, user, release)

switch lower(cluster)
    case {'amd', 'intel'}
        scratch = ['/scratch/dragon/' cluster '/' user '/Jobs/' release];
    case {'shaheen'}
        scratch = ['/scratch/' user '/Jobs/' release];
    otherwise
        error('Unsupported cluster %s', cluster)
end

end


function assembleClusterProfile(jfolder, rjsl, cluster, user, profile, def)

% Create generic cluster profile
c = parallel.cluster.Generic;

% Required mutual fields
% Location of the Integration Scripts
% c.IntegrationScriptsLocation = fullfile(fileparts(mfilename('fullpath')), '+IntegrationScripts', '+common');
c.IntegrationScriptsLocation = fullfile(fileparts(mfilename('fullpath')), 'IntegrationScriptsRef');
c.NumWorkers = def.NumWorkers;
c.OperatingSystem = 'unix';

% Set common properties
c.AdditionalProperties.UserNameOnCluster = user;
c.AdditionalProperties.ClusterHost = def.ClusterHost;
c.ClusterMatlabRoot = def.ClusterMatlabRoot;
c.AdditionalProperties.RemoteJobStorageLocation = rjsl;
c.HasSharedFilesystem = false;
c.JobStorageLocation = jfolder;

% Get cluster respective information
cInfo = clusterInformation(cluster);

% AdditionalProperties for the cluster:
% username, queue, walltime, e-mail, etc.
c.AdditionalProperties.AdditionalSubmitArgs = '';
% Set the debug log to false by default. Enable if troubleshooting.
c.AdditionalProperties.DebugMessagesTurnedOn = false;
c.AdditionalProperties.StraceOn = false;
c.AdditionalProperties.EmailAddress = '';
c.AdditionalProperties.ProcsPerNode = 0;
c.AdditionalProperties.QueueName = cInfo.defaultQueue;
c.AdditionalProperties.UseIdentityFile = true;
c.AdditionalProperties.IdentityFile = '';
c.AdditionalProperties.IdentityFileHasPassphrase = false;
c.AdditionalProperties.WallTime = '';
c.AdditionalProperties.SshPort = 22;
c.AdditionalProperties.DataParallelism = cInfo.parallelType;
c.AdditionalProperties.ClusterName = cluster;
c.AdditionalProperties.JobName = '';
c.AdditionalProperties.RequiresExclusiveNode = false;

% Save Profile
c.saveAsProfile(profile);
c.saveProfile('Description', profile)

% Set as default profile
parallel.defaultClusterProfile(profile);

end

function cInfo = clusterInformation(cluster)

switch lower(cluster)
    case {'amd'}
        cInfo.parallelType = 'eth';
        cInfo.defaultQueue = 'batch';
    case {'intel'}
        cInfo.parallelType  = 'eth';
        cInfo.defaultQueue = 'batch';
    case {'shaheen'}
        cInfo.parallelType  = 'ib';
        cInfo.defaultQueue = 'workq';
    otherwise
        error('Unsupported cluster %s', cluster)
end

end


% Modify the below banner to display a message for users regarding
% the cluster requirements (based on getAdditionalSubmitArguement).
% If you wish to display this banner, uncomment the above
function lNotifyUserOfCluster(cluster)

switch lower(cluster)
    case {'amd', 'intel', 'shaheen'}
        fprintf(['\nBefore submitting a job to %s, you must specify the wall time.\n', ...
                 '\n\t\t>> %% E.g. set wall time to 1 hour', ...
                 '\n\t\t>> c = parcluster;', ...
                 '\n\t\t>> c.AdditionalProperties.WallTime = (''0-1'')', ...
                 '\n\t\t>> c.saveProfile', ...
                 '\n\t\tAcceptable time formats include:\n \t\t"minutes",', ...
                 ' "minutes:seconds", "hours:minutes:seconds", "days-hours",', ...
                 '"days-hours:minutes" and "days-hours:minutes:seconds"\n\n'], cluster);

        if strcmpi(cluster, 'shaheen')
            fprintf(['\nOn %s cluster, you must also specify your pojecct.\n', ...
                    '\n\t\t>> %% E.g. set project to k1117\n\t\t', ...
                    '\n\t\t>> c = parcluster;', ...
                    '\n\t\t>> c.AdditionalProperties.ProjectName = (''k1117'')', ...
                    '\n\t\t>> c.saveProfile\n'], cluster);

            fprintf('\nOn %s cluster, you must also start a secure connection that has been OTP authenticated.\n', cluster);
            fprintf('\n\t\t>> %% E.g. starting SSH connection on localhost listenening on port 2222\n\t\tssh -L2222:shaheen.hpc.kaust.edu.sa:22 -p 22 -N -f -t -x -o PreferredAuthentications=publickey,keyboard-interactive shaheen.hpc.kaust.edu.sa');
            fprintf(['\n\t\t>> %% Now set port used by MATLAB HPC Add-on:', ...
                    '\n\t\t>> c = parcluster;', ...
                    '\n\t\t>> c.AdditionalProperties.SshPort = (''2222'')', ...
                    '\n\t\t>> c.saveProfile\n']);
        end
    otherwise
        error('Unsupported cluster %s', cluster)
end

end
