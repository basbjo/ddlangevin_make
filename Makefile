prefix = .
datadirs = .
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/readme.mk
include $(makedir)/dpca.mk
include $(makedir)/split.mk

## source data files in this directory (wildcards allowed)
DATA_HERE = $(RAWDATA)
## source data files in datadirs (wildcards allowed)
DATA_LINK =
DROPSUFFIX =

## settings
#see config.mk
SPLIT_DROPSUFFIX = .cossin.pca
SPLIT_LIST = *$(SPLIT_DROPSUFFIX)

## default targets
all += dpca minmax

## call macros
$(call_macros)
