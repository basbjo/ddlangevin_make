## default target
.SECONDEXPANSION:
all: $$(all)

## default variables
SCR ?= $(makedir)/scripts# scripts directory
datadirs ?= $(prefix)# remote data directories
DROPSUFFIX ?= # data filename suffix to be omitted in link names

## common variables

## macros to be called later
MACROS +=

## macro to call several macros later
define call_macros
$(foreach macro,${MACROS},$(call ${macro}))
endef

## source data files
DATA += $(sort $(wildcard ${DATA_HERE}) ${DATALINKS})#without repetitions
REMOTEDATA += $(foreach wildcard,${DATA_LINK},$(foreach dir,${datadirs},\
	      $(wildcard ${dir}/${wildcard})))
DATALINKS = $(notdir $(patsubst %${DROPSUFFIX},%,${REMOTEDATA}))

## common phony targets
.PHONY: all

.PRECIOUS: $$(PRECIOUS)

## common rules

## common macros
