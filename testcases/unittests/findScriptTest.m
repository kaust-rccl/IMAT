function tests = findScriptTest
tests = functiontests(localfunctions);
end

function testEmptyScriptName(testCase)
verifyEqual(testCase, profiles.kaust.common.findScript('', 'intel'), '')
end

function testEmptyCluster(testCase)
dirname = fileparts(which('profiles.kaust.common.findScript'));
verifyEqual(testCase, profiles.kaust.common.findScript('aScript', ''), fullfile(dirname, 'aScript'))
end

function testFindAmdAdditionalArguments(testCase)
dirname = fileparts(which('profiles.kaust.amd.getAdditionalSubmitArguments'));
verifyEqual(testCase, profiles.kaust.common.findScript('getAdditionalSubmitArguments.m', 'amd'), fullfile(dirname, 'getAdditionalSubmitArguments.m'))
end

function testFindTasksPerNode(testCase)
dirname = fileparts(which('profiles.kaust.common.findScript'));
verifyEqual(testCase, profiles.kaust.common.findScript('tasks_per_node.py', 'intel'), fullfile(dirname, 'tasks_per_node.py'))
end
