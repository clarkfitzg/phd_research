#!/bin/sh
FNAME=$(date '+%Y-%m-%d__%H-%M.log')
/usr/sbin/lsof > /home/clarkf/phd_research/hadoop/lsof_logs/$FNAME
