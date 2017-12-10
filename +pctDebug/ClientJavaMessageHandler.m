function aHandler = ClientJavaMessageHandler()
% Create a message handler.
%
% The message handler accepts a level number and a message, and routes them to the worker logger.

% Antonio Arena: Removed version detetction since we only support R2014 and above
%                Streamlined how client ogger is called
% Copyright 2016 KAUST.
% Copyright 2006-2014 The MathWorks, Inc.

aHandler = @nMessageHandler;

    function nMessageHandler(msg, levelNum)
        % Do nothing if log level is invalid
        if nargin ~= 2
            return
        end

        try
            clientLogger = com.mathworks.toolbox.parallel.pctutil.logging.RootLog.LOG;
            lvl = com.mathworks.toolbox.parallel.pctutil.logging.DistcompLevel.getLevelFromValue(levelNum);
            clientLogger.log(lvl, msg);
        catch err
            fprintf('\nexplicit error start *********\n');
            fprintf('%s\n', getReport(err))
            fprintf('explicit error end   *********\n');
        end
    end
end
