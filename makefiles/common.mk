## default target
.SECONDEXPANSION:
all: $$(all)

## default variables
SCR ?= $(makedir)/scripts# scripts directory
datadirs ?= $(prefix)# remote data directories
DROPSUFFIX ?= # data filename suffix to be omitted in link names

## common variables
SYMLINKS += $(DATALINKS)

## macros to be called later
MACROS += rule_data_links

## macro to call several macros later
define call_macros
$(foreach macro,${MACROS},$(call ${macro}))
endef

## source data files
DATA += $(sort $(wildcard ${DATA_HERE}) ${DATALINKS})#without repetitions
REMOTEDATA += $(foreach wildcard,${DATA_LINK},$(foreach dir,${datadirs},\
	      $(wildcard ${dir}/${wildcard})))
DATALINKS = $(notdir $(patsubst %${DROPSUFFIX},%,${REMOTEDATA}))
SHOWDATA += DATA datadirs DROPSUFFIX REMOTEDATA# to be shown by showdata

# symbolic links to source data files
define template_data_links
$(1): $(2)
	$$(if $$(wildcard $$@),,ln -s $$< $$@)
endef
define rule_data_links
$(foreach file,${REMOTEDATA},$(eval $(call template_data_links,\
	$(notdir $(patsubst %${DROPSUFFIX},%,${file})),${file})))
endef

# reread makefiles after creating links
-include .data
.data: $$(DATALINKS); @touch $@

## common phony targets
define INFO_start

Specific targets:
  all            $(all)
endef

define INFO_common
Common targets: info, show, showconf, showdata, showmacros,
  mksymlinks, rmsymlinks.
endef

info: ;@true
	$(info ${INFO_start})
	$(foreach target,${INFO},$(info $(shell\
		printf "  %-12s\n" ${target} '${INFO_${target}}')))
	$(foreach target,${INFOend},$(if $(filter\
		${target},${INFO}),,$(info $(shell\
		printf "  %-12s\n" ${target} '${INFO_${target}}'))))
	$(info )
	$(info ${INFO_common})
	$(info ${INFOADD})

show: showconf showdata showmacros

showconf: ;@true
	$(foreach var,${SHOWCONF},$(info ${var} = ${${var}}))
	$(info )

showdata: ;@true
	$(foreach var,${SHOWDATA},$(info ${var} = ${${var}}))
	$(info )

showmacros: ;@true
	$(info MACROS = $(MACROS))

mksymlinks: $$(SYMLINKS)

rmsymlinks:
	$(RM) $(foreach file,${SYMLINKS},$(if $(shell\
		[ -h ${file} ] && echo yes),${file}))
	@$(RM) .data

.PHONY: all info show showconf showdata showmacros\
	mksymlinks rmsymlinks

.PRECIOUS: $$(PRECIOUS)

## common rules

## common macros
