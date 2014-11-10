.PHONY: tica
tica: $$(TICADATA)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA += TICADATA

## default settings that must be changed before including this file

## variables
# projected data from time lagged independent component analysis
TICADATA += $(foreach lt,${LAG_TIMES},$(addsuffix .lag${lt}.tica,${COSSINDATA}))
DIR_LIST += $(addsuffix _dir,${TICADATA})
# suffix for projected data that is further analysed
PROJSUFFIX = .cs.lag*.tica
PROJDROPSUFFIX =# drop this suffix in subdirs
# minima and maxima as reference for ranges
MINMAXALL = $(TICADATA)

## rules
define template_tica
%.cs.lag$(1).tica_dir/time_independent_components.dat : %.cs
	# perform time lagged independent component analysis on $$<\
		(lag time $(1) frames)
	mkdir -p $$(@D)
	$$(if $$(shell [ $${IF_FUTURE} -eq 0 ] && echo yes)\
	  ,cd $$(@D) && $$(DELAYPCA) --trajectory ../$$< --lagtime $(1) --tica\
	  ,cd $$(@D) && awk '{print $$$$NF}' ../$$* | paste -d\  ../$$< - \
		  | $$(DELAYPCA) --break --lagtime $(1) --tica)
	$(RM) $$(@D)/principal_components.dat
%.cs.lag$(1).tica :\
	%.cs.lag$(1).tica_dir/time_independent_components.dat
	$$(appendlastcol_command)
endef

define rule_tica
$(foreach lag_time,${LAG_TIMES},$(eval $(call template_tica,${lag_time})))
endef

## macros to be called later
MACROS += rule_tica

## info
ifndef INFO
INFO = cossin tica clean
INFO_tica   = time lagged independent component analysis
INFO_clean  = delete cos-/sin-transformed data
define INFOADD
endef
else
INFOend +=
endif

## makefile includes (must remain after info)
include $(makedir)/cossin.mk
include $(makedir)/projfuture.mk

## keep intermediate files
PRECIOUS += $(COSSINDATA)

## clean
PLOTS_LIST +=
CLEAN_LIST += $(COSSINDATA)
PURGE_LIST += $(TICADATA) $(foreach name,lagged_covariance_matrix_tica\
	      pca_eigenvalues pca_eigenvectors tica_eigenvalues\
	      tica_eigenvectors symmetrized_covariance_matrix_tica,\
	      $(addsuffix _dir/${name}.dat,${TICADATA}))
