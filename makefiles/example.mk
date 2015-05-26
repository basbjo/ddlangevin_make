.PHONY: example exampleconf plot
example: $$(EXAMPLE)$$(TIME_UNIT) exampleconf

exampleconf:
	@echo
	@echo The following settings in config.mk
	@echo
	@grep '^projtarget' config.mk
	@sed -i '/^projtarget/s/=.*/=/' config.mk
	@echo
	@echo have been changed as follows.
	@echo
	@grep '^projtarget' config.mk

plot: split trajs.png

## default settings
TIME_STEP ?= 0.005
EXAMPLE ?= mle2$(example_suffix)_$(TIME_STEP)

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA +=

## default settings that must be changed before including this file
MLE = $(makedir)/example/make_example$(example_suffix)

## variables

## rules
$(MLE): $(MLE).c
	cd $(@D) && $(MAKE) $(@F)

$(EXAMPLE)$(TIME_UNIT): $(MLE).c | $(MLE)
	$| $(TIME_STEP) > $@

trajs.png: trajs.gp $(wildcard ${splitdir}/*)
	gnuplot -e 'EXAMPLE="$(EXAMPLE)$(TIME_UNIT)"' $<

## macros to be called later
#MACROS +=

## info
ifndef INFO
INFO =
define INFOADD
endef
else
INFOend += example exampleconf plot
endif
INFO_example = create example trajectory
INFO_exampleconf = set example configuration
INFO_plot = plot example trajectories

## keep intermediate files
PRECIOUS +=

## clean
PLOTS_LIST +=
CLEAN_LIST +=
PURGE_LIST += $(EXAMPLE)$(TIME_UNIT) trajs.png $(MLE)
