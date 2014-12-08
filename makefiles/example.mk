.PHONY: example exampleconf
example: $$(EXAMPLE)$$(TIME_UNIT) exampleconf

exampleconf:
	@echo
	@echo The following settings in config.mk
	@echo
	@grep '^\(RAWDATA\|projtarget\)' config.mk
	@sed -i '/^RAWDATA/s/=.*/= $(EXAMPLE)$$(TIME_UNIT)/' config.mk
	@sed -i '/^projtarget/s/=.*/= colselect pca/' config.mk
	@echo
	@echo have been changed as follows.
	@echo
	@grep '^\(RAWDATA\|projtarget\)' config.mk

## default settings
TIME_STEP ?= 0.001
EXAMPLE ?= example_$(TIME_STEP)

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA +=

## default settings that must be changed before including this file
MLE = $(makedir)/example/make_example

## variables

## rules
$(MLE): $(MLE).c
	cd $(@D) && $(MAKE)

$(EXAMPLE)$(TIME_UNIT): $(MLE)
	$< > $@

## macros to be called later
#MACROS +=

## info
ifndef INFO
INFO =
define INFOADD
endef
else
INFOend += example exampleconf
endif
INFO_example = create example trajectory
INFO_exampleconf = set example configuration

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST += $(EXAMPLE)$(TIME_UNIT)
