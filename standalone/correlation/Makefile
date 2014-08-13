prefix = ../..
datadirs = ..
makedir = $(prefix)/makefiles
# include split.mk only in one makefile that uses the splitdir specified on
# the following line and if not including split.mk here uncomment that line
#splitdir = $(or $(firstword ${datadirs}),.)/splitdata
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/correlation.mk
include $(makedir)/split.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.dat
DROPSUFFIX = .dat

## settings
IF_FUTURE = 0		# 1 if last column for follower, 0 else
# settings for autocorrelations
CORR_LAST_COL = 18	# last column (optional)
CORR_PLOT_NCOLS = 6	# number of columns per plot
CORR_XRANGE =		# xrange (optional, format: xmin:xmax)
CORR_MAXRATIO =		# maximum ratio between correlation times (optional)
TIME_UNIT =		# time unit to be shown in x label

## default targets
all += calc

## call macros
$(call_macros)
