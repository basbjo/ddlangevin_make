prefix = ../..
datadirs = ..
makedir = $(prefix)/makefiles
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/correlation.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.dat
DROPSUFFIX = .dat

## settings
IF_FUTURE = 0		# 1 if last column for follower, 0 else
# settings for autocorrelations
CORR_LAST_COL = 18	# last column (optional)
CORR_XRANGE =		# xrange (optional, format: xmin:xmax)
TIME_UNIT =		# time unit to be shown in x label

## default targets
all +=

## call macros
$(call_macros)
