function tests = getDefaultValuesTest
tests = functiontests(localfunctions);
end

function testAmdDefaultQueue(testCase)
ClusterInfo.clear
ClusterInfo.setNameSpace('amd')
verifyEqual(testCase, ClusterInfo.getQueueName(), 'batch')
end

function testIntelDefaultQueue(testCase)
ClusterInfo.clear
ClusterInfo.setNameSpace('intel')
verifyEqual(testCase, ClusterInfo.getQueueName(), 'batch')
end

function testShaheenDefaultQueue(testCase)
ClusterInfo.clear
ClusterInfo.setNameSpace('shaheen')
verifyEqual(testCase, ClusterInfo.getQueueName(), 'workq')
end

function testAmdDefaultDataParallelism(testCase)
ClusterInfo.clear
ClusterInfo.setNameSpace('amd')
verifyEqual(testCase, ClusterInfo.getDataParallelism(), 'eth')
end

function testIntelDefaultDataParallelism(testCase)
ClusterInfo.clear
ClusterInfo.setNameSpace('intel')
verifyEqual(testCase, ClusterInfo.getDataParallelism(), 'eth')
end

function testShaheenDefaultDataParallelism(testCase)
ClusterInfo.clear
ClusterInfo.setNameSpace('shaheen')
verifyEqual(testCase, ClusterInfo.getDataParallelism(), 'ib')
end
