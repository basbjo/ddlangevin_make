.PHONY: downsampling
downsampling: $$(SAMPDATA)

## default settings
ifeq ($(strip ${IF_FUTURE}),0)
SPLIT_FUTURE ?= 2# 2: no splitting, 1: split by last column
else
SPLIT_FUTURE ?= $(or ${IF_FUTURE},1)
endif

# settings/data to be shown by showconf/showdata
SHOWCONF += REDUCTION_FACTORS
SHOWDATA += SAMPDATA

## default settings that must be changed before including this file

## variables
SAMPDATA += $(foreach rfac,${REDUCTION_FACTORS},$(addsuffix _ds${rfac},${DATA}))

## rules
# include also split.mk to split data
define template_sampling
%_ds$(1) : % | $$(splitdir)/%-01
	$$(SCR)/downsampling.sh $$(splitdir) $$*\
		$$< $(1) $$(strip $${SPLIT_FUTURE})
endef

define rule_downsampling
$(foreach rfac,$(REDUCTION_FACTORS),$(eval $(call template_sampling,${rfac})))
endef

## macros to be called later
MACROS += rule_downsampling

## info
ifndef INFO
INFO = downsampling clean
INFO_clean        = delete data with fixed starting points
define INFOADD

Down sampled trajectories with starting points ## are concatenated
in file_ds<factor>-## and then all concatendated in file_ds<factor>.

endef
else
INFOend +=
endif
INFO_downsampling = resample and concatenate trajectories

## keep intermediate files
PRECIOUS += $(SPLIT_LIST)

## clean
CLEAN_LIST += $(addsuffix -[0-9]*[0-9],${SAMPDATA})
PURGE_LIST += $(SAMPDATA)
