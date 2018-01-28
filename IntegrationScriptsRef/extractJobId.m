function jobID = extractJobId(sbatchCommandOutput)

extractJobId = @IntegrationScripts.common.extractJobId;
jobID = extractJobId(sbatchCommandOutput);
