function debugLog(job)

% Copyright 2016-2018 KAUST.
% Antonio M. Arena (antonio.arena@kaust.edu.sa)

narginchk(1, 1)
if numel(job) > 1
    error('Must only supply one job.')
end

if ~isa(job, 'parallel.job.CJSIndependentJob') && ~isa(job, 'parallel.job.CJSCommunicatingJob')
    error('Must provide Independent or Communicating Job')
end

job.Parent.getDebugLog(job);
end
