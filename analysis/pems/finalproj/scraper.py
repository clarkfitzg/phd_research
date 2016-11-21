#!/usr/bin/env python

"""
Automates download from PeMS

Run this on poisson, save to scratch partition
"""

import os
import pems


def main(args):

    with open(args.cookie) as f:
        cookies = {"PHPSESSID": f.read().strip()}

    links = pems.pems_links(args.linkhtml)

    if args.test:
        links = dict((links.popitem(), links.popitem()))

    pems.download(links, cookies, datadir=args.datadir)


if __name__ == "__main__":

    import argparse
    parser = argparse.ArgumentParser()

    parser.add_argument("--datadir",
            default=os.getcwd(),
            help="Location of the raw station txt.gz files")

    parser.add_argument("--linkhtml",
            help="Html file containing table with links")

    parser.add_argument("--cookie",
            help="Cookie file containing value corresponding to PHPSESSID")

    parser.add_argument("--test", action="store_true",
            help="Test run with only two links")

    args = parser.parse_args()

    main(args)
