.PHONY: showfields

## default settings
HIST_NBINS ?= 100# number of bins within reference range (histogram)
BIN1D_NBINS ?= 100# number of bins per dimension (1D binning)
BIN2D_NBINS ?= 80# number of bins per dimension (2D binning)
HEATMAP_FLAGS ?=# additional options to heatmap script

# settings/data to be shown by showconf/showdata
SHOWCONF += HIST_NBINS BIN1D_NBINS BIN2D_NBINS HEATMAP_FLAGS
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
head $(1) | grep '^#x1' | sed 's/ [01]$$//' \
	| tr ' ' '\n' | sed 's/^#//' \
	| nl -ba -s\  | sed 's/^  *//'
endef

# field binning
getfieldno_macro = $(showfields_macro) | grep $(2) | cut -d\  -f1

define template_histogram
$(1).%.hist : $(1) $(wildcard ${1}.minmax)
	$$(eval cols := $$(foreach label,$$(subst ., ,$$*),\
		$$(shell $$(call getfieldno_macro,${1},$${label}))))
	$$(eval minmaxfile := $$(word 2,$$+))
	$$(if $$(patsubst 1,,$$(words $${cols}))\
		,,${HIST1D})$$(if $$(patsubst 2,,$$(words $${cols}))\
		,,${HIST2D}) -c $$(shell echo $${cols}|tr ' ' ',')\
		$$(if $$(minmaxfile),-r $$(minmaxfile) )$$< -o $$@
endef

define template_binning
$(1).x% : $(1)
	$$(eval cols := $$(foreach label,$$(subst ., ,x$$*),\
		$$(shell $$(call getfieldno_macro,${1},$${label}))))
	$$(if $$(patsubst 2,,$$(words $${cols}))\
		,,${BINNING1D})$$(if $$(patsubst 3,,$$(words $${cols}))\
		,,${BINNING2D}) -c $$(shell echo $${cols}|tr ' ' ',') $$< -o $$@
endef

# plotting
%.hist.pdf: %.hist
	$(HEATMAP) -c1,2,3 -t "Histogram for $*" $< -o $@

%.pdf: %
	$(HEATMAP) -c1,2,3 -t "Binned field for $*" $< -o $@

## macros to be called later
MACROS += rule_fields

define rule_fields
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
To calculate field binnings of a »file« use the labels that are shown
by target »showfields«, e.g. »make file.x1.f1« or »make file.x1.x2.f2«.

*After* the file with binned data has been created, plots of fields in two
dimensions can be plotted first to pdf, e.g. »make file.x1.x2.f2.pdf« and
*afterwards* be converted to png, e.g. »make file.x1.x2.f2.png«.

Histogram
=========
To calculate field binnings of a »file« use the labels that are shown
by target »showfields«, e.g. »make file.x1.hist« or »make file.f2.hist«.
If »file.minmax« exists it is used to set the histogram reference range.
Plots of 2D histograms are created as described above for binning.

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
