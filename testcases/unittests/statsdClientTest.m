function tests = statsdClientTest
tests = functiontests(localfunctions);
end

% This gets executed at the beginning of each test
function setup(testCase)  % do not change function name
testCase.TestData.Client = TestStatsdClient(testCase);
end

function testSendsCounterValue(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.mycount:1234567890|c';
client.countWithoutRate('mycount', 1234567890);
end

function testSendsCounterValueWithRate(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.mycount:1234567890|c|@0.00024';
client.count('mycount', 1234567890, 0.00024);
end

function testSendsCounterIncrement(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.myinc:1|c';
client.increment('myinc');
end

function testSendsCounterDecrement(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.myinc:-1|c';
client.decrement('myinc');
end

function testSendsGauge(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.mygauge:22334455|g';
client.gauge('mygauge', 22334455);
end

function testSendsFractionalGauge(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.mygauge:423.1235|g';
client.gauge('mygauge', 423.123456789);
end

function testSendsLargeFractionalGauge(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.mygauge:423423423.9|g';
client.gauge('mygauge', 423423423.9);
end

function testSendsZeroGauge(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.mygauge:0|g';
client.gauge('mygauge', 0)
end

function testSendsNegagiveGaugeByResettingToZeroFirst(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.mygauge:0|g\nstatsd.kmat.mygauge:-423|g';
client.gauge('mygauge', -423);
end

function testSendsGaugePositiveDelta(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.mygauge:+423|g';
client.gaugeDelta('mygauge', 423);
end

function testSendsGaugeNegativeDelta(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.mygauge:-423|g';
client.gaugeDelta('mygauge', -423);
end

function testSendsGaugeZeroDelta(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.mygauge:+0|g';
client.gaugeDelta('mygauge', 0);
end

function testSendsSet(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.myset:test|s';
client.sendSet('myset', 'test');
end

function testSendsTimer(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.mytime:12345|ms';
client.executionTimeWithoutRate('mytime', 12345);
end

function testSendsTimerWithRate(testCase)
client = testCase.TestData.Client;
client.expected = 'statsd.kmat.mytime:67890|ms|@0.000123';
client.executionTime('mytime', 67890, 0.000123);
end
