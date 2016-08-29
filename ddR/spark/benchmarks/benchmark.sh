#!/bin/bash

# Mon Aug 29 14:01:06 KST 2016
#
# Goal:
# Accurate benchmarks for SparkR performance

# User and machine specific settings

SPARK_HOME="$HOME/dev/spark"
#SPARK_WORKER_INSTANCES=4  # One for every physical core

# Make sure we're not competing for system resources
source $SPARK_HOME/sbin/stop-all.sh

# Use mostly defaults to start up local master and workers.
# source $SPARK_HOME/sbin/start-master.sh

# N
#source $SPARK_HOME/sbin/start-slave.sh -m 1G -c 1 localhost:7077
#source $SPARK_HOME/sbin/start-slave.sh -m 1G -c 1 localhost:7077

# Mon Aug 29 15:56:27 KST 2016 The one below causes a worker to appear in
# the master web UI: http//localhost:8080
# Should also see worker UI at http//localhost:8081
source $SPARK_HOME/sbin/start-slaves.sh -m 1G -c 1 localhost:7077
