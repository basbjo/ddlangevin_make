prefix = .
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/readme.mk
include $(makedir)/dpca.mk
include $(makedir)/split.mk
include $(makedir)/link_downsampling.mk

## source data files in this directory (wildcards allowed)
DATA_HERE = $(RAWDATA)
## source data files in datadirs (wildcards allowed)
datadirs +=
DATA_LINK =
DROPSUFFIX =

## settings
#see config.mk
SPLIT_LIST = *.cossin.pca

## default targets
all += dpca minmax

## call macros
$(call_macros)
