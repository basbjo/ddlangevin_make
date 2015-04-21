prefix = ../../..
datadirs = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/neighbors.mk
include $(firstword ${datadirs})/localconf.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *.osn
DROPSUFFIX = .osn

## settings
# see config.mk and localconf.mk
SELECT_ROWS = 1 2

## default targets
all += calc

## call macros
$(call_macros)
