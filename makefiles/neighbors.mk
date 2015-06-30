.PHONY: calc plot plot2d plot_all
calc: $$(NEIGHBORHOODS)

plot: calc $$(NH_PLOTS)

plot2d: calc plot $$(HIST2D)

plot_all: plot plot2d

## default settings
HIST2D_REFDIR ?= $(prefix)/histogram/histdata2d# histogram data is searched here

# settings/data to be shown by showconf/showdata
SHOWCONF += SELECT_ROWS
SHOWDATA +=

## default settings that must be changed before including this file

## variables
NEIGHBORHOODS = $(foreach row,${SELECT_ROWS},$(addsuffix .row${row}.nh,${DATA}))
PDATA = $(shell echo ${DATA}|tr ' ' '\n'|grep -v '\.m1')
NH_PLOTS = $(patsubst %.nh,%.png,$(foreach row,${SELECT_ROWS},\
	   $(addsuffix .row${row}.nh,${PDATA})))
HIST2D = $(addsuffix .png,${PDATA})

## rules
extract_argument = $(shell echo $@|egrep -o '\.$(1)[0-9]+\.'|grep -o '[0-9]*')

define template_calc
$(1).row%.nh: $(firstword ${datadirs})/$(2) $(1)
	$$(SCR)/get_neighborhood.sh $$+ $$* $$(call extract_argument,m) > $$@
endef

%.tex: %.nh $(SCR)/plot_neighborhood.gp
	gnuplot -e 'FILE="$(basename $<)"' $(lastword $+)

%.pdf: % $(SCR)/plot_neighborhoods.gp
	$(eval reffile := $(shell $(SCR)/reffile_search.sh\
		${HIST2D_REFDIR} $<-V01-V02.hist))
	gnuplot -e 'FILE="$<"; HIST2D="$(reffile)"' $(lastword $+)

## macros to be called later
MACROS += rule_neighbors
define rule_neighbors
$(foreach file,${DATA},\
	$(eval $(call template_calc,${file},$(shell\
		echo ${file} | sed \
			-e 's/\.m[0-9]*.k[0-9]*$$//' \
			-e 's/\.dle[_a-z0-9]*$$//'))))
endef

## info
ifndef INFO
INFO = calc plot plot2d
define INFOADD
endef
else
INFOend +=
endif
INFO_calc       = get coordinates for given neighbor indices
INFO_plot       = plot two dimensional neighborhoods
INFO_plot2d     = plot neighborhood positions in V1-V2 plane

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(NH_PLOTS) $(patsubst %.png,%.box,${NH_PLOTS}) $(HIST2D)
CLEAN_LIST +=
PURGE_LIST += $(NEIGHBORHOODS)
