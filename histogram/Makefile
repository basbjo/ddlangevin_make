prefix = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/histogram.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DROPSUFFIX =
DATA_LINK = $(addsuffix ${PROJSUFFIX},${RAWDATA})

## settings
# see config.mk

## default targets
all += calc calc_fel1d #plot_all

## call macros
$(call_macros)
