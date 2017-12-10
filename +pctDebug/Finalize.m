function Finalize()

FCN = 'pctDebug.ClientJavaLogging';

% Turn off logging
pctDebug.ClientJavaLogging([])

% Unlock function from the memory so all its persistent variable can be
% reinitialized by subsequent clear command.
if mislocked(FCN)
    munlock(FCN)
end
