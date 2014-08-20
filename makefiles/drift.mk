.PHONY: calc
calc: $$(DRIFT_DATA)

## default settings
DRIFT_LAST_COL ?= 2# last column (optional)

# settings/data to be shown by showconf/showdata
SHOWCONF += DRIFT_LAST_COL
SHOWDATA +=

## default settings that must be changed before including this file
driftdir ?= driftdata

## variables
DIR_LIST += $(driftdir)
DRIFT_DATA = $(addprefix $(driftdir)/,$(call add-V01-V02,\
	     ${DATA},.2ddrifthist,DRIFT))

## rules
$(driftdir):
	mkdir -p $@

# drift field calculation
define template_calc
$(driftdir)/$(1)-V$(2)-V$(3).2ddrifthist : $$(MINMAXFILE) $(1) | $$(driftdir)
	$$(SCR)/calc_drift.sh $(1) $(2) $(3) "$$(strip $${MINMAXFILE})"\
		$$(driftdir) $$(strip $${IF_FUTURE}) $$(strip $${TIME_UNIT})
endef

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
INFO = calc
INFO_calc = calculate drift fields
define INFOADD

Reference binning ranges are read from »$(MINMAXFILE)«.

endef
else
INFOend +=
endif

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST += $(DRIFT_DATA) $(patsubst %.2ddrifthist,%.1ddrifthist,${DRIFT_DATA})
PURGE_LIST +=
