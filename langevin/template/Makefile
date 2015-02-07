prefix = ../..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/langevin.mk
include localconf.mk
include $(makedir)/name_downsampling.mk# variable SAMPDATA
include $(makedir)/cat.mk
include $(makedir)/split.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DROPSUFFIX =
DATA_LINK = $(addsuffix ${PROJSUFFIX},${RAWDATA}) $(SAMPDATA)

## settings
# see config.mk and localconf.mk
OL_SUFFIX =# extra suffix for olangevin programs
include ol-second.mk# set OL_SUFFIX first

## default targets
all += $(TESTMODEL_DATA) $(OLANGEVIN_DATA)

TESTMODEL_DATA =\
	$(RAWDATA).dle2$(OL_SUFFIX).m1.k25.ltm\
	$(RAWDATA).dle2$(OL_SUFFIX).m1.k200.ltm\
	$(RAWDATA).dle2$(OL_SUFFIX).m1.k500.ltm

## call macros
$(call_macros)
