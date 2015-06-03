# do not add any targets in this file
makedir = $(prefix)/makefiles

## example selection
# default: none, variants: _var1
example_suffix =

# integration time step for mle
TIME_STEP = 0.001# WARNING: also adjust dt in model*.gp
# number and length of mle trajectories
NTRAJS = 4
TRAJ_LENGTH = 800001

## source data
TIME_UNIT = ps
RAWDATA = mle2$(example_suffix)_$(TIME_STEP)$(TIME_UNIT)
# name format: <first part>_<num>$(TIME_UNIT)[<second part>]
#      the occurance of _<num>$(TIME_UNIT) must be unique
# data format: "[time] dihedral_angles... [future]"
#      future: 0 at end of trajectory / 1 else
IF_FUTURE ?= 1# 1 with future column, 0 else
SHOWDATA += RAWDATA

## projected data, e.g. from principal component analysis
# WARNING: recreate all affected data manually after changes
# typical `projtargets`:
#   `cossin pca` for dPCA (PCA on cos-/sin-transforms)
#   `cossin pca tica` for TICA on cos-/sin-transforms
#   `pca` for PCA on single trajectory data file (IF_FUTURE = 0)
#   `colselect pca` for PCA on multi trajectory data (IF_FUTURE = 1)
projtargets =
projmakefiles = $(addprefix ${makedir}/,$(addsuffix .mk,${projtargets}))
# lag times in units of one time frame in data files (tica only)
LAG_TIMES = 100
# suffix for data that is further analysed
$(foreach makefile,${projmakefiles},$(eval\
	PROJSUFFIX := ${PROJSUFFIX}$(shell\
	grep '^SUFFIX :=' ${makefile}|grep -o '\.[a-z.*]*')))
SHOWDATA += PROJSUFFIX

## data and factors for downsampling
SAMPORIG = $(addsuffix ${PROJSUFFIX},${RAWDATA})
REDUCTION_FACTORS = 5

## first and last column to be selected from source data
# WARNING: recreate all affected data manually after changes
MIN_COL = 1
MAX_COL = $(call fcols,$<)#last data column before future column
# first column containing dihedral angles (needed for .angles.pdf plot)
FIRST_DIH_COL = $(call getmin,3 ${MIN_COL})

## save split data here to avoid recalculation
splitdir ?= $(or $(firstword ${datadirs}),.)/splitdata

## minima and maxima as reference for ranges
MINMAXFILE = $(prefix)/minmax

## settings for projections
# if EIGVEC_PCA_LASTX is less or equal to 10, values are shown
EIGVEC_PCA_LASTX =	# last eigenvector in plot (optional)
EIGVEC_PCA_LASTY =	# last eigenvector entry in plot (optional)
ANGLE_DPCA_LASTX = 20	# number of angles per plot (dpca only)
EIGVEC_TICA_LAST = 10	# last eigenvector and eigenvector entry (optional)

## settings for binned fields
CROP_1DBINNING_RANGE = -S-3.4,3.3

## settings for clustering
CLUSTER_LAST_COL = 5	# last column (optional)

## settings for 1D histograms
HIST1D_LAST_COL = 1	# last column (optional)
HIST1D_PLOT_NCOLS = 4	# number of columns per plot
HIST1D_YRANGE =		# yrange (optional, format: ymin:ymax)

## settings for 2D histograms
HIST2D_LAST_COL = 1	# last column (optional, >1)

## settings for autocorrelations
CORR_LAST_COL = 1	# last column (optional)
CORR_PLOT_NCOLS = 6	# number of columns per plot
CORR_XRANGE =		# xrange (optional, format: xmin:xmax)
CORR_MAXRATIO =		# maximum ratio between correlation times (optional)

## settings for drift fields
DRIFT_LAST_COL = 1	# last column (optional, >1)

## settings for negentropies
NEGENT_LAST_COL = 1	# last column (optional)
