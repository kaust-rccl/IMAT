function Init(logdir, LEVEL)

if nargin < 2
    LEVEL = 6;
end

if nargin < 1
    logdir = pwd;
end

% Preserve jobs from being delete. This is more applicable to matlabpool/parpool.
pctconfig('preservejobs', true);

% Enable client side debugging
setenv('MDCE_DEBUG', 'true');

% Enable the PCT client side (as well worker side) logging
setSchedulerMessageHandler(pctDebug.ClientJavaMessageHandler);
pctDebug.ClientJavaLogging(logdir, LEVEL)
