function state = getJobStateFcn(cluster, job, jobState)

getJobStateFcn = @IntegrationScripts.common.deleteJobFcn;
state = getJobStateFcn(cluster, job, jobState);
