#!/usr/bin/env python

"""
Download all the FARS data from the FTP server.

When running from command line you should see output like this.

$ python download_fars.py
downloaded FARS1975.zip
downloaded FARS1976.zip
...
downloaded FARS2011.zip
"""

import fars


def main():

    ftp = ftplib.FTP("ftp.nhtsa.dot.gov")
    ftp.login()
    # Navigate into the FARS directory
    ftp.cwd("FARS")

    allyears = filter(before2012, ftp.nlst())

    for year in allyears:
        ftp.cwd(year + "/DBF")
        # Grab the first zip file
        fname = [x for x in ftp.nlst() if x.lower().endswith("zip")][0]
        # Retrieve binary files and write them to the local machine
        with open(DATADIR + fname, "wb") as f:
            ftp.retrbinary("RETR " + fname, f.write)
            print("downloaded " + fname)
        ftp.cwd("../..")


if __name__ == "__main__":
    main()
