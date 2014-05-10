prefix = ../..
splitdir = splitdata-pca
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/langevin.mk
include $(makedir)/split.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.cossin.pca
DROPSUFFIX = .cossin.pca

## settings
# see config.mk
SPLIT_LIST = *.lang
SPLIT_FUTURE = 1# 1 if files in SPLIT_LIST have follower column, 0 else
SPLIT_DROPSUFFIX = .lang

## default targets
all += split

## call macros
$(call_macros)
