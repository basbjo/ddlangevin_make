prefix = ../../..
datadirs = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/information.mk
include $(firstword ${datadirs})/localconf.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = $(SPLIT_LIST)
DROPSUFFIX = $(SUBDIR_DROPSUFFIX)

## settings
# see config.mk and localconf.mk
IF_FUTURE = $(SPLIT_FUTURE)

## default targets
all +=

## call macros
$(call_macros)
