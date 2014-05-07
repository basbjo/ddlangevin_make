prefix = .
datadirs = .
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/readme.mk

## source data files in this directory (wildcards allowed)
DATA_HERE = $(RAWDATA)
## source data files in datadirs (wildcards allowed)
DATA_LINK =
DROPSUFFIX =

## settings
#see config.mk

## default targets
all += doc

## call macros
$(call_macros)
