#!/usr/bin/env python
#Perform PCA, delay PCA or TICA
# author - abhinav jain ;  last updated: 2014-08-12
import numpy as np
import argparse
import textwrap
import sys
def read_data(fhandle):
    """
    read data from file X
    """
    data = []
    for line in fhandle:
        data.append(map(float,line.strip().split()))
    return np.asarray(data)

def delay_cov(X,delay):
    """
    compute delayed covariance matrix
    """
    print "using non high memory module for delayed covariance matrix calculation"
    ncol = X[0].shape[1]
    covmat = np.empty((ncol,ncol))
    for i in np.arange(ncol):
        var_i1 = []
        var_j2 = []
        for Xk in X:
            var_i1.append(Xk[:-delay,i])
            var_j2.append(Xk[delay:,i])
        var_i1 = np.hstack(var_i1)
        var_j2 = np.hstack(var_j2)
        for j in np.arange(i,ncol):
            if i!=j:
                var_j1 = []
                var_i2 = []
                for Xk in X:
                    var_j1.append(Xk[delay:,j])
                    var_i2.append(Xk[:-delay,j])
                var_j1 = np.hstack(var_j1)
                var_i2 = np.hstack(var_i2)
                covmat[i,j] = np.cov(var_i1, var_j1)[0,1]
                covmat[j,i] = np.cov(var_i2, var_j2)[0,1]
            else:
                covmat[i,j] = np.cov(var_i1, var_j2)[0,1]
    return covmat

def delay_cov_high_mem(X,delay):
    """
    compute delayed covariance matrix, faster but high memory consumption
    """
    print "using high memory module for delayed covariance matrix calculation"
    ncol = X[0].shape[1]
    covmat = np.empty((ncol,ncol))
    tail_chopped_components = []
    head_chopped_components = []
    for i in np.arange(ncol):
        head_chopped_i = []
        tail_chopped_i = []
        for j in X:
            tail_chopped_i.append(j[:-delay,i])
            head_chopped_i.append(j[delay:,i])
        tail_chopped_components.append(np.hstack(tail_chopped_i))
        head_chopped_components.append(np.hstack(head_chopped_i))
    for var1 in np.arange(ncol):
        for var2 in np.arange(var1,ncol):
            covmat[var1,var2]=np.cov(tail_chopped_components[var1], head_chopped_components[var2])[0,1]
            if var1!=var2 :
                covmat[var2,var1] = np.cov(tail_chopped_components[var2], head_chopped_components[var1])[0,1]
    return covmat

def PCA_delayPCA_tica(X, delay, tica=False, delayPCA=False, PCA=True, high_memory=False):
    """
    do tica or delay_PCA or PCA over input trajectories
    """
    # output dictionary
    output = dict()

    # concat X if many files
    if X[0].size != X[0].shape[0]:
        Y = np.vstack(X)
    else:
        Y = np.hstack(X)

    if  delayPCA:
        print "doing delay PCA"
        # calculate lagged covariance matrix
        if high_memory:
            lagged_covmat = delay_cov_high_mem(X, delay)
        else:
            lagged_covmat = delay_cov(X, delay)
        # symmetrize lagged covariance matrix
        symm_cov = (lagged_covmat + lagged_covmat.T)/2
        # diagonalize symm cov mat
        d1,u1 = np.linalg.eigh(symm_cov)
        # sort eigenvalues and eigenvectors
        idx = np.argsort(np.abs(d1))[::-1]
        u1 = u1[:,idx]
        d1 = d1[idx]
        # project on lagged eigenvectors to get delayPCA components
        delay_proj = np.dot(Y,u1)
        # append to output
        output['lagged_covariance_matrix'] = lagged_covmat
        output['symmetrized_covariance_matrix'] = symm_cov
        output['lagged_eigenvectors']= u1
        output['lagged_eigenvalues']=d1
        output['delay_principal_components'] = delay_proj

    if tica:
        print "doing TICA"
        u,d,v = np.linalg.svd(np.cov(Y,rowvar=0)) # normal PCA
        proj = []  # PCs
        norm_proj = [] # normalized PCs
        for Xi in X:
            proj.append(np.dot(Xi,u))
            norm_proj.append(np.dot(Xi,u)/np.sqrt(d))
        # calculate lagged covariance on normalized PCs
        if high_memory:
            lagged_covmat_tica = delay_cov_high_mem(norm_proj, delay)
        else:
            lagged_covmat_tica = delay_cov(norm_proj, delay)
        # symmetrized lagged covariance matrix
        symm_cov_tica = (lagged_covmat_tica + lagged_covmat_tica.T)/2
        # diagonalized symm cov mat tica
        d2,u2 = np.linalg.eigh(symm_cov_tica)
        # sort eigenvalues and eigenvectors
        idx = np.argsort(np.abs(d2))[::-1]
        u2 = u2[:,idx]
        d2 = d2[idx]
        # project normalized PCs on lagged eigenvectors to get tica components
        tica_proj = []
        for pj in norm_proj:
            tica_proj.append(np.dot(pj,u2))
        # contact projections
        if tica_proj[0].size != tica_proj[0].shape[0]:
            tica_proj = np.vstack(tica_proj)
            proj = np.vstack(proj)
        else:
            tica_proj = np.hstack(tica_proj)
            proj = np.hstack(proj)
        # append to output
        output['pca_eigenvectors'] = u
        output['pca_eigenvalues'] = d
        output['principal_components'] = proj
        output['lagged_covariance_matrix_tica'] = lagged_covmat_tica
        output['symmetrized_covariance_matrix_tica'] = symm_cov_tica
        output['tica_eigenvectors'] = u2
        output['tica_eigenvalues'] = d2
        output['time_independent_components'] = tica_proj


    if not tica and PCA:
        print "doing PCA"
        u,d,v = np.linalg.svd(np.cov(Y,rowvar=0)) # normal PCA
        proj = np.dot(Y,u)
        output['pca_eigenvectors'] = u
        output['pca_eigenvalues'] = d
        output['principal_components'] = proj

    return  output


def main():
    parser = argparse.ArgumentParser(description='delay PCA/ tica/ PCA', formatter_class=argparse.RawDescriptionHelpFormatter,epilog=textwrap.dedent('''\
     PCA output :
        pca_eigenvectors,
        pca_eigenvalues,
        principal_components

     delayPCA output :
        lagged_covariance_matrix,
        symmetrized_covariance_matrix,
        lagged_eigenvectors,
        lagged_eigenvalues,
        delay_principal_components

     TICA output :
        pca_eigenvectors,
        pca_eigenvalues,
        principal_components,
        lagged_covariance_matrix_tica,
        symmetrized_covariance_matrix_tica,
        tica_eigenvectors,
        tica_eigenvalues,
        time_independent_components(tica_projections)
        '''))
    parser.add_argument('-i','--trajectory', dest='tt', nargs='*', default=sys.stdin, type=str, help='input, trajectory file(s) with variables in columns and observations in rows')
    parser.add_argument('-b','--break', dest='ttb', help='split trajectory by last column, 0 means no successor', action='store_true')
    parser.add_argument('-l','--lagtime', dest='delay', default=1, type=int, help='input, number of frames for lag/delay >=1, default=1, ignore for only doing PCA')
    parser.add_argument('-p','--PCA', dest='PCA', help='do PCA', action='store_true' )
    parser.add_argument('-d','--delayPCA', dest='delayPCA', help='do delay PCA', action='store_true')
    parser.add_argument('-t','--tica', dest='tica', help='do TICA', action='store_true')
    parser.add_argument('-m','--highmem', dest='high_memory', help='faster delayed covariance matrix calculation, uses higher memory', action='store_true')
    args = parser.parse_args()
    print "reading input files"
    X = []
    if args.ttb and not isinstance(args.tt,file) and len(args.tt)>1:
        sys.exit("You must not provide several files with option -b.")
    elif args.ttb:
        if isinstance(args.tt,file):
            file_in = args.tt
        else:
            file_in = open(args.tt[0],'r')
        iX = []
        for line in file_in:
            buf = map(float,line.strip().split())
            iX.append(buf[0:-1])
            if buf[-1]==0:
                X.append(np.asarray(iX))
                iX = []
        file_in.close()
    else:
        if isinstance(args.tt,file):
            X.append(read_data(args.tt))
        else:
            for filename in args.tt:
                with open(filename,'r') as file_in:
                    X.append(read_data(file_in))

    X = np.asarray(X)

    output = PCA_delayPCA_tica(X, args.delay, args.tica, args.delayPCA, args.PCA, args.high_memory)
    print "saving output"
    for i in output:
        np.savetxt(i+".dat", output[i], fmt="%.6e")
    return

if __name__ == "__main__":
    main()
