prefix = ../../..
datadirs = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/histogram.mk
include $(firstword ${datadirs})/localconf.mk
splitdir := $(firstword ${datadirs})/$(splitdir)

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *$(DLE_SUFFIX)
DROPSUFFIX = $(SUBDIR_DROPSUFFIX)

## settings
# see config.mk and localconf.mk
IF_FUTURE = $(SPLIT_FUTURE)
# settings for 1D histograms
KTFACTOR = 1            # factor for temperature rescaling

## default targets
all += calc calc_fel1d #plot_all

## call macros
$(call_macros)
