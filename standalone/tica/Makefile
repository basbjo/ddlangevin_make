prefix = ../..
datadirs = ..
makedir = $(prefix)/makefiles
include $(makedir)/common.mk
include $(makedir)/tica.mk

## source data files in this directory (wildcards allowed)
DATA_HERE = *.dat
## source data files in datadirs (wildcards allowed)
DATA_LINK =
DROPSUFFIX =

## settings
IF_FUTURE = 0		# if 1: append last column of source data to pca data
DIH_MIN_COL = 7		# first column to be selected from source data
DIH_MAX_COL = 16	# last column to be selected from source data
# WARNING: recreate all affected data manually after changes

# lag times in units of one time frame in data files
LAG_TIMES = 100

## default targets
all += tica minmax

## call macros
$(call_macros)
