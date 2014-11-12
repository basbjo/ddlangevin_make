prefix = ../..
datadirs = ..
makedir = $(prefix)/makefiles
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/drift.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.dat
DROPSUFFIX = .dat

## settings
IF_FUTURE = 0		# 1 if last column for follower, 0 else
# settings for drift fields
DRIFT_LAST_COL = 3	# last column (optional, >1)
# reference data is searched here (optional)
DRIFT_REFDIR = $(prefix)/drift

## default targets
all += calc #plot_all

## call macros
$(call_macros)
