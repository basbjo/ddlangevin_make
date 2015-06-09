prefix = ../..
datadirs = ..
makedir = $(prefix)/makefiles
# include split.mk only in one makefile that uses
# the splitdir as specified on the following line
#splitdir = $(or $(firstword ${datadirs}),.)/splitdata
include $(makedir)/common.mk
include $(makedir)/downsampling.mk
include $(makedir)/split.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.dat

## settings
SPLIT_FUTURE = 2
# if 1: data is split into consecutive trajectories such
#       that each series ends when the last column is 0
# if 2: data is not split
REDUCTION_FACTORS = 2

## default targets
all += downsampling

## call macros
$(call_macros)
