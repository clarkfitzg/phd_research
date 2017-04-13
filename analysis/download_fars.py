#!/usr/bin/env python

"""
Download all the FARS data from the FTP server
"""

# Standard library
import ftplib


DATADIR = "/scratch/clarkf/fars/"

ftp = ftplib.FTP("ftp.nhtsa.dot.gov")
ftp.login()
# Navigate into the FARS directory
ftp.cwd("FARS")


def before2012(x):
    """
    In 2012 the directory pattern changed, so we'll just look at those
    years between 1975 and 2011.
    """
    try:
        year = int(x)
        return 1975 <= year < 2012
    except ValueError:
        return False


allyears = filter(before2012, ftp.nlst())


for year in allyears:
    ftp.cwd(year + "/DBF")
    # Not sure if it always comes first...
    fname = DATADIR + ftp.nlst()[0]
    # Retrieve binary files and write them to the local machine
    with open(fname, "wb") as f:
        ftp.retrbinary("RETR " + fname, f.write)
        print("downloaded " + fname)
    ftp.cwd("../..")
