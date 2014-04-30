prefix = ..
makedir = $(prefix)/makefiles
include $(makedir)/common.mk
include $(makedir)/hello.mk

## source data files in this directory (wildcards allowed)
DATA_HERE = *.dat
## source data files in datadirs (wildcards allowed)
datadirs += $(prefix)/data
DATA_LINK = *.dat

## settings
HELLO = Hello world!

## default targets
all += hello

## call macros
$(call_macros)
