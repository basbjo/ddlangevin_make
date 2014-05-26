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

## data and factors for downsampling
SAMPORIG = $(addsuffix .cossin.pca,${RAWDATA})
REDUCTION_FACTORS = 5

## first and last column to be selected from source data for dPCA
# WARNING: recreate all affected data manually after changes
DIH_MIN_COL = 7
DIH_MAX_COL = 16

## save split pca data here to avoid recalculation
splitdir ?= $(firstword ${datadirs})/splitdata

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
