.PHONY: target
target:

## default settings

## default settings that must be changed before including this file

## variables

## rules

## macros to be called later
MACROS +=

## info
ifndef INFO
INFO = target
define INFOADD

Further information

endef
else
INFOend += target
endif
INFO_target = description

## keep intermediate files
PRECIOUS +=
