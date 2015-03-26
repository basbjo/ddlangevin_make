.PHONY: calc plot
calc: $$(NEIGHBORHOODS)

plot: calc $$(NH_PLOTS)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += SELECT_ROWS
SHOWDATA +=

## default settings that must be changed before including this file

## variables
SDATA = $(shell echo ${DATA}|tr ' ' '\n'|grep '\.m2')# only 2D is supported
NEIGHBORHOODS = $(foreach row,${SELECT_ROWS},$(addsuffix .row${row}.nh,${SDATA}))
NH_PLOTS = $(patsubst %.nh,%.png,${NEIGHBORHOODS})

## rules
define template_calc
$(1).row%.nh: $(firstword ${datadirs})/$(2) $(1)
	$$(SCR)/get_neighborhood.sh $$+ $$* > $$@
endef

%.tex: %.nh $(SCR)/plot_neighborhood.gp
	gnuplot -e 'FILE="$(basename $<)"' $(lastword $+)

## macros to be called later
MACROS += rule_neighbors
define rule_neighbors
$(foreach file,${SDATA},\
	$(eval $(call template_calc,${file},$(shell\
		echo ${file} | sed 's/\.m[0-9]*.k[0-9]*$$//'))))
endef

## info
ifndef INFO
INFO = calc plot
define INFOADD

Currently only neighborhoods in two dimensions are supported.

endef
else
INFOend +=
endif
INFO_calc       = get coordinates for given neighbor indices
INFO_plot       = plot two dimensional neighborhoods

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST += $(NH_PLOTS) $(patsubst %.png,%.box,${NH_PLOTS})
CLEAN_LIST +=
PURGE_LIST += $(NEIGHBORHOODS)
