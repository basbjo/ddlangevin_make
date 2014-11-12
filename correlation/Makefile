prefix = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/correlation.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DROPSUFFIX =
DATA_LINK = $(addsuffix ${PROJSUFFIX},${RAWDATA})

## settings
# see config.mk

## default targets
all += estim #calc/plot plot_all

## call macros
$(call_macros)
