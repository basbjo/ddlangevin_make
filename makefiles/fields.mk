.PHONY: showfields

## default settings
HIST_NBINS ?= 100# number of bins within reference range (histogram)
BIN1D_NBINS ?= 100# number of bins per dimension (1D binning)
BIN2D_NBINS ?= 80# number of bins per dimension (2D binning)
HEATMAP_FLAGS ?=# additional options to heatmap script
MINMAX_FLAG ?=-R# full output: -r, output only for reference range: -R

# settings/data to be shown by showconf/showdata
SHOWCONF += HIST_NBINS BIN1D_NBINS BIN2D_NBINS MINMAX_FLAG HEATMAP_FLAGS
SHOWDATA +=

## default settings that must be changed before including this file

## variables

## rules
# field labels and column numbers
showfields:
	@echo; $(foreach file,${DATA},echo "${file}";\
		echo ${file} | sed 's/./=/g';\
		$(call showfields_macro,${file}); echo;)

define showfields_macro
head $(1) | sed '/^#Content: /s//#/' | grep '^#x1' | sed 's/ [01]$$//' \
	| tr ' ' '\n' | sed 's/^#//' \
	| nl -ba -s\  | sed 's/^  *//'
endef

# field binning
getfieldno_macro = $(showfields_macro) | grep $(2) | cut -d\  -f1

comma = ,
define special_binning_ranges
$(if $(filter xi%,$*),-S-5$(comma)5 )
endef

define template_histogram
$(1).%.hist : $(1) $(wildcard ${1}.minmax)
	$$(eval cols := $$(foreach label,$$(subst ., ,$$*),\
		$$(shell $$(call getfieldno_macro,${1},$${label}))))
	$$(eval minmaxfile := $$(word 2,$$+))
	$$(if $$(patsubst 1,,$$(words $${cols}))\
		,,${HIST1D})$$(if $$(patsubst 2,,$$(words $${cols}))\
		,,${HIST2D}) -c $$(shell echo $${cols}|tr ' ' ',')\
		$$(if $$(minmaxfile),$$(MINMAX_FLAG) $$(minmaxfile)\
		)$$(special_binning_ranges)$$< -o $$@
endef

define template_binning
$(1).%.bins : $(1) $(wildcard ${1}.minmax)
	$$(eval cols := $$(foreach label,$$(subst ., ,$$*),\
		$$(shell $$(call getfieldno_macro,${1},$${label}))))
	$$(if $$(patsubst 2,,$$(words $${cols}))\
		,,${BINNING1D})$$(if $$(patsubst 3,,$$(words $${cols}))\
		,,${BINNING2D}) -c $$(shell echo $${cols}|tr ' ' ',')\
		$$(if $$(minmaxfile),$$(MINMAX_FLAG) $$(minmaxfile)\
		)$$< -o $$@
endef

# plotting
%.hist.pdf: %.hist
	$(HEATMAP) -c1,2,3 -t "Histogram for $*" $< -o $@

%.bins.pdf: %.bins
	$(HEATMAP) -c1,2,3 -t "Binned field for $*" $< -o $@

define template_plot_noise
$(1).xi%.hist.tex : $(1).xi%.hist
	gnuplot -e "set terminal tikz standalone tightboundingbox;\
	set output '$$@'; set title 'Noise histogram for \\verb|$(1)|';\
	set key spacing 2; plot exp(-x**2/2)/sqrt(2*pi) \
		title '\$$$$\\frac{1}{\\sqrt{2\\pi}}e^{-\\frac{x^2}{2}}$$$$',\
		'$$<' title '$$$$\\xi_$$*$$$$'"
endef

## macros to be called later
MACROS += rule_fields

define rule_fields
$(foreach file,$(filter %.ltm,${DATA}),\
       $(eval $(call template_plot_noise,${file})))\
$(foreach file,$(filter %.ltm,${DATA}) $(filter-out %.ltm,${DATA}),\
	$(eval $(call template_histogram,${file}))\
	$(eval $(call template_binning,${file})))
endef

## info
ifndef INFO
INFO = showfields
define INFOADD

Binning
=======
To calculate field binnings of a »file« use the labels as shown by target
»showfields«, e.g. »make file.x1.f1.bins« or »make file.x1.x2.f2.bins«.

To create heatmap plots of fields in two dimensions as pdf and png file and
keep intermediate files, e.g. call »make file.x1.x2.f2.bins{,.{pdf,png}}«.

Histogram
=========
To calculate field histograms of a »file« use the labels that are shown by
target »showfields«, e.g. »make file.f2.hist« or »make file.x1.x2.hist«.
If »file.minmax« exists it is used to set the histogram reference range.
Plots of 2D histograms are created as described above for binning.

Noise histograms »name.ltm.xi#.hist« are treated specially: the range is
set to [-5:5] and the creation of an intermediate tex file should be forced
by calling »make name.ltm.xi#.hist{,.{tex,pdf,png}}« for meaningful plots.

endef
else
INFOend +=
endif
INFO_showfields = show column numbers with field labels

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST +=
