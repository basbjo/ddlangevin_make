.PHONY: showfields average calc plot
average: $$(AVERAGES)

calc: $$(CALC)

plot: calc $$(PLOT)

## default settings
HIST1D_NBINS ?= 100# number of bins within reference range (1D histogram)
HIST2D_NBINS ?= 100# number of bins within reference range (2D histogram)
BIN1D_NBINS ?= 100# number of bins per dimension (1D binning)
BIN2D_NBINS ?= 80# number of bins per dimension (2D binning)
CROP_1DBINNING_RANGE ?=# crop output range of binned data (1D binning)
HEATMAP_HIST_COLS ?= -c1,2,5# columns to plot (2D histogram)
HEATMAP_BINS_COLS ?= -c1,2,3# columns to plot (2D binning)
HEATMAP_FLAGS ?=# additional options to heatmap script
MINMAX_FLAG ?= -R# full output: -r, output only for reference range: -R

# settings/data to be shown by showconf/showdata
SHOWCONF += HIST1D_NBINS HIST2D_NBINS BIN1D_NBINS BIN2D_NBINS MINMAX_FLAG\
	    HEATMAP_HIST_COLS HEATMAP_BINS_COLS HEATMAP_FLAGS\
	    CROP_1DBINNING_RANGE
SHOWDATA +=

## default settings that must be changed before including this file

## variables
BINNING1D += $(CROP_1DBINNING_RANGE)
GPMODEL = $(prefix)/model$(example_suffix).gp
AVERAGES += $(addsuffix .mean,${DATA})

## rules
# field labels and column numbers
showfields:
	@echo; $(foreach file,${DATA},echo "${file}";\
		echo ${file} | sed 's/./=/g';\
		$(call shownumberedfields_macro,${file}); echo;)

define showfields_macro
head $(1) | sed '/^#Content: /s//#/' | grep '^#x1' | sed 's/ [01]$$//' \
	| tr ' ' '\n' | sed 's/^#//'
endef

shownumberedfields_macro = $(showfields_macro) | nl -ba -s\  | sed 's/^  *//'

alllabels = $(sort $(foreach file,$(wildcard ${DATA}),\
	    $(shell $(call showfields_macro,${file}))))

# field averages
%.ltm.mean : %.ltm $(SCR)/average_ltm.awk
	$(average_command)

define average_command
$(lastword $+)$(if ${CROP_1DBINNING_RANGE},\
-vxmin=$(shell echo ${CROP_1DBINNING_RANGE} | cut -d',' -f1 | sed 's/-S//')\
-vxmax=$(shell echo ${CROP_1DBINNING_RANGE} | cut -d',' -f2)\
, )$< > $@
endef

# field binning
getfieldno_macro = $(shownumberedfields_macro) | grep $(2) | cut -d\  -f1

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
	$$(eval minmaxfile := $$(word 2,$$+))
	$$(if $$(patsubst 2,,$$(words $${cols}))\
		,,${BINNING1D})$$(if $$(patsubst 3,,$$(words $${cols}))\
		,,${BINNING2D}) -c $$(shell echo $${cols}|tr ' ' ',')\
		$$(if $$(minmaxfile),$$(MINMAX_FLAG) $$(minmaxfile)\
		)$$< -o $$@
endef

# plotting
%.hist.pdf: %.hist
	$(HEATMAP) $(HEATMAP_HIST_COLS) -t "Histogram for $*" $< -o $@

%.bins.pdf: %.bins
	$(HEATMAP) $(HEATMAP_BINS_COLS) -t "Binned field for $*" $< -o $@

define template_plot_noisehist
$(1).xi%.hist.tex : $(1).xi%.hist
	gnuplot -e 'set terminal tikz standalone tightboundingbox;\
	set output "$$@"; set title "Noise histogram for\n\\verb|$(1)|";\
	set key spacing 2; set ytics 0,0.1; plot exp(-x**2/2)/sqrt(2*pi) \
		title "\$$$$\\frac{1}{\\sqrt{2\\pi}}e^{-\\frac{x^2}{2}}$$$$",\
		"$$<" title "$$$$\\xi_$$*$$$$"'
endef

define template_plot_noisebins
$(1).$(2).xi%.bins.tex : $(1).$(2).xi%.bins
	gnuplot -e 'set terminal tikz standalone tightboundingbox;\
	set output "$$@"; set title "Noise projection for\n\\verb|$(1).$(2).xi$$*|";\
	set key Left reverse horizontal; set ytics -0.5,0.5; set mytics 5;\
	set grid; set grid mytics; plot [][-0.2:1.5] \
	"$$<" u 1:($$$$3*sqrt($$$$4)) title "Standard deviation",\
	"$$<" u 1:2:3 w e title "Average", 0 lt -1 notitle, 1 lt -1 notitle'
endef

define plot_command_one_file
gnuplot -e 'DATA="$<"; LABEL="$*"; gpmodel="$(word 2,$+)"' $(lastword $+)
endef

define plot_command_two_files
gnuplot -e 'DATA1="$<"; DATA2="$(word 2,$+)"; LABEL="$*"; OUTFILE="$@";\
	gpmodel="$(word 3,$+)"' $(lastword $+)
endef

%.x1.f1.bins.tex: %.x1.f1.bins $(GPMODEL) $(SCR)/plot_field_f.gp
	$(plot_command_one_file)

%.x1.g_1_1.bins.tex: %.x1.g_1_1.bins $(GPMODEL) $(SCR)/plot_field_g.gp
	$(plot_command_one_file)

%.x1.g_1_1xxi1.tex: %.x1.g_1_1.bins %.x1.xi1.bins $(GPMODEL) $(SCR)/plot_field_gxxi.gp
	$(plot_command_two_files)

%.x1.K_1_1.bins.tex: %.x1.K_1_1.bins $(GPMODEL) $(SCR)/plot_field_k.gp
	$(plot_command_one_file)

%.x1.K_1_1xxi1.tex: %.x1.K_1_1.bins %.x1.xi1.bins $(GPMODEL) $(SCR)/plot_field_kxxi.gp
	$(plot_command_two_files)

%.x1.distance.bins.tex: %.x1.distance.bins %.x1.abs_ecc.bins $(GPMODEL) $(SCR)/plot_field_distance.gp
	$(plot_command_two_files)

%.x1.var_ratio_fut.bins.tex: %.x1.var_ratio_fut.bins $(GPMODEL) $(SCR)/plot_field_var_ratio_fut.gp
	$(plot_command_one_file)

%.x1.var_ratio_past.bins.tex: %.x1.var_ratio_past.bins $(GPMODEL) $(SCR)/plot_field_var_ratio_past.gp
	$(plot_command_one_file)

%.x1.sweights.bins.tex: %.x1.sweights.bins $(GPMODEL) $(SCR)/plot_field_sweights.gp
	$(plot_command_one_file)

## macros to be called later
MACROS += rule_fields

define rule_fields
$(foreach file,$(filter %.ltm,${DATA}),\
	$(eval $(call template_plot_noisehist,${file}))\
	$(foreach xlabel,$(filter-out xi%,$(filter x%,${alllabels})),\
		$(eval $(call template_plot_noisebins,${file},${xlabel}))))\
$(foreach file,$(filter %.ltm,${DATA}) $(filter-out %.ltm,${DATA}),\
	$(eval $(call template_histogram,${file}))\
	$(eval $(call template_binning,${file})))
endef

## info
ifndef INFO
INFO = showfields average calc plot
define INFOADD

Averages
========
Field averages are calculated within »CROP_1DBINNING_RANGE«.

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

Average and standard deviation of projected noise components are created
by calling »make name.ltm.x#.xi#.bins{,.{tex,pdf,png}}«.

endef
else
INFOend +=
endif
INFO_showfields = show column numbers with field labels
INFO_average = average all fields within specified range
INFO_calc = create targets in CALC list (see Makefile)
INFO_plot = create targets in PLOT list (see Makefile)

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(PLOT)
CLEAN_LIST +=
PURGE_LIST += $(AVERAGES) $(CALC) $(ALL)
