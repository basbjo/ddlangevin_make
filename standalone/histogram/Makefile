prefix = ../..
datadirs = ..
makedir = $(prefix)/makefiles
# include split.mk only in one makefile that uses the splitdir specified on
# the following line and if not including split.mk here uncomment that line
#splitdir = $(or $(firstword ${datadirs}),.)/splitdata
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/histogram.mk
include $(makedir)/split.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.dat
DROPSUFFIX = .dat

## settings
IF_FUTURE = 0		# 1 if last column for follower, 0 else
# settings for 1D histograms
HIST1D_LAST_COL = 20	# last column (optional)
HIST1D_PLOT_NCOLS = 4	# number of columns per plot
HIST1D_YRANGE =		# yrange (optional, format: ymin:ymax)
KTFACTOR = 1		# factor for temperature rescaling
# settings for 2D histograms
HIST2D_LAST_COL = 3	# last column (optional, >1)
# reference data is searched here (optional)
HIST1D_REFDIR = $(prefix)/histogram
HIST2D_REFDIR = $(prefix)/histogram

## default targets
all += calc #plot_all

## call macros
$(call_macros)
