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
	@echo The followig settings in config.mk
	@echo
	@grep '^\(TIME_UNIT\|RAWDATA\|IF_FUTURE\|projtarget\|M.._COL\)' config.mk
	@sed -i '/^TIME_UNIT/s/=.*/= ps/' config.mk
	@sed -i '/^RAWDATA/s/=.*/= example_1$$(TIME_UNIT)/' config.mk
	@sed -i '/^IF_FUTURE/s/= *[01]/= 0/' config.mk
	@sed -i '/^projtarget/s/=.*/= pca/' config.mk
	@sed -i '/^MIN_COL/s/=.*/= 1/' config.mk
	@sed -i '/^MAX_COL/s/=.*/= 2/' config.mk
	@echo
	@echo have been changed to the following.
	@echo
	@grep '^\(TIME_UNIT\|RAWDATA\|IF_FUTURE\|projtarget\|M.._COL\)' config.mk

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
