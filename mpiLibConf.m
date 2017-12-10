function [primaryLib, extras] = mpiLibConf

% Copyright 2016-2018 KAUST
% Antonio M. Arena (antonio.arena@kaust.edu.sa)
% Copyright 2014-2015 The MathWorks, Inc.
display('Using HPC Add-on');

% Turn off MPI deadlock detection to be sure we don't choke on mpiFinalize
mpiSettings('DeadlockDetection', 'off');

% Check first if we're running the local scheduler.  If we are, then get
% the default, and exit early.
dfcn = getenv('MDCE_DECODE_FUNCTION');
ext = getenv('MDCE_MPI_EXT');
if strcmp(dfcn, 'parallel.internal.decode.localMpiexecTask') || strcmp(ext, 'simple') || strcmp(ext, 'eth')
    [primaryLib, extras] = distcomp.mpiLibConfs( 'default' );
    return
end

cluster = getenv('MDCE_CLUSTER');
if strcmp(cluster, 'profiles.kaust.shaheen')
    % Let's use Cray's MPICH to connect to fabric
    env = 'MPICH_ROOT';
    root = getenv(env);
    if isempty(root)
        error(['Undefined variable: ' env]);
    end

    mpichlib = fullfile(root, 'lib');
    primaryLib = fullfile(mpichlib, 'libmpich.so');
    extras = {};
else
    % We're not running the local scheduler or using the default MATLAB libmpich
    % We only support INTEL MPI to connect to underlying QLogic PSM layer
    env = 'I_MPI_ROOT';
    root = getenv(env);
    if isempty(root)
        error(['Undefined variable: ' env]);
    end

    slurmlib = '/usr/lib64';
    mpichlib = fullfile(root, 'lib');
    primaryLib = fullfile(mpichlib, 'libmpi.so');
    extras = {fullfile(slurmlib, 'libpmi.so')};
end
