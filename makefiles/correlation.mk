.PHONY: calc plot estim calc_times plot_times plot_ratios plot_all
.calc: $$(CORR_DATA) $$(TIMES)
calc: estim
	@$(MAKE) .calc

plot: calc calc_times $$(CORR_PLOT) $$(TIMES_PLOT)

estim: $$(ESTIM_DATA)

calc_times: $$(TIMES)

plot_times: calc_times $$(TIME_PLOT)

plot_ratios: calc_times $$(RATIOS_PLOT)

plot_all: plot plot_times plot_ratios

## default settings
CORR_NBINS ?= 100# number of bins for binning on logarithmic scale
SPLIT_SUFFIX ?= $(DROPSUFFIX)# to find split data in remote directory
ESTIMLENGTH ?= 1000000# max correlation length for first estimate
RANGEFACTOR ?= 6# times correlation time for final data
CORR_LAST_COL ?= 18# last column (optional)
CORR_PLOT_NCOLS ?= 6# number of columns per plot
CORR_XRANGE ?= # xrange (optional, format: xmin:xmax)
CORR_MAXRATIO ?= # maximum ratio between correlation times (optional)
TIME_UNIT ?= # time unit to be shown in x label (optional)

# settings/data to be shown by showconf/showdata
SHOWCONF += CORR_NBINS CORR_LAST_COL CORR_PLOT_NCOLS CORR_XRANGE TIME_UNIT
SHOWDATA += fitdir cordir splitdir SPLIT_SUFFIX

## default settings that must be changed before including this file
fitdir ?= estimation
cordir ?= corrdata

## variables
DIR_LIST += $(fitdir) $(cordir)
# initial fit for correlation time estimation data
ESTIM_DATA = $(addprefix ${fitdir}/,$(call add-V01,${DATA},.fit,CORR))
DEL_FITCOR = $(addsuffix .*,${ESTIM_DATA})
# final time correlation data and plots
CORR_DATA = $(addprefix ${cordir}/,$(call add-V01,${DATA},.cor,CORR))
CORR_PLOT = $(foreach a,n e,$(call add_01,${DATA},.cor_,${a}.png,CORR))
TIMES = $(addsuffix .tau,${DATA})
TIMES_PLOT = $(addsuffix .png,${TIMES})
RATIOS_PLOT = $(addsuffix .ratios.png,${TIMES})
TIME_PLOT = $(addprefix ${cordir}/,$(call add-V01,${DATA},.png,CORR))

## rules
$(fitdir) $(cordir):
	mkdir -p $@

# initial fit for correlation time estimation
define template_estim
$(fitdir)/$(1)-V$(2).fit : $(1) | $$(fitdir)
	$$(SCR)/fit_corrtime.sh $(1) $(2) $$(fitdir) $$(strip $${IF_FUTURE})\
		$$(ESTIMLENGTH) $$(RANGEFACTOR) $$(CORR)
endef

%.tau.tex : %.tau $(SCR)/plot_corrtimes.gp $(SCR)/plot_corrtimes.sh
	$(SCR)/plot_corrtimes.sh $< "$(strip ${CORR_XRANGE})" $(TIME_UNIT)

# calculate final autocorrelation data
# include also split.mk to split data
define template_calc
$(cordir)/$(1)-V$(2).cor : $$(fitdir)/$(1)-V$(2).fit\
	$$(if $$(wildcard $${splitdir}),\
		$$(addprefix $(cordir)/$(1)-V$(2).cor,$$(call\
		splitnums,$${splitdir}/$(1)$$(SPLIT_SUFFIX))))\
	| $$(splitdir)/$(1)$$(SPLIT_SUFFIX)-01
	$$(SCR)/av_second_column.py $$(sort $$(filter $${cordir}%,$$+)) > $$@
$(cordir)/$(1)-V$(2).cor% : $$(fitdir)/$(1)-V$(2).fit\
	$$(splitdir)/$(1)$$(SPLIT_SUFFIX)-% | $$(cordir)
	$$(if $$(wildcard $$<),$$(eval corrlength := $$(call getmax,${CORR_NBINS}\
		$$(shell tail -n1 $$<))),$$(eval corrlength := <corrlength>))
	$$(CORR) -c$(2) -D$$(corrlength) $$(lastword $$+) \
		| $$(SCR)/logbinning.awk -vxmin=1 -vxmax=$$(corrlength)\
		-vbins=$$(CORR_NBINS) > $$@
endef

# calculate final crosscorrelation data
define template_calc_xcor
$(cordir)/$(1)-V$(2)-V$(3).xcor : $$(fitdir)/$(1)-V$(2).fit $$(fitdir)/$(1)-V$(3).fit\
	$$(if $$(wildcard $${splitdir}),\
		$$(addprefix $(cordir)/$(1)-V$(2)-V$(3).xcor,$$(call\
		splitnums,$${splitdir}/$(1)$$(SPLIT_SUFFIX))))\
	| $$(splitdir)/$(1)$$(SPLIT_SUFFIX)-01
	$$(SCR)/av_second_column.py $$(sort $$(filter $${cordir}%,$$+)) > $$@
$(cordir)/$(1)-V$(2)-V$(3).xcor% : $$(fitdir)/$(1)-V$(2).fit $$(fitdir)/$(1)-V$(3).fit\
	$$(splitdir)/$(1)$$(SPLIT_SUFFIX)-% | $$(cordir)
	$$(if $$(wildcard $$<),$$(eval corrlength := $$(call getmax,${CORR_NBINS}\
		$$(shell tail -n1 $$<) $$(shell tail -n1 $$(word 2,$$+)))),\
		$$(eval corrlength := <corrlength>))
	$$(XCOR) -c$(2),$(3) -D$$(corrlength) $$(lastword $$+) | grep -v '^-' \
		| $$(SCR)/logbinning.awk -vxmin=1 -vxmax=$$(corrlength)\
		-vbins=$$(CORR_NBINS) > $$@
endef

# calculate correlation times
define template_timeplot
$(cordir)/$(1)-V$(2).png : $$(cordir)/$(1)-V$(2).cor $(1).tau\
	$$(SCR)/plot_corrtime.gp | $$(cordir)
	$$(eval tau := $$(if $$(wildcard $$(word 2,$$+)),\
		$$(shell grep $$+ |cut -d\  -f2)))
	gnuplot -e 'FILE="$$(basename $$<)"; TAU=$$(tau)'\
		$$(SCR)/plot_corrtime.gp
endef

define template_tau
$(1).tau : $$(filter $$(cordir)/${1}-V%,$${CORR_DATA})
	$$(info Write estimated correlation times to $$@.)
	@$$(RM) $$@
	@for file in $$+; do times=$$$$($(SCR)/get_corrtime.awk $$$${file})\
		&& echo $$$${file}: $$$${times}; done\
		| sort -k2 -gr | tee -a $$@
endef

# plot ratios between correlation times
%.tau.ratios.tex : %.tau $(SCR)/plot_tau_ratios.gp
	$(ratios_command)

define ratios_command
gnuplot -e 'FILE="$<"'\
	$(if ${CORR_MAXRATIO},-e 'ymax=$(strip ${CORR_MAXRATIO})')\
	$(SCR)/plot_tau_ratios.gp
endef

# plot final autocorrelation data
define template_plot
$(1).cor_$(2)e.tex : $(1).cor_$(2)n.tex
$(1).cor_$(2)e.pdf : $(1).cor_$(2)n.pdf
$(1).cor_$(2)e.png : $(1).cor_$(2)n.png
$(1).cor_$(2)n.tex : $$(SCR)/plot_autocorr.py\
	$$(addprefix $${cordir}/,$$(call plot-V01,${1},${2},.cor,CORR))
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
		$(eval $(call template_estim,${file},${col}))\
		$(eval $(call template_calc,${file},${col}))\
		$(eval $(call template_timeplot,${file},${col})))\
	$(foreach N,$(call range,${lastplot}),\
		$(eval $(call template_plot,${file},${N})))\
	$(foreach col2,$(call range,$(call getmin,${CORR_LAST_COL}\
		${lastcol})),$(foreach col1,$(call rangeto,${col2}),\
		$(eval $(call template_calc_xcor,${file},${col1},${col2}))\
		$(eval $(call template_calc_xcor,${file},${col2},${col1})))))
endef

## info
ifndef INFO
INFO = estim calc calc_times plot plot_times plot_ratios plot_all del_estim
define INFOADD

Do not call targets calc or plot before estim is completed.
Do not call targets plot_* before calc is completed.
There are two possibilities to build all targets (-j optional):
  j=2; make -j$$j estim; make -j$$j calc; make -j$$j plot_all
  j=2; make -j$$j estim; make -j$$j plot; make -j$$j plot_all

Cross correlations:
There is no phony target to calculate cross correlations, but after target
»estim« has been called for the components in question, they are calculated
by calling »make corrdata/filename-V##-V##.xcor« (the order of ## matters).

endef
else
INFOend +=
endif
INFO_estim = estimate correlation times
INFO_calc       = calculate time correlation data
INFO_calc_times = (re)calculate correlation times
INFO_plot       = plot correlation functions and times
INFO_plot_times = plot correlation times in »$(cordir)«
INFO_plot_ratios = plot ratios between correlation times
INFO_plot_all   = call all plot targets
INFO_del_estim  = delete linear fit data and plots

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(TIMES_PLOT) $(RATIOS_PLOT) $(TIME_PLOT) $(CORR_PLOT)
CLEAN_LIST +=
PURGE_LIST += $(DEL_FITCOR) $(ESTIM_DATA) $(TIMES) $(CORR_DATA)\
	      $(addsuffix [0-9]*[0-9],${CORR_DATA})

.PHONY: del_estim
del_estim:
	$(if $(wildcard ${DEL_FITCOR}),$(RM) $(wildcard ${DEL_FITCOR}))
	$(if $(wildcard ${fitdir}),$(if $(shell\
		[ -d ${fitdir} ] && [ . != ${fitdir} ] && echo yes),\
		rmdir --ignore-fail-on-non-empty ${fitdir}))
