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
c.AdditionalProperties.ClusterName = 'amd';
c.AdditionalProperties.WallTime = '';
try 
   IntegrationScripts.amd.getCommonSubmitArgs(c, 128, 'itDoesNotMatter');
catch exception
    assertSubstring(testCase, exception.message, 'Must provide a wall time.')
end
end

function testIntel(testCase)
c = testCase.TestData.Cluster;
c.AdditionalProperties.ClusterName = 'intel';
additionalArgs = IntegrationScripts.intel.getCommonSubmitArgs(c, 16, 'testIntel');
verifyEqual(testCase, additionalArgs, '--job-name=testIntel -n 16 -C cpu_intel_gold_6148 -t 15 --partition=batch')
end

function testIntelOnMultipleNodes(testCase)
c = testCase.TestData.Cluster;
c.AdditionalProperties.ClusterName = 'intel';
c.AdditionalProperties.ProcsPerNode = 4;
additionalArgs = IntegrationScripts.intel.getCommonSubmitArgs(c, 16, 'testIntelOnMultipleNodes');
verifyEqual(testCase, additionalArgs, '--job-name=testIntelOnMultipleNodes --ntasks-per-node=4 -n 16 -C cpu_intel_gold_6148 -t 15 --partition=batch')
end

function testShaheen(testCase)
c = testCase.TestData.Cluster;
c.AdditionalProperties.ClusterName = 'shaheen';
additionalArgs = IntegrationScripts.shaheen.getCommonSubmitArgs(c, 12, 'testShaheen');
verifyEqual(testCase, additionalArgs, '--job-name=testShaheen -n 12 --ntasks-per-socket=16 -t 15 --partition=workq')
end

function testShaheenOnMultipleNodes(testCase)
c = testCase.TestData.Cluster;
c.AdditionalProperties.ClusterName = 'shaheen';
c.AdditionalProperties.ProcsPerNode = 12;
additionalArgs = IntegrationScripts.shaheen.getCommonSubmitArgs(c, 24, 'testShaheenOnMultipleNodes');
verifyEqual(testCase, additionalArgs, '--job-name=testShaheenOnMultipleNodes --ntasks-per-node=12 -n 24 --ntasks-per-socket=16 -t 15 --partition=workq')
end
