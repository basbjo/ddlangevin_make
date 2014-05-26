.PHONY: calc plot calc_times plot_times
calc: $$(CORR_DATA) calc_times

plot: calc plot_times $$(CORR_PLOT)

calc_times: $$(TAU_ESTIMATE)

plot_times: calc_times $$(TAU_PLOT)

## default settings
SPLIT_SUFFIX ?= $(DROPSUFFIX)# to find split data in remote directory
ESTIMLENGTH ?= 1000000# max correlation length for first estimate
RANGEFACTOR ?= 6# times correlation time for final data
CORR_LAST_COL ?= 18# last column (optional)
CORR_PLOT_NCOLS ?= 6# number of columns per plot
CORR_XRANGE ?= # xrange (optional, format: xmin:xmax)
TIME_UNIT ?=# time unit to be shown in x label

# settings/data to be shown by showconf/showdata
SHOWCONF += CORR_LAST_COL CORR_PLOT_NCOLS CORR_XRANGE TIME_UNIT
SHOWDATA += fitdir cordir SPLIT_SUFFIX

## default settings that must be changed before including this file
fitdir ?= estimation
cordir ?= corrdata

## variables
DIR_LIST += $(fitdir) $(cordir)
# initial fit for correlation time estimation data
ESTIM_DATA = $(addprefix ${fitdir}/,$(call add-V01,${DATA},.fit,CORR))
DEL_FITCOR = $(addsuffix .*,${ESTIM_DATA})
TAU_ESTIMATE = $(addsuffix .tau,${DATA})
TAU_PLOT = $(addsuffix .png,${TAU_ESTIMATE})
# final time correlation data and plots
CORR_DATA = $(addprefix ${cordir}/,$(call add-V01,${DATA},.cor,CORR))
CORR_PLOT = $(foreach a,n e,$(call add_01,${DATA},.cor_,${a}.png,CORR))

## rules
$(fitdir) $(cordir):
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

# calculate final autocorrelation data
# include also split.mk to split data
define template_calc
$(cordir)/$(1)-V$(2).cor : $$(fitdir)/$(1)-V$(2).fit\
	| $$(cordir) $$(splitdir)/$(1)$$(SPLIT_SUFFIX)-01
	$$(SCR)/wrapper_corr.sh $(1) $(2) $$(fitdir)\
		$$(splitdir)/$(1)$$(SPLIT_SUFFIX) $$(@D) $$(CORR)
endef

# plot final autocorrelation data
define template_plot
$(1).cor_$(2)e.tex : $(1).cor_$(2)n.tex
$(1).cor_$(2)n.tex : $$(SCR)/plot_autocorr.py\
	$$(filter $${cordir}/${1}%,$${CORR_DATA})
	$$(SCR)/plot_autocorr.py $(1) $$(cordir)\
		$$(strip $${CORR_PLOT_NCOLS}) $(2) $$(NCOLS_${1}_CORR)\
		"$$(strip $${CORR_XRANGE})" $(TIME_UNIT)
endef

## macros to be called later
MACROS += rule_correlation

FILEINFO_NAMES = CORR
FILEINFO_PLOTS = CORR
define rule_correlation
$(foreach file,${DATA},\
	$(eval $(call template_tau,${file}))\
	$(foreach col,$(call range,${lastcol}),\
		$(eval $(call template_estim,${file},${col})))\
	$(foreach col,$(call range,${lastcol}),\
		$(eval $(call template_calc,${file},${col})))\
	$(foreach N,$(call range,${lastplot}),\
		$(eval $(call template_plot,${file},${N}))))
endef

## info
ifndef INFO
INFO = calc_times calc plot_times plot del_estim
define INFOADD
endef
else
INFOend +=
endif
INFO_calc_times = estimate correlation times
INFO_calc       = calculate time correlation data
INFO_plot_times = plot correlation times
INFO_plot       = plot time correlation data
INFO_del_estim  = delete linear fit data and plots

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(TAU_PLOT) $(CORR_PLOT)
CLEAN_LIST += */*.tmp[0-9]*[0-9]
PURGE_LIST += $(DEL_FITCOR) $(ESTIM_DATA) $(TAU_ESTIMATE) $(CORR_DATA)

.PHONY: del_estim
del_estim:
	$(if $(wildcard ${DEL_FITCOR}),$(RM) $(wildcard ${DEL_FITCOR}))
	$(if $(wildcard ${fitdir}),$(if $(shell\
		[ -d ${fitdir} ] && [ . != ${fitdir} ] && echo yes),\
		rmdir --ignore-fail-on-non-empty ${fitdir}))
