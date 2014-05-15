.PHONY: calc calc_hist1d calc_hist2d\
	plot plot_hist2d

calc: calc_hist1d calc_hist2d

plot: plot_hist2d

calc_hist1d: $$(HIST1D_DATA)
calc_hist2d: $$(HIST2D_DATA)

plot_hist2d: calc_hist2d $$(HIST2D_PLOT)

## default settings
HIST_NBINS ?= 100# number of bins within reference range
# default settings 1D histograms
HIST1D_LAST_COL ?= 20# last column (optional)
# default settings 2D histograms
HIST2D_LAST_COL ?= 3# last column (optional, >1)
HIST2D_REFDIR ?= $(prefix)/histogram# reference data is searched here

# settings/data to be shown by showconf/showdata
SHOWCONF += HIST_NBINS HIST2D_LAST_COL HIST2D_REFDIR\
	    HIST1D_LAST_COL
SHOWDATA += splitdir histdir1d histdir2d

## default settings that must be changed before including this file
histdir1d ?= histdata1d
histdir2d ?= histdata2d

## variables
HIST1D_DATA = $(addprefix $(histdir1d)/,$(call add-V01,${DATA},.hist,HIST1D))
HIST2D_DATA = $(addprefix $(histdir2d)/,$(call add-V01-V02,${DATA},.hist,HIST2D))
HIST2D_PLOT = $(addprefix hist2d_,$(call add-V01-V02,${DATA},.png,HIST2D))
DIR_LIST += $(histdir1d) $(histdir2d)

## rules
$(histdir1d) $(histdir2d):
	mkdir -p $@

# histogram calculation
# include also split.mk to split data
define template_calc1d
$(histdir1d)/$(1)-V$(2).hist : $$(MINMAXFILE) $(1)\
	| $$(histdir1d) $$(splitdir)/$(1)-01
	$$(SCR)/wrapper_histogram.sh $(1) $(2) "$$(strip $${MINMAXFILE})"\
		$$(splitdir) $$(@D) $$(HIST1D)
endef

define template_calc2d
$(histdir2d)/$(1)-V$(2)-V$(3).hist : $$(MINMAXFILE) $(1) | $$(histdir2d)
	$$(if $$(wildcard $${MINMAXFILE}),$$(if $$(shell\
		[ $$(shell $${NROWS} $$<) -eq 2 ] || echo false),\
		$$(error Error: »$${MINMAXFILE}« has wrong format)))
	cat $$+ | $$(HIST2D) -c $(2),$(3) -o $$@
endef

# histogram plotting
hist2d_%.pdf : $(histdir2d)/%.hist $(SCR)/wrapper_heatmap.sh
	@$(SCR)/wrapper_heatmap.sh $(HEATMAP) $(HIST2D_REFDIR) $< -o $@

## macros to be called later
MACROS += rule_histogram

FILEINFO_NAMES = HIST1D HIST2D
define rule_histogram
$(foreach file,${DATA},\
	$(foreach col,$(call range,${lastcol}),\
		$(eval $(call template_calc1d,${file},${col})))\
	$(foreach col2,$(call range,$(call getmin,${HIST2D_LAST_COL}\
		${lastcol})),$(foreach col1,$(call rangeto,${col2}),\
		$(eval $(call template_calc2d,${file},${col1},${col2})))))
endef

## info
ifndef INFO
INFO = calc calc_hist1d calc_hist2d plot plot_hist2d
INFO_calc        = calls the two targets below
INFO_calc_hist1d = calculate 1D histogram data
INFO_calc_hist2d = calculate 2D histogram data
INFO_plot = calls the two targets below
INFO_plot_hist2d = plot 2D histograms
define INFOADD

Histogram ranges are read from »$(MINMAXFILE)«. Reference files
to set color bar ranges are searched in »$(HIST2D_REFDIR)/«.

endef
else
INFOend +=
endif

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(HIST2D_PLOT)
CLEAN_LIST += */*.tmp[0-9]*[0-9]
PURGE_LIST += $(HIST1D_DATA) $(HIST2D_DATA)
