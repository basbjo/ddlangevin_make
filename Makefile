prefix = .
datadirs = .
include $(prefix)/config.mk
include $(makedir)/common.mk
include $(makedir)/readme.mk
include $(makedir)/dpca.mk
include $(makedir)/split.mk

## source data files in this directory (wildcards allowed)
DATA_HERE = $(RAWDATA) $(SAMPDATA)
## source data files in datadirs (wildcards allowed)
DATA_LINK =
DROPSUFFIX =

## settings
#see config.mk
SPLIT_DROPSUFFIX = .cossin.pca
SPLIT_LIST = *$(SPLIT_DROPSUFFIX)

## default targets
all += dpca minmax

## call macros
$(call_macros)

## additional info
INFOend += downsampling
INFO_downsampling = calculate down sampled data
define INFOADD

Call downsampling once to consider down sampled data for dpca.

endef

## symbolic links to data derived from raw data by down sampling
SAMPDATA = $(foreach file,$(wildcard ${RAWDATA})\
	   ,$(foreach rfac,${REDUCTION_FACTORS}\
	   ,$(call down_sampled_linkname,${file},${TIME_UNIT},${rfac})))
PURGE_LIST += $(SAMPDATA)
RAWDATA := $(wildcard ${RAWDATA})
SHOWCONF += TIME_UNIT
SHOWDATA += RAWDATA REDUCTION_FACTORS SAMPDATA

define template_ds_ln
$(1): downsampling/$(2)
	ln -sf $$< $$@
endef

## down sampling
downsampling: $$(SAMPDATA)

define template_ds
downsampling/$(1):
	cd $$(@D) && $$(MAKE) $$(@F)
endef

## macros
define down_sampled_linkname
$(shell name=$(1); unit=$(2); factor=$(3);
prefix=`echo $${name}|sed -r "s/_[0-9]+$${unit}.*//"`;
suffix=`echo $${name}|sed -r "s/.*_[0-9]+$${unit}//"`;
oldvalue=`echo $${name}|egrep -o "_[0-9]+$${unit}($$|\.)"|grep -o '[0-9]*'`;
newvalue=$$(($${oldvalue}*$${factor}));
echo $${prefix}_$${newvalue}$${unit}$${suffix})
endef

## call macros for down sampling
$(foreach file,$(wildcard ${RAWDATA}),$(foreach rfac,${REDUCTION_FACTORS},\
	$(eval $(call template_ds_ln,$(call\
	down_sampled_linkname,${file},${TIME_UNIT},${rfac}),${file}_ds${rfac}))\
	$(eval $(call template_ds,${file}_ds${rfac}))))
