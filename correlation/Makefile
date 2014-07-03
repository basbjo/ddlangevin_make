prefix = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/correlation.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DROPSUFFIX = $(PROJDROPSUFFIX)
DATA_LINK = $(addsuffix ${PROJSUFFIX},${RAWDATA})

## settings
# see config.mk

## default targets
all += calc

## call macros
$(call_macros)
