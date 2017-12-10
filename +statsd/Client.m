classdef Client < handle
    %CLIENT Summary of this class goes here
    %   Detailed explanation goes here

    methods
        function obj = Client(varargin)
            defaultPort = 8125;

            switch (nargin)
                case 0
                    host = getenv('STATSD_HOST');
                    if isempty(host)
                        host = 'localhost';
                    end
                    port = getenv('STATSD_PORT');
                    if isempty(port)
                        port = 8125;
                    else
                        port = str2num(port);
                    end
                case 1
                    host = varargin{1};
                    port = defaultPort;
                case 2
                    host = varargin{1};
                    port = varargin{2};
                otherwise
                    host = varargin{1};
                    port = varargin{2};
                    if isa(port, 'numeric')
                    else
                        port = defaultPort;
                    end
            end

            obj.statsdHost = host;
            obj.statsdPort = port;
            obj.udpSocket = udp(obj.statsdHost, obj.statsdPort);
            fopen(obj.udpSocket);
        end
    end

    properties (Constant, Access='private')
        PREFIX = 'statsd.kmat.';
        NO_RATE = 1.0;
    end

    properties (Access='private')
        statsdHost
        statsdPort
        udpSocket
    end

    methods (Static, Access='private')
        function msg = messageWithoutRate(tag, value, type)
            msg = statsd.Client.messageFor(tag, value, type, statsd.Client.NO_RATE);
        end

        function msg = messageFor(tag, value, type, rate)
            val = [statsd.Client.PREFIX tag ':' num2str(value) '|' type];
            if rate ~= statsd.Client.NO_RATE
                val = [val '|@' num2str(rate)];
            end
            msg = val;
        end
    end

    methods (Access='protected')
        function send(obj, message)
            fprintf(obj.udpSocket, message);
        end
    end

    methods (Access='public')
        function delete(obj)
            fclose(obj.udpSocket);
            delete(obj.udpSocket);
            clear obj.udpSocket;
        end

        function countWithoutRate(obj, tag, value)
            count(obj, tag, value, statsd.Client.NO_RATE);
        end

        function count(obj, tag, value, rate)
            send(obj, statsd.Client.messageFor(tag, value, 'c', rate));
        end

        function increment(obj, tag)
            countWithoutRate(obj, tag, 1)
        end

        function decrement(obj, tag)
            countWithoutRate(obj, tag, -1)
        end

        function gauge(obj, tag, value)
            val = '';
            if value < 0
                val = [statsd.Client.messageWithoutRate(tag, 0, 'g') '\n'];
            end
            val = [val '' statsd.Client.messageWithoutRate(tag, value, 'g')];
            send(obj, val);
        end

        function gaugeDelta(obj, tag, delta)
            if delta >= 0
                val = ['+' num2str(delta)];
            else
                val = delta;
            end
            send(obj, statsd.Client.messageWithoutRate(tag, val, 'g'));
        end

        function sendSet(obj, tag, name)
            send(obj, statsd.Client.messageWithoutRate(tag, name, 's'));
        end

        function executionTimeWithoutRate(obj, tag, time)
            executionTime(obj, tag, time, statsd.Client.NO_RATE);
        end

        function executionTime(obj, tag, time, rate)
            send(obj, statsd.Client.messageFor(tag, time, 'ms', rate));
        end
    end

end
