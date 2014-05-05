prefix = ../..
datadirs = ..
splitdir = .
makedir = $(prefix)/makefiles
include $(makedir)/common.mk
include $(makedir)/split.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.dat
DROPSUFFIX = .dat

## settings
IF_FUTURE = 1
# if 1: data is split into consecutive trajectories such
#       that each series ends when the last column is 0
# if 0: data is split into two parts of equal length
SPLIT_DROPSUFFIX = # drop suffix of source filenames

## default targets
all += split

## call macros
$(call_macros)
