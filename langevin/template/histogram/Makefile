prefix = ../../..
datadirs = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/histogram.mk
SHOWDATA += splitdir

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.lang
DROPSUFFIX = .lang

## settings
# see config.mk
IF_FUTURE = 1           # 1 if last column for follower, 0 else
# settings for 1D histograms
KTFACTOR = 1            # factor for temperature rescaling

## default targets
all += calc

## call macros
$(call_macros)
