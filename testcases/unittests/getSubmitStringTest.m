function tests = getSubmitStringTest
tests = functiontests(localfunctions);
end

% This gets executed at the beginning of each test
function setup(testCase)  % do not change function name
ClusterInfo.setWallTime('15')
end

% This get executed at the end of each test
function teardown(testCase)  % do not change function name
ClusterInfo.clear
end

function testNoWalltime(testCase)
ClusterInfo.clear
ClusterInfo.setNameSpace('amd')
props = TestProps;
getSubmitString = str2func('profiles.kaust.common.getSubmitString');
try 
    getSubmitString('fail_test', 'fail_log', 'pwd', props);
catch exception
    assertSubstring(testCase, exception.message, 'Must provide a wall time.')
end
end

function testAmd(testCase)
ClusterInfo.setNameSpace('amd')
props = TestProps;
props.NumberOfTasks = 4;
getSubmitString = str2func('profiles.kaust.common.getSubmitString');
submitString = getSubmitString('test', 'testlog', 'hostname', props);
verifyEqual(testCase, submitString, 'sbatch --output=testlog --job-name=test -n 4 --cpus-per-task=2 -C amd -t 15 --partition=batch hostname')
end

function testAmdOnMultipleNodes(testCase)
ClusterInfo.setNameSpace('amd')
ClusterInfo.setProcsPerNode(2)
props = TestProps;
props.NumberOfTasks = 4;
getSubmitString = str2func('profiles.kaust.common.getSubmitString');
submitString = getSubmitString('test', 'testlog', 'hostname', props);
verifyEqual(testCase, submitString, 'sbatch --output=testlog --job-name=test --ntasks-per-node=2 -n 4 --cpus-per-task=2 -C amd -t 15 --partition=batch hostname')
end

function testIntel(testCase)
ClusterInfo.setNameSpace('intel')
props = TestProps;
props.NumberOfTasks = 16;
getSubmitString = str2func('profiles.kaust.common.getSubmitString');
submitString = getSubmitString('test', 'testlog', 'date', props);
verifyEqual(testCase, submitString, 'sbatch --output=testlog --job-name=test -n 16 -C intel -t 15 --partition=batch date')
end

function testIntelOnMultipleNodes(testCase)
ClusterInfo.setNameSpace('intel')
ClusterInfo.setProcsPerNode(4)
props = TestProps;
props.NumberOfTasks = 16;
getSubmitString = str2func('profiles.kaust.common.getSubmitString');
submitString = getSubmitString('test', 'testlog', 'date', props);
verifyEqual(testCase, submitString, 'sbatch --output=testlog --job-name=test --ntasks-per-node=4 -n 16 -C intel -t 15 --partition=batch date')
end

function testShaheen(testCase)
ClusterInfo.setNameSpace('shaheen')
props = TestProps;
props.NumberOfTasks = 4;
getSubmitString = str2func('profiles.kaust.common.getSubmitString');
submitString = getSubmitString('test', 'testlog', 'pwd', props);
verifyEqual(testCase, submitString, 'sbatch --output=testlog --job-name=test -n 4 --ntasks-per-socket=16 -t 15 --partition=workq pwd')
end

function testShaheenOnMultipleNodes(testCase)
ClusterInfo.setNameSpace('shaheen')
ClusterInfo.setProcsPerNode(12)
props = TestProps;
props.NumberOfTasks = 24;
getSubmitString = str2func('profiles.kaust.common.getSubmitString');
submitString = getSubmitString('test', 'testlog', 'pwd', props);
verifyEqual(testCase, submitString, 'sbatch --output=testlog --job-name=test --ntasks-per-node=12 -n 24 --ntasks-per-socket=16 -t 15 --partition=workq pwd')
end
