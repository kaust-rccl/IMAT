function tests = getCommonSubmitArgsTest
tests = functiontests(localfunctions);
end

% This gets executed at the beginning of each test
function setup(testCase)  % do not change function name
c = parallel.cluster.Generic;
c.NumWorkers = 600;
c.OperatingSystem = 'unix';
c.AdditionalProperties.UserNameOnCluster = 'fakeuser';
c.AdditionalProperties.ClusterHost = 'aHost';
c.HasSharedFilesystem = false;
c.AdditionalProperties.AdditionalSubmitArgs = '';
c.AdditionalProperties.DebugMessagesTurnedOn = false;
c.AdditionalProperties.StraceOn = false;
c.AdditionalProperties.EmailAddress = '';
c.AdditionalProperties.ProcsPerNode = 0;
c.AdditionalProperties.QueueName = '';
c.AdditionalProperties.UseIdentityFile = true;
c.AdditionalProperties.IdentityFile = '';
c.AdditionalProperties.WallTime = '15';
c.AdditionalProperties.SshPort = 22;
c.AdditionalProperties.DataParallelism = 'eth';
c.AdditionalProperties.ClusterName = 'aCluster';
c.AdditionalProperties.JobName = '';

testCase.TestData.Cluster = c;
end
% 
% % This get executed at the end of each test
% function teardown(testCase)  % do not change function name
% testCase.TestData.Cluster.
% end

function testNoWalltime(testCase)
c = testCase.TestData.Cluster;
c.AdditionalProperties.ClusterName = 'ibex';
c.AdditionalProperties.WallTime = '';
try 
   IntegrationScripts.ibex.getCommonSubmitArgs(c, 128, 'itDoesNotMatter');
catch exception
    assertSubstring(testCase, exception.message, 'Must provide a wall time.')
end
end

function testIbex(testCase)
c = testCase.TestData.Cluster;
c.AdditionalProperties.ClusterName = 'ibex';
additionalArgs = IntegrationScripts.ibex.getCommonSubmitArgs(c, 16, 'testIbex');
verifyEqual(testCase, additionalArgs, '--job-name=testIbex -n 16 -t 15 --partition=batch')
end

function testIbexOnMultipleNodes(testCase)
c = testCase.TestData.Cluster;
c.AdditionalProperties.ClusterName = 'Ibex';
c.AdditionalProperties.ProcsPerNode = 4;
additionalArgs = IntegrationScripts.ibex.getCommonSubmitArgs(c, 16, 'testIbexOnMultipleNodes');
verifyEqual(testCase, additionalArgs, '--job-name=testIbexOnMultipleNodes --ntasks-per-node=4 -n 16 -t 15 --partition=batch')
end

