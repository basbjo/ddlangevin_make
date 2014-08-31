#!/usr/bin/env python
#Calculate component-wise negentropies of multivariate data

import sys, argparse
import numpy as np

def negentropy(data, nrbins):
    """
    Calculate negentropy of data by calculating a histogram with nrbins and
    comparing the Shannon entropy to that of a equally binned Gaussian function.

    :Returns: Tuple (negentropy, entropy of Gaussian function, entropy of data).
    """
    hist, bin_edges = np.histogram(data, bins=nrbins, density=True)
    binwidths = np.diff(bin_edges)
    bincenters = bin_edges[:-1] + 0.5*binwidths
    variance = np.var(data, ddof=1)

    # only non-zero nrbins of data distribution before taking logarithm
    ifnonzero = np.nonzero(hist)
    posbinwidths = binwidths[ifnonzero]
    histpos = hist[ifnonzero]
    # normalize distribution
    histpos /= np.sum(histpos)
    # entropy of binned distribution
    entropy = -np.dot(np.log(histpos/posbinwidths), histpos)

    # exactly integrated entropy of a Gaussian function
    entropygauss = np.log(2*np.pi*np.e*variance)/2

    return entropygauss-entropy, entropygauss, entropy


#######

if __name__ == "__main__":
    parser = argparse.ArgumentParser("calcnegent",
            description=("Calculate component-wise negentropies of multivariate"
                + ' data.  Output format: "[component] [negentropy]'
                + ' [entropy of gaussian] [entropy of system]".\n'))
    parser.add_argument("input_file", metavar="INPUT", type=str, nargs='?',
            default=None,
            help=("input file. If not given will read from STDIN."))
    parser.add_argument("-m", "--nrcomp", dest="nrcomp", default="1", type=int,
            help=("number of columns to consider, starting from first"
                +" [default=1]. If 0, use all."))
    parser.add_argument("-b", "--bins", dest="nrbins", default="500", type=int,
            help=("number of bins for distributions [default=500]."))
    parser.add_argument("-o", "--output", dest="outfile", default=None,
            help=("output file [default=STDOUT]."))
    parser.add_argument("-w", "--whiten", dest="whiten", action='store_true',
            default=False, help=("divide each column by its standard"
                + " deviation."))

    # get command line arguments and data
    args = parser.parse_args()

    if args.input_file == None:
        args.input_file = sys.stdin
    if args.nrcomp == 0:
        usecols = None
    else:
        usecols = range(args.nrcomp)
    try:
        timeseries = np.loadtxt(args.input_file, ndmin=2, usecols=usecols)
    except IndexError:
        timeseries = np.loadtxt(args.input_file, ndmin=2)

    nrcol = timeseries.shape[1]
    if args.nrcomp > nrcol:
        sys.stderr.write("number of colums exceeds file content -> set to %d\n"
                % nrcol)
        args.nrcomp = nrcol
    elif args.nrcomp == 0:
        args.nrcomp = nrcol
        sys.stderr.write("using all %i columns\n" % nrcol)

    # calculate negentropies
    outlist = []
    for nr, curdat in enumerate(timeseries.T):
        if args.whiten:
            sd = np.std(curdat)
            curdat /= sd
            sys.stderr.write("stddev before whitening: %f and after: %f\n" %
                    (sd, np.std(curdat)))
        outlist.append([nr+1]+list(negentropy(curdat, args.nrbins)))

    # write out results
    if args.outfile == None:
            args.outfile = sys.stdout
    np.savetxt(args.outfile, outlist, fmt=('%d' + (len(outlist[0])-1)*' %e'),
            header=("component negentropy entropy_of_gaussian entropy_of_system"
                +" (%d bins)" % args.nrbins))

