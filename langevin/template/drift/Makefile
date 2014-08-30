prefix = ../../..
datadirs = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/fileinfo.mk
include $(makedir)/drift.mk
include $(firstword ${datadirs})/localconf.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = $(SPLIT_LIST)
DROPSUFFIX = .lang

## settings
# see config.mk and localconf.mk
IF_FUTURE = $(SPLIT_FUTURE)

## default targets
all += calc #plot_all

## call macros
$(call_macros)
