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
# extra suffix for olangevin programs
OL_SUFFIX =
include ol-second.mk# set OL_SUFFIX first
# extra settings for testmodel programs
# (set -L to length of two input trajectories)
OL_TM_FLAGS = -L$(shell echo $$((2*${TRAJ_LENGTH}-4))) -H

## default targets
all += testmodel# dle

.PHONY: testmodel dle
testmodel: $$(TESTMODEL_DATA)
dle: $$(OLANGEVIN_DATA)
INFO += testmodel dle
INFO_testmodel = create testmodel trajectories and fields
INFO_dle = create new dLE trajectories and fields

TESTMODEL_DATA =\
	$(RAWDATA).dle2$(OL_SUFFIX).m1.k50.ltm\
	$(RAWDATA).dle2$(OL_SUFFIX).m1.k300.ltm\
	$(RAWDATA).dle2$(OL_SUFFIX).m1.k1000.ltm

## call macros
$(call_macros)
