prefix = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/name_downsampling.mk# variable SAMPDATA
include $(makedir)/drift.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DROPSUFFIX = $(PROJDROPSUFFIX)
DATA_LINK = $(addsuffix ${PROJSUFFIX},${RAWDATA} ${SAMPDATA})

## settings
# see config.mk

## default targets
all += calc #plot_all

## call macros
$(call_macros)
