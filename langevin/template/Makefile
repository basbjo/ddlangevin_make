prefix = ../..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/langevin.mk
include localconf.mk
include $(makedir)/split.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.cossin.pca
DROPSUFFIX = .cossin.pca

## settings
# see config.mk and localconf.mk

## default targets
all += split

## call macros
$(call_macros)