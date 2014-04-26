.PHONY: target
target:

## default settings

# settings/data to be shown by showconf/showdata
SHOWCONF +=
SHOWDATA +=

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
