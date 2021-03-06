prefix = ../../..
datadirs = ..
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/fields.mk
include $(firstword ${datadirs})/localconf.mk

## source data files in this directory (wildcards allowed)
DATA_HERE =
## source data files in datadirs (wildcards allowed)
DATA_LINK = *${DLE_SUFFIX}.field *.ltm
DROPSUFFIX = $(SUBDIR_DROPSUFFIX).field

## settings
# see config.mk and localconf.mk
IF_FUTURE = $(SPLIT_FUTURE)
# additional flags for langevin fields
HEATMAP_FLAGS =
# additional info for target showdata
#SHOWDATA += CALC PLOT

## default targets
all += calc

## call macros
$(call_macros)

## calc and plot targets to be created

# components to be considered for noise
NOISE_PCS = 1
# calculate noise histograms
CALC += $(foreach V,${NOISE_PCS},$(foreach suffix,.xi${V}.hist,\
	$(addsuffix ${suffix},$(filter %.ltm,${DATA}))))
# calculate noise binnings
CALC += $(foreach V,${NOISE_PCS},$(foreach suffix,\
	$(foreach W,$(call urange,${V}),.x${V}.xi${W}.bins),\
	$(addsuffix ${suffix},$(filter %.ltm,${DATA}))))
# plot noise histograms and projected mean/stddev
PLOT += $(foreach suffix,.tex .pdf .png,$(addsuffix ${suffix},\
	$(wildcard *.ltm.xi*.hist *.ltm.x*.xi*.bins)))

# further suffixes to be considered for /all/ data files
1DFIELD_SUFFIXES = #e.g. .x1.hist .x1.f1.bins
2DFIELD_SUFFIXES = #e.g. .x1.x2.hist .x1.x2.f1.bins
CALC += $(foreach suffix,${1DFIELD_SUFFIXES} ${2DFIELD_SUFFIXES},\
	$(addsuffix ${suffix},${DATA}))
# further targets for plotting (heatmap for 2D histograms or binnings)
PLOT += $(foreach psuffix,.pdf .png,$(addsuffix ${psuffix},\
	$(foreach suffix,${2DFIELD_SUFFIXES},$(addsuffix ${suffix},${DATA}))))

# further calc and plot targets
CALC +=
PLOT +=
