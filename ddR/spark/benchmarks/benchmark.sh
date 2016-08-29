#!/bin/bash

# Mon Aug 29 14:01:06 KST 2016
#
# Goal:
# Accurate benchmarks for SparkR performance

# User and machine specific settings

SPARK_HOME="$HOME/dev/spark"
SPARK_WORKER_INSTANCES="4"  # One for every physical core

# Make sure we're not competing for system resources
source $SPARK_HOME/sbin/stop-all.sh

# Use mostly defaults to start up local master and workers.
# These workers don't appear in the web UI at http://localhost:8080/
# but I see them on the system process manager.
source $SPARK_HOME/sbin/start-master.sh

source $SPARK_HOME/sbin/start-slave.sh -m 1G -c 1 localhost:7077
