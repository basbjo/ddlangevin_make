## default target
.SECONDEXPANSION:
all: $$(all)

## default variables
SCR ?= $(makedir)/scripts# scripts directory

## common variables

## source data files
DATA += $(wildcard ${DATA_HERE})

## common phony targets
.PHONY: all

.PRECIOUS: $$(PRECIOUS)

## common rules

## common macros
