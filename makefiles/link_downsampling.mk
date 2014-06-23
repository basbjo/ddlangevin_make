.PHONY: downsampling
downsampling: $$(SAMPDATA)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += TIME_UNIT
SHOWDATA += REDUCTION_FACTORS SAMPORIG SAMPDATA

## default settings that must be changed before including this file

## variables
SAMPDATA = $(foreach file,$(wildcard ${SAMPORIG})\
	   ,$(foreach rfac,${REDUCTION_FACTORS}\
	   ,$(call down_sampled_linkname,${file},${TIME_UNIT},${rfac})))

## rules
define template_ds_ln
$(1): downsampling/$(2)
	ln -sf $$< $$@
endef

define template_ds
downsampling/$(1):
	cd $$(@D) && $$(MAKE) $$(@F)
endef

## macros
define down_sampled_linkname
$(shell name=$(1); unit=$(2); factor=$(3);
prefix=`echo $${name}|sed -r "s/_[0-9.]+$${unit}.*//"`;
suffix=`echo $${name}|sed -r "s/.*_[0-9.]+$${unit}//"`;
oldvalue=`echo $${name}|egrep -o "_[0-9.]+$${unit}($$|\.)"|grep -o '[0-9.]*[0-9]'`;
newvalue=`echo $${oldvalue}*$${factor}|bc`;
echo $${prefix}_$${newvalue}$${unit}$${suffix})
endef

define link_downsampling
$(foreach file,$(wildcard ${SAMPORIG}),$(foreach rfac,${REDUCTION_FACTORS},\
	$(eval $(call template_ds_ln,$(call\
	down_sampled_linkname,${file},${TIME_UNIT},${rfac}),${file}_ds${rfac}))\
	$(eval $(call template_ds,${file}_ds${rfac}))))\
$(eval SAMPORIG := $(wildcard ${SAMPORIG}))
endef

## macros to be called later
MACROS += link_downsampling

## info
INFOend += downsampling
INFO_downsampling = calculate down sampled data
define INFOADD

Call target downsampling once to consider down sampled data.

endef

## clean
PURGE_LIST += $(SAMPDATA)
