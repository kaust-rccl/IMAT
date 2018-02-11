function submitString = getSubmitString(jobName, quotedLogFile, quotedCommand, additionalSubmitArgs)

getSubmitString = @IntegrationScripts.common.getSubmitString;
submitString = getSubmitString(jobName, quotedLogFile, quotedCommand, additionalSubmitArgs);
