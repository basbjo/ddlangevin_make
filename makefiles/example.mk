.PHONY: example
example: example_1ps

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA +=

## default settings that must be changed before including this file
MLE = $(makedir)/example/make_example

## variables

## rules
$(MLE): $(MLE).c
	cd $(@D) && $(MAKE)

example_1ps: $(MLE)
	$< > $@
	@echo
	@echo The following settings in config.mk
	@echo
	@grep '^\(RAWDATA\|projtarget\)' config.mk
	@sed -i '/^RAWDATA/s/=.*/= example_1$$(TIME_UNIT)/' config.mk
	@sed -i '/^projtarget/s/=.*/= colselect pca/' config.mk
	@echo
	@echo have been changed as follows.
	@echo
	@grep '^\(RAWDATA\|projtarget\)' config.mk

## macros to be called later
#MACROS +=

## info
ifndef INFO
INFO =
define INFOADD
endef
else
INFOend += example
endif
INFO_example = create example trajectory

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST +=
