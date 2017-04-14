"""
Tools for working with fars data

Lessons
-------
- Look before you leap?
- Self documenting
- Self testing

"""

# Standard library
import re
import os
import math
import ftplib
from zipfile import ZipFile

# Third party library. Get it with `pip install dbfread`
from dbfread import DBF


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


def isfars(fname):
    """
    Return True if the filename looks like a FARS file
    """
    x = fname.lower()
    return x.startswith("fars") and x.endswith(".zip")


def download(datadir = DATADIR, start = 2010):
    """
    Download FARS data from the FTP server.

    Expect to see output like this-

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
        #fname = [x for x in ftp.nlst() if isfars(x)][0]
        fname = next(filter(isfars, ftp.nlst()))
        # Retrieve binary files and write them to the local machine
        with open(DATADIR + fname, "wb") as f:
            # TODO: Explain following line-
            ftp.retrbinary("RETR " + fname, f.write)
            print("downloaded " + fname)
        ftp.cwd("../..")


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


def response_minutes(row):
    """
    Minutes between the occurrence
    of the accident and the arrival of emergency medical services.
    """
    HOUR, MINUTE = row["HOUR"], row["MINUTE"]
    ARR_HOUR, ARR_MIN= row["ARR_HOUR"], row["ARR_MIN"]

    unknown = any((MINUTE >= 60,
        HOUR >= 24,
        ARR_MIN >= 60,
        ARR_HOUR >= 24,
        ARR_MIN == 0 and ARR_HOUR == 0,
        ))

    # Just to help for later
    if unknown:
        return -math.inf

    # Arrival was the following day, ie. midnight between accident and
    # response, so one day off.
    if ARR_HOUR < HOUR:
        ARR_HOUR += 24

    diff = (60 * ARR_HOUR + ARR_MIN) - (60 * HOUR + MINUTE)
    return diff


def all_responses(fname):
    """
    Generator over the rows of responses
    """
    for row in iter(DBF(fname)):
        yield response_minutes(row)
