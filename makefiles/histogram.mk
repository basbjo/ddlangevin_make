.PHONY: calc calc_hist1d calc_hist2d calc_fel1d\
	plot plot_hist1d plot_hist2d plot_all

calc: calc_hist1d calc_hist2d

plot: calc plot_hist1d plot_hist2d

plot_all: plot

calc_hist1d: $$(HIST1D_DATA)
calc_hist2d: $$(HIST2D_DATA)

calc_fel1d: calc_hist1d $$(FEL1D_DATA)

plot_hist1d: calc_fel1d $$(HIST1D_PLOT)
plot_hist2d: calc_hist2d $$(HIST2D_PLOT)

## default settings
HIST1D_NBINS ?= 100# number of bins within reference range (1D histogram)
HIST2D_NBINS ?= 100# number of bins within reference range (2D histogram)
SPLIT_SUFFIX ?= $(DROPSUFFIX)# to find split data in remote directory
# default settings 1D histograms
HIST1D_LAST_COL ?= 20# last column (optional)
HIST1D_PLOT_NCOLS ?= 4# number of columns per plot
HIST1D_YRANGE ?= # yrange (optional, format: ymin:ymax)
KTFACTOR ?= 1# factor for temperature rescaling
HIST1D_REFDIR ?= $(prefix)/histogram# reference data is searched here (optional)
# default settings 2D histograms
HIST2D_LAST_COL ?= 3# last column (optional, >1)
HIST2D_REFDIR ?= $(prefix)/histogram# reference data is searched here (optional)
TIME_UNIT ?=# to find reference data with different time step

# settings/data to be shown by showconf/showdata
SHOWCONF += HIST2D_NBINS HIST2D_LAST_COL HIST2D_REFDIR\
	    HIST1D_NBINS HIST1D_LAST_COL HIST1D_REFDIR\
	    HIST1D_PLOT_NCOLS HIST1D_YRANGE TIME_UNIT
SHOWDATA += histdir1d histdir2d splitdir SPLIT_SUFFIX

## default settings that must be changed before including this file
histdir1d ?= histdata1d
histdir2d ?= histdata2d

## variables
HIST1D_DATA = $(addprefix $(histdir1d)/,$(call add-V01,${DATA},.hist,HIST1D))
FEL1D_DATA = $(addprefix $(histdir1d)/,$(call add-V01,${DATA},.fel1d,HIST1D))
HIST1D_PLOT = $(foreach a,n e,$(call add_01,${DATA},.fel1d_,${a}.png,HIST1D))
HIST2D_DATA = $(addprefix $(histdir2d)/,$(call add-V01-V02,${DATA},.hist,HIST2D))
HIST2D_PLOT = $(addprefix hist2d_,$(call add-V01-V02,${DATA},.png,HIST2D))
DIR_LIST += $(histdir1d) $(histdir2d)

## rules
$(histdir1d) $(histdir2d):
	mkdir -p $@

# histogram calculation
# include also split.mk to split data
define template_calc1d
$(histdir1d)/$(1)-V$(2).hist : $$(MINMAXFILE) $$(if $$(wildcard $${splitdir}),\
		$$(addprefix $(histdir1d)/$(1)-V$(2).hist,$$(call\
		splitnums,$${splitdir}/$(1)$$(SPLIT_SUFFIX))))\
	| $$(splitdir)/$(1)$$(SPLIT_SUFFIX)-01
	$$(SCR)/av_second_column.py $$(sort $$(filter $${histdir1d}%,$$+)) > $$@
$(histdir1d)/$(1)-V$(2).hist% : $$(MINMAXFILE)\
	$$(splitdir)/$(1)$$(SPLIT_SUFFIX)-% | $$(histdir1d)
	$$(HIST1D) -c $(2) $$(if $${MINMAXFILE},-r )$$+ -o $$@
endef

define template_calc2d
$(histdir2d)/$(1)-V$(2)-V$(3).hist : $$(MINMAXFILE) $(1) | $$(histdir2d)
	$$(HIST2D) -c $(2),$(3) $$(if $${MINMAXFILE},-r )$$+ -o $$@
endef

$(histdir1d)/%.fel1d : $(histdir1d)/%.hist $$(MINMAXFILE)
	$(calc_fel1d_command)

define calc_fel1d_command
$(SCR)/calc_fel1d.py $< "$(strip ${KTFACTOR})" > $@
endef

# histogram plotting
define template_plot1d
$(if ${HIST1D_REFDIR},$(eval reffile := $(shell\
	${SCR}/reffile_search.sh ${HIST1D_REFDIR} $(1) ${TIME_UNIT})))
$(1).fel1d_$(2)e.tex : $(1).fel1d_$(2)n.tex
$(1).fel1d_$(2)e.pdf : $(1).fel1d_$(2)n.pdf
$(1).fel1d_$(2)e.png : $(1).fel1d_$(2)n.png
$(1).fel1d_$(2)n.tex : $$(SCR)/plot_fel1d.py\
	$$(addprefix $${histdir1d}/,$$(call plot-V01,${1},${2},.fel1d,HIST1D))
	$$(SCR)/plot_fel1d.py $(1) $$(histdir1d)\
		$$(strip $${HIST1D_PLOT_NCOLS}) $(2) $$(NCOLS_${1}_HIST1D)\
		"$(reffile)" "$$(strip $${HIST1D_YRANGE})"
endef

hist2d_%.pdf : $(histdir2d)/%.hist $$(MINMAXFILE)
	$(heatmap_command)

define heatmap_command
$(if ${HIST2D_REFDIR},$(eval reffile := $(shell\
	${SCR}/reffile_search.sh ${HIST2D_REFDIR} $< ${TIME_UNIT})))
$(HEATMAP) $< -o $@ -t "2D FEL for $*"\
	$(if ${reffile},--ref ${reffile})
endef

## macros to be called later
MACROS += rule_histogram

FILEINFO_NAMES = HIST1D HIST2D
FILEINFO_PLOTS = HIST1D
define rule_histogram
$(foreach file,${DATA},\
	$(foreach col,$(call range,${lastcol}),\
		$(eval $(call template_calc1d,${file},${col})))\
	$(foreach N,$(call range,${lastplot}),\
		$(eval $(call template_plot1d,${file},${N})))\
	$(foreach col2,$(call range,$(call getmin,${HIST2D_LAST_COL}\
		${lastcol})),$(foreach col1,$(call rangeto,${col2}),\
		$(eval $(call template_calc2d,${file},${col1},${col2})))))
endef

## info
ifndef INFO
INFO = calc calc_hist1d calc_hist2d calc_fel1d plot plot_hist1d plot_hist2d
INFO_calc        = calls the two targets below
INFO_calc_hist1d = calculate 1D histogram data
INFO_calc_hist2d = calculate 2D histogram data
INFO_calc_fel1d  = calculate 1D free energy landscape
INFO_plot = calls the two targets below
INFO_plot_hist1d = plot 1D free energy landscape
INFO_plot_hist2d = plot 2D histograms
define INFOADD

Reference binning ranges are read from »$(MINMAXFILE)«.
Reference files for 1D histogram x-range are searched in »$(HIST1D_REFDIR)«.
Reference files for 2D histogram color bar are searched in »$(HIST2D_REFDIR)«.
If the strings above are empty, reference files are not used.

endef
else
INFOend +=
endif

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(HIST1D_PLOT) $(HIST2D_PLOT)
CLEAN_LIST +=
PURGE_LIST += $(HIST1D_DATA) $(HIST2D_DATA) $(FEL1D_DATA)\
	      $(addsuffix [0-9]*[0-9],${HIST1D_DATA})
