prefix = ../../..
datadirs = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/histogram.mk
include $(firstword ${datadirs})/localconf.mk
splitdir := $(firstword ${datadirs})/$(splitdir)
SHOWDATA += splitdir

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = $(SPLIT_LIST)
DROPSUFFIX = .lang

## settings
# see config.mk and localconf.mk
IF_FUTURE = $(SPLIT_FUTURE)
# settings for 1D histograms
KTFACTOR = 1            # factor for temperature rescaling

## default targets
all += calc

## call macros
$(call_macros)
