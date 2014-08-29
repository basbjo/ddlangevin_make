#!/usr/bin/env python
#Calculate component-wise negentropies of multivariate data

import sys, argparse
import numpy as np

def gaussian(x, mu, var):
    """
    Gaussian function with expected value mu and variance var.
    The function is not normalized to a probability density.

    :Returns: Function value at x.
    """
    return np.exp(-np.power(x - mu, 2.) / (2 * var))

def bingaussianentropy(var, bin_edges):
    """
    Calculates Shannon entropy of a Gaussian function with variance var
    that is centered to the mean of the bin centers.  The function values
    are evaluted at the bin centers and the entropy is estimated from the
    resulting histogram.

    :Returns: Tuple (entropy, mean).
    """
    binwidths = np.diff(bin_edges)
    bincenters = bin_edges[:-1] + 0.5*binwidths
    mu = np.mean(bincenters)
    # binned gaussian distribution
    gaussbinned = gaussian(bincenters, mu, var)
    # normalize binned gaussian distribution
    gaussbinned = gaussbinned/np.sum(gaussbinned)/binwidths
    # take only non-zero elements for logarithm
    gaussbinned = gaussbinned[np.nonzero(gaussbinned)]
    # Shannon entropy
    entropygaussbinned = -np.dot(np.log(gaussbinned),
            (binwidths*gaussbinned).T)

    return entropygaussbinned, mu

def negentropy(data, nrbins):
    """
    Calculate negentropy of data by calculating a histogram with nrbins and
    comparing the Shannon entropy to that of a equally binned Gaussian function.

    :Returns: Tuple (negentropy, entropy of Gaussian function, entropy of data).
    """
    hist, bin_edges = np.histogram(data, bins=nrbins, density=True)
    binwidths = np.diff(bin_edges)
    bincenters = bin_edges[:-1] + 0.5*binwidths
    # variance: delta X * sum_i(x_i**2*f(x_i))
    var = np.dot(hist*binwidths, bincenters**2)

    # only non-zero nrbins of data distribution
    ifnonzero = np.nonzero(hist)
    posbinwidths = binwidths[ifnonzero]
    histpos = hist[ifnonzero]
    # normalize distribution
    histpos /= np.sum(histpos)
    # entropy of binned distribution
    entropy = -np.dot(np.log(histpos/posbinwidths), histpos.T)
    # entropy of binned Gaussian function
    entropygaussbinned, mu = bingaussianentropy(var, bin_edges)

    # exactly integrated entropy of a Gaussian function
    #entropygauss = np.log(2*np.pi*np.e*var)/2

    return entropygaussbinned-entropy, entropygaussbinned, entropy


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

    # get command line arguments
    args = parser.parse_args()

    if args.input_file == None:
        args.input_file = sys.stdin
    timeseries = np.loadtxt(args.input_file, ndmin=2)

    nrcol = timeseries.shape[1]
    if args.nrcomp > nrcol:
        sys.stderr.write("number of colums exceeds file content -> set to %d\n"
                % nrcol)
        args.nrcomp = nrcol
    if args.nrcomp == 0:
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
        outlist += [[nr+1]+list(negentropy(curdat, args.nrbins))]

    # write out results
    if args.outfile == None:
            args.outfile = sys.stdout
    np.savetxt(args.outfile, outlist, fmt=('%d' + (len(outlist[0])-1)*' %9.5e'),
            header=("component negentropy entropy_of_gaussian entropy_of_system"
                +" (%d bins)" % args.nrbins))

