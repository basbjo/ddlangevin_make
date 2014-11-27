prefix = ../../..
datadirs = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/fields.mk
include $(firstword ${datadirs})/localconf.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *${DLE_SUFFIX}.field *.ltm
DROPSUFFIX = $(SUBDIR_DROPSUFFIX).field

## settings
# see config.mk and localconf.mk
IF_FUTURE = $(SPLIT_FUTURE)
# settings for langevin fields
HEATMAP_FLAGS =

## default targets
all += info

## call macros
$(call_macros)
