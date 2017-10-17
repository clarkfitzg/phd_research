# Tue Oct 17 09:32:41 PDT 2017
# Attempting to do the simplest possible thing, appending the process ID to a
# table. This will tell me how many Python processes are operating.

from __future__ import print_function
import sys
import os


pid = str(os.getpid())

for line in sys.stdin:
  line = line.strip()
  print('\t'.join([line, pid]))
