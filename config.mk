# do not add any targets in this file
makedir = $(prefix)/makefiles

## source data
TIME_UNIT = ps
RAWDATA = alldih*_1$(TIME_UNIT)
# name format: <first part>_<num>$(TIME_UNIT)[<second part>]
#      the occurance of _<num>$(TIME_UNIT) must be unique
# data format: "[time] dihedral_angles... [future]"
#      future: 0 at end of trajectory / 1 else
IF_FUTURE ?= 1# 1 with future column, 0 else
SHOWDATA += RAWDATA

## projected data, e.g. from principal component analysis
# WARNING: recreate all affected data manually after changes
projtarget = colselect
projmakefile = $(makedir)/$(projtarget).mk
# lag times in units of one time frame in data files (tica only)
LAG_TIMES = 100
# suffix for projected data that is further analysed
#$(eval $(shell grep '^PROJSUFFIX =' ${projmakefile}))
#$(eval $(shell grep '^PROJDROPSUFFIX =' ${projmakefile}))
SHOWDATA += PROJSUFFIX

## data and factors for downsampling
SAMPORIG = $(addsuffix ${PROJSUFFIX},${RAWDATA})
REDUCTION_FACTORS = 5

## first and last column to be selected from source data
# WARNING: recreate all affected data manually after changes
MIN_COL = 7
MAX_COL = 16

## save split pca data here to avoid recalculation
splitdir ?= $(or $(firstword ${datadirs}),.)/splitdata

## minima and maxima as reference for ranges
MINMAXFILE = $(prefix)/minmax

## settings for 1D histograms
HIST1D_LAST_COL = 20	# last column (optional)
HIST1D_PLOT_NCOLS = 4	# number of columns per plot
HIST1D_YRANGE =		# yrange (optional, format: ymin:ymax)

## settings for 2D histograms
HIST2D_LAST_COL = 3	# last column (optional, >1)

## settings for autocorrelations
CORR_LAST_COL = 18	# last column (optional)
CORR_PLOT_NCOLS = 6	# number of columns per plot
CORR_XRANGE =		# xrange (optional, format: xmin:xmax)
CORR_MAXRATIO =		# maximum ratio between correlation times (optional)

## settings for drift fields
DRIFT_LAST_COL = 3	# last column (optional, >1)

## settings for negentropies
NEGENT_LAST_COL = 20	# last column (optional)
