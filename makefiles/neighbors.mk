.PHONY: calc
calc: $$(NEIGHBORHOODS)

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF += SELECT_ROWS
SHOWDATA +=

## default settings that must be changed before including this file

## variables
SDATA = $(shell echo ${DATA}|tr ' ' '\n'|grep '\.m2')# only 2D is supported
NEIGHBORHOODS = $(foreach row,${SELECT_ROWS},$(addsuffix .row${row}.nh,${SDATA}))

## rules
define template_calc
$(1).row%.nh: $(firstword ${datadirs})/$(2) $(1)
	$$(SCR)/get_neighborhood.sh $$+ $$* > $$@
endef

## macros to be called later
MACROS += rule_neighbors
define rule_neighbors
$(foreach file,${SDATA},\
	$(eval $(call template_calc,${file},$(shell\
		echo ${file} | sed 's/\.m[0-9]*.k[0-9]*$$//'))))
endef

## info
ifndef INFO
INFO = calc
define INFOADD

Currently only neighborhoods in two dimensions are supported.

endef
else
INFOend +=
endif
INFO_calc       = get coordinates for given neighbor indices

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST += $(NEIGHBORHOODS)
