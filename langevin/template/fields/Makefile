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
# settings for langevin fields
HEATMAP_FLAGS =

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

# further calc and plot targets
CALC +=
PLOT +=
