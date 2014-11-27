.PHONY: rescale tica
rescale: $$(UNITVARDATA)

tica: rescale $$(TICADATA)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA += TICADATA

## default settings that must be changed before including this file

## variables
TICAPREVSUFFIX := $(SUFFIX)
UNITVARDATA += $(addsuffix ${TICAPREVSUFFIX}.rs,${DATA})
TICADATA += $(foreach lt,${LAG_TIMES},$(addsuffix\
	    ${TICAPREVSUFFIX}.lag${lt}.tica,${DATA}))
DIR_LIST += $(addsuffix _dir,${TICADATA})
# suffix for data that is further analysed
SUFFIX := $(TICAPREVSUFFIX).lag*.tica
# minima and maxima as reference for ranges
MINMAXALL = $(TICADATA)

## rules
%$(TICAPREVSUFFIX).rs: %$(TICAPREVSUFFIX)
	# rescale columns to unit variance
	$(if $(shell [ ${IF_FUTURE} -eq 0 ] && echo yes),\
		$(RESCALE) -v -m$(call fcols,$<) $< -o $@,\
		sed 's/ [01]$$//' $< | $(RESCALE) -v -m$(call fcols,$<) -o $@)

define template_tica
%$(TICAPREVSUFFIX).lag$(1).tica_dir/delay_principal_components.dat :\
	%$(TICAPREVSUFFIX).rs
	# perform time lagged independent component analysis on $$<\
		(lag time $(1) frames)
	mkdir -p $$(@D)
	$$(if $$(shell [ $${IF_FUTURE} -eq 0 ] && echo yes)\
	  ,cd $$(@D) && $$(DELAYPCA) --trajectory ../$$< --lagtime $(1) --delayPCA\
	  ,cd $$(@D) && awk '{print $$$$NF}' ../$$* | paste -d\  ../$$< - \
		  | $$(DELAYPCA) --break --lagtime $(1) --delayPCA)
%$(TICAPREVSUFFIX).lag$(1).tica :\
	%$(TICAPREVSUFFIX).lag$(1).tica_dir/delay_principal_components.dat
	$$(appendlastcol_command)
endef

define rule_tica
$(foreach lag_time,${LAG_TIMES},$(eval $(call template_tica,${lag_time})))
endef

## macros to be called later
MACROS += rule_tica

## info
ifndef INFO
INFO = rescale tica
define INFOADD
endef
else
INFOend += rescale tica
endif
INFO_rescale = rescale data to unit variance
INFO_tica   = time lagged independent component analysis

## makefile includes (must remain after info)
include $(makedir)/projfuture.mk

## keep intermediate files
PRECIOUS += $(UNITVARDATA)

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST += $(TICADATA) $(foreach name, symmetrized_covariance_matrix\
	      lagged_covariance_matrix lagged_eigenvalues lagged_eigenvectors,\
	      $(addsuffix _dir/${name}.dat,${TICADATA})) $(UNITVARDATA)
