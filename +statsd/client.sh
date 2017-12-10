#!/usr/bin/env bash

#
# Very simple bash client to send metrics to a statsd server
# Example with gauge:  ./statsd-client.sh 'my_metric:100|g'
#
# Alexander Fortin <alexander.fortin@gmail.com>
# Antonio Arena - 2017 - <antonio.arena@kaust.edu.sa>
#

host="statsd.kaust.edu.sa"
port=8125
stats=

# Let's read in the inputs
while [ $# -gt 0 ]; do
    case "${1}" in
        --host)
            shift
            host="${1}"
            shift
        ;;

        --port)
            shift
            mdport="${1}"
            shift
        ;;

        --stats)
            shift
            stats="${1}"
            shift
        ;;

        -*)
            echo "${0}: error - unrecognized option ${1}" 1>&2;
            exit 1
        ;;

        *)  break
        ;;
    esac
done

if [ -z "${stats}" ]
then
    echo "Syntax: $0 '<gauge_data_for_statsd>'"
    exit 1
fi

# Setup UDP socket with statsd server
exec 3<> /dev/udp/$host/$port

# Send data
printf "${1}" >&3

# Close UDP socket
exec 3<&-
exec 3>&-
