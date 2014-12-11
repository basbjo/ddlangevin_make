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

## settings
IF_FUTURE = 1
# if 1: data is split into consecutive trajectories such
#       that each series ends when the last column is 0
# if 0: data is split into two parts of equal length
SPLIT_KEEP_FUTURE = 0
# if 1: keep follower column if IF_FUTURE is 1
# else: remove follower column if IF_FUTURE is 1

## default targets
all += split

## call macros
$(call_macros)
