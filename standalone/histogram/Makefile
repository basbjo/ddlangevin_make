prefix = ../..
datadirs = ..
makedir = $(prefix)/makefiles
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/histogram.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.dat
DROPSUFFIX = .dat

## settings
IF_FUTURE = 0           # 1 if last column for follower, 0 else
# settings for 2D histograms
HIST2D_LAST_COL = 3	# last column (optional, >1)

## default targets
all += calc

## call macros
$(call_macros)