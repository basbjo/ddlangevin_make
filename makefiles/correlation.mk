.PHONY: calc_times plot_times

calc_times: $$(TAU_ESTIMATE)

plot_times: calc_times $$(TAU_PLOT)

## default settings
ESTIMLENGTH ?= 1000000# max correlation length for first estimate
RANGEFACTOR ?= 6# times correlation time for final data
CORR_LAST_COL ?= 18# last column (optional)
CORR_XRANGE ?= # xrange (optional, format: xmin:xmax)
TIME_UNIT ?=# time unit to be shown in x label

# settings/data to be shown by showconf/showdata
SHOWCONF += CORR_LAST_COL CORR_XRANGE TIME_UNIT
SHOWDATA += fitdir

## default settings that must be changed before including this file
fitdir ?= estimation

## variables
DIR_LIST += $(fitdir)
# initial fit for correlation time estimation data
ESTIM_DATA = $(addprefix ${fitdir}/,$(call add-V01,${DATA},.fit,CORR))
DEL_FITCOR = $(addsuffix .*,${ESTIM_DATA})
TAU_ESTIMATE = $(addsuffix .tau,${DATA})
TAU_PLOT = $(addsuffix .png,${TAU_ESTIMATE})

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

%.tau.tex : %.tau
	$(SCR)/plot_corrtime.sh $< "$(strip ${CORR_XRANGE})" $(TIME_UNIT)

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
INFO = calc_times plot_times del_estim
define INFOADD
endef
else
INFOend +=
endif
INFO_calc_times = estimate correlation times
INFO_plot_times = plot correlation times
INFO_del_estim  = delete linear fit data and plots

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(TAU_PLOT)
CLEAN_LIST +=
PURGE_LIST += $(DEL_FITCOR) $(ESTIM_DATA) $(TAU_ESTIMATE)

.PHONY: del_estim
del_estim:
	$(if $(wildcard ${DEL_FITCOR}),$(RM) $(wildcard ${DEL_FITCOR}))
	$(if $(wildcard ${fitdir}),$(if $(shell\
		[ -d ${fitdir} ] && [ . != ${fitdir} ] && echo yes),\
		rmdir --ignore-fail-on-non-empty ${fitdir}))
