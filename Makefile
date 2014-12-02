prefix = .
include $(prefix)/config.mk
include $(makedir)/common.mk
$(foreach makefile,${projmakefiles},$(eval include ${makefile}))
include $(makedir)/split.mk
include $(makedir)/link_downsampling.mk
include $(makedir)/example.mk
include $(makedir)/readme.mk

## source data files in this directory (wildcards allowed)
DATA_HERE = $(RAWDATA)
## source data files in datadirs (wildcards allowed)
datadirs +=
DATA_LINK =
DROPSUFFIX =

## settings
#see config.mk
SPLIT_LIST = $(addsuffix ${PROJSUFFIX},${RAWDATA})

## default targets
all += $(projtargets) minmax

## call macros
$(call_macros)
