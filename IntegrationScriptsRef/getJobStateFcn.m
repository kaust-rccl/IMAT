function state = getJobStateFcn(cluster, job, jobState)

getJobStateFcn = @IntegrationScripts.common.getJobStateFcn;
state = getJobStateFcn(cluster, job, jobState);
