"""
Tools for working with fars data
"""

# Standard library
import re
import os
import ftplib
from zipfile import ZipFile


# This will be user specific, probably want to change it.
# Keep the trailing /, since following code assumes it.
DATADIR = os.path.expanduser("~/data/fars/")


def before2012(x, start):
    """
    In 2012 the directory pattern changed, so we'll just look at those
    years before that.
    
    start year can be as early as 1975.
    """
    try:
        year = int(x)
        return start <= year < 2012
    except ValueError:
        return False


def download(datadir = DATADIR, start = 2010):
    """
    Download FARS data from the FTP server.

    When running from command line you should see output like this.

    $ python download_fars.py
    downloaded FARS1975.zip
    downloaded FARS1976.zip
    ...
    downloaded FARS2011.zip
    """

    ftp = ftplib.FTP("ftp.nhtsa.dot.gov")
    ftp.login()
    # Navigate into the FARS directory
    ftp.cwd("FARS")

    allyears = (x for x in ftp.nlst() if before2012(x, start))

    for year in allyears:
        ftp.cwd(year + "/DBF")
        # Grab the first zip file
        fname = [x for x in ftp.nlst() if x.lower().endswith("zip")][0]
        # Retrieve binary files and write them to the local machine
        with open(DATADIR + fname, "wb") as f:
            ftp.retrbinary("RETR " + fname, f.write)
            print("downloaded " + fname)
        ftp.cwd("../..")


def isfars(fname):
    """
    Return True if the filename looks like a FARS file
    """
    x = fname.lower()
    return x.startswith("fars") and x.endswith(".zip")


def unzip(fname, datadir = DATADIR):
    """
    Unzip a single fars file into a directory based on year
    """
    yr = re.findall(r"[0-9]{2,4}", fname)[0]
    yrdir = datadir + yr
    try:
        os.mkdir(yrdir)
    except FileExistsError:
        print(yrdir + " already exists. Skipping.")
        return None

    with ZipFile(datadir + fname) as zf:
        zf.extractall(yrdir)


def unzip_all(datadir = DATADIR):
    for f in os.listdir(datadir):
        if isfars(f):
            unzip(f, datadir)
            print("unzipped " + f)
