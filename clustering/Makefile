prefix = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/clustering.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DROPSUFFIX =
DATA_LINK = $(RAWDATA) $(if ${PROJSUFFIX},$(addsuffix ${PROJSUFFIX},${RAWDATA}))

## settings
# see config.mk

## default targets
all += coring centers

## call macros
$(call_macros)
