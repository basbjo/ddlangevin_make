.PHONY: downsampling
downsampling: $$(SAMPDATA)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += TIME_UNIT
SHOWDATA += REDUCTION_FACTORS SAMPORIG SAMPDATA

## default settings that must be changed before including this file

## variables
include $(makedir)/name_downsampling.mk# variable SAMPDATA

## rules
define template_ds_ln
$(1): downsampling/$(2)
	ln -sf $$< $$@
endef

define template_ds
downsampling/$(1):
	cd $$(@D) && $$(MAKE) $$(@F)
endef

## macros to be called later
MACROS += link_downsampling

define link_downsampling
$(foreach file,$(wildcard ${SAMPORIG}),$(foreach rfac,${REDUCTION_FACTORS},\
	$(eval $(call template_ds_ln,$(call\
	down_sampled_linkname,${file},${TIME_UNIT},${rfac}),${file}_ds${rfac}))\
	$(eval $(call template_ds,${file}_ds${rfac}))))\
$(eval SAMPORIG := $(wildcard ${SAMPORIG}))
endef

## info
INFOend += downsampling
INFO_downsampling = calculate down sampled data
define INFOADD

Call target downsampling once to consider down sampled data.

endef

## clean
PURGE_LIST += $(SAMPDATA)
