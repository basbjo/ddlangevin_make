## default target
.SECONDEXPANSION:
all: $$(all)

## default variables
SCR ?= $(makedir)/scripts# scripts directory

## common variables

## common phony targets
.PHONY: all

.PRECIOUS: $$(PRECIOUS)

## common rules

## common macros
