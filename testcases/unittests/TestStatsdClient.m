classdef TestStatsdClient < statsd.Client
    %TESTSTATSDCLIENT Summary of this class goes here
    %   Detailed explanation goes here

    methods
        function obj = TestStatsdClient(ts)
            obj = obj@statsd.Client();
            obj.testcase = ts;
        end
    end

    properties (Access='private')
        testcase
    end
    
    properties
        expected
    end

    methods (Access='protected')
        function send(obj, message)
            import matlab.unittest.constraints.IsEqualTo;
            obj.testcase.verifyThat(message, IsEqualTo(obj.expected));
        end
    end

end

