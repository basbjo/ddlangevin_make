prefix = ../..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/langevin.mk
include localconf.mk
include $(makedir)/name_downsampling.mk# variable SAMPDATA
include $(makedir)/cat.mk
include $(makedir)/split.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DROPSUFFIX =
DATA_LINK = $(addsuffix ${PROJSUFFIX},${RAWDATA}) $(SAMPDATA)

## settings
# see config.mk and localconf.mk
# extra suffix for olangevin programs
OL_SUFFIX = _b2
# extra settings for testmodel programs
OL_TM_FLAGS = -H

## default targets
all += info

## call macros
$(call_macros)
