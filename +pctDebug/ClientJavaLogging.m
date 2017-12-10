function ClientJavaLogging(logdir, loglevel)
% Turn java logging on in the client machine
% If logdir is empty this implies that any existing logging should be turned off

% Antonio Arena: Removed version detetction since we only support R2014 and above
% Raymond Norris: Merged R2012a-R2014b
% Anthony Chan: This is a modified version of qePCTTest.hClientJavaLogging()
%               so the input argument are optional.
%               If 1st argument, logdir, is missing, default to `tempdir`
%               Also, if 2nd argument, loglevel, is missing, default to 6.
% John Cao: modified the logging settings and turns off qeinbat mode
%           so it's more appropriate for customer debugging

% Copyright 2016 KAUST.
% Copyright 2009-2011 The MathWorks, Inc.

import java.util.logging.Level;
import('com.mathworks.toolbox.parallel.pctutil.logging.DistcompLevel');

clientLogger = com.mathworks.toolbox.parallel.pctutil.logging.RootLog.LOG;
formatter = @com.mathworks.toolbox.parallel.pctutil.logging.DistcompSimpleFormatter;

persistent aHandler
persistent aLogFilename
% mlock to hold the handler even if someone clears all MATLAB variables
mlock;

try
    if nargin < 2
        % Default PCT logging level
        log_level = 6;
    else
        log_level = loglevel;
    end
    
    if nargin < 1
        % Default PCT temp dir
        log_dir = tempdir;
    else
        log_dir = logdir;
    end

    % New file we are going to start logging to
    logFilePattern = fullfile(log_dir, 'pct_client.log');
    % Size and count for log rolling
    % Log rolling currently disabled due to sporadic failures seen where
    % log rolling takes 20-30 seconds
    useLogRolling = false;

    if isempty(log_dir)
        clientLogger.log(Level.INFO, 'Log handler stopping');
    else
        % Lets write where we are going next so someone can follow the logs
        clientLogger.log(Level.INFO, sprintf('Log handler moving to file %s', logFilePattern));
    end
    
    % If there is already a handler then we need to remove it
    if ~isempty(aHandler)
        % Remove and close
        clientLogger.removeHandler(aHandler);
        aHandler.close();
    end
    
    if isempty(log_dir)
        % Turn off logging
        aHandler = [];
        aLogFilename = [];
    else
        % Just in case the file already exists we will append to it
        append = true;
        if useLogRolling
            aHandler = java.util.logging.FileHandler(logFilePattern, logFileMaxSize, logFileMaxNumber, append); %#ok<UNRCH>
        else
            aHandler = java.util.logging.FileHandler(logFilePattern, append);
        end
        aHandler.setFormatter(formatter());
        % Set the logging level and add the handler
        aHandler.setLevel(DistcompLevel.getLevelFromValue(log_level));
        clientLogger.addHandler(aHandler);
        % If we are following on from a previous log then indicate where we came
        % from just in case it is useful
        if ~isempty(aLogFilename)
            clientLogger.log(Level.INFO, sprintf('Continuing log from file %s', aLogFilename));
        end
        % Write a log message indicating that it has all been done
        clientLogger.log(Level.INFO, sprintf('Logging at level %d', log_level));
        % Persistently hold the name of this log file for when it is changed.
        aLogFilename = logFilePattern;
    end
catch err
    fprintf('Unable to start java logging. Report is\n%s\n', err.getReport);
end
