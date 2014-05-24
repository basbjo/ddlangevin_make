prefix = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/histogram.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DROPSUFFIX = .cossin.pca
DATA_LINK = $(addsuffix ${DROPSUFFIX},${RAWDATA})

## settings
# see config.mk

## default targets
all += calc

## call macros
$(call_macros)
