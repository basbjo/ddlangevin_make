.PHONY: calc\
	plot plot_drift2d plot_all
calc: $$(DRIFT_DATA)

plot: plot_drift2d

plot_all: plot

plot_drift2d: calc $$(DRIFT2D_PLOT)

## default settings
DRIFT_LAST_COL ?= 2# last column (optional)
DRIFT_REFDIR ?= $(prefix)/drift# reference data is searched here (optional)

# settings/data to be shown by showconf/showdata
SHOWCONF += DRIFT_LAST_COL DRIFT_REFDIR
SHOWDATA +=

## default settings that must be changed before including this file
driftdir ?= driftdata

## variables
DIR_LIST += $(driftdir)
DRIFT_DATA = $(addprefix $(driftdir)/,$(call add-V01-V02,\
	     ${DATA},.2ddrifthist,DRIFT))
DRIFT2D_PLOT = $(addprefix drift2d_,$(call add-V01-V02,${DATA},.png,DRIFT))

## rules
$(driftdir):
	mkdir -p $@

# drift field calculation
define template_calc
$(driftdir)/$(1)-V$(2)-V$(3).2ddrifthist : $$(MINMAXFILE) $(1) | $$(driftdir)
	$$(SCR)/calc_drift.sh $(1) $(2) $(3) "$$(strip $${MINMAXFILE})"\
		$$(driftdir) $$(strip $${IF_FUTURE}) $$(strip $${TIME_UNIT})
endef

# drift field plotting
drift2d_%.tex : $(driftdir)/%.2ddrifthist $(SCR)/plot_drift2d.gp
	$(if ${DRIFT_REFDIR},$(eval reffile := $(shell\
		${SCR}/reffile_search.sh ${DRIFT_REFDIR} $< ${TIME_UNIT})))
	$(if ${reffile},,$(eval reffile := $(wildcard $<)))
	$(info # determine arrow stddev from ${reffile})
	$(if ${reffile},$(eval std = $(shell python -c "import numpy as np;\
		x, y = np.loadtxt('${reffile}', usecols=(2,3), unpack=True);\
		print(np.std(np.sqrt(x**2+y**2)))")),$(eval std = <stddev>))
	gnuplot -e "dir='$(driftdir)';name='$*';std=$(std)" $(SCR)/plot_drift2d.gp

## macros to be called later
MACROS += rule_drift

FILEINFO_NAMES = DRIFT
define rule_drift
$(foreach file,${DATA},\
	$(foreach col2,$(call range,$(call getmin,${DRIFT_LAST_COL}\
		${lastcol})),$(foreach col1,$(call rangeto,${col2}),\
		$(eval $(call template_calc,${file},${col1},${col2})))))
endef

## info
ifndef INFO
INFO = calc plot plot_drift2d
INFO_calc = calculate drift fields
INFO_plot = calls the plot targets below
INFO_plot_drift2d = plot 2d drift fields
define INFOADD

Reference binning ranges are read from »$(MINMAXFILE)«.
Reference files are searched in »$(DRIFT_REFDIR)/«. Their
variances are used to set the scale of arrow lengths.

There are 2d drift field plots with all arrows in »$(driftdir)«
while very long arrows are omitted in this directory.

endef
else
INFOend +=
endif

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(DRIFT2D_PLOT) $(addprefix ${driftdir}/,${DRIFT2D_PLOT})
CLEAN_LIST += $(DRIFT_DATA) $(patsubst %.2ddrifthist,%.1ddrifthist,${DRIFT_DATA})
PURGE_LIST +=
