function tests = extractJobIdTest
tests = functiontests(localfunctions);
end

function testEmptySubmissionStrig(testCase)
verifyEqual(testCase, '', profiles.kaust.common.extractJobId(''))
end

function testStringWhosePatternDoesNotMatch(testCase)
verifyEqual(testCase, profiles.kaust.common.extractJobId('Job <12345> was submiited.'), '')
end

function testExpctedPattern(testCase)
verifyEqual(testCase, profiles.kaust.common.extractJobId('Submitted batch job 127845 to cluster'), '127845')
end

function testExpctedPatternWithExtraSpaces(testCase)
verifyEqual(testCase, profiles.kaust.common.extractJobId('   Submitted batch job 338866    '), '338866')
end

function testWarningIncludedInOutput(testCase)
verifyEqual(testCase, profiles.kaust.common.extractJobId('sbatch: Warning: cannot run 1 processes on 3 nodes, setting nnodes to 1\nSubmitted batch job 12346'), '12346')
end
