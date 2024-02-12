function configCluster
% Configure MATLAB to submit to the cluster.

% Copyright 2016-2018 KAUST
% Antonio M. Arena (antonio.arena@kaust.edu.sa)
% Copyright 2013-2017 The MathWorks, Inc.

% The version of MATLAB being supported
release = ['R' version('-release')];

% Import cluster definitions
def.NumWorkers = 600;

cluster = 'ibex';

% Delete the old profile (if it exists)
profiles = parallel.clusterProfiles();
idx = strcmp(profiles, cluster);
ps = parallel.Settings;
ws = warning;
warning off
ps.Profiles(idx).delete
warning(ws)

def.ClusterMatlabRoot = lGetMatlabRoot(release);
def.ClusterHost = 'ilogin.ibex.kaust.edu.sa';

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
%rjsl = lGetScratch(cluster, user, release);
rjsl = ['/ibex/scratch/' user '/Jobs/' release];
assembleClusterProfile(jfolder, rjsl, cluster, user, def);

% Uncomment this if you want to display a banner for users.
lNotifyUserOfCluster(upper(cluster))

%cmd = sprintf('/sw/spack-kaust/scripts/elasticapps.py --app mat_hpc_add_on --version %s &', release);
%system(cmd);

end


function matRoot = lGetMatlabRoot(release)

    switch release
    	case {'R2022a'}
        	matRoot = ['/sw/rl9c/matlab/' release '/rl9_binary'];
    	case {'R2022b'}
		matRoot = ['/sw/rl9c/matlab/' release '/rl9_binary'];
    	case {'R2023a'}
		matRoot = ['/sw/rl9c/matlab/' release '/rl9_binary'];
    	case {'R2023b'}
		matRoot = ['/sw/rl9c/matlab/' release '/rl9_binary'];
    	otherwise
    		matRoot = ['/sw/rl9c/matlab/' release '/rl9_binary'];
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


function assembleClusterProfile(jfolder, rjsl, cluster, user, def)

% Create generic cluster profile
c = parallel.cluster.Generic;

% Required mutual fields
% Location of the Integration Scripts
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

% AdditionalProperties for the cluster:
% username, queue, walltime, e-mail, etc.
c.AdditionalProperties.AdditionalSubmitArgs = '';
% Set the debug log to false by default. Enable if troubleshooting.
c.AdditionalProperties.DebugMessagesTurnedOn = false;
c.AdditionalProperties.StraceOn = false;
c.AdditionalProperties.EmailAddress = '';
c.AdditionalProperties.ProcsPerNode = 0;
c.AdditionalProperties.QueueName = 'batch';
c.AdditionalProperties.UseIdentityFile = true;
c.AdditionalProperties.IdentityFile = '';
c.AdditionalProperties.IdentityFileHasPassphrase = false;
c.AdditionalProperties.WallTime = '';
c.AdditionalProperties.SshPort = 22;
% DataParallelism is unused. However, removing it entirely breaks the code, so it's staying for now. -OM March 2023
c.AdditionalProperties.DataParallelism = 'eth';
c.AdditionalProperties.ClusterName = cluster;
c.AdditionalProperties.JobName = '';
c.AdditionalProperties.ProjectName = '';
c.AdditionalProperties.RequiresExclusiveNode = false;

% Added this property to accomodate the changes from the new mathworks repo for the slurm plugin for matlab. -OM March 2023
if verLessThan('matlab', '9.6')
    c.AdditionalProperties.useSmpd = 1;
else
    c.AdditionalProperties.useSmpd = 0;
end


% Save Profile
c.saveAsProfile(cluster);
c.saveProfile('Description', 'Ibex')

% Set as default profile
parallel.defaultClusterProfile(cluster);

end

% Modify the below banner to display a message for users regarding
% the cluster requirements (based on getAdditionalSubmitArguement).
% If you wish to display this banner, uncomment the above
function lNotifyUserOfCluster(cluster)
    fprintf(['\nBefore submitting a job to %s, you must specify the wall time.\n', ...
             '\n\t\t>> %% E.g. set wall time to 1 hour', ...
             '\n\t\t>> c = parcluster;', ...
             '\n\t\t>> c.AdditionalProperties.WallTime = (''60'')', ...
             '\n\t\t>> c.saveProfile', ...
             '\n\t\tAcceptable time formats include:\n \t\t"minutes",', ...
             ' "minutes:seconds", "hours:minutes:seconds", "days-hours",', ...
             '"days-hours:minutes" and "days-hours:minutes:seconds"\n\n'], cluster);

end
