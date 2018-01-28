function state = getJobStateFcn(cluster, job, state)

getJobStateFcn = @IntegrationScripts.common.deleteJobFcn;
state = getJobStateFcn(cluster, job, state);
