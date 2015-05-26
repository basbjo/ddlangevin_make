prefix = ../..
datadirs = ..
makedir = $(prefix)/makefiles
include $(makedir)/common.mk
#include $(makedir)/colselect.mk# optional if IF_FUTURE=0
include $(makedir)/pca.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.dat
DROPSUFFIX = .dat

## settings
IF_FUTURE = 0# if 1: append last column of source data to pca data
# WARNING: be sure to include colselect.mk if IF_FUTURE=1
# first and last column to be selected from source data
MIN_COL = 1
MAX_COL = $(call fcols,$<)#last data column before future column
# WARNING: recreate all affected data manually after changes

## default targets
all += pca

## call macros
$(call_macros)
