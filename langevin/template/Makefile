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
DROPSUFFIX = .pru
DATA_LINK = $(addsuffix ${PROJSUFFIX},${RAWDATA}) $(SAMPDATA)\
	    $(addsuffix ${PROJSUFFIX}*.pru,${RAWDATA})\
	    $(addsuffix *.pru,${SAMPDATA})

## settings
# see config.mk and localconf.mk
# extra suffix for olangevin programs
OL_SUFFIX = _b2
include ol-second.mk# set OL_SUFFIX first
# additional flags for olangevin testmodel programs
# (set -L to length of two input trajectories)
# (set -H to print neighbourhood information)
OL_TM_FLAGS = -L$(shell echo $$((2*${TRAJ_LENGTH}-4))) -H
# additional flags for ol-search-neighbors programs
OL_SN_FLAGS =

## default targets
all += testmodel# neighborhood dle

TESTMODEL_DATA =\
	$(foreach m,1 \
	,$(foreach k,50 300 1000 \
	,$(addsuffix .dle2${OL_SUFFIX}.m${m}.k${k}.ltm,${DATA})))

NEIGHBORS_DATA =\
	$(foreach m,1 \
	,$(foreach k,50 300 1000 \
	,$(addsuffix .dle2.m${m}.k${k}.osn,${DATA})))

## call macros
$(call_macros)
