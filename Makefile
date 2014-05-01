prefix = .
datadirs = .
makedir = $(prefix)/makefiles
include $(makedir)/common.mk
include $(makedir)/readme.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK =
DROPSUFFIX =

## settings

## default targets
all += doc

## call macros
$(call_macros)
