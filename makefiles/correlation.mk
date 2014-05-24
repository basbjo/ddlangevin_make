.PHONY: calc_times
calc_times: $$(TAU_ESTIMATE)

## default settings
ESTIMLENGTH ?= 1000000# max correlation length for first estimate
RANGEFACTOR ?= 6# times correlation time for final data
CORR_LAST_COL ?= 18# last column (optional)

# settings/data to be shown by showconf/showdata
SHOWCONF += CORR_LAST_COL
SHOWDATA += fitdir

## default settings that must be changed before including this file
fitdir ?= estimation

## variables
DIR_LIST += $(fitdir)
# initial fit for correlation time estimation data
ESTIM_DATA = $(addprefix ${fitdir}/,$(call add-V01,${DATA},.fit,CORR))
TAU_ESTIMATE = $(addsuffix .tau,${DATA})

## rules
$(fitdir):
	mkdir -p $@

# initial fit for correlation time estimation
define template_estim
$(fitdir)/$(1)-V$(2).fit : $(1) | $$(fitdir)
	$$(SCR)/fit_corrtime.sh $(1) $(2) $$(fitdir) $$(strip $${IF_FUTURE})\
		$$(ESTIMLENGTH) $$(RANGEFACTOR) $$(CORR)
endef

define template_tau
$(1).tau : $$(filter $$(fitdir)/${1}%,$${ESTIM_DATA})
	$$(info Write summary of estimated correlation times to $$@.)
	@for file in $$(fitdir)/$(1)-V[0-9]*[0-9].fit; do \
		grep -H 'tau *=' $$$${file} | tail -n1 \
		  | sed 's/:/& /;s/  */ /g' >> $$@.tmp; done
	@$$(NROWS) $$(fitdir)/$(1)-V[0-9]*[0-9].fit.cor \
	     | awk '{if ($$$$1>2) print $$$$1-1}' \
	     | paste -d\  $$@.tmp - > $$@ && $$(RM) $$@.tmp
endef

## macros to be called later
MACROS += rule_correlation

FILEINFO_NAMES = CORR
define rule_correlation
$(foreach file,${DATA},\
	$(eval $(call template_tau,${file}))\
	$(foreach col,$(call range,${lastcol}),\
		$(eval $(call template_estim,${file},${col})))\
)
endef

FILEINFO_NAMES = CORR

## info
ifndef INFO
INFO = calc_times
define INFOADD
endef
else
INFOend +=
endif
INFO_calc_times = estimate correlation times

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST += $(ESTIM_DATA) $(TAU_ESTIMATE)
