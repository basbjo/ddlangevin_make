prefix = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/downsampling.mk
include $(makedir)/split.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = $(SAMPORIG)

## settings
# see config.mk
# additional factors for downsampling
REDUCTION_FACTORS +=

## default targets
all += downsampling

## call macros
$(call_macros)
