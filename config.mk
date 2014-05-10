# do not add any targets in this file
makedir = $(prefix)/makefiles

## source data
TIME_UNIT = ps
RAWDATA = alldih*_1$(TIME_UNIT)
# name format: <unique name without dots>[.suffixes]_<num>$(TIME_UNIT)
# data format: "[time] dihedral_angles... [future]"
#      future: 0 at end of trajectory / 1 else
IF_FUTURE ?= 1# 1 with future column, 0 else

## data and factors for downsampling
SAMPORIG = $(RAWDATA)
REDUCTION_FACTORS = 5

## first and last column to be selected from source data for dPCA
# WARNING: recreate all affected data manually after changes
DIH_MIN_COL = 7
DIH_MAX_COL = 16

## save split pca data here to avoid recalculation
splitdir ?= $(firstword ${datadirs})/splitdata-pca
